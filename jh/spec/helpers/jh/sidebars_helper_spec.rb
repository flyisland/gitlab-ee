# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SidebarsHelper, feature_category: :navigation do
  include Devise::Test::ControllerHelpers

  describe '#super_sidebar_context gitlab_com_and_canary override' do
    let(:helper_instance) { Class.new { include SidebarsHelper }.new }

    before do
      allow(helper_instance).to receive(:request).and_return(
        instance_double(ActionDispatch::Request, cookies: cookies)
      )
    end

    subject { helper_instance.send(:jh_gitlab_next_data) }

    context 'when on JihuLab SaaS' do
      before do
        allow(::Gitlab).to receive_messages(com?: true, canary?: false)
      end

      context 'when gitlab_canary cookie is set to "true"' do
        let(:cookies) { { 'gitlab_canary' => 'true' } }

        it { is_expected.to eq(gitlab_com_and_canary: true) }
      end

      context 'when gitlab_canary cookie is not set' do
        let(:cookies) { {} }

        it { is_expected.to eq(gitlab_com_and_canary: false) }
      end

      context 'when canary ENV is set' do
        let(:cookies) { {} }

        before do
          allow(::Gitlab).to receive(:canary?).and_return(true)
        end

        it { is_expected.to eq(gitlab_com_and_canary: true) }
      end
    end

    context 'when not on SaaS' do
      let(:cookies) { { 'gitlab_canary' => 'true' } }

      before do
        allow(::Gitlab).to receive(:com?).and_return(false)
      end

      it { is_expected.to eq(gitlab_com_and_canary: false) }
    end
  end
end
