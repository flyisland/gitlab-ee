# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ligaai::Query do
  let(:ligaai_integration) { create(:ligaai_integration) }
  let(:params) { {} }

  subject(:query) { described_class.new(ligaai_integration, ActionController::Parameters.new(params)) }

  describe '#issues' do
    let(:response) do
      ["0", {
        "list" => [
          { "id" => 90959637, "summary" => "content 01" },
          { "id" => 90959639, "summary" => "content 02" }
        ],
        "total" => 2
      }]
    end

    def expect_query_option_include(expected_params)
      expect_next_instance_of(Gitlab::Ligaai::Client) do |client|
        expect(client).to receive(:fetch_issues)
          .with(expected_params)
          .and_return(response)
      end

      query.issues
    end

    context 'when params are empty' do
      it 'fills default params' do
        expect_query_option_include(orderBy: "updateTime", pageNumber: 1, pageSize: 20, sort: "DESC",
          statusTypes: [2, 3], summary: "")
      end
    end

    context 'when params contain valid options' do
      let(:params) { { state: 'closed', sort: 'created_asc', labels: %w[Bugs Features] } }

      it 'fills params with standard of LigaAI' do
        expect_query_option_include(orderBy: "createTime", pageNumber: 1, pageSize: 20, sort: "ASC", statusTypes: [4],
          summary: "")
      end
    end

    context 'when params contain invalid options' do
      let(:params) { { state: 'xxx', sort: 'xxx', labels: %w[xxx] } }

      it 'fills default params with standard of LigaAI' do
        expect_query_option_include(orderBy: "updateTime", pageNumber: 1, pageSize: 20, sort: "DESC",
          statusTypes: [2, 3], summary: "")
      end
    end
  end

  describe '#issue' do
    let(:response) do
      ["0",
        { "data" => {
          "comments" => [{ "commentId" => 90959637, "content" => "comment 01" },
            { "commentId" => 90959639,
              "content" => "comment 02" }], "id" => "88551213", "summary" => "This is a test issue"
        } }]
    end

    it 'returns issue object by client' do
      expect_next_instance_of(Gitlab::Ligaai::Client) do |client|
        expect(client).to receive(:fetch_issue)
          .and_return(response)
      end

      expect(query.issue).to include('id' => '88551213')
    end
  end
end
