# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::RetentionPolicy, feature_category: :database do
  describe 'schema exclusions' do
    it 'preserves upstream exclusions and excludes the JH schema' do
      expect(described_class::EXCLUDED_SCHEMAS).to include('gitlab_geo', 'gitlab_main_jh', 'gitlab_jh')
    end
  end

  describe '.eligible_tables' do
    it 'excludes tables from the JH schema' do
      jh_tables = Gitlab::Database::Dictionary.entries.select { |table| table.gitlab_schema == 'gitlab_jh' }

      expect(jh_tables).not_to be_empty
      expect(described_class.eligible_tables).not_to include(*jh_tables)
    end
  end
end
