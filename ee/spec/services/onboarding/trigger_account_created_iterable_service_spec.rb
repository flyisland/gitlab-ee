# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Onboarding::TriggerAccountCreatedIterableService, feature_category: :onboarding do
  let_it_be(:user, freeze: false) do
    create(
      :user,
      preferred_language: 'en',
      user_detail_attributes: {
        onboarding_status: {
          'email_opt_in' => true,
          'setup_for_company' => true,
          'role' => 0,
          'registration_objective' => 0,
          'glm_content' => 'content-value',
          'glm_source' => 'source-value'
        }
      }
    )
  end

  let(:status_presenter) do
    instance_double(
      ::Onboarding::StatusPresenter,
      unification_enabled?: unification_enabled,
      account_created_product_interaction: product_interaction
    )
  end

  let(:unification_enabled) { true }
  let(:product_interaction) { 'Direct Purchase Account Creation Premium SM' }

  subject(:execute) { described_class.new(user, status_presenter).execute }

  describe '#execute' do
    context 'when unification is enabled' do
      it 'enqueues the iterable trigger worker with the expected payload' do
        expect(::Onboarding::CreateIterableTriggerWorker).to receive(:perform_async).with(
          {
            'provider' => 'gitlab',
            'work_email' => user.email,
            'uid' => user.id,
            'product_interaction' => 'Direct Purchase Account Creation Premium SM',
            'opt_in' => true,
            'preferred_language' => 'English',
            'setup_for_company' => true,
            'role' => 'software_developer',
            'jtbd' => 'basics',
            'glm_content' => 'content-value',
            'glm_source' => 'source-value'
          }
        )

        execute
      end

      context 'with the .com product interaction' do
        let(:product_interaction) { 'Direct Purchase Account Creation Premium Dotcom' }

        it 'forwards the .com product_interaction value' do
          expect(::Onboarding::CreateIterableTriggerWorker).to receive(:perform_async).with(
            hash_including('product_interaction' => 'Direct Purchase Account Creation Premium Dotcom')
          )

          execute
        end
      end

      context 'when glm tracking values are blank' do
        before do
          user.user_detail.update!(
            onboarding_status: user.onboarding_status.except('glm_content', 'glm_source')
          )
        end

        it 'omits glm_content and glm_source from the payload' do
          expect(::Onboarding::CreateIterableTriggerWorker).to receive(:perform_async) do |params|
            expect(params).not_to have_key('glm_content')
            expect(params).not_to have_key('glm_source')
          end

          execute
        end
      end
    end

    context 'when unification is not enabled' do
      let(:unification_enabled) { false }

      it 'does not enqueue the iterable trigger worker' do
        expect(::Onboarding::CreateIterableTriggerWorker).not_to receive(:perform_async)

        execute
      end
    end
  end
end
