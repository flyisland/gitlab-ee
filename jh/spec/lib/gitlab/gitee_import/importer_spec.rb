# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers -- Just for testing
RSpec.describe Gitlab::GiteeImport::Importer do
  let(:project_identifier) { 'namespace/repo' }
  let(:data) { { gitee_access_token: 'abc123' } }

  let(:all_methods) do
    [
      :import_wiki, :import_labels, :import_milestones, :import_issues,
      :import_pull_requests, :import_releases, :handle_errors
    ]
  end

  let(:project) do
    create(
      :project,
      :repository,
      import_source: project_identifier,
      import_type: 'gitee',
      import_url: "https://gitee.com/#{project_identifier}.git",
      import_data_attributes: { credentials: data }
    )
  end

  let(:importer) { described_class.new(project) }
  let(:sample) { RepoHelpers.sample_compare }

  let(:source_branch) { 'feature' }
  let(:target_branch) { project.default_branch }

  let(:repo) do
    instance_double(
      Gitee::Representation::Repo,
      owner_and_slug: %w[namespace repo],
      owner: 'namespace',
      slug: 'repo',
      clone_url: 'https://oauth2:abc123@gitee.com/namespace/repo.git',
      description: 'repo description',
      full_name: 'namespace/repo',
      issues_enabled?: true,
      name: 'repo',
      has_wiki?: true,
      visibility_level: ::Gitlab::VisibilityLevel::PRIVATE,
      to_s: 'namespace/repo'
    )
  end

  let(:label1) do
    instance_double(
      Gitee::Representation::Label,
      color: '#FFFFFF',
      title: 'bug',
      url: 'https://test.gitee.com/bug',
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let(:label2) do
    instance_double(
      Gitee::Representation::Label,
      color: '#FFFFFA',
      title: 'test',
      url: 'https://test.gitee.com/test',
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let(:milestone1) do
    instance_double(
      Gitee::Representation::Milestone,
      title: 'milestone1',
      description: 'milestone1 description',
      due_date: Time.zone.today,
      state: 'active',
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let(:milestone2) do
    instance_double(
      Gitee::Representation::Milestone,
      title: 'milestone2',
      description: 'milestone2 description',
      due_date: Time.zone.today,
      state: 'active',
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let(:issue1) do
    instance_double(
      Gitee::Representation::Issue,
      number: 1,
      author: 'author',
      description: 'issue1 description',
      title: 'issue1',
      state: 'opened',
      labels: [],
      milestone: 'milestone1',
      closed?: false,
      due_date: Time.now,
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let(:issue2) do
    instance_double(
      Gitee::Representation::Issue,
      number: 2,
      author: 'author',
      description: 'issue2 description',
      title: 'issue2',
      state: 'opened',
      labels: ['test'],
      milestone: 'milestone1',
      closed?: false,
      due_date: Time.now,
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let(:issue_comment1) do
    instance_double(
      Gitee::Representation::IssueComment,
      iid: 1,
      author: 'author',
      note: 'test note',
      has_parent?: false,
      parent_id: nil,
      user: { name: 'author' },
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let(:issue_comment2) do
    instance_double(
      Gitee::Representation::IssueComment,
      iid: 2,
      author: 'author',
      note: 'test reply note',
      has_parent?: true,
      parent_id: 1,
      user: { name: 'author' },
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let(:source_branch_sha) { project.repository.commit(source_branch).sha }
  let(:target_branch_sha) { project.repository.commit(target_branch).sha }

  let(:pull_request1) do
    instance_double(
      Gitee::Representation::PullRequest,
      author: 'author',
      description: 'pr1 description',
      iid: 1,
      state: 'opened',
      title: 'pr1',
      source_branch_sha: source_branch_sha,
      source_branch_name: source_branch,
      target_branch_sha: target_branch_sha,
      target_branch_name: target_branch,
      labels: ['test'],
      milestone: 'milestone1',
      draft?: false,
      created_at: Time.now,
      updated_at: Time.now,
      raw: {}
    )
  end

  let(:pull_request_comment1) do
    instance_double(
      Gitee::Representation::PullRequestComment,
      iid: 1,
      file_path: 'a.rb',
      author_name: 'author',
      note: 'test note',
      inline?: false,
      has_parent?: false,
      parent_id: nil,
      new_pos: nil,
      old_pos: nil,
      author: { name: 'author' },
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let(:pull_request_comment2) do
    instance_double(
      Gitee::Representation::PullRequestComment,
      iid: 2,
      file_path: 'a.rb',
      author_name: 'author',
      note: 'test reply note',
      inline?: false,
      has_parent?: true,
      parent_id: 1,
      new_pos: nil,
      old_pos: nil,
      author: { name: 'author' },
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let(:release1) do
    instance_double(
      Gitee::Representation::Release,
      name: 'tes1',
      tag_name: 'v1',
      body: 'test',
      author_name: 'author',
      author: { name: 'author' },
      created_at: Time.now
    )
  end

  subject { described_class.new(project) }

  def when_testing(method_name)
    allow_called_methods = all_methods - [method_name]
    allow_called_methods.each do |method|
      allow(subject).to receive(method)
    end
  end

  describe '#execute' do
    before do
      unless project.repository.branch_exists?(source_branch)
        project.repository.create_branch(source_branch, target_branch)
      end

      allow_any_instance_of(Gitee::Client).to receive(:repo).and_return(repo)
      allow_any_instance_of(Gitee::Client).to receive(:labels).and_return([label1, label2])
      allow_any_instance_of(Gitee::Client).to receive(:milestones).and_return([milestone1, milestone2])
      allow_any_instance_of(Gitee::Client).to receive(:issues).and_return([issue1, issue2])
      allow_any_instance_of(Gitee::Client).to receive(:pull_requests).and_return([pull_request1])
      allow_any_instance_of(Gitee::Client).to receive(:issue_comments).and_return([issue_comment1, issue_comment2])
      allow_any_instance_of(Gitee::Client).to receive(:pull_request_comments).and_return(
        [pull_request_comment1, pull_request_comment2]
      )
      allow_any_instance_of(Gitee::Client).to receive(:releases).and_return([release1])
    end

    context 'when execute' do
      before do
        allow(project.wiki.repository).to receive(:import_repository).and_return(true)
      end

      it 'calls import methods' do
        all_methods.each do |method_name|
          expect(subject).to receive(method_name)
        end

        expect_next_instance_of(Gitlab::Import::Metrics) do |metrics|
          expect(metrics).to receive(:track_finished_import)
        end

        subject.execute
      end
    end

    context 'when execute an error occurs' do
      before do
        allow(project.wiki.repository).to receive(:import_repository).and_raise(Gitlab::Git::CommandError)
      end

      it 'returns true' do
        expect(subject.execute).to be true
      end

      it 'does not raise an error' do
        expect { subject.execute }.not_to raise_error
      end

      it 'stores error messages' do
        error = {
          message: 'The remote data could not be fully imported.',
          errors: [
            { type: :wiki, errors: "Gitlab::Git::CommandError" }
          ]
        }

        described_class.new(project).execute
        expect(project.import_state.last_error).to eq Gitlab::Json.generate(error)
      end
    end

    context 'when importing a Gitee project' do
      subject { described_class.new(project) }

      describe '#client' do
        it 'instantiates a Client' do
          expect(Gitee::Client).to receive(:new).with(data)

          subject.client
        end
      end
    end
  end

  describe '#import_labels' do
    let(:invalid_label) do
      instance_double(
        Gitee::Representation::Label,
        color: '#FFFFFF',
        title: nil,
        url: 'https://test.gitee.com/bug',
        created_at: Time.now,
        updated_at: Time.now
      )
    end

    before do
      when_testing(:import_labels)
      allow_any_instance_of(Gitee::Client).to receive(:labels).and_return([invalid_label])
    end

    context 'with invalid labels' do
      it 'raises an error' do
        subject.execute
        expect(subject.errors.count).to eq(1)
      end
    end
  end

  describe '#import_milestones' do
    let(:invalid_milestone) do
      instance_double(
        Gitee::Representation::Milestone,
        title: nil,
        description: 'milestone1 description',
        due_date: Time.zone.today,
        state: 'active',
        created_at: Time.now,
        updated_at: Time.now
      )
    end

    before do
      when_testing(:import_milestones)
      allow_any_instance_of(Gitee::Client).to receive(:milestones).and_return([invalid_milestone])
    end

    context 'with invalid milestones' do
      it 'raises an error' do
        subject.execute
        expect(subject.errors.count).to eq(1)
      end
    end
  end

  describe '#import_issues' do
    let(:issue3) do
      instance_double(
        Gitee::Representation::Issue,
        number: 3,
        author: 'author',
        description: 'issue3 description',
        title: 'issue3',
        state: 'opened',
        labels: [],
        milestone: 'milestone1',
        closed?: false,
        due_date: Time.zone.today,
        created_at: Time.now,
        updated_at: Time.now
      )
    end

    let(:invalid_issue) do
      instance_double(
        Gitee::Representation::Issue,
        number: nil,
        author: nil,
        description: "",
        title: nil,
        state: nil,
        labels: nil,
        milestone: nil,
        closed?: nil,
        created_at: nil,
        due_date: Time.zone.today,
        updated_at: Time.now
      )
    end

    let(:invalid_parent_issue_comment) do
      instance_double(
        Gitee::Representation::IssueComment,
        iid: 1,
        author: nil,
        note: 'aaa',
        has_parent?: false,
        parent_id: nil,
        user: { name: nil },
        created_at: Time.now,
        updated_at: Time.now
      )
    end

    let(:invalid_children_issue_comment) do
      instance_double(
        Gitee::Representation::IssueComment,
        iid: 3,
        author: nil,
        note: 'invalid_children_issue_comment',
        has_parent?: true,
        parent_id: 1,
        user: { name: nil },
        created_at: Time.now,
        updated_at: Time.now
      )
    end

    before do
      when_testing(:import_issues)
    end

    context 'with invalid issues' do
      before do
        allow_any_instance_of(Gitee::Client).to receive(:repo).and_return(repo)
        allow_any_instance_of(Gitee::Client).to receive(:issues).and_return([invalid_issue])
        allow_any_instance_of(Issue).to receive(:valid?).and_return(false)
      end

      it 'raises an error' do
        subject.execute

        expect(subject.errors.count).to eq(1)
      end
    end

    context 'with invalid parent issue comments' do
      before do
        allow_any_instance_of(Gitee::Client).to receive(:repo).and_return(repo)
        allow_any_instance_of(Gitee::Client).to receive(:issues).and_return([issue3])
        allow_any_instance_of(Gitee::Client).to receive(:issue_comments).and_return(
          [invalid_parent_issue_comment])
        allow_next_instance_of(Note) do |comment|
          allow(comment).to receive(:valid?).and_return(false)
        end
      end

      it 'raises an error' do
        subject.execute

        expect(subject.errors.count).to eq(1)
      end
    end

    context 'with invalid children issue comments' do
      before do
        allow_any_instance_of(Gitee::Client).to receive(:repo).and_return(repo)
        allow_any_instance_of(Gitee::Client).to receive(:issues).and_return([issue1])
        allow_any_instance_of(Gitee::Client).to receive(:issue_comments).and_return(
          [invalid_children_issue_comment])
      end

      it 'raises an error' do
        subject.execute

        expect(subject.errors.count).to eq(1)
      end
    end
  end

  describe '#import_pull_requests' do
    before do
      when_testing(:import_pull_requests)
    end

    context 'with invalid pull requests' do
      let(:invalid_pr) do
        instance_double(
          Gitee::Representation::PullRequest,
          author: 'author',
          description: 'invalid_pr description',
          iid: 1,
          state: 'opened',
          title: nil,
          source_branch_sha: nil,
          source_branch_name: nil,
          target_branch_sha: nil,
          target_branch_name: nil,
          labels: [],
          milestone: 'milestone1',
          draft?: true,
          created_at: Time.now,
          updated_at: Time.now,
          raw: {}
        )
      end

      before do
        allow_any_instance_of(Gitee::Client).to receive(:pull_requests).and_return([invalid_pr])
      end

      it 'raises an error' do
        subject.execute

        expect(subject.errors.count).to eq(1)
      end
    end

    context 'with invalid parent pull request comments' do
      let(:pull_request3) do
        instance_double(
          Gitee::Representation::PullRequest,
          author: 'author',
          description: 'pr3 description',
          iid: 3,
          state: 'opened',
          title: 'pr3',
          source_branch_sha: source_branch_sha,
          source_branch_name: source_branch,
          target_branch_sha: target_branch_sha,
          target_branch_name: target_branch,
          labels: [],
          draft?: false,
          milestone: 'milestone1',
          created_at: Time.now,
          updated_at: Time.now,
          raw: {}
        )
      end

      let(:invalid_pr_parent_comment) do
        instance_double(
          Gitee::Representation::PullRequestComment,
          iid: 2,
          file_path: nil,
          author_name: nil,
          note: nil,
          inline?: false,
          has_parent?: false,
          parent_id: nil,
          new_pos: nil,
          old_pos: nil,
          author: { name: nil },
          created_at: Time.now,
          updated_at: Time.now
        )
      end

      before do
        allow_any_instance_of(Gitee::Client).to receive(:pull_requests).and_return([pull_request3])
        allow_any_instance_of(Gitee::Client).to receive(:pull_request_comments).and_return(
          [invalid_pr_parent_comment]
        )
        allow_next_instance_of(Note) do |comment|
          allow(comment).to receive(:valid?).and_return(false)
        end
      end

      it 'raises an error' do
        subject.execute

        expect(subject.errors.count).to eq(1)
      end
    end

    context 'with invalid children pull request comments' do
      let(:pull_request4) do
        instance_double(
          Gitee::Representation::PullRequest,
          author: 'author',
          description: 'pr4 description',
          iid: 3,
          state: 'opened',
          title: 'pr4',
          source_branch_sha: source_branch_sha,
          source_branch_name: source_branch,
          target_branch_sha: target_branch_sha,
          target_branch_name: target_branch,
          labels: [],
          draft?: false,
          milestone: 'milestone1',
          created_at: Time.now,
          updated_at: Time.now,
          raw: {}
        )
      end

      let(:invalid_pr_children_comment) do
        instance_double(
          Gitee::Representation::PullRequestComment,
          iid: 4,
          file_path: nil,
          author_name: nil,
          note: nil,
          inline?: false,
          has_parent?: true,
          parent_id: 1,
          new_pos: nil,
          old_pos: nil,
          author: { name: nil },
          created_at: Time.now,
          updated_at: Time.now
        )
      end

      before do
        allow_any_instance_of(Gitee::Client).to receive(:pull_requests).and_return([pull_request4])
        allow_any_instance_of(Gitee::Client).to receive(:pull_request_comments).and_return(
          [invalid_pr_children_comment]
        )
      end

      it 'raises an error' do
        subject.execute

        expect(subject.errors.count).to eq(1)
      end
    end
  end

  describe '#import_releases' do
    let(:release2) do
      instance_double(
        Gitee::Representation::Release,
        name: nil,
        tag_name: nil,
        body: nil,
        author_name: nil,
        author: { name: nil },
        created_at: Time.now
      )
    end

    before do
      when_testing(:import_releases)
    end

    context 'with invalid releases' do
      before do
        allow_any_instance_of(Gitee::Client).to receive(:releases).and_return([release2])
      end

      it 'raises an error' do
        subject.execute

        expect(subject.errors.count).to eq(1)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
