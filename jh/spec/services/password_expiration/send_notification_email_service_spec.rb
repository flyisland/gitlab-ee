# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PasswordExpiration::SendNotificationEmailService do
  include NotificationHelpers

  let(:subject) { described_class.new(1).execute }
  let_it_be(:has_noticed) { 84.days.ago }
  let_it_be(:today_notice) { 83.days.ago }
  let_it_be(:be_noticing) { 82.days.ago }

  let_it_be(:user_detail1, freeze: false) { create(:user).user_detail }
  let_it_be(:user_detail2, freeze: false) { create(:user).user_detail }
  let_it_be(:user_detail3, freeze: false) { create(:user).user_detail }
  let_it_be(:user_detail4, freeze: false) { create(:user).user_detail }

  before_all do
    user_detail1.update!(password_last_changed_at: has_noticed)
    user_detail2.update!(password_last_changed_at: today_notice)
    user_detail3.update!(password_last_changed_at: today_notice)
    user_detail4.update!(password_last_changed_at: be_noticing)
  end

  before do
    stub_application_setting(password_expires_in_days: 90)
    stub_application_setting(password_expires_notice_before_days: 7)
  end

  context 'when password expiration is enabled' do
    before do
      allow(::Gitlab::PasswordExpirationSystem).to receive(:enabled?).and_return(true)
    end

    it 'notice user2(today_notice)' do
      expect { subject }.to have_enqueued_email(user_detail2.user,
        (user_detail2.password_last_changed_at + 90.days).to_date,
        mail: "notice_password_is_expiring_email")
    end

    it 'notice user3(today_notice)' do
      expect { subject }.to have_enqueued_email(user_detail3.user,
        (user_detail3.password_last_changed_at + 90.days).to_date,
        mail: "notice_password_is_expiring_email")
    end

    it 'not notice user1(has_noticed) and user4(be_noticing)' do
      expect { subject }.not_to have_enqueued_email(user_detail1.user,
        (user_detail1.password_last_changed_at + 90.days).to_date,
        mail: "notice_password_is_expiring_email")
      expect { subject }.not_to have_enqueued_email(user_detail4.user,
        (user_detail4.password_last_changed_at + 90.days).to_date,
        mail: "notice_password_is_expiring_email")
    end
  end

  context 'when password expiration is disabled' do
    before do
      allow(::Gitlab::PasswordExpirationSystem).to receive(:enabled?).and_return(false)
    end

    it 'no notification enqueue' do
      expect { subject }.not_to have_enqueued_email(user_detail1.user,
        (user_detail1.password_last_changed_at + 90.days).to_date,
        mail: "notice_password_is_expiring_email")
      expect { subject }.not_to have_enqueued_email(user_detail2.user,
        (user_detail2.password_last_changed_at + 90.days).to_date,
        mail: "notice_password_is_expiring_email")
      expect { subject }.not_to have_enqueued_email(user_detail3.user,
        (user_detail3.password_last_changed_at + 90.days).to_date,
        mail: "notice_password_is_expiring_email")
      expect { subject }.not_to have_enqueued_email(user_detail4.user,
        (user_detail4.password_last_changed_at + 90.days).to_date,
        mail: "notice_password_is_expiring_email")
    end
  end
end
