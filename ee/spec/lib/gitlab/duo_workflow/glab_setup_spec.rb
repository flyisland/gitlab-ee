# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::DuoWorkflow::GlabSetup, feature_category: :duo_agent_platform do
  let_it_be(:user) { create(:user, username: 'glab-user') }

  subject(:glab_setup) { described_class.new(current_user: user) }

  describe '#commands' do
    subject(:commands) { glab_setup.commands }

    context 'when the GitLab URL uses the default HTTPS port' do
      before do
        allow(Gitlab.config.gitlab).to receive(:url).and_return('https://gitlab.example.com')
      end

      it 'installs the configured glab version' do
        archive = "glab_#{described_class::VERSION}_${GLAB_OS}_${GLAB_ARCH}.tar.gz"

        expect(commands).to include(a_string_including("Installing glab@#{described_class::VERSION}"))
        expect(commands).to include(a_string_including(archive))
      end

      it 'puts the glab binary on PATH and verifies the install' do
        expect(commands).to include(%(export PATH="#{described_class::GLAB_BIN_DIR}:$PATH"))
        expect(commands).to include(%(which glab || echo "glab not in PATH"))
        expect(commands).to include(a_string_starting_with('glab version || echo "glab not working.'))
      end

      it 'guards the install against silent failures' do
        install = commands.find { |c| c.include?("Installing glab@") }

        expect(install).to start_with('if command -v glab')
        expect(install).to include('set -o pipefail')
        expect(install).to include('curl --silent --show-error --fail --location')
        expect(install).to include('*) echo "Unsupported architecture: $GLAB_ARCH" >&2; exit 1 ;;')
      end

      it 'does not halt the runner if the install itself fails' do
        install = commands.find { |c| c.include?("Installing glab@") }

        expect(install).to include(
          %{) || echo "Warning: glab installation failed; continuing without glab" >&2}
        )
      end

      it 'writes a glab config for the GitLab host without an explicit port' do
        config = commands.find { |c| c.include?('<<GLAB_CONFIG') }

        expect(config).to include('api_host: gitlab.example.com')
        expect(config).to include('api_protocol: https')
        expect(config).to include('git_protocol: https')
        expect(config).to include("user: #{user.username}")
        expect(config).not_to include('gitlab.example.com:443')
      end

      it 'does not embed a static auth token field in the config' do
        config = commands.find { |c| c.include?('<<GLAB_CONFIG') }

        # Anchored to avoid colliding with `oauth2_refresh_token:`, which is
        # a deliberately empty placeholder (see config_file_command).
        expect(config).not_to match(/^\s*token:/)
      end

      it 'creates the config directory and locks down config file permissions' do
        expect(commands).to include('mkdir -p ~/.config/glab-cli')
        expect(commands).to include('chmod 600 ~/.config/glab-cli/config.yml')
      end

      it 'orders install steps before configuration steps before skills install' do
        install_idx = commands.index { |c| c.include?("Installing glab@") }
        config_dir_idx = commands.index('mkdir -p ~/.config/glab-cli')
        chmod_idx = commands.index('chmod 600 ~/.config/glab-cli/config.yml')
        skills_idx = commands.index { |c| c.include?('glab skills install') }

        expect(install_idx).to be < config_dir_idx
        expect(config_dir_idx).to be < chmod_idx
        expect(chmod_idx).to be < skills_idx
      end

      it 'installs glab skills globally' do
        skills_cmd = commands.find { |c| c.include?('glab skills install') }

        expected = 'glab skills install --global || echo "Warning: glab skills install failed; ' \
          'continuing without glab skills"'
        expect(skills_cmd).to eq(expected)
      end
    end

    context 'when the GitLab URL includes a non-default port' do
      before do
        allow(Gitlab.config.gitlab).to receive(:url).and_return('http://gitlab.example.com:3000')
      end

      it 'includes the port in the configured host and uses the matching protocol' do
        config = commands.find { |c| c.include?('<<GLAB_CONFIG') }

        expect(config).to include('api_host: gitlab.example.com:3000')
        expect(config).to include('api_protocol: http')
        expect(config).to include('git_protocol: http')
      end
    end
  end
end
