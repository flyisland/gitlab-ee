# frozen_string_literal: true

module API
  class GroupRepositoryStorageMoves < ::API::Base
    include PaginationParams

    before { authenticated_as_admin! }

    feature_category :gitaly

    resource :group_repository_storage_moves do
      desc 'Get a list of all group repository storage moves' do
        detail 'This feature was introduced in GitLab 13.9.'
        tags ['storage_moves']
        is_array true
        success code: 200, model: Entities::Groups::RepositoryStorageMove
      end
      params do
        use :pagination
      end
      route_setting :authorization, permissions: :read_repository_storage_move, boundary_type: :instance
      get do
        storage_moves = ::Groups::RepositoryStorageMove.with_groups.order_created_at_desc

        present paginate(storage_moves), with: Entities::Groups::RepositoryStorageMove, current_user: current_user
      end

      desc 'Get a group repository storage move' do
        detail 'This feature was introduced in GitLab 13.9.'
        tags ['storage_moves']
        success code: 200, model: Entities::Groups::RepositoryStorageMove
      end
      params do
        requires :repository_storage_move_id, type: Integer, desc: 'The ID of a group repository storage move'
      end
      route_setting :authorization, permissions: :read_repository_storage_move, boundary_type: :instance
      get ':repository_storage_move_id' do
        storage_move = ::Groups::RepositoryStorageMove.find(params[:repository_storage_move_id])

        present storage_move, with: Entities::Groups::RepositoryStorageMove, current_user: current_user
      end

      desc 'Schedule bulk group repository storage moves' do
        detail 'This feature was introduced in GitLab 13.9.'
        tags ['storage_moves']
        success code: 202, message: '202 Accepted'
      end
      # rubocop:disable API/ParameterValuesProc -- storage shards are instance-specific
      params do
        requires :source_storage_name, type: String, desc: 'The source storage shard', values: -> { Gitlab.config.repositories.storages.keys }, documentation: { example: 'default' }
        optional :destination_storage_name, type: String, desc: 'The destination storage shard', values: -> { Gitlab.config.repositories.storages.keys }, documentation: { example: 'fast-storage' }
      end
      # rubocop:enable API/ParameterValuesProc
      route_setting :authorization, permissions: :create_repository_storage_move, boundary_type: :instance
      post do
        ::Groups::ScheduleBulkRepositoryShardMovesService.enqueue(
          declared_params[:source_storage_name],
          declared_params[:destination_storage_name]
        )

        accepted!
      end
    end

    params do
      requires :id, type: String, desc: 'The ID of a group'
    end
    resource :groups, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Get a list of all group repository storage moves' do
        detail 'This feature was introduced in GitLab 13.9.'
        tags ['storage_moves']
        is_array true
        success code: 200, model: Entities::Groups::RepositoryStorageMove
      end
      params do
        use :pagination
      end
      route_setting :authorization, permissions: :read_repository_storage_move, boundary_type: :group
      get ':id/repository_storage_moves' do
        storage_moves = user_group.repository_storage_moves.with_groups.order_created_at_desc

        present paginate(storage_moves), with: Entities::Groups::RepositoryStorageMove, current_user: current_user
      end

      desc 'Get a group repository storage move' do
        detail 'This feature was introduced in GitLab 13.9.'
        tags ['storage_moves']
        success code: 200, model: Entities::Groups::RepositoryStorageMove
      end
      params do
        requires :repository_storage_move_id, type: Integer, desc: 'The ID of a group repository storage move'
      end
      route_setting :authorization, permissions: :read_repository_storage_move, boundary_type: :group
      get ':id/repository_storage_moves/:repository_storage_move_id' do
        storage_move = user_group.repository_storage_moves.find(params[:repository_storage_move_id])

        present storage_move, with: Entities::Groups::RepositoryStorageMove, current_user: current_user
      end

      desc 'Schedule a group repository storage move' do
        detail 'This feature was introduced in GitLab 13.9.'
        tags ['storage_moves']
        success code: 201, model: Entities::Groups::RepositoryStorageMove
      end
      params do
        optional :destination_storage_name, type: String, desc: 'The destination storage shard'
      end
      route_setting :authorization, permissions: :create_repository_storage_move, boundary_type: :group
      post ':id/repository_storage_moves' do
        storage_move = user_group.repository_storage_moves.build(
          declared_params.compact.merge(source_storage_name: user_group.wiki.repository_storage)
        )

        if storage_move.schedule
          present storage_move, with: Entities::Groups::RepositoryStorageMove, current_user: current_user
        else
          render_validation_error!(storage_move)
        end
      end
    end
  end
end
