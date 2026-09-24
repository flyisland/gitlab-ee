# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WikiPage do
  let(:project) { create(:project, :public, :repository) }
  let(:wiki) { create(:project_wiki, project: project) }
  let(:wiki_page) { create(:wiki_page, wiki: wiki) }

  describe '#human_title' do
    context "with content blocked state" do
      before do
        allow(ContentValidation::Setting).to receive(:content_validation_enable?).and_return(true)
      end

      let!(:content_blocked_state) do
        create(:content_blocked_state, container: wiki, commit_sha: wiki_page.version.commit.id, path: wiki_page.path)
      end

      it "return illegal content" do
        expect(wiki_page.human_title).to eq("Illegal content")
      end
    end
  end
end
