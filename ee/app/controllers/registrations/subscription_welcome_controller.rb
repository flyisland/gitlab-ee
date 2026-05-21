# frozen_string_literal: true

module Registrations
  class SubscriptionWelcomeController < ApplicationController
    include OneTrustCSP
    include GoogleAnalyticsCSP
    include GoogleSyndicationCSP
    include ::Gitlab::Utils::StrongMemoize
    include ::Onboarding::Redirectable
    include ::Onboarding::SetRedirect
    include ::Onboarding::InProgress

    layout 'minimal'

    before_action :verify_onboarding_enabled!
    before_action :verify_welcome_needed!, only: :show
    before_action :verify_in_onboarding_flow!

    feature_category :onboarding

    def show; end

    def update
      result = ::Users::SubscriptionSignupService.new(current_user, params: update_params).execute

      if result.success?
        clear_memoization(:onboarding_status_presenter) # needed for any new reads from the user like joining a project
        track_event('successfully_submitted_form')
        track_joining_a_project_event

        redirect_to redirect_path
      else
        track_event(
          "track_#{::Onboarding::SubscriptionRegistration.tracking_label}_error", label: 'failed_submitting_form'
        )

        render :show
      end
    end

    private

    def verify_welcome_needed!
      return unless ::Onboarding.completed_welcome_step?(current_user)

      redirect_to redirect_path
    end

    def update_params
      params
        .require(:user)
        .permit(
          :onboarding_status_joining_project,
          :onboarding_status_role,
          :onboarding_status_setup_for_company,
          :onboarding_status_registration_objective
        )
    end

    def redirect_path
      stored_location_for(:user) || dashboard_projects_path
    end

    def track_joining_a_project_event
      onboarding_status_presenter = Onboarding::StatusPresenter.new(onboarding_status_params, nil, current_user)

      return unless onboarding_status_presenter.joining_a_project?

      cookies[:signup_with_joining_a_project] = { value: true, expires: 30.days }

      track_event('select_button', label: 'join_a_project')
    end

    def track_event(action, label: Onboarding::SubscriptionRegistration.tracking_label)
      ::Gitlab::Tracking.event(
        helpers.body_data_page,
        action,
        user: current_user,
        label: label
      )
    end

    def onboarding_status_params
      params
        .require(:user)
        .permit(:onboarding_status_setup_for_company).merge(params.permit(:joining_project)).to_h.deep_symbolize_keys
    end
  end
end
