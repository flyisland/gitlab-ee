# frozen_string_literal: true

module JH
  module CountriesController
    extend ::Gitlab::Utils::Override

    protected

    override :index
    def index
      return super unless ::Gitlab.com? && ::Gitlab.jh?

      return super unless ::Feature.enabled?(:jh_filter_countries)

      referer = request.referer.to_s

      return super unless referer.include?('trials/new')

      countries = ::World.jh_trial_countries_for_select

      render json: countries, status: (countries ? :ok : :not_found)
    end
  end
end
