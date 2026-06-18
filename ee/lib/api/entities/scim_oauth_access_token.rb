# frozen_string_literal: true

module API
  module Entities
    class ScimOauthAccessToken < ScimAccessTokenBase
      expose :organization_id, documentation: { type: 'Integer', example: 1 }
    end
  end
end
