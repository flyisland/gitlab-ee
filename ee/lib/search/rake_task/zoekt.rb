# frozen_string_literal: true

module Search
  module RakeTask
    module Zoekt
      class << self
        def info(name:, extended: nil, watch_interval: nil)
          extended_mode = if extended.present?
                            Gitlab::Utils.to_boolean(extended)
                          else
                            !watch_interval
                          end

          options = { extended_mode: extended_mode }

          run_with_interval(name:, watch_interval:) do
            task_executor_service(options: options).execute(:info)
          end
        end

        def health(name:, watch_interval: nil)
          interval = watch_interval.to_f
          options = interval > 0 ? { watch_mode: true, watch_interval: interval.to_i } : {}

          run_with_interval(name:, watch_interval:) do
            task_executor_service(options: options).execute(:health)
          end
        end

        def index
          task_executor_service.execute(:index) || abort('Failed to enable Zoekt indexing')
        end

        def disable
          task_executor_service.execute(:disable) || abort('Failed to disable Zoekt')
        end

        def pause_indexing
          task_executor_service.execute(:pause_indexing) || abort('Failed to pause Zoekt indexing')
        end

        def resume_indexing
          task_executor_service.execute(:resume_indexing) || abort('Failed to resume Zoekt indexing')
        end

        def estimate_storage
          task_executor_service.execute(:estimate_storage)
        end

        def reindex_projects
          task_executor_service.execute(:reindex_projects) || abort('Failed to reindex projects')
        end

        private

        def task_executor_service(options: {})
          Search::Zoekt::RakeTaskExecutorService.new(logger: stdout_logger, options: options)
        end

        def run_with_interval(name:, watch_interval:)
          interval = watch_interval.to_f
          return yield if interval <= 0

          loop do
            clear_screen

            stdout_logger.info "Every #{interval}s: #{name} (Updated: #{Time.now.utc.iso8601})"
            yield
            sleep interval
          end
        rescue Interrupt
          puts "\nInterrupted. Exiting gracefully..."
        end

        def clear_screen
          system('clear') || system('cls') # Clear screen (Linux/macOS & Windows)
        end

        def stdout_logger
          @stdout_logger ||= Logger.new($stdout).tap do |l|
            l.formatter = ->(_severity, _datetime, _progname, msg) { "#{msg}\n" }
          end
        end
      end
    end
  end
end
