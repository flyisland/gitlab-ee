# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::NotesController do
  include ProjectForksHelper

  let(:user)    { create(:user) }
  let(:issue)   { create(:issue, project: project) }
  let(:note)    { create(:note, noteable: issue, project: project) }
  let(:request_params) do
    {
      namespace_id: project.namespace,
      project_id: project,
      id: note,
      format: :json,
      note: {
        note: "New comment"
      }
    }
  end

  let(:illegal_characters_tips_with_appeal_email) do
    s_("JH|ContentValidation|Your content couldn't be submitted because it violated the rules. " \
      "If you believe this was a miscalculation, please email usersupport@gitlab.cn to appeal. " \
      "We will process your appeal within 24 hours (working days) and send the result to your registered " \
      "email address, please pay attention to it. Thank you for your understanding and support.")
  end

  describe 'PUT update' do
    context 'when application setting content validation is enable' do
      before do
        sign_in(note.author)
        project.add_developer(note.author)
      end

      context 'when note update invalid content with project is private' do
        before do
          stub_content_validation_request(false)
        end

        let(:project) { create(:project, :private) }

        it "updates the note" do
          expect { put :update, params: request_params }.to change { note.reset.note }
        end
      end

      context 'when project is public' do
        let(:project) { create(:project, :public) }

        context 'when note update with valid content' do
          before do
            stub_content_validation_request(true)
          end

          it "updates the note" do
            note_html = note.note_html
            expect { put :update, params: request_params }.to change { note.reset.note }
            expect(note.reset.note_html).not_to eq(note_html)
            expect(response).to have_gitlab_http_status(:ok)
          end
        end

        context 'when note update with invalid content' do
          before do
            stub_content_validation_request(false)
          end

          it "updates the note" do
            note_html = note.note_html
            expect { put :update, params: request_params }.not_to change { note.reset.note }
            expect(note.reset.note_html).to eq(note_html)
            expect(response).to have_gitlab_http_status(:unprocessable_entity)
            response_body = Gitlab::Json.parse(response.body)
            expect(response_body).to eq({
              "valid" => false,
              "content_invalid" => true,
              "errors" => illegal_characters_tips_with_appeal_email
            })
          end
        end
      end
    end

    context 'when application setting content validation is disabled' do
      before do
        sign_in(note.author)
        project.add_developer(note.author)
      end

      context 'when note update invalid content with project is private' do
        before do
          stub_content_validation_request(false)
          stub_application_setting(content_validation_endpoint_enabled: false)
        end

        let(:project) { create(:project, :private) }

        it "updates the note" do
          expect { put :update, params: request_params }.to change { note.reset.note }
        end
      end

      context 'when project is public' do
        let(:project) { create(:project, :public) }

        context 'when note update with valid content' do
          before do
            stub_content_validation_request(true)
            stub_application_setting(content_validation_endpoint_enabled: false)
          end

          it "updates the note" do
            note_html = note.note_html
            expect { put :update, params: request_params }.to change { note.reset.note }
            expect(note.reset.note_html).not_to eq(note_html)
            expect(response).to have_gitlab_http_status(:ok)
          end
        end

        context 'when note update with invalid content' do
          before do
            stub_content_validation_request(false)
            stub_application_setting(content_validation_endpoint_enabled: false)
          end

          it "updates the note" do
            note_html = note.note_html
            expect { put :update, params: request_params }.to change { note.reset.note }
            expect(note.reset.note_html).not_to eq(note_html)
            expect(response).to have_gitlab_http_status(:ok)
          end
        end
      end
    end
  end

  describe 'POST create' do
    let(:merge_request) { create(:merge_request) }
    let(:project) { merge_request.source_project }
    let(:note_text) { 'some note' }
    let(:request_params) do
      {
        note: {
          note: note_text,
          noteable_id: merge_request.id,
          noteable_type: 'MergeRequest'
        }.merge(extra_note_params),
        namespace_id: project.namespace,
        project_id: project,
        merge_request_diff_head_sha: 'sha',
        target_type: 'merge_request',
        target_id: merge_request.id
      }.merge(extra_request_params)
    end

    let(:extra_request_params) { { format: :json } }
    let(:extra_note_params) { {} }

    let(:project_visibility) { Gitlab::VisibilityLevel::PUBLIC }
    let(:merge_requests_access_level) { ProjectFeature::ENABLED }

    def create!
      post :create, params: request_params
    end

    before do
      project.update_attribute(:visibility_level, project_visibility)
      project.project_feature.update!(merge_requests_access_level: merge_requests_access_level)
      project.add_developer(user)
      sign_in(user)
    end

    context 'when application setting content validation is enable' do
      context 'when note create invalid content with project is private' do
        let(:project_visibility) { Gitlab::VisibilityLevel::PRIVATE }

        before do
          stub_content_validation_request(false)
        end

        it "create successful" do
          create!
          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'when project is public' do
        let(:project_visibility) { Gitlab::VisibilityLevel::PUBLIC }

        context 'when create note with valid content' do
          before do
            stub_content_validation_request(true)
          end

          it do
            create!
            expect(response).to have_gitlab_http_status(:ok)
          end
        end

        context 'when create note with invalid content' do
          before do
            stub_content_validation_request(false)
          end

          it do
            create!
            expect(response).to have_gitlab_http_status(:unprocessable_entity)
            response_body = Gitlab::Json.parse(response.body)
            expect(response_body).to eq({
              "valid" => false,
              "content_invalid" => true,
              "errors" => illegal_characters_tips_with_appeal_email
            })
          end
        end
      end
    end

    context 'when application setting content validation is disabled' do
      let(:project_visibility) { Gitlab::VisibilityLevel::PRIVATE }

      context 'when note create invalid content with project is private' do
        before do
          stub_content_validation_request(false)
          stub_application_setting(content_validation_endpoint_enabled: false)
        end

        it do
          create!
          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'when project is public' do
        let(:project_visibility) { Gitlab::VisibilityLevel::PUBLIC }

        context 'when note create with valid content' do
          before do
            stub_content_validation_request(true)
            stub_application_setting(content_validation_endpoint_enabled: false)
          end

          it do
            create!
            expect(response).to have_gitlab_http_status(:ok)
          end
        end

        context 'when note create with invalid content' do
          before do
            stub_content_validation_request(false)
            stub_application_setting(content_validation_endpoint_enabled: false)
          end

          it do
            create!
            expect(response).to have_gitlab_http_status(:ok)
          end
        end
      end
    end
  end
end
