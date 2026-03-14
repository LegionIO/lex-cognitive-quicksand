# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveQuicksand::Helpers::Pit do
  subject(:pit) { described_class.new }

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(pit.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'defaults saturation to 0.5' do
      expect(pit.saturation).to eq(0.5)
    end

    it 'defaults danger_level to 0.3' do
      expect(pit.danger_level).to eq(0.3)
    end

    it 'starts with empty trap_ids' do
      expect(pit.trap_ids).to be_empty
    end
  end

  describe '#add_trap' do
    it 'adds a trap id' do
      expect(pit.add_trap('t-1')).to eq(:added)
      expect(pit.trap_ids).to include('t-1')
    end

    it 'returns :already_present for duplicates' do
      pit.add_trap('t-1')
      expect(pit.add_trap('t-1')).to eq(:already_present)
    end

    it 'recalculates danger level' do
      initial = pit.danger_level
      5.times { |i| pit.add_trap("t-#{i}") }
      expect(pit.danger_level).not_to eq(initial)
    end
  end

  describe '#remove_trap' do
    it 'removes a trap id' do
      pit.add_trap('t-1')
      expect(pit.remove_trap('t-1')).to eq(:removed)
    end

    it 'returns :not_found for missing' do
      expect(pit.remove_trap('nope')).to eq(:not_found)
    end
  end

  describe '#saturate!' do
    it 'increases saturation' do
      initial = pit.saturation
      pit.saturate!(rate: 0.1)
      expect(pit.saturation).to eq((initial + 0.1).round(10))
    end
  end

  describe '#drain!' do
    it 'decreases saturation' do
      initial = pit.saturation
      pit.drain!(rate: 0.1)
      expect(pit.saturation).to eq((initial - 0.1).round(10))
    end
  end

  describe '#deadly?' do
    it 'returns false at default' do
      expect(pit).not_to be_deadly
    end

    it 'returns true when danger_level >= 0.8' do
      pit.danger_level = 0.9
      expect(pit).to be_deadly
    end
  end

  describe '#safe?' do
    it 'returns false at default' do
      expect(pit).not_to be_safe
    end

    it 'returns true when danger_level < 0.2' do
      pit.danger_level = 0.1
      expect(pit).to be_safe
    end
  end

  describe '#trap_count' do
    it 'returns 0 initially' do
      expect(pit.trap_count).to eq(0)
    end
  end

  describe '#to_h' do
    it 'includes all expected keys' do
      expected = %i[id saturation danger_level trap_count deadly safe created_at]
      expect(pit.to_h.keys).to match_array(expected)
    end
  end
end
