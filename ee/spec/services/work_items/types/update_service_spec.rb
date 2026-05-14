# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WorkItems::Types::UpdateService, feature_category: :team_planning do
  let_it_be(:organization) { create(:organization) }
  let_it_be(:root_group) { create(:group) }
  let_it_be(:subgroup) { create(:group, parent: root_group) }
  let_it_be(:other_group) { create(:group) }
  let_it_be(:project) { create(:project, group: root_group) }
  let(:user) { create(:user, maintainer_of: root_group) }

  let_it_be(:system_defined_work_item_type) { create(:work_item_system_defined_type, :issue) }
  let_it_be(:organization_custom_work_item_type) do
    create(:work_item_custom_type, :with_organization, organization: organization)
  end

  let_it_be(:namespace_custom_work_item_type) do
    create(:work_item_custom_type, namespace: root_group)
  end

  let(:updated_name) { 'Bug' }
  let(:updated_icon_name) { 'bug' }

  let(:work_item_type) { system_defined_work_item_type }
  let(:expected_base_type) { work_item_type.base_type }

  let(:container) { root_group }
  let(:params) do
    {
      id: work_item_type.to_global_id.to_s,
      name: updated_name,
      icon_name: updated_icon_name
    }
  end

  subject(:result) do
    described_class.new(container: container, current_user: user, params: params).execute
  end

  before do
    stub_feature_flags(work_item_configurable_types: true)
  end

  RSpec.shared_examples 'returns work item type with updated attributes' do
    it 'returns work item type with updated attributes' do
      expect(result).to be_success
      expect(result.payload[:work_item_type]).to have_attributes(
        name: updated_name,
        icon_name: updated_icon_name,
        base_type: expected_base_type
      )
    end
  end

  RSpec.shared_examples 'updates custom work item type partially' do |field_name|
    it "updates custom work item type with only #{field_name} changed" do
      work_item_type.reload
      original_name = work_item_type.name
      original_icon_name = work_item_type.icon_name

      expect { result }.not_to change { WorkItems::TypesFramework::Custom::Type.count }

      expect(result).to be_success

      expected_attributes = {
        name: field_name == 'name' ? updated_name : original_name,
        icon_name: field_name == 'icon_name' ? updated_icon_name : original_icon_name
      }

      expect(work_item_type.reload).to have_attributes(expected_attributes)
    end
  end

  RSpec.shared_examples 'returns error response' do
    it 'returns error response' do
      expect(result).to be_error
      expect(result.message).to eq(expected_error_message)
    end
  end

  RSpec.shared_examples 'returns feature not available error' do
    let(:expected_error_message) { 'Feature not available' }

    it_behaves_like 'returns error response'
  end

  RSpec.shared_examples 'returns invalid container error' do
    let(:expected_error_message) { 'Work item types can only be modified at the root group or organization level' }

    it_behaves_like 'returns error response'
  end

  describe '#execute' do
    context 'with valid container' do
      context 'when container is an organization' do
        let(:container) { organization }

        context 'with system-defined work item type' do
          it 'creates custom work item type' do
            expect { result }.to change { WorkItems::TypesFramework::Custom::Type.count }.by(1)

            custom_work_item_type = WorkItems::TypesFramework::Custom::Type.last

            expect(custom_work_item_type).to have_attributes(
              name: updated_name,
              icon_name: updated_icon_name,
              converted_from_system_defined_type_identifier: system_defined_work_item_type.id,
              namespace_id: nil,
              organization_id: organization.id
            )
          end

          it_behaves_like 'returns work item type with updated attributes'

          context 'when only name is updated' do
            let(:params) do
              {
                id: work_item_type.to_global_id.to_s,
                name: updated_name
              }
            end

            it 'creates custom work item type with copied icon name' do
              expect { result }.to change { WorkItems::TypesFramework::Custom::Type.count }.by(1)

              custom_work_item_type = WorkItems::TypesFramework::Custom::Type.last

              expect(custom_work_item_type).to have_attributes(
                name: updated_name,
                icon_name: system_defined_work_item_type.icon_name,
                converted_from_system_defined_type_identifier: system_defined_work_item_type.id,
                namespace_id: nil,
                organization_id: organization.id
              )
            end
          end

          context 'when only icon_name is updated' do
            let(:params) do
              {
                id: work_item_type.to_global_id.to_s,
                icon_name: updated_icon_name
              }
            end

            it 'creates custom work item type with copied name' do
              expect { result }.to change { WorkItems::TypesFramework::Custom::Type.count }.by(1)

              custom_work_item_type = WorkItems::TypesFramework::Custom::Type.last

              expect(custom_work_item_type).to have_attributes(
                name: system_defined_work_item_type.name,
                icon_name: updated_icon_name,
                converted_from_system_defined_type_identifier: system_defined_work_item_type.id,
                namespace_id: nil,
                organization_id: organization.id
              )
            end
          end
        end

        context 'with custom work item type' do
          let(:work_item_type) { organization_custom_work_item_type }

          it 'updates custom work item type' do
            expect { result }.not_to change { WorkItems::TypesFramework::Custom::Type.count }

            expect(result).to be_success
            expect(work_item_type.reload).to have_attributes(
              name: updated_name,
              icon_name: updated_icon_name,
              converted_from_system_defined_type_identifier: nil,
              namespace_id: nil,
              organization_id: organization.id
            )
          end

          it_behaves_like 'returns work item type with updated attributes'

          context 'when only name is updated' do
            let(:params) do
              {
                id: work_item_type.to_global_id.to_s,
                name: updated_name
              }
            end

            it_behaves_like 'updates custom work item type partially', 'name'
          end

          context 'when only icon_name is updated' do
            let(:params) do
              {
                id: work_item_type.to_global_id.to_s,
                icon_name: updated_icon_name
              }
            end

            it_behaves_like 'updates custom work item type partially', 'icon_name'
          end
        end

        context 'with converted custom work item type' do
          let_it_be(:organization_converted_custom_work_item_type) do
            create(:work_item_custom_type, :with_organization, :converted_from_issue, organization: organization)
          end

          let(:work_item_type) { organization_converted_custom_work_item_type }

          it 'updates the existing custom type instead of creating a new one' do
            expect { result }.not_to change { WorkItems::TypesFramework::Custom::Type.count }

            expect(result).to be_success
            expect(work_item_type.reload).to have_attributes(
              name: updated_name,
              icon_name: updated_icon_name,
              converted_from_system_defined_type_identifier: 1,
              namespace_id: nil,
              organization_id: organization.id
            )
          end

          it_behaves_like 'returns work item type with updated attributes'
        end
      end

      context 'when container is a root group' do
        let(:container) { root_group }

        context 'with system-defined work item type' do
          it 'creates custom work item type' do
            expect { result }.to change { WorkItems::TypesFramework::Custom::Type.count }.by(1)

            custom_work_item_type = WorkItems::TypesFramework::Custom::Type.last

            expect(custom_work_item_type).to have_attributes(
              name: updated_name,
              icon_name: updated_icon_name,
              converted_from_system_defined_type_identifier: system_defined_work_item_type.id,
              namespace_id: root_group.id,
              organization_id: nil
            )
          end

          it_behaves_like 'returns work item type with updated attributes'

          it 'tracks update_work_item_type event for conversion', :clean_gitlab_redis_shared_state do
            expect { result }
              .to trigger_internal_events('update_work_item_type')
              .with(user: user, namespace: root_group,
                additional_properties: { label: system_defined_work_item_type.name })
              .and increment_usage_metrics(
                'counts.count_total_update_work_item_type',
                'counts.count_total_update_work_item_type_weekly',
                'counts.count_total_update_work_item_type_monthly',
                'redis_hll_counters.count_distinct_namespace_id_from_update_work_item_type_weekly',
                'redis_hll_counters.count_distinct_namespace_id_from_update_work_item_type_monthly'
              )
          end

          it 'does not track create_work_item_type event for conversion' do
            expect { result }.not_to trigger_internal_events('create_work_item_type')
          end

          context 'when only name is updated' do
            let(:params) do
              {
                id: work_item_type.to_global_id.to_s,
                name: updated_name
              }
            end

            it 'creates custom work item type with copied icon name' do
              expect { result }.to change { WorkItems::TypesFramework::Custom::Type.count }.by(1)

              custom_work_item_type = WorkItems::TypesFramework::Custom::Type.last

              expect(custom_work_item_type).to have_attributes(
                name: updated_name,
                icon_name: system_defined_work_item_type.icon_name,
                converted_from_system_defined_type_identifier: system_defined_work_item_type.id,
                namespace_id: root_group.id,
                organization_id: nil
              )
            end
          end

          context 'when only icon_name is updated' do
            let(:params) do
              {
                id: work_item_type.to_global_id.to_s,
                icon_name: updated_icon_name
              }
            end

            it 'creates custom work item type with copied name' do
              expect { result }.to change { WorkItems::TypesFramework::Custom::Type.count }.by(1)

              custom_work_item_type = WorkItems::TypesFramework::Custom::Type.last

              expect(custom_work_item_type).to have_attributes(
                name: system_defined_work_item_type.name,
                icon_name: updated_icon_name,
                converted_from_system_defined_type_identifier: system_defined_work_item_type.id,
                namespace_id: root_group.id,
                organization_id: nil
              )
            end
          end
        end

        context 'with custom work item type' do
          let(:work_item_type) { namespace_custom_work_item_type }

          it 'updates custom work item type' do
            expect { result }.not_to change { WorkItems::TypesFramework::Custom::Type.count }

            expect(result).to be_success
            expect(work_item_type.reload).to have_attributes(
              name: updated_name,
              icon_name: updated_icon_name,
              converted_from_system_defined_type_identifier: nil,
              namespace_id: root_group.id,
              organization_id: nil
            )
          end

          it_behaves_like 'returns work item type with updated attributes'

          it 'tracks update_work_item_type event', :clean_gitlab_redis_shared_state do
            expect { result }
              .to trigger_internal_events('update_work_item_type')
              .with(user: user, namespace: root_group, additional_properties: { label: updated_name })
              .and increment_usage_metrics(
                'counts.count_total_update_work_item_type',
                'counts.count_total_update_work_item_type_weekly',
                'counts.count_total_update_work_item_type_monthly',
                'redis_hll_counters.count_distinct_namespace_id_from_update_work_item_type_weekly',
                'redis_hll_counters.count_distinct_namespace_id_from_update_work_item_type_monthly'
              )
          end

          context 'when only name is updated' do
            let(:params) do
              {
                id: work_item_type.to_global_id.to_s,
                name: updated_name
              }
            end

            it_behaves_like 'updates custom work item type partially', 'name'
          end

          context 'when only icon_name is updated' do
            let(:params) do
              {
                id: work_item_type.to_global_id.to_s,
                icon_name: updated_icon_name
              }
            end

            it_behaves_like 'updates custom work item type partially', 'icon_name'
          end
        end

        context 'with converted custom work item type' do
          let_it_be(:namespace_converted_custom_work_item_type) do
            create(:work_item_custom_type, :converted_from_issue, namespace: root_group)
          end

          let(:work_item_type) { namespace_converted_custom_work_item_type }

          it 'updates the existing custom type instead of creating a new one' do
            expect { result }.not_to change { WorkItems::TypesFramework::Custom::Type.count }

            expect(result).to be_success
            expect(work_item_type.reload).to have_attributes(
              name: updated_name,
              icon_name: updated_icon_name,
              converted_from_system_defined_type_identifier: 1,
              namespace_id: root_group.id,
              organization_id: nil
            )
          end

          it_behaves_like 'returns work item type with updated attributes'
        end
      end
    end

    context 'with invalid container' do
      context 'when container is nil' do
        let(:container) { nil }

        it_behaves_like 'returns invalid container error'
      end

      context 'when container is a subgroup' do
        let(:container) { subgroup }

        it_behaves_like 'returns invalid container error'
      end

      context 'when container is a project' do
        let(:container) { project }

        it_behaves_like 'returns invalid container error'
      end
    end

    context 'when work item type ID is not provided' do
      let(:params) { super().except(:id) }
      let(:expected_error_message) { 'Work item type not found' }

      it_behaves_like 'returns error response'
    end

    context 'when work item type ID has invalid format' do
      let(:params) { super().merge(id: "invalid-global-id") }
      let(:expected_error_message) { 'Work item type not found' }

      it_behaves_like 'returns error response'
    end

    context 'when work item type does not exist' do
      let(:params) { super().merge(id: "gid://gitlab/WorkItems::Type/999") }
      let(:expected_error_message) { 'Work item type not found' }

      it_behaves_like 'returns error response'
    end

    context 'when name is invalid' do
      let(:updated_name) { 'Task' }
      let(:expected_error_message) { "Name 'Task' is already taken." }

      it_behaves_like 'returns error response'
    end

    context 'when icon_name is invalid' do
      let(:updated_icon_name) { 'invalid' }
      let(:expected_error_message) do
        valid_icons = WorkItems::TypesFramework::Custom::Type.icon_names.keys.sort.join(', ')
        "Icon name is not valid. Valid icon names are: #{valid_icons}"
      end

      it_behaves_like 'returns error response'
    end

    context 'when converting system-defined type and create service returns error' do
      let(:work_item_type) { system_defined_work_item_type }
      let(:params) { { id: work_item_type.to_global_id.to_s, name: 'Task', icon_name: 'bug' } }
      let(:expected_error_message) { "Name 'Task' is already taken." }

      it_behaves_like 'returns error response'

      it 'does not create a custom type' do
        expect { result }.not_to change { WorkItems::TypesFramework::Custom::Type.count }
      end
    end

    context 'when trying to update archived work item type' do
      let_it_be(:archived_custom_type) do
        create(:work_item_custom_type, :archived, namespace: root_group, name: 'Archived Type')
      end

      let(:work_item_type) { archived_custom_type }
      let(:expected_error_message) { 'Cannot update name or icon of an archived work item type' }

      context 'when updating the name' do
        let(:params) do
          {
            id: work_item_type.to_global_id.to_s,
            name: 'New Name'
          }
        end

        it_behaves_like 'returns error response'

        it 'does not update the work item type name' do
          expect { result }.not_to change { work_item_type.reload.name }
        end
      end

      context 'when updating the icon' do
        let(:params) do
          {
            id: work_item_type.to_global_id.to_s,
            icon_name: 'bug'
          }
        end

        it_behaves_like 'returns error response'

        it 'does not update the work item type icon' do
          expect { result }.not_to change { work_item_type.reload.icon_name }
        end
      end

      context 'when unarchiving without updating name or icon' do
        let(:params) do
          {
            id: work_item_type.to_global_id.to_s,
            archive: false
          }
        end

        it 'allows unarchiving' do
          expect(result).to be_success
          expect(work_item_type.reload.archived).to be false
        end
      end
    end

    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(work_item_configurable_types: false)
      end

      it_behaves_like 'returns feature not available error'
    end

    context 'when archiving system-defined type along with updating icon' do
      let(:expected_error_message) do
        'Cannot update name or icon of a system defined work item type and archive it simultaneously'
      end

      let(:params) do
        {
          id: system_defined_work_item_type.to_global_id.to_s,
          archive: true,
          icon_name: 'bug'
        }
      end

      it_behaves_like 'returns error response'

      it 'does not create the custom work item type' do
        expect { result }.not_to change { WorkItems::TypesFramework::Custom::Type.count }
      end
    end

    context 'when archiving system-defined type along with updating name' do
      let(:expected_error_message) do
        'Cannot update name or icon of a system defined work item type and archive it simultaneously'
      end

      let(:params) do
        {
          id: system_defined_work_item_type.to_global_id.to_s,
          archive: true,
          name: 'Custom Type'
        }
      end

      it_behaves_like 'returns error response'

      it 'does not create the custom work item type' do
        expect { result }.not_to change { WorkItems::TypesFramework::Custom::Type.count }
      end
    end

    context 'when archiving a system-defined type without updating name or icon' do
      let(:params) do
        {
          id: system_defined_work_item_type.to_global_id.to_s,
          archive: true
        }
      end

      it 'creates a custom type record with archived set to true' do
        expect { result }.to change { WorkItems::TypesFramework::Custom::Type.count }.by(1)

        custom_type = WorkItems::TypesFramework::Custom::Type.last
        expect(custom_type.archived).to be true
        expect(custom_type.name).to eq(system_defined_work_item_type.name)
        expect(custom_type.icon_name).to eq(system_defined_work_item_type.icon_name)
        expect(custom_type.converted_from_system_defined_type_identifier).to eq(system_defined_work_item_type.id)
        expect(custom_type.namespace_id).to eq(root_group.id)
      end

      context 'when container is an organization' do
        let(:container) { organization }

        it 'creates a custom type record with organization_id' do
          expect { result }.to change { WorkItems::TypesFramework::Custom::Type.count }.by(1)

          custom_type = WorkItems::TypesFramework::Custom::Type.last
          expect(custom_type.archived).to be true
          expect(custom_type.organization_id).to eq(organization.id)
          expect(custom_type.namespace_id).to be_nil
        end
      end
    end

    context 'when archiving a custom type' do
      let(:work_item_type) { namespace_custom_work_item_type }
      let(:params) do
        {
          id: work_item_type.to_global_id.to_s,
          archive: true
        }
      end

      it 'updates the archived attribute' do
        expect { result }.not_to change { WorkItems::TypesFramework::Custom::Type.count }

        expect(result).to be_success
        expect(work_item_type.reload.archived).to be true
      end

      it 'tracks archive_work_item_type event', :clean_gitlab_redis_shared_state do
        expect { result }
          .to trigger_internal_events('archive_work_item_type')
          .with(user: user, namespace: root_group,
            additional_properties: { label: work_item_type.name, property: 'true' })
          .and increment_usage_metrics(
            'counts.count_total_archive_work_item_type',
            'counts.count_total_archive_work_item_type_weekly',
            'counts.count_total_archive_work_item_type_monthly',
            'redis_hll_counters.count_distinct_namespace_id_from_archive_work_item_type_weekly',
            'redis_hll_counters.count_distinct_namespace_id_from_archive_work_item_type_monthly'
          )
      end

      it 'does not track update_work_item_type event' do
        expect { result }.not_to trigger_internal_events('update_work_item_type')
      end
    end

    context 'when unarchiving a custom type' do
      let_it_be(:archived_custom_type) do
        create(:work_item_custom_type, :archived, namespace: root_group, name: 'Archived Type')
      end

      let(:work_item_type) { archived_custom_type }
      let(:params) do
        {
          id: work_item_type.to_global_id.to_s,
          archive: false
        }
      end

      it 'updates the archived attribute to false' do
        expect(work_item_type.archived).to be true

        expect { result }.not_to change { WorkItems::TypesFramework::Custom::Type.count }

        expect(result).to be_success
        expect(work_item_type.reload.archived).to be false
      end

      it 'tracks archive_work_item_type event with property false' do
        expect { result }
          .to trigger_internal_events('archive_work_item_type')
          .with(user: user, namespace: root_group,
            additional_properties: { label: 'Archived Type', property: 'false' })
      end
    end

    context 'when updating name and archiving at the same time' do
      let(:work_item_type) { namespace_custom_work_item_type }
      let(:params) do
        {
          id: work_item_type.to_global_id.to_s,
          name: 'New Archived Name',
          archive: true
        }
      end

      it 'updates both name and archived attributes' do
        expect { result }.not_to change { WorkItems::TypesFramework::Custom::Type.count }

        expect(result).to be_success
        work_item_type.reload
        expect(work_item_type.name).to eq('New Archived Name')
        expect(work_item_type.archived).to be true
      end

      it 'tracks both archive and update events' do
        expect { result }
          .to trigger_internal_events('archive_work_item_type')
          .with(user: user, namespace: root_group,
            additional_properties: { label: 'New Archived Name', property: 'true' })
          .and trigger_internal_events('update_work_item_type')
          .with(user: user, namespace: root_group,
            additional_properties: { label: 'New Archived Name' })
      end
    end
  end
end
