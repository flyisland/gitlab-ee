# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::RunnerInstructions, feature_category: :runner_fleet do
  using RSpec::Parameterized::TableSyntax

  describe '#install_script' do
    subject { described_class.new(**params) }

    context 'with valid params' do
      where(:os, :arch) do
        'linux'   | 'amd64'
        'linux'   | '386'
        'linux'   | 'arm'
        'linux'   | 'arm64'
        'windows' | 'amd64'
        'windows' | '386'
        'osx'     | 'amd64'
        'osx'     | 'arm64'
      end

      with_them do
        let(:params) { { os: os, arch: arch } }

        around do |example|
          # puma in production does not run from Rails.root, ensure file loading does not assume this
          Dir.chdir(Rails.root.join('tmp').to_s) do
            example.run
          end
        end

        it 'returns string containing correct params' do
          result = subject.install_script

          expect(result).to be_a(String)
          expect(result).to include('gitlab-runner-downloads.gitlab.cn')

          if os == 'osx'
            expect(result).to include("darwin-#{arch}")
          else
            expect(result).to include("#{os}-#{arch}")
          end
        end
      end
    end
  end
end
