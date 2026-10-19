# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CodeSuggestions::Prompts::CodeCompletion::AiGatewayCodeCompletionMessage, feature_category: :"self-hosted_models" do
  let_it_be(:current_user) { create(:user) }
  let_it_be(:ai_self_hosted_model) { create(:ai_self_hosted_model, model: :codestral, name: 'whatever', endpoint: 'http://example.com/endpoint') }
  let_it_be(:ai_feature_setting) do
    create(
      :ai_feature_setting,
      feature: :code_completions,
      self_hosted_model: ai_self_hosted_model
    )
  end

  let(:dummy_class) do
    Class.new(described_class) do
      def prompt
        'dummy prompt'
      end
    end
  end

  let(:current_file) do
    {
      'file_name' => 'test.py',
      'content_above_cursor' => "some content_above_cursor that ends in lots of #{'a' * 1000}",
      'content_below_cursor' => "#{'b' * 1000} is the letter that leads some content_below_cursor"
    }.with_indifferent_access
  end

  let(:params) do
    {
      current_file: current_file
    }
  end

  let(:dummy_message) do
    dummy_class.new(
      params,
      current_user,
      ::Ai::FeatureSetting.find_by_feature(:code_completions)
    )
  end

  describe '#request_params' do
    it 'returns the correct request params' do
      expected_params = {
        model_provider: 'litellm',
        prompt_version: 2,
        prompt: 'dummy prompt',
        model_endpoint: 'http://example.com/endpoint',
        model_name: 'codestral',
        model_api_key: "token",
        model_identifier: "provider/some-model"
      }

      expect(dummy_message.request_params).to eq(expected_params)
    end

    context 'when the self-hosted model has an IAM role' do
      let(:ai_self_hosted_model) do
        build_stubbed(:ai_self_hosted_model, provider: :bedrock, model: :codestral, endpoint: nil, api_token: nil,
          identifier: 'bedrock/model', iam_role: 'arn:aws:iam::123456789012:role/my-role')
      end

      let(:ai_feature_setting) do
        build_stubbed(:ai_feature_setting, feature: :code_completions, self_hosted_model: ai_self_hosted_model)
      end

      let(:dummy_message) { dummy_class.new(params, current_user, ai_feature_setting) }

      it 'sends the IAM role to AI Gateway' do
        expect(dummy_message.request_params)
          .to include(model_iam_role: 'arn:aws:iam::123456789012:role/my-role')
      end
    end

    it 'does not send an IAM role without one' do
      expect(dummy_message.request_params).not_to have_key(:model_iam_role)
    end
  end

  describe '#prompt' do
    it 'raises NotImplementedError for the abstract class' do
      expect(described_class.new(
        params,
        current_user,
        ::Ai::FeatureSetting.find_by_feature(:code_completions)
      ).prompt).to be_nil
    end
  end

  describe '#pick_content_above_cursor' do
    it 'returns the last 500 characters of the content' do
      expect(dummy_message.send(:pick_content_above_cursor)).to eq('a' * 500)
    end
  end

  describe '#pick_content_below_cursor' do
    it 'returns the first 500 characters of the content' do
      expect(dummy_message.send(:pick_content_below_cursor)).to eq('b' * 500)
    end
  end
end
