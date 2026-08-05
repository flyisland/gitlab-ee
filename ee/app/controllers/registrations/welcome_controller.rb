# frozen_string_literal: true

module Registrations
  class WelcomeController < ApplicationController
    include OneTrustCSP
    include GoogleAnalyticsCSP
    include GoogleSyndicationCSP
    include ::Gitlab::Utils::StrongMemoize
    include ::Onboarding::Redirectable
    include ::Onboarding::SetRedirect
    include ::Onboarding::InProgress

    layout :welcome_layout

    before_action :verify_onboarding_enabled!
    before_action only: :show do
      set_onboarding_status_params
      verify_welcome_needed!
    end

    before_action :verify_in_onboarding_flow!, unless: :skip_verify_in_onboarding_flow?
    before_action :set_update_onboarding_status_params, only: :update

    helper_method :onboarding_status_presenter

    feature_category :onboarding

    def show
      return unless onboarding_status_presenter.unification_enabled?

      render ::Registrations::Welcome::FormComponent.new(
        current_user,
        params.permit(:step).merge(step: ::Onboarding::FreeNamespaceCreateService::FULL)
      )
    end

    def update
      return update_unified if ::Onboarding::FreeRegistration.unification_enabled?

      result = ::Users::SignupService
                 .new(current_user, user_return_to: session['user_return_to'], params: update_params).execute

      if result.success?
        clear_memoization(:onboarding_status_presenter) # needed in case registration_type is changed on update
        track_event('successfully_submitted_form')
        track_joining_a_project_event

        redirect_to update_success_path
      else
        track_event("track_#{onboarding_status_presenter.tracking_label}_error", label: 'failed_submitting_form')

        render :show
      end
    end

    private

    def update_unified
      result = ::Onboarding::FreeNamespaceCreateService.new(
        user: current_user,
        params: unified_form_params,
        step: step_param,
        **namespace_params
      ).execute

      if result.success?
        track_event('successfully_submitted_form')

        if onboarding_status_presenter.continue_full_onboarding?
          redirect_to unified_success_path(result.payload[:project])
        else
          redirect_to path_for_signed_in_user
        end
      else
        case result.reason
        when ::Onboarding::FreeNamespaceCreateService::NOT_FOUND
          render_404
        when ::Onboarding::FreeNamespaceCreateService::USER_VALIDATION_FAILED
          render ::Registrations::Welcome::FormComponent.new(current_user, resubmit_params(result, step: ::Onboarding::FreeNamespaceCreateService::FULL))
        when ::Onboarding::FreeNamespaceCreateService::NAMESPACE_CREATE_FAILED
          render ::Registrations::Welcome::FormComponent.new(current_user, resubmit_params(result, step: ::Onboarding::FreeNamespaceCreateService::GROUP_FLOW))
        when ::Onboarding::FreeNamespaceCreateService::PROJECT_CREATE_FAILED
          render ::Registrations::Welcome::FormComponent.new(current_user, resubmit_params(result, step: ::Onboarding::FreeNamespaceCreateService::PROJECT_FLOW))
        end
      end
    end

    def unified_success_path(project)
      if ::Feature.enabled?(:remove_onboarding_tutorial_pages, current_user)
        new_project_path(namespace_id: project.namespace_id)
      else
        project_learn_gitlab_path(project)
      end
    end

    def resubmit_params(result, step:)
      {
        namespace_id: result.payload[:namespace_id],
        step: step,
        errors: result.payload[:model_errors]
      }.merge(unified_form_params).to_h.symbolize_keys
    end

    def unified_form_params
      params.permit(
        :first_name, :last_name, :jobs_to_be_done_other,
        :group_name, :project_name, :company_name, :country, :state,
        :onboarding_status_role, :onboarding_status_setup_for_company, :onboarding_status_registration_objective
      ).with_defaults(organization_id: Current.organization.id)
    end
    strong_memoize_attr :unified_form_params

    def step_param
      params.permit(:step)[:step]
    end

    def namespace_params
      params.permit(:namespace_id).to_h.symbolize_keys
    end

    def welcome_layout
      onboarding_status_presenter.unification_enabled? ? 'registration_two_panel' : 'minimal'
    end

    def set_onboarding_status_params
      @onboarding_status_params = {}
    end

    def verify_welcome_needed!
      return unless ::Onboarding.completed_welcome_step?(current_user)

      redirect_to path_for_signed_in_user
    end

    def skip_verify_in_onboarding_flow?
      action_name == 'update' && ::Onboarding::FreeRegistration.unification_enabled?
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
                      .merge(params.permit(:jobs_to_be_done_other))
                      .merge(onboarding_registration_type_params)
                      .merge(onboarding_in_progress: onboarding_status_presenter.continue_full_onboarding?)
    end

    def onboarding_registration_type_params
      return {} unless onboarding_status_presenter.convert_to_automatic_trial?

      # Now we are in automatic trial, and we'll update our status as such, initial_registration_type
      # will be how we know if they weren't a trial originally from here on out.
      { onboarding_status_registration_type: ::Onboarding::REGISTRATION_TYPE[:trial] }
    end

    def passed_through_params
      update_params.slice(*::Onboarding::StatusPresenter::PASSED_THROUGH_PARAMS)
    end

    def update_success_path
      log_success if ::Feature.enabled?(:stop_welcome_redirection, current_user)

      ::Onboarding.cache_onboarding_in_progress(current_user)

      if onboarding_status_presenter.continue_full_onboarding? # trials/regular registration on .com
        signup_onboarding_path
      else
        # Redirect for users not continuing full onboarding (includes OAuth flows)
        path_for_signed_in_user
      end
    end

    def log_success
      Gitlab::AppLogger.info(
        message: 'Welcome update success path',
        username: current_user.username,
        onboarding_in_progress: current_user.onboarding_in_progress,
        onboarding_status: current_user.onboarding_status.to_json,
        user_id: current_user.id,
        db_lsn: User.connection.load_balancer.primary_write_location
      )
    rescue StandardError
      # For non production SaaS instances like test/CI and staging as there is only a primary and no replicas.
      # User.connection.load_balancer.primary_write_location can throw an error
      nil
    end

    def signup_onboarding_path
      if onboarding_status_presenter.joining_a_project?
        Onboarding::FinishService.new(current_user).execute
        path_for_signed_in_user
      elsif onboarding_status_presenter.redirect_to_company_form? # trial only
        Onboarding::StatusStepUpdateService
          .new(current_user, new_users_sign_up_company_path(passed_through_params)).execute[:step_url]
      else
        Onboarding::StatusStepUpdateService.new(current_user, new_users_sign_up_group_path).execute[:step_url]
      end
    end

    def track_joining_a_project_event
      return unless onboarding_status_presenter.joining_a_project?

      cookies[:signup_with_joining_a_project] = { value: true, expires: 30.days }

      track_event('select_button', label: 'join_a_project')
    end

    def track_event(action, label: onboarding_status_presenter.tracking_label)
      ::Gitlab::Tracking.event(
        helpers.body_data_page,
        action,
        user: current_user,
        label: label
      )
    end

    def onboarding_status_presenter
      Onboarding::StatusPresenter.new(@onboarding_status_params, session['user_return_to'], current_user)
    end
    strong_memoize_attr :onboarding_status_presenter

    def set_update_onboarding_status_params
      # The unified form posts flat params; the legacy form nests under `user`. Read whichever is present.
      # rubocop:disable Rails/StrongParams -- value is permitted on the next line
      source = params.fetch(:user, params)
      # rubocop:enable Rails/StrongParams

      @onboarding_status_params = source.permit(:onboarding_status_setup_for_company)
                                        .merge(params.permit(:joining_project)).to_h.deep_symbolize_keys
    end
  end
end

Registrations::WelcomeController.prepend_mod
