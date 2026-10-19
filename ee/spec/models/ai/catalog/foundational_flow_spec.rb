# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Catalog::FoundationalFlow, feature_category: :duo_agent_platform do
  include I18nHelper
  using RSpec::Parameterized::TableSyntax

  shared_context 'with clean internal items cache' do
    around do |example|
      described_class.instance_variable_set(:@storage, nil)
      described_class.instance_variable_set(:@raw_items, nil)
      example.run
    ensure
      described_class.instance_variable_set(:@storage, nil)
      described_class.instance_variable_set(:@raw_items, nil)
    end
  end

  let(:code_review_description) do
    <<~DESC.squish
      Streamline code reviews by analyzing code changes and relevant codebase context.
      [How can I use this flow](https://docs.gitlab.com/user/duo_agent_platform/flows/foundational_flows/code_review/#use-the-flow)?
    DESC
  end

  let(:fr_translations) do
    {
      'FoundationalFlow|Code Review' => 'Code Review in French',
      "FoundationalFlow|#{code_review_description}" => 'Code Review description in French'
    }
  end

  describe '.fixed_items' do
    it 'does not translate display_name' do
      with_stubbed_translations(:fr, fr_translations) do
        expect(described_class['code_review/v1'].display_name)
          .to eq('Code Review')
      end
    end

    it 'does not translate description' do
      with_stubbed_translations(:fr, fr_translations) do
        expect(described_class['code_review/v1'].description).to eq(code_review_description)
      end
    end

    # Dormant today (no flow declares coding_environment: none yet) but prevents future
    # inconsistency. RUN_COMMANDS is deliberately absent from this list: an API-only flow
    # may still legitimately shell out to curl, jq or glab without a repository.
    it 'does not grant repository privileges to flows that declare coding_environment: none' do
      repository_privileges = [
        ::Ai::DuoWorkflows::Workflow::AgentPrivileges::USE_GIT,
        ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_FILES
      ]

      offending = described_class.all.select do |flow|
        flow.coding_environment.to_s == 'none' &&
          (Array(flow.agent_privileges) & repository_privileges).any?
      end

      expect(offending).to be_empty,
        "Flows with coding_environment: 'none' get no repository checkout, so they must not " \
          "include USE_GIT or READ_WRITE_FILES in agent_privileges. " \
          "Offending flows: #{offending.map(&:foundational_flow_reference).join(', ')}"
    end
  end

  describe 'default_trigger_filter validity' do
    # A filter value FlowTrigger refuses fails silently: sync swallows the error,
    # no project trigger is created, the flow never runs. Pin every flow's filter.
    it 'only uses filters Ai::FlowTrigger permits', :aggregate_failures do
      described_class.find_each do |flow|
        (flow.default_trigger_filter || {}).each do |event_type, group|
          allowed = ::Ai::FlowTrigger::ALLOWED_FILTER_FIELDS[event_type]
          expect(allowed).to be_present,
            "#{flow.foundational_flow_reference}: no ALLOWED_FILTER_FIELDS for event type #{event_type}"

          Array(group['rules']).each do |rule|
            field = rule['field']
            expect(allowed).to have_key(field),
              "#{flow.foundational_flow_reference}: #{event_type} filter field #{field} is not permitted"

            permitted = allowed[field]
            next if permitted.nil? # nil means any value

            expect(permitted).to include(rule['value']),
              "#{flow.foundational_flow_reference}: #{event_type} #{field}=#{rule['value'].inspect} " \
                "is not permitted (allowed: #{permitted.inspect})"
          end
        end
      end
    end
  end

  describe '.register_flow' do
    described_class.find_each do |flow|
      it "registers #{flow.foundational_flow_reference}" do
        accessor = flow.foundational_flow_reference.parameterize(separator: "_")
        expect(described_class.public_send(accessor)).to eq(flow)
      end
    end
  end

  describe '#saas_only' do
    it 'defaults to false' do
      expect(described_class.new.saas_only).to be(false)
    end
  end

  describe '#blocked_by_feature_flag?' do
    let(:group) { build_stubbed(:group) }
    let(:flow) { described_class.bl_security_experimental }

    before do
      stub_feature_flags(bl_security_analyzer: true)
    end

    it 'is false on GitLab.com with the flag on' do
      stub_saas_features(gitlab_com_subscriptions: true)

      expect(flow.blocked_by_feature_flag?(group)).to be(false)
    end

    it 'is true off GitLab.com, even with the flag on' do
      stub_saas_features(gitlab_com_subscriptions: false)

      expect(flow.blocked_by_feature_flag?(group)).to be(true)
    end

    it 'does not block a flow that is not SaaS only off GitLab.com' do
      stub_saas_features(gitlab_com_subscriptions: false)

      expect(described_class['code_review/v1'].blocked_by_feature_flag?(group)).to be(false)
    end
  end

  describe 'coding_environment validation' do
    using RSpec::Parameterized::TableSyntax

    subject(:flow) { described_class.new(coding_environment: coding_environment) }

    where(:coding_environment, :valid) do
      'full' | true
      'none' | true
      'non'  | false
      ''     | false
    end

    with_them do
      it 'guards against unrecognised registry values' do
        flow.valid?

        expect(flow.errors[:coding_environment].present?).to eq(!valid)
      end
    end
  end

  describe 'content_retention' do
    using RSpec::Parameterized::TableSyntax

    it 'defaults to full' do
      expect(described_class.new.content_retention).to eq('full')
    end

    where(:content_retention, :valid) do
      'full'     | true
      'metadata' | true
      'none'     | false
      ''         | false
    end

    with_them do
      subject(:flow) { described_class.new(content_retention: content_retention) }

      it 'guards against unrecognised registry values' do
        flow.valid?

        expect(flow.errors[:content_retention].present?).to eq(!valid)
      end
    end
  end

  describe 'pre_approved_agent_privileges validation' do
    using RSpec::Parameterized::TableSyntax

    subject(:flow) { described_class.new(agent_privileges: [2, 3], pre_approved_agent_privileges: pre_approved) }

    where(:pre_approved, :valid) do
      nil    | true
      []     | true
      [2]    | true
      [2, 3] | true
      [4]    | false
      [3, 4] | false
    end

    with_them do
      it 'rejects pre-approving a privilege the flow was never granted' do
        flow.valid?

        expect(flow.errors[:pre_approved_agent_privileges].present?).to eq(!valid)
      end
    end
  end

  describe '.[]' do
    subject(:definition) { described_class[key] }

    context 'with a valid foundational_flow_reference' do
      let(:key) { 'code_review/v1' }

      it { is_expected.to eq(described_class.find_by(foundational_flow_reference: key)) }
    end

    context 'with a valid display_name (for backward compatibility)' do
      let(:key) { 'Code Review' }

      it { is_expected.to eq(described_class.find_by(display_name: key)) }
    end

    context 'with a invalid key' do
      let(:key) { 'foo' }

      it { is_expected.to be_nil }
    end
  end

  describe '.session_hook?' do
    subject(:session_hook) { described_class.session_hook?(workflow.workflow_definition, event) }

    let(:flow) { described_class.new(foundational_flow_reference: 'something/v1') }
    let(:event) { ::Ai::DuoWorkflows::WorkflowFailedEvent }
    let(:workflow) { instance_double(::Ai::DuoWorkflows::Workflow, workflow_definition: 'something/v1') }

    before do
      allow(described_class).to receive(:find_by)
        .with({ foundational_flow_reference: workflow.workflow_definition })
        .and_return(flow)
    end

    context 'when session is from a foundational flow' do
      context 'and flow does not define hooks at all' do
        it { is_expected.to be(false) }
      end

      context 'and flow does not define a hook for that event' do
        before do
          flow.on_session_failed = nil
          flow.on_session_stopped = ->(workflow:) {}
        end

        it { is_expected.to be(false) }
      end

      context 'and flow defines a hook for that event' do
        before do
          flow.on_session_failed = ->(workflow:) {}
        end

        it { is_expected.to be(true) }
      end

      context 'and the hook map does not cover that event' do
        let(:event) { ::Ai::DuoWorkflows::WorkflowStartedEvent }

        before do
          flow.on_session_failed = ->(workflow:) {}
        end

        it { is_expected.to be(false) }
      end
    end

    context 'when session is not from a foundational flow' do
      let(:flow) { nil }

      it { is_expected.to be(false) }
    end
  end

  describe '.beta?' do
    subject(:beta?) { described_class.beta?(foundational_flow_reference) }

    context 'when foundational flow is beta' do
      before do
        allow(described_class).to receive(:find_by)
          .with(foundational_flow_reference: 'some_beta_flow/v1')
          .and_return(instance_double(described_class, beta?: true))
      end

      let(:foundational_flow_reference) { 'some_beta_flow/v1' }

      it { is_expected.to be true }
    end

    context 'when foundational flow is GA' do
      let(:foundational_flow_reference) { 'code_review/v1' }

      it { is_expected.to be false }
    end

    context 'when foundational flow does not exist' do
      let(:foundational_flow_reference) { 'non_existent/v1' }

      it { is_expected.to be false }
    end
  end

  describe '.ultimate_only?' do
    subject(:ultimate_only?) { described_class.ultimate_only?(foundational_flow_reference) }

    context 'when foundational flow is ultimate-only' do
      let(:foundational_flow_reference) { 'resolve_sast_vulnerability/v1' }

      it { is_expected.to be true }
    end

    context 'when foundational flow is not ultimate-only' do
      let(:foundational_flow_reference) { 'code_review/v1' }

      it { is_expected.to be false }
    end

    context 'when foundational flow does not exist' do
      let(:foundational_flow_reference) { 'non_existent/v1' }

      it { is_expected.to be false }
    end
  end

  describe '#available_for?' do
    let(:namespace) { build_stubbed(:group) }
    let(:flow) { described_class['developer/v1'] }

    where(:beta, :beta_consent, :ultimate_only, :licensed, :flagged_off, :expected) do
      false | true  | false | true  | false | true
      true  | true  | false | true  | false | true
      true  | false | false | true  | false | false
      false | true  | true  | true  | false | true
      false | true  | true  | false | false | false
      false | true  | false | true  | true  | false
    end

    with_them do
      before do
        allow(namespace).to receive(:duo_beta_flows_enabled?).and_return(beta_consent)
        allow(namespace).to receive(:licensed_feature_available?).with(:ai_features).and_return(licensed)
        allow(flow).to receive_messages(beta?: beta, ultimate_only?: ultimate_only)
        allow(flow).to receive(:blocked_by_feature_flag?).with(namespace).and_return(flagged_off)
      end

      it { expect(flow.available_for?(namespace)).to be(expected) }
    end

    # duo_beta_flows_enabled? is defined on Namespace, so a personal namespace answers
    # rather than raising NoMethodError.
    context 'with a user namespace' do
      let(:namespace) { build_stubbed(:namespace) }

      it 'is true when the namespace is entitled to the flow' do
        stub_saas_features(gitlab_com_subscriptions: false)
        stub_application_setting(instance_level_ai_beta_features_enabled: true)
        allow(namespace).to receive(:licensed_feature_available?).with(:ai_features).and_return(true)

        expect(flow.available_for?(namespace)).to be(true)
      end
    end
  end

  describe '.available_for_group' do
    subject(:references) { described_class.available_for_group(group).map(&:foundational_flow_reference) }

    let(:group) { build_stubbed(:group) }

    context 'when beta flows are enabled for the group' do
      before do
        allow(group).to receive(:duo_beta_flows_enabled?).and_return(true)
        allow(group).to receive(:licensed_feature_available?).with(:ai_features).and_return(true)
      end

      it 'includes beta flows' do
        expect(references).to include('recommend_reviewers/v1', 'security_review/v1')
      end

      it 'always includes GA flows' do
        expect(references).to include('code_review/v1', 'developer/v1')
      end
    end

    context 'when beta flows are not enabled for the group' do
      before do
        allow(group).to receive(:duo_beta_flows_enabled?).and_return(false)
        allow(group).to receive(:licensed_feature_available?).with(:ai_features).and_return(true)
      end

      it 'excludes beta flows' do
        expect(references).not_to include('recommend_reviewers/v1', 'security_review/v1')
      end

      it 'always includes GA flows' do
        expect(references).to include('code_review/v1', 'developer/v1')
      end
    end

    context 'with ai_features license (Ultimate)' do
      before do
        stub_saas_features(gitlab_com_subscriptions: false)
        stub_application_setting(instance_level_ai_beta_features_enabled: false)
        allow(group).to receive(:licensed_feature_available?).with(:ai_features).and_return(true)
      end

      it 'includes ultimate-only flows' do
        expect(references).to include('resolve_sast_vulnerability/v1', 'sast_fp_detection/v1')
      end
    end

    context 'without ai_features license (Free/Premium)' do
      before do
        stub_saas_features(gitlab_com_subscriptions: false)
        stub_application_setting(instance_level_ai_beta_features_enabled: false)
        allow(group).to receive(:licensed_feature_available?).with(:ai_features).and_return(false)
      end

      it 'excludes ultimate-only flows' do
        expect(references).not_to include('resolve_sast_vulnerability/v1', 'sast_fp_detection/v1',
          'secrets_fp_detection/v1')
      end

      it 'includes non-ultimate GA flows' do
        expect(references).to include('code_review/v1', 'developer/v1')
      end
    end

    context 'with a feature-flag-gated flow' do
      include_context 'with clean internal items cache'

      let(:gated_flow_reference) { 'gated_flow/v1' }

      where(:flag_disabled) do
        [true, false]
      end

      with_them do
        before do
          stub_saas_features(gitlab_com_subscriptions: false)
          stub_application_setting(instance_level_ai_beta_features_enabled: false)
          allow(group).to receive(:licensed_feature_available?).with(:ai_features).and_return(true)
          allow(described_class).to receive(:fixed_items).and_wrap_original do |original|
            original.call + [{
              foundational_flow_reference: gated_flow_reference,
              display_name: s_('FoundationalFlow|Gated Flow'),
              description: s_('FoundationalFlow|A flow behind a feature flag.'),
              feature_maturity: 'ga',
              feature_flag: 'my_gated_flow_flag'
            }]
          end
          allow(Feature).to receive(:disabled?).and_call_original
          allow(Feature).to receive(:disabled?).with(:my_gated_flow_flag, group).and_return(flag_disabled)
        end

        it 'includes the flow only when the feature flag is enabled' do
          expect(references.include?(gated_flow_reference)).to eq(!flag_disabled)
        end
      end
    end

    context 'when a flow has no feature_flag set' do
      before do
        stub_saas_features(gitlab_com_subscriptions: false)
        stub_application_setting(instance_level_ai_beta_features_enabled: false)
        allow(group).to receive(:licensed_feature_available?).with(:ai_features).and_return(true)
      end

      it 'always includes the flow' do
        expect(references).to include('code_review/v1')
      end
    end
  end

  describe 'flows that disallow event triggers' do
    where(:foundational_flow_reference) do
      %w[resolve_sast_vulnerability/v1 sast_fp_detection/v1 secrets_fp_detection/v1]
    end

    with_them do
      it 'has supported_events set to an empty array' do
        expect(described_class[foundational_flow_reference].supported_events).to eq([])
      end
    end
  end

  describe '#supports_resource?' do
    let_it_be(:project) { create(:project) }
    let_it_be(:merge_request) { create(:merge_request, source_project: project, target_project: project) }

    context 'when the flow declares no supported_resource_types' do
      subject(:flow) { described_class['convert_to_gl_ci/v1'] }

      it 'accepts any resource, including none' do
        expect(flow.supports_resource?(merge_request)).to be(true)
        expect(flow.supports_resource?(create(:issue, project: project))).to be(true)
        expect(flow.supports_resource?(nil)).to be(true)
      end
    end

    context 'when the flow declares supported_resource_types' do
      subject(:flow) { described_class['recommend_reviewers/v1'] }

      it 'accepts a declared resource type' do
        expect(flow.supports_resource?(merge_request)).to be(true)
      end

      it 'rejects an undeclared resource type and a missing resource' do
        expect(flow.supports_resource?(create(:issue, project: project))).to be(false)
        expect(flow.supports_resource?(nil)).to be(false)
      end
    end

    context 'when the flow declares an empty supported_resource_types' do
      subject(:flow) { described_class.new(supported_resource_types: []) }

      it 'rejects every resource' do
        expect(flow.supports_resource?(merge_request)).to be(false)
        expect(flow.supports_resource?(nil)).to be(false)
      end
    end
  end

  describe 'supported_resource_types declarations' do
    # Guarded here rather than by a model validation: an invalid definition makes
    # load_items! raise on first access and then leave the catalog permanently
    # truncated, taking unrelated flows with it.
    it 'is nil or an array of classes for every flow' do
      invalid = described_class.all.reject do |flow|
        types = flow.supported_resource_types
        types.nil? || (types.is_a?(Array) && types.all?(Class))
      end

      expect(invalid.map(&:foundational_flow_reference)).to be_empty
    end
  end

  describe '#validate_start_request' do
    let_it_be(:project) { create(:project) }

    context 'when the flow has no start_request_validator' do
      let(:flow) { described_class['convert_to_gl_ci/v1'] }

      it 'returns nil' do
        expect(flow.validate_start_request(container: project, goal: 'any goal')).to be_nil
      end
    end
  end

  describe '#run_eligible?' do
    let(:project) { instance_double(::Project) }

    it 'is true when the flow declares no check' do
      expect(described_class.new.run_eligible?(project: project, resource: nil)).to be(true)
    end

    it 'returns what the check returns' do
      flow = described_class.new(run_eligibility_resolver: ->(**args) { args[:resource] == :ok })

      expect(flow.run_eligible?(project: project, resource: :ok)).to be(true)
      expect(flow.run_eligible?(project: project, resource: nil)).to be(false)
    end

    it 'checks the Business Logic profile for bl_security/experimental' do
      expect(described_class.bl_security_experimental.run_eligibility_resolver)
        .to eq(described_class::BlSecurity::RunEligibility)
    end
  end

  describe '#run_on_session_created' do
    let(:resource) { instance_double(::MergeRequest) }
    let(:calls) { [] }

    context 'when flow declares no callback' do
      it 'is a no-op' do
        expect(described_class.new.run_on_session_created(resource: resource)).to be_nil
      end
    end

    context 'when flow declares a callback' do
      it 'hands the resource to the callback' do
        flow = described_class.new(on_session_created: ->(resource:) { calls << resource })

        flow.run_on_session_created(resource: resource)

        expect(calls).to eq([resource])
      end

      it 'skips a resource type the flow does not declare' do
        flow = described_class.new(
          on_session_created: ->(resource:) { calls << resource },
          supported_resource_types: [::Issue]
        )

        flow.run_on_session_created(resource: resource)

        expect(calls).to be_empty
      end
    end
  end

  describe '#run_session_hook' do
    subject(:run_session_hook) { flow.run_session_hook(event, workflow: workflow) }

    let(:workflow) { instance_double(::Ai::DuoWorkflows::Workflow) }
    let(:calls) { [] }
    let(:event) { ::Ai::DuoWorkflows::WorkflowFailedEvent }

    context 'when the flow declares no hook for the event' do
      let(:flow) { described_class.new }

      it 'returns false without calling anything' do
        expect(run_session_hook).to be(false)
        expect(calls).to be_empty
      end
    end

    context 'when the flow declares a lambda hook' do
      let(:flow) do
        described_class.new(on_session_failed: ->(workflow:) { calls << workflow })
      end

      it 'hands the workflow to the hook and returns true' do
        expect(run_session_hook).to be(true)
        expect(calls).to eq([workflow])
      end
    end

    context 'when the flow declares a callable class' do
      let(:hook) do
        Class.new do
          class << self
            attr_reader :received

            def call(workflow:)
              @received = workflow
            end
          end
        end
      end

      let(:flow) do
        described_class.new(on_session_failed: hook)
      end

      it 'hands the workflow to the hook and returns true' do
        expect(run_session_hook).to be(true)
        expect(hook.received).to eq(workflow)
      end
    end

    context 'when the flow does not declare the session resource type' do
      let(:flow) do
        described_class.new(
          on_session_failed: ->(workflow:) { calls << workflow },
          supported_resource_types: [::Issue]
        )
      end

      it 'still runs' do
        expect(run_session_hook).to be(true)
        expect(calls).to eq([workflow])
      end
    end

    context 'when the event is covered' do
      where(:event_class, :hook) do
        Ai::Catalog::FoundationalFlow::SESSION_LIFECYCLE_HOOKS.to_a
      end

      with_them do
        let(:event) { event_class }
        let(:flow) do
          described_class.new(
            hook => ->(workflow:) { calls << [hook, workflow] }
          )
        end

        it 'dispatches the event hook' do
          expect(run_session_hook).to be(true)
          expect(calls).to eq([[hook, workflow]])
        end
      end
    end

    context 'when the event is not covered' do
      let(:event) { ::Ai::DuoWorkflows::WorkflowStartedEvent }
      let(:flow) do
        described_class.new(
          on_session_failed: ->(workflow:) { calls << [:failed, workflow] },
          on_session_stopped: ->(workflow:) { calls << [:stopped, workflow] }
        )
      end

      it 'is a no-op' do
        expect(run_session_hook).to be(false)
        expect(calls).to eq([])
      end
    end
  end

  describe '#session_lifecycle_hook' do
    let(:on_failed) { ->(workflow:) { workflow } }
    let(:on_stopped) { ->(workflow:) { workflow } }
    let(:on_finished) { ->(workflow:) { workflow } }
    let(:flow) do
      described_class.new(
        on_session_failed: on_failed,
        on_session_stopped: on_stopped,
        on_session_finished: on_finished
      )
    end

    it 'returns the hook the event maps to' do
      expect(flow.session_lifecycle_hook(::Ai::DuoWorkflows::WorkflowFailedEvent)).to eq(on_failed)
      expect(flow.session_lifecycle_hook(::Ai::DuoWorkflows::WorkflowStoppedEvent)).to eq(on_stopped)
      expect(flow.session_lifecycle_hook(::Ai::DuoWorkflows::WorkflowFinishedCloudEvent)).to eq(on_finished)
    end

    context 'when the flow declares no hook for that event' do
      let(:flow) { described_class.new(on_session_stopped: on_stopped) }

      it 'returns nil' do
        expect(flow.session_lifecycle_hook(::Ai::DuoWorkflows::WorkflowFailedEvent)).to be_nil
      end
    end

    context 'when the event is not covered' do
      it 'returns nil' do
        expect(flow.session_lifecycle_hook(::Ai::DuoWorkflows::WorkflowStartedEvent)).to be_nil
      end
    end
  end

  describe '#resolve_noteable_for' do
    let_it_be(:project) { create(:project) }

    context 'when the flow has no noteable_resolver' do
      let(:flow) { described_class['convert_to_gl_ci/v1'] }

      it 'returns nil' do
        expect(flow.resolve_noteable_for(project: project, goal: 'https://gitlab.com/-/pipelines/1')).to be_nil
      end
    end
  end

  describe '#resolve_source_branch_for' do
    it 'returns nil when the flow has no source_branch_resolver' do
      flow = described_class['convert_to_gl_ci/v1']

      expect(flow.resolve_source_branch_for(project: build_stubbed(:project), goal: '1')).to be_nil
    end

    it 'rejects a resolver that does not accept project: and goal:' do
      flow = described_class.new(source_branch_resolver: ->(project:) { project })

      flow.valid?

      expect(flow.errors[:source_branch_resolver]).to be_present
    end
  end

  describe '#resolve_source_pipeline_for' do
    let_it_be(:project) { create(:project) }

    context 'when the flow has no source_pipeline_resolver' do
      let(:flow) { described_class['convert_to_gl_ci/v1'] }

      it 'returns nil' do
        expect(flow.resolve_source_pipeline_for(project: project, goal: 'https://gitlab.com/-/pipelines/1')).to be_nil
      end
    end
  end

  describe '#resolve_additional_context_for' do
    let(:resource) { instance_double(::MergeRequest, id: 42) }
    let(:resolver) { nil }
    let(:flow) { described_class.new(additional_context_resolver: resolver) }

    subject(:additional_context) { flow.resolve_additional_context_for(resource: resource) }

    context 'when the flow has no additional_context_resolver' do
      it 'returns an empty array' do
        expect(additional_context).to eq([])
      end
    end

    context 'when additional_context_resolver is a lambda' do
      let(:resolver) do
        ->(resource:) do
          {
            "resource" => {
              type: "merge_request",
              id: resource.id
            }
          }
        end
      end

      it 'returns the resolved additional context formatted for AIGW' do
        expect(additional_context).to eq([
          {
            "Category" => "resource",
            "Content" => {
              type: "merge_request",
              id: resource.id
            }.to_json
          }
        ])
      end
    end

    context 'when additional_context_resolver is a Module' do
      let(:resolver) do
        Module.new do
          module_function

          def call(resource:)
            {
              "resource" => {
                type: "merge_request",
                id: resource.id
              }
            }
          end
        end
      end

      it 'returns the resolved additional context formatted for AIGW' do
        expect(additional_context).to eq([
          {
            "Category" => "resource",
            "Content" => {
              type: "merge_request",
              id: resource.id
            }.to_json
          }
        ])
      end
    end

    context 'when the flow declares supported_resource_types' do
      let(:resource) { build_stubbed(:merge_request) }
      let(:unsupported) { build_stubbed(:issue) }

      let(:resolver) { ->(resource:) { { "resource" => { id: resource.id } } } }
      let(:flow) do
        described_class.new(additional_context_resolver: resolver, supported_resource_types: [::MergeRequest])
      end

      it 'resolves context for a supported resource' do
        expect(flow.resolve_additional_context_for(resource: resource))
          .to contain_exactly(hash_including("Category" => "resource"))
      end

      it 'returns an empty array for an unsupported resource' do
        expect(flow.resolve_additional_context_for(resource: unsupported)).to eq([])
      end
    end
  end

  describe '#resolve_flow_version_for' do
    let(:container) { build_stubbed(:project) }
    let(:user) { build_stubbed(:user) }
    let(:resolver) { nil }
    let(:flow) do
      described_class.new(
        foundational_flow_reference: 'developer/v1',
        flow_version: '^2.0.0',
        flow_version_resolver: resolver
      )
    end

    subject(:resolved) { flow.resolve_flow_version_for(container: container, user: user) }

    context 'when the flow has no flow_version_resolver' do
      it 'returns the flow own reference and version' do
        expect(resolved).to eq(
          flow_config_id: 'developer',
          flow_config_schema_version: 'v1',
          flow_version: '^2.0.0'
        )
      end
    end

    context 'when the flow_version_resolver returns an override' do
      let(:resolver) { ->(**) { ['developer/experimental', '3.0.0'] } }

      it 'returns the overridden reference and version' do
        expect(resolved).to eq(
          flow_config_id: 'developer',
          flow_config_schema_version: 'experimental',
          flow_version: '3.0.0'
        )
      end
    end

    context 'when the flow_version_resolver declines to override' do
      let(:resolver) { ->(**) {} }

      it 'falls back to the flow own reference and version' do
        expect(resolved).to eq(
          flow_config_id: 'developer',
          flow_config_schema_version: 'v1',
          flow_version: '^2.0.0'
        )
      end
    end
  end

  describe '#beta?' do
    it 'returns true for a beta flow' do
      expect(described_class.new(feature_maturity: 'beta').beta?).to be true
    end

    it 'returns false for a GA flow' do
      expect(described_class.new(feature_maturity: 'ga').beta?).to be false
    end
  end

  describe '#ultimate_only?' do
    it 'returns true for an ultimate-only flow' do
      expect(described_class['resolve_sast_vulnerability/v1'].ultimate_only?).to be true
    end

    it 'returns false for a non-ultimate-only flow' do
      expect(described_class['code_review/v1'].ultimate_only?).to be false
    end
  end

  describe '#agent_privileges' do
    subject(:agent_privileges) { definition.agent_privileges }

    context 'when agent_privileges are not set' do
      let(:definition) { described_class.new(agent_privileges: nil) }

      it 'returns the default value' do
        expect(agent_privileges).to eq([])
      end
    end

    context 'with agent_privileges' do
      let(:definition) { described_class.new(agent_privileges: [1, 2]) }

      it 'returns the agent_privileges' do
        expect(agent_privileges).to match_array([1, 2])
      end
    end
  end

  describe '#pre_approved_agent_privileges' do
    subject(:pre_approved_agent_privileges) { definition.pre_approved_agent_privileges }

    context 'when pre_approved_agent_privileges are not set' do
      let(:definition) { described_class.new(agent_privileges: [1, 2]) }

      it 'pre-approves every granted privilege' do
        expect(pre_approved_agent_privileges).to match_array([1, 2])
      end
    end

    context 'with a narrowed pre_approved_agent_privileges' do
      let(:definition) { described_class.new(agent_privileges: [1, 2], pre_approved_agent_privileges: %w[1]) }

      it 'returns the narrowed set, coerced to integers' do
        expect(pre_approved_agent_privileges).to eq([1])
      end
    end

    context 'with an empty pre_approved_agent_privileges' do
      let(:definition) { described_class.new(agent_privileges: [1, 2], pre_approved_agent_privileges: []) }

      it 'pre-approves nothing rather than falling back to the granted set' do
        expect(pre_approved_agent_privileges).to eq([])
      end
    end
  end

  describe '#catalog_item' do
    subject(:catalog_item) { definition.catalog_item }

    context 'with foundational_flow_reference' do
      let_it_be(:definition) { described_class.new(foundational_flow_reference: 'code_review') }
      let_it_be(:duo_code_review) do
        create(:ai_catalog_item, :flow, :public, foundational_flow_reference: 'code_review')
      end

      it 'returns the corresponding foundational workflow catalog item' do
        expect(catalog_item).to eq(duo_code_review)
      end
    end

    context 'without foundational_flow_reference' do
      let_it_be(:definition) { described_class.new(foundational_flow_reference: nil) }

      it 'returns nil' do
        expect(catalog_item).to be_nil
      end
    end

    context 'when the corresponding foundational workflow does not exist' do
      let_it_be(:definition) { described_class.new(foundational_flow_reference: 'code_review') }

      it 'returns nil' do
        expect(catalog_item).to be_nil
      end
    end
  end

  describe '#display_name' do
    subject(:display_name) { definition.display_name }

    let(:definition) { described_class['code_review/v1'] }

    it 'does not translate if locale is not English' do
      with_stubbed_translations(:fr, fr_translations) do
        expect(display_name).to eq('Code Review')
      end
    end
  end

  describe '#description' do
    subject(:description) { definition.description }

    let(:definition) { described_class['code_review/v1'] }

    it 'does not translate if locale is not English' do
      with_stubbed_translations(:fr, fr_translations) do
        expect(description).to eq(code_review_description)
      end
    end
  end

  describe '#reference' do
    it 'aliases foundational_flow_reference' do
      flow = described_class.new(foundational_flow_reference: 'code_review/v1')

      expect(flow.reference).to eq('code_review/v1')
    end
  end

  describe '#translated_display_name' do
    subject(:translated_display_name) { definition.translated_display_name }

    let(:definition) { described_class['code_review/v1'] }

    context 'when the locale is English' do
      it 'returns the English display_name' do
        Gitlab::I18n.with_locale(:en) do
          expect(translated_display_name).to eq('Code Review')
        end
      end
    end

    context 'when the locale is not English' do
      it 'returns the translated display_name' do
        with_stubbed_translations(:fr, fr_translations) do
          expect(translated_display_name).to eq('Code Review in French')
        end
      end
    end
  end

  describe '#translated_description' do
    subject(:translated_description) { definition.translated_description }

    let(:definition) { described_class['code_review/v1'] }

    context 'when the locale is English' do
      it 'returns the English description' do
        Gitlab::I18n.with_locale(:en) do
          expect(translated_description).to eq(code_review_description)
        end
      end
    end

    context 'when the locale is not English' do
      it 'returns the translation description' do
        with_stubbed_translations(:fr, fr_translations) do
          expect(translated_description)
            .to eq('Code Review description in French')
        end
      end
    end
  end

  describe '#resolve_ai_feature' do
    subject(:resolved_ai_feature) do
      described_class[foundational_flow_reference].resolve_ai_feature(current_user: current_user)
    end

    let_it_be(:current_user) { build_stubbed(:user) }

    where(:foundational_flow_reference, :ai_feature) do
      'business_context_security_guidelines/experimental'   | 'duo_agent_platform'
      'code_review/v1'                                      | 'review_merge_request_dap'
      'convert_to_gl_ci/v1'                                 | 'duo_agent_platform'
      'developer/v1'                                        | 'duo_developer'
      'fix_pipeline/v1'                                     | 'duo_agent_platform'
      'recommend_reviewers/v1'                              | 'recommend_reviewers_assign'
      'resolve_dependency_bump/experimental'                | 'resolve_dependency_bump'
      'resolve_sast_vulnerability/v1'                       | 'sast_vulnerability_resolution'
      'risk_classification/v1'                              | 'risk_classification'
      'sast_fp_detection/v1'                                | 'sast_vulnerability_fp_detection'
      'secrets_fp_detection/v1'                             | 'secret_vulnerability_fp_detection'
      'security_review/v1'                                  | 'security_review'
      'workplan/v1'                                         | 'duo_agent_platform'
    end

    with_them do
      it 'resolves the expected ai_feature' do
        expect(resolved_ai_feature).to eq(ai_feature)
      end
    end
  end
end
