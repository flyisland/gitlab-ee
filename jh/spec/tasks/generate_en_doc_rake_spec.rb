# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'gettext', :silence_stdout, feature_category: :pages do
  let(:jh_en_doc_path) { Rails.root.join('jh/doc-en') }
  let(:doc_path) { Rails.root.join('doc') }
  let(:jh_doc_scan_rules_path) { Rails.root.join('jh/config/doc_scan_rules.yml') }
  let(:tmp_dir_path) { Rails.root.join('doc/tmp') }
  let(:tmp_md_file_path) { Rails.root.join('doc/tmp/tmp.md') }
  let(:tmp_img_file_path) { Rails.root.join('doc/tmp/tmp.jpg') }
  let(:jh_tmp_dir_path) { Rails.root.join('jh/doc-en/tmp') }
  let(:jh_tmp_file_path) { Rails.root.join('jh/doc-en/tmp/tmp.md') }
  let(:excluded_file_path) { Rails.root.join('doc/tmp/excluded_file.md') }
  let(:jh_excluded_file_path) { Rails.root.join('jh/doc/tmp/excluded_file.md') }

  let(:mock_file_paths) do
    [tmp_dir_path,
      tmp_img_file_path,
      tmp_md_file_path,
      excluded_file_path]
  end

  let(:mock_rules) do
    { "delete_rules" =>
      [%r{\(https://gitlab\.com/gitlab-org/gitlab/-/issues/[0-9]*\)},
        %r{\(https://gitlab\.com/gitlab-org/gitlab/-/merge_requests/[0-9]*\)},
        %r{\(https://en\.wikipedia\.org/wiki/[\w#=-?.&]*\)},
        %r{\(https://www\.youtube\.com/([\w#=-?.&]*)\)},
        %r{\(https://youtu\.be/[\w#=-?.&]*\)}],
      "replace_rules" =>
      [{ "from" => "https://gitlab.com/gitlab-org/", "to" => "https://jihulab.com/gitlab-cn/" },
        { "from" => "https://docs.gitlab.com/omnibus", "to" => "https://docs.gitlab.cn/omnibus" },
        { "from" => "https://docs.gitlab.com/runner", "to" => "https://docs.gitlab.cn/runner" },
        { "from" => "https://docs.gitlab.com/charts", "to" => "https://docs.gitlab.cn/charts" },
        { "from" => "registry.gitlab.com/", "to" => "registry.gitlab.cn/" },
        { "from" => "https://about.gitlab.com/install", "to" => "https://gitlab.cn/install" },
        { "from" => "gitlab/gitlab-ee:latest", "to" => "registry.gitlab.cn/omnibus/gitlab-jh:latest" }],
      "excluded_files" =>
        [excluded_file_path] }
  end

  before do
    Rake.application.rake_require('tasks/jh/generate_en_doc')
    FileUtils.rm_r(jh_en_doc_path) if Dir.exist?(jh_en_doc_path)

    FileUtils.mkdir_p(jh_en_doc_path)
    FileUtils.mkdir_p(tmp_dir_path)
    FileUtils.touch(tmp_md_file_path)
    FileUtils.touch(tmp_img_file_path)
    FileUtils.touch(excluded_file_path)

    allow(Find).to receive(:find).with(doc_path).and_return(mock_file_paths.each)
    allow(YAML).to receive(:load_file).with(jh_doc_scan_rules_path).and_return(mock_rules)
  end

  after do
    FileUtils.rm_r(jh_en_doc_path) if Dir.exist?(jh_en_doc_path)
    FileUtils.rm_r(tmp_dir_path) if Dir.exist?(tmp_dir_path)
  end

  describe ':generate_en_doc' do
    subject { run_rake_task('jh:doc:generate_en_doc') }

    describe 'with delete rules exist' do
      context 'when file content match rules' do
        let(:file_content) do
          <<~PO
          - API [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/332747) in GitLab 14.5 [with a flag](../administration/feature_flags.md)#{' '}
          named `ff_external_audit_events_namespace`. Disabled by default.
          - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/1283) in [GitLab Premium](https://about.gitlab.com/pricing/) 9.0.
          Now create a `.gitlab-ci.yml` file. It is a [YAML](https://en.wikipedia.org/wiki/YAML) file where
          you specify instructions for GitLab CI/CD.
          The name and hierarchy of repositories, as well as image manifests and tags are also stored in the storage backend, represented by a nested structure of folders and files.#{' '}
          [This video](https://www.youtube.com/watch?v=i5mbF2bgWoM&feature=youtu.be) gives a practical overview of the registry storage structure.
          Watch the [video tutorial](https://youtu.be/dD8c7WNcc6s) for this configuration.
          PO
        end

        before do
          File.write(tmp_md_file_path, file_content, mode: "w")
        end

        after do
          FileUtils.rm_r(jh_tmp_file_path)
        end

        it 'delete success' do
          subject
          expect(jh_tmp_file_content.include?("(https://gitlab.com/gitlab-org/gitlab/-/issues/332747)")).to be false
          expect(jh_tmp_file_content.include?("(https://gitlab.com/gitlab-org/gitlab/" \
            "-/merge_requests/1283)")).to be false
          expect(jh_tmp_file_content.include?("(https://en.wikipedia.org/wiki/YAML)")).to be false
          expect(jh_tmp_file_content.include?("(https://www.youtube.com/watch" \
            "?v=i5mbF2bgWoM&feature=youtu.be)")).to be false
          expect(jh_tmp_file_content.include?("(https://youtu.be/dD8c7WNcc6s)")).to be false
        end
      end

      context 'when file content do not match rules' do
        let(:file_content) do
          <<~PO
          - API [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/332747aaa) in GitLab 14.5 [with a flag](../administration/feature_flags.md)#{' '}
          named `ff_external_audit_events_namespace`. Disabled by default.
          - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/1283aaa) in [GitLab Premium](https://about.gitlab.com/pricing/) 9.0.
          Now create a `.gitlab-ci.yml` file. It is a [YAML](https://en.wikipedia.org/wiki/YAML@~) file where
          you specify instructions for GitLab CI/CD.
          The name and hierarchy of repositories, as well as image manifests and tags are also stored in the storage backend, represented by a nested structure of folders and files.#{' '}
          [This video](https://www.youtube.com/watch?v=i5mbF2&feature.yoube@~) gives a practical overview of the registry storage structure.
          Watch the [video tutorial](https://youtu.be/dD8c7WNcc6s@) for this configuration.
          PO
        end

        before do
          File.write(tmp_md_file_path, file_content, mode: "w")
        end

        after do
          FileUtils.rm_r(jh_tmp_file_path)
        end

        it 'delete failed' do
          subject
          expect(jh_tmp_file_content.include?("(https://jihulab.com/gitlab-cn/gitlab/-/issues/332747aaa)")).to be true
          expect(jh_tmp_file_content.include?("(https://jihulab.com/gitlab-cn/" \
            "gitlab/-/merge_requests/1283aaa)")).to be true
          expect(jh_tmp_file_content.include?("(https://en.wikipedia.org/wiki/YAML@~)")).to be true
          expect(jh_tmp_file_content.include?("(https://www.youtube.com/watch?v=i5mbF2&feature.yoube@~)")).to be true
          expect(jh_tmp_file_content.include?("(https://youtu.be/dD8c7WNcc6s@)")).to be true
        end
      end
    end

    describe 'with replace rules exist' do
      context 'when file content match rules' do
        let(:file_content) do
          <<~PO
          You can create shortcut links to create an issue using a designated template.
          For example: `https://gitlab.com/gitlab-org/gitlab/-/issues/new?issuable_template=Feature%20proposal`. Read more about [creating issues using a URL with prefilled values](issues/managing_issues.md#using-a-url-with-prefilled-values).

          - Review the [Omnibus backup and restore documentation](https://docs.gitlab.com/omnibus/settings/backups).#{'    '}

          When using GitLab CI over a TLS v1.3 configured GitLab server, you must
          [upgrade to GitLab Runner](https://docs.gitlab.com/runner/install/index.html) 13.2.0#{'   '}

          to follow the [secrets guide for adding the secret](https://docs.gitlab.com/charts/installation/secrets.html#gitlab-rails-secret).

          Starting in GitLab 14.8, new versions of GitLab Secure and Protect analyzers are published to#{' '}
          a new registry location under `registry.gitlab.com/security-products`.
          gitlab_docs:
          image: registry.gitlab.com/gitlab-org/gitlab-docs:14.5
          hostname: 'https://docs.gitlab.example.com:4000'
          ports:
            - '4000:4000'

            1. Follow the instructions to [install](https://about.gitlab.com/install/)
            GitLab by choosing your preferred platform, but do not supply the

              web:
                image: 'gitlab/gitlab-ee:latest'
                restart: always

          PO
        end

        before do
          File.write(tmp_md_file_path, file_content, mode: "w")
        end

        after do
          FileUtils.rm_r(jh_tmp_file_path)
        end

        it 'replace success' do
          subject
          expect(jh_tmp_file_content.include?("https://jihulab.com/gitlab-cn/")).to be true
          expect(jh_tmp_file_content.include?("https://docs.gitlab.cn/omnibus")).to be true
          expect(jh_tmp_file_content.include?("https://docs.gitlab.cn/runner")).to be true
          expect(jh_tmp_file_content.include?("https://docs.gitlab.cn/charts")).to be true
          expect(jh_tmp_file_content.include?("registry.gitlab.cn/")).to be true
          expect(jh_tmp_file_content.include?("https://gitlab.cn/install")).to be true
          expect(jh_tmp_file_content.include?("registry.gitlab.cn/omnibus/gitlab-jh:latest")).to be true
        end
      end

      context 'when file content do not match rules' do
        let(:file_content) do
          <<~PO
          You can create shortcut links to create an issue using a designated template.
          For example: `https://gitlabaaa.com/gitlab-org/gitlab/-/issues/new?issuable_template=Feature%20proposal`. Read more about [creating issues using a URL with prefilled values](issues/managing_issues.md#using-a-url-with-prefilled-values).

          - Review the [Omnibus backup and restore documentation](https://docs.gitlabaaa.com/omnibus/settings/backups).#{'    '}

          When using GitLab CI over a TLS v1.3 configured GitLab server, you must
          [upgrade to GitLab Runner](https://docs.gitlabaaa.com/runner/install/index.html) 13.2.0#{'   '}

          to follow the [secrets guide for adding the secret](https://docs.gitlabaaa.com/charts/installation/secrets.html#gitlab-rails-secret).

          Starting in GitLab 14.8, new versions of GitLab Secure and Protect analyzers are published to#{' '}
          a new registry location under `registry.gitlabaaa.com/security-products`.
          gitlab_docs:
          image: registry.gitlab.com/gitlab-org/gitlab-docs:14.5
          hostname: 'https://docs.gitlabaaa.example.com:4000'
          ports:
            - '4000:4000'

            1. Follow the instructions to [install](https://about.gitlabaaa.com/install/)
            GitLab by choosing your preferred platform, but do not supply the

              web:
                image: 'gitlabaaa/gitlab-ee:latest'
                restart: always

          PO
        end

        before do
          File.write(tmp_md_file_path, file_content, mode: "w")
        end

        after do
          FileUtils.rm_r(jh_tmp_file_path)
        end

        it 'replace failed' do
          subject
          expect(jh_tmp_file_content.include?("https://jihulab.com/gitlab-cn/")).to be false
          expect(jh_tmp_file_content.include?("https://docs.gitlab.cn/omnibus")).to be false
          expect(jh_tmp_file_content.include?("https://docs.gitlab.cn/runner")).to be false
          expect(jh_tmp_file_content.include?("https://docs.gitlab.cn/charts")).to be false
          expect(jh_tmp_file_content.include?("registry.gitlab.cn/ ")).to be false
          expect(jh_tmp_file_content.include?("https://gitlab.cn/install")).to be false
          expect(jh_tmp_file_content.include?("registry.gitlab.cn/omnibus/gitlab-jh:latest")).to be false
        end
      end
    end

    describe 'with excluded files exists' do
      context 'when scan file in excluded files' do
        it 'do not scan file' do
          subject
          expect(File.exist?(jh_excluded_file_path)).to be false
        end
      end

      context 'when scan file do not in excluded files' do
        it 'scan file' do
          subject
          expect(File.exist?(jh_tmp_file_path)).to be true
        end
      end
    end
  end

  def jh_tmp_file_content
    File.read(jh_tmp_file_path)
  end
end
