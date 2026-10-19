# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'jh/config/initializers/ai_catalog_migration_tasks.rb', feature_category: :workflow_catalog do
  let(:db_migrate) { instance_double(Rake::Task) }
  let(:db_migrate_main) { instance_double(Rake::Task) }
  let(:seeder) { instance_double(Gitlab::Ai::Catalog::ThirdPartyFlows::Seeder) }
  let(:enhancements) { {} }

  before do
    allow(Rake::Task).to receive(:task_defined?).and_return(true)
    allow(Rake::Task).to receive(:[]).with('db:migrate').and_return(db_migrate)
    allow(Rake::Task).to receive(:[]).with('db:migrate:main').and_return(db_migrate_main)
    allow(db_migrate).to receive(:enhance) { |&block| enhancements['db:migrate'] = block }
    allow(db_migrate_main).to receive(:enhance) { |&block| enhancements['db:migrate:main'] = block }
    allow(Gitlab::Ai::Catalog::ThirdPartyFlows::Seeder).to receive(:new).and_return(seeder)
    allow(seeder).to receive(:seed_missing_agents!)

    load Rails.root.join('jh/config/initializers/ai_catalog_migration_tasks.rb')
  end

  it 'syncs missing agents after each main database migration task' do
    enhancements.each_value(&:call)

    expect(seeder).to have_received(:seed_missing_agents!).twice
  end

  context 'when post-deployment migrations are skipped' do
    before do
      stub_env('SKIP_POST_DEPLOYMENT_MIGRATIONS', 'true')
    end

    it 'defers syncing missing agents' do
      enhancements.each_value(&:call)

      expect(seeder).not_to have_received(:seed_missing_agents!)
    end
  end
end
