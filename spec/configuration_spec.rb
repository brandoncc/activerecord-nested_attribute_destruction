# frozen_string_literal: true

require 'spec_helper'

require_relative 'support/models/harbor.rb'
require_relative 'support/models/ship.rb'

RSpec.describe 'Verify gem configuration' do
  it 'can have a harbor' do
    Harbor.new
  end

  it 'validates ship name' do
    expect { Harbor.create }.to raise_error(ActiveRecord::NotNullViolation)
  end

  it 'can have ships in a harbor' do
    harbor = Harbor.create(name: 'Smokey Beach')

    3.times do
      harbor.ships << Ship.new
    end

    expect(harbor.ships.size).to eq(3)
  end
end
