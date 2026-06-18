# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::FoundationalFlowMessages, feature_category: :duo_agent_platform do
  describe '.namespace_missing_error' do
    let(:user) { build_stubbed(:user, name: 'User Name') }

    subject(:message) { described_class.namespace_missing_error(user) }

    it 'includes actionable guidance about setting a default namespace' do
      expect(message).to include(user.to_reference)
      expect(message).to include('default GitLab Duo namespace')
      expect(message).to include('preferences')
    end

    it 'includes a link to the documentation' do
      expect(message).to include('set-a-default-gitlab-duo-namespace')
    end
  end
end
