# frozen_string_literal: true

module JH
  module Gitlab
    module ProjectTemplate
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      attr_writer :preview

      JH_PROJECT_TEMPLATE_GROUP = "#{::Gitlab.com_url}/gitlab-cn/project-templates".freeze

      class_methods do
        extend ::Gitlab::Utils::Override

        def localized_jh_templates_table
          [
            ::Gitlab::ProjectTemplate.new('dongtai_iast', 'DongTai IAST', s_('JH|A demo project showing how DongTai IAST integrates into DevOps for detecting vulnerabilities'), 'https://jihulab.com/gitlab-cn/project-templates/dongtai-iast', 'illustrations/jh/logos/dongtai.svg')
          ].freeze
        end

        def jh_archive_directory
          Rails.root.join("jh/vendor/project_templates")
        end

        override :localized_templates_table
        def localized_templates_table
          super.each(&:change_to_jh_preview)
        end

        override :localized_ee_templates_table
        def localized_ee_templates_table
          super.each(&:change_to_jh_preview)
        end

        override :all
        def all
          super + localized_jh_templates_table
        end
      end

      override :archive_path
      def archive_path
        if self.class.localized_jh_templates_table.include?(self)
          self.class.jh_archive_directory.join(archive_filename)
        else
          super
        end
      end

      def change_to_jh_preview
        project_name = preview.split('/').last
        jh_preview = File.join(JH_PROJECT_TEMPLATE_GROUP, project_name)
        self.preview = jh_preview
      end
    end
  end
end
