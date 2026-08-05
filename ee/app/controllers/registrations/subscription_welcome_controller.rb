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

    layout :subscription_welcome_layout

    before_action :verify_onboarding_enabled!
    before_action :verify_welcome_needed!, only: :show
    before_action :verify_in_onboarding_flow!

    feature_category :onboarding

    def show
      return unless onboarding_status_presenter.unification_enabled?

      render GitlabSubscriptions::Subscriptions::Welcome::FormComponent.new(
        current_user,
        { step: Onboarding::SubscriptionNamespaceCreateService::FULL }
      )
    end

    def update
      if onboarding_status_presenter.unification_enabled?
        result = ::Onboarding::SubscriptionNamespaceCreateService.new(
          params: update_params, user: current_user, plan_id: plan_id_from_url,
          step: step_param, **namespace_params
        ).execute

        if result.success?
          actions_after_success(result.payload[:namespace])
          redirect_to redirect_path, notice: _('Group and project created successfully')
        elsif result.reason == ::Onboarding::SubscriptionNamespaceCreateService::NOT_FOUND
          render_404
        elsif result.reason == ::Onboarding::SubscriptionNamespaceCreateService::NAMESPACE_CREATE_FAILED
          render GitlabSubscriptions::Subscriptions::Welcome::FormComponent.new(
            current_user,
            resubmit_params(result, step: ::Onboarding::SubscriptionNamespaceCreateService::GROUP_FLOW)
          )
        elsif result.reason == ::Onboarding::SubscriptionNamespaceCreateService::PROJECT_CREATE_FAILED
          render GitlabSubscriptions::Subscriptions::Welcome::FormComponent.new(
            current_user,
            resubmit_params(result, step: ::Onboarding::SubscriptionNamespaceCreateService::PROJECT_FLOW)
          )
        else
          render GitlabSubscriptions::Subscriptions::Welcome::ResubmitComponent.new(
            hidden_fields: result.payload.merge(lead_params),
            submit_path: users_sign_up_welcome_path(
              step: Onboarding::SubscriptionNamespaceCreateService::LEAD_FLOW
            )
          ).with_content(result.message)
        end
      else
        result = ::Users::SubscriptionSignupService.new(current_user, params: update_params).execute

        if result.success?
          # needed for any new reads from the user like joining a project
          clear_memoization(:onboarding_status_presenter)
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
    end

    private

    def onboarding_status_presenter
      ::Onboarding::StatusPresenter.new({}, nil, current_user)
    end
    strong_memoize_attr :onboarding_status_presenter

    def subscription_welcome_layout
      onboarding_status_presenter.unification_enabled? ? 'registration_two_panel' : 'minimal'
    end

    def verify_welcome_needed!
      return unless ::Onboarding.completed_welcome_step?(current_user)

      redirect_to redirect_path
    end

    def update_params
      if onboarding_status_presenter.unification_enabled?
        params.permit(
          :first_name,
          :last_name,
          :company_name,
          :namespace_id,
          :group_name,
          :project_name
        ).with_defaults(organization_id: Current.organization.id)
      else
        params
          .require(:user)
          .permit(
            :onboarding_status_joining_project,
            :onboarding_status_role,
            :onboarding_status_setup_for_company,
            :onboarding_status_registration_objective
          )
      end
    end

    def actions_after_success(namespace)
      set_user_return_to(namespace)

      ::Onboarding::FinishService.new(current_user).execute
    end

    def set_user_return_to(namespace)
      uri = Gitlab::Utils.parse_url(session['user_return_to'])
      return unless uri

      query_params = uri.query_values || {}
      query_params['namespace_id'] = namespace.id
      uri.query = Rack::Utils.build_query(query_params)
      session['user_return_to'] = uri.to_s
    end

    def redirect_path
      if onboarding_status_presenter.unification_enabled?
        users_sign_up_customers_portal_redirect_path
      else
        stored_location_for(:user) || dashboard_projects_path
      end
    end

    def plan_id_from_url
      uri = Gitlab::Utils.parse_url(session['user_return_to'])
      uri&.query_values&.[]('plan_id')
    end

    def resubmit_params(result, step: nil)
      { namespace_id: result.payload[:namespace_id], project_id: result.payload[:project_id],
        step: step, errors: result.payload[:model_errors] }.merge(update_params).to_h.symbolize_keys
    end

    def step_param
      params.permit(:step)[:step]
    end

    def namespace_params
      params.permit(:namespace_id, :project_id).to_h.symbolize_keys
    end

    def lead_params
      params.permit(:first_name, :last_name, :company_name)
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
