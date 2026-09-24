# frozen_string_literal: true

module QA
  module Page
    module Group
      class Analytics < QA::Page::Base
        view 'jh/app/views/groups/analytics/performance_analytics/index.html.haml' do
          element 'analytics-title-content'
        end
        view 'app/assets/javascripts/analytics/shared/components/projects_dropdown_filter.vue' do
          element 'project-name'
        end
        view 'jh/app/assets/javascripts/analytics/performance_analytics/components/performance_value_filters.vue' do
          element 'branch-filter'
          element 'project-filter'
        end

        def has_analytics_title?(text)
          has_element?('analytics-title-content', text: text)
        end

        def click_export_csv_button
          click_element('export-performance-table-as-csv')
        end

        def remove_exist_csv_file(file)
          file_path = ::File.expand_path("tmp/#{file}")
          ::FileUtils.rm_f(file_path)
        end

        # rubocop: disable CodeReuse/ActiveRecord -- Usage of `exists` forces us to use this.
        def has_the_analytics_csv_file?(file)
          Support::Retrier.retry_until(sleep_interval: 5) do
            files = Dir.entries("tmp/").join(' ')
            print("files = ", files, "\n")
            ::File.exist?(::File.expand_path("tmp/#{file}"))
          end
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def has_the_card?(card_list)
          card_list.all? { |card_name| has_element?(card_name) }
        end

        def has_correct_the_card_value?(card_list)
          card_list.all? do |card_name, card_value|
            within_element('performance-card') do
              find_element(card_name).has_text?(card_value)
            end
          end
        end

        def select_branch(branch_name)
          click_element('branch-filter')
          find("li[data-testid='listbox-item-#{branch_name}']", text: branch_name).click
        end

        def has_date_range?(date_range_list)
          date_range_list.all? { |date_range_name| has_element?(date_range_name) }
        end

        def select_project(project)
          click_element('project-filter')
          within_element('project-filter') do
            click_element('project-name', text: project)
          end
          click_element('project-filter')
        end

        def has_branch_in_branch_filter?(branch_name)
          filter_has_value(branch_name, 'branch')
        end

        def has_project_in_project_filter?(branch_name)
          filter_has_value(branch_name, 'project')
        end

        def has_the_rank_list_option?(rank_option_list)
          click_element('leaderboard-option')
          rank_option_list.all? { |option| has_element?(option) }
        end

        private

        def filter_has_value(value, type = nil)
          find_element(type == 'branch' ? 'branch-filter' : 'project-filter').has_text?(value)
        end
      end
    end
  end
end
