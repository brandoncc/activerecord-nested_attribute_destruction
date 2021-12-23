# rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

unless defined?(ActiveRecord::NestedAttributes)
  raise "activerecord-nested_attribute_destruction gem must be loaded after active_record"
end

module ActiveRecord
  module NestedAttributes
    module ClassMethods
      alias _rails_accepts_nested_attributes_for accepts_nested_attributes_for

      # rubocop:disable Metrics/AbcSize
      def accepts_nested_attributes_for(*attr_names)
        _rails_accepts_nested_attributes_for(*attr_names)

        # remove any options from the end of the array
        attr_names.extract_options!

        unless respond_to?(:nested_attribute_destruction_watch_associations)
          self.class.define_method(:nested_attribute_destruction_watch_associations) do
            @nested_attribute_destruction_watch_associations || {}
          end
        end

        unless respond_to?(:nested_attribute_destruction_watch_association)
          self.class.define_method(:nested_attribute_destruction_watch_association) do |assoc, type|
            @nested_attribute_destruction_watch_associations ||= {}
            @nested_attribute_destruction_watch_associations[assoc.to_sym] = type
          end
        end

        NestedAttributeDestruction::Monitor.define_hooks(self) if attr_names.any?

        attr_names.each do |association_name|
          reflection = _reflect_on_association(association_name)
          next unless reflection

          type = (reflection.collection? ? :many : :one)

          nested_attribute_destruction_watch_association(association_name, type)
          NestedAttributeDestruction::Monitor.define_predicate(self, association_name)
        end
      end
    end
  end
end

# rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
# rubocop:enable Metrics/AbcSize
