# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveQuicksand::Helpers::Constants do
  described_class = Legion::Extensions::CognitiveQuicksand::Helpers::Constants

  describe 'TRAP_TYPES' do
    it 'contains expected types' do
      expect(described_class::TRAP_TYPES).to eq(%i[overthinking rumination analysis_paralysis
                                                   perfectionism indecision])
    end

    it 'is frozen' do
      expect(described_class::TRAP_TYPES).to be_frozen
    end
  end

  describe 'STRUGGLE_MODES' do
    it 'contains expected modes' do
      expect(described_class::STRUGGLE_MODES).to eq(%i[thrash freeze sink float escape])
    end
  end

  describe 'numeric constants' do
    it 'defines MAX_TRAPS' do
      expect(described_class::MAX_TRAPS).to eq(200)
    end

    it 'defines SINK_RATE' do
      expect(described_class::SINK_RATE).to eq(0.08)
    end

    it 'defines STRUGGLE_PENALTY' do
      expect(described_class::STRUGGLE_PENALTY).to eq(0.12)
    end

    it 'defines ESCAPE_THRESHOLD' do
      expect(described_class::ESCAPE_THRESHOLD).to eq(0.3)
    end
  end

  describe '.label_for' do
    it 'returns :submerged for high depth' do
      expect(described_class.label_for(described_class::DEPTH_LABELS, 0.9)).to eq(:submerged)
    end

    it 'returns :surface for low depth' do
      expect(described_class.label_for(described_class::DEPTH_LABELS, 0.1)).to eq(:surface)
    end

    it 'returns :concrete for high viscosity' do
      expect(described_class.label_for(described_class::VISCOSITY_LABELS, 0.9)).to eq(:concrete)
    end

    it 'returns :dry for low viscosity' do
      expect(described_class.label_for(described_class::VISCOSITY_LABELS, 0.1)).to eq(:dry)
    end
  end
end
