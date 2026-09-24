# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContentValidation::ComplaintService do
  let_it_be(:group) { create(:group) }
  let_it_be(:user)  { create(:user) }
  let_it_be(:project) { create(:project, :repository, :public, group: group) }

  before do
    allow(ContentValidation::Setting).to receive(:block_enabled?).and_return(true)
  end

  describe "#execute" do
    let(:content_blocked_state) { create(:content_blocked_state, container: project) }
    let(:description) { "This content is OK." }

    subject { described_class.new(content_blocked_state: content_blocked_state, user: user, description: description) }

    it "client call user_complaint" do
      expect_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
        expect(client).to receive(:user_complaint)
          .with(hash_including(container_identifier: content_blocked_state.container_identifier,
            content_blocked_state_id: content_blocked_state.id,
            commit_sha: content_blocked_state.commit_sha,
            path: content_blocked_state.path,
            user_id: user.id,
            user_username: user.username,
            user_email: user.email,
            description: description)).at_least(:once)
      end

      subject.execute
    end
  end
end
