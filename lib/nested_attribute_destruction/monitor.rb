# frozen_string_literal: true

module NestedAttributeDestruction
  class Monitor
    def initialize
      @attributes_marked_for_destruction = Set.new
      @attributes_destroyed_during_last_save = Set.new
    end

    class << self
      def define_hooks(klass)
        return if hooks_defined?(klass)

        define_callbacks(klass)
        redefine_reload(klass)

        hooks_defined!(klass)
      end

      def define_predicate(klass, assoc_name)
        klass.define_method("#{assoc_name}_destroyed_during_save?") do
          @nested_attribute_destruction_monitor ||= NestedAttributeDestruction::Monitor.new
          @nested_attribute_destruction_monitor.send(:destroyed_during_save?, assoc_name.to_sym)
        end
      end

      private

      def define_callbacks(klass)
        klass.before_update do |obj|
          @nested_attribute_destruction_monitor ||= NestedAttributeDestruction::Monitor.new
          @nested_attribute_destruction_monitor.send(:store_attributes_marked_for_destruction, obj)
        end

        klass.after_commit(on: :update) do
          @nested_attribute_destruction_monitor.send(:save_succeeded)
        end
      end

      def hooks_defined?(klass)
        klass.instance_variable_get(:@nested_attribute_destruction_monitor_hooks_defined)
      end

      def hooks_defined!(klass)
        klass.instance_variable_set(:@nested_attribute_destruction_monitor_hooks_defined, true)
      end

      def redefine_reload(klass)
        klass.alias_method :_rails_reload, :reload

        klass.class_eval do
          def reload(*args)
            ret_val = _rails_reload(*args)

            # run our code after rails' code, in case the rails code blows up
            @nested_attribute_destruction_monitor&.send(:reset)

            # make sure we return the value that rails intended
            ret_val
          end
        end
      end
    end

    private

    def clear_attributes_marked_for_destruction
      @attributes_marked_for_destruction.clear
    end

    def clear_attributes_stored_during_last_save
      @attributes_destroyed_during_last_save.clear
    end

    def destroyed_during_save?(assoc_name)
      @attributes_destroyed_during_last_save.include?(assoc_name.to_sym)
    end

    def reset
      @attributes_marked_for_destruction.clear
      @attributes_destroyed_during_last_save.clear
    end

    def save_succeeded
      clear_attributes_stored_during_last_save
      stored_attributes_were_destroyed
      clear_attributes_marked_for_destruction
    end

    def store_attributes_marked_for_destruction(obj)
      watched_associations(obj).each_pair do |assoc, type|
        if type == :many
          store_many_association(obj, assoc)
        else
          store_one_association(obj, assoc)
        end
      end
    end

    def store_many_association(obj, assoc_name)
      return unless obj.send(assoc_name).load_target.any? do |el|
        el.marked_for_destruction? && !el.destroyed?
      end

      @attributes_marked_for_destruction.add(assoc_name)
    end

    def store_one_association(obj, assoc_name)
      return unless obj.send(assoc_name)&.marked_for_destruction? &&
                    !obj.send(assoc_name)&.destroyed?

      @attributes_marked_for_destruction.add(assoc_name)
    end

    def stored_attributes_were_destroyed
      @attributes_destroyed_during_last_save +=
        @attributes_marked_for_destruction
    end

    def watched_associations(obj)
      obj.class.nested_attribute_destruction_watch_associations
    end
  end
end
