# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Repositories::PostReceiveWorker do
  include AfterNextHelpers

  let(:changes) { "123456 789012 refs/heads/tést\n654321 210987 refs/tags/tag" }
  let(:wrongly_encoded_changes) { changes.encode("ISO-8859-1").force_encoding("UTF-8") }
  let(:base64_changes) { Base64.encode64(wrongly_encoded_changes) }
  let(:gl_repository) { "project-#{project.id}" }
  let(:key) { create(:key, user: project.owner) }
  let(:key_id) { key.shell_id }
  let(:project) { create(:project) }

  before do
    allow(ContentValidation::Setting).to receive(:check_enabled?).and_return(true)
    stub_feature_flags(incremental_cache_for_refs: false)
  end

  subject { described_class.new.perform(gl_repository, key_id, base64_changes) }

  describe "#process_project_changes" do
    let(:fake_hook_data) { Hash.new(event_name: 'repository_update') }

    before do
      allow_next(Gitlab::DataBuilder::Repository)
        .to receive(:update).and_return(fake_hook_data)

      # silence hooks so we can isolate
      allow_next(Key).to receive(:post_create_hook).and_return(true)

      expect_next(Git::TagPushService).to receive(:execute).and_return(true)
      expect_next(Git::BranchPushService).to receive(:execute).and_return(true)
    end

    it "calls ContentValidation::ProcessChangesService#execute" do
      expect(::ContentValidation::ProcessChangesService).to get_executed
      subject
    end
  end

  describe "#process_wiki_changes" do
    before do
      allow_next(::Git::WikiPushService).to receive(:execute).and_return(true)
    end

    context "with a project wiki" do
      let(:wiki) { build(:project_wiki, project: project) }
      let(:gl_repository) { "project-#{project.id}-wiki" }

      it "calls ContentValidation::ProcessChangesService#execute" do
        expect(::ContentValidation::ProcessChangesService).to get_executed
        subject
      end
    end

    context "with a group wiki" do
      let(:group) { create(:group) }
      let(:wiki) { build(:group_wiki, group: group) }
      let(:gl_repository) { "group-#{group.id}-wiki" }

      it "calls ContentValidation::ProcessChangesService#execute" do
        expect(::ContentValidation::ProcessChangesService).to get_executed
        subject
      end
    end
  end

  describe "#process_snippet_changes" do
    let(:gl_repository) { "snippet-#{snippet.id}" }

    before do
      allow_next(::Snippets::UpdateStatisticsService).to receive(:execute).and_return(true)
    end

    context "with a personal snippet" do
      let(:snippet) { create(:personal_snippet, author: project.owner) }

      it "calls ContentValidation::ProcessChangesService#execute" do
        expect(::ContentValidation::ProcessChangesService).to get_executed
        subject
      end
    end

    context "with a project snippet" do
      let!(:snippet) { create(:project_snippet, :repository, project: project, author: project.first_owner) }

      it "calls ContentValidation::ProcessChangesService#execute" do
        expect(::ContentValidation::ProcessChangesService).to get_executed
        subject
      end
    end
  end
end
