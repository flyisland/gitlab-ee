# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('tooling/lib/tooling/gettext_extractor')

RSpec.describe ::Gitlab::Patch::ToolingGettextExtractor do
  subject do
    klass = Class.new do
      def self.gettext_messages_by_file
        @gettext_messages_by_file ||= ::Gitlab::Json.parse(load_messages)
      end
    end

    klass.prepend(described_class)
  end

  before do
    status = {}
    Tooling::GettextExtractor.prepend(described_class)
    allow(status).to receive(:success?).and_return(true)
    allow(Open3).to receive(:capture2)
                      .with("node jh/scripts/frontend/extract_gettext_all.js --all")
                      .and_return([
                        '{"example.js": [ ["JS"], ["All"], ["Mango\u0000Mangoes"], ["Context|A"], ["All2"] ] }',
                        status
                      ])
  end

  describe '#parse' do
    it 'scans JH frontend files' do
      expect(Tooling::GettextExtractor.new.send(:parse_frontend_files).map(&:msgid)).to match_array(
        ['JS', 'All', 'Mango', 'Context|A', 'All2']
      )
    end
  end
end
