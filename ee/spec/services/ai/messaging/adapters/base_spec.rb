# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Messaging::Adapters::Base, feature_category: :duo_agent_platform do
  subject(:adapter) { described_class.new }

  let(:callback_context) { { 'adapter' => 'test', 'channel' => 'C123' } }

  describe '#deliver_result' do
    it 'raises NotImplementedError' do
      expect do
        adapter.deliver_result(callback_context: callback_context, message: 'hello')
      end.to raise_error(NotImplementedError, /must implement #deliver_result/)
    end
  end

  describe '#deliver_error' do
    it 'raises NotImplementedError' do
      expect do
        adapter.deliver_error(callback_context: callback_context, error: :flow_failed)
      end.to raise_error(NotImplementedError, /must implement #deliver_error/)
    end
  end

  describe '#on_flow_started' do
    it 'is a no-op by default' do
      expect(adapter.on_flow_started(callback_context: callback_context, workflow: nil)).to be_nil
    end
  end

  describe '#on_flow_completed' do
    it 'is a no-op by default' do
      expect(adapter.on_flow_completed(callback_context: callback_context, workflow: nil)).to be_nil
    end
  end

  describe '#on_flow_failed' do
    it 'delegates to deliver_error' do
      expect(adapter).to receive(:deliver_error).with(callback_context: callback_context, error: :flow_failed)

      adapter.on_flow_failed(callback_context: callback_context, error: :flow_failed)
    end
  end
end
