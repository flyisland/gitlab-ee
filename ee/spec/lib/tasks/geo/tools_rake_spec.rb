# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'geo:tools rake tasks', feature_category: :geo_replication do
  include RakeHelpers

  before_all do
    Rake.application.rake_require 'tasks/geo/tools'
    Rake::Task.define_task(:gitlab_environment)
  end

  describe 'geo:tools:cleanup_check' do
    it 'delegates to Gitlab::Geo::Tools.cleanup_check' do
      expect(Gitlab::Geo::Tools).to receive(:cleanup_check)

      run_rake_task('geo:tools:cleanup_check')
    end
  end

  describe 'geo:tools:resolve' do
    let(:known_error) { instance_double(Geo::Tools::KnownError) }

    before do
      allow(Geo::Tools::KnownErrors).to receive(:find).with('url_blocked').and_return(known_error)
    end

    it 'finds the error and delegates to the module, dry run by default' do
      expect(Gitlab::Geo::Tools).to receive(:resolve).with(known_error, dry_run: true, limit: nil)

      run_rake_task('geo:tools:resolve', 'url_blocked')
    end

    it 'passes dry_run: false when DRY_RUN=false' do
      stub_env('DRY_RUN', 'false')

      expect(Gitlab::Geo::Tools).to receive(:resolve).with(known_error, dry_run: false, limit: nil)

      run_rake_task('geo:tools:resolve', 'url_blocked')
    end

    it 'passes LIMIT as an integer' do
      stub_env('LIMIT', '10')

      expect(Gitlab::Geo::Tools).to receive(:resolve).with(known_error, dry_run: true, limit: 10)

      run_rake_task('geo:tools:resolve', 'url_blocked')
    end

    it 'aborts when LIMIT is not a number' do
      stub_env('LIMIT', 'abc')

      expect(Gitlab::Geo::Tools).not_to receive(:resolve)

      expect { run_rake_task('geo:tools:resolve', 'url_blocked') }
        .to raise_error(SystemExit, /LIMIT must be a positive integer/)
    end

    it 'aborts when LIMIT is zero' do
      stub_env('LIMIT', '0')

      expect(Gitlab::Geo::Tools).not_to receive(:resolve)

      expect { run_rake_task('geo:tools:resolve', 'url_blocked') }
        .to raise_error(SystemExit, /LIMIT must be a positive integer/)
    end

    it 'aborts when LIMIT is negative' do
      stub_env('LIMIT', '-5')

      expect(Gitlab::Geo::Tools).not_to receive(:resolve)

      expect { run_rake_task('geo:tools:resolve', 'url_blocked') }
        .to raise_error(SystemExit, /LIMIT must be a positive integer/)
    end

    context 'with an unknown key' do
      before do
        allow(Geo::Tools::KnownErrors).to receive(:find).with('nope').and_return(nil)
      end

      it 'aborts without calling the module' do
        expect(Gitlab::Geo::Tools).not_to receive(:resolve)

        expect { run_rake_task('geo:tools:resolve', 'nope') }
          .to raise_error(SystemExit, /Unknown error key/)
      end
    end
  end
end
