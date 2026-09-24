# frozen_string_literal: true

return if Rails.env.production?

# rubocop:disable Lint/ConstantDefinitionInBlock -- This is a Rake task
# rubocop: disable Rake/Require -- we need it
namespace :jh do
  namespace :gitlab do
    require 'graphql/rake_task'
    require_relative Rails.root.join('tooling/graphql/deprecated_docs/renderer')

    JH_OUTPUT_DIR = Rails.root.join("jh/doc/api/graphql/reference")

    # Make all feature flags enabled so that all feature flag
    # controlled fields are considered visible and are output.
    # Also avoids pipeline failures in case developer
    # dumps schema with flags disabled locally before pushing
    task enable_feature_flags: :environment do
      def Feature.enabled?(*_args)
        true
      end
    end

    namespace :graphql do
      desc 'GitLab | GraphQL | Generate JH GraphQL docs'
      task compile_docs: [:environment, :enable_feature_flags] do
        renderer = Tooling::Graphql::DeprecatedDocs::Renderer.new(GitlabSchema, **jh_render_options)

        renderer.write

        puts "JH GraphQL documentation compiled."
      end

      desc 'GitLab | GraphQL | Check if JH GraphQL docs are up to date'
      task check_docs: [:environment, :enable_feature_flags] do
        renderer = Tooling::Graphql::DeprecatedDocs::Renderer.new(GitlabSchema, **jh_render_options)

        doc = File.read(Rails.root.join(JH_OUTPUT_DIR, '_index.md'))

        if doc == renderer.contents
          puts "JH GraphQL documentation is up to date"
        else
          format_output('JH GraphQL documentation is outdated!
              Please update it by running `bundle exec rake jh:gitlab:graphql:compile_docs`.')
          abort
        end
      end
    end
  end
end
# rubocop:enable Lint/ConstantDefinitionInBlock
# rubocop:enable Rake/Require

def jh_render_options
  {
    output_dir: JH_OUTPUT_DIR,
    template: Rails.root.join(TEMPLATES_DIR, 'default.md.haml')
  }
end
