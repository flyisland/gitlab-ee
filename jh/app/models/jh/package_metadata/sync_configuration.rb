# frozen_string_literal: true

module JH
  module PackageMetadata
    module SyncConfiguration
      module Location
        ALIYUN_LICENSES_BUCKET = ENV.fetch('ALIYUN_PACKAGE_METADATA_LICENSES_BUCKET',
          'aliyun-package-metadata-licenses-bucket')
        ALIYUN_ADVISORIES_BUCKET = ENV.fetch('ALIYUN_PACKAGE_METADATA_ADVISORIES_BUCKET',
          'aliyun-package-metadata-advisories-bucket')

        module ClassMethods
          extend ::Gitlab::Utils::Override

          override :for_licenses
          def for_licenses
            storage_type, _ = super
            return super unless should_replace?(storage_type)

            [:aliyun, ALIYUN_LICENSES_BUCKET]
          end

          override :for_advisories
          def for_advisories
            storage_type, _ = super
            return super unless should_replace?(storage_type)

            [:aliyun, ALIYUN_ADVISORIES_BUCKET]
          end

          def should_replace?(storage_type)
            storage_type == :gcp
          end
        end

        def self.prepended(base)
          # prepend class method should use this pattern
          base.singleton_class.prepend(ClassMethods)
        end
      end
    end
  end
end
