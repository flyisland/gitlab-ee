# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ligaai::Client do
  subject(:client) { described_class.new(ligaai_integration) }

  let(:ligaai_integration) { create(:ligaai_integration) }
  let(:mock_headers) do
    {
      headers: {
        'Content-Type' => 'application/json',
        'accessToken' => ligaai_access_token
      }
    }
  end

  let(:ligaai_access_token) { 'ligaai_access_token' }

  def mock_get_project_url
    client.send(:url, "project/get?projectId=#{ligaai_integration.project_key}")
  end

  def mock_fetch_issues_url
    client.send(:url, "issue/page")
  end

  def mock_fetch_issue_url(issue_id)
    client.send(:url, "issue/get?id=#{issue_id}")
  end

  def mock_fetch_comments_url
    client.send(:url, "comment/page")
  end

  before do
    stub_request(:post, ::Gitlab::Ligaai::Client::ACCESS_TOKEN_ENDPOINT)
      .with(
        body: Gitlab::Json.generate({ clientId: ligaai_integration.user_key, secretKey: ligaai_integration.api_token }),
        headers: {
          'Content-Type' => 'application/json; charset=utf-8'
        })
      .to_return(
        status: 200,
        body: Gitlab::Json.generate({ code: '0', data: { accessToken: ligaai_access_token, expireIn: 1000 } }),
        headers: {})
  end

  describe '#fetch_project' do
    context 'with valid project' do
      let(:mock_response) { ['0', { 'id' => ligaai_integration.project_key }] }

      before do
        stub_request(:get, mock_get_project_url)
          .with(mock_headers)
          .to_return(
            status: 200,
            body: Gitlab::Json.generate({
              code: '0',
              data: { id: ligaai_integration.project_key }
            }), headers: {})
      end

      it 'fetches the project' do
        expect(client.fetch_project(ligaai_integration.project_key)).to eq mock_response
      end
    end

    context 'with invalid project' do
      before do
        stub_request(:get, mock_get_project_url)
          .with(mock_headers)
          .to_return(
            status: 200,
            body: Gitlab::Json.generate({
              code: '4',
              data: {}
            }), headers: {})
      end

      it 'fetches the empty project' do
        expect do
          client.fetch_project(ligaai_integration.project_key)
        end.to raise_error(Gitlab::HTTP::Error)
      end
    end

    context 'with invalid response' do
      before do
        stub_request(:get, mock_get_project_url)
          .with(mock_headers)
          .to_return(
            status: 404,
            body: {}.to_json)
      end

      it 'fetches the empty project' do
        expect do
          client.fetch_project(ligaai_integration.project_key)
        end.to raise_error(Gitlab::HTTP::Error)
      end
    end
  end

  describe '#ping' do
    context 'with valid resource' do
      before do
        stub_request(:get, mock_get_project_url)
          .with(mock_headers)
          .to_return(
            status: 200,
            body: Gitlab::Json.generate({
              code: '0',
              data: { id: ligaai_integration.project_key }
            }), headers: {})
      end

      it 'responds with success' do
        expect(client.ping[:success]).to be true
      end
    end
  end

  describe '#fetch_issues' do
    let(:issues) do
      {
        total: 2,
        list: [
          { summary: 'issue 01', id: 91058478 },
          { summary: 'issue 02', id: 88551213 }
        ]
      }
    end

    let(:mock_response) { ['0', Gitlab::Json.generate(issues)] }

    before do
      headers = mock_headers.merge({
        body: Gitlab::Json.generate({ projectId: ligaai_integration.project_key })
      })
      stub_request(:post, mock_fetch_issues_url)
        .with(headers)
        .to_return(
          status: 200,
          body: Gitlab::Json.generate({ code: '0', data: Gitlab::Json.generate(issues) }),
          headers: {})
    end

    it 'returns the response' do
      expect(client.fetch_issues).to eq(mock_response)
    end
  end

  describe '#fetch_issue' do
    context 'with invalid id' do
      let(:invalid_issue_id) { 'abc1234' }

      it 'raises Error' do
        expect { client.fetch_issue(invalid_issue_id) }
          .to raise_error(Gitlab::Ligaai::Client::Error, 'invalid issue id')
      end
    end

    context 'with valid id' do
      let(:valid_issue_id) { '88551213' }
      let(:comments) do
        {
          total: 2,
          list: [
            { content: 'comment 01', commentId: 90959637 },
            { content: 'comment 02', commentId: 90959639 }
          ]
        }
      end

      before do
        stub_request(:get, mock_fetch_issue_url(valid_issue_id))
          .with(mock_headers)
          .to_return(
            status: 200,
            body: Gitlab::Json.generate({
              code: '0',
              data: { data: { id: valid_issue_id, summary: 'This is a test issue' } }
            }), headers: {})

        headers = mock_headers.merge({
          body: Gitlab::Json.generate({
            commentModule: "issue",
            linkId: valid_issue_id,
            pageNumber: 1,
            pageSize: 20
          })
        })
        stub_request(:post, mock_fetch_comments_url)
          .with(headers)
          .to_return(
            status: 200,
            body: Gitlab::Json.generate({ code: '0', data: comments }),
            headers: {})
      end

      it 'fetches the issue' do
        expect(client.fetch_issue(valid_issue_id)).to eq(["0",
          { "data" =>
            { "comments" =>
              [{ "commentId" => 90959637, "content" => "comment 01" },
                { "commentId" => 90959639, "content" => "comment 02" }],
              "id" => "88551213",
              "summary" => "This is a test issue" } }])
      end
    end
  end

  describe '#url' do
    context 'with api url' do
      shared_examples 'joins api_url correctly' do
        it 'verify url' do
          expect(client.send(:url, "project/1").to_s)
            .to eq("https://api.ligaai.net/v3/project/1")
        end
      end

      context 'when no ends slash' do
        let(:ligaai_integration) { create(:ligaai_integration, api_url: 'https://api.ligaai.net/v3') }

        include_examples 'joins api_url correctly'
      end

      context 'when ends slash' do
        let(:ligaai_integration) { create(:ligaai_integration, api_url: 'https://api.ligaai.net/v3/') }

        include_examples 'joins api_url correctly'
      end
    end

    context 'without api url' do
      let(:ligaai_integration) { create(:ligaai_integration, url: 'https://demo.ligaai.cn') }

      it 'joins url correctly' do
        expect(client.send(:url, "project/1").to_s)
          .to eq("https://demo.ligaai.cn/openapi/api/project/1")
      end
    end
  end
end
