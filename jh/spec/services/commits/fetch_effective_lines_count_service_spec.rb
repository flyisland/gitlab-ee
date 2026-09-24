# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Commits::FetchEffectiveLinesCountService, feature_category: :source_code_management do
  let(:project) { instance_double(Project, full_path: 'gitlab-org/gitlab') }
  let(:stats) { instance_double(::Gitlab::Git::CommitStats, additions: 10, deletions: 4) }
  let(:diff_1_data) { Struct.new(:diff).new('diff-1') }
  let(:diff_2_data) { Struct.new(:diff).new('diff-2') }
  let(:diff_file_1_data) { Struct.new(:diff).new(diff_1_data) }
  let(:diff_file_2_data) { Struct.new(:diff).new(diff_2_data) }
  let(:diff_file_1) { object_double(diff_file_1_data, diff: diff_file_1_data.diff) }
  let(:diff_file_2) { object_double(diff_file_2_data, diff: diff_file_2_data.diff) }
  let(:diffs_data) { Struct.new(:diff_files).new([diff_file_1, diff_file_2]) }
  let(:diffs) { object_double(diffs_data, diff_files: diffs_data.diff_files) }
  let(:commit) do
    instance_double(
      ::Gitlab::Git::Commit,
      id: 'abc123',
      author_name: 'Test Author',
      author_email: 'author@example.com',
      committed_date: Date.parse('2026-06-08'),
      stats: stats,
      diffs: diffs
    )
  end

  let(:counter_1) { instance_double(::Gitlab::Analytics::EffectiveLines::Counter, additions: 1, deletions: 0) }
  let(:counter_2) { instance_double(::Gitlab::Analytics::EffectiveLines::Counter, additions: 2, deletions: 1) }

  subject(:execute_service) { described_class.new(project, commit).execute }

  before do
    allow(::Gitlab::Analytics::EffectiveLines::Counter).to receive(:new).with('diff-1').and_return(counter_1)
    allow(::Gitlab::Analytics::EffectiveLines::Counter).to receive(:new).with('diff-2').and_return(counter_2)
  end

  describe '#execute' do
    it 'returns the commit information' do
      expect(execute_service).to eq({
        id: commit.id,
        author_name: commit.author_name,
        author_email: commit.author_email,
        date: commit.committed_date.to_date.iso8601,
        additions: commit.stats.additions,
        deletions: commit.stats.deletions,
        effective_additions: 3,
        effective_deletions: 1
      })
    end

    it 'caches the result', :use_clean_rails_redis_caching do
      cache_key = "commit_effective_lines-#{project.full_path}-#{commit.id}"

      expect { execute_service }.to change { Rails.cache.fetch(cache_key) }

      described_class.new(project, commit).execute

      expect(::Gitlab::Analytics::EffectiveLines::Counter).to have_received(:new).twice
    end
  end
end
