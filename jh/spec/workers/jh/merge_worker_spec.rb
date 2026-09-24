# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeWorker, feature_category: :source_code_management do
  describe "#perform'" do
    let!(:merge_request) { create(:merge_request) }
    let!(:source_project) { merge_request.source_project }
    let!(:project) { merge_request.project }
    let!(:author) { merge_request.author }

    before do
      source_project.add_maintainer(author)
    end

    it "calls ::MergeRequests::MonorepoService.try_cancel_lease_if_possible!", :sidekiq_inline do
      expect(::MergeRequests::MonorepoService).to receive(
        :try_cancel_lease_if_possible!
      ).with(merge_request.id).and_call_original

      described_class.new.perform(merge_request.id, merge_request.author_id, commit_message: 'wow such merge')
    end
  end
end
