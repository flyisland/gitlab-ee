# frozen_string_literal: true

module API
  class License < ::API::Base
    before { authenticated_as_admin! }

    LICENSES_TAGS = %w[licenses].freeze
    feature_category :plan_provisioning
    urgency :low

    resource :license do
      desc 'Retrieve information about the current license' do
        detail 'Get information on the currently active license'
        success ::API::Entities::GitlabLicenseWithActiveUsers
        tags LICENSES_TAGS
      end
      route_setting :authorization, permissions: :read_license, boundary_type: :instance
      get do
        license = ::License.current

        present license, with: ::API::Entities::GitlabLicenseWithActiveUsers
      end

      resource :usage_export do
        after do
          Gitlab::CurrentSettings.update(license_usage_data_exported: true) if ::License.current.offline_cloud_license?
        end

        desc 'Retrieve license usage data' do
          detail 'Get usage data on the currently active license'
          tags LICENSES_TAGS
        end
        route_setting :authorization, permissions: :read_license, boundary_type: :instance
        get do
          license = ::License.current
          content_type MIME::Types.type_for('csv').first.content_type
          env['api.format'] = :txt
          body HistoricalUserData::CsvService.new(license.historical_data).generate
        end
      end

      desc 'Add a new license' do
        detail 'Adds a new licence'
        success ::API::Entities::GitlabLicenseWithActiveUsers
        failure [
          { code: 400, message: 'Bad request' }
        ]
        tags LICENSES_TAGS
      end
      params do
        requires :license, type: String, desc: 'The license string'
      end
      route_setting :authorization, permissions: :create_license, boundary_type: :instance
      post do
        license = ::License.new(data: params[:license])
        if license.save
          present license, with: ::API::Entities::GitlabLicenseWithActiveUsers
        else
          render_api_error!(license.errors.full_messages.first, 400)
        end
      end

      desc 'Get a license' do
        detail 'Gets a license'
        success ::API::Entities::GitlabLicenseWithActiveUsers
        failure [
          { code: 404, message: 'Not Found' },
          { code: 403, message: 'Forbidden' },
          { code: 401, message: 'Unauthorized' }
        ]
        tags LICENSES_TAGS
      end
      params do
        requires :id, type: Integer, desc: 'ID of the GitLab license'
      end
      route_setting :authorization, permissions: :read_license, boundary_type: :instance
      get ':id' do
        license = LicensesFinder.new(current_user, id: params[:id]).execute.first

        not_found! unless license

        present license, with: ::API::Entities::GitlabLicenseWithActiveUsers
      end

      desc 'Delete a license' do
        detail 'Deletes a license'
        failure [
          { code: 404, message: 'Not found' }
        ]
        tags LICENSES_TAGS
      end
      params do
        requires :id, type: Integer, desc: 'ID of the GitLab license'
      end
      route_setting :authorization, permissions: :delete_license, boundary_type: :instance
      delete ':id' do
        license = LicensesFinder.new(current_user, id: params[:id]).execute.first

        Licenses::DestroyService.new(license, current_user).execute

        no_content!
      end

      desc 'Refresh licence billable users' do
        detail 'Triggers refresh of billable users count for licence'
        success ::API::Entities::BasicSuccess
        failure [
          { code: 404, message: 'Not found' },
          { code: 403, message: 'Forbidden' },
          { code: 401, message: 'Unauthorized' }
        ]
        tags LICENSES_TAGS
      end
      params do
        requires :id, type: Integer, desc: 'ID of the GitLab license'
      end
      route_setting :authorization, permissions: :refresh_license_billable_user, boundary_type: :instance
      put ':id/refresh_billable_users' do
        license = LicensesFinder.new(current_user, id: params[:id]).execute.first

        not_found! unless license

        license.update_billable_user_counts

        status :accepted
        { success: true }
      end
    end

    resource :licenses do
      desc 'Retrieve information about all licenses' do
        detail 'Get a list of licenses'
        success ::API::Entities::GitlabLicense
        failure [
          { code: 403, message: 'Forbidden' }
        ]
        is_array true
        tags LICENSES_TAGS
      end
      route_setting :authorization, permissions: :read_license, boundary_type: :instance
      get do
        licenses = LicensesFinder.new(current_user).execute

        present licenses, with: ::API::Entities::GitlabLicense, current_active_users_count: ::License.current&.daily_billable_users_count
      end
    end
  end
end
