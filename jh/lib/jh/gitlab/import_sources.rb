# frozen_string_literal: true

# Add this line to fix pipeline failure https://jihulab.com/gitlab-cn/gitlab/-/jobs/4404247 temporary
require Rails.root.join 'lib/gitlab/redis.rb'

module JH
  module Gitlab
    module ImportSources
      extend ::Gitlab::Utils::Override

      override :import_table
      def import_table
        super + jh_import_table
      end

      def jh_import_table
        [::Gitlab::ImportSources::ImportSource.new('gitee', 'Gitee', ::Gitlab::GiteeImport::Importer)]
      end
    end
  end
end
