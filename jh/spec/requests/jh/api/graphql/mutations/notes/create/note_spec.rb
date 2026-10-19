# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Adding a Note', feature_category: :team_planning do
  include GraphqlHelpers
  include ApiHelpers
  include JH::ContentValidationMessagesTestHelper

  let_it_be(:current_user) { create(:user) }

  let(:noteable) { create(:issue, project: project) }
  let(:project) { create(:project, :public, :repository) }
  let(:discussion) { nil }
  let(:head_sha) { nil }
  let(:body) { 'Body text' }
  let(:mutation) do
    variables = {
      noteable_id: GitlabSchema.id_from_object(noteable).to_s,
      discussion_id: (GitlabSchema.id_from_object(discussion).to_s if discussion),
      merge_request_diff_head_sha: head_sha.presence,
      body: body
    }

    graphql_mutation(:create_note, variables)
  end

  def mutation_response
    graphql_mutation_response(:create_note)
  end

  context 'with content validation' do
    before do
      noteable
      discussion
      allow(ContentValidation::Setting).to receive(:content_validation_enable?).and_return(true)
      project.add_developer(current_user)
    end

    context "when note content is valid" do
      before do
        stub_content_validation_request(true)
      end

      it "create new note" do
        expect do
          post_graphql_mutation(mutation, current_user: current_user)
        end.to change { Note.count }.by(1)
      end
    end

    context "when note content is not valid" do
      before do
        stub_content_validation_request(false)
      end

      it 'returns an empty Note and errors' do
        expect do
          post_graphql_mutation(mutation, current_user: current_user)
        end.not_to change { Note.count }

        expect(mutation_response).to have_key('note')
        expect(mutation_response['note']).to be_nil
        expect(mutation_response['errors'].first).to include(illegal_characters_tips_with_appeal_email)
      end
    end

    context 'when body only contains quick actions' do
      let(:body) { '/close' }

      it 'returns a nil note and info about the command in quickActionsStatus' do
        post_graphql_mutation(mutation, current_user: current_user)

        expect(mutation_response).to include(
          'errors' => [],
          'note' => nil,
          'quickActionsStatus' => {
            "commandNames" => ["close"],
            "commandsOnly" => true,
            "messages" => ["Closed this issue."],
            "errorMessages" => nil
          }
        )
      end
    end
  end
end
