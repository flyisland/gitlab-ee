# frozen_string_literal: true

module Gitlab
  module Dingtalk
    # A button click on a Duo card, as DingTalk posts it to the callback that
    # the gitlab:dingtalk:register_card_callback task registers.
    class CardCallback
      AuthenticationError = Class.new(StandardError)

      ROUTE_KEY = 'gitlab-duo-approval'
      PATH = '/api/v4/integrations/dingtalk/card_callback'
      ACTION_TYPE = 'actionCallback'
      # DingTalk signs the timestamp alone, so the window is what bounds a replay.
      TIMESTAMP_WINDOW = 5.minutes
      CONTENT_MAX_SIZE = 16.kilobytes

      def self.default_url
        "#{Gitlab.config.gitlab.url}#{PATH}"
      end

      # The instance's DingTalk integration for corp_id, when it is on and has a
      # secret to sign clicks with.
      #
      # @param corp_id [String]
      # @return [Integrations::Dingtalk, nil]
      def self.integration_for(corp_id)
        return if corp_id.blank?

        integration = ::Integrations::Dingtalk.find_by_corpid(corp_id)
        integration if integration&.activated? && integration.card_callback_secret.present?
      end

      # @param params [Hash] the request body
      # @param headers [Hash] the request headers
      def initialize(params, headers)
        @params = params
        @headers = headers.to_h.transform_keys { |key| key.to_s.downcase }
      end

      # @raise [AuthenticationError] unless the corp's secret signed a fresh timestamp
      # @return [self]
      def verify!
        secret = self.class.integration_for(corp_id)&.card_callback_secret
        raise AuthenticationError, 'No card callback secret for this corp' if secret.blank?

        timestamp = headers['x-ddpaas-signature-timestamp'].to_s
        raise AuthenticationError, 'Malformed timestamp' unless timestamp.match?(/\A\d{13}\z/)

        age = (Time.current.to_f - (timestamp.to_i / 1000.0)).abs
        raise AuthenticationError, 'Stale timestamp' if age > TIMESTAMP_WINDOW

        expected = Base64.strict_encode64(OpenSSL::HMAC.digest('SHA256', secret, timestamp))
        signature = headers['x-ddpaas-signature'].to_s
        unless ActiveSupport::SecurityUtils.secure_compare(expected, signature)
          raise AuthenticationError, 'Invalid signature'
        end

        # The signature covers no body, so a leaked one would sign any click
        # until the window closes; DingTalk sends each click once.
        raise AuthenticationError, 'Replayed signature' unless claim_signature(signature)

        self
      end

      def action?
        params[:type] == ACTION_TYPE
      end

      def corp_id
        params[:corpId].to_s
      end

      # The staff id of whoever clicked.
      def user_id
        params[:userId].to_s
      end

      def out_track_id
        params[:outTrackId].to_s
      end

      # What the clicked button sends, as the template binds it.
      #
      # @return [Hash] empty when the body carries nothing readable
      def action_params
        content = params[:content]
        return {} unless content.is_a?(String) && content.bytesize <= CONTENT_MAX_SIZE

        parsed = ::Gitlab::Json::SafeParser.parse(content)
        values = parsed.dig('cardPrivateData', 'params') if parsed.is_a?(Hash)
        values.is_a?(Hash) ? values : {}
      rescue JSON::ParserError, TypeError # TypeError: dig through a non-Hash
        {}
      end

      private

      attr_reader :params, :headers

      def claim_signature(signature)
        ::Gitlab::Redis::SharedState.with do |redis|
          redis.set("dingtalk:card_callback:signature:#{signature}", 1, nx: true, ex: TIMESTAMP_WINDOW.to_i)
        end
      end
    end
  end
end
