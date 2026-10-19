# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Entities::WikiPage, feature_category: :wiki do
  include JH::ContentValidationMessagesTestHelper
  context "with content validation enable" do
    let_it_be(:project, freeze: false) { create(:project, :public, :repository) }
    let_it_be(:wiki, freeze: false) { create(:project_wiki, project: project) }
    let_it_be(:wiki_page, freeze: false) { create(:wiki_page, wiki: wiki) }

    let(:blocked_message_html) do
      "According to the relevant laws and regulations, this content is not displayed.To appeal, please click"
    end

    let(:content_blocked_state) do
      create(:content_blocked_state, container: wiki, commit_sha: wiki_page.version.commit.id, path: wiki_page.path)
    end

    before do
      allow(ContentValidation::Setting).to receive(:block_enabled?).and_return(true)
    end

    context "with content blocked state" do
      before do
        content_blocked_state
      end

      context "when render_html is true" do
        it "render blocked messasge html" do
          expect(described_class.new(wiki_page, { render_html: true }).as_json[:content])
            .to include blocked_message_html
        end
      end

      context "when render_html is false" do
        it "render blocked messsage" do
          expect(described_class.new(wiki_page, { render_html: false }).as_json[:content])
            .to eq illegal_tips_with_appeal_email
        end
      end
    end

    context "without content blocked state" do
      context "when render_html is true" do
        it "render content" do
          expect(described_class.new(wiki_page, { render_html: true }).as_json[:content])
            .to include wiki_page.raw_content
        end
      end

      context "when render_html is false" do
        it "render content" do
          expect(described_class.new(wiki_page, { render_html: false }).as_json[:content])
            .to eq wiki_page.raw_content
        end
      end
    end
  end
end
