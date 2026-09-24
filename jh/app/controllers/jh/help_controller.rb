# frozen_string_literal: true

module JH
  module HelpController
    extend ::Gitlab::Utils::Override

    ORIGINAL_EN_DOC_BASE_URL_REGEXP = %r{https?://docs.gitlab.com}

    override :documentation_file_path
    def documentation_file_path
      return super if ORIGINAL_EN_DOC_BASE_URL_REGEXP.match? documentation_base_url

      path = if @path.nil? || @path.empty?
               ''
             elsif @path.end_with?('_index')
               base_path = @path.chomp('_index').chomp('/')
               "#{base_path}/index"
             else
               @path
             end

      @documentation_file_path ||= [version_segment, 'jh', "#{path}.html"].compact.join('/')
    end

    override :path_to_doc
    def path_to_doc(file_name)
      if current_user && current_user.preferred_language != 'zh_CN'
        jh_en_doc_path = Rails.root.join("jh/doc-en", file_name).to_s

        return File.exist?(jh_en_doc_path) ? jh_en_doc_path : super
      end

      jh_doc_path = Rails.root.join("jh/doc", file_name).to_s

      File.exist?(jh_doc_path) ? jh_doc_path : super
    end
  end
end
