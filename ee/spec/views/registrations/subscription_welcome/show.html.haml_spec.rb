# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'registrations/subscription_welcome/show', feature_category: :onboarding do
  let(:user) { build_stubbed(:user) }

  before do
    allow(view).to receive(:current_user).and_return(user)
  end

  subject { rendered }

  context 'when unification is disabled' do
    let(:onboarding_status_presenter) do
      instance_double(::Onboarding::StatusPresenter, unification_enabled?: false)
    end

    before do
      allow(view).to receive(:onboarding_status_presenter).and_return(onboarding_status_presenter)
      render
    end

    context 'with basic form items' do
      it 'has correct form action' do
        is_expected.to have_css('form[action="/users/sign_up/welcome"]')
      end

      it { is_expected.to have_tracking(action: 'render', label: 'subscription_registration') }

      it 'the text for the :onboarding_status_setup_for_company label' do
        is_expected.to(
          have_selector(
            'label[for="user_onboarding_status_setup_for_company"]',
            text: _('Who will be using this GitLab subscription?')
          )
        )
      end

      it 'shows the text for the submit button' do
        is_expected.to have_button(_('Continue'))
      end

      it 'has the joining_project fields', :aggregate_failures do
        is_expected.to have_selector('#user_onboarding_status_joining_project_true')
        is_expected.to have_selector('#user_onboarding_status_joining_project_false')
      end

      it 'renders a select and text field for additional information' do
        is_expected.to have_selector('select[name="user[onboarding_status_registration_objective]"]')
        is_expected.to have_selector('.js-jobs-to-be-done-other-group.hidden')
        is_expected.to have_selector('input[name="jobs_to_be_done_other"]')
      end

      it 'renders role dropdown with translated options' do
        expect(rendered).to have_selector('select[name="user[onboarding_status_role]"]')
        expect(rendered).to have_selector('option', text: 'Software Developer')
        expect(rendered).to have_selector('option', text: 'Development Team Lead')
        expect(rendered).to have_selector('option', text: 'Other')
      end
    end
  end
end
