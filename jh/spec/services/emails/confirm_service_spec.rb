# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emails::ConfirmService, feature_category: :user_management do
  let(:user) { create(:user) }
  let(:email) { user.emails.create!(email: 'new@email.com') }

  subject(:service) { described_class.new(user) }

  describe '#execute' do
    context 'when email has suitable interval' do
      before do
        email.update(updated_at: 2.minutes.ago)
      end

      it 'enqueues a background job to send confirmation email again' do
        expect { service.execute(email) }.to have_enqueued_job.on_queue('mailers')
      end
    end

    context 'when email has too short sending interval' do
      before do
        email.touch
      end

      it 'does not enqueue a background job' do
        expect { service.execute(email) }.not_to have_enqueued_job.on_queue('mailers')
      end
    end

    context 'when email has been verified' do
      before do
        email.update(confirmed_at: 5.minutes.ago)
      end

      it 'does not enqueue a background job' do
        expect { service.execute(email) }.not_to have_enqueued_job.on_queue('mailers')
      end
    end

    it 'records an audit event when confirmation is sent' do
      unconfirmed_email = 'foobar@gitlab.com'

      expect(::Gitlab::Audit::Auditor).to(receive(:audit).with(hash_including({
        name: 'email_confirmation_sent',
        message: 'Confirmation instructions sent to: foobar@gitlab.com',
        additional_details: hash_including({
          current_email: user.email,
          target_type: 'Email',
          unconfirmed_email: unconfirmed_email
        })
      })).and_call_original)

      described_class.new(user).execute(user.emails.create!(email: unconfirmed_email, updated_at: 2.minutes.ago))
    end
  end
end
