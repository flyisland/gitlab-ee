# frozen_string_literal: true

module Gitlab
  module Feishu
    # Feishu cards cannot load image URLs, only images uploaded by the same app, so the GitLab icon
    # is uploaded once per app and its key cached. Without a key the card is sent without an icon.
    module NotificationIcon
      # Feishu renders header icons at a fixed small size, so this tanuki has a transparent background and no padding.
      FILE_PATH = Rails.root.join('jh/public/feishu-notification-icon.png')
      CACHE_TTL = 7.days
      # Avoids an upload attempt per notification while the app lacks the image permission.
      FAILURE_TTL = 10.minutes

      class << self
        def image_key(app: App)
          key = cache_key(app)
          cached = Rails.cache.read(key)
          return cached.presence unless cached.nil?

          image_key = upload(app)
          Rails.cache.write(key, image_key.to_s, expires_in: image_key ? CACHE_TTL : FAILURE_TTL)
          image_key
        end

        private

        def upload(app)
          data = AppClient.new(app: app).upload_image(FILE_PATH)['data']
          image_key = data['image_key'] if data.is_a?(Hash)
          image_key if image_key.is_a?(String) && image_key.present?
        rescue AppResponse::Error => e
          ::Gitlab::AppLogger.warn(
            message: 'Could not upload the Feishu notification icon',
            Labkit::Fields::ERROR_TYPE => e.class.name,
            Labkit::Fields::ERROR_MESSAGE => e.message
          )
          nil
        end

        def cache_key(app)
          fingerprint = ::Gitlab::CryptoHelper.sha256(
            ::Gitlab::Json.generate([app.api_site, app.app_id, file_digest])
          )
          "integration:feishu:#{fingerprint}:notification_icon"
        end

        def file_digest
          @file_digest ||= Digest::SHA256.file(FILE_PATH).hexdigest
        end
      end
    end
  end
end
