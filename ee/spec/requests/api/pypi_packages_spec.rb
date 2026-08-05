# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::PypiPackages, feature_category: :package_registry do
  include WorkhorseHelpers
  include PackagesManagerApiSpecHelpers
  include HttpBasicAuthHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group, freeze: false) { create(:group, maintainers: user) }
  let_it_be(:project, freeze: false) { create(:project, group: group) }
  let_it_be(:personal_access_token) { create(:personal_access_token, user: user) }
  let_it_be(:package_name) { 'Dummy-Package' }
  let_it_be(:package) { create(:pypi_package, project: project, name: package_name, version: '1.0.0') }

  let(:file_sha256) { package.package_files.first.file_sha256 }
  let(:headers) { basic_auth_header(user.username, personal_access_token.token) }
  let(:firewall_service) { Security::DependencyFirewall::EnforcementService }
  let(:snowplow_gitlab_standard_context) do
    { project: project, namespace: group, property: 'i_package_pypi_user', user: user }
  end

  subject(:download) { get api(url), headers: headers }

  shared_examples 'allowing auditor to download' do
    context 'when group/project is private' do
      let(:headers) { user_basic_auth_header(create(:auditor)) }

      before do
        target.update_column(:visibility_level, ::Gitlab::VisibilityLevel.const_get(:PRIVATE, false))
      end

      it_behaves_like 'returning response status', :success
    end
  end

  shared_examples 'pypi dependency firewall enforcement on download' do
    before do
      allow(firewall_service).to receive(:firewall_check)
        .and_return(ServiceResponse.success(payload: { status: firewall_service::SUCCESS_ALLOWED }))
    end

    context 'when the dependency_firewall_phase1 feature flag is disabled' do
      before do
        stub_feature_flags(dependency_firewall_phase1: false)
      end

      it 'does not call the firewall and allows the download', :aggregate_failures do
        expect(firewall_service).not_to receive(:firewall_check)

        download

        expect(response).to have_gitlab_http_status(:ok)
      end
    end

    context 'when the dependency_firewall_phase1 feature flag is enabled' do
      context 'when the firewall allows the package' do
        it 'calls the firewall with the PEP 503 normalized name, version, operation, and current_user',
          :aggregate_failures do
          expect(firewall_service).to receive(:firewall_check)
            .with(
              project: package.project,
              pkg_type: 'pypi',
              name: package.normalized_pypi_name,
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

        it 'allows the download' do
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
          expect(::Gitlab::Tracking).not_to receive(:event).with(anything, 'pull_package', anything)

          download

          expect(response).to have_gitlab_http_status(:forbidden)
          expect(json_response['error']).to eq('Dependency Firewall policy violation')
        end
      end

      context 'when firewall_check returns a non-blocking error response' do
        before do
          allow(firewall_service).to receive(:firewall_check)
            .and_return(ServiceResponse.error(message: 'upstream unavailable', reason: :service_unavailable))
        end

        it 'allows the download' do
          download

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'when the firewall is not licensed' do
        before do
          allow(project).to receive(:licensed_feature_available?).with(:dependency_firewall).and_return(false)
        end

        it 'allows the download', :aggregate_failures do
          expect(firewall_service).to receive(:firewall_check).and_call_original

          download

          expect(response).to have_gitlab_http_status(:ok)
        end
      end
    end
  end

  describe 'GET /api/v4/groups/:id/-/packages/pypi/files/:sha256/*file_identifier' do
    let(:url) { "/groups/#{group.id}/-/packages/pypi/files/#{file_sha256}/#{package_name}-1.0.0.tar.gz" }

    it_behaves_like 'applying ip restriction for group'
    it_behaves_like 'allowing auditor to download' do
      let(:target) { group }
    end
  end

  describe 'GET /api/v4/projects/:id/packages/pypi/files/:sha256/*file_identifier' do
    let(:url) { "/projects/#{project.id}/packages/pypi/files/#{file_sha256}/#{package_name}-1.0.0.tar.gz" }

    it_behaves_like 'applying ip restriction for group'
    it_behaves_like 'allowing auditor to download' do
      let(:target) { project }
    end

    it_behaves_like 'pypi dependency firewall enforcement on download'
  end

  describe 'Flow 1: forwarded simple index', feature_category: :package_registry do
    include_context 'dependency proxy helpers context'

    let(:unknown) { 'requests' }
    let(:url) { "/projects/#{project.id}/packages/pypi/simple/#{unknown}" }
    let(:upstream_simple_url) { 'https://pypi.org/simple/requests/' }
    let(:json_headers) { headers.merge('Accept' => 'application/vnd.pypi.simple.v1+json') }
    let(:upstream_body) do
      {
        'meta' => { 'api-version' => '1.0' },
        'name' => 'requests',
        'files' => [{ 'filename' => 'requests-2.31.0.tar.gz',
                      'url' => 'https://files.pythonhosted.org/p/requests-2.31.0.tar.gz',
                      'hashes' => { 'sha256' => 'aaa' } }]
      }.to_json
    end

    before do
      stub_feature_flags(dependency_firewall_phase1: true, pypi_pep_691_json: true)
      allow_fetch_cascade_application_setting(attribute: 'pypi_package_requests_forwarding', return_value: true)
    end

    context 'when the package is unknown locally and upstream returns 200' do
      before do
        stub_request(:get, upstream_simple_url).to_return(status: 200, body: upstream_body)
      end

      it 'proxies and rewrites file URLs back to GitLab (JSON)', :aggregate_failures do
        expect(firewall_service).not_to receive(:firewall_check)
        get api(url), headers: json_headers
        expect(response).to have_gitlab_http_status(:ok)
        body = ::Gitlab::Json.safe_parse(response.body)
        file_url = body['files'].first['url']
        # The rewritten URL is an absolute GitLab URL (via expose_url, so relative_url_root
        # is preserved) pointing at GitLab's file endpoint, not directly at pythonhosted.
        expect(file_url).to include("/api/v4/projects/#{project.id}/packages/pypi/files/")
        # The upstream URL is embedded as a query param for the Flow 2 redirect - the
        # path itself must not be a direct pythonhosted link
        expect(URI.parse(file_url).path).not_to include('pythonhosted')
      end

      it 'renders HTML when JSON is not requested', :aggregate_failures do
        get api(url), headers: headers
        expect(response).to have_gitlab_http_status(:ok)
        expect(response.content_type).to include('text/html')
        expect(response.body).to include('<h1>Links for requests</h1>')
      end
    end

    context 'when a known local package exists' do
      let(:url) { "/projects/#{project.id}/packages/pypi/simple/#{package_name}" }

      it 'serves the local presenter without calling upstream or the firewall', :aggregate_failures do
        expect(firewall_service).not_to receive(:firewall_check)
        get api(url), headers: headers
        expect(response).to have_gitlab_http_status(:ok)
        expect(a_request(:get, %r{pypi.org/simple})).not_to have_been_made
      end
    end

    context 'when upstream returns 404' do
      before do
        stub_request(:get, upstream_simple_url).to_return(status: 404)
      end

      it 'returns not found' do
        get api(url), headers: json_headers
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when upstream returns 500' do
      before do
        stub_request(:get, upstream_simple_url).to_return(status: 500)
      end

      it 'returns bad gateway' do
        get api(url), headers: json_headers
        expect(response).to have_gitlab_http_status(:bad_gateway)
      end
    end

    context 'when upstream times out' do
      before do
        stub_request(:get, upstream_simple_url).to_raise(Net::ReadTimeout)
      end

      it 'returns bad gateway' do
        get api(url), headers: json_headers
        expect(response).to have_gitlab_http_status(:bad_gateway)
      end
    end

    context 'when upstream returns only disallowed hosts' do
      before do
        body = {
          'meta' => { 'api-version' => '1.0' },
          'name' => 'requests',
          'files' => [{ 'filename' => 'requests-2.31.0.tar.gz',
                        'url' => 'https://evil.example.com/x.tar.gz',
                        'hashes' => { 'sha256' => 'aaa' } }]
        }.to_json
        stub_request(:get, upstream_simple_url).to_return(status: 200, body: body)
      end

      it 'returns 200 with an empty files array' do
        get api(url), headers: json_headers
        expect(::Gitlab::Json.safe_parse(response.body)['files']).to be_empty
      end
    end

    context 'when the feature flag is disabled' do
      before do
        stub_feature_flags(dependency_firewall_phase1: false)
      end

      it 'redirects to pypi.org (existing behaviour)', :aggregate_failures do
        get api(url), headers: headers
        expect(response).to have_gitlab_http_status(:found)
        expect(response.headers['Location']).to eq('https://pypi.org/simple/requests/')
      end
    end

    context 'when forwarding is disabled' do
      before do
        allow_fetch_cascade_application_setting(attribute: 'pypi_package_requests_forwarding', return_value: false)
      end

      it 'returns 404 (existing behaviour)' do
        get api(url), headers: headers
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  describe 'Flow 2: forwarded file download', feature_category: :package_registry do
    include_context 'dependency proxy helpers context'

    let(:upstream_url) { 'https://files.pythonhosted.org/packages/aa/requests-2.31.0.tar.gz' }
    let(:base_path) { "/projects/#{project.id}/packages/pypi/files/abc123/requests-2.31.0.tar.gz" }
    let(:query) { { package_name: 'requests', version: '2.31.0', upstream_url: upstream_url } }
    let(:url) { "#{base_path}?#{query.to_query}" }

    before do
      stub_feature_flags(dependency_firewall_phase1: true)
      allow_fetch_cascade_application_setting(attribute: 'pypi_package_requests_forwarding', return_value: true)
      allow(firewall_service).to receive(:firewall_check)
        .and_return(ServiceResponse.success(payload: { status: firewall_service::SUCCESS_ALLOWED }))
    end

    it 'redirects to the upstream artifact when the firewall allows', :aggregate_failures do
      get api(url), headers: headers
      expect(response).to have_gitlab_http_status(:found)
      expect(response.headers['Location']).to eq(upstream_url)
    end

    it 'normalizes the package name to PEP 503 at the firewall boundary' do
      expect(firewall_service).to receive(:firewall_check).with(hash_including(name: 'requests'))
        .and_return(ServiceResponse.success(payload: { status: firewall_service::SUCCESS_ALLOWED }))
      get api("#{base_path}?#{query.merge(package_name: 'Requests').to_query}"), headers: headers
    end

    it 'issues a 302 (not 404) when firewall warns', :aggregate_failures do
      allow(firewall_service).to receive(:firewall_check)
        .and_return(ServiceResponse.success(payload: { status: firewall_service::SUCCESS_WARNING }))
      get api(url), headers: headers
      expect(response).to have_gitlab_http_status(:found)
      expect(response.headers['Location']).to eq(upstream_url)
    end

    it 'returns 403 when the firewall blocks', :aggregate_failures do
      allow(firewall_service).to receive(:firewall_check)
        .and_return(ServiceResponse.error(message: "Package 'requests' violates 'X' policy",
          reason: firewall_service::SUCCESS_BLOCKED))
      get api(url), headers: headers
      expect(response).to have_gitlab_http_status(:forbidden)
      expect(::Gitlab::Json.safe_parse(response.body)['message']).to eq("Package 'requests' violates 'X' policy")
    end

    it 'returns 404 and never calls the firewall for a disallowed host', :aggregate_failures do
      expect(firewall_service).not_to receive(:firewall_check)
      get api("#{base_path}?#{query.merge(upstream_url: 'https://evil.example.com/x.tar.gz').to_query}"),
        headers: headers
      expect(response).to have_gitlab_http_status(:not_found)
    end

    it 'returns 404 when query params are missing' do
      get api(base_path), headers: headers
      expect(response).to have_gitlab_http_status(:not_found)
    end

    context 'when the feature flag is disabled' do
      before do
        stub_feature_flags(dependency_firewall_phase1: false)
      end

      it 'returns 404 without calling the firewall', :aggregate_failures do
        expect(firewall_service).not_to receive(:firewall_check)
        get api(url), headers: headers
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when forwarding is disabled' do
      before do
        allow_fetch_cascade_application_setting(attribute: 'pypi_package_requests_forwarding', return_value: false)
      end

      it 'returns 404 without calling the firewall', :aggregate_failures do
        expect(firewall_service).not_to receive(:firewall_check)
        get api(url), headers: headers
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v4/projects/:id/packages/pypi (dependency firewall)' do
    include_context 'workhorse headers'

    let(:url) { "/projects/#{project.id}/packages/pypi" }
    let(:file_name) { 'package.whl' }
    # Consecutive runs of [-_.] must collapse to a single '-' (PEP 503),
    # matching Packages::Pypi::Package#normalized_pypi_name.
    let(:upload_name) { 'Upload__Test..Pkg' }
    let(:upload_version) { '1.2.3' }
    let(:params) do
      {
        content: temp_file(file_name),
        name: upload_name,
        version: upload_version,
        sha256_digest: '1' * 64,
        md5_digest: '1' * 32,
        requires_python: '>=3.7'
      }
    end

    let(:headers) { basic_auth_header(user.username, personal_access_token.token).merge(workhorse_headers) }

    subject(:upload) do
      workhorse_finalize(
        api(url),
        method: :post,
        file_key: :content,
        params: params,
        headers: headers,
        send_rewritten_field: true
      )
    end

    before do
      stub_feature_flags(dependency_firewall_phase1: project)
      allow(firewall_service).to receive(:firewall_check)
        .and_return(ServiceResponse.success(payload: { status: firewall_service::SUCCESS_ALLOWED }))
    end

    context 'when the dependency_firewall_phase1 feature flag is disabled' do
      before do
        stub_feature_flags(dependency_firewall_phase1: false)
      end

      it 'does not call the firewall and creates the package', :aggregate_failures do
        expect(firewall_service).not_to receive(:firewall_check)

        expect { upload }.to change { project.packages.pypi.count }.by(1)
        expect(response).to have_gitlab_http_status(:created)
      end
    end

    context 'when the firewall allows the package' do
      it 'creates the package', :aggregate_failures do
        expect { upload }.to change { project.packages.pypi.count }.by(1)
        expect(response).to have_gitlab_http_status(:created)
      end

      it 'calls the firewall with the PEP 503 normalized name, version, operation, and current_user',
        :aggregate_failures do
        expect(firewall_service).to receive(:firewall_check)
          .with(
            project: project,
            pkg_type: 'pypi',
            name: 'upload-test-pkg',
            version: upload_version,
            operation: firewall_service::PACKAGE_UPLOAD,
            current_user: user
          )
          .and_return(ServiceResponse.success(payload: { status: firewall_service::SUCCESS_ALLOWED }))

        upload

        expect(response).to have_gitlab_http_status(:created)
      end
    end

    context 'when the firewall warns on the package' do
      before do
        allow(firewall_service).to receive(:firewall_check)
          .and_return(ServiceResponse.success(payload: { status: firewall_service::SUCCESS_WARNING }))
      end

      it 'creates the package', :aggregate_failures do
        expect { upload }.to change { project.packages.pypi.count }.by(1)
        expect(response).to have_gitlab_http_status(:created)
      end
    end

    context 'when firewall_check returns a non-blocking error response' do
      before do
        allow(firewall_service).to receive(:firewall_check)
          .and_return(ServiceResponse.error(message: 'upstream unavailable', reason: :service_unavailable))
      end

      it 'creates the package', :aggregate_failures do
        expect { upload }.to change { project.packages.pypi.count }.by(1)
        expect(response).to have_gitlab_http_status(:created)
      end
    end

    context 'when the firewall is not licensed' do
      before do
        allow(project).to receive(:licensed_feature_available?).with(:dependency_firewall).and_return(false)
      end

      it 'creates the package', :aggregate_failures do
        expect(firewall_service).to receive(:firewall_check).and_call_original

        expect { upload }.to change { project.packages.pypi.count }.by(1)
        expect(response).to have_gitlab_http_status(:created)
      end
    end

    context 'when the firewall blocks the package' do
      before do
        allow(firewall_service).to receive(:firewall_check)
          .and_return(ServiceResponse.error(message: nil, reason: firewall_service::SUCCESS_BLOCKED))
      end

      it 'returns 403 and does not create the package', :aggregate_failures do
        expect { upload }.not_to change { project.packages.pypi.count }
        expect(response).to have_gitlab_http_status(:forbidden)
        expect(json_response['error']).to eq('Dependency Firewall policy violation')
      end

      it 'does not track a push_package event', :aggregate_failures do
        expect(::Gitlab::Tracking).not_to receive(:event).with(anything, 'push_package', anything)

        upload

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end
end
