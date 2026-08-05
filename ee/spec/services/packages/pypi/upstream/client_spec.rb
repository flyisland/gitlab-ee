# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Packages::Pypi::Upstream::Client, feature_category: :package_registry do
  let(:client) { described_class.new }
  let(:base_url) { 'https://pypi.org/simple/' }
  let(:url) { 'https://pypi.org/simple/requests/' }
  let(:accept) { 'application/vnd.pypi.simple.v1+json' }
  let(:valid_body) do
    {
      'meta' => { 'api-version' => '1.0' },
      'name' => 'requests',
      'files' => [
        { 'filename' => 'requests-2.31.0.tar.gz', 'url' => 'https://files.pythonhosted.org/x/requests-2.31.0.tar.gz',
          'hashes' => { 'sha256' => 'aaa' } },
        { 'filename' => 'requests-2.31.0-py3-none-any.whl', 'url' => 'https://files.pythonhosted.org/y/requests-2.31.0-py3-none-any.whl', 'hashes' => { 'sha256' => 'bbb' } }
      ]
    }.to_json
  end

  subject(:result) { client.fetch_simple('requests', base_url: base_url) }

  context 'with a valid 200 response' do
    before do
      stub_request(:get, url).to_return(status: 200, body: valid_body)
    end

    it 'returns success with the files array', :aggregate_failures do
      expect(result).to be_success
      expect(result.payload[:files].size).to eq(2)
      expect(result.payload[:files].first).to include('filename' => 'requests-2.31.0.tar.gz')
    end

    it 'requests the normalized URL with the PEP 691 Accept header' do
      result
      expect(a_request(:get, url).with(headers: { 'Accept' => accept })).to have_been_made
    end
  end

  context 'with 200 but missing files key' do
    before do
      stub_request(:get, url).to_return(status: 200, body: { 'name' => 'requests' }.to_json)
    end

    it 'returns error with malformed reason', :aggregate_failures do
      expect(result).to be_error
      expect(result.reason).to eq(:malformed)
    end
  end

  context 'with 200 but a null JSON body' do
    before do
      stub_request(:get, url).to_return(status: 200, body: 'null')
    end

    it 'returns error with malformed reason instead of raising NoMethodError', :aggregate_failures do
      expect(result).to be_error
      expect(result.reason).to eq(:malformed)
    end
  end

  context 'with 200 but non-JSON body' do
    before do
      stub_request(:get, url).to_return(status: 200, body: '<html></html>')
    end

    it { expect(result.reason).to eq(:malformed) }
  end

  context 'with 404' do
    before do
      stub_request(:get, url).to_return(status: 404)
    end

    it { expect(result.reason).to eq(:not_found) }
  end

  context 'with 500' do
    before do
      stub_request(:get, url).to_return(status: 500)
    end

    it 'returns upstream_failure with a message', :aggregate_failures do
      expect(result.reason).to eq(:upstream_failure)
      expect(result.message).to be_present
    end
  end

  context 'when the connection times out' do
    before do
      stub_request(:get, url).to_raise(Net::ReadTimeout)
    end

    it { expect(result.reason).to eq(:upstream_failure) }
  end

  context 'when the URL is blocked' do
    before do
      stub_request(:get, url).to_raise(Gitlab::HTTP_V2::BlockedUrlError)
    end

    it { expect(result.reason).to eq(:upstream_failure) }
  end
end
