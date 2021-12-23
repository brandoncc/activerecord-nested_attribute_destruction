# frozen_string_literal: true

class Ship < ActiveRecord::Base
  belongs_to :harbor
end
