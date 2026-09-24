# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Group show page', :saas, feature_category: :groups_and_projects do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) do
    create(:group_with_plan, :private, plan: :ultimate_trial_plan, trial_starts_on: Time.zone.today,
      trial_ends_on: 10.days.from_now)
  end

  let_it_be(:sub_group) { create(:group, :private, :with_avatar, parent: group, description: 'bar') }

  let(:path) { group_path(group) }
  let(:sub_group_path) { group_path(sub_group) }

  before_all do
    group.add_developer(user)
  end

  before do
    allow(group).to receive(:root?).and_return(true)
    allow_any_instance_of(::Group).to receive(:trial_active?).and_return(true)

    sign_in(user)
  end

  context 'when visiting subgroup' do
    before do
      visit sub_group_path
    end

    it 'does not render any content with trials related card' do
      expect(page).not_to have_content('Group premium trial time')
    end
  end

  context 'when visiting root group' do
    before do
      visit path
    end

    it 'renders trial card for the top-level group' do
      expect(page).to have_content('Group ultimate trial time')
    end
  end
end
