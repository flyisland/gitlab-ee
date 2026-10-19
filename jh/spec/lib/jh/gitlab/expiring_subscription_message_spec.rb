# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ExpiringSubscriptionMessage, :saas do
  include ActionView::Helpers::SanitizeHelper

  describe 'jh message' do
    using RSpec::Parameterized::TableSyntax

    subject(:message) { strip_tags(raw_message) }

    let(:subject) { strip_tags(raw_subject) }
    let(:subscribable) { double(:license) }
    let(:namespace) { nil }
    let(:force_notification) { false }
    let(:raw_message) do
      described_class.new(
        subscribable: subscribable,
        signed_in: true,
        notify_as_admin: true,
        namespace: namespace,
        force_notification: force_notification
      ).message
    end

    let(:raw_subject) do
      described_class.new(
        subscribable: subscribable,
        signed_in: true,
        notify_as_admin: true,
        namespace: namespace,
        force_notification: force_notification
      ).subject
    end

    let(:today) { Time.utc(2020, 3, 7, 10) }
    let(:expired_date) { Time.utc(2020, 3, 9, 10).to_date }
    let(:block_changes_date) { Time.utc(2020, 3, 23, 10).to_date }

    where(:plan_name) do
      [
        [::Plan::GOLD],
        [::Plan::ULTIMATE]
      ]
    end

    with_them do
      around do |example|
        travel_to(today) do
          example.run
        end
      end

      context 'subscribable installed' do
        let(:auto_renew) { false }

        before do
          allow(subscribable).to receive_messages(plan: plan_name, expires_at: expired_date, auto_renew: auto_renew)
        end

        context 'subscribable should notify admins' do
          before do
            allow(subscribable).to receive(:notify_admins?).and_return(true)
          end

          context 'admin signed in' do
            let(:signed_in) { true }
            let(:is_admin) { true }

            context 'subscribable expired' do
              let(:expired_date) { Time.utc(2020, 3, 1, 10).to_date }

              before do
                allow(subscribable).to receive_messages(expired?: true, expires_at: expired_date)
              end

              context 'when it blocks changes' do
                before do
                  allow(subscribable).to receive(:will_block_changes?).and_return(true)
                end

                context 'when it is currently blocking changes' do
                  let(:plan_name) { ::Plan::FREE }

                  before do
                    allow(subscribable).to receive_messages(block_changes?: true, block_changes_at: expired_date)
                  end

                  context 'with namespace' do
                    let(:has_future_renewal) { false }

                    let_it_be(:namespace) { create(:group_with_plan, name: 'No Limit Records') }

                    before do
                      allow_next_instance_of(GitlabSubscriptions::CheckFutureRenewalService,
                        namespace: namespace) do |service|
                        allow(service).to receive(:execute).and_return(has_future_renewal)
                      end
                    end

                    it 'has an expiration blocking message with jh support link' do
                      expect(message).to include("Your subscription for No Limit Records has expired and you are now on the GitLab Free tier. Don't worry, your data is safe. Get in touch with our support team (support@gitlab.cn). They'll gladly help with your subscription renewal.")
                    end

                    context 'is auto_renew' do
                      let(:auto_renew) { true }

                      it 'has a nice subject' do
                        expect(subject).to include('Something went wrong with your automatic subscription renewal')
                      end

                      it 'has an expiration blocking message with jh support' do
                        expect(message).to include("We tried to automatically renew your subscription for No Limit Records on 2020-03-01 but something went wrong so your subscription was downgraded to the free plan. Don't worry, your data is safe. We suggest you check your payment method and get in touch with our support team (support.gitlab.cn). They'll gladly help with your subscription renewal.")
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
