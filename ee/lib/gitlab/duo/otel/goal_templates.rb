# frozen_string_literal: true

module Gitlab
  module Duo
    module Otel
      module GoalTemplates
        ISSUE_TITLE = "Add OpenTelemetry instrumentation"

        RUBY_TEMPLATE = <<~GOAL
          Add OpenTelemetry SDK instrumentation to this Ruby project.

          Requirements:
          1. Add these gems to the Gemfile:
             - opentelemetry-sdk
             - opentelemetry-exporter-otlp
             - opentelemetry-instrumentation-rails
             - opentelemetry-instrumentation-rack

          2. Run `bundle install` to update Gemfile.lock with the new dependencies

          3. Create config/initializers/opentelemetry.rb with SDK configuration:
             - Use ENV['OTEL_EXPORTER_OTLP_ENDPOINT'] for the endpoint (default: http://localhost:4318)
             - Use ENV['OTEL_SERVICE_NAME'] for service name (default to project name)
             - Enable auto-instrumentation with use_all

          4. Do NOT hardcode any secrets, tokens, or endpoints

          5. Include setup instructions in the MR description explaining:
             - How to set the environment variables
             - How to run a local OTel Collector for testing
        GOAL

        JAVASCRIPT_TEMPLATE = <<~GOAL
          Add OpenTelemetry SDK instrumentation to this Node.js project.

          Requirements:
          1. Add these packages to package.json:
             - @opentelemetry/sdk-node
             - @opentelemetry/auto-instrumentations-node
             - @opentelemetry/exporter-trace-otlp-http

          2. Run `npm install` to update package-lock.json with the new dependencies

          3. Create tracing.js with SDK initialization (loaded via --require flag):
             - Use process.env.OTEL_EXPORTER_OTLP_ENDPOINT for the endpoint (default: http://localhost:4318)
             - Use process.env.OTEL_SERVICE_NAME for service name
             - Enable auto-instrumentation with getNodeAutoInstrumentations()

          4. Do NOT hardcode any secrets, tokens, or endpoints

          5. Include setup instructions in the MR description explaining:
             - How to set the environment variables
             - How to load tracing.js on startup (node --require ./tracing.js app.js)
             - How to run a local OTel Collector for testing
        GOAL

        PYTHON_TEMPLATE = <<~GOAL
          Add OpenTelemetry SDK instrumentation to this Python project.

          Requirements:
          1. Add these packages to requirements.txt:
             - opentelemetry-sdk
             - opentelemetry-exporter-otlp
             - opentelemetry-instrumentation

          2. Run `pip install -r requirements.txt` to install the new dependencies

          3. Create otel_config.py or add to app startup:
             - Use os.environ.get('OTEL_EXPORTER_OTLP_ENDPOINT') for the endpoint (default: http://localhost:4318)
             - Use os.environ.get('OTEL_SERVICE_NAME') for service name
             - Configure TracerProvider with BatchSpanProcessor and OTLPSpanExporter

          4. Do NOT hardcode any secrets, tokens, or endpoints

          5. Include setup instructions in the MR description explaining:
             - How to set the environment variables
             - How to run a local OTel Collector for testing
        GOAL

        DEFAULT_TEMPLATE = <<~GOAL
          Add OpenTelemetry SDK instrumentation to this project.

          Requirements:
          1. Add the OpenTelemetry SDK and OTLP exporter packages for this project's language

          2. Install the new dependencies using the project's package manager and commit any lock files

          3. Configure the SDK initialization:
             - Use environment variable OTEL_EXPORTER_OTLP_ENDPOINT for the endpoint (default: http://localhost:4318)
             - Use environment variable OTEL_SERVICE_NAME for service name
             - Enable auto-instrumentation where available

          4. Do NOT hardcode any secrets, tokens, or endpoints

          5. Include setup instructions in the MR description explaining:
             - How to set the environment variables
             - How to run a local OTel Collector for testing
        GOAL

        TEMPLATES = {
          'Ruby' => RUBY_TEMPLATE,
          'JavaScript' => JAVASCRIPT_TEMPLATE,
          'TypeScript' => JAVASCRIPT_TEMPLATE,
          'Python' => PYTHON_TEMPLATE
        }.freeze

        class << self
          def issue_title
            ISSUE_TITLE
          end

          def build_description(language)
            TEMPLATES[language] || DEFAULT_TEMPLATE
          end
        end
      end
    end
  end
end
