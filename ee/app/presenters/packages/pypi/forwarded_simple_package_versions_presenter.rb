# frozen_string_literal: true

module Packages
  module Pypi
    # EE-only: HTML Simple page for forwarded packages. Reuses the CE base's body,
    # link, and escaping, overriding only the file source (upstream PEP 691 files)
    # and the rewritten file URL.
    class ForwardedSimplePackageVersionsPresenter < ::Packages::Pypi::SimplePackageVersionsPresenter
      include ::Packages::Pypi::ForwardedSimplePresenterMethods

      def initialize(package_name:, files:, project:, allowed_hosts:)
        super(::Packages::Pypi::Package.none, project)

        @package_name = package_name
        @upstream_files = files
        @allowed_hosts = allowed_hosts
      end

      private

      def links
        usable_files.map do |file|
          package_link(escape(forwarded_file_url(file)), file[:requires_python], escape(file[:filename]))
        end.join
      end
    end
  end
end
