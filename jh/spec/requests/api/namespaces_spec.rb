# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Namespaces, :aggregate_failures, feature_category: :groups_and_projects do
  include AfterNextHelpers

  let_it_be(:admin) { create(:admin) }
  let_it_be(:user) { create(:user) }
  let_it_be(:group_owner) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:user_namespace) { create(:namespace, owner: user) }
  let_it_be(:params) do
    {
      shared_runners_minutes_limit: 9001,
      additional_purchased_storage_size: 10_000,
      additional_purchased_storage_ends_on: Time.zone.today.to_s
    }
  end

  describe 'PUT /namespaces/:id' do
    before_all do
      group.add_owner(group_owner)
    end

    context 'when saas', :saas do
      it 'reset group members free trial left days' do
        group_owner.custom_attributes.create(key: ::JH::User::FREE_TRIAL_LEFT_DAYS, value: '1')
        put api("/namespaces/#{group.full_path}", admin, admin_mode: true), params: params

        expect(response).to have_gitlab_http_status(:ok)
        expect(group_owner.last_custom_attribute).to be_nil
      end

      it 'reset owner of user namespace free trial left days' do
        user.custom_attributes.create(key: ::JH::User::FREE_TRIAL_LEFT_DAYS, value: '1')
        put api("/namespaces/#{user_namespace.id}", admin, admin_mode: true), params: params

        expect(response).to have_gitlab_http_status(:ok)
        expect(user.last_custom_attribute).to be_nil
      end

      it 'not reset trial group' do
        group_owner.custom_attributes.create(key: ::JH::User::FREE_TRIAL_LEFT_DAYS, value: '1')
        new_params = params.merge(trial_ends_on: '2019-05-01')
        put api("/namespaces/#{group.full_path}", admin, admin_mode: true), params: new_params

        expect(response).to have_gitlab_http_status(:ok)
        expect(group_owner.last_custom_attribute).not_to be_nil
      end
    end

    context 'when self-managed' do
      it 'not reset owner of user namespace free trial left days' do
        user.custom_attributes.create(key: ::JH::User::FREE_TRIAL_LEFT_DAYS, value: '1')
        put api("/namespaces/#{user_namespace.id}", admin, admin_mode: true), params: params

        expect(response).to have_gitlab_http_status(:ok)
        expect(user.last_custom_attribute).not_to be_nil
      end

      it 'not reset group members free trial left days' do
        group_owner.custom_attributes.create(key: ::JH::User::FREE_TRIAL_LEFT_DAYS, value: '1')
        put api("/namespaces/#{group.full_path}", admin, admin_mode: true), params: params

        expect(response).to have_gitlab_http_status(:ok)
        expect(group_owner.last_custom_attribute).not_to be_nil
      end
    end
  end
end
