# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::Settings::WorkItemsController, feature_category: :team_planning do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:group) { create(:group) }
  let_it_be(:subgroup) { create(:group, parent: group) }
  let_it_be(:nested_subgroup) { create(:group, parent: subgroup) }
  let_it_be(:user) { create(:user) }

  before do
    sign_in(user)
  end

  shared_examples 'successful access' do
    it 'returns 200' do
      subject

      expect(response).to have_gitlab_http_status(:ok)
    end
  end

  shared_examples 'unauthorized access' do
    it 'returns 404' do
      subject

      expect(response).to have_gitlab_http_status(:not_found)
    end
  end

  describe 'GET #show' do
    subject { get group_settings_work_items_path(current_group) }

    context 'with subgroup' do
      let(:current_group) { subgroup }

      where(:user_role, :configurable_work_item_types_licensed, :expected_result) do
        # Maintainer+ roles should have access when configurable_work_item_types is licensed
        :maintainer | true  | 'successful access'
        :maintainer | false | 'unauthorized access'
        :owner      | true  | 'successful access'
        :owner      | false | 'unauthorized access'

        # Other roles should never have access regardless of licensed features
        :anonymous  | true  | 'unauthorized access'
        :anonymous  | false | 'unauthorized access'
        :guest      | true  | 'unauthorized access'
        :guest      | false | 'unauthorized access'
        :developer  | true  | 'unauthorized access'
        :developer  | false | 'unauthorized access'
      end

      with_them do
        before do
          assign_user_role(user_role, current_group)
          stub_licensed_features(configurable_work_item_types: configurable_work_item_types_licensed)
        end

        it_behaves_like params[:expected_result]
      end

      context 'when work_item_configurable_types feature flag is disabled' do
        before do
          current_group.add_maintainer(user)
          stub_licensed_features(custom_fields: true, work_item_status: true,
            configurable_work_item_types: true)
          stub_feature_flags(work_item_configurable_types: false)
        end

        it_behaves_like 'unauthorized access'
      end

      context 'when work_item_configurable_types feature flag is enabled for the root namespace' do
        before do
          current_group.add_maintainer(user)
          stub_licensed_features(custom_fields: true, work_item_status: true,
            configurable_work_item_types: true)
          stub_feature_flags(work_item_configurable_types: group)
        end

        it_behaves_like 'successful access'
      end
    end

    context 'with root group' do
      let(:current_group) { group }

      where(:user_role, :custom_fields_licensed, :work_item_status_licensed, :configurable_work_item_types_licensed,
        :expected_result) do
        # Maintainer+ roles should have access when at least one licensed feature is enabled
        :maintainer | true  | true  | true  | 'successful access'
        :maintainer | true  | false | true  | 'successful access'
        :maintainer | false | true  | true  | 'successful access'
        :maintainer | false | false | true  | 'successful access'
        :maintainer | true  | true  | false | 'successful access'
        :maintainer | true  | false | false | 'successful access'
        :maintainer | false | true  | false | 'successful access'
        :maintainer | false | false | false | 'unauthorized access'
        :owner      | true  | true  | true  | 'successful access'
        :owner      | true  | false | true  | 'successful access'
        :owner      | false | true  | true  | 'successful access'
        :owner      | false | false | true  | 'successful access'
        :owner      | true  | true  | false | 'successful access'
        :owner      | true  | false | false | 'successful access'
        :owner      | false | true  | false | 'successful access'
        :owner      | false | false | false | 'unauthorized access'

        # Other roles should never have access regardless of licensed features
        :anonymous  | true  | true  | true  | 'unauthorized access'
        :anonymous  | false | false | false | 'unauthorized access'
        :guest      | true  | true  | true  | 'unauthorized access'
        :guest      | false | false | false | 'unauthorized access'
        :developer  | true  | true  | true  | 'unauthorized access'
        :developer  | false | false | false | 'unauthorized access'
      end

      with_them do
        before do
          assign_user_role(user_role, current_group)
          stub_licensed_features(
            custom_fields: custom_fields_licensed,
            work_item_status: work_item_status_licensed,
            configurable_work_item_types: configurable_work_item_types_licensed
          )
        end

        it_behaves_like params[:expected_result]
      end

      context 'with work item feature flags' do
        before do
          current_group.add_owner(user)
          stub_licensed_features(custom_fields: true, work_item_status: true, configurable_work_item_types: true)
        end

        context 'when work_item_configurable_types feature flag is disabled' do
          before do
            stub_feature_flags(work_item_configurable_types: false)
          end

          it_behaves_like 'successful access'
        end
      end
    end
  end

  def assign_user_role(user_role, group)
    case user_role
    when :anonymous then sign_out(user)
    when :guest then group.add_guest(user)
    when :developer then group.add_developer(user)
    when :maintainer then group.add_maintainer(user)
    when :owner then group.add_owner(user)
    end
  end
end
