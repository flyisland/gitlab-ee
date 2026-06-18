# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NoteEntity do
  include Gitlab::Routing

  let_it_be(:issue, freeze: false) { create(:issue) }
  let_it_be(:description_version) { create(:description_version, issue: issue) }
  let_it_be(:system_note_metadata, freeze: false) { create(:system_note_metadata, description_version: description_version) }
  let_it_be(:system_note, freeze: false) do
    create(:system_note, project: issue.project, noteable: issue, system_note_metadata: system_note_metadata)
  end

  let_it_be(:plain_note) do
    create(:note, project: issue.project, noteable: issue)
  end

  let(:note) { plain_note }
  let(:request) { double('request', current_user: issue.author, noteable: issue) }
  let(:entity) { described_class.new(note, request: request) }

  subject { entity.as_json }

  describe 'duo_session_url' do
    let_it_be(:workflow) { create(:duo_workflows_workflow, project: issue.project) }
    let_it_be(:duo_metadata) do
      create(:note_duo_metadata, note: plain_note, workflow_id: workflow.id, namespace_id: issue.namespace_id)
    end

    context 'when duo agent platform is available' do
      before do
        allow(::Ai::DuoWorkflow).to receive(:duo_agent_platform_available?).and_return(true)
      end

      context 'when the note is not a system note' do
        it 'exposes the workflow web_url as duo_session_url' do
          expect(subject[:duo_session_url]).to eq(workflow.web_url)
        end

        context 'when the note has no duo_metadata' do
          let_it_be(:note_without_metadata) { create(:note, project: issue.project, noteable: issue) }

          let(:note) { note_without_metadata }

          it 'exposes duo_session_url as nil' do
            expect(subject[:duo_session_url]).to be_nil
          end
        end
      end

      context 'when the note is a system note' do
        let(:note) { system_note }

        it 'does not expose duo_session_url' do
          expect(subject.key?(:duo_session_url)).to be false
        end
      end
    end
  end

  describe 'description versions', feature_category: :team_planning do
    let(:note) { system_note }

    context 'when description_diffs license is available' do
      before do
        stub_licensed_features(description_diffs: true)
      end

      it 'includes description versions attributes' do
        expect(subject[:description_version_id]).to eq(description_version.id)
        expect(subject[:description_diff_path]).to eq(description_diff_project_issue_path(issue.project, issue, description_version.id))
        expect(subject[:delete_description_version_path]).to eq(delete_description_version_project_issue_path(issue.project, issue, description_version.id))
        expect(subject[:can_delete_description_version]).to eq(true)
      end
    end

    context 'when description_diffs license is not available' do
      before do
        stub_licensed_features(description_diffs: false)
      end

      it 'does not include description versions attributes' do
        expect(subject[:description_version_id]).to be_nil
        expect(subject[:description_diff_path]).to be_nil
        expect(subject[:delete_description_version_path]).to be_nil
        expect(subject[:can_delete_description_version]).to be_nil
      end
    end
  end
end
