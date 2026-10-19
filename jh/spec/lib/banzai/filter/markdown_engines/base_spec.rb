# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Banzai::Filter::MarkdownEngines::Base do
  let(:import_type) { nil }
  let(:project) { create(:project, import_type: import_type) }
  let(:description) do
    <<~MARKDOWN.strip
      Line start;
      line end.

      We want to `keep \n in code block`.

      | header A | header B|
      | ------ | ------ |
      | cell 1 | cell 2|
      | cell 3 | cell 4|

      ```ruby
      def render(text)
        CommonMarker.render_html(text, render_options, EXTENSIONS)
      end
      ```
    MARKDOWN
  end

  let(:issue) { create(:issue, project: project, description: description) }

  subject(:html) { issue.description_html }

  context 'with a normal project with no imports from Gitee' do
    let(:import_type) { nil }

    it 'render markdown as normal' do
      expect(html).to include(">Line start;\nline end.</p>\n")
      expect(html).not_to include('<br>')
    end
  end

  context 'with a project imported from Gitee' do
    let(:import_type) { 'gitee' }

    context 'when create' do
      it 'render markdown with :HARDBREAKS option' do
        expect(html).to include(">Line start;\nline end.</p>\n")
      end
    end

    context 'when update' do
      it 'render markdown with :HARDBREAKS option' do
        issue.update(description: "line start;\nline end.")

        expect(html).to eq <<~HTML.strip
          <p data-sourcepos="1:1-2:9" dir="auto">line start;
          line end.</p>
        HTML
      end
    end
  end
end
