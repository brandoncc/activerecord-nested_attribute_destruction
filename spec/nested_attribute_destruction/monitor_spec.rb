# frozen_string_literal: true

RSpec.describe NestedAttributeDestruction::Monitor do
  describe '#watch' do
    it 'raises an error if the association type is unknown' do
      expect { subject.watch(:assoc_name, :fake_assoc_type) }
        .to raise_error(NestedAttributeDestruction::Monitor::InvalidAssociationType)
    end
  end
end
