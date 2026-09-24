# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('tooling/lib/tooling/gettext_extractor')

RSpec.describe 'gettext', :silence_stdout do
  let(:locale_path) { Rails.root.join('tmp/jh/gettext_spec') }
  let(:cn_locale_path) { File.join(locale_path, 'zh_CN') }
  let(:en_locale_path) { File.join(locale_path, 'en') }
  let(:tw_locale_path) { File.join(locale_path, 'zh_TW') }
  let(:jh_pot_file_path) { File.join(locale_path, 'gitlab.pot') }
  let(:jh_cn_po_file_path) { File.join(cn_locale_path, 'gitlab.po') }
  let(:jh_en_po_file_path) { File.join(en_locale_path, 'gitlab.po') }
  let(:jh_tw_po_file_path) { File.join(tw_locale_path, 'gitlab.po') }

  before do
    Rake.application.rake_require('tasks/jh/gettext')

    FileUtils.rm_r(locale_path) if Dir.exist?(locale_path)
    FileUtils.mkdir_p(cn_locale_path)
    FileUtils.mkdir_p(en_locale_path)
    FileUtils.mkdir_p(tw_locale_path)
    FileUtils.touch(jh_en_po_file_path)
    FileUtils.touch(jh_tw_po_file_path)
    FileUtils.touch(jh_pot_file_path)
    FileUtils.touch(jh_cn_po_file_path)

    allow(Rails.root).to receive(:join).and_call_original
    # This mock will take effect in "#jh_locale_path" in the "jh/lib/tasks/jh/gettext.rake",
    # which is used to tell "regenerate" command the new jh_pot_file_path and jh_po_file_path
    allow(Rails.root).to receive(:join).with('jh/locale').and_return(locale_path)
    # This mock will take effect when "extractor" is instantiated in "jh/lib/tasks/jh/gettext.rake",
    # which used to tell "extractor" to parse the code in "tmp/jh/gettext_spec" instead of "jh" directory
    allow(Rails.root).to receive(:join).with('jh').and_return(locale_path)
  end

  after do
    FileUtils.rm_r(locale_path) if Dir.exist?(locale_path)
  end

  describe ':updated_check' do
    subject { run_rake_task('jh:gettext:updated_check') }

    let(:jh_pot_content) do
      <<~POT
        msgid "GitLab"
        msgstr ""
      POT
    end

    context 'when regenerate is success and jh regenerate has run before push' do
      before do
        allow_next_instance_of(Tooling::GettextExtractor) do |extractor|
          allow(extractor).to receive(:generate_pot).and_return(jh_pot_content)
        end

        run_rake_task('jh:gettext:regenerate')
      end

      it 'success' do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe ':compile' do
    before do
      Rake.application.rake_require('../jh/lib/tasks/gettext')

      FileUtils.rm_r(locale_path) if Dir.exist?(locale_path)
      FileUtils.mkdir_p(locale_path)

      allow(Rails.root).to receive(:join).with('locale').and_return(locale_path)
      allow_any_instance_of(Rake::Task).to receive(:clear_actions).and_return(nil)
    end

    let(:pot_file_path) { File.join(locale_path, 'gitlab.pot') }
    let(:compile_command) do
      [
        "node", "./jh/scripts/frontend/po_to_json.js",
        "--locale-root", Rails.root.join('locale').to_s,
        "--output-dir", Rails.root.join('app/assets/javascripts/locale').to_s
      ]
    end

    it 'creates a pot file and runs po-to-json conversion via node script' do
      expect(Kernel).to receive(:system).with(*compile_command).and_return(true)
      expect { run_rake_task('gettext:compile') }
        .to change { File.exist?(pot_file_path) }
        .to be_truthy
    end

    it 'aborts with non-successful po-to-json conversion via node script' do
      expect(Kernel).to receive(:system).with(*compile_command).and_return(false)
      expect { run_rake_task('gettext:compile') }.to abort_execution
    end
  end

  describe ':regenerate' do
    subject { run_rake_task('jh:gettext:regenerate') }

    context 'when generating pot files from code files' do
      let(:jh_pot_content) { File.read(jh_pot_file_path) }
      let(:files) do
        {
          rb_file: File.join(locale_path, 'app', 'ruby.rb'),
          haml_file: File.join(locale_path, 'app', 'template.haml'),
          erb_file: File.join(locale_path, 'app', 'template.erb')
        }
      end

      before do
        FileUtils.mkdir_p(File.join(locale_path, 'app'))
        # Disable parallelism in specs in order to suppress some confusing stack traces
        stub_env(
          'PARALLEL_PROCESSOR_COUNT' => 0
        )
        # Mock Backend files
        File.write(
          files[:rb_file],
          '[s_("JH|RB"), s_("JH|All"), n_("JH|Apple", "Apples", size), s_("JH|Context|A"), N_("JH|All2") ]'
        )
        File.write(
          files[:erb_file],
          '<h1><%= s_("JH|ERB") + s_("JH|All") + s_("JH|Context|B") + N_("JH|All2") %></h1>'
        )
        File.write(
          files[:haml_file],
          '%h1= s_("JH|HAML") + s_("JH|All") + s_("JH|Context|C") + N_("JH|All2")'
        )
        # Stub out Frontend file parsing
        status = {}
        allow(status).to receive(:success?).and_return(true)
        allow(Open3).to receive(:capture2)
          .with("node jh/scripts/frontend/extract_gettext_all.js --all")
          .and_return([
            '{"example.js": [ ["JH|JS"], ["JH|All"], ["JH|Mango\u0000Mangoes"], ["JH|Context|D"], ["JH|All2"] ] }',
            status
          ])

        subject
      end

      it 'produces pot without date headers' do
        expect(jh_pot_content).not_to include('POT-Creation-Date:')
        expect(jh_pot_content).not_to include('PO-Revision-Date:')
      end

      it 'produces pot file with all translated strings, sorted by msgid' do
        expect(jh_pot_content).to eql <<~POT_FILE
          # SOME DESCRIPTIVE TITLE.
          # Copyright (C) YEAR THE PACKAGE'S COPYRIGHT HOLDER
          # This file is distributed under the same license as the gitlab package.
          # FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
          #
          #, fuzzy
          msgid ""
          msgstr ""
          "Project-Id-Version: gitlab 1.0.0\\n"
          "Report-Msgid-Bugs-To: \\n"
          "Last-Translator: FULL NAME <EMAIL@ADDRESS>\\n"
          "Language-Team: LANGUAGE <LL@li.org>\\n"
          "Language: \\n"
          "MIME-Version: 1.0\\n"
          "Content-Type: text/plain; charset=UTF-8\\n"
          "Content-Transfer-Encoding: 8bit\\n"
          "Plural-Forms: nplurals=INTEGER; plural=EXPRESSION;\\n"

          msgid "JH|All"
          msgstr ""

          msgid "JH|All2"
          msgstr ""

          msgid "JH|Apple"
          msgid_plural "Apples"
          msgstr[0] ""
          msgstr[1] ""

          msgid "JH|Context|A"
          msgstr ""

          msgid "JH|Context|B"
          msgstr ""

          msgid "JH|Context|C"
          msgstr ""

          msgid "JH|Context|D"
          msgstr ""

          msgid "JH|ERB"
          msgstr ""

          msgid "JH|HAML"
          msgstr ""

          msgid "JH|JS"
          msgstr ""

          msgid "JH|Mango"
          msgid_plural "Mangoes"
          msgstr[0] ""
          msgstr[1] ""

          msgid "JH|RB"
          msgstr ""
        POT_FILE
      end
    end

    context 'when dealing with content associations between pot and po files' do
      let(:jh_pot_content) do
        <<~POT
          msgid "GitLab"
          msgstr ""
        POT
      end

      let(:jh_po_cn_content) do
        <<~PO
          msgid "GitLab"
          msgstr "极狐GitLab"
        PO
      end

      before do
        File.write(jh_pot_file_path, jh_pot_content)
        File.write(jh_cn_po_file_path, jh_po_cn_content)
        allow_next_instance_of(Tooling::GettextExtractor) do |extractor|
          allow(extractor).to receive(:generate_pot).and_return(jh_pot_content)
        end
      end

      context 'when msgids are matched' do
        it 'keeps the existing msgid' do
          subject

          expect(jh_cn_po_content).to include('极狐GitLab')
        end
      end

      context 'with a new added JH entry' do
        let(:jh_pot_content) do
          <<~POT
              msgid "GitLab"
              msgstr ""

              msgid "JH|New added entry"
              msgstr ""
          POT
        end

        it 'adds the new entry to po file' do
          subject

          expect(jh_cn_po_content).to include('极狐GitLab')
          expect(jh_cn_po_content).to include('JH|New added entry')
          expect(File.read(jh_en_po_file_path)).to include('JH|New added entry')
          expect(File.read(jh_tw_po_file_path)).to include('JH|New added entry')
        end
      end

      context 'with unattached JH entry' do
        let(:jh_po_cn_content) do
          <<~PO
            msgid "GitLab"
            msgstr "极狐GitLab"

            msgid "JH|Unattached entry"
            msgstr "一条在 pot 中不存在的文案"
          PO
        end

        it 'removes that entry' do
          subject

          expect(jh_cn_po_content).to include('极狐GitLab')
          expect(jh_cn_po_content).not_to include('JH|Unattached entry')
        end
      end

      context 'with unattached non-JH entry in JH pot' do
        let(:jh_pot_content) do
          <<~POT
            msgid "An non-JH entry not exists in Upstream pot"
            msgstr "一条非 JH 文案，在 Upstream pot 中也不存在"
          POT
        end

        it 'removes that entry' do
          expect { subject }
            .to(raise_error(
              RuntimeError, 'Msgid without "JH|" is found: An non-JH entry not exists in Upstream pot.'
            ))
        end
      end
    end
  end

  def jh_cn_po_content
    File.read(jh_cn_po_file_path)
  end
end
