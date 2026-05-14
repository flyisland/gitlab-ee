# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::AggregationEngines::Contributions, :click_house, time_travel_to: '2026-01-30',
  type: :aggregation_engine,
  feature_category: :product_analytics do
  let(:engine) { described_class.new(context: engine_context) }
  let(:engine_context) { { scope: ClickHouse::Client::QueryBuilder.new(described_class.table_name) } }

  let_it_be(:project1) { create(:project) }

  before do
    clickhouse_fixture(:contributions_new, contributions_data.map { |c| contribution_row(c) })
  end

  def contribution_row(data)
    {
      id: data[:id],
      path: data[:project].project_namespace.traversal_path.to_s,
      author_id: data[:author_id],
      target_type: data.fetch(:target_type, ''),
      action: data.fetch(:action, 5),
      created_at: data[:created_at],
      updated_at: data.fetch(:updated_at, data[:created_at]),
      version: data.fetch(:updated_at, data[:created_at]),
      deleted: false
    }
  end

  describe 'metrics' do
    describe 'users_count' do
      let(:contributions_data) do
        [
          { id: 1, author_id: 1, project: project1, created_at: 10.days.ago },
          { id: 2, author_id: 1, project: project1, created_at: 10.days.ago },
          { id: 3, author_id: 2, project: project1, created_at: 10.days.ago },
          { id: 4, author_id: 3, project: project1, created_at: 10.days.ago }
        ]
      end

      it 'counts distinct number of contributors' do
        request = {
          metrics: [{ identifier: :users_count }]
        }

        expect(engine).to execute_aggregation(request).and_return([
          { users_count: 3 }
        ])
      end
    end

    describe 'total_count' do
      let(:contributions_data) do
        [
          { id: 1, author_id: 1, project: project1, created_at: 10.days.ago },
          { id: 2, author_id: 1, project: project1, created_at: 10.days.ago },
          { id: 3, author_id: 2, project: project1, created_at: 10.days.ago }
        ]
      end

      it 'counts total number of contributions' do
        request = {
          metrics: [{ identifier: :total_count }]
        }

        expect(engine).to execute_aggregation(request).and_return([
          { total_count: 3 }
        ])
      end
    end
  end

  describe 'filters' do
    let(:contributions_data) do
      [
        { id: 1, author_id: 1, project: project1, created_at: 100.days.ago },
        { id: 2, author_id: 1, project: project1, created_at: 50.days.ago },
        { id: 3, author_id: 2, project: project1, created_at: 10.days.ago },
        { id: 4, author_id: 3, project: project1, created_at: 5.days.ago }
      ]
    end

    describe 'author_id' do
      it 'filters by single author GlobalID' do
        request = {
          metrics: [{ identifier: :total_count }],
          filters: [{ identifier: :author_id, values: "gid://gitlab/User/1" }]
        }

        expect(engine).to execute_aggregation(request).and_return([
          { total_count: 2 }
        ])
      end

      it 'filters by multiple author GlobalIDs' do
        request = {
          metrics: [{ identifier: :total_count }],
          filters: [{ identifier: :author_id, values: %w[gid://gitlab/User/1 gid://gitlab/User/2] }]
        }

        expect(engine).to execute_aggregation(request).and_return([
          { total_count: 3 }
        ])
      end
    end

    describe 'created_at' do
      it 'filters by start date' do
        request = {
          metrics: [{ identifier: :total_count }],
          filters: [{ identifier: :created_at, values: (30.days.ago..) }]
        }

        expect(engine).to execute_aggregation(request).and_return([
          { total_count: 2 }
        ])
      end

      it 'filters by end date' do
        request = {
          metrics: [{ identifier: :total_count }],
          filters: [{ identifier: :created_at, values: (..20.days.ago) }]
        }

        expect(engine).to execute_aggregation(request).and_return([
          { total_count: 2 }
        ])
      end

      it 'filters by date range' do
        request = {
          metrics: [{ identifier: :total_count }],
          filters: [{ identifier: :created_at, values: (60.days.ago..20.days.ago) }]
        }

        expect(engine).to execute_aggregation(request).and_return([
          { total_count: 1 }
        ])
      end
    end
  end

  describe 'combined metrics and filters' do
    let(:contributions_data) do
      [
        { id: 1, author_id: 1, project: project1, created_at: 100.days.ago },
        { id: 2, author_id: 1, project: project1, created_at: 10.days.ago },
        { id: 3, author_id: 2, project: project1, created_at: 10.days.ago },
        { id: 4, author_id: 2, project: project1, created_at: 10.days.ago },
        { id: 5, author_id: 3, project: project1, created_at: 5.days.ago }
      ]
    end

    it 'returns both metrics with filters applied' do
      request = {
        metrics: [
          { identifier: :users_count },
          { identifier: :total_count }
        ],
        filters: [
          { identifier: :author_id, values: %w[gid://gitlab/User/1 gid://gitlab/User/2] },
          { identifier: :created_at, values: (30.days.ago..) }
        ]
      }

      expect(engine).to execute_aggregation(request).and_return([
        { users_count: 2, total_count: 3 }
      ])
    end
  end
end
