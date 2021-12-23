# frozen_string_literal: true

class Harbor < ActiveRecord::Base
  has_many :ships
  has_one :lighthouse
end

class DangerousHarbor < Harbor
  self.table_name = "harbors"

  # this verifies that we handle more than one column in a single call
  accepts_nested_attributes_for :lighthouse, :ships, allow_destroy: true
end

class SafeHarbor < Harbor
  self.table_name = "harbors"

  # this verifies that we handle more than one call
  accepts_nested_attributes_for :ships
  accepts_nested_attributes_for :lighthouse
end
