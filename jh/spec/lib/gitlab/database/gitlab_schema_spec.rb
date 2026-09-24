# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::GitlabSchema, feature_category: :database do
  shared_examples 'maps table name to table schema' do
    using RSpec::Parameterized::TableSyntax

    where(:name, :classification) do
      '_test_gitlab_jh_table' | :gitlab_jh
    end

    with_them do
      it { is_expected.to eq(classification) }
    end
  end

  describe '.table_schema' do
    subject { described_class.table_schema(name) }

    it_behaves_like 'maps table name to table schema'
  end

  describe '.table_schema!' do
    subject { described_class.table_schema!(name) }

    it_behaves_like 'maps table name to table schema'
  end
end
