# frozen_string_literal: true

module Packages
  module Pypi
    # EE-only: PEP 691 JSON Simple page for forwarded packages. Reuses the CE JSON
    # body, overriding only the file source (upstream PEP 691 files) and the
    # rewritten file URL.
    class ForwardedSimplePackageVersionsJsonPresenter < ::Packages::Pypi::SimplePackageVersionsJsonPresenter
      include ::Packages::Pypi::ForwardedSimplePresenterMethods

      def initialize(package_name:, files:, project:, allowed_hosts:)
        super(::Packages::Pypi::Package.none, project, package_name: package_name)

        @upstream_files = files
        @allowed_hosts = allowed_hosts
      end

      private

      def files
        usable_files.map do |file|
          entry = {
            'filename' => file[:filename],
            'url' => forwarded_file_url(file),
            'hashes' => { 'sha256' => file[:sha256] }
          }
          entry['requires-python'] = file[:requires_python] if file[:requires_python].present?
          entry
        end
      end
    end
  end
end
