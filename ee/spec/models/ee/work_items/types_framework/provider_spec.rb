# frozen_string_literal: true

require 'spec_helper'

# EE Provider specs focus on the critical paths for custom type resolution.
# All public Provider methods route through resolve_by_id or resolve_all,
# which are the two methods overridden in EE. We test representative methods
# across system-defined, converted, and custom types rather than exhaustively
# covering every public method.

RSpec.describe ::WorkItems::TypesFramework::Provider, :request_store, feature_category: :team_planning do
  let_it_be(:organization) { create(:organization) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:namespace) { group }
  let_it_be(:user_namespace) { create(:user_namespace) }
  let_it_be(:issue_type) { build(:work_item_system_defined_type, :issue) }
  let_it_be(:task_type) { build(:work_item_system_defined_type, :task) }
  let_it_be(:incident_type) { build(:work_item_system_defined_type, :incident) }

  let_it_be(:namespace_custom_work_item_type) { create(:work_item_custom_type, namespace: namespace) }
  let_it_be(:organization_custom_work_item_type) do
    create(:work_item_custom_type, :with_organization, organization: organization)
  end

  let_it_be(:namespace_converted_custom_work_item_type) do
    create(:work_item_custom_type, :converted_from_incident, namespace: namespace)
  end

  let_it_be(:organization_converted_custom_work_item_type) do
    create(:work_item_custom_type, :with_organization, :converted_from_incident, organization: organization)
  end

  let_it_be(:disabled_workflow_types) { %w[requirement test_case] }
  let_it_be(:okr_types) { %w[objective key_result] }

  let(:provider) { described_class.new(namespace) }

  before do
    stub_licensed_features(epics: true, requirements: true)
  end

  shared_examples 'returns only system-defined work item types' do
    it 'returns only system-defined work item types' do
      system_defined_types = described_class.new.all
      expect(result).to match_array(system_defined_types)
    end
  end

  RSpec.shared_examples 'includes epic types in results' do
    it 'includes epic types in results' do
      result_base_types = result.map { |t| t.base_type.to_s }
      expect(result_base_types).to include('epic')
    end
  end

  RSpec.shared_examples 'excludes epic types from results' do
    it 'excludes epic types from results' do
      result_base_types = result.map { |t| t.base_type.to_s }
      expect(result_base_types).not_to include('epic')
    end
  end

  RSpec.shared_examples 'includes disabled workflow types in results' do
    it 'includes disabled workflow types from results' do
      result_base_types = result.map { |t| t.base_type.to_s }
      disabled_workflow_types.each do |disabled_type|
        expect(result_base_types).to include(disabled_type)
      end
    end
  end

  RSpec.shared_examples 'excludes disabled workflow types from results' do
    it 'excludes disabled workflow types from results' do
      result_base_types = result.map { |t| t.base_type.to_s }
      disabled_workflow_types.each do |disabled_type|
        expect(result_base_types).not_to include(disabled_type)
      end
    end
  end

  RSpec.shared_examples 'includes OKR types in results' do
    it 'includes OKR types in results' do
      result_base_types = provider.all.map { |t| t.base_type.to_s }
      okr_types.each do |okr_type|
        expect(result_base_types).to include(okr_type)
      end
    end
  end

  RSpec.shared_examples 'excludes OKR types from results' do
    it 'excludes OKR types from results' do
      result_base_types = result.map { |t| t.base_type.to_s }
      okr_types.each do |okr_type|
        expect(result_base_types).not_to include(okr_type)
      end
    end
  end

  describe '#all_ordered_by_name' do
    subject(:result) { provider.all_ordered_by_name }

    it 'caches the result in SafeRequestStore' do
      expect(Gitlab::SafeRequestStore).to receive(:fetch)
       .with("work_items_types_provider_root_ancestor_#{namespace.root_ancestor.id}")
       .and_call_original

      expect(Gitlab::SafeRequestStore).to receive(:fetch)
        .with("work_items_types_provider:#{namespace.class.base_class.name}:#{namespace.id}")
        .and_call_original

      result
    end

    it 'caches the result on subsequent calls' do
      expect(::WorkItems::TypesFramework::Custom::Type).to receive(:for_namespace).once.and_call_original

      result
      result
    end

    it 'maintains separate caches for different namespaces' do
      provider1 = described_class.new(namespace)
      provider2 = described_class.new(create(:group))

      expect(provider1.all_ordered_by_name).not_to eq(provider2.all_ordered_by_name)
    end

    it 'uses distinct cache keys for different namespace types with the same id' do
      test_project = create(:project, group: namespace)

      group_provider = described_class.new(namespace)
      project_provider = described_class.new(test_project)

      group_key = group_provider.send(:cache_key)
      project_key = project_provider.send(:cache_key)

      # Project is converted to its project_namespace in Provider#initialize,
      # so both keys use Namespace as the base class but differ by ID
      expect(group_key).to include("Namespace")
      expect(project_key).to include("Namespace")
      expect(group_key).not_to eq(project_key)
    end

    it 'returns system-defined, custom and converted work item types' do
      expect(result).to include(issue_type, task_type, namespace_custom_work_item_type,
        namespace_converted_custom_work_item_type)
    end

    it 'excludes system-defined types that were converted to custom types' do
      expect(result).not_to include(incident_type)
    end

    it 'only includes namespace-scoped types' do
      expect(result).not_to include(organization_custom_work_item_type, organization_converted_custom_work_item_type)
    end

    it 'returns types sorted by name' do
      names = result.map(&:name)
      expect(names).to eq(names.sort)
    end

    context 'with organization as namespace' do
      let(:provider) { described_class.new(organization) }

      it 'caches the result in SafeRequestStore' do
        expect(Gitlab::SafeRequestStore).to receive(:fetch)
          .with("work_items_types_provider:#{organization.class.base_class.name}:#{organization.id}")
          .and_call_original

        result
      end

      it 'caches the result on subsequent calls' do
        expect(::WorkItems::TypesFramework::Custom::Type).to receive(:for_organization).once.and_call_original

        result
        result
      end

      it 'maintains separate caches for different organizations' do
        provider1 = described_class.new(organization)
        provider2 = described_class.new(create(:organization))

        expect(provider1.all_ordered_by_name).not_to eq(provider2.all_ordered_by_name)
      end

      it 'maintains separate caches between namespace and organization providers' do
        namespace_provider = described_class.new(namespace)
        org_provider = described_class.new(organization)

        expect(namespace_provider.all_ordered_by_name).not_to eq(org_provider.all_ordered_by_name)
      end

      it 'returns system-defined, custom and converted work item types' do
        expect(result).to include(issue_type, task_type, organization_custom_work_item_type,
          organization_converted_custom_work_item_type)
      end

      it 'excludes system-defined types that were converted to custom types' do
        expect(result).not_to include(incident_type)
      end

      it 'excludes namespace-scoped custom types' do
        expect(result).not_to include(namespace_custom_work_item_type, namespace_converted_custom_work_item_type)
      end

      it 'returns types sorted by name' do
        names = result.map(&:name)

        expect(names).to eq(names.sort)
      end
    end

    context 'with user namespace' do
      let(:provider) { described_class.new(user_namespace) }

      it_behaves_like 'returns only system-defined work item types'

      it 'does not check feature flag' do
        expect(Feature).not_to receive(:enabled?)

        result
      end
    end

    context 'with project under user namespace' do
      let_it_be(:project) { create(:project, namespace: user_namespace) }
      let(:provider) { described_class.new(project) }

      it_behaves_like 'returns only system-defined work item types'

      it 'does not check feature flag' do
        expect(Feature).not_to receive(:enabled?)

        result
      end
    end

    context 'with nil namespace' do
      let(:provider) { described_class.new(nil) }

      it_behaves_like 'returns only system-defined work item types'

      it 'does not check feature flag' do
        expect(Feature).not_to receive(:enabled?)

        result
      end
    end

    context 'when work_item_configurable_types feature flag is disabled' do
      before do
        stub_feature_flags(work_item_configurable_types: false)
      end

      it_behaves_like 'returns only system-defined work item types'

      it 'excludes custom work item types' do
        expect(result).not_to include(namespace_converted_custom_work_item_type, namespace_custom_work_item_type)
      end

      it 'returns types sorted by name' do
        names = result.map(&:name)
        expect(names).to eq(names.sort)
      end

      context 'with organization as namespace' do
        let(:provider) { described_class.new(organization) }

        it_behaves_like 'returns only system-defined work item types'

        it 'excludes custom work item types' do
          expect(result).not_to include(organization_custom_work_item_type,
            organization_converted_custom_work_item_type)
        end
      end
    end
  end

  describe '#find_by_id' do
    context 'with a system-defined type id' do
      it 'returns the system-defined type' do
        expect(provider.find_by_id(issue_type.id)).to eq(issue_type)
      end
    end

    context 'with a custom type id' do
      it 'returns the custom type' do
        expect(provider.find_by_id(namespace_custom_work_item_type.id)).to eq(namespace_custom_work_item_type)
      end
    end

    context 'with a converted custom type' do
      it 'returns the converted type when looked up by the system type id it replaced' do
        system_type_id = namespace_converted_custom_work_item_type.converted_from_system_defined_type_identifier
        expect(provider.find_by_id(system_type_id)).to eq(namespace_converted_custom_work_item_type)
      end

      it 'returns the same type when looked up by its own id' do
        result = provider.find_by_id(namespace_converted_custom_work_item_type.id)
        system_type_id = namespace_converted_custom_work_item_type.converted_from_system_defined_type_identifier

        expect(result).to eq(namespace_converted_custom_work_item_type)
        expect(result).to be(provider.find_by_id(system_type_id))
      end
    end

    context 'with a custom type from a different namespace' do
      it 'returns nil' do
        expect(provider.find_by_id(organization_custom_work_item_type.id)).to be_nil
      end
    end

    context 'with a non-existent id' do
      it 'returns nil' do
        expect(provider.find_by_id(non_existing_record_id)).to be_nil
      end
    end

    context 'when work_item_configurable_types feature flag is disabled' do
      before do
        stub_feature_flags(work_item_configurable_types: false)
      end

      it 'returns system-defined types' do
        expect(provider.find_by_id(issue_type.id)).to eq(issue_type)
      end

      it 'returns nil for custom types' do
        expect(provider.find_by_id(namespace_custom_work_item_type.id)).to be_nil
      end
    end

    context 'with organization as namespace' do
      let(:provider) { described_class.new(organization) }

      it 'returns organization custom types' do
        expect(provider.find_by_id(organization_custom_work_item_type.id)).to eq(organization_custom_work_item_type)
      end

      it 'returns nil for namespace custom types' do
        expect(provider.find_by_id(namespace_custom_work_item_type.id)).to be_nil
      end
    end
  end

  describe '#find_by_gid' do
    it 'resolves system-defined type GIDs' do
      expect(provider.find_by_gid(issue_type.to_global_id)).to eq(issue_type)
    end

    it 'resolves custom type GIDs' do
      expect(provider.find_by_gid(namespace_custom_work_item_type.to_global_id))
        .to eq(namespace_custom_work_item_type)
    end

    context 'when work_item_configurable_types feature flag is disabled' do
      before do
        stub_feature_flags(work_item_configurable_types: false)
      end

      it 'returns nil for custom type GIDs' do
        expect(provider.find_by_gid(namespace_custom_work_item_type.to_global_id)).to be_nil
      end
    end
  end

  describe '#fetch_work_item_type' do
    it 'resolves custom type objects' do
      expect(provider.fetch_work_item_type(namespace_custom_work_item_type)).to eq(namespace_custom_work_item_type)
    end

    it 'resolves custom type ids' do
      expect(provider.fetch_work_item_type(namespace_custom_work_item_type.id)).to eq(namespace_custom_work_item_type)
    end

    context 'when work_item_configurable_types feature flag is disabled' do
      before do
        stub_feature_flags(work_item_configurable_types: false)
      end

      it 'returns nil for custom type ids' do
        expect(provider.fetch_work_item_type(namespace_custom_work_item_type.id)).to be_nil
      end
    end
  end

  describe '#find_by_name' do
    it 'resolves custom types by name' do
      expect(provider.find_by_name(namespace_custom_work_item_type.name)).to eq(namespace_custom_work_item_type)
    end

    it 'resolves system-defined types by name' do
      expect(provider.find_by_name('Issue')).to eq(issue_type)
    end

    context 'when work_item_configurable_types feature flag is disabled' do
      before do
        stub_feature_flags(work_item_configurable_types: false)
      end

      it 'returns nil for custom types' do
        expect(provider.find_by_name(namespace_custom_work_item_type.name)).to be_nil
      end
    end
  end

  describe '#by_ids' do
    it 'resolves custom type ids' do
      result = provider.by_ids([namespace_custom_work_item_type.id, issue_type.id])
      expect(result).to contain_exactly(namespace_custom_work_item_type, issue_type)
    end

    it 'excludes custom types from other namespaces' do
      result = provider.by_ids([organization_custom_work_item_type.id])
      expect(result).to be_empty
    end
  end

  describe '#find_by_base_type' do
    it 'returns the converted custom type instead of the system type' do
      expect(provider.find_by_base_type(:incident)).to eq(namespace_converted_custom_work_item_type)
    end

    it 'returns the system type when no conversion exists' do
      expect(provider.find_by_base_type(:issue)).to eq(issue_type)
    end

    context 'when work_item_configurable_types feature flag is disabled' do
      before do
        stub_feature_flags(work_item_configurable_types: false)
      end

      it 'returns the system type even when a conversion exists' do
        expect(provider.find_by_base_type(:incident)).to eq(incident_type)
      end
    end
  end

  describe '#default_issue_type' do
    context 'with nil namespace' do
      let(:provider) { described_class.new(nil) }

      it 'returns the system issue type without error' do
        expect(provider.default_issue_type).to eq(issue_type)
      end
    end
  end

  describe '#by_base_types_ordered_by_name' do
    it 'returns only the canonical type per base_type' do
      result = provider.by_base_types_ordered_by_name([:issue])
      expect(result).to contain_exactly(issue_type)
    end

    it 'returns the converted type when one exists' do
      result = provider.by_base_types_ordered_by_name([:incident])
      expect(result).to contain_exactly(namespace_converted_custom_work_item_type)
    end
  end

  describe 'enabled attribute' do
    it 'is available on types returned by find_by_id for custom types' do
      type = provider.find_by_id(namespace_custom_work_item_type.id)

      expect(type).to respond_to(:enabled)
      expect(type.enabled).to be(true)
    end

    it 'is available on types returned by find_by_id for system-defined types' do
      type = provider.find_by_id(issue_type.id)

      expect(type).to respond_to(:enabled)
      expect(type.enabled).to be(true)
    end

    it 'is available on all types returned by all_ordered_by_name' do
      provider.all_ordered_by_name.each do |type|
        expect(type).to respond_to(:enabled)
        expect(type.enabled).to be(true)
      end
    end

    context 'when work_item_configurable_types feature flag is disabled' do
      before do
        stub_feature_flags(work_item_configurable_types: false)
      end

      it 'is not available on types returned by find_by_id' do
        type = provider.find_by_id(issue_type.id)

        expect(type).not_to respond_to(:enabled)
      end
    end
  end

  describe 'cache key' do
    it 'uses namespace.id directly in cache key' do
      expect(Gitlab::SafeRequestStore).to receive(:fetch)
        .with("work_items_types_provider_root_ancestor_#{namespace.root_ancestor.id}")
        .and_call_original

      expect(Gitlab::SafeRequestStore).to receive(:fetch)
        .with("work_items_types_provider:#{namespace.class.base_class.name}:#{namespace.id}")
        .and_call_original

      provider.all_ordered_by_name
    end

    context 'with a subgroup' do
      let_it_be(:subgroup) { create(:group, parent: group) }
      let(:provider) { described_class.new(subgroup) }

      it 'uses the subgroup namespace.id in cache key' do
        expect(Gitlab::SafeRequestStore).to receive(:fetch)
          .with("work_items_types_provider_root_ancestor_#{subgroup.root_ancestor.id}")
          .and_call_original

        expect(Gitlab::SafeRequestStore).to receive(:fetch)
        .with("work_items_types_provider:#{subgroup.class.base_class.name}:#{subgroup.id}")
        .and_call_original

        provider.all_ordered_by_name
      end
    end

    context 'with organization as namespace' do
      let(:provider) { described_class.new(organization) }

      it 'uses organization id in cache key' do
        expect(Gitlab::SafeRequestStore).to receive(:fetch)
          .with("work_items_types_provider:#{organization.class.base_class.name}:#{organization.id}")
          .and_call_original

        provider.all_ordered_by_name
      end
    end
  end

  describe '#filtered_types' do
    subject(:result) { provider.filtered_types }

    shared_examples 'filters types by feature availability' do
      context 'with group as namespace' do
        context 'with requirements enabled' do
          it_behaves_like 'includes disabled workflow types in results'
        end

        context 'with requirements disabled' do
          before do
            stub_licensed_features(requirements: false)
          end

          it_behaves_like 'excludes disabled workflow types from results'
        end

        context 'with epics enabled' do
          it_behaves_like 'includes epic types in results'
        end

        context 'with epics disabled' do
          before do
            stub_licensed_features(epics: false)
          end

          it_behaves_like 'excludes epic types from results'
        end

        context 'with OKRs enabled' do
          it_behaves_like 'excludes OKR types from results'
        end

        context 'with OKRs disabled' do
          before do
            stub_feature_flags(okrs_mvc: false)
          end

          it_behaves_like 'excludes OKR types from results'
        end
      end

      context 'with project as namespace' do
        let(:provider) { described_class.new(project) }

        context 'with requirements enabled' do
          it_behaves_like 'includes disabled workflow types in results'
        end

        context 'with requirements disabled' do
          before do
            stub_licensed_features(requirements: false)
          end

          it_behaves_like 'excludes disabled workflow types from results'
        end

        context 'with epics enabled' do
          context 'with project epics enabled' do
            before do
              allow(project).to receive(:project_epics_enabled?).and_return(true)
            end

            it_behaves_like 'includes epic types in results'
          end

          context 'with project epics disabled' do
            before do
              stub_feature_flags(project_work_item_epics: false)
            end

            it_behaves_like 'excludes epic types from results'
          end
        end

        context 'with epics disabled' do
          before do
            stub_licensed_features(epics: false)
          end

          it_behaves_like 'excludes epic types from results'
        end

        context 'with OKRs enabled' do
          it_behaves_like 'includes OKR types in results'
        end

        context 'with OKRs disabled' do
          before do
            stub_feature_flags(okrs_mvc: false)
          end

          it_behaves_like 'excludes OKR types from results'
        end
      end

      context 'with organization as namespace' do
        let(:provider) { described_class.new(organization) }

        context 'with requirements enabled' do
          it_behaves_like 'includes disabled workflow types in results'
        end

        context 'with requirements disabled' do
          before do
            stub_licensed_features(requirements: false)
          end

          it_behaves_like 'excludes disabled workflow types from results'
        end

        context 'with epics enabled' do
          it_behaves_like 'includes epic types in results'
        end

        context 'with epics disabled' do
          before do
            stub_licensed_features(epics: false)
          end

          it_behaves_like 'excludes epic types from results'
        end

        context 'with OKRs enabled' do
          it_behaves_like 'includes OKR types in results'
        end

        context 'with OKRs disabled' do
          before do
            stub_feature_flags(okrs_mvc: false)
          end

          it_behaves_like 'excludes OKR types from results'
        end
      end

      context 'with user namespace' do
        let(:provider) { described_class.new(user_namespace) }

        it_behaves_like 'excludes disabled workflow types from results'
        it_behaves_like 'excludes epic types from results'
        it_behaves_like 'excludes OKR types from results'
      end

      context 'with project under user namespace' do
        let_it_be(:project) { create(:project, namespace: user_namespace) }
        let(:provider) { described_class.new(project) }

        it_behaves_like 'includes disabled workflow types in results'
        it_behaves_like 'includes epic types in results'
        it_behaves_like 'includes OKR types in results'
      end

      context 'with nil namespace' do
        let(:provider) { described_class.new(nil) }

        it 'returns only system-defined types' do
          expected_base_types = WorkItems::TypesFramework::SystemDefined::Type::BASE_TYPES.pluck(:base_type)
          actual_base_types = result.map(&:base_type)

          expect(actual_base_types).to match_array(expected_base_types)
        end
      end
    end

    it_behaves_like 'filters types by feature availability'

    it 'includes custom work item types' do
      expect(result).to include(namespace_custom_work_item_type, namespace_converted_custom_work_item_type)
    end

    context 'when work_item_configurable_types feature flag is disabled' do
      before do
        stub_feature_flags(work_item_configurable_types: false)
      end

      it 'excludes custom work item types' do
        expect(result).not_to include(namespace_custom_work_item_type, namespace_converted_custom_work_item_type)
      end
    end
  end

  describe '#available_system_defined_types_count' do
    subject(:result) { provider.available_system_defined_types_count }

    let(:all_system_defined_types_count) { described_class.new.all.count }

    context 'with organization as namespace' do
      let(:provider) { described_class.new(organization) }

      context 'when all features are enabled' do
        before do
          stub_licensed_features(epics: true, requirements: true)
          stub_feature_flags(okrs_mvc: true)
        end

        it 'counts only non-converted system-defined types' do
          expect(result).to eq(all_system_defined_types_count - 1)
        end
      end

      context 'when some features are disabled' do
        before do
          stub_licensed_features(epics: false, requirements: false)
          stub_feature_flags(okrs_mvc: false)
        end

        it 'excludes unavailable types from count' do
          expect(result).to eq(all_system_defined_types_count - 6)
        end
      end

      context 'with custom types present' do
        it 'does not count custom types including converted ones' do
          expect(provider.filtered_types).to include(
            organization_custom_work_item_type,
            organization_converted_custom_work_item_type
          )
          expect(result).to eq(all_system_defined_types_count - 1)
        end
      end
    end

    context 'with group as namespace' do
      it 'excludes OKR types and counts only non-converted system-defined types' do
        okr_types_count = okr_types.count
        converted_types_count = 1
        expect(result).to eq(all_system_defined_types_count - okr_types_count - converted_types_count)
      end
    end
  end

  describe '#allowed_types' do
    subject(:result) { provider.allowed_types.map(&:base_type) }

    context 'when namespace is a organization' do
      let(:provider) { described_class.new(organization) }

      it 'returns available work item types' do
        expect(result).to match_array(%w[epic objective key_result])
      end
    end

    context 'when namespace is a group' do
      it 'returns available work item types' do
        expect(result).to include('epic')
      end
    end

    context 'when namespace is a project' do
      let(:provider) { described_class.new(project) }

      it 'returns available work item types' do
        expect(result).to include('issue', 'incident', 'task', 'ticket')
      end

      it 'applies licensed feature filtering' do
        stub_licensed_features(epics: false)

        expect(result).not_to include('epic')
      end

      it 'applies feature flag filtering for OKRs' do
        stub_feature_flags(okrs_mvc: true)

        expect(result).to include('key_result', 'objective')
      end

      it 'applies licensed feature filtering for disabled workflow types' do
        stub_licensed_features(requirements: false)

        expect(result).not_to include('requirement', 'test_case')
      end
    end

    context 'when namespace is a user namespace' do
      let(:provider) { described_class.new(user_namespace) }

      it 'returns empty array' do
        expect(result).to eq([])
      end
    end

    context 'when project is under user namespace' do
      let_it_be(:project) { create(:project, namespace: user_namespace) }
      let(:provider) { described_class.new(project) }

      it 'returns available work item types' do
        expect(result).to include('issue', 'incident', 'task', 'ticket')
      end
    end

    context 'when namespace is nil' do
      let(:provider) { described_class.new(nil) }

      it 'returns empty array' do
        expect(result).to eq([])
      end
    end
  end
end
