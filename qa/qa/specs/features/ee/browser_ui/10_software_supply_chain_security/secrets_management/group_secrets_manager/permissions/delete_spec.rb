# frozen_string_literal: true

module QA
  RSpec.describe(
    'Software Supply Chain Security',
    :secrets_manager,
    only: { job: 'gdk-instance-secrets-manager' },
    feature_category: :secrets_management
  ) do
    include_context 'group secrets manager base'
    describe 'Delete on group secret permissions' do
      let(:reporter) { create(:user) }

      context 'when owner deletes a permission' do
        it 'successfully deletes permissions',
          testcase: 'https://gitlab.com/gitlab-org/gitlab/-/quality/test_cases/598001' do
          group.add_member(reporter, Resource::Members::AccessLevel::REPORTER)

          Support::Waiter.wait_until(max_duration: 10, sleep_interval: 1) do
            group.reload!
            group.find_member(reporter.username).present?
          end

          Flow::Login.while_signed_in(as: owner) do
            group.visit!

            Page::Group::Menu.perform(&:go_to_general_settings)
            Page::Group::Settings::General.perform do |settings|
              scopes = %w[read]
              settings.add_user_permission(username: reporter.username, scopes: scopes)
              settings.delete_user_permission(username: reporter.username)
              expect(settings).not_to have_user_permission(username: reporter.username, scopes: scopes)
            end
          end
        end
      end
    end
  end
end
