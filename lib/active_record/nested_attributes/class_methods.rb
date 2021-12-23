raise 'nested_attribute_destruction gem must be loaded after active_record' unless defined?(ActiveRecord)

module ActiveRecord
  module NestedAttributes
    module ClassMethods
      alias_method :_rails_accepts_nested_attributes_for, :accepts_nested_attributes_for

      def accepts_nested_attributes_for(*attr_names)
        _rails_accepts_nested_attributes_for(*attr_names)

        # remove any options from the end of the array
        attr_names.extract_options!

        @nested_attribute_destruction ||= NestedAttributeDestruction::Monitor.new
        @nested_attribute_destruction.define_callbacks(self) if attr_names.any?

        attr_names.each do |association_name|
          reflection = _reflect_on_association(association_name)
          next unless reflection

          type = (reflection.collection? ? :many : :one)

          @nested_attribute_destruction.watch(association_name, type)
          @nested_attribute_destruction.define_predicate(self, association_name)
        end
      end
    end
  end
end
