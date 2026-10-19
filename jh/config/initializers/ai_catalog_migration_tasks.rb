# frozen_string_literal: true

Gitlab.jh do
  next unless defined?(Rake::Task)

  %w[db:migrate db:migrate:main].each do |task_name|
    next unless Rake::Task.task_defined?(task_name)

    Rake::Task[task_name].enhance do
      next if ENV['SKIP_POST_DEPLOYMENT_MIGRATIONS']

      Gitlab::Ai::Catalog::ThirdPartyFlows::Seeder.new.seed_missing_agents!
    end
  end
end
