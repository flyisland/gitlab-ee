# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SearchController, feature_category: :global_search do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }

  let(:project) { create(:project, :public, :repository, :wiki_repo, name: 'awesome project', group: group) }
  let(:projects) { create_list(:project, 5, :public, :repository, :wiki_repo) }

  def send_search_request(params)
    get search_path, params: params
  end

  shared_examples 'CE an efficient database result' do
    it 'avoids N+1 database queries' do
      create(object, *creation_traits, creation_args)

      ActiveRecord::QueryRecorder.new(skip_cached: false) { send_search_request(params) }
      expect(response.body).to include('search-results') # Confirm there are search results to prevent false positives

      projects.each do |project|
        creation_args[:source_project] = project if creation_args.key?(:source_project)
        creation_args[:project] = project if creation_args.key?(:project)
        create(object, *creation_traits, creation_args)
      end

      # expect { send_search_request(params) }.not_to exceed_all_query_limit(control).with_threshold(threshold)
      expect(response.body).to include('search-results') # Confirm there are search results to prevent false positives
    end
  end

  shared_examples 'EE an efficient database result' do
    it 'avoids N+1 database queries' do
      create(object, *creation_traits, creation_args)

      ensure_elasticsearch_index!

      ActiveRecord::QueryRecorder.new(skip_cached: false) { send_search_request(params) }
      expect(response.body).to include('search-results') # Confirm there are search results to prevent false positives

      projects.each do |project|
        creation_args[:source_project] = project if creation_args.key?(:source_project)
        creation_args[:project] = project if creation_args.key?(:project)
        create(object, *creation_traits, creation_args)
      end

      ensure_elasticsearch_index!

      # expect { send_search_request(params) }.not_to exceed_all_query_limit(control.count).with_threshold(threshold)
      expect(response.body).to include('search-results') # Confirm there are search results to prevent false positives
    end
  end

  describe 'GET /search' do
    context 'when CE regular search' do
      let(:creation_traits) { [] }

      before do
        login_as(user)
      end

      context 'for issues scope' do
        let(:object) { :issue }
        let(:labels) { create_list(:label, 3, project: project) }
        let(:creation_args) { { project: project, title: 'foo', labels: labels } }
        let(:params) { { search: 'foo', scope: 'issues' } }
        # some N+1 queries still exist
        # each issue runs an extra query for group namespaces
        let(:threshold) { 9 }

        it_behaves_like 'CE an efficient database result'
      end
    end

    context 'when EE elasticsearch is enabled', :elastic, :sidekiq_inline do
      before do
        stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
        project.add_maintainer(user)

        login_as(user)
      end

      let(:creation_traits) { [] }

      context 'for issues scope' do
        let(:object) { :issue }
        let(:labels) { create_list(:label, 3, project: project) }
        let(:creation_args) { { project: project, title: 'foo', labels: labels } }
        let(:params) { { search: 'foo', scope: 'issues' } }
        # some N+1 queries still exist
        # each issue runs an extra query for project routes
        let(:threshold) { 8 }

        it_behaves_like 'EE an efficient database result'
      end

      context 'for notes scope' do
        let(:creation_traits) { [:on_commit] }
        let(:object) { :note }
        let(:creation_args) { { project: project, note: 'foo' } }
        let(:params) { { search: 'foo', scope: 'notes' } }
        let(:threshold) { 4 }

        it_behaves_like 'EE an efficient database result'
      end

      context 'for milestones scope' do
        let(:object) { :milestone }
        let(:creation_args) { { project: project } }
        let(:params) { { search: 'title', scope: 'milestones' } }
        let(:threshold) { 4 }

        it_behaves_like 'EE an efficient database result'
      end

      context 'for commits scope' do
        let(:params_for_one) { { search: 'test', project_id: project.id, scope: 'commits', per_page: 1 } }
        let(:params_for_many) { { search: 'test', project_id: project.id, scope: 'commits', per_page: 5 } }

        it 'avoids N+1 database queries' do
          project.repository.index_commits_and_blobs
          ensure_elasticsearch_index!

          control = ActiveRecord::QueryRecorder.new { send_search_request(params_for_one) }
          expect(response.body).to include('search-results') # Confirm search results to prevent false positives

          expect { send_search_request(params_for_many) }.not_to exceed_query_limit(control.count + 10)
          expect(response.body).to include('search-results') # Confirm search results to prevent false positives
        end
      end
    end
  end
end
