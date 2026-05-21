# frozen_string_literal: true

module API
  module Ci
    class RunnerControllerScopes < ::API::Base
      feature_category :continuous_integration

      before do
        authenticated_as_admin!

        not_found! unless ::License.feature_available?(:ci_runner_controllers)
      end

      helpers do
        def find_runner_controller!
          ::Ci::RunnerController.find(params[:id])
        end

        def find_runner!(runner_id)
          ::Ci::Runner.find(runner_id)
        end
      end

      resource :runner_controllers do
        route_setting :lifecycle, :experiment

        desc 'List runner controller scopes' do
          detail 'Get all scopes for a specific runner controller.'
          success code: 200
          tags %w[runner_controllers]
          failure [
            { code: 403, message: 'Forbidden' },
            { code: 404, message: 'Not found' }
          ]
        end
        params do
          requires :id, type: Integer, desc: 'ID of the runner controller'
        end
        get ':id/scopes' do
          controller = find_runner_controller!

          instance_level_scopings = [controller.instance_level_scoping].compact
          runner_level_scopings = controller.runner_level_scopings

          {
            instance_level_scopings: instance_level_scopings.map do |scoping|
              Entities::Ci::RunnerControllerInstanceLevelScoping.represent(scoping)
            end,
            runner_level_scopings: runner_level_scopings.map do |scoping|
              Entities::Ci::RunnerControllerRunnerLevelScoping.represent(scoping)
            end
          }
        end

        desc 'Add instance-level scope' do
          detail 'Add an instance-level scope to a runner controller.'
          success Entities::Ci::RunnerControllerInstanceLevelScoping
          tags %w[runner_controllers]
          failure [
            { code: 403, message: 'Forbidden' },
            { code: 404, message: 'Not found' },
            { code: 409, message: 'Conflict' }
          ]
        end
        params do
          requires :id, type: Integer, desc: 'ID of the runner controller'
        end
        post ':id/scopes/instance' do
          controller = find_runner_controller!

          result = ::Ci::RunnerControllers::Scopes::AddInstanceService.new(
            runner_controller: controller,
            current_user: current_user
          ).execute

          render_api_error!(result.message, result.reason) unless result.success?

          present result.payload, with: Entities::Ci::RunnerControllerInstanceLevelScoping
        end

        desc 'Remove instance-level scope' do
          detail 'Remove an instance-level scope from a runner controller.'
          success code: 204
          tags %w[runner_controllers]
          failure [
            { code: 403, message: 'Forbidden' },
            { code: 404, message: 'Not found' }
          ]
        end
        params do
          requires :id, type: Integer, desc: 'ID of the runner controller'
        end
        delete ':id/scopes/instance' do
          controller = find_runner_controller!

          result = ::Ci::RunnerControllers::Scopes::RemoveInstanceService.new(
            runner_controller: controller,
            current_user: current_user
          ).execute

          render_api_error!(result.message, result.reason) unless result.success?

          no_content!
        end

        desc 'Add runner scope' do
          detail 'Add a runner scope to a runner controller.'
          success Entities::Ci::RunnerControllerRunnerLevelScoping
          tags %w[runner_controllers]
          failure [
            { code: 403, message: 'Forbidden' },
            { code: 404, message: 'Not found' },
            { code: 409, message: 'Conflict' },
            { code: 422, message: 'Unprocessable Entity' }
          ]
        end
        params do
          requires :id, type: Integer, desc: 'ID of the runner controller'
          requires :runner_id, type: Integer, desc: 'ID of the runner'
        end
        post ':id/scopes/runners/:runner_id' do
          controller = find_runner_controller!
          runner = find_runner!(params[:runner_id])

          result = ::Ci::RunnerControllers::Scopes::AddRunnerService.new(
            runner_controller: controller,
            runner: runner,
            current_user: current_user
          ).execute

          render_api_error!(result.message, result.reason) unless result.success?

          present result.payload, with: Entities::Ci::RunnerControllerRunnerLevelScoping
        end

        desc 'Remove runner scope' do
          detail 'Remove a runner scope from a runner controller.'
          success code: 204
          tags %w[runner_controllers]
          failure [
            { code: 403, message: 'Forbidden' },
            { code: 404, message: 'Not found' }
          ]
        end
        params do
          requires :id, type: Integer, desc: 'ID of the runner controller'
          requires :runner_id, type: Integer, desc: 'ID of the runner'
        end
        delete ':id/scopes/runners/:runner_id' do
          controller = find_runner_controller!
          runner = find_runner!(params[:runner_id])

          result = ::Ci::RunnerControllers::Scopes::RemoveRunnerService.new(
            runner_controller: controller,
            runner: runner,
            current_user: current_user
          ).execute

          render_api_error!(result.message, result.reason) unless result.success?

          no_content!
        end
      end
    end
  end
end
