# frozen_string_literal: true

module JH
  module DocUrlHelper
    extend ::Gitlab::Utils::Override

    override :version
    def version
      "13.4.0-jh"
    end

    override :doc_url
    def doc_url(documentation_base_url)
      doc_source = documentation_base_url&.end_with?('docs.gitlab.com') ? 'ee' : 'jh'
      "#{documentation_base_url}/13.4/#{doc_source}/#{path}.html"
    end

    override :doc_url_without_version
    def doc_url_without_version(documentation_base_url)
      doc_source = documentation_base_url&.end_with?('docs.gitlab.com') ? 'ee' : 'jh'
      "#{documentation_base_url}/#{doc_source}/#{path}.html"
    end

    override :stub_doc_file_read
    def stub_doc_file_read(content:, file_name: 'index.md')
      if File.exist?(Rails.root.join('jh/doc-en', file_name))
        expect_file_read(Rails.root.join('jh/doc-en', file_name), content: content)
      else
        super
      end
    end
  end
end
