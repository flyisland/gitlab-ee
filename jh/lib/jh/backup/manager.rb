# frozen_string_literal: true

module JH
  module Backup
    module Manager
      extend ::Gitlab::Utils::Override

      override :backup_file?
      def backup_file?(file)
        file.match(/^(\d{10})(?:_\d{4}_\d{2}_\d{2}(_\d+\.\d+\.\d+((-|\.)(pre|rc\d))?(-ee|-jh)?)?)?_gitlab_backup\.tar$/)
      end
    end
  end
end
