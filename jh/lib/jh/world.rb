# frozen_string_literal: true

module JH
  module World
    extend ActiveSupport::Concern

    class_methods do
      extend ::Gitlab::Utils::Override
      include ::Gitlab::Utils::StrongMemoize

      override :supported_countries
      def supported_countries
        ISO3166::Country.all.reject { |item| ::World::COUNTRY_DENYLIST.include?(item.alpha2) }
      end
      strong_memoize_attr :supported_countries

      def jh_trial_countries_for_select
        supported_countries.select { |country| country.alpha2 == 'CN' }
          .sort_by(&:name).map { |c| [c.name, c.alpha2, c.emoji_flag, c.country_code] }
      end

      override :states_for_country
      def states_for_country(country_code)
        return super unless ::Gitlab.com? && ::Gitlab.jh? && country_code.casecmp?('cn')

        strong_memoize("states_for_country_#{country_code}") do
          country = ISO3166::Country.find_country_by_alpha2(country_code)
          next unless country

          Hash[country.subdivision_names_with_codes('zh')]
        end
      end
    end
  end
end
