# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveQuicksand::Runners::CognitiveQuicksand do
  let(:runner) do
    obj = Object.new
    obj.extend(described_class)
    obj
  end

  let(:engine) { Legion::Extensions::CognitiveQuicksand::Helpers::QuicksandEngine.new }

  describe '#create_trap' do
    it 'returns success' do
      result = runner.create_trap(trap_type: :overthinking, domain: :reasoning,
                                  content: 'test', engine: engine)
      expect(result[:success]).to be true
      expect(result[:trap][:trap_type]).to eq(:overthinking)
    end

    it 'returns failure for invalid type' do
      result = runner.create_trap(trap_type: :joy, domain: :t, content: 'x', engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '#create_pit' do
    it 'returns success' do
      result = runner.create_pit(engine: engine)
      expect(result[:success]).to be true
      expect(result[:pit]).to be_a(Hash)
    end
  end

  describe '#struggle' do
    it 'returns trap with struggle data' do
      t = engine.create_trap(trap_type: :overthinking, domain: :t, content: 'x')
      result = runner.struggle(trap_id: t.id, engine: engine)
      expect(result[:success]).to be true
      expect(result[:struggle_count]).to eq(1)
    end

    it 'returns failure for unknown trap' do
      result = runner.struggle(trap_id: 'bad', engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '#calm_down' do
    it 'decreases depth' do
      t = engine.create_trap(trap_type: :rumination, domain: :t, content: 'x', depth: 0.5)
      result = runner.calm_down(trap_id: t.id, engine: engine)
      expect(result[:success]).to be true
      expect(result[:trap][:depth]).to be < 0.5
    end
  end

  describe '#attempt_escape' do
    it 'returns escape result' do
      t = engine.create_trap(trap_type: :indecision, domain: :t, content: 'x', depth: 0.4)
      result = runner.attempt_escape(trap_id: t.id, engine: engine)
      expect(result[:success]).to be true
      expect(result[:result]).to eq(:escaped)
    end
  end

  describe '#list_traps' do
    before do
      engine.create_trap(trap_type: :overthinking, domain: :t, content: 'a')
      engine.create_trap(trap_type: :rumination, domain: :t, content: 'b')
    end

    it 'returns all traps' do
      result = runner.list_traps(engine: engine)
      expect(result[:count]).to eq(2)
    end

    it 'filters by trap_type' do
      result = runner.list_traps(trap_type: :overthinking, engine: engine)
      expect(result[:count]).to eq(1)
    end
  end

  describe '#quicksand_status' do
    it 'returns report' do
      result = runner.quicksand_status(engine: engine)
      expect(result[:success]).to be true
      expect(result[:report]).to include(:total_traps)
    end
  end
end
