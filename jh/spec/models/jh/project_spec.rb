# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Project, feature_category: :groups_and_projects do
  describe '#after_import' do
    context 'in content validation' do
      let(:user) { create(:user) }
      let(:wiki) { project.wiki }
      let(:wiki_page) { create(:wiki_page, wiki: wiki) }
      let(:import_state) { create(:import_state, project: project) }

      before do
        stub_application_setting(content_validation_endpoint_enabled: true)
        allow(Gitlab).to receive(:com?).and_return(true)
        allow(import_state).to receive(:finish)
        allow_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
          allow(client).to receive(:pre_check).and_return(instance_double(HTTParty::Response, success?: false))
        end
        project
        wiki_page
      end

      context "with public project" do
        let(:project) { create(:project, :repository, :wiki_repo, :public, creator: user) }

        it 'call ContentValidation::ContainerService and ContentValidation::ProjectScanWorker' do
          expect(ContentValidation::ContainerService).to receive(:new)
            .with(hash_including(container: project, user: user)).ordered.and_call_original
          expect(ContentValidation::ContainerService).to receive(:new)
            .with(hash_including(container: wiki, user: user)).ordered.and_call_original
          expect(ContentValidation::ProjectScanWorker).to receive(:perform_async).with(project.id)
          project.after_import
        end
      end

      context "with private project" do
        let(:project) { create(:project, :repository, :wiki_repo, :private, creator: user) }

        it 'not validation when project is private' do
          expect(ContentValidation::ContainerService).not_to receive(:new)
          project.after_import
        end
      end
    end
  end

  describe '#pages_available?', :saas do
    let(:project) { create(:project, group: group) }
    let(:group) { create(:group) }

    subject { project.pages_available? }

    before do
      allow(Gitlab.config.pages).to receive(:enabled).and_return(true)
    end

    context 'when disable ff jh_pages' do
      before do
        stub_feature_flags(jh_pages: false)
      end

      it { is_expected.to be(false) }

      context 'when only enabled in specific group' do
        before do
          stub_feature_flags(jh_pages: group)
        end

        context 'when the project is in a top level namespace' do
          it { is_expected.to be(true) }
        end

        context 'when the project is in a subgroup' do
          let(:sub_group) { create(:group, parent: group) }
          let(:project) { create(:project, group: sub_group) }

          it { is_expected.to be(true) }
        end
      end
    end
  end

  describe '#disabled_integrations' do
    let(:project) { create(:project) }

    it 'does not disable shimo integrations' do
      expect(project.disabled_integrations).not_to include('shimo')
    end

    it 'disable third party integrations with its feature flag disabled' do
      stub_feature_flags(integration_with_ligaai_issues: false)
      stub_feature_flags(wecom_integration: false)

      expect(project.disabled_integrations).to include('ligaai', 'wecom')
    end

    context 'with licensed features' do
      { zentao_issues_integration: 'zentao', ones_issues_integration: 'ones' }.each do |feature, item|
        context 'when licensed feature is available' do
          before do
            stub_licensed_features(feature => true)
          end

          it "does not disable #{item} integrations" do
            expect(project.disabled_integrations).not_to include(item)
          end
        end

        context 'when licensed feature is not available' do
          before do
            stub_licensed_features(feature => false)
          end

          it "disable #{item} integrations" do
            expect(project.disabled_integrations).to include(item)
          end
        end
      end
    end
  end

  describe '#ci_template_variables' do
    let(:project) { create(:project) }

    context 'with jh SaaS' do
      it 'adds value registry.gitlab.cn to CI_TEMPLATE_REGISTRY_HOST' do
        expect(project.ci_template_variables['CI_TEMPLATE_REGISTRY_HOST'].value).to eq('registry.gitlab.cn')
      end
    end

    context 'with hk SaaS' do
      before do
        allow(Gitlab).to receive(:hk?).and_return(true)
      end

      it 'adds value registry.gitlab.com to CI_TEMPLATE_REGISTRY_HOST' do
        expect(project.ci_template_variables['CI_TEMPLATE_REGISTRY_HOST'].value).to eq('registry.gitlab.com')
      end
    end
  end

  describe '#merge_method' do
    using RSpec::Parameterized::TableSyntax

    let_it_be_with_reload(:project) { create(:project, squash_option: :always) }

    where(:merge_requests_ff_only_enabled, :merge_requests_rebase_enabled, :merge_method, :comment) do
      true  | true  | :ff                  | 'Fast-forward merges only'
      true  | false | :single_squash_merge | 'Single squash merge'
      false | true  | :rebase_merge        | 'Merge commit with semi-linear history'
      false | false | :merge               | 'Merge commit'
    end

    with_them do
      before do
        project.update(merge_requests_ff_only_enabled: merge_requests_ff_only_enabled,
          merge_requests_rebase_enabled: merge_requests_rebase_enabled)
      end

      it 'returns current merge_method' do
        expect(project.merge_method).to eq merge_method
      end
    end

    context 'with single squash merge method attributes and non-always squash option' do
      before do
        project.update(merge_requests_ff_only_enabled: true,
          merge_requests_rebase_enabled: false,
          squash_option: :never)
      end

      it 'fallbacks to fast-forward' do
        expect(project.merge_method).to eq :ff
      end
    end
  end

  describe '#merge_method=' do
    let_it_be_with_reload(:project) { create(:project, squash_option: :never) }

    context 'when single_squash_merge' do
      before do
        project.merge_method = :single_squash_merge
      end

      context 'with invalid squash option' do
        before do
          project.squash_option = 'never'
        end

        it 'fallbacks to fast-forward' do
          expect(project.merge_method).to eq :ff
        end
      end

      context 'with always squash option' do
        before do
          project.squash_option = 'always'
        end

        it 'is valid' do
          expect(project).to be_valid

          expect(project.merge_requests_ff_only_enabled).to be_truthy
          expect(project.merge_requests_rebase_enabled).to be_falsey
        end
      end
    end
  end

  describe '#breadcrumbs' do
    let(:project) { build(:project, :repository) }

    before do
      allow(project).to receive(:full_path).and_return(
        'root-group/sub-group/project'
      )
    end

    it 'returns the breadcrumbs' do
      expect(project.breadcrumbs).to eq(
        [
          { text: 'root-group', href: '/root-group' },
          { text: 'sub-group', href: '/root-group/sub-group' },
          { text: 'project', href: '/root-group/sub-group/project' }
        ]
      )
    end
  end
end
