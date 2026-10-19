# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FreeTrial::RemindFreeTrialUserWorker, :freeze_time do
  subject(:worker) { described_class.new.perform(user_id, remind_type, '2023-11-01') }

  let(:remind_type) { :last_free_trial_reminder }
  let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }
  let(:trial_end_date) { '2023-11-01' }
  let(:user) { create(:user) }
  let(:user_id) { user.id }

  context "when saas" do
    before do
      allow(Gitlab).to receive(:com?).and_return(true)
    end

    let(:total_counter_args) do
      [:free_trial_mailer_execution_total, :free_trial_mailer_execution_total,
        { version: Gitlab.version_info.to_s, mailer_category: remind_type }]
    end

    context 'when no sent email before' do
      it 'send remind email' do
        expect(Notify).to receive(:free_trial_remind_notification)
                            .with(user.id, trial_end_date).and_return(mailer).once
        expect(::Gitlab::Metrics.counter(*total_counter_args)).to receive(:increment).once

        expect { worker }.to change { user.custom_attributes.count }.by(1)
        expect(user.custom_attributes.last).to have_attributes(user_id: user.id, key: remind_type.to_s,
          value: Time.current.to_s)
      end
    end

    context 'when send mail wrong' do
      it 'send mailer error metric' do
        response = ::Net::SMTP::Response.new("599", "error string")
        error = Net::SMTPUnknownError.new(response)
        expect(Notify).to receive(:free_trial_remind_notification)
                            .with(user.id, trial_end_date).and_raise(error).once
        expect(::Gitlab::Metrics.counter(:free_trial_mailer_error_total, :free_trial_mailer_error_total,
          { version: Gitlab.version_info.to_s, mailer_category: remind_type,
            status_code: '599', error_message: 'error string' })).to receive(:increment).once

        expect { worker }.to raise_error { error }
      end

      it 'send general error message' do
        error = StandardError.new('standard error')
        expect(Notify).to receive(:free_trial_remind_notification)
                            .with(user.id, trial_end_date).and_raise(error).once
        expect(::Gitlab::Metrics.counter(:free_trial_mailer_error_total, :free_trial_mailer_error_total,
          { version: Gitlab.version_info.to_s, mailer_category: remind_type,
            error_message: 'standard error' })).to receive(:increment).once

        expect { worker }.to raise_error { error }
      end
    end

    context 'when wrong user id no email send' do
      let(:user_id) { 'wrong user id' }

      it 'do not send email' do
        expect(Notify).not_to receive(:free_trial_remind_notification)

        expect { worker }.not_to change { user.custom_attributes.count }
      end
    end

    context 'when sent email before' do
      it 'do not send email' do
        user.custom_attributes.create(user_id: user_id, key: remind_type, value: Time.current.to_s)
        expect(Notify).not_to receive(:free_trial_remind_notification)

        expect { worker }.not_to change { user.custom_attributes.count }
      end
    end
  end

  context "when not saas" do
    it "not call service if not saas" do
      allow(Gitlab).to receive(:com?).and_return(false)

      expect { worker }.not_to change { user.custom_attributes.count }
    end
  end
end
