# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DiffFileEntity do
  let_it_be(:project) { create(:project, :repository, :public) }

  let(:repository) { project.repository }
  let(:commit) { project.repository.commit }
  let(:blob) { commit.diffs.diff_files.first.blob }
  let(:diff_refs) { commit.diff_refs }
  let(:diff) { commit.raw_diffs.first }
  let(:diff_file) { Gitlab::Diff::File.new(diff, diff_refs: diff_refs, repository: repository) }
  let(:options) { {} }
  let(:entity) { described_class.new(diff_file, options.reverse_merge(request: {})) }

  subject { entity.as_json }

  context "in content validation" do
    context 'with blocked commit diff file' do
      let(:options) { { commit: commit } }
      let!(:content_blocked_state) do
        create(:content_blocked_state, container: project, commit_sha: commit.id, path: blob.path)
      end

      before do
        allow(ContentValidation::Setting).to receive(:block_enabled?).and_return(true)
      end

      it "exposes content blocked state" do
        expect(subject).to include(:content_blocked_state)
        expect(subject[:content_blocked_state][:id]).to eq(content_blocked_state.id)
      end
    end
  end
end
