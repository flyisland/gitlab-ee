# frozen_string_literal: true

module Gitlab
  module Wecom
    # Reads and writes the `<CorpID>:<UserId>` extern_uid of a WeCom identity.
    #
    # OmniAuth::Strategies::Wecom writes the value (see its UID_SEPARATOR);
    # this is the reading side. A UserId is only unique within one corp, so the
    # CorpID must be checked before the UserId is used: after the instance
    # switches corps, an old binding has to stop working rather than deliver to
    # whoever shares that UserId in the new corp.
    module ExternUid
      SEPARATOR = ':'
      PROVIDER = 'wecom'

      class << self
        def encode(corp_id, user_id)
          return if blank?(corp_id) || blank?(user_id)

          "#{corp_id}#{SEPARATOR}#{user_id}"
        end

        # @return [Array(String, String), nil] [corp_id, user_id]
        def decode(extern_uid)
          return if blank?(extern_uid)

          corp_id, separator, user_id = extern_uid.to_s.partition(SEPARATOR)
          return if separator.empty? || corp_id.empty? || user_id.empty?

          [corp_id, user_id]
        end

        # Returns the UserId only when the CorpID still matches the configured
        # one; anything else is a stale binding.
        def user_id_for(extern_uid, corp_id)
          decoded = decode(extern_uid)
          return if decoded.nil?
          return if blank?(corp_id) || decoded.first != corp_id.to_s

          decoded.last
        end

        private

        def blank?(value)
          value.nil? || value.to_s.empty?
        end
      end
    end
  end
end
