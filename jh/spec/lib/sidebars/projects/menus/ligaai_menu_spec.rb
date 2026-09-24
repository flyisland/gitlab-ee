# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::LigaaiMenu do
  let(:project) { create(:project, has_external_issue_tracker: true) }
  let(:user) { project.first_owner }
  let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project) }
  let(:ligaai_integration) { create(:ligaai_integration, project: project) }

  subject { described_class.new(context) }

  describe '#render?' do
    context 'when issues integration is disabled' do
      before do
        ligaai_integration.update!(active: false)
      end

      it 'returns false' do
        expect(subject.render?).to be false
      end
    end

    context 'when issues integration is enabled' do
      before do
        ligaai_integration.update!(active: true)
      end

      it 'returns true' do
        expect(subject.render?).to be true
      end

      it 'renders menu link' do
        expect(subject.link).to eq ligaai_integration.url
      end

      it 'renders external-link icon' do
        expect(subject.sprite_icon).to eq 'external-link'
      end

      it 'renders LigaAI menu' do
        expect(subject.title).to eq s_('LigaaiIntegration|LigaAI')
      end

      it 'does not contain items' do
        expect(subject.renderable_items.count).to eq 0
      end
    end
  end
end
