# frozen_string_literal: true

module Import
  class GiteeProviderRepoEntity < BaseProviderRepoEntity
    # rubocop:disable Style/SymbolProc
    # to avoid Grape::Entity::Deprecated with Ruby 3
    # https://jihulab.com/gitlab-cn/gitlab/-/pipelines/894445/failures
    expose :id, override: true do |repo|
      repo.full_name
    end

    expose :sanitized_name, override: true do |repo|
      repo.name
    end

    expose :provider_link, override: true do |repo|
      repo.clone_url
    end
    # rubocop:enable Style/SymbolProc
  end
end
