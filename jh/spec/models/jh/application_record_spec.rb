# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::ApplicationRecord, feature_category: :database do
  describe '.table_name_prefix' do
    it 'removes the prefix' do
      expect(described_class.table_name_prefix).to eq 'jh_'
    end
  end

  describe '.model_name' do
    subject(:jh_record) { described_class.model_name }

    it 'removes the prefix' do
      expect(jh_record.collection).to eq 'application_records'
    end
  end
end
