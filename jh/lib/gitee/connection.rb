# frozen_string_literal: true

module Gitee
  class Connection
    DEFAULT_API_VERSION = '/api/v5/'
    DEFAULT_BASE_URI    = 'https://gitee.com/'

    attr_reader :api_version, :base_uri, :default_query, :token

    def initialize(options = {})
      @api_version   = options.fetch(:api_version, DEFAULT_API_VERSION)
      @base_uri      = options.fetch(:base_uri, DEFAULT_BASE_URI)
      @token         = options.delete(:gitee_access_token)
      @default_query = { access_token: @token }
    end

    def get(path, extra_query = {})
      ::Gitlab::HTTP.get(build_url(path), query: @default_query.merge(extra_query))
    end

    private

    def build_url(path)
      return path if path.starts_with?(root_url)

      Gitlab::Utils.append_path(root_url, path)
    end

    def root_url
      @root_url ||= Gitlab::Utils.append_path(@base_uri, @api_version)
    end
  end
end
