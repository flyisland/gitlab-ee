# frozen_string_literal: true

module Gitlab
  module GiteeImport
    class Importer
      attr_reader :project, :client, :errors, :users

      def initialize(project)
        @project = project
        @client = ::Gitee::Client.new(project.import_data.credentials)
        @formatter = Gitlab::ImportFormatter.new
        @labels = {}
        @milestones = {}
        @errors = []
        @users = {}
      end

      def execute
        import_wiki
        import_labels
        import_milestones
        import_issues
        import_pull_requests
        import_releases
        handle_errors
        metrics.track_finished_import

        true
      end

      private

      def handle_errors
        return unless errors.any?

        project.import_state.update_column(:last_error,
          Gitlab::Json.generate(
            {
              message: s_('JH|Gitee Import|The remote data could not be fully imported.'),
              errors: errors
            }
          ))
      end

      def repo
        @repo ||= client.repo(project.import_source)
      end

      def import_wiki
        return if project.wiki.repository_exists?

        wiki = WikiFormatter.new(project)

        project.wiki.repository.import_repository(wiki.import_url)
      rescue StandardError => e
        errors << { type: :wiki, errors: e.message }
      end

      def import_labels
        client.labels(gitee_repo_path).each do |label|
          import_label(label)
        end
      end

      def import_label(label)
        params = label_params(label)
        created_label = ::Labels::FindOrCreateService.new(nil, project, params).execute(skip_authorization: true)

        unless created_label.valid?
          raise format(s_('JH|Gitee Import|Failed to create label %{label} for project %{project}'),
            label: params[:title], project: project.full_name)
        end

        @labels[params[:title]] = created_label
      rescue StandardError => e
        errors << { type: :label, iid: created_label.title, errors: e.message }
      end

      def import_milestones
        client.milestones(gitee_repo_path).each do |milestone|
          import_milestone(milestone)
        end
      end

      def import_milestone(milestone)
        params = milestone_params(milestone)

        created_milestone = project.milestones.create(params)

        unless created_milestone.valid?
          raise format(s_('JH|Gitee Import|Failed to create milestone %{milestone} for project %{project}'),
            milestone: params[:title], project: project.full_name)
        end

        @milestones[params[:title]] = created_milestone
      rescue StandardError => e
        errors << { type: :milestone, iid: created_milestone.title, errors: e.message }
      end

      def import_issues
        return unless repo.issues_enabled?

        client.issues(gitee_repo_path).each do |issue|
          import_issue(issue)
        end
      end

      def import_issue(issue)
        issue_labels = issue.labels
        params = issue_params(issue)
        gitlab_issue = project.issues.create(params)

        unless gitlab_issue.valid?
          raise format(s_('JH|Gitee Import|Failed to create issue %{issue} for project %{project}'),
            issue: params[:title], project: project.full_name)
        end

        metrics.issues_counter.increment
        issue_labels.each do |label_name|
          gitlab_issue.labels << @labels[label_name]
        end

        import_issue_comments(issue, gitlab_issue) if gitlab_issue.persisted?
      rescue StandardError => e
        errors << { type: :issue, iid: issue.number, errors: e.message }
      end

      def import_issue_comments(issue, gitlab_issue)
        issue_comments = client.issue_comments(gitee_repo_path, issue.number)

        created_notes = {}
        discussion_map = {}

        children, parents = issue_comments.partition(&:has_parent?)
        import_parent_issue_comments(issue, gitlab_issue, parents) do |comment, note|
          discussion_map[comment.iid] = note.discussion_id
          created_notes[comment.iid] = note
        end

        import_children_issue_comments(issue, gitlab_issue, children, created_notes, discussion_map)
      end

      def import_parent_issue_comments(issue, gitlab_issue, parent_comments)
        parent_comments.each do |comment|
          next unless comment.note.present?

          begin
            params = note_params(comment)
            note = gitlab_issue.notes.create!(params)
            yield(comment, note)
          rescue StandardError => e
            errors << { type: :issue_comment, iid: issue.number, errors: e.message }
          end
        end
      end

      def import_children_issue_comments(issue, gitlab_issue, children_comments, created_notes, discussion_map)
        children_comments.each do |comment|
          next unless comment.note.present?

          begin
            params = note_params(comment)
            params[:discussion_id] = discussion_map[comment.parent_id]
            params[:type] = 'DiscussionNote'
            gitlab_issue.notes.create!(params)
            created_notes[comment.parent_id].update(type: 'DiscussionNote')
          rescue StandardError => e
            errors << { type: :issue_comment, iid: issue.number, errors: e.message }
          end
        end
      end

      def import_pull_requests
        client.pull_requests(gitee_repo_path).each do |pull_request|
          import_pull_request(pull_request)
        end
      end

      def import_pull_request(pull_request)
        pull_request_labels = pull_request.labels
        params = pull_request_params(pull_request)
        created_merge_request = project.merge_requests.create(params)

        unless created_merge_request.valid?
          raise format(s_('JH|Gitee Import|Failed to create merge request %{merge_request} for project %{project}'),
            merge_request: params[:title], project: project.full_name)
        end

        metrics.merge_requests_counter.increment

        pull_request_labels.each do |label|
          created_merge_request.labels << @labels[label]
        end

        import_pull_request_comments(pull_request, created_merge_request)
      rescue StandardError => e
        store_pull_request_error(pull_request, e)
      end

      def import_pull_request_comments(pull_request, merge_request)
        comments = client.pull_request_comments(gitee_repo_path, pull_request.iid)
        _, pr_comments = comments.partition(&:inline?)
        import_standalone_pr_comments(pr_comments, merge_request)
      end

      def import_standalone_pr_comments(pr_comments, merge_request)
        created_notes = {}
        discussion_map = {}

        children, parents = pr_comments.partition(&:has_parent?)

        parents.each do |comment|
          params = pull_request_comment_params(comment)
          note = merge_request.notes.create!(params)
          discussion_map[comment.iid] = note.discussion_id
          created_notes[comment.iid] = note
        rescue StandardError => e
          errors << { type: :pull_request_comment, iid: comment.iid, errors: e.message }
        end

        children.each do |comment|
          params = pull_request_comment_params(comment)
          params[:discussion_id] = discussion_map[comment.parent_id]
          params[:type] = 'DiscussionNote'
          merge_request.notes.create!(params)
          created_notes[comment.parent_id].update(type: 'DiscussionNote')
        rescue StandardError => e
          errors << { type: :pull_request_comment, iid: comment.iid, errors: e.message }
        end
      end

      def import_releases
        client.releases(gitee_repo_path).each do |release|
          import_release(release)
        end
      end

      def import_release(release)
        release_params = release_params(release)
        project.releases.create!(release_params)

      rescue StandardError => e
        errors << { type: :release, tag: release.tag_name, errors: e.message }
      end

      def release_params(release)
        {
          tag: release.tag_name,
          name: release.name,
          description: release.body,
          author_id: gitlab_user_id(project, release.author_name),
          created_at: release.created_at
        }
      end

      def label_params(label)
        {
          title: label.title,
          color: label.color,
          created_at: label.created_at,
          updated_at: label.updated_at
        }
      end

      def milestone_params(milestone)
        {
          title: milestone.title,
          description: milestone.description,
          due_date: milestone.due_date,
          state: milestone.state,
          created_at: milestone.created_at,
          updated_at: milestone.updated_at
        }
      end

      def issue_params(issue)
        description = ''
        description += @formatter.author_line(issue.author) unless find_user_id(issue.author)
        description += issue.description
        issue_type_id = ::WorkItems::TypesFramework::Provider.new(project).default_issue_type.id
        milestone = issue.milestone ? @milestones[issue.milestone] : nil

        {
          title: issue.title,
          description: description,
          state_id: ::Issue.available_states[issue.state],
          author_id: gitlab_user_id(project, issue.author),
          namespace_id: project.project_namespace_id,
          milestone: milestone,
          work_item_type_id: issue_type_id,
          due_date: issue.due_date,
          created_at: issue.created_at,
          updated_at: issue.updated_at
        }
      end

      def note_params(comment)
        note = ''
        note += @formatter.author_line(comment.author) unless find_user_id(comment.author)
        note += comment.note

        {
          project: project,
          note: note,
          author_id: gitlab_user_id(project, comment.author),
          created_at: comment.created_at,
          updated_at: comment.updated_at
        }
      end

      def pull_request_params(pull_request)
        description = ''
        description += @formatter.author_line(pull_request.author) unless find_user_id(pull_request.author)
        description += pull_request.description

        source_branch_sha = pull_request.source_branch_sha
        target_branch_sha = pull_request.target_branch_sha
        source_branch_sha = project.repository.commit(source_branch_sha)&.sha || source_branch_sha
        target_branch_sha = project.repository.commit(target_branch_sha)&.sha || target_branch_sha

        pull_request_title = pull_request.draft? ? "Draft: #{pull_request.title}" : pull_request.title

        milestone = pull_request.milestone ? @milestones[pull_request.milestone] : nil
        {
          iid: pull_request.iid,
          title: pull_request_title,
          description: description,
          source_project: project,
          source_branch: pull_request.source_branch_name,
          source_branch_sha: source_branch_sha,
          target_project: project,
          target_branch: pull_request.target_branch_name,
          target_branch_sha: target_branch_sha,
          state: pull_request.state,
          author_id: gitlab_user_id(project, pull_request.author),
          draft: pull_request.draft?,
          milestone: milestone,
          created_at: pull_request.created_at,
          updated_at: pull_request.updated_at
        }
      end

      def pull_request_comment_params(comment)
        {
          project: project,
          author_id: gitlab_user_id(project, comment.author_name),
          note: comment_note(comment),
          created_at: comment.created_at,
          updated_at: comment.updated_at
        }
      end

      def comment_note(comment)
        author = @formatter.author_line(comment.author_name) unless find_user_id(comment.author_name)

        author.to_s + comment.note.to_s
      end

      def gitee_repo_path
        project.import_source
      end

      def gitlab_user_id(project, username)
        find_user_id(username) || project.creator_id
      end

      def find_user_id(username)
        return unless username

        return users[username] if users.key?(username)

        users[username] = ::User.by_provider_and_extern_uid(:gitee, username).select(:id).first&.id
      end

      def store_pull_request_error(pull_request, ex)
        backtrace = Gitlab::BacktraceCleaner.clean_backtrace(ex.backtrace)
        error = {
          type: :pull_request,
          iid: pull_request.iid,
          errors: ex.message,
          trace: backtrace,
          raw_response: pull_request.raw&.to_json
        }

        Gitlab::ErrorTracking.log_exception(ex, error)

        # Omit the details from the database to avoid blowing up usage in the error column
        error.delete(:trace)
        error.delete(:raw_response)

        errors << error
      end

      def metrics
        @metrics ||= Gitlab::Import::Metrics.new(:gitee_importer, @project)
      end
    end
  end
end
