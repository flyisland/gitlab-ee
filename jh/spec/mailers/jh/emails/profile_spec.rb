# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::Emails::Profile, feature_category: :compliance_management do
  let_it_be(:user) { create(:user) }

  let(:deadline) { 30.days.from_now.to_date }

  describe '#pipl_compliance_notification' do
    it 'resolves the instance method to the JH override' do
      expect(Notify.instance_method(:pipl_compliance_notification).owner).to eq(described_class)
    end

    it 'builds no deliverable message instead of the PIPL notification' do
      message = Notify.new
        .tap { |mailer| mailer.process(:pipl_compliance_notification, user, deadline) }
        .message

      expect(message.to).to be_nil
      expect(message.subject).to be_nil
    end

    it 'does not add a delivery on deliver_now' do
      expect { Notify.pipl_compliance_notification(user, deadline).deliver_now }
        .not_to change { ActionMailer::Base.deliveries.count }
    end

    it 'does not add a delivery when the deliver_later job is performed' do
      expect do
        perform_enqueued_jobs do
          Notify.pipl_compliance_notification(user, deadline).deliver_later
        end
      end.not_to change { ActionMailer::Base.deliveries.count }
    end

    it 'does not add a delivery when a previously enqueued delivery job is performed' do
      expect do
        ActionMailer::MailDeliveryJob
          .perform_now('Notify', 'pipl_compliance_notification', 'deliver_now', args: [user, deadline])
      end.not_to change { ActionMailer::Base.deliveries.count }
    end
  end

  describe 'other profile emails' do
    it 'still delivers' do
      expect { Notify.test_email(user.email, 'subject', 'body').deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
