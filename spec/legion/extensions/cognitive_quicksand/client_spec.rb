# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveQuicksand::Client do
  subject(:client) { described_class.new }

  it 'includes the runner module' do
    expect(described_class.ancestors).to include(
      Legion::Extensions::CognitiveQuicksand::Runners::CognitiveQuicksand
    )
  end

  it 'responds to create_trap' do
    expect(client).to respond_to(:create_trap)
  end

  it 'responds to struggle' do
    expect(client).to respond_to(:struggle)
  end

  it 'responds to attempt_escape' do
    expect(client).to respond_to(:attempt_escape)
  end

  it 'responds to quicksand_status' do
    expect(client).to respond_to(:quicksand_status)
  end

  it 'can create and struggle through client' do
    result = client.create_trap(trap_type: :overthinking, domain: :test, content: 'loop')
    expect(result[:success]).to be true
    trap_id = result[:trap][:id]
    struggle_result = client.struggle(trap_id: trap_id)
    expect(struggle_result[:success]).to be true
  end
end
