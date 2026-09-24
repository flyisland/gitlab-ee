# frozen_string_literal: true

require 'spec_helper'
require 'email_spec'

RSpec.describe Notify do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include EmailHelpers
  describe 'rollback visibility level' do
    let_it_be(:project) { create(:project) }

    context 'when an issue content invalid' do
      let(:issue) { create(:issue) }

      subject do
        described_class.rollback_visibility_level_email(project.id, project.owner.id, issue)
      end

      it do
        is_expected.to have_body_text "Administrator"
      end
    end

    context 'when a merge request title or description invalid' do
      let(:merge_request) { create(:merge_request) }

      subject do
        described_class.rollback_visibility_level_email(project.id, project.owner.id, merge_request)
      end

      it do
        is_expected.to have_body_text "Administrator"
      end
    end

    context 'when a note on commit title or description invalid' do
      let(:note) { create(:note_on_commit) }

      subject do
        described_class.rollback_visibility_level_email(project.id, project.owner.id, note)
      end

      it do
        is_expected.to have_body_text "Administrator"
      end
    end

    context 'when a note on issue title or description invalid' do
      let(:note) { create(:note_on_issue) }

      subject do
        described_class.rollback_visibility_level_email(project.id, project.owner.id, note)
      end

      it do
        is_expected.to have_body_text "Administrator"
      end
    end

    context 'when a note on project snippet title or description invalid' do
      let(:note) { create(:note_on_project_snippet) }

      subject do
        described_class.rollback_visibility_level_email(project.id, project.owner.id, note)
      end

      it do
        is_expected.to have_body_text "Administrator"
      end
    end
  end

  describe '.notice_password_is_expiring_email' do
    let_it_be(:expiration_time) { Time.current }
    let_it_be(:user, freeze: false) { create(:user) }

    subject { described_class.notice_password_is_expiring_email(user, expiration_time.to_date) }

    it 'have the content' do
      is_expected.to have_body_text "Your account password will expire on #{expiration_time.to_date}, " \
        "it is recommended that you change your password as soon as possible."
      is_expected.to have_body_text "If your password has expired. After you log in, " \
        "you must update your password to access your account."
      is_expected.to have_link('Reset password')
    end
  end

  describe '.free_trial_remind_notification' do
    let_it_be(:trial_end_date) { Time.zone.today.to_s }
    let_it_be(:user) { create(:user) }

    subject { described_class.free_trial_remind_notification(user.id, trial_end_date) }

    it 'has the content' do
      is_expected.to have_body_text "Your free trial of JiHu GitLab on #{Gitlab.config.gitlab.host} will end soon. " \
        "If you do not upgrade any of your group or purchase add-on service, " \
        "your account will be deactivated on #{trial_end_date}."
      is_expected.to have_body_text "To keep using your account, you can:"
      is_expected.to have_body_text "Navigate to 'Group Settings - Billing' and upgrade your plan"
      is_expected.to have_body_text "Contact 400-088-8738 or scan below QR code to upgrade any of your group or " \
        "purchase add-on service"
      is_expected.to have_body_text "If you have no plan to continue using #{Gitlab.config.gitlab.host}, " \
        "please <a href=\"https://docs.gitlab.cn/jh/user/group/import/index.html\" " \
        "target=\"_blank\" rel=\"noopener noreferrer\">migrate your data</a> " \
        "before #{trial_end_date}. " \
        "After free trial ends, your data will be deleted."
    end
  end

  describe '.free_trial_ends_notification' do
    let_it_be(:user) { create(:user) }

    subject { described_class.free_trial_ends_notification(user.id) }

    it 'has the content' do
      is_expected.to have_body_text "Your free trial of JiHu GitLab on #{Gitlab.config.gitlab.host} ends today. " \
        "We are sorry to inform that your account is deactivated. " \
        "If you want to continue, you can contact 400-088-8738 or " \
        "scan below QR code to upgrade " \
        "any of your group or purchase add-on service."
      is_expected.to have_body_text "If you do not upgrade any of your group or purchase add-on service, " \
        "all data in your account will be deleted."
    end
  end
end
