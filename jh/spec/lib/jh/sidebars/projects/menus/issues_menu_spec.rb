# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::IssuesMenu do
  let(:project) { build(:project) }
  let(:user) { project.first_owner }
  let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project) }

  describe 'Ligaai issues' do
    let(:project) { create(:project, has_external_issue_tracker: true) }
    let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project) }
    let(:ligaai_integration) { create(:ligaai_integration, project: project) }

    subject { described_class.new(context) }

    shared_examples 'includes Ligaai issues menu items' do
      it "shows in the sidebar" do
        expect(subject.send(:show_ligaai_menu_items?)).to be(true)
        expect(subject.renderable_items.any? { |e| e.item_id == :ligaai_issue_list }).to be(true)
      end
    end

    shared_examples 'does not include Ligaai issues menu items' do
      it 'does not show in the sidebar' do
        expect(subject.send(:show_ligaai_menu_items?)).to be(false)
        expect(subject.renderable_items.any? { |e| e.item_id == :ligaai_issue_list }).to be(false)
      end
    end

    context 'when Ligaai integration is enabled' do
      before do
        stub_licensed_features(ligaai_issues_integration: true)
        ligaai_integration.update!(active: true)
      end

      context 'when Issues feature is enabled' do
        before do
          allow(project).to receive(:issues_enabled?).and_return(true)
        end

        it_behaves_like 'includes Ligaai issues menu items'
      end

      context 'when Issues feature is disabled' do
        before do
          allow(project).to receive(:issues_enabled?).and_return(false)
        end

        it_behaves_like 'includes Ligaai issues menu items'
      end
    end

    context 'when Ligaai integration is disabled' do
      before do
        stub_licensed_features(ligaai_issues_integration: false)
      end

      context 'when Issues feature is disabled' do
        before do
          allow(project).to receive(:issues_enabled?).and_return(false)
        end

        it_behaves_like 'does not include Ligaai issues menu items'
      end
    end
  end

  describe 'ONES issues' do
    let(:project) { create(:project, has_external_issue_tracker: true) }
    let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project) }
    let(:ones_integration) { create(:ones_integration, project: project) }

    subject { described_class.new(context) }

    shared_examples 'includes ONES issues menu items' do
      it "shows in the sidebar" do
        expect(subject.send(:show_ones_menu_items?)).to be(true)
        expect(subject.renderable_items.any? { |e| e.item_id == :ones_issue_list }).to be(true)
        expect(subject.renderable_items.any? { |e| e.item_id == :ones_external_link }).to be(true)
      end
    end

    shared_examples 'does not include ONES issues menu items' do
      it 'does not show in the sidebar' do
        expect(subject.send(:show_ones_menu_items?)).to be(false)
        expect(subject.renderable_items.any? { |e| e.item_id == :ones_issue_list }).to be(false)
        expect(subject.renderable_items.any? { |e| e.item_id == :ones_external_link }).to be(false)
      end
    end

    context 'when ONES integration is enabled' do
      before do
        stub_licensed_features(ones_issues_integration: true)
        ones_integration.update!(active: true)
      end

      context 'when Issues feature is enabled' do
        before do
          allow(project).to receive(:issues_enabled?).and_return(true)
        end

        it_behaves_like 'includes ONES issues menu items'
      end

      context 'when Issues feature is disabled' do
        before do
          allow(project).to receive(:issues_enabled?).and_return(false)
        end

        it_behaves_like 'includes ONES issues menu items'
      end
    end

    context 'when ONES integration is disabled' do
      before do
        stub_licensed_features(ones_issues_integration: false)
      end

      context 'when Issues feature is disabled' do
        before do
          allow(project).to receive(:issues_enabled?).and_return(false)
        end

        it_behaves_like 'does not include ONES issues menu items'
      end
    end
  end
end
