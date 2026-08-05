# frozen_string_literal: true

module Packages
  module Pypi
    # EE-only: shared behaviour for the forwarded (proxied) PyPI Simple-page
    # presenters. Consumes the upstream PEP 691 `files` array (not local package
    # records) and rewrites each file URL back to GitLab's own file endpoint so the
    # follow-up download is firewall-checked. Files from a disallowed host, without a
    # sha256, or whose version can't be derived are dropped; core-metadata
    # (PEP 658/714) is not emitted. Including classes provide the readers below.
    module ForwardedSimplePresenterMethods
      EXTENSION_REGEX = /\.(?:tar\.(?:gz|bz2|xz|z)|tgz|zip|whl|egg)\z/i

      private

      attr_reader :package_name, :upstream_files, :allowed_hosts, :project_or_group

      def usable_files
        upstream_files.filter_map do |file|
          next unless file.is_a?(Hash) && file['hashes'].is_a?(Hash)

          sha256 = file.dig('hashes', 'sha256')
          next if sha256.blank?
          next unless allowed_upstream_file_url?(file['url'])

          version = extract_version(file['filename'])
          next if version.blank?

          {
            filename: file['filename'],
            sha256: sha256,
            version: version,
            requires_python: file['requires-python'],
            upstream_url: file['url']
          }
        end
      end

      # Rewrites back to GitLab's file endpoint through the shared route helper so
      # relative_url_root is preserved, carrying the coordinates the firewall needs at
      # download time as query params (and the sha256 as the PEP 503 fragment). sha256
      # and filename come from the untrusted upstream index and land in route segments
      # the helper does not escape, so url-encode them (real values are unaffected).
      def forwarded_file_url(file)
        encoded_sha256 = ERB::Util.url_encode(file[:sha256])
        path = api_v4_projects_packages_pypi_files_file_identifier_path(
          {
            id: project_or_group.id,
            sha256: encoded_sha256,
            file_identifier: ERB::Util.url_encode(file[:filename])
          },
          true
        )
        query = { package_name: package_name, version: file[:version], upstream_url: file[:upstream_url] }.to_query

        "#{expose_url(path)}?#{query}#sha256=#{encoded_sha256}"
      end

      # PyPI file names are "<dist>-<version>[-...]" where <dist> normalizes to the
      # package name. Strip the known (normalized) name prefix rather than splitting
      # on the first "-", so hyphenated names like django-allauth-0.1.tar.gz resolve
      # to "0.1" and not "allauth".
      def extract_version(filename)
        base = filename.to_s
        return unless base.match?(EXTENSION_REGEX)

        base = base.sub(EXTENSION_REGEX, '')
        normalized = ::Sbom::PackageUrl::Normalizer.new(type: 'pypi', text: package_name).normalize_name
        name_pattern = normalized.split('-').map { |segment| Regexp.escape(segment) }.join('[-_.]+')
        match = base.match(/\A#{name_pattern}[-_.]+(.+)\z/i)
        return unless match

        match[1].split('-').first.presence
      end

      def allowed_upstream_file_url?(url)
        uri = URI.parse(url.to_s)
        uri.scheme == 'https' && allowed_hosts.include?(uri.host&.downcase)
      rescue URI::InvalidURIError
        false
      end

      def body_name
        package_name
      end
    end
  end
end
