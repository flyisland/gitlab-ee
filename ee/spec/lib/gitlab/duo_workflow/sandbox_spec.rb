# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::DuoWorkflow::Sandbox, feature_category: :duo_agent_platform do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:workflow) { create(:duo_workflows_workflow, project: project, user: user) }
  let_it_be(:duo_config) { ::Gitlab::DuoAgentPlatform::Config.new(project) }

  let(:duo_workflow_service_url) { 'https://duo-workflow.example.com:443' }

  subject(:sandbox) do
    described_class.new(
      current_user: user,
      duo_workflow_service_url: duo_workflow_service_url,
      duo_config: duo_config
    )
  end

  describe '#wrap_command' do
    let(:command) { '/tmp/duo-workflow-executor' }

    it 'wraps the command with SRT sandbox', :aggregate_failures do
      result = sandbox.wrap_command(command)

      expect(result).to be_an(Array)
      expect(result.length).to eq(19)

      settings_path = "#{Gitlab::DuoWorkflow::Sandbox::DUO_AGENT_PLATFORM_WRITE_DIR}/srt-settings.json"
      expect(result[0]).to eq('if which srt > /dev/null; then')
      expect(result[1]).to eq('  echo "SRT found, creating config..."')
      expect(result[2]).to include("echo '")
      expect(result[2]).to include(settings_path)
      expect(result[3]).to eq('  echo "Testing SRT sandbox capabilities..."')
      expect(result[4]).to eq("  if srt --settings #{settings_path} true 2>/dev/null; then")
      expect(result[5]).to eq("    echo \"SRT sandbox test successful, running command: #{command}\"")
      expect(result[6]).to eq("    export GITLAB_WORKFLOW_SANDBOX=true")
      expect(result[7]).to include("    unshare -m env -i ")
      expect(result[7]).to include(" srt --settings #{settings_path} #{command}")
      expect(result[8]).to eq('  else')
      expect(result[9]).to include("    echo \"Warning: SRT found but can't create sandbox")
      expect(result[10]).to include('    echo "For more details visit: https://docs.gitlab.com')
      expect(result[11]).to eq("    #{command}")
      expect(result[12]).to eq('  fi')
      expect(result[13]).to eq('else')
      expect(result[14]).to include('  echo "Warning: srt is not installed or not in PATH')
      expect(result[15]).to include('  echo "For more details visit: https://docs.gitlab.com')
      expect(result[16]).to eq("  #{command}")
      expect(result[17]).to eq('fi')
      expect(result[18]).to eq('echo "Command execution completed with exit code: $?"')
    end

    it 'includes SRT configuration in the wrapped command' do
      result = sandbox.wrap_command(command)
      config_line = result[2]

      expect(config_line).to include('network')
      expect(config_line).to include('allowedDomains')
      expect(config_line).to include('deniedDomains')
      expect(config_line).to include('filesystem')
    end
  end

  describe '#environment_variables' do
    it 'returns SRT-specific environment variables' do
      expect(sandbox.environment_variables).to eq({
        NPM_CONFIG_CACHE: "/tmp/gitlab_duo_agent_platform/.npm-cache",
        GITLAB_LSP_STORAGE_DIR: "/tmp/gitlab_duo_agent_platform",
        TMPDIR: "/tmp/gitlab_duo_agent_platform"
      })
    end
  end

  describe '#setup_sandbox_commands' do
    it 'returns sandbox setup commands' do
      expect(sandbox.setup_sandbox_commands).to eq([
        "mkdir -p /tmp/gitlab_duo_agent_platform"
      ])
    end
  end

  describe 'SRT configuration' do
    before do
      allow(Gitlab.config.gitlab).to receive(:url).and_return('https://gitlab.example.com')
    end

    it 'includes allowed domains in the configuration' do
      result = sandbox.wrap_command('/tmp/executor')
      config_line = result[2]

      expect(config_line).to include('host.docker.internal')
      expect(config_line).to include('localhost')
      expect(config_line).to include('gitlab.example.com')
      expect(config_line).to include('*.gitlab.example.com')
      expect(config_line).to include('duo-workflow.example.com')
    end

    it 'includes filesystem restrictions in the configuration' do
      result = sandbox.wrap_command('/tmp/executor')
      config_line = result[2]

      expect(config_line).to include('~/.ssh')
      expect(config_line).to include('/tmp/')
    end

    it 'includes network restrictions in the configuration' do
      result = sandbox.wrap_command('/tmp/executor')
      config_line = result[2]

      expect(config_line).to include('allowAllUnixSockets')
    end
  end

  describe 'domain extraction' do
    before do
      allow(Gitlab.config.gitlab).to receive(:url).and_return('https://gitlab.example.com')
    end

    context 'with blank or nil URLs' do
      it 'handles blank duo_workflow_service_url' do
        sandbox = described_class.new(
          current_user: user,
          duo_workflow_service_url: '',
          duo_config: duo_config
        )

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        expect(config_line).to include('gitlab.example.com')
        expect(config_line).to include('localhost')
      end

      it 'handles nil duo_workflow_service_url' do
        sandbox = described_class.new(
          current_user: user,
          duo_workflow_service_url: nil,
          duo_config: duo_config
        )

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        expect(config_line).to include('gitlab.example.com')
        expect(config_line).to include('localhost')
      end
    end

    context 'with full URI formats' do
      it 'extracts domain from https URL with port' do
        sandbox = described_class.new(
          current_user: user,
          duo_workflow_service_url: 'https://example.com:443',
          duo_config: duo_config
        )

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        expect(config_line).to include('example.com')
      end

      it 'extracts domain from http URL' do
        sandbox = described_class.new(
          current_user: user,
          duo_workflow_service_url: 'http://service.example.com',
          duo_config: duo_config
        )

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        expect(config_line).to include('service.example.com')
      end

      it 'extracts domain from URL with path' do
        sandbox = described_class.new(
          current_user: user,
          duo_workflow_service_url: 'https://example.com/path/to/resource',
          duo_config: duo_config
        )

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        expect(config_line).to include('example.com')
      end
    end

    context 'with host:port format (no scheme)' do
      it 'extracts domain from host:port format' do
        sandbox = described_class.new(
          current_user: user,
          duo_workflow_service_url: 'example.com:50052',
          duo_config: duo_config
        )

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        expect(config_line).to include('example.com')
      end

      it 'extracts domain from grpc service with port' do
        sandbox = described_class.new(
          current_user: user,
          duo_workflow_service_url: 'grpc.example.com:50052',
          duo_config: duo_config
        )

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        expect(config_line).to include('grpc.example.com')
      end

      it 'extracts domain from localhost:port format' do
        sandbox = described_class.new(
          current_user: user,
          duo_workflow_service_url: 'localhost:8080',
          duo_config: duo_config
        )

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        expect(config_line).to include('localhost')
      end

      it 'extracts domain from IP:port format' do
        sandbox = described_class.new(
          current_user: user,
          duo_workflow_service_url: '192.168.1.1:3000',
          duo_config: duo_config
        )

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        expect(config_line).to include('192.168.1.1')
      end
    end

    context 'with plain hostnames' do
      it 'handles plain hostname without port' do
        sandbox = described_class.new(
          current_user: user,
          duo_workflow_service_url: 'simple-hostname',
          duo_config: duo_config
        )

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        expect(config_line).to include('simple-hostname')
      end
    end

    context 'with invalid URI formats' do
      it 'handles invalid URI with colon by extracting first part' do
        sandbox = described_class.new(
          current_user: user,
          duo_workflow_service_url: 'http://[invalid:malformed',
          duo_config: duo_config
        )

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        expect(config_line).to include('http')
      end

      it 'handles invalid URI without colon by using as-is' do
        sandbox = described_class.new(
          current_user: user,
          duo_workflow_service_url: 'invalid[bracket',
          duo_config: duo_config
        )

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        expect(config_line).to include('invalid[bracket')
      end
    end
  end

  describe 'network policy configuration' do
    before do
      allow(Gitlab.config.gitlab).to receive(:url).and_return('https://gitlab.example.com')
    end

    context 'when network_policy is not specified' do
      it 'uses only minimal allowlisted domains' do
        allow(duo_config).to receive(:network_policy).and_return(nil)

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        # Should include only minimal domains
        expect(config_line).to include('host.docker.internal')
        expect(config_line).to include('localhost')
        expect(config_line).to include('gitlab.example.com')
        expect(config_line).to include('*.gitlab.example.com')
        expect(config_line).to include('duo-workflow.example.com')

        # Should not include recommended domains
        expect(config_line).not_to include('pypi.org')
        expect(config_line).not_to include('npmjs.org')
        expect(config_line).not_to include('rubygems.org')

        # Should have empty deny list
        parsed_config = ::Gitlab::Json.safe_parse(config_line.match(/echo '(.+)' >/)[1])
        expect(parsed_config['network']['deniedDomains']).to eq([])
      end
    end

    context 'when deny all traffic is configured' do
      it 'denies all domains with wildcard in denied_domains' do
        allow(duo_config).to receive(:network_policy).and_return({
          'allowed_domains' => [],
          'denied_domains' => ['*']
        })

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        parsed_config = ::Gitlab::Json.safe_parse(config_line.match(/echo '(.+)' >/)[1])

        # Should still include minimal allowed domains (these take precedence)
        expect(parsed_config['network']['allowedDomains']).to include('host.docker.internal')
        expect(parsed_config['network']['allowedDomains']).to include('localhost')
        expect(parsed_config['network']['allowedDomains']).to include('gitlab.example.com')

        # Should have wildcard in deny list
        expect(parsed_config['network']['deniedDomains']).to include('*')
      end
    end

    context 'with custom allow list' do
      it 'includes custom allow list domains in the configuration' do
        allow(duo_config).to receive(:network_policy).and_return({
          'allowed_domains' => ['custom-domain.com', 'api.custom.com'],
          'denied_domains' => []
        })

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        # Should include custom domains
        expect(config_line).to include('custom-domain.com')
        expect(config_line).to include('api.custom.com')

        # Should still include minimal domains
        expect(config_line).to include('gitlab.example.com')
        expect(config_line).to include('localhost')
      end

      it 'includes custom deny list domains in the configuration' do
        allow(duo_config).to receive(:network_policy).and_return({
          'allowed_domains' => ['allowed.com'],
          'denied_domains' => ['blocked.com', 'malicious.com']
        })

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        # Should include denied domains in deny list
        expect(config_line).to include('blocked.com')
        expect(config_line).to include('malicious.com')

        # Should include allowed domain
        expect(config_line).to include('allowed.com')
      end
    end

    context 'when blank allowed_domains and denied_domains are specified' do
      it 'uses only minimal allowlisted domains with empty deny list' do
        allow(duo_config).to receive(:network_policy).and_return({
          'allowed_domains' => [],
          'denied_domains' => []
        })

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        parsed_config = ::Gitlab::Json.safe_parse(config_line.match(/echo '(.+)' >/)[1])

        # Should still include minimal domains
        expect(parsed_config['network']['allowedDomains']).to include('host.docker.internal')
        expect(parsed_config['network']['allowedDomains']).to include('localhost')
        expect(parsed_config['network']['allowedDomains']).to include('gitlab.example.com')

        # Should have empty deny list
        expect(parsed_config['network']['deniedDomains']).to eq([])

        # Should not include any recommended or custom domains
        expect(config_line).not_to include('pypi.org')
        expect(config_line).not_to include('npmjs.org')
      end
    end

    context 'with allow_all_unix_sockets configuration' do
      it 'defaults to false when network_policy is nil' do
        allow(duo_config).to receive(:network_policy).and_return(nil)

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        parsed_config = ::Gitlab::Json.safe_parse(config_line.match(/echo '(.+)' >/)[1])
        expect(parsed_config['network']['allowAllUnixSockets']).to be(false)
      end

      it 'defaults to false when allow_all_unix_sockets is not specified' do
        allow(duo_config).to receive(:network_policy).and_return({ 'allowed_domains' => [] })

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        parsed_config = ::Gitlab::Json.safe_parse(config_line.match(/echo '(.+)' >/)[1])
        expect(parsed_config['network']['allowAllUnixSockets']).to be(false)
      end

      it 'uses false when allow_all_unix_sockets is explicitly false' do
        allow(duo_config).to receive(:network_policy).and_return({ 'allow_all_unix_sockets' => false })

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        parsed_config = ::Gitlab::Json.safe_parse(config_line.match(/echo '(.+)' >/)[1])
        expect(parsed_config['network']['allowAllUnixSockets']).to be(false)
      end

      it 'uses true when allow_all_unix_sockets is explicitly true' do
        allow(duo_config).to receive(:network_policy).and_return({ 'allow_all_unix_sockets' => true })

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        parsed_config = ::Gitlab::Json.safe_parse(config_line.match(/echo '(.+)' >/)[1])
        expect(parsed_config['network']['allowAllUnixSockets']).to be(true)
      end
    end

    context 'with recommended allowed list network policy mode' do
      it 'includes preset allowlisted domains in the configuration' do
        allow(duo_config).to receive(:network_policy).and_return({ 'include_recommended_allowed' => true })

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        # Should include recommended preset domains
        expect(config_line).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::VERSION_CONTROL_DOMAINS.first)
        expect(config_line).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::CONTAINER_REGISTRY_DOMAINS.first)
        expect(config_line).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::JAVASCRIPT_DOMAINS.first)
        expect(config_line).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::PYTHON_DOMAINS.first)
        expect(config_line).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::RUBY_DOMAINS.first)
        expect(config_line).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::RUST_DOMAINS.first)
        expect(config_line).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::JVM_DOMAINS.first)
        expect(config_line).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::PACKAGE_MANAGEMENT_DOMAINS.first)
        expect(config_line).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::LINUX_DOMAINS.first)
        expect(config_line).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::DEV_DOMAINS.first)
        expect(config_line).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::CONTENT_DELIVERY_DOMAINS.first)
        expect(config_line).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::SCHEMA_DOMAINS.first)
        expect(config_line).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::GO_DOMAINS.first)
        expect(config_line).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::MCP_DOMAINS.first)

        expect(config_line).to include('host.docker.internal')
        expect(config_line).to include('localhost')
        expect(config_line).to include('gitlab.example.com')
      end
    end
  end
end
