# frozen_string_literal: true

module JH
  module ReleaseHighlight
    extend ActiveSupport::Concern

    TIER_MAP = {
      "Free" => "免费版",
      "Team" => "团队版",
      "Premium" => "专业版",
      "Ultimate" => "旗舰版"
    }.freeze

    TEAM_PACKAGE = 'Team'

    class_methods do
      extend ::Gitlab::Utils::Override

      override :whats_new_path
      def whats_new_path
        Rails.root.join('jh/data/whats_new/*.yml')
      end

      override :load_items
      def load_items(page:)
        index = page - 1
        file_path = file_paths[index]

        return if file_path.nil?

        file = File.read(file_path)
        items = YAML.safe_load(file, permitted_classes: [Date])

        items&.map! do |item|
          next unless include_item?(item)

          begin
            item.tap do |i|
              i['description'] = ::Banzai.render(i['description'], { project: nil })
              i.delete 'image_url'
              i['available_in'].map! { |tier| TIER_MAP[tier] || tier }
            end
          rescue StandardError => e
            ::Gitlab::ErrorTracking.track_exception(e, file_path: file_path)

            next
          end
        end

        items&.compact
      rescue Psych::Exception => e
        ::Gitlab::ErrorTracking.track_exception(e, file_path: file_path)
        []
      end

      override :current_package
      def current_package
        return TEAM_PACKAGE if ::License.current&.plan&.downcase == ::License::TEAM_PLAN

        super
      end
    end
  end
end
