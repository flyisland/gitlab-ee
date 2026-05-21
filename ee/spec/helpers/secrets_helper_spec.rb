# frozen_string_literal: true

require "spec_helper"

RSpec.describe SecretsHelper, feature_category: :secrets_management do
  let_it_be(:project) { build_stubbed(:project) }
  let_it_be(:group) { create(:group) } # rubocop:disable RSpec/FactoryBot/AvoidCreate -- need persisted object
  let_it_be(:sub_group) { create(:group, parent: group) } # rubocop:disable RSpec/FactoryBot/AvoidCreate -- need persisted object
  let_it_be(:owner) { create(:user) } # rubocop:disable RSpec/FactoryBot/AvoidCreate -- need persisted object
  let_it_be(:maintainer) { create(:user) } # rubocop:disable RSpec/FactoryBot/AvoidCreate -- need persisted object

  describe '#project_secrets_app_data' do
    subject { helper.project_secrets_app_data(project) }

    it 'returns expected data' do
      expect(subject).to include({
        project_path: project.full_path,
        base_path: project_secrets_path(project)
      })
    end
  end

  describe '#group_secrets_app_data' do
    subject { helper.group_secrets_app_data(group) }

    it 'returns expected data' do
      expect(subject).to include({
        group_path: group.full_path,
        base_path: group_secrets_path(group)
      })
    end
  end

  describe '#namespace_enrollment_data' do
    before_all do
      group.add_owner(owner)
      group.add_maintainer(maintainer)
    end

    subject(:group_enrollment) { helper.namespace_enrollment_data(group, owner) }

    it 'returns expected data' do
      expect(group_enrollment).to include({
        full_path: group.full_path,
        group_path_regex: JsRegex.new(Gitlab::PathRegex::FULL_NAMESPACE_FORMAT_REGEX).source,
        is_namespace_enrollable: 'false'
      })
    end

    context 'when user is a maintainer of the group', :saas do
      subject(:group_enrollment_with_maintainer) { helper.namespace_enrollment_data(group, maintainer) }

      it 'sets correct permissions' do
        expect(group_enrollment_with_maintainer).to include({
          can_manage_secrets_manager: 'false',
          can_enroll_namespace: 'false'
        })
      end
    end

    context 'when user is the owner' do
      using RSpec::Parameterized::TableSyntax

      # only enrollable when SaaS + top-level group
      where(:is_saas, :namespace, :expected_enrollable) do
        true  | ref(:group)     | 'true'
        true  | ref(:sub_group) | 'false'
        false | ref(:group)     | 'false'
        false | ref(:sub_group) | 'false'
      end

      with_them do
        before do
          allow(Gitlab).to receive(:com?).and_return(is_saas) # -- testing Gitlab.com? behavior directly
        end

        subject(:group_enrollment_with_owner) { helper.namespace_enrollment_data(namespace, owner) }

        it 'returns correct is_namespace_enrollable' do
          expect(group_enrollment_with_owner).to include(is_namespace_enrollable: expected_enrollable)
        end
      end
    end
  end
end
