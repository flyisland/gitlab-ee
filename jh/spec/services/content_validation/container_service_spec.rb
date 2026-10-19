# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContentValidation::ContainerService do
  let_it_be(:user) { create(:user) }
  let_it_be(:project, freeze: false) { create(:project, :repository, :public) }

  before do
    allow(ContentValidation::Setting).to receive(:check_enabled?).and_return(true)
  end

  subject(:service_execute) { described_class.new(container: container, user: user).execute }

  describe "#execute" do
    context "when container is a project" do
      let(:container) { project }

      it "call ContentValidation::ProcessChangesService#execute" do
        expect(ContentValidation::ProcessChangesService).to receive(:new)
          .with(hash_including(
            container: container,
            project: project,
            repo_type: ::Gitlab::GlRepository::PROJECT,
            user: user,
            changes: [{
              oldrev: ::Gitlab::Git::SHA1_BLANK_SHA,
              newrev: container.repository.commit.id,
              ref: "refs/heads/#{container.repository.root_ref}"
              }])
               ).and_call_original
        service_execute
      end
    end

    context "when container is a wiki" do
      let!(:wiki_page) { create(:wiki_page, wiki: project.wiki, container: project) }
      let(:container)  { project.wiki }

      it "call ContentValidation::ProcessChangesService#execute" do
        expect(ContentValidation::ProcessChangesService).to receive(:new)
          .with(hash_including(
            container: container,
            project: project,
            repo_type: ::Gitlab::GlRepository::WIKI,
            user: user,
            changes: [{
              oldrev: ::Gitlab::Git::SHA1_BLANK_SHA,
              newrev: container.repository.commit.id,
              ref: "refs/heads/#{container.repository.root_ref}"
              }])
               ).and_call_original
        service_execute
      end
    end

    context "when container is a snippet" do
      let(:container) { create(:project_snippet, :repository, :public, project: project) }

      it "call ContentValidation::ProcessChangesService#execute" do
        expect(ContentValidation::ProcessChangesService).to receive(:new)
          .with(hash_including(
            container: container,
            project: project,
            repo_type: ::Gitlab::GlRepository::SNIPPET,
            user: user,
            changes: [{
              oldrev: ::Gitlab::Git::SHA1_BLANK_SHA,
              newrev: container.repository.commit.id,
              ref: "refs/heads/#{container.repository.root_ref}"
              }])
               ).and_call_original
        service_execute
      end
    end
  end
end
