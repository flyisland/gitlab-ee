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

  describe 'fix_pipeline/v1' do
    subject(:flow) { described_class['fix_pipeline/v1'] }

    it 'has supported_events limited to pipeline_hooks' do
      expect(flow.supported_events).to eq([::Ai::FlowTrigger::EVENT_TYPES[:pipeline_hooks]])
    end

    it 'has a precondition requiring failed pipeline status' do
      expect(flow.precondition).to eq({
        'match' => 'all',
        'rules' => [
          { 'field' => 'object_attributes.status', 'operator' => 'eq', 'value' => 'failed' }
        ]
      })
    end

    it 'has resolve_noteable defined' do
      expect(flow.resolve_noteable).to be_present
    end
  end

  describe 'flows that disallow event triggers' do
    where(:foundational_flow_reference) do
      %w[resolve_sast_vulnerability/v1 sast_fp_detection/v1 secrets_fp_detection/v1
        resolve_dependency_bump/experimental]
    end

    with_them do
      it 'has supported_events set to an empty array' do
        expect(described_class[foundational_flow_reference].supported_events).to eq([])
      end
    end
  end

  describe '.code_review' do
    subject(:code_review) { described_class.code_review }

    it 'returns the code review foundational flow' do
      expect(code_review.foundational_flow_reference).to eq('code_review/v1')
      expect(code_review.display_name).to eq('Code Review')
      expect(code_review.ai_feature).to eq('review_merge_request')
      expect(code_review.feature_maturity).to eq('ga')
    end
  end

  describe '#resolve_noteable_for' do
    let_it_be(:project) { create(:project) }

    context 'when the flow has no resolve_noteable' do
      let(:flow) { described_class['convert_to_gl_ci/v1'] }

      it 'returns nil' do
        expect(flow.resolve_noteable_for(project: project, goal: 'https://gitlab.com/-/pipelines/1')).to be_nil
      end
    end

    context 'when the flow is code review' do
      let(:flow) { described_class['code_review/v1'] }
      let_it_be(:merge_request) { create(:merge_request, source_project: project) }

      it 'returns the merge request matching the iid goal' do
        expect(flow.resolve_noteable_for(project: project, goal: merge_request.iid)).to eq(merge_request)
      end

      it 'returns nil when no merge request matches the goal' do
        expect(flow.resolve_noteable_for(project: project, goal: non_existing_record_iid)).to be_nil
      end
    end

    context 'when the flow has resolve_noteable defined' do
      let(:flow) { described_class['fix_pipeline/v1'] }

      context 'with a valid pipeline URL for a merge request pipeline' do
        let_it_be(:merge_request) { create(:merge_request, source_project: project) }
        let_it_be(:pipeline) do
          create(:ci_pipeline, project: project, merge_request: merge_request)
        end

        let(:goal) { "https://gitlab.com/#{project.full_path}/-/pipelines/#{pipeline.id}" }

        it 'returns the merge request' do
          expect(flow.resolve_noteable_for(project: project, goal: goal)).to eq(merge_request)
        end
      end

      context 'when the pipeline has no associated merge request' do
        let_it_be(:pipeline) { create(:ci_pipeline, project: project) }
        let(:goal) { "https://gitlab.com/#{project.full_path}/-/pipelines/#{pipeline.id}" }

        it 'returns nil' do
          expect(flow.resolve_noteable_for(project: project, goal: goal)).to be_nil
        end
      end

      context 'with a malformed goal URL' do
        it 'returns nil' do
          expect(flow.resolve_noteable_for(project: project, goal: 'not-a-url')).to be_nil
        end
      end

      context 'with a nil goal' do
        it 'returns nil' do
          expect(flow.resolve_noteable_for(project: project, goal: nil)).to be_nil
        end
      end

      context 'when the pipeline belongs to a different project' do
        let_it_be(:other_project) { create(:project) }
        let_it_be(:other_pipeline) { create(:ci_pipeline, project: other_project) }
        let(:goal) { "https://gitlab.com/#{other_project.full_path}/-/pipelines/#{other_pipeline.id}" }

        it 'returns nil because the pipeline is scoped to the given project' do
          expect(flow.resolve_noteable_for(project: project, goal: goal)).to be_nil
        end
      end
    end
  end

  describe 'security_review/v1' do
    subject(:flow) { described_class['security_review/v1'] }

    it 'returns the security review foundational flow', :aggregate_failures do
      expect(flow.foundational_flow_reference).to eq('security_review/v1')
      expect(flow.display_name).to eq('Security Review')
      expect(flow.description).to eq('Review merge request code changes for business logic security vulnerabilities.')
      expect(flow.feature_maturity).to eq('beta')
      expect(flow.ai_feature).to eq('security_review')
      expect(flow.environment).to eq('web')
      expect(flow.ultimate_only).to be true
      expect(flow.suppress_mention_progress_note).to be true
    end

    it 'is beta' do
      expect(described_class.beta?('security_review/v1')).to be true
    end

    it 'is ultimate-only' do
      expect(described_class.ultimate_only?('security_review/v1')).to be true
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

    context 'with empty agent_privileges' do
      let(:definition) { described_class.new(agent_privileges: [], pre_approved_agent_privileges: [1, 2]) }

      it 'copies pre_approved_agent_privileges' do
        expect(agent_privileges).to match_array([1, 2])
      end
    end

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

  describe '#catalog_item' do
    subject(:catalog_item) { definition.catalog_item }

    context 'with foundational_flow_reference' do
      let_it_be(:definition) { described_class.new(foundational_flow_reference: 'code_review') }
      let_it_be(:duo_code_review) do
        create(:ai_catalog_item, foundational_flow_reference: 'code_review')
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
end
