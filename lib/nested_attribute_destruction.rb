# frozen_string_literal: true

require_relative "nested_attribute_destruction/version"
require_relative "nested_attribute_destruction/monitor"

require_relative "active_record/nested_attributes/class_methods"

module NestedAttributeDestruction
  class Error < StandardError; end
end
