# frozen_string_literal: true

module Ai
  module ExternalAgents
    module Sessions
      class CompleteService
        def initialize(project:, current_user:, session:, params:)
          @project = project
          @current_user = current_user
          @session = session
          @params = params
        end

        def execute
          return ServiceResponse.error(message: 'Unauthorized') unless authorized?
          return ServiceResponse.error(message: 'Session not found') unless session
          return ServiceResponse.error(message: 'Not session owner', reason: :forbidden) unless owner?
          return ServiceResponse.success(payload: { session: session }) if already_terminal?

          begin
            update_session
            ServiceResponse.success(payload: { session: session })
          rescue ActiveRecord::RecordInvalid => e
            ServiceResponse.error(message: e.message)
          end
        end

        private

        attr_reader :project, :current_user, :session, :params

        def authorized?
          current_user.can?(:update_ai_agent_session, project)
        end

        def owner?
          session.user_id == current_user.id
        end

        def status_for_params
          params[:status] == 'completed' ? 'finished' : 'failed'
        end

        def update_session
          session.session_finished_at = Time.current
          session.status = status_for_params
          session.save!
        end

        def already_terminal?
          session.finished? || session.failed? || session.stopped?
        end
      end
    end
  end
end
