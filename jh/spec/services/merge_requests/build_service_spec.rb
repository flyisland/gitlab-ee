# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/VerifiedDoubles
RSpec.describe MergeRequests::BuildService, feature_category: :code_review_workflow do
  using RSpec::Parameterized::TableSyntax
  include RepoHelpers
  include ProjectForksHelper

  let(:project) { create(:project, :repository, has_external_issue_tracker: true) }
  let(:source_project) { nil }
  let(:target_project) { nil }
  let(:user) { create(:user) }
  let(:issue_confidential) { false }
  let(:issue) { create(:issue, project: project, title: 'A bug', confidential: issue_confidential) }
  let(:description) { nil }
  let(:source_branch) { 'feature' }
  let(:target_branch) { 'master' }
  let(:milestone_id) { nil }
  let(:label_ids) { [] }
  let(:merge_request) { service.execute }
  let(:compare) { double(:compare, commits: commits) }
  let(:commit_1) do
    double(:commit_1,
      sha: 'f00ba6',
      safe_message: 'Initial commit',
      gitaly_commit?: false,
      id: 'f00ba6',
      parent_ids: ['f00ba5'],
      author_email: 'tom@example.com',
      author_name: 'Tom Example')
  end

  let(:commit_2) do
    double(:commit_2,
      sha: 'f00ba7',
      safe_message: "Closes #1234 Second commit\n\nCreate the app",
      gitaly_commit?: false,
      id: 'f00ba7',
      parent_ids: ['f00ba6'],
      author_email: 'alice@example.com',
      author_name: 'Alice Example')
  end

  let(:commit_3) do
    double(:commit_3,
      sha: 'f00ba8',
      safe_message: 'This is a bad commit message!',
      gitaly_commit?: false,
      id: 'f00ba8',
      parent_ids: ['f00ba7'],
      author_email: 'jo@example.com',
      author_name: 'Jo Example')
  end

  let(:commits) { nil }

  let(:params) do
    {
      description: description,
      source_branch: source_branch,
      target_branch: target_branch,
      source_project: source_project,
      target_project: target_project,
      milestone_id: milestone_id,
      label_ids: label_ids
    }
  end

  let(:service) do
    described_class.new(project: project, current_user: user, params: params)
  end

  before do
    project.repository.create_branch(source_branch, target_branch) if source_branch && target_branch
    project.add_guest(user)
  end

  def stub_compare
    allow(CompareService).to receive_message_chain(:new, :execute).and_return(compare)
    allow(project).to receive(:commit).and_return(commit_1)
    allow(project).to receive(:commit).and_return(commit_2)
    allow(project).to receive(:commit).and_return(commit_3)
  end

  describe '#execute' do
    context 'when one commit in the diff' do
      let(:commits) { Commit.decorate([commit_2], project) }
      let(:commit_description) { commit_2.safe_message.split(/\n+/, 2).last }

      before do
        stub_compare
      end

      context 'when the source branch matches an issue' do
        where(:factory, :source_branch, :closing_message) do
          :ones_integration | '123-fix-issue' | 'Closes #123'
          :ones_integration | 'fix-issue'     | nil
        end

        with_them do
          before do
            if factory
              create(factory, project: project)
              project.reload # rubocop:disable Cop/ActiveRecordAssociationReload
            else
              issue.update!(iid: 123)
            end
          end

          it 'builds the merge_request successfully' do
            expect(merge_request).to be_valid
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/VerifiedDoubles
