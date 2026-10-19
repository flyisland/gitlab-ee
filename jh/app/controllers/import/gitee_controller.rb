# frozen_string_literal: true

module Import
  class GiteeController < BaseController
    extend ::Gitlab::Utils::Override

    include ImportHelper
    include ActionView::Helpers::SanitizeHelper

    before_action :verify_import_enabled
    before_action :provider_auth, only: [:status, :realtime_changes, :create]
    before_action :verify_gitee_access_token, only: :personal_access_token

    def new
      return unless session[access_token_key]

      redirect_to status_import_url
    end

    def personal_access_token
      session[access_token_key] = params[:personal_access_token]&.strip
      redirect_to status_import_url
    end

    def status
      client_repos(filter: sanitized_filter_param)

      super
    end

    def create
      gitee_client = Gitee::Client.new(credentials)

      name = params[:repo_id].to_s
      repo = gitee_client.repo(name)
      project_name = params[:new_name].presence || repo.name

      repo_owner = repo.owner
      repo_owner = current_user.username if repo_owner == gitee_client.user.username
      namespace_path = params[:new_namespace].presence || repo_owner
      target_namespace = find_or_create_namespace(namespace_path, current_user)

      if current_user.can?(:create_projects, target_namespace)
        session[access_token_key] = gitee_client.connection.token

        project = Gitlab::GiteeImport::ProjectCreator.new(
          repo, project_name, target_namespace, current_user, credentials).execute

        if project.persisted?
          render json: ProjectSerializer.new.represent(project, serializer: :import)
        else
          render json: { errors: project_save_error(project) }, status: :unprocessable_entity
        end
      else
        render json: {
          errors: s_('JH|This namespace has already been taken! Please choose another one.')
        }, status: :unprocessable_entity
      end
    end

    def reset_access_token
      session[:gitee_access_token] = nil
      redirect_to new_import_url,
        alert: s_('JH|The access token has been cleared.')
    end

    protected

    override :importable_repos
    def importable_repos
      client_repos.to_a
    end

    override :incompatible_repos
    def incompatible_repos
      []
    end

    override :provider_name
    def provider_name
      :gitee
    end

    override :provider_url
    def provider_url
      'https://gitee.com'
    end
    strong_memoize_attr :provider_url

    private

    def serialized_imported_projects(projects = already_added_projects)
      ProjectSerializer.new.represent(projects, serializer: :import, provider_url: provider_url)
    end

    def client
      @client ||= Gitee::Client.new(gitee_access_token: session[access_token_key])
    end

    def client_repos(filter: nil)
      @client_repos ||= client.repos(filter: filter)
    end

    def sanitized_filter_param
      super

      @filter = @filter&.tr(' ', '')&.tr(':', '')
    end

    def verify_import_enabled
      render_404 unless import_enabled?
    end

    def import_enabled?
      __send__(:"#{provider_name}_import_enabled?") # rubocop:disable GitlabSecurity/PublicSend
    end

    def new_import_url
      public_send(:"new_import_#{provider_name}_url", extra_import_params.merge({ namespace_id: params[:namespace_id] })) # rubocop:disable GitlabSecurity/PublicSend
    end

    def status_import_url
      public_send(:"status_import_#{provider_name}_url", extra_import_params.merge({ namespace_id: params[:namespace_id].presence })) # rubocop:disable GitlabSecurity/PublicSend
    end

    def access_token_key
      :"#{provider_name}_access_token"
    end

    def provider_auth
      return unless session[access_token_key].blank?

      redirect_to new_import_url, alert: s_('JH|Access token is invalid or expired.')
    end

    def extra_import_params
      {}
    end

    def credentials
      {
        gitee_access_token: session[access_token_key]
      }
    end

    def verify_gitee_access_token
      if params[:personal_access_token].blank?
        redirect_to new_import_url, alert: s_('JH|Access token cannot be blank.')
      else
        client = Gitee::Client.new(gitee_access_token: params[:personal_access_token])
        return unless client.user.username.nil?

        session[access_token_key] = nil
        redirect_to new_import_url, alert: s_('JH|Access token is invalid or expired.')
      end
    end
  end
end
