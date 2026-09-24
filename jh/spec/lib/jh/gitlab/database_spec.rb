# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database, feature_category: :database do
  describe '.db_config_names' do
    using RSpec::Parameterized::TableSyntax

    where(:configs_for, :gitlab_schema, :expected) do
      %i[main jh] | nil | %i[main jh]
      %i[main jh] | :gitlab_internal | %i[main jh]
      %i[main jh] | :gitlab_shared | %i[main] # jh does not have `gitlab_shared`
      %i[main jh] | :gitlab_jh | %i[jh]
    end

    with_them do
      before do
        skip_if_multiple_databases_not_setup(:jh)

        hash_configs = configs_for.map do |x|
          instance_double(ActiveRecord::DatabaseConfigurations::HashConfig, name: x)
        end
        allow(::ActiveRecord::Base).to receive(:configurations).and_return(
          instance_double(ActiveRecord::DatabaseConfigurations, configs_for: hash_configs)
        )
      end

      it do
        expect(described_class.db_config_names(with_schema: gitlab_schema))
          .to eq(expected)
      end
    end
  end
end
