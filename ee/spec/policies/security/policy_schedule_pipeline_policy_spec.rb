# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::PolicySchedulePipelinePolicy, feature_category: :security_policy_management do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:policy_schedule_pipeline) { create(:security_policy_schedule_pipeline, project: project) }

  subject(:policy) { described_class.new(user, policy_schedule_pipeline) }

  describe 'read_pipeline' do
    context 'when user has permission on the project' do
      before_all do
        project.add_developer(user)
      end

      it { expect_allowed(:read_pipeline) }
    end

    context 'when user does not have permission on the project' do
      it { expect_disallowed(:read_pipeline) }
    end
  end
end
