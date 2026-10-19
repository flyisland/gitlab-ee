# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContentValidation::CommitService do
  let_it_be(:group) { create(:group) }
  let_it_be(:user)  { create(:user) }

  before do
    allow(ContentValidation::Setting).to receive(:check_enabled?).and_return(true)
  end

  describe "#validate_trees" do
    let(:project)  { create(:project, :repository, group: group) }
    let(:commit) { project.commit("master") }
    let(:diff_file) { commit.diffs.diff_files.first }
    let(:blob) { diff_file.blob }
    let(:tree) { project.repository.tree("master", "") }

    subject(:instance) do
      described_class.new(
        commit: commit,
        container: project,
        project: project,
        repo_type: Gitlab::GlRepository::PROJECT, user: user)
    end

    it "client call blob_validate" do
      expect_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
        expect(client).to receive(:blob_validate)
          .with(hash_including(container_identifier: "project-#{project.id}",
            project_id: project.id,
            project_full_path: project.full_path,
            group_id: group.id,
            group_full_path: group.full_path,
            repo_type: :project,
            commit_sha: commit.id,
            user_id: user.id,
            user_username: user.username,
            user_email: user.email,
            blob_sha: commit.sha,
            incremental: false,
            content_type: "tree")).at_least(:once)
      end

      instance.validate_trees
    end

    describe "#get_parent_dirnames" do
      it "return parent dirnames" do
        expect(instance.send(:get_parent_dirnames, "app/models/test.rb")).to eq(["", "app", "app/models"])
      end
    end
  end

  describe "#validate_blobs" do
    context "for project commit" do
      let(:project)  { create(:project, :repository, group: group) }
      let(:commit) { project.commit("master") }
      let(:diff_file) { commit.diffs.diff_files.first }
      let(:blob) { diff_file.blob }

      subject(:instance) do
        described_class.new(
          commit: commit,
          container: project,
          project: project,
          repo_type: Gitlab::GlRepository::PROJECT, user: user)
      end

      it "client call blob_validate" do
        expect_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
          expect(client).to receive(:blob_validate)
            .with(hash_including(container_identifier: "project-#{project.id}",
              project_id: project.id,
              project_full_path: project.full_path,
              group_id: group.id,
              group_full_path: group.full_path,
              repo_type: :project,
              commit_sha: commit.id,
              user_id: user.id,
              user_username: user.username,
              user_email: user.email,
              blob_sha: blob.id,
              path: blob.path,
              incremental: false,
              content_type: "text",
              text: Base64.encode64(diff_file_content(diff_file))))
        end

        instance.validate_blobs
      end

      context "with image binary file" do
        before do
          allow_any_instance_of(Blob).to receive(:binary?).and_return(true)
          allow_any_instance_of(Blob).to receive(:extension).and_return("jpg")
        end

        it "client call blob_validate" do
          expect_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
            expect(client).to receive(:blob_validate)
              .with(hash_including(content_type: "image", image: Base64.strict_encode64(blob.data)))
          end

          instance.validate_blobs
        end
      end

      context "with video binary file" do
        before do
          allow_any_instance_of(Blob).to receive(:binary?).and_return(true)
          allow_any_instance_of(Blob).to receive(:extension).and_return("mp4")
        end

        it "client call blob_validate" do
          expect_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
            expect(client).to receive(:blob_validate)
              .with(hash_including(content_type: "video", video: Base64.strict_encode64(blob.data)))
          end

          instance.validate_blobs
        end
      end

      context "with audio binary file" do
        before do
          allow_any_instance_of(Blob).to receive(:binary?).and_return(true)
          allow_any_instance_of(Blob).to receive(:extension).and_return("mp3")
        end

        it "client call blob_validate" do
          expect_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
            expect(client).to receive(:blob_validate)
              .with(hash_including(content_type: "audio", audio: Base64.strict_encode64(blob.data)))
          end

          instance.validate_blobs
        end
      end

      context "with last_for_path_commit blocked" do
        let(:blob) { commit.diffs.diff_files.first.blob }
        let(:last_for_path_commit) { commit.parent }

        before do
          allow(Gitlab::Git::Commit).to receive(:last_for_path).and_return(last_for_path_commit)
          create(:content_blocked_state, container: project, commit_sha: last_for_path_commit.id, path: blob.path)
        end

        it "validate total data" do
          expect_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
            expect(client).to receive(:blob_validate)
              .with(hash_including(incremental: false, text: Base64.encode64([blob.name, blob.data].join("\n"))))
          end

          instance.validate_blobs
        end
      end

      context "with large file size" do
        before do
          allow_any_instance_of(Gitlab::Git::Blob).to receive(:size).and_return(3.megabytes)
          allow_any_instance_of(Gitlab::Git::Diff).to receive(:diff_bytesize).and_return(3.megabytes)
        end

        it "not validate blob data" do
          expect_any_instance_of(Gitlab::ContentValidation::Client).not_to receive(:blob_validate)

          instance.validate_blobs
        end
      end
    end

    context "for wiki commit" do
      let(:project) { create(:project, :wiki_repo, group: group) }
      let(:wiki_page) { create(:wiki_page, project: project) }
      let(:commit) { wiki_page.version.commit }

      subject(:instance) do
        described_class.new(
          commit: commit,
          container: project.wiki,
          project: project,
          repo_type: Gitlab::GlRepository::WIKI, user: user)
      end

      it "client call blob_validate" do
        expect_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
          diffs(project.wiki, commit).diff_files.each do |diff_file|
            blob = diff_file.blob
            expect(client).to receive(:blob_validate)
              .with(hash_including(container_identifier: "wiki-#{project.id}",
                project_id: project.id,
                project_full_path: project.full_path,
                group_id: group.id,
                group_full_path: group.full_path,
                repo_type: :wiki,
                commit_sha: commit.id,
                user_id: user.id,
                user_username: user.username,
                user_email: user.email,
                blob_sha: blob.id,
                path: blob.path,
                incremental: false,
                content_type: "text",
                text: Base64.encode64(diff_file_content(diff_file))))
          end
        end

        instance.validate_blobs
      end
    end

    context "for snippet commit" do
      let(:project)  { create(:project, group: group) }
      let(:snippet)  { create(:project_snippet, :repository, project: project) }
      let(:commit)   { snippet.repository.head_commit }
      let(:diff_file) { diffs(snippet, commit).diff_files.first }
      let(:blob) { diff_file.blob }

      subject(:instance) do
        described_class.new(
          commit: commit,
          container: snippet,
          project: project,
          repo_type: Gitlab::GlRepository::SNIPPET, user: user)
      end

      it "client call blob_validate" do
        expect_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
          expect(client).to receive(:blob_validate)
            .with(hash_including(container_identifier: "snippet-#{snippet.id}",
              project_id: project.id,
              project_full_path: project.full_path,
              group_id: group.id,
              group_full_path: group.full_path,
              repo_type: :snippet,
              commit_sha: commit.id,
              user_id: user.id,
              user_username: user.username,
              user_email: user.email,
              blob_sha: blob.id,
              path: blob.path,
              incremental: false,
              content_type: "text",
              text: Base64.encode64(diff_file_content(diff_file))))
        end

        instance.validate_blobs
      end
    end
  end

  def diffs(container, commit)
    Gitlab::Diff::FileCollection::Base.new(
      commit,
      project: container,
      diff_refs: commit.diff_refs
    )
  end

  def diff_file_content(diff_file)
    if diff_file.new_file?
      [diff_file.blob.name, diff_file.blob.data].join("\n")
    else
      diff_file.diff.diff.split("\n").grep(/^\+/).map { |line| line[1..] }.join("\n")
    end
  end
end
