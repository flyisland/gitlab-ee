# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::GitalyClient::CommitService, feature_category: :gitaly do
  let(:repository) { instance_double(Gitlab::Git::Repository, container: container, gitaly_repository: nil) }
  let(:client) { described_class.new(repository) }

  describe '#single_file_lookahead?' do
    subject(:lookahead) { client.send(:single_file_lookahead?) }

    [:personal_snippet, :project_snippet].each do |snippet_type|
      context "when the container is a #{snippet_type}" do
        let(:container) { build_stubbed(snippet_type) }

        it 'uses the enabled global flag without rejecting the snippet as an actor' do
          expect(lookahead).to be(true)
        end

        context 'when the global flag is disabled' do
          before do
            stub_feature_flags(diff_stitcher_single_file_lookahead: false)
          end

          it 'disables look-ahead' do
            expect(lookahead).to be(false)
          end
        end

        context 'when the flag is enabled only for a project' do
          before do
            stub_feature_flags(diff_stitcher_single_file_lookahead: build_stubbed(:project))
          end

          it 'keeps look-ahead disabled for the snippet' do
            expect(lookahead).to be(false)
          end
        end
      end
    end

    context 'when the container is a project' do
      let(:container) { build_stubbed(:project) }

      it 'enables look-ahead by default' do
        expect(lookahead).to be(true)
      end

      context 'when the global flag is disabled' do
        before do
          stub_feature_flags(diff_stitcher_single_file_lookahead: false)
        end

        it 'disables look-ahead' do
          expect(lookahead).to be(false)
        end
      end

      context 'when the flag is enabled only for the project' do
        before do
          stub_feature_flags(diff_stitcher_single_file_lookahead: container)
        end

        it 'preserves the upstream project-scoped flag behavior' do
          expect(lookahead).to be(true)
        end
      end

      context 'when the flag is enabled only for another project' do
        before do
          stub_feature_flags(diff_stitcher_single_file_lookahead: build_stubbed(:project))
        end

        it 'keeps look-ahead disabled for this project' do
          expect(lookahead).to be(false)
        end
      end
    end
  end
end
