# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::DuoWorkflow::Sandbox, feature_category: :duo_agent_platform do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:workflow) { create(:duo_workflows_workflow, project: project, user: user) }
  let_it_be(:duo_config, freeze: false) { ::Gitlab::DuoAgentPlatform::Config.new(project) }

  let(:duo_workflow_service_url) { 'https://duo-workflow.example.com:443' }

  # Extracts and parses the SRT config JSON from the echo command line.
  # The line uses Shellwords.escape so we use Shellwords.shellsplit to recover the JSON.
  def parse_srt_config_from_line(config_line)
    parts = Shellwords.shellsplit(config_line.strip)
    # parts: ["echo", "<json>", ">", "<path>"]
    ::Gitlab::Json.safe_parse(parts[1])
  end

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

      settings_path = "#{Gitlab::DuoWorkflow::Sandbox::SANDBOX_SYSTEM_DIR}/srt-settings.json"
      expect(result[0]).to eq('if which srt > /dev/null; then')
      expect(result[1]).to eq('  echo "SRT found, creating config..."')
      expect(result[2]).to include("echo ")
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

    it 'shell-escapes the SRT config JSON to prevent injection via domain values' do
      # A domain containing a single quote would break naive single-quoting and allow
      # arbitrary shell command injection. Shellwords.escape must neutralise it.
      allow(duo_config).to receive(:network_policy).and_return({
        'allowed_domains' => ["evil'.com; rm -rf /"],
        'denied_domains' => []
      })

      result = sandbox.wrap_command(command)
      config_line = result[2]

      # The line must not contain an unescaped single-quote that would terminate
      # the shell argument early. Verify the JSON round-trips safely.
      parsed_config = parse_srt_config_from_line(config_line)
      expect(parsed_config['network']['allowedDomains']).to include("evil'.com; rm -rf /")
    end
  end

  describe '#environment_variables' do
    it 'returns SRT-specific environment variables' do
      expect(sandbox.environment_variables).to eq({
        NPM_CONFIG_CACHE: "/tmp/.npm-cache",
        GITLAB_LSP_STORAGE_DIR: "/tmp/gitlab-lsp",
        TMPDIR: "/tmp"
      })
    end
  end

  describe '#setup_sandbox_commands' do
    it 'returns sandbox setup commands' do
      expect(sandbox.setup_sandbox_commands).to eq([
        "mkdir -p #{Gitlab::DuoWorkflow::Sandbox::SANDBOX_SYSTEM_DIR}"
      ])
    end
  end

  describe 'SRT configuration' do
    before do
      stub_feature_flags(dap_group_network_access_controls: false, dap_instance_network_access_controls: false)
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

      parsed_config = parse_srt_config_from_line(config_line)
      filesystem = parsed_config['filesystem']

      expect(filesystem['denyRead']).to include('~/.ssh')
      expect(filesystem['allowWrite']).to match_array(["./", "/tmp"])
      expect(filesystem['denyWrite']).to include(Gitlab::DuoWorkflow::Sandbox::SANDBOX_SYSTEM_DIR)
    end

    it 'includes network restrictions in the configuration' do
      result = sandbox.wrap_command('/tmp/executor')
      config_line = result[2]

      expect(config_line).to include('allowAllUnixSockets')
    end
  end

  describe 'SANDBOX_SYSTEM_DIR write protection (defense in depth)' do
    let(:filesystem) do
      parse_srt_config_from_line(sandbox.wrap_command('/tmp/executor')[2])['filesystem']
    end

    let(:system_dir) { described_class::SANDBOX_SYSTEM_DIR }

    it 'explicitly denies the agent write access to the system directory' do
      expect(filesystem['denyWrite']).to include(system_dir)
      expect(filesystem['allowWrite']).not_to include(system_dir)
    end

    it 'keeps the system directory outside every agent-writable path' do
      # Even if the denyWrite rule were removed, the directory must not sit under any
      # absolute allowWrite root (e.g. /tmp), so the agent still could not reach it.
      absolute_writable_roots = filesystem['allowWrite'].select { |path| path.start_with?('/') }

      expect(absolute_writable_roots).not_to be_empty # guard against an empty allowWrite list
      absolute_writable_roots.each do |root|
        expect(system_dir).not_to start_with("#{root}/"),
          "SANDBOX_SYSTEM_DIR (#{system_dir}) must not live under agent-writable path #{root}"
      end
    end
  end

  describe 'domain extraction' do
    before do
      stub_feature_flags(dap_group_network_access_controls: false, dap_instance_network_access_controls: false)
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

        parsed_config = parse_srt_config_from_line(config_line)
        expect(parsed_config['network']['allowedDomains']).to include('invalid[bracket')
      end
    end
  end

  describe 'parent AI settings' do
    before do
      stub_saas_features(gitlab_com_subscriptions: true)
      allow(Gitlab.config.gitlab).to receive(:url).and_return('https://gitlab.example.com')
    end

    context 'when the project has a namespace with AI settings' do
      let!(:namespace_ai_settings) do
        create(:namespace_ai_settings,
          namespace: project.namespace,
          allowed_domains: ['parent-allowed.com'],
          denied_domains: ['parent-denied.com'],
          allow_project_extension: true,
          include_recommended_allowed: false,
          allow_all_unix_sockets: false
        )
      end

      before do
        allow(duo_config).to receive(:network_policy).and_return(nil)
      end

      it 'includes parent-level allowed domains' do
        result = sandbox.wrap_command('/tmp/executor')

        expect(result[2]).to include('parent-allowed.com')
      end

      it 'includes parent-level denied domains' do
        result = sandbox.wrap_command('/tmp/executor')
        parsed_config = parse_srt_config_from_line(result[2])

        expect(parsed_config['network']['deniedDomains']).to include('parent-denied.com')
      end
    end

    context 'when parent has include_recommended_allowed enabled' do
      let!(:namespace_ai_settings) do
        create(:namespace_ai_settings,
          namespace: project.namespace,
          include_recommended_allowed: true,
          allow_project_extension: true
        )
      end

      before do
        allow(duo_config).to receive(:network_policy).and_return(nil)
      end

      it 'includes recommended domains from parent settings' do
        result = sandbox.wrap_command('/tmp/executor')

        expect(result[2]).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::PYTHON_DOMAINS.first)
        expect(result[2]).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::RUBY_DOMAINS.first)
      end
    end

    context 'when parent has allow_all_unix_sockets enabled' do
      let!(:namespace_ai_settings) do
        create(:namespace_ai_settings,
          namespace: project.namespace,
          allow_all_unix_sockets: true,
          allow_project_extension: true
        )
      end

      before do
        allow(duo_config).to receive(:network_policy).and_return(nil)
      end

      it 'enables unix sockets from parent settings' do
        result = sandbox.wrap_command('/tmp/executor')
        parsed_config = parse_srt_config_from_line(result[2])

        expect(parsed_config['network']['allowAllUnixSockets']).to be(true)
      end
    end

    context 'with strict mode (allow_project_extension: false)' do
      let!(:namespace_ai_settings) do
        create(:namespace_ai_settings,
          namespace: project.namespace,
          allow_project_extension: false,
          allowed_domains: ['parent-allowed.com'],
          denied_domains: ['parent-denied.com']
        )
      end

      it 'ignores project-level allowed_domains' do
        allow(duo_config).to receive(:network_policy).and_return({
          'allowed_domains' => ['project-only.com'],
          'denied_domains' => []
        })

        result = sandbox.wrap_command('/tmp/executor')

        expect(result[2]).not_to include('project-only.com')
        expect(result[2]).to include('parent-allowed.com')
      end

      it 'does not allow project to loosen include_recommended_allowed (true when parent is false)' do
        allow(duo_config).to receive(:network_policy).and_return({
          'include_recommended_allowed' => true
        })

        result = sandbox.wrap_command('/tmp/executor')

        expect(result[2]).not_to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::PYTHON_DOMAINS.first)
      end

      it 'honors project-level denied_domains' do
        allow(duo_config).to receive(:network_policy).and_return({
          'allowed_domains' => ['project-only.com'],
          'denied_domains' => ['project-denied.com']
        })

        result = sandbox.wrap_command('/tmp/executor')
        parsed_config = parse_srt_config_from_line(result[2])

        expect(parsed_config['network']['deniedDomains']).to include('project-denied.com')
        expect(parsed_config['network']['deniedDomains']).to include('parent-denied.com')
      end

      it 'does not allow project to loosen allow_all_unix_sockets (true when parent is false)' do
        allow(duo_config).to receive(:network_policy).and_return({
          'allow_all_unix_sockets' => true
        })

        result = sandbox.wrap_command('/tmp/executor')
        parsed_config = parse_srt_config_from_line(result[2])

        expect(parsed_config['network']['allowAllUnixSockets']).to be(false)
      end

      context 'when parent has allow_all_unix_sockets: true' do
        let!(:namespace_ai_settings) do
          create(:namespace_ai_settings,
            namespace: project.namespace,
            allow_project_extension: false,
            allow_all_unix_sockets: true
          )
        end

        it 'allows project to tighten allow_all_unix_sockets (false when parent is true)' do
          allow(duo_config).to receive(:network_policy).and_return({
            'allow_all_unix_sockets' => false
          })

          result = sandbox.wrap_command('/tmp/executor')
          parsed_config = parse_srt_config_from_line(result[2])

          expect(parsed_config['network']['allowAllUnixSockets']).to be(false)
        end
      end

      context 'when parent has include_recommended_allowed: true' do
        let!(:namespace_ai_settings) do
          create(:namespace_ai_settings,
            namespace: project.namespace,
            allow_project_extension: false,
            include_recommended_allowed: true
          )
        end

        it 'allows project to tighten include_recommended_allowed (false when parent is true)' do
          allow(duo_config).to receive(:network_policy).and_return({
            'include_recommended_allowed' => false
          })

          result = sandbox.wrap_command('/tmp/executor')

          expect(result[2]).not_to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::PYTHON_DOMAINS.first)
        end
      end
    end

    context 'with flexible mode and project-level allow_all_unix_sockets override' do
      let!(:namespace_ai_settings) do
        create(:namespace_ai_settings,
          namespace: project.namespace,
          allow_project_extension: true,
          allow_all_unix_sockets: false
        )
      end

      it 'enables unix sockets when project sets allow_all_unix_sockets: true and parent has it false' do
        allow(duo_config).to receive(:network_policy).and_return({
          'allow_all_unix_sockets' => true
        })

        result = sandbox.wrap_command('/tmp/executor')
        parsed_config = parse_srt_config_from_line(result[2])

        expect(parsed_config['network']['allowAllUnixSockets']).to be(true)
      end
    end

    context 'with flexible mode and project disabling allow_all_unix_sockets when parent has it enabled' do
      let!(:namespace_ai_settings) do
        create(:namespace_ai_settings,
          namespace: project.namespace,
          allow_project_extension: true,
          allow_all_unix_sockets: true
        )
      end

      it 'disables unix sockets when project sets allow_all_unix_sockets: false' do
        allow(duo_config).to receive(:network_policy).and_return({
          'allow_all_unix_sockets' => false
        })

        result = sandbox.wrap_command('/tmp/executor')
        parsed_config = parse_srt_config_from_line(result[2])

        expect(parsed_config['network']['allowAllUnixSockets']).to be(false)
      end
    end

    context 'with flexible mode and parent-level domains' do
      let!(:namespace_ai_settings) do
        create(:namespace_ai_settings,
          namespace: project.namespace,
          allow_project_extension: true,
          allowed_domains: ['parent-allowed.com'],
          denied_domains: ['parent-denied.com']
        )
      end

      it 'merges project and parent allowed domains' do
        allow(duo_config).to receive(:network_policy).and_return({
          'allowed_domains' => ['project-allowed.com'],
          'denied_domains' => []
        })

        result = sandbox.wrap_command('/tmp/executor')

        expect(result[2]).to include('parent-allowed.com')
        expect(result[2]).to include('project-allowed.com')
      end

      it 'merges project and parent denied domains' do
        allow(duo_config).to receive(:network_policy).and_return({
          'allowed_domains' => [],
          'denied_domains' => ['project-denied.com']
        })

        result = sandbox.wrap_command('/tmp/executor')
        parsed_config = parse_srt_config_from_line(result[2])

        expect(parsed_config['network']['deniedDomains']).to include('parent-denied.com')
        expect(parsed_config['network']['deniedDomains']).to include('project-denied.com')
      end
    end

    context 'with flexible mode and project-level include_recommended_allowed override' do
      context 'when parent has include_recommended_allowed disabled' do
        let!(:namespace_ai_settings) do
          create(:namespace_ai_settings,
            namespace: project.namespace,
            allow_project_extension: true,
            include_recommended_allowed: false
          )
        end

        it 'enables recommended domains when project sets it to true' do
          allow(duo_config).to receive(:network_policy).and_return({
            'include_recommended_allowed' => true
          })

          result = sandbox.wrap_command('/tmp/executor')

          expect(result[2]).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::PYTHON_DOMAINS.first)
        end
      end

      context 'when parent has include_recommended_allowed enabled' do
        let!(:namespace_ai_settings) do
          create(:namespace_ai_settings,
            namespace: project.namespace,
            allow_project_extension: true,
            include_recommended_allowed: true
          )
        end

        it 'disables recommended domains when project sets it to false' do
          allow(duo_config).to receive(:network_policy).and_return({
            'include_recommended_allowed' => false
          })

          result = sandbox.wrap_command('/tmp/executor')

          expect(result[2]).not_to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::PYTHON_DOMAINS.first)
        end
      end
    end

    context 'when both network access control feature flags are disabled' do
      before do
        stub_feature_flags(dap_group_network_access_controls: false, dap_instance_network_access_controls: false)
      end

      it 'uses agent-config.yml allowed_domains and ignores parent AI settings' do
        create(:namespace_ai_settings, namespace: project.namespace, allowed_domains: ['parent-only.com'])
        allow(duo_config).to receive(:network_policy).and_return({
          'allowed_domains' => ['agent-config.com'],
          'denied_domains' => []
        })

        result = sandbox.wrap_command('/tmp/executor')

        expect(result[2]).to include('agent-config.com')
        expect(result[2]).not_to include('parent-only.com')
      end

      it 'uses agent-config.yml denied_domains' do
        allow(duo_config).to receive(:network_policy).and_return({
          'allowed_domains' => [],
          'denied_domains' => ['blocked.com']
        })

        result = sandbox.wrap_command('/tmp/executor')
        parsed_config = parse_srt_config_from_line(result[2])

        expect(parsed_config['network']['deniedDomains']).to include('blocked.com')
      end

      it 'uses agent-config.yml allow_all_unix_sockets' do
        allow(duo_config).to receive(:network_policy).and_return({ 'allow_all_unix_sockets' => true })

        result = sandbox.wrap_command('/tmp/executor')
        parsed_config = parse_srt_config_from_line(result[2])

        expect(parsed_config['network']['allowAllUnixSockets']).to be(true)
      end

      it 'uses agent-config.yml include_recommended_allowed' do
        allow(duo_config).to receive(:network_policy).and_return({ 'include_recommended_allowed' => true })

        result = sandbox.wrap_command('/tmp/executor')

        expect(result[2]).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::PYTHON_DOMAINS.first)
      end
    end

    context 'when project is nil (self-managed, instance-level settings)' do
      let(:duo_config_no_project) do
        instance_double(Gitlab::DuoAgentPlatform::Config, project: nil, network_policy: nil)
      end

      let(:sandbox_no_project) do
        described_class.new(
          current_user: user,
          duo_workflow_service_url: duo_workflow_service_url,
          duo_config: duo_config_no_project
        )
      end

      before do
        stub_saas_features(gitlab_com_subscriptions: false)
      end

      context 'with flexible mode (allow_project_extension: true)' do
        let(:instance_ai_settings) do
          instance_double(Ai::Setting,
            allow_project_extension: true,
            allowed_domains: ['instance-allowed.com'],
            denied_domains: ['instance-denied.com'],
            include_recommended_allowed: false,
            allow_all_unix_sockets: false
          )
        end

        before do
          allow(::Ai::Setting).to receive(:instance).and_return(instance_ai_settings)
        end

        it 'includes instance-level allowed_domains' do
          result = sandbox_no_project.wrap_command('/tmp/executor')

          expect(result[2]).to include('instance-allowed.com')
        end

        it 'includes instance-level denied_domains' do
          result = sandbox_no_project.wrap_command('/tmp/executor')
          parsed_config = parse_srt_config_from_line(result[2])

          expect(parsed_config['network']['deniedDomains']).to include('instance-denied.com')
        end

        it 'uses instance-level allow_all_unix_sockets' do
          allow(instance_ai_settings).to receive(:allow_all_unix_sockets).and_return(true)

          result = sandbox_no_project.wrap_command('/tmp/executor')
          parsed_config = parse_srt_config_from_line(result[2])

          expect(parsed_config['network']['allowAllUnixSockets']).to be(true)
        end

        it 'uses instance-level include_recommended_allowed' do
          allow(instance_ai_settings).to receive(:include_recommended_allowed).and_return(true)

          result = sandbox_no_project.wrap_command('/tmp/executor')

          expect(result[2]).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::PYTHON_DOMAINS.first)
        end

        it 'merges project duo_config allowed_domains with instance allowed_domains' do
          allow(duo_config_no_project).to receive(:network_policy).and_return({
            'allowed_domains' => ['project-config.com'],
            'denied_domains' => []
          })

          result = sandbox_no_project.wrap_command('/tmp/executor')

          expect(result[2]).to include('instance-allowed.com')
          expect(result[2]).to include('project-config.com')
        end

        it 'merges project duo_config denied_domains with instance denied_domains' do
          allow(duo_config_no_project).to receive(:network_policy).and_return({
            'allowed_domains' => [],
            'denied_domains' => ['project-denied.com']
          })

          result = sandbox_no_project.wrap_command('/tmp/executor')
          parsed_config = parse_srt_config_from_line(result[2])

          expect(parsed_config['network']['deniedDomains']).to include('instance-denied.com')
          expect(parsed_config['network']['deniedDomains']).to include('project-denied.com')
        end

        it 'disables unix sockets when project sets allow_all_unix_sockets: false and instance has it true' do
          allow(instance_ai_settings).to receive(:allow_all_unix_sockets).and_return(true)
          allow(duo_config_no_project).to receive(:network_policy).and_return({
            'allow_all_unix_sockets' => false
          })

          result = sandbox_no_project.wrap_command('/tmp/executor')
          parsed_config = parse_srt_config_from_line(result[2])

          expect(parsed_config['network']['allowAllUnixSockets']).to be(false)
        end

        it 'enables recommended domains when project overrides include_recommended_allowed to true' do
          allow(duo_config_no_project).to receive(:network_policy).and_return({
            'include_recommended_allowed' => true
          })

          result = sandbox_no_project.wrap_command('/tmp/executor')

          expect(result[2]).to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::PYTHON_DOMAINS.first)
        end

        it 'disables recommended domains when project overrides include_recommended_allowed to false' do
          allow(instance_ai_settings).to receive(:include_recommended_allowed).and_return(true)
          allow(duo_config_no_project).to receive(:network_policy).and_return({
            'include_recommended_allowed' => false
          })

          result = sandbox_no_project.wrap_command('/tmp/executor')

          expect(result[2]).not_to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::PYTHON_DOMAINS.first)
        end
      end

      context 'with strict mode (allow_project_extension: false)' do
        let(:instance_ai_settings) do
          instance_double(Ai::Setting,
            allow_project_extension: false,
            allowed_domains: ['instance-allowed.com'],
            denied_domains: ['instance-denied.com'],
            include_recommended_allowed: false,
            allow_all_unix_sockets: false
          )
        end

        before do
          allow(::Ai::Setting).to receive(:instance).and_return(instance_ai_settings)
        end

        it 'ignores project-level allowed_domains' do
          allow(duo_config_no_project).to receive(:network_policy).and_return({
            'allowed_domains' => ['project-only.com'],
            'denied_domains' => []
          })

          result = sandbox_no_project.wrap_command('/tmp/executor')

          expect(result[2]).not_to include('project-only.com')
          expect(result[2]).to include('instance-allowed.com')
        end

        it 'does not allow project to loosen include_recommended_allowed (true when instance is false)' do
          allow(duo_config_no_project).to receive(:network_policy).and_return({
            'include_recommended_allowed' => true
          })

          result = sandbox_no_project.wrap_command('/tmp/executor')

          expect(result[2]).not_to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::PYTHON_DOMAINS.first)
        end

        it 'honors project-level denied_domains' do
          allow(duo_config_no_project).to receive(:network_policy).and_return({
            'allowed_domains' => ['project-only.com'],
            'denied_domains' => ['project-denied.com']
          })

          result = sandbox_no_project.wrap_command('/tmp/executor')
          parsed_config = parse_srt_config_from_line(result[2])

          expect(parsed_config['network']['deniedDomains']).to include('instance-denied.com')
          expect(parsed_config['network']['deniedDomains']).to include('project-denied.com')
        end

        it 'does not allow project to loosen allow_all_unix_sockets (true when instance is false)' do
          allow(duo_config_no_project).to receive(:network_policy).and_return({
            'allow_all_unix_sockets' => true
          })

          result = sandbox_no_project.wrap_command('/tmp/executor')
          parsed_config = parse_srt_config_from_line(result[2])

          expect(parsed_config['network']['allowAllUnixSockets']).to be(false)
        end

        context 'when instance has allow_all_unix_sockets: true' do
          let(:instance_ai_settings) do
            instance_double(Ai::Setting,
              allow_project_extension: false,
              allowed_domains: ['instance-allowed.com'],
              denied_domains: ['instance-denied.com'],
              include_recommended_allowed: false,
              allow_all_unix_sockets: true
            )
          end

          it 'allows project to tighten allow_all_unix_sockets (false when instance is true)' do
            allow(duo_config_no_project).to receive(:network_policy).and_return({
              'allow_all_unix_sockets' => false
            })

            result = sandbox_no_project.wrap_command('/tmp/executor')
            parsed_config = parse_srt_config_from_line(result[2])

            expect(parsed_config['network']['allowAllUnixSockets']).to be(false)
          end
        end

        context 'when instance has include_recommended_allowed: true' do
          let(:instance_ai_settings) do
            instance_double(Ai::Setting,
              allow_project_extension: false,
              allowed_domains: ['instance-allowed.com'],
              denied_domains: ['instance-denied.com'],
              include_recommended_allowed: true,
              allow_all_unix_sockets: false
            )
          end

          it 'allows project to tighten include_recommended_allowed (false when instance is true)' do
            allow(duo_config_no_project).to receive(:network_policy).and_return({
              'include_recommended_allowed' => false
            })

            result = sandbox_no_project.wrap_command('/tmp/executor')

            expect(result[2]).not_to include(Gitlab::DuoWorkflow::NetworkPolicyDomains::PYTHON_DOMAINS.first)
          end
        end
      end
    end
  end

  describe 'network policy configuration' do
    before do
      stub_feature_flags(dap_group_network_access_controls: false, dap_instance_network_access_controls: false)
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
        parsed_config = parse_srt_config_from_line(config_line)
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

        parsed_config = parse_srt_config_from_line(config_line)

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

        parsed_config = parse_srt_config_from_line(config_line)

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

        parsed_config = parse_srt_config_from_line(config_line)
        expect(parsed_config['network']['allowAllUnixSockets']).to be(false)
      end

      it 'defaults to false when allow_all_unix_sockets is not specified' do
        allow(duo_config).to receive(:network_policy).and_return({ 'allowed_domains' => [] })

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        parsed_config = parse_srt_config_from_line(config_line)
        expect(parsed_config['network']['allowAllUnixSockets']).to be(false)
      end

      it 'uses false when allow_all_unix_sockets is explicitly false' do
        allow(duo_config).to receive(:network_policy).and_return({ 'allow_all_unix_sockets' => false })

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        parsed_config = parse_srt_config_from_line(config_line)
        expect(parsed_config['network']['allowAllUnixSockets']).to be(false)
      end

      it 'uses true when allow_all_unix_sockets is explicitly true' do
        allow(duo_config).to receive(:network_policy).and_return({ 'allow_all_unix_sockets' => true })

        result = sandbox.wrap_command('/tmp/executor')
        config_line = result[2]

        parsed_config = parse_srt_config_from_line(config_line)
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
