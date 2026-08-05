# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::NpmProjectPackages, feature_category: :package_registry do
  include HttpBasicAuthHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, maintainers: user) }
  let_it_be(:project) { create(:project, :public, group: group) }
  let_it_be(:personal_access_token) { create(:personal_access_token, user: user) }
  let_it_be(:package) { create(:npm_package, project: project) }

  let(:firewall_service) { Security::DependencyFirewall::EnforcementService }
  let(:headers) { basic_auth_header(user.username, personal_access_token.token) }

  describe 'GET /api/v4/projects/:id/packages/npm/*package_name/-/*file_name' do
    let(:package_file) { package.package_files.first }
    let(:url) { "/projects/#{project.id}/packages/npm/#{package.name}/-/#{package_file.file_name}" }

    subject { get api(url), headers: headers }

    it_behaves_like 'applying ip restriction for group'
  end

  describe 'GET /api/v4/projects/:id/packages/npm/*package_name/-/*file_name (dependency firewall)' do
    let(:package_file) { package.package_files.first }
    let(:url) { "/projects/#{project.id}/packages/npm/#{package.name}/-/#{package_file.file_name}" }
    # npm authenticates via a Bearer token (basic auth is ignored), so this resolves
    # current_user; without it the firewall would receive current_user: nil.
    let(:headers) { build_token_auth_header(personal_access_token.token) }

    subject(:download) { get api(url), headers: headers }

    shared_examples 'npm dependency firewall enforcement on download' do
      before do
        stub_feature_flags(dependency_firewall_phase1: project)
        allow(firewall_service).to receive(:firewall_check)
          .and_return(ServiceResponse.success(payload: { status: firewall_service::SUCCESS_ALLOWED }))
      end

      context 'when the dependency_firewall_phase1 feature flag is disabled' do
        before do
          stub_feature_flags(dependency_firewall_phase1: false)
        end

        it 'does not call the firewall and serves the file', :aggregate_failures do
          expect(firewall_service).not_to receive(:firewall_check)

          download

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'when the firewall allows the package' do
        it 'serves the file' do
          download

          expect(response).to have_gitlab_http_status(:ok)
        end

        it 'calls the firewall with the normalized name, version, operation, and current_user', :aggregate_failures do
          expect(firewall_service).to receive(:firewall_check)
            .with(
              project: package.project,
              pkg_type: 'npm',
              name: package.name,
              version: package.version,
              operation: firewall_service::PACKAGE_DOWNLOAD,
              current_user: user
            )
            .and_return(ServiceResponse.success(payload: { status: firewall_service::SUCCESS_ALLOWED }))

          download

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'when the firewall warns on the package' do
        before do
          allow(firewall_service).to receive(:firewall_check)
            .and_return(ServiceResponse.success(payload: { status: firewall_service::SUCCESS_WARNING }))
        end

        it 'serves the file' do
          download

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'when the firewall blocks the package' do
        before do
          allow(firewall_service).to receive(:firewall_check)
            .and_return(ServiceResponse.error(message: nil, reason: firewall_service::SUCCESS_BLOCKED))
        end

        it 'returns 403 with a policy violation error', :aggregate_failures do
          download

          expect(response).to have_gitlab_http_status(:forbidden)
          expect(json_response['error']).to eq('Dependency Firewall policy violation')
        end

        it 'does not track a pull_package event', :aggregate_failures do
          expect(::Gitlab::Tracking).not_to receive(:event).with(anything, 'pull_package', anything)

          download

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end

      context 'when firewall_check returns a non-blocking error response' do
        before do
          allow(firewall_service).to receive(:firewall_check)
            .and_return(ServiceResponse.error(message: 'upstream unavailable', reason: :service_unavailable))
        end

        it 'serves the file' do
          download

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'when the firewall is not licensed' do
        before do
          allow(project).to receive(:licensed_feature_available?).and_call_original
          allow(project).to receive(:licensed_feature_available?).with(:dependency_firewall).and_return(false)
        end

        it 'serves the file', :aggregate_failures do
          expect(firewall_service).to receive(:firewall_check).and_call_original

          download

          expect(response).to have_gitlab_http_status(:ok)
        end
      end
    end

    it_behaves_like 'npm dependency firewall enforcement on download'
  end
end
