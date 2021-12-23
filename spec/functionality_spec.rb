# frozen_string_literal: true

require 'spec_helper'

require_relative 'support/models/harbor.rb'
require_relative 'support/models/lighthouse.rb'
require_relative 'support/models/ship.rb'

RSpec.describe 'Nested attributes functionality' do
  context 'has_many relationship' do
    context 'nested attributes can be destroyed' do
      let(:harbor) { DangerousHarbor.create(name: 'Blue Lagoon') }
      let!(:ship1) { (harbor.ships << Ship.create(harbor: harbor)).first }
      let!(:ship2) { (harbor.ships << Ship.create(harbor: harbor)).first }

      context 'nested collection has one destroyed object' do
        it 'returns true' do
          harbor.ships_attributes = [
            ship1.attributes.merge('_destroy': true),
            ship2.attributes.merge(fuel_remaining: 10)
          ]

          harbor.save!

          expect(harbor).to be_ships_destroyed_during_save
        end
      end

      context 'nested collection has more than one destroyed object' do
        it 'returns true' do
          harbor.ships_attributes = [
            ship1.attributes.merge('_destroy': true),
            ship2.attributes.merge('_destroy': true)
          ]

          harbor.save!

          expect(harbor).to be_ships_destroyed_during_save
        end
      end

      context 'nested collection has zero destroyed objects' do
        it 'returns false' do
          harbor.ships_attributes = [
            ship1.attributes.merge(fuel_remaining: 10),
            ship2.attributes.merge(fuel_remaining: 5)
          ]

          harbor.save!

          expect(harbor).not_to be_ships_destroyed_during_save
        end
      end

      context 'destroyed state is reset on every save' do
        it 'returns true and then false' do
          harbor.ships_attributes = [
            ship1.attributes.merge('_destroy': true),
            ship2.attributes.merge(fuel_remaining: 10)
          ]

          harbor.save!
          expect(harbor).to be_ships_destroyed_during_save

          harbor.save!
          expect(harbor).not_to be_ships_destroyed_during_save
        end
      end
    end

    context 'nested attributes cannot be destroyed' do
      let(:harbor) { SafeHarbor.create(name: 'Blue Lagoon') }
      let!(:ship) { (harbor.ships << Ship.create(harbor: harbor)).first }

      it 'returns false' do
        harbor.ships_attributes = [
          ship.attributes.merge('_destroy': true)
        ]

        harbor.save!

        expect(harbor).not_to be_ships_destroyed_during_save
      end
    end
  end

  context 'has_one relationship' do
    context 'nested attribute can be destroyed' do
      let(:harbor) { DangerousHarbor.create(name: 'Blue Lagoon') }
      let!(:lighthouse) { Lighthouse.create(harbor: harbor) }

      context 'attribute was destroyed' do
        it 'returns true' do
          harbor.lighthouse_attributes =
            lighthouse.attributes.merge('_destroy': true)

          harbor.save!

          expect(harbor).to be_lighthouse_destroyed_during_save
        end
      end

      context 'attribute was not destroyed' do
        it 'returns false' do
          harbor.lighthouse_attributes =
            lighthouse.attributes.merge(name: "Red 'n White")

          harbor.save!

          expect(harbor).not_to be_lighthouse_destroyed_during_save
        end
      end
    end

    context 'nested attribute cannot be destroyed' do
      let(:harbor) { SafeHarbor.create(name: 'Blue Lagoon') }
      let!(:lighthouse) { Lighthouse.create(harbor: harbor) }

      it 'returns false' do
        harbor.lighthouse_attributes =
          lighthouse.attributes.merge('_destroy': true)

        harbor.save!

        expect(harbor).not_to be_lighthouse_destroyed_during_save
      end
    end
  end
end
