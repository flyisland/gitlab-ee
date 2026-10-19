# frozen_string_literal: true

module GitlabSubscriptions
  class ExpiredStorageNotice
    REMINDER_DAYS = [15, 7, 3].freeze

    attr_reader :namespace

    def initialize(namespace)
      @namespace = namespace
    end

    class << self
      def execute
        limits = NamespaceLimit.where('additional_purchased_storage_size > 0') # rubocop: disable CodeReuse/ActiveRecord -- query namespace buy storage addon before
        limits.each do |limit|
          namespace = limit.namespace
          next if namespace.blank?

          new(namespace).call
        end
      end
    end

    def call
      return unless feature_enabled?
      return unless storage_expiry_date_present?

      days_until_expiry = calculate_days_until_expiry
      return unless should_send_reminder?(days_until_expiry)

      send_expiry_notification(days_until_expiry)

    rescue StandardError => error
      Gitlab::ErrorTracking.track_exception(error, class: self.class.name, namespace_id: namespace.id)

      false
    end

    def feature_enabled?
      Feature.enabled?(:expired_storage_check, namespace)
    end

    def storage_expiry_date_present?
      storage_expiry_date.present?
    end

    def storage_expiry_date
      @storage_expiry_date ||= namespace.additional_purchased_storage_ends_on
    end

    def calculate_days_until_expiry
      return 0 unless storage_expiry_date

      (storage_expiry_date - Date.current).to_i
    end

    def should_send_reminder?(days_until_expiry)
      REMINDER_DAYS.include?(days_until_expiry)
    end

    def send_expiry_notification(days_until_expiry)
      namespace_owners = namespace.owners

      namespace.custom_attributes.create(key: "last_expired_storage_notice_sent_#{Time.now.to_i}", value: Time.now)

      namespace_owners.each do |owner|
        Notify.storage_expiry_notification(
          owner.id,
          namespace.id,
          days_until_expiry,
          storage_expiry_date
        ).deliver_now
      end
    end
  end
end
