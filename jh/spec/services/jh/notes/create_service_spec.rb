# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Notes::CreateService, feature_category: :team_planning do
  let_it_be(:user) { create(:user) }
  let(:project) { create(:project, :public, :repository) }
  let(:issue) { create(:issue, project: project) }
  let(:snippet) { create(:project_snippet, project: project) }
  let(:base_opts) { { note: 'Awesome comment', noteable_type: 'Issue', noteable_id: issue.id } }
  let(:opts) { base_opts.merge(confidential: true) }
  let(:illegal_characters_tips_with_appeal_email) do
    s_("JH|ContentValidation|Your content couldn't be submitted because it violated the rules. " \
      "If you believe this was a miscalculation, please email usersupport@gitlab.cn to appeal. " \
      "We will process your appeal within 24 hours (working days) and send the result to your registered " \
      "email address, please pay attention to it. Thank you for your understanding and support.")
  end

  describe '#execute' do
    context "with content validation enabled" do
      before do
        allow(ContentValidation::Setting).to receive(:content_validation_enable?).and_return(true)
        project.add_maintainer(user)
      end

      context "when project is public" do
        context "when issuable is not issue" do
          let(:base_opts) { { note: 'Awesome comment', noteable_type: 'Snippet', noteable_id: snippet.id } }

          it 'not call content validation service' do
            expect_any_instance_of(ContentValidation::ContentValidationService).not_to receive(:valid?)
            described_class.new(project, user, opts).execute
          end
        end

        context "when issuable is issue" do
          context "with valid note" do
            before do
              stub_content_validation_request(true)
            end

            it 'create successfully' do
              note = described_class.new(project, user, opts).execute
              expect(note.errors).to be_blank
              expect(note).to be_persisted
            end
          end

          context "with invalid note" do
            before do
              project
              issue
              stub_content_validation_request(false)
            end

            it 'create failed' do
              note = described_class.new(project, user, opts).execute
              expect(note.errors).to be_present
              expect(note.errors[:note].first).to eq(illegal_characters_tips_with_appeal_email)
              expect(note).not_to be_persisted
            end
          end
        end
      end

      context "when project is private" do
        let(:project) { create(:project, :private, :repository) }

        it 'not call content validation service' do
          expect_any_instance_of(ContentValidation::ContentValidationService).not_to receive(:valid?)
          described_class.new(project, user, opts).execute
        end
      end
    end
  end
end
