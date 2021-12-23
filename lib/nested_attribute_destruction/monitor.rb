# frozen_string_literal: true

module NestedAttributeDestruction
  class Monitor
    class InvalidAssociationType < StandardError; end

    def initialize
      @watched_associations = {}
      @attributes_marked_for_destruction = Set.new
      @attributes_destroyed_during_last_save = Set.new
    end

    def define_callbacks(klass)
      return if callbacks_defined?

      monitor = self
      klass.before_update { |obj| monitor.send(:store_attributes_marked_for_destruction, obj) }
      klass.after_update { monitor.send(:save_succeeded) }

      callbacks_defined!
    end

    def define_predicate(klass, assoc_name)
      monitor = self
      klass.define_method("#{assoc_name}_destroyed_during_save?") do
        monitor.send(:destroyed_during_save?, assoc_name.to_sym)
      end
    end

    def watch(association, type)
      raise InvalidAssociationType unless %i[one many].include?(type)

      add_watched_asociation(association, type)
    end

    private

    def add_watched_asociation(association, type)
      @watched_associations[association.to_sym] = type
    end

    def callbacks_defined?
      @callbacks_defined
    end

    def callbacks_defined!
      @callbacks_defined = true
    end

    def clear_attributes_marked_for_destruction
      @attributes_marked_for_destruction.clear
    end

    def clear_attributes_stored_during_last_save
      @attributes_destroyed_during_last_save.clear
    end

    def destroyed_during_save?(assoc_name)
      @attributes_destroyed_during_last_save.include?(assoc_name.to_sym)
    end

    def save_succeeded
      clear_attributes_stored_during_last_save
      stored_attributes_were_destroyed
      clear_attributes_marked_for_destruction
    end

    def store_attributes_marked_for_destruction(obj)
      @watched_associations.each_pair do |assoc, type|
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
  end
end
