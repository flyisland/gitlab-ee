# frozen_string_literal: true

Gitlab.jh do
  Rails.application.config.after_initialize do
    next unless defined?(Rake) && Rake::Task.task_defined?('gitlab:openapi:v3:check_docs')

    Rake::Task['gitlab:openapi:v3:check_docs'].clear

    namespace :gitlab do
      namespace :openapi do
        namespace :v3 do
          desc 'GitLab | OpenAPI | Check if OpenAPI v3 doc is up to date (skipped on JH)'
          task check_docs: :environment do
            puts 'Skipping gitlab:openapi:v3:check_docs on JH'
          end
        end
      end
    end
  end
end
