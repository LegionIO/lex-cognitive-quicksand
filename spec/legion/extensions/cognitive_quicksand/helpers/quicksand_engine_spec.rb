# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveQuicksand::Helpers::QuicksandEngine do
  subject(:engine) { described_class.new }

  let(:default_attrs) { { trap_type: :overthinking, domain: :reasoning, content: 'loop' } }

  describe '#create_trap' do
    it 'creates and stores a trap' do
      t = engine.create_trap(**default_attrs)
      expect(t).to be_a(Legion::Extensions::CognitiveQuicksand::Helpers::Trap)
      expect(engine.all_traps.size).to eq(1)
    end

    it 'raises when limit reached' do
      stub_const('Legion::Extensions::CognitiveQuicksand::Helpers::Constants::MAX_TRAPS', 1)
      engine.create_trap(**default_attrs)
      expect do
        engine.create_trap(trap_type: :rumination, domain: :t, content: 'x')
      end.to raise_error(ArgumentError, /trap limit/)
    end
  end

  describe '#create_pit' do
    it 'creates and stores a pit' do
      p = engine.create_pit
      expect(p).to be_a(Legion::Extensions::CognitiveQuicksand::Helpers::Pit)
      expect(engine.all_pits.size).to eq(1)
    end
  end

  describe '#sink_trap' do
    it 'increases trap depth' do
      t = engine.create_trap(**default_attrs)
      initial = t.depth
      engine.sink_trap(trap_id: t.id)
      expect(t.depth).to be > initial
    end

    it 'raises for unknown trap' do
      expect do
        engine.sink_trap(trap_id: 'bad')
      end.to raise_error(ArgumentError, /trap not found/)
    end
  end

  describe '#struggle' do
    it 'returns trap data with depth and count' do
      t = engine.create_trap(**default_attrs)
      result = engine.struggle(trap_id: t.id)
      expect(result[:struggle_count]).to eq(1)
      expect(result[:depth]).to be > 0.3
    end
  end

  describe '#calm' do
    it 'decreases trap depth' do
      t = engine.create_trap(**default_attrs)
      initial = t.depth
      engine.calm(trap_id: t.id)
      expect(t.depth).to be < initial
    end
  end

  describe '#attempt_escape' do
    it 'escapes when shallow' do
      t = engine.create_trap(**default_attrs, depth: 0.5)
      result = engine.attempt_escape(trap_id: t.id)
      expect(result[:result]).to eq(:escaped)
    end

    it 'fails when deep' do
      t = engine.create_trap(**default_attrs, depth: 0.9)
      result = engine.attempt_escape(trap_id: t.id)
      expect(result[:result]).to eq(:too_deep)
    end
  end

  describe '#add_trap_to_pit' do
    it 'links trap to pit' do
      t = engine.create_trap(**default_attrs)
      p = engine.create_pit
      expect(engine.add_trap_to_pit(trap_id: t.id, pit_id: p.id)).to eq(:added)
    end
  end

  describe '#sink_all!' do
    it 'sinks all traps' do
      t1 = engine.create_trap(**default_attrs)
      t2 = engine.create_trap(trap_type: :rumination, domain: :t, content: 'x')
      engine.sink_all!
      expect(t1.depth).to be > 0.3
      expect(t2.depth).to be > 0.3
    end
  end

  describe '#calm_all!' do
    it 'calms all traps' do
      t = engine.create_trap(**default_attrs, depth: 0.5)
      engine.calm_all!
      expect(t.depth).to be < 0.5
    end
  end

  describe '#traps_by_type' do
    it 'returns counts' do
      engine.create_trap(**default_attrs)
      engine.create_trap(trap_type: :rumination, domain: :t, content: 'x')
      counts = engine.traps_by_type
      expect(counts[:overthinking]).to eq(1)
      expect(counts[:rumination]).to eq(1)
    end
  end

  describe '#deepest' do
    it 'returns traps sorted by depth descending' do
      engine.create_trap(**default_attrs, depth: 0.2)
      t2 = engine.create_trap(trap_type: :rumination, domain: :t, content: 'x', depth: 0.9)
      expect(engine.deepest(limit: 1).first).to eq(t2)
    end
  end

  describe '#submerged_traps' do
    it 'returns only submerged' do
      engine.create_trap(**default_attrs, depth: 0.9)
      engine.create_trap(trap_type: :rumination, domain: :t, content: 'x', depth: 0.3)
      expect(engine.submerged_traps.size).to eq(1)
    end
  end

  describe '#stuck_traps' do
    it 'returns stuck traps' do
      engine.create_trap(**default_attrs, depth: 0.6, viscosity: 0.7)
      engine.create_trap(trap_type: :rumination, domain: :t, content: 'x', depth: 0.1)
      expect(engine.stuck_traps.size).to eq(1)
    end
  end

  describe '#quicksand_report' do
    it 'returns comprehensive hash' do
      engine.create_trap(**default_attrs)
      report = engine.quicksand_report
      expect(report).to include(:total_traps, :total_pits, :by_type,
                                :submerged, :stuck, :avg_depth, :deadly_pits)
    end

    it 'handles empty engine' do
      report = engine.quicksand_report
      expect(report[:total_traps]).to eq(0)
      expect(report[:avg_depth]).to eq(0.0)
    end
  end
end
