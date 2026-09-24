# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::ExpiredStorageNotice, feature_category: :subscription_management do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:namespace) { group }
  let(:expired_storage_notice_email) { double('mailer', deliver_now: true) } # rubocop:disable RSpec/VerifiedDoubles -- instance_double keeps raise error

  let(:service) { described_class.new(namespace) }
  let(:storage_expiry_date) { 7.days.from_now.to_date }

  before_all do
    group.add_owner(user)
  end

  before do
    allow(namespace).to receive(:additional_purchased_storage_ends_on).and_return(storage_expiry_date)
  end

  describe '#call' do
    subject(:call_service) { service.call }

    context 'when expired_storage_check feature flag is disabled' do
      before do
        stub_feature_flags(expired_storage_check: false)
      end

      it 'does not send notification' do
        expect(Notify).not_to receive(:storage_expiry_notification)
        call_service
      end
    end

    context 'when expired_storage_check feature flag is enabled' do
      before do
        stub_feature_flags(expired_storage_check: namespace)
      end

      context 'when storage expiry date is not present' do
        let(:storage_expiry_date) { nil }

        it 'does not send notification' do
          expect(Notify).not_to receive(:storage_expiry_notification)
          call_service
        end
      end

      context 'when storage expiry date is present' do
        context 'when storage expires in 15 days' do
          let(:storage_expiry_date) { 15.days.from_now.to_date }

          it 'sends notification email' do
            expect(Notify).to receive(:storage_expiry_notification)
              .with(user.id, namespace.id, 15, storage_expiry_date)
              .and_return(expired_storage_notice_email)

            call_service
          end
        end

        context 'when storage expires in 7 days' do
          let(:storage_expiry_date) { 7.days.from_now.to_date }

          it 'sends notification email' do
            expect(Notify).to receive(:storage_expiry_notification)
              .with(user.id, namespace.id, 7, storage_expiry_date)
              .and_return(expired_storage_notice_email)

            call_service
          end
        end

        context 'when storage expires in 3 days' do
          let(:storage_expiry_date) { 3.days.from_now.to_date }

          it 'sends notification email' do
            expect(Notify).to receive(:storage_expiry_notification)
              .with(user.id, namespace.id, 3, storage_expiry_date)
              .and_return(expired_storage_notice_email)

            call_service
          end
        end

        context 'when storage expires in 14 days (not a reminder day)' do
          let(:storage_expiry_date) { 14.days.from_now.to_date }

          it 'does not send notification' do
            expect(Notify).not_to receive(:storage_expiry_notification)
            call_service
          end
        end

        context 'when storage expires in 5 days (not a reminder day)' do
          let(:storage_expiry_date) { 5.days.from_now.to_date }

          it 'does not send notification' do
            expect(Notify).not_to receive(:storage_expiry_notification)
            call_service
          end
        end

        context 'when storage expires in 1 day (not a reminder day)' do
          let(:storage_expiry_date) { 1.day.from_now.to_date }

          it 'does not send notification' do
            expect(Notify).not_to receive(:storage_expiry_notification)
            call_service
          end
        end

        context 'when storage expires today (0 days)' do
          let(:storage_expiry_date) { Date.current }

          it 'does not send notification' do
            expect(Notify).not_to receive(:storage_expiry_notification)
            call_service
          end
        end

        context 'when storage already expired' do
          let(:storage_expiry_date) { 1.day.ago.to_date }

          it 'does not send notification' do
            expect(Notify).not_to receive(:storage_expiry_notification)
            call_service
          end
        end

        context 'when storage expires in more than 15 days' do
          let(:storage_expiry_date) { 30.days.from_now.to_date }

          it 'does not send notification' do
            expect(Notify).not_to receive(:storage_expiry_notification)
            call_service
          end
        end
      end
    end
  end

  describe '#feature_enabled?' do
    subject { service.feature_enabled? }

    context 'when feature flag is enabled for the namespace' do
      before do
        stub_feature_flags(expired_storage_check: namespace)
      end

      it { is_expected.to be_truthy }
    end

    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(expired_storage_check: false)
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#storage_expiry_date_present?' do
    subject { service.storage_expiry_date_present? }

    context 'when storage expiry date exists' do
      let(:storage_expiry_date) { 7.days.from_now.to_date }

      it { is_expected.to be_truthy }
    end

    context 'when storage expiry date is nil' do
      let(:storage_expiry_date) { nil }

      it { is_expected.to be_falsey }
    end
  end

  describe '#storage_expiry_date' do
    subject { service.storage_expiry_date }

    let(:storage_expiry_date) { 7.days.from_now.to_date }

    it 'returns the namespace additional_purchased_storage_ends_on' do
      expect(subject).to eq(storage_expiry_date)
    end

    it 'memoizes the result' do
      expect(namespace).to receive(:additional_purchased_storage_ends_on).once.and_return(storage_expiry_date)

      2.times { service.storage_expiry_date }
    end
  end

  describe '#calculate_days_until_expiry' do
    subject { service.calculate_days_until_expiry }

    context 'when storage expiry date is present' do
      let(:storage_expiry_date) { 7.days.from_now.to_date }

      it 'returns the correct number of days' do
        expect(subject).to eq(7)
      end
    end

    context 'when storage expiry date is nil' do
      let(:storage_expiry_date) { nil }

      it 'returns 0' do
        expect(subject).to eq(0)
      end
    end

    context 'when storage has already expired' do
      let(:storage_expiry_date) { 2.days.ago.to_date }

      it 'returns negative number' do
        expect(subject).to eq(-2)
      end
    end
  end

  describe '#should_send_reminder?' do
    subject { service.should_send_reminder?(days_until_expiry) }

    context 'when days_until_expiry is 15' do
      let(:days_until_expiry) { 15 }

      it { is_expected.to be_truthy }
    end

    context 'when days_until_expiry is 7' do
      let(:days_until_expiry) { 7 }

      it { is_expected.to be_truthy }
    end

    context 'when days_until_expiry is 3' do
      let(:days_until_expiry) { 3 }

      it { is_expected.to be_truthy }
    end

    context 'when days_until_expiry is 14' do
      let(:days_until_expiry) { 14 }

      it { is_expected.to be_falsey }
    end

    context 'when days_until_expiry is 1' do
      let(:days_until_expiry) { 1 }

      it { is_expected.to be_falsey }
    end

    context 'when days_until_expiry is 0' do
      let(:days_until_expiry) { 0 }

      it { is_expected.to be_falsey }
    end

    context 'when days_until_expiry is negative' do
      let(:days_until_expiry) { -1 }

      it { is_expected.to be_falsey }
    end
  end

  describe '#send_expiry_notification' do
    let(:days_until_expiry) { 7 }
    let(:storage_expiry_date) { 7.days.from_now.to_date }

    subject { service.send_expiry_notification(days_until_expiry) }

    it 'calls Notify.storage_expiry_notification with correct parameters' do
      expect(Notify).to receive(:storage_expiry_notification)
        .with(user.id, namespace.id, days_until_expiry, storage_expiry_date)
        .and_return(expired_storage_notice_email)

      subject
    end

    it 'calls deliver_later on the mailer' do
      allow(Notify).to receive(:storage_expiry_notification).and_return(expired_storage_notice_email)
      expect(expired_storage_notice_email).to receive(:deliver_now)

      subject
    end
  end

  describe 'REMINDER_DAYS constant' do
    it 'contains the expected reminder days' do
      expect(described_class::REMINDER_DAYS).to eq([15, 7, 3])
    end
  end

  describe '.execute' do
    let_it_be(:namespace_with_storage) { create(:group) }
    let_it_be(:namespace_without_storage) { create(:group) }
    let_it_be(:limit_with_storage) do
      create(:namespace_limit, namespace: namespace_with_storage, additional_purchased_storage_size: 100)
    end

    let_it_be(:limit_without_storage) do
      create(:namespace_limit, namespace: namespace_without_storage, additional_purchased_storage_size: 0)
    end

    subject(:execute_service) { described_class.execute }

    it 'processes namespaces with purchased storage and calls service for each' do
      expect(described_class).to receive(:new).with(namespace_with_storage).and_call_original
      expect_any_instance_of(described_class).to receive(:call)
      expect(described_class).not_to receive(:new).with(namespace_without_storage)

      execute_service
    end

    context 'when no namespaces have purchased storage' do
      before do
        NamespaceLimit.update_all(additional_purchased_storage_size: 0)
      end

      it 'does not create any service instances' do
        expect(described_class).not_to receive(:new)

        execute_service
      end
    end
  end
end
