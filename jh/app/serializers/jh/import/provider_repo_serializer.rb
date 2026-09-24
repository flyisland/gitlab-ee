# frozen_string_literal: true

module JH
  module Import
    module ProviderRepoSerializer
      extend ::Gitlab::Utils::Override

      override :represent
      def represent(repo, opts = {})
        entity =
          case opts[:provider]
          when :fogbugz
            ::Import::FogbugzProviderRepoEntity
          when :github, :gitea
            ::Import::GithubishProviderRepoEntity
          when :bitbucket
            ::Import::BitbucketProviderRepoEntity
          when :bitbucket_server
            ::Import::BitbucketServerProviderRepoEntity
          when :gitlab
            ::Import::GitlabProviderRepoEntity
          when :manifest
            ::Import::ManifestProviderRepoEntity
          when :gitee
            ::Import::GiteeProviderRepoEntity
          else
            raise NotImplementedError
          end
        BaseSerializer.instance_method(:represent).bind_call(self, repo, opts, entity)
      end
    end
  end
end
