# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DuoChatPanel::IdentityVerificationComponent, :aggregate_failures, feature_category: :duo_chat do
  let(:user_namespace) { build_stubbed(:namespace) }
  let(:user) { build_stubbed(:user, namespace: user_namespace) }
  let(:source) { nil }

  subject(:component) { render_inline(described_class.new(source: source, user: user)) && page }

  describe 'rendering' do
    it 'renders the #duo-chat-panel.duo-chat-panel element' do
      is_expected.to have_selector('#duo-chat-panel.duo-chat-panel')
    end

    it 'sets the identity-verification-required data attribute' do
      is_expected.to have_css('#duo-chat-panel[data-identity-verification-required="true"]')
    end

    it 'sets the identity-verification-path data attribute' do
      is_expected.to have_css(
        "#duo-chat-panel[data-identity-verification-path='#{Gitlab::Routing.url_helpers.identity_verification_path}']"
      )
    end

    context 'when source is nil' do
      let(:source) { nil }

      it 'defaults the container-type data attribute to group' do
        is_expected.to have_css('#duo-chat-panel[data-container-type="group"]')
      end
    end

    context 'when within a project' do
      let(:source) { build(:project) }

      it 'sets the correct container-type data attribute' do
        is_expected.to have_css('#duo-chat-panel[data-container-type="project"]')
      end
    end

    context 'when within a group' do
      let(:source) { build(:group) }

      it 'sets the correct container-type data attribute' do
        is_expected.to have_css('#duo-chat-panel[data-container-type="group"]')
      end
    end
  end

  describe '#data' do
    it_behaves_like 'sets auto_expand field with respect to the legacy callout'
  end
end
