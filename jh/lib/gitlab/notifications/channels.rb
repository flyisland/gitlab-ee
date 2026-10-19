# frozen_string_literal: true

module Gitlab
  module Notifications
    module Channels
      class << self
        def register(name, &channel)
          registrations[name] = channel
        end

        def each
          registrations.each do |name, resolver|
            channel = safely(name) { resolver.call }
            yield name, channel if channel
          end
        end

        def fetch(name)
          registered_name, resolver = registrations.find { |key, _| key.to_s == name.to_s }
          safely(registered_name) { resolver.call } if resolver
        end

        def available?
          registrations.any? { |name, resolver| safely(name) { resolver.call.available? } }
        end

        private

        def safely(name)
          yield
        rescue StandardError => e
          ::Gitlab::AppLogger.error(
            message: 'Could not resolve a notification channel', channel: name.to_s,
            Labkit::Fields::ERROR_TYPE => e.class.name
          )
          nil
        end

        def registrations
          @registrations ||= {}
        end
      end
    end
  end
end
