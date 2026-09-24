# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FreeTrial::BlockFreeTrialUserService, :freeze_time do
  subject(:service) { described_class.new(user.id).execute }

  let(:user) { create(:user) }

  describe "#execute" do
    context "when block success" do
      it "block user, send email and update user custom attribute" do
        free_trial_email = double
        expect(free_trial_email).to receive(:deliver_now).once
        expect(Notify).to receive(:free_trial_ends_notification).with(user.id)
                                                                .and_return(free_trial_email)
        expect(::Gitlab::Metrics.counter(:free_trial_mailer_execution_total, :free_trial_mailer_execution_total,
          { version: Gitlab.version_info.to_s, mailer_category: :block_free_trial })).to receive(:increment).once

        service

        user.reset
        expect(user.blocked?).to be(true)
        expect(user.custom_attributes.count).to eq(1)
        expect(user.custom_attributes.first).to have_attributes({ user_id: user.id, key: 'blocked_by_free_trial_ends',
                                                                  value: Time.current.to_s })
      end

      context 'when send mail wrong' do
        it 'send mailer error metric' do
          response = ::Net::SMTP::Response.new("599", "error string")
          error = Net::SMTPUnknownError.new(response)
          expect(Notify).to receive(:free_trial_ends_notification).with(user.id).and_raise(error).once
          expect(::Gitlab::Metrics.counter(:free_trial_mailer_error_total, :free_trial_mailer_error_total,
            { version: Gitlab.version_info.to_s, mailer_category: :block_free_trial,
              status_code: '599', error_message: 'error string' })).to receive(:increment).once

          expect { service }.to raise_error { error }
        end

        it 'send general error message' do
          error = StandardError.new('standard error')
          expect(Notify).to receive(:free_trial_ends_notification).with(user.id).and_raise(error).once
          expect(::Gitlab::Metrics.counter(:free_trial_mailer_error_total, :free_trial_mailer_error_total,
            { version: Gitlab.version_info.to_s, mailer_category: :block_free_trial,
              error_message: 'standard error' })).to receive(:increment).once

          expect { service }.to raise_error { error }
        end
      end
    end

    context 'when block failed' do
      it 'not block user, no email nor no user custom attribute' do
        expect(User).to receive(:find_by_id).and_return(user)
        expect(user).to receive(:block).and_return(false)
        expect(user).to receive_message_chain(:errors, :full_messages).and_return(%w[error1 error2])
        expect(Sidekiq.logger).to receive(:error).with(class: described_class, message: 'error1. error2')
        expect(Notify).not_to receive(:free_trial_ends_notification).with(user.id)

        service

        user.reset
        expect(user.blocked?).to be(false)
        expect(user.custom_attributes).to eq([])
      end
    end

    context 'when user is already blocked' do
      it 'do nothing' do
        user.block
        expect(UserCustomAttribute).not_to receive(:upsert_custom_attributes)
        expect(::Notify).not_to receive(:free_trial_ends_notification).with(user.id)
        expect(Sidekiq.logger).not_to receive(:error)

        service
      end
    end
  end
end
