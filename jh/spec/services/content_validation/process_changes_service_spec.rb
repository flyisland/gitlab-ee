# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContentValidation::ProcessChangesService, feature_category: :source_code_management do
  let_it_be(:group)    { create(:group) }
  let_it_be(:user)     { create(:user) }
  let_it_be(:project, freeze: false) { create(:project, :repository, :public, group: group) }

  let(:container) { project }
  let(:repo_type) { Gitlab::GlRepository::PROJECT }
  let(:default_branch) { container.default_branch }
  let(:commit) { container.repository.commit(default_branch) }
  let(:changes) { [{ oldrev: Gitlab::Git::SHA1_BLANK_SHA, newrev: commit.id, ref: "refs/heads/#{default_branch}" }] }

  before do
    allow(ContentValidation::Setting).to receive(:content_validation_enable?).and_return(true)
    allow_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
      allow(client).to receive(:pre_check).and_return(
        instance_double(HTTParty::Response, success?: true, parsed_response: { "skip_validate" => false })
      )
    end
  end

  subject(:service_instance) do
    described_class.new(container: container, project: project, repo_type: repo_type, user: user, changes: changes)
  end

  describe "#execute" do
    context "without user" do
      let(:user) { nil }

      it "return false" do
        expect(ContentValidation::CommitServiceWorker).not_to receive(:perform_async)
        expect(service_instance.execute).to be(false)
      end
    end

    context "with pre_check skip_validate is true" do
      before do
        allow_next_instance_of(::Gitlab::ContentValidation::Client) do |client|
          allow(client).to receive(:pre_check).with(
            {
              user_username: user.username,
              group_full_path: group.full_path,
              project_full_path: project.full_path
            }
          ).and_return(
            instance_double(HTTParty::Response, success?: true, parsed_response: { "skip_validate" => true })
          )
        end
      end

      it "skip validate" do
        expect(ContentValidation::CommitServiceWorker).not_to receive(:perform_async)
        expect(service_instance.execute).to be(false)
      end
    end

    context "with project changes" do
      context "with private project" do
        let(:project) { create(:project, :repository, :private) }

        it "return false" do
          expect(ContentValidation::CommitServiceWorker).not_to receive(:perform_async)
          expect(service_instance.execute).to be(false)
        end
      end

      it "calls ContentValidation::CommitServiceWorker#perform_async" do
        expect(ContentValidation::CommitServiceWorker).to receive(:perform_async).at_least(:once)
        service_instance.execute
      end

      context "with branch changes" do
        context "when create default branch" do
          it "calls ContentValidation::CommitServiceWorker#perform_async" do
            expect(ContentValidation::CommitServiceWorker).to receive(:perform_async).at_least(:once)
            service_instance.execute
          end
        end

        context "when create new branch" do
          let(:commit) do
            project.repository.create_file(
              project.creator,
              'README.md',
              "README on branch test",
              message: 'Add README.md',
              branch_name: "test")
            project.repository.commit("test")
          end

          let(:changes) { [{ oldrev: Gitlab::Git::SHA1_BLANK_SHA, newrev: commit.id, ref: "refs/heads/test" }] }

          it "calls ContentValidation::CommitServiceWorker#perform_async" do
            expect(ContentValidation::CommitServiceWorker).to receive(:perform_async).at_least(:once)
            service_instance.execute
          end
        end

        context "when update branch" do
          let(:prev_commit) { project.repository.commits(default_branch, limit: 1, offset: 1)[0] }
          let(:changes) { [{ oldrev: prev_commit.id, newrev: commit.id, ref: "refs/heads/#{default_branch}" }] }

          it "calls ContentValidation::CommitServiceWorker#perform_async once" do
            expect(ContentValidation::CommitServiceWorker).to(
              receive(:perform_async).with(commit.id, "project-#{project.id}", user.id).once)
            service_instance.execute
          end
        end

        context "when remove branch" do
          let(:changes) do
            [{ oldrev: commit.id, newrev: Gitlab::Git::SHA1_BLANK_SHA, ref: "refs/heads/#{default_branch}" }]
          end

          it "not calls ContentValidation::CommitServiceWorker#perform_async" do
            expect(ContentValidation::CommitServiceWorker).not_to receive(:perform_async)
            service_instance.execute
          end
        end
      end

      context "with tag changes" do
        context "when create new tag" do
          let(:commit) do
            project.repository.create_file(
              project.creator,
              'test.md',
              "test",
              message: 'test',
              branch_name: "test")
            project.repository.commit("test")
          end

          let(:changes) { [{ oldrev: Gitlab::Git::SHA1_BLANK_SHA, newrev: commit.id, ref: "refs/tags/vtest" }] }

          before do
            Commits::TagService.new(project, user, { tag_name: "vtest", tag_message: "test" }).execute(commit)
          end

          it "calls ContentValidation::CommitServiceWorker#perform_async" do
            expect(ContentValidation::CommitServiceWorker).to receive(:perform_async).at_least(:once)
            service_instance.execute
          end
        end
      end
    end

    context "with wiki changes" do
      let(:repo_type) { Gitlab::GlRepository::WIKI }
      let(:container) { wiki }
      let!(:wiki_page) { create(:wiki_page, wiki: wiki, container: project) }

      context "with private wiki container" do
        let(:project) { create(:project, :repository, :private) }
        let(:wiki) { build(:project_wiki, :empty_repo, project: project) }

        it "return false" do
          expect(ContentValidation::CommitServiceWorker).not_to receive(:perform_async)
          expect(service_instance.execute).to be(false)
        end
      end

      context "with group wiki" do
        let(:project) { nil }
        let(:wiki) { build(:group_wiki, :empty_repo, container: group) }
        let!(:wiki_page) { create(:wiki_page, wiki: wiki, container: group) }

        it "calls ContentValidation::CommitServiceWorker#perform_async" do
          expect(ContentValidation::CommitServiceWorker).to receive(:perform_async).at_least(:once)
          service_instance.execute
        end
      end

      context "with project wiki" do
        let(:wiki) { build(:project_wiki, :empty_repo, project: project) }

        it "calls ContentValidation::CommitServiceWorker#perform_async" do
          expect(ContentValidation::CommitServiceWorker).to receive(:perform_async).at_least(:once)
          service_instance.execute
        end
      end
    end

    context "with snippet changes" do
      let(:repo_type) { Gitlab::GlRepository::SNIPPET }
      let(:container) { snippet }

      context "with private snippet" do
        let(:snippet) { create(:project_snippet, :repository, :private) }

        it "return false" do
          expect(ContentValidation::CommitServiceWorker).not_to receive(:perform_async)
          expect(service_instance.execute).to be(false)
        end
      end

      context "with personal snippet" do
        let(:snippet) { create(:personal_snippet, :repository, :public) }

        it "calls ContentValidation::CommitServiceWorker#perform_async" do
          expect(ContentValidation::CommitServiceWorker).to receive(:perform_async).at_least(:once)
          service_instance.execute
        end
      end

      context "with project snippet" do
        let(:snippet) { create(:project_snippet, :repository, :public) }

        it "calls ContentValidation::CommitServiceWorker#perform_async" do
          expect(ContentValidation::CommitServiceWorker).to receive(:perform_async).at_least(:once)
          service_instance.execute
        end
      end
    end
  end
end
