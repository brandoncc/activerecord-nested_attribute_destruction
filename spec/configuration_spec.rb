# frozen_string_literal: true

require "spec_helper"

require_relative "support/models/harbor"
require_relative "support/models/lighthouse"
require_relative "support/models/ship"

RSpec.describe "Verify gem configuration" do
  it "can have a harbor" do
    Harbor.new
  end

  it "validates ship name" do
    expect { Harbor.create }.to raise_error(ActiveRecord::NotNullViolation)
  end

  it "can have ships in a harbor" do
    harbor = Harbor.create(name: "Smokey Beach")

    3.times do
      harbor.ships << Ship.new
    end

    expect(harbor.ships.size).to eq(3)
  end

  it "dangerous harbors can destroy ships" do
    harbor = DangerousHarbor.create(name: "Pirate's Cove")
    ship = (harbor.ships << Ship.new).first

    harbor.ships_attributes = [ship.attributes.merge('_destroy': true)]

    expect(harbor.ships.load_target.find { |s| s.id == ship.id })
      .to be_marked_for_destruction

    harbor.reload

    expect(harbor.ships.load_target.find { |s| s.id == ship.id })
      .not_to be_marked_for_destruction

    harbor.save!

    expect(harbor.reload.ships.size).not_to be_zero
  end

  it "dangerous harbors can destroy their lighthouse" do
    harbor = DangerousHarbor.create(name: "Pirate's Cove")

    harbor.update!(lighthouse: Lighthouse.new)
    lighthouse = harbor.lighthouse

    harbor.lighthouse_attributes = lighthouse.attributes.merge('_destroy': true)
    harbor.save!

    expect(harbor.reload.lighthouse).to be_nil
    expect(Lighthouse.all.count).to be_zero
  end

  it "safe harbors cannot destroy ships" do
    harbor = SafeHarbor.create(name: "Still Waters")
    ship = (harbor.ships << Ship.new).first

    harbor.ships_attributes = [ship.attributes.merge('_destroy': true)]

    expect(harbor.ships.load_target.find { |s| s.id == ship.id })
      .not_to be_marked_for_destruction

    harbor.save!

    expect(harbor.reload.ships.size).to eq(1)
  end

  it "safe harbors cannot destroy their lighthouse" do
    harbor = SafeHarbor.create(name: "Pirate's Cove")

    lighthouse = Lighthouse.create(harbor: harbor)

    harbor.lighthouse_attributes = lighthouse.attributes.merge('_destroy': true)
    harbor.save!

    expect(harbor.reload.lighthouse.id).to eq(lighthouse.id)
  end
end
