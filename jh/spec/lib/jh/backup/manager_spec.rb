# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Backup::Manager, feature_category: :backup_restore do
  include StubENV

  let(:progress) { StringIO.new }
  let(:backup_tasks) { nil }
  let(:options) { build(:backup_options, :skip_none) }

  subject(:backup_manager) { described_class.new(progress, backup_tasks: backup_tasks) }

  before do
    # Rspec fails with `uninitialized constant RSpec::Support::Differ` when it
    # is trying to display a diff and `File.exist?` is stubbed. Adding a
    # default stub fixes this.
    allow(File).to receive(:exist?).and_call_original
    allow(FileUtils).to receive(:rm_rf).and_call_original

    allow(progress).to receive(:puts)
    allow(progress).to receive(:print)
  end

  def backup_path
    Pathname(Gitlab.config.backup.path)
  end

  describe '#create' do
    let(:incremental_env) { 'false' }
    let(:expected_backup_contents) { %w[backup_information.yml lfs.tar.gz pages.tar.gz] }
    let(:backup_time) { Time.zone.parse('2019-1-1') }
    let(:backup_id) { "1546300800_2019_01_01_#{Gitlab::VERSION}" }
    let(:pack_tar_file) { "#{backup_id}_gitlab_backup.tar" }

    let(:lfs) { Backup::Tasks::Lfs.new(progress: progress, options: options) }
    let(:pages) { Backup::Tasks::Pages.new(progress: progress, options: options) }
    let(:backup_tasks) { { 'lfs' => lfs, 'pages' => pages } }

    before do
      stub_env('INCREMENTAL', incremental_env)
      allow(ApplicationRecord.connection).to receive(:reconnect!)
      allow(Gitlab::BackupLogger).to receive(:info)
    end

    context 'when BACKUP is set' do
      let(:backup_id) { 'custom' }

      before do
        stub_env('BACKUP', '/ignored/path/custom')
      end

      context 'with many backup files' do
        let(:file_with_jh_tag) { '1451520000_2015_12_31_4.5.6-pre-jh_gitlab_backup.tar' }

        before do
          allow(Gitlab::BackupLogger).to receive(:info)
          FileUtils.touch(backup_path.join(file_with_jh_tag))
          allow(Open3).to receive(:pipeline).and_return(
            [instance_double(Process::Status, success?: true, exitstatus: 0)]
          )
          allow(FileUtils).to receive(:rm)
          allow(Time).to receive(:now).and_return(Time.zone.parse('2016-1-1'))
        end

        context 'when keep_time is set to remove files' do
          before do
            # Set to 1 second
            allow(Gitlab.config.backup).to receive(:keep_time).and_return(1)

            backup_manager.create
          end

          it 'removes matching files with a human-readable versioned timestamp with tagged JH' do
            expect(FileUtils).to have_received(:rm).with(file_with_jh_tag)
          end
        end
      end
    end
  end
end
