# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::JobsController, feature_category: :continuous_integration do
  let_it_be(:project) { create(:project, :public) }

  describe '#raw_redirect_params' do
    subject(:redirect_query) { controller.send(:raw_redirect_params)[:query] }

    before do
      allow(controller).to receive(:project).and_return(project)
    end

    it 'omits response-content-type when the feature flag is enabled', :aggregate_failures do
      expect(redirect_query).not_to have_key('response-content-type')
      expect(redirect_query['response-content-disposition']).to eq('inline')
    end

    context 'when jh_hidden_oss_content_type is disabled' do
      before do
        stub_feature_flags(jh_hidden_oss_content_type: false)
      end

      it 'keeps the upstream response-content-type override', :aggregate_failures do
        expect(redirect_query['response-content-type']).to eq('text/plain; charset=utf-8')
        expect(redirect_query['response-content-disposition']).to eq('inline')
      end
    end
  end
end
