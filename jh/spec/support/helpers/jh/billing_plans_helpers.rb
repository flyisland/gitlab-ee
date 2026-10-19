# frozen_string_literal: true

module JH
  module BillingPlansHelpers
    extend ::Gitlab::Utils::Override

    override :should_have_hand_raise_lead_button
    def should_have_hand_raise_lead_button; end

    override :click_premium_contact_sales_button_and_submit_form
    def click_premium_contact_sales_button_and_submit_form
      page.within('[data-testid="plan-card-premium"]') do
        click_link 'Contact sales'
      end
      ::GitlabSubscriptions::CreateHandRaiseLeadService.new.execute(lead_params)
    end
  end
end
