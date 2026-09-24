# frozen_string_literal: true

namespace :gitlab do
  namespace :db do
    # Fix Job: https://jihulab.com/gitlab-cn/gitlab/-/jobs/25261337
    namespace :create_dynamic_partitions do
      task :jh, [:skip] => :environment do |_, _args|
        puts "JH skip creating dynamic partitions"
      end
    end
  end
end
