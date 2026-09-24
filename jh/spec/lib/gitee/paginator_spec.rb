# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitee::Paginator do
  let(:headers) { { 'total_page' => 2 } }
  let(:response) { {} }
  let(:last_page) { instance_double(Gitee::Page, has_next_page?: false, items: ['item_2']) }
  let(:first_page) { instance_double(Gitee::Page, has_next_page?: true, items: ['item_1']) }

  before do
    allow(response).to receive(:headers).and_return(headers)
  end

  describe '#initialize' do
    it 'initializes the paginator' do
      paginator = described_class.new(nil, nil, nil, {})
      expect(paginator.send(:connection)).to be_nil
      expect(paginator.send(:type)).to be_nil
      expect(paginator.send(:url)).to be_nil
      expect(paginator.send(:page)).to be_nil
    end
  end

  describe '#items' do
    it 'returns items and raises StopIteration in the end' do
      paginator = described_class.new(nil, nil, nil, {})

      allow(paginator).to receive(:fetch_next_page).and_return(first_page)
      expect(paginator.items).to match(['item_1'])

      allow(paginator).to receive(:fetch_next_page).and_return(last_page)
      expect(paginator.items).to match(['item_2'])

      allow(paginator).to receive(:fetch_next_page).and_return(nil)
      expect { paginator.items }.to raise_error(StopIteration)
    end
  end

  describe '#next_page' do
    context 'when page is nil' do
      it 'returns 1' do
        paginator = described_class.new(nil, nil, nil, {})
        expect(paginator.send(:next_page)).to eq(1)
      end
    end

    context 'when page is not nil' do
      let(:page) { instance_double(Gitee::Page, current_page: 1) }
      let(:paginator) { described_class.new(nil, nil, nil, {}) }

      before do
        allow(paginator).to receive(:page).and_return(page)
      end

      it 'returns next page of current page' do
        expect(paginator.send(:next_page)).to eq(2)
      end
    end
  end

  describe '#fetch_next_page' do
    let(:connection) { instance_double(Gitee::Connection, get: 'response') }

    it 'calls get method of connection' do
      paginator = described_class.new(connection, nil, :user, {})
      expect(connection).to receive(:get)
      expect(Gitee::Page).to receive(:new).with('response', :user, 1)

      paginator.send(:fetch_next_page)
    end
  end
end
