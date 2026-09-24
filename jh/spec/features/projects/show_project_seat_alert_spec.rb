# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project show page all seats used alert', :saas, :use_clean_rails_memory_store_caching,
  feature_category: :seat_cost_management do
  include BillableMembersHelpers

  let_it_be(:user) { create(:user) }
  let_it_be_with_refind(:group) { create(:group) }
  let_it_be(:project) { create(:project, namespace: group) }
  let_it_be(:subscription) { create(:gitlab_subscription, :premium, namespace: group, seats: 3) }

  let(:root_namespace) { group }
  let(:visit_page) { visit project_path(project) }

  before_all do
    group.add_owner(user)
    group.add_developer(create(:user))
    group.add_developer(create(:user))
  end

  before do
    group.namespace_settings.update!(seat_control: :block_overages)
    stub_billable_members_reactive_cache(group)
    sign_in(user)
  end

  it_behaves_like 'displays the reached seat count threshold alert with JH purchase link'
end
