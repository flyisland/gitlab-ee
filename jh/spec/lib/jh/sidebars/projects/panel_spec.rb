# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Panel, feature_category: :navigation do
  using RSpec::Parameterized::TableSyntax

  let_it_be_with_reload(:project) { create(:project, has_external_issue_tracker: true) }
  let(:context) { Sidebars::Projects::Context.new(current_user: nil, container: project, show_get_started_menu: false) }

  subject(:panel) { described_class.new(context) }

  describe 'ExternalIssueTrackerMenu' do
    where(:hidden_integration_item, :show_ligaai_menu_items, :expect_to_contains_external_issue_tracker_menu) do
      'ones'   | false  | false
      'zentao' | false  | false
      nil      | true   | false
      nil      | false  | true
    end

    with_them do
      before do
        create(:"#{hidden_integration_item}_integration", project: project) unless hidden_integration_item.nil?

        allow_next_instance_of(Sidebars::Projects::Menus::IssuesMenu) do |issues_menu|
          allow(issues_menu).to receive(:show_ligaai_menu_items?).and_return(show_ligaai_menu_items)
          allow(project).to receive(:external_issue_tracker).and_return(nil) if hidden_integration_item.nil?
        end
      end

      it 'contains ExternalIssueTracker menu as expected' do
        expect(contains_external_issue_tracker_menu?).to be(expect_to_contains_external_issue_tracker_menu)
      end
    end
  end

  describe 'Shimo inheritance configuration' do
    let_it_be(:group) { create(:group) }
    let_it_be(:project) { create(:project, namespace: group) }

    let(:group_integraion) { create(:shimo_integration, group: group, project: nil, active: group_active) }
    let(:project_integraion) { create(:shimo_integration, project: project) }

    let(:panel_menus) { panel.instance_variable_get(:@menus) }

    subject { panel_menus.any?(Sidebars::Projects::Menus::ShimoMenu) }

    context 'when Shimo is active on group level' do
      let(:group_active) { true }

      context 'when project configuration is inherited' do
        before do
          project_integraion.update(active: group_active, inherit_from_id: group_integraion.id)
        end

        it { is_expected.to be_truthy }
      end

      context 'when project configuration is specific' do
        context 'when turn on Shimo on project' do
          it { is_expected.to be_truthy }
        end

        context 'when turn off Shimo on project' do
          before do
            project_integraion.update(active: false)
          end

          it { is_expected.to be_falsey }
        end
      end
    end

    context 'when Shimo is inactive on group level' do
      let(:group_active) { false }

      context 'when project configuration is inherited' do
        before do
          project_integraion.update(active: group_active, inherit_from_id: group_integraion.id)
        end

        it { is_expected.to be_falsey }
      end

      context 'when project configuration is specific' do
        context 'when turn on Shimo on project' do
          it { is_expected.to be_truthy }
        end

        context 'when turn off Shimo on project' do
          before do
            project_integraion.update(active: false)
          end

          it { is_expected.to be_falsey }
        end
      end
    end
  end

  def contains_external_issue_tracker_menu?
    panel.instance_variable_get(:@menus).any?(Sidebars::Projects::Menus::ExternalIssueTrackerMenu)
  end
end
