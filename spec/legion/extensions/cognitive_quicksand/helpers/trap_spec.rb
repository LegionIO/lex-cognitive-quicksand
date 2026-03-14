# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveQuicksand::Helpers::Trap do
  subject(:trap) do
    described_class.new(trap_type: :overthinking, domain: :reasoning, content: 'recursive loop')
  end

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(trap.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets trap_type as symbol' do
      expect(trap.trap_type).to eq(:overthinking)
    end

    it 'defaults depth to 0.3' do
      expect(trap.depth).to eq(0.3)
    end

    it 'defaults viscosity to 0.5' do
      expect(trap.viscosity).to eq(0.5)
    end

    it 'starts with 0 struggle_count' do
      expect(trap.struggle_count).to eq(0)
    end

    it 'accepts custom depth' do
      t = described_class.new(trap_type: :rumination, domain: :t, content: 'x', depth: 0.7)
      expect(t.depth).to eq(0.7)
    end

    it 'clamps depth to 0..1' do
      t = described_class.new(trap_type: :indecision, domain: :t, content: 'x', depth: 5.0)
      expect(t.depth).to eq(1.0)
    end

    it 'raises on unknown trap type' do
      expect do
        described_class.new(trap_type: :happiness, domain: :t, content: 'x')
      end.to raise_error(ArgumentError, /unknown trap type/)
    end
  end

  describe '#sink!' do
    it 'increases depth' do
      initial = trap.depth
      trap.sink!
      expect(trap.depth).to eq((initial + 0.08).round(10))
    end

    it 'accepts custom rate' do
      trap.sink!(rate: 0.2)
      expect(trap.depth).to eq(0.5)
    end

    it 'clamps at 1.0' do
      trap.depth = 0.95
      trap.sink!(rate: 0.2)
      expect(trap.depth).to eq(1.0)
    end
  end

  describe '#struggle!' do
    it 'increases depth based on viscosity' do
      initial = trap.depth
      trap.struggle!
      penalty = 0.12 * 0.5
      expect(trap.depth).to eq((initial + penalty).round(10))
    end

    it 'increments struggle_count' do
      trap.struggle!
      expect(trap.struggle_count).to eq(1)
    end

    it 'sinks faster with high viscosity' do
      trap.viscosity = 0.9
      initial = trap.depth
      trap.struggle!
      expect(trap.depth).to be > (initial + 0.1)
    end
  end

  describe '#calm!' do
    it 'decreases depth' do
      initial = trap.depth
      trap.calm!
      expect(trap.depth).to eq((initial - 0.03).round(10))
    end

    it 'clamps at 0' do
      trap.depth = 0.01
      trap.calm!(rate: 0.1)
      expect(trap.depth).to eq(0.0)
    end
  end

  describe '#escape!' do
    it 'returns :escaped when shallow enough' do
      trap.depth = 0.5
      expect(trap.escape!).to eq(:escaped)
      expect(trap.depth).to eq(0.0)
    end

    it 'returns :too_deep when too deep' do
      trap.depth = 0.8
      expect(trap.escape!).to eq(:too_deep)
    end
  end

  describe '#submerged?' do
    it 'returns false at default depth' do
      expect(trap).not_to be_submerged
    end

    it 'returns true at 0.8+' do
      trap.depth = 0.85
      expect(trap).to be_submerged
    end
  end

  describe '#surface?' do
    it 'returns false at default depth' do
      expect(trap).not_to be_surface
    end

    it 'returns true below 0.2' do
      trap.depth = 0.1
      expect(trap).to be_surface
    end
  end

  describe '#stuck?' do
    it 'returns false at default' do
      expect(trap).not_to be_stuck
    end

    it 'returns true when deep and viscous' do
      trap.depth = 0.6
      trap.viscosity = 0.7
      expect(trap).to be_stuck
    end
  end

  describe '#depth_label' do
    it 'returns :ankle_deep at default' do
      expect(trap.depth_label).to eq(:ankle_deep)
    end
  end

  describe '#viscosity_label' do
    it 'returns :moderate at default' do
      expect(trap.viscosity_label).to eq(:moderate)
    end
  end

  describe '#to_h' do
    it 'includes all expected keys' do
      expected = %i[id trap_type domain content depth viscosity depth_label
                    viscosity_label struggle_count submerged surface stuck created_at]
      expect(trap.to_h.keys).to match_array(expected)
    end
  end
end
