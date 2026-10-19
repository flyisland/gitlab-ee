# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Members::InviteService, :aggregate_failures, :clean_gitlab_redis_shared_state, :sidekiq_inline,
  feature_category: :groups_and_projects do
  let_it_be(:project, reload: true) { create(:project) }
  let_it_be(:maintainer1) { create(:user) }
  let_it_be(:maintainer2) { create(:user) }
  let(:rate_limit_threshold) do
    ::Gitlab::ApplicationRateLimiter::LabkitAdapter::SupportedRateLimits.limit_for(:invitation_email)
  end

  let(:params) { {} }
  let(:base_params) { { access_level: Gitlab::Access::GUEST, source: project, invite_source: '_invite_source_' } }

  subject(:result) { described_class.new(user, base_params.merge(params)).execute }

  before_all do
    project.add_maintainer(maintainer1)
    project.add_maintainer(maintainer2)
  end

  before do
    stub_feature_flags(ff_invitation_email_rate_limit: true)
  end

  context 'when invites are passed as array' do
    context 'with more emails than the rate limit' do
      let(:user) { maintainer1 }
      let(:params) { { email: emails(rate_limit_threshold + 1, '@example1.com') } }

      it 'does not create members' do
        expect_not_to_create_members
        expect(result[:message]).to eq(s_('JH|inviteEmail|Invite email rate limit exceeded'))
      end

      context 'when feature flag is disabled' do
        before do
          stub_feature_flags(ff_invitation_email_rate_limit: false)
        end

        it 'successfully creates members' do
          expect_to_create_members(count: rate_limit_threshold + 1)
        end
      end
    end

    context 'with less emails than the rate limit' do
      let(:user) { maintainer2 }
      let(:params) { { email: emails(rate_limit_threshold - 1, '@example2.com') } }

      it 'successfully creates members' do
        expect_to_create_members(count: rate_limit_threshold - 1)
      end
    end
  end

  def expect_to_create_members(count:)
    expect { result }.to change { ProjectMember.count }.by(count)
    expect(result[:status]).to eq(:success)
  end

  def expect_not_to_create_members
    expect { result }.not_to change { ProjectMember.count }
    expect(result[:status]).to eq(:error)
  end

  def emails(count, domain)
    (1..count).map { |i| "email#{i}#{domain}" }
  end
end
