# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Admin updates search settings', :js, :elastic_delete_by_query, :with_current_organization,
  :request_store, :enable_admin_mode, feature_category: :global_search do
  include Features::SettingsHelpers
  include Spec::Support::Helpers::ModalHelpers
  include ListboxHelpers

  let_it_be(:admin) { create(:admin) }
  let_it_be(:default_organization) { create(:organization) }

  let(:elastic_search_license) { true }

  let(:task) do
    create(:elastic_reindexing_task).tap do |task|
      allow(task).to receive_messages(in_progress?: false, error_message: nil, state: "indexing_paused")
    end
  end

  let(:subtask) do
    create(:elastic_reindexing_subtask, documents_count: 0, documents_count_target: 0, reindexing_task: task)
  end

  before do
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
    sign_in(admin)
    allow(License).to receive(:feature_available?).and_return(true)
    allow(Organizations::Organization).to receive(:default_organization).and_return(default_organization)
    stub_licensed_features(elastic_search: elastic_search_license)
    allow(::Search::Elastic::ReindexingTask).to receive(:last).and_return(task)
    visit search_admin_application_settings_path
  end

  it 'changes advanced search settings' do
    within_testid('elasticsearch-settings') do
      check 'Turn on indexing for advanced search'
      check 'Search with advanced search'

      fill_in 'application_setting_elasticsearch_shards[gitlab-test]', with: '120'
      fill_in 'application_setting_elasticsearch_replicas[gitlab-test]', with: '2'
      fill_in 'application_setting_elasticsearch_shards[gitlab-test-notes]', with: '20'
      fill_in 'application_setting_elasticsearch_replicas[gitlab-test-notes]', with: '4'
      fill_in 'application_setting_elasticsearch_shards[gitlab-test-merge_requests]', with: '15'
      fill_in 'application_setting_elasticsearch_replicas[gitlab-test-merge_requests]', with: '5'
      fill_in 'application_setting_elasticsearch_shards[gitlab-test-commits]', with: '25'
      fill_in 'application_setting_elasticsearch_replicas[gitlab-test-commits]', with: '6'

      fill_in 'Maximum file size indexed (KiB)', with: '5000'
      fill_in 'Maximum field length', with: '100000'
      fill_in 'Maximum bulk request size (MiB)', with: '17'
      fill_in 'Bulk request concurrency', with: '23'
      fill_in 'Client request timeout', with: '30'
    end

    expect_save_settings('elasticsearch-settings')

    aggregate_failures do
      expect(current_settings.elasticsearch_indexing).to be_truthy
      expect(current_settings.elasticsearch_search).to be_truthy

      expect(current_settings.elasticsearch_shards).to eq(120)
      expect(current_settings.elasticsearch_replicas).to eq(2)
      expect(Elastic::IndexSetting['gitlab-test'].number_of_shards).to eq(120)
      expect(Elastic::IndexSetting['gitlab-test'].number_of_replicas).to eq(2)
      expect(Elastic::IndexSetting['gitlab-test-notes'].number_of_shards).to eq(20)
      expect(Elastic::IndexSetting['gitlab-test-notes'].number_of_replicas).to eq(4)
      expect(Elastic::IndexSetting['gitlab-test-merge_requests'].number_of_shards).to eq(15)
      expect(Elastic::IndexSetting['gitlab-test-merge_requests'].number_of_replicas).to eq(5)
      expect(Elastic::IndexSetting['gitlab-test-commits'].number_of_shards).to eq(25)
      expect(Elastic::IndexSetting['gitlab-test-commits'].number_of_replicas).to eq(6)

      expect(current_settings.elasticsearch_indexed_file_size_limit_kb).to eq(5000)
      expect(current_settings.elasticsearch_indexed_field_length_limit).to eq(100000)
      expect(current_settings.elasticsearch_max_bulk_size_mb).to eq(17)
      expect(current_settings.elasticsearch_max_bulk_concurrency).to eq(23)
      expect(current_settings.elasticsearch_client_request_timeout).to eq(30)
    end
  end

  it 'allows limiting projects and namespaces to index', :aggregate_failures do
    project = create(:project)
    namespace = create(:namespace)

    within_testid('elasticsearch-settings') do
      expect(page).not_to have_content('Namespaces to index')
      expect(page).not_to have_content('Projects to index')

      check 'Limit the amount of namespace and project data to index'

      expect(page).to have_content('Namespaces to index')
      expect(page).to have_content('Projects to index')

      click_button 'Select namespaces to index'
      find('.gl-listbox-search-input').set(namespace.path)
      expect_listbox_item namespace.full_path
      select_listbox_item namespace.full_path

      click_button 'Select projects to index'
      find('.gl-listbox-search-input').set(project.path)
      expect_listbox_item project.name_with_namespace
      select_listbox_item project.name_with_namespace
    end

    expect_save_settings('elasticsearch-settings')

    expect(current_settings.elasticsearch_limit_indexing).to be_truthy
    expect(ElasticsearchIndexedNamespace.exists?(namespace_id: namespace.id)).to be_truthy
    expect(ElasticsearchIndexedProject.exists?(project_id: project.id)).to be_truthy
  end

  it 'allows removing all namespaces and projects', :aggregate_failures do
    stub_ee_application_setting(elasticsearch_limit_indexing: true)

    namespace = create(:elasticsearch_indexed_namespace).namespace
    project = create(:elasticsearch_indexed_project).project

    expect(ElasticsearchIndexedNamespace.count).to be > 0
    expect(ElasticsearchIndexedProject.count).to be > 0

    visit search_admin_application_settings_path

    within_testid('elasticsearch-settings') do
      expect(page).to have_content('Namespaces to index')
      expect(page).to have_content('Projects to index')
      expect(page).to have_content(namespace.full_path)
      expect(page).to have_content(project.full_path)

      find('.js-limit-namespaces button[data-testid="remove-index-entity"]').click
      find('.js-limit-projects button[data-testid="remove-index-entity"]').click

      expect(page).not_to have_content(namespace.full_path)
      expect(page).not_to have_content(project.full_path)
    end

    expect_save_settings('elasticsearch-settings')

    expect(ElasticsearchIndexedNamespace.count).to eq(0)
    expect(ElasticsearchIndexedProject.count).to eq(0)
  end

  it 'zero-downtime reindexing shows popup' do
    within_testid('elasticsearch-reindexing-settings') do
      expect(page).to have_content 'Trigger cluster reindexing'
      click_button 'Trigger cluster reindexing'
    end

    accept_gl_confirm('Are you sure you want to reindex?')
  end

  context 'when not licensed' do
    let(:elastic_search_license) { false }

    before do
      visit search_admin_application_settings_path
    end

    it 'cannot access the page' do
      expect(page).not_to have_content("Advanced Search with Elasticsearch")
    end
  end

  def current_settings
    ApplicationSetting.current_without_cache
  end
end
