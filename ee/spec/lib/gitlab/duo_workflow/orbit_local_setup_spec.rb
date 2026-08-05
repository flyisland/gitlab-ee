# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::DuoWorkflow::OrbitLocalSetup, feature_category: :duo_agent_platform do
  let_it_be(:user) { create(:user) }

  subject(:orbit_local_setup) { described_class.new(current_user: user) }

  describe '#commands' do
    subject(:commands) { orbit_local_setup.commands }

    context 'when duo_developer_orbit is enabled and orbit is enabled for the user' do
      before do
        stub_feature_flags(duo_developer_orbit: user)
        allow(::Ai::Orbit::Settings).to receive(:killswitch_on?).with(user).and_return(true)
      end

      it 'returns install and index commands' do
        expect(commands.length).to eq(2)
      end

      it 'installs orbit local without prompts' do
        expect(commands.first).to include('glab orbit local --install --yes')
      end

      it 'indexes the current directory without prompts', :aggregate_failures do
        expect(commands.second).to include('[ -x "$HOME/.config/glab-cli/bin/orbit" ]')
        expect(commands.second).to include('glab orbit local --yes index .')
      end

      it 'includes fallback warnings for both commands' do
        expect(commands).to all(include('Warning:'))
      end
    end

    context 'when duo_developer_orbit is disabled' do
      before do
        stub_feature_flags(duo_developer_orbit: false)
      end

      it 'returns no commands' do
        expect(commands).to be_empty
      end
    end

    context 'when orbit is disabled for the user' do
      before do
        stub_feature_flags(duo_developer_orbit: user)
        allow(::Ai::Orbit::Settings).to receive(:killswitch_on?).with(user).and_return(false)
      end

      it 'returns no commands' do
        expect(commands).to be_empty
      end
    end
  end
end
