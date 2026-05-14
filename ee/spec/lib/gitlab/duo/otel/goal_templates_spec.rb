# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Gitlab::Duo::Otel::GoalTemplates, feature_category: :duo_agent_platform do
  describe '.issue_title' do
    it 'returns the expected title' do
      expect(described_class.issue_title).to eq('Add OpenTelemetry instrumentation')
    end
  end

  describe '.build_description' do
    context 'for Ruby' do
      it 'returns Ruby template' do
        description = described_class.build_description('Ruby')

        expect(description).to include('Add OpenTelemetry SDK instrumentation to this Ruby project')
        expect(description).to include('opentelemetry-sdk')
        expect(description).to include('opentelemetry-instrumentation-rails')
        expect(description).to include('bundle install')
      end
    end

    context 'for JavaScript' do
      it 'returns JavaScript template' do
        description = described_class.build_description('JavaScript')

        expect(description).to include('Add OpenTelemetry SDK instrumentation to this Node.js project')
        expect(description).to include('@opentelemetry/sdk-node')
        expect(description).to include('getNodeAutoInstrumentations()')
        expect(description).to include('npm install')
      end
    end

    context 'for TypeScript' do
      it 'returns JavaScript template (same as JavaScript)' do
        description = described_class.build_description('TypeScript')

        expect(description).to include('Add OpenTelemetry SDK instrumentation to this Node.js project')
        expect(description).to include('@opentelemetry/sdk-node')
        expect(description).to include('npm install')
      end
    end

    context 'for Python' do
      it 'returns Python template' do
        description = described_class.build_description('Python')

        expect(description).to include('Add OpenTelemetry SDK instrumentation to this Python project')
        expect(description).to include('opentelemetry-sdk')
        expect(description).to include('TracerProvider')
        expect(description).to include('pip install -r requirements.txt')
      end
    end

    context 'for unknown language' do
      it 'returns default template' do
        description = described_class.build_description('Go')

        expect(description).to include('Add OpenTelemetry SDK instrumentation to this project')
        expect(description).to include("for this project's language")
        expect(description).to include('Install the new dependencies using the project\'s package manager')
      end
    end

    context 'for nil language' do
      it 'returns default template' do
        description = described_class.build_description(nil)

        expect(description).to include('Add OpenTelemetry SDK instrumentation to this project')
        expect(description).to include("for this project's language")
        expect(description).to include('Install the new dependencies using the project\'s package manager')
      end
    end
  end
end
