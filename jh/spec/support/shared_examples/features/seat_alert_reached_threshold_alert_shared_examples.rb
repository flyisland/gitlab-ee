# frozen_string_literal: true

RSpec.shared_examples 'displays the reached seat count threshold alert with JH purchase link' do
  it 'displays the reached seat count threshold alert' do
    visit_page

    expect(page).to have_css '[data-testid="reached-seat-count-threshold-alert"].gl-alert-warning'

    within_testid('reached-seat-count-threshold-alert') do
      expect(page).to have_css('[data-testid="close-icon"]')
      expect(page).to have_text "Your namespace has reached its seat limit"
      expect(page).to have_text "Your namespace has used all 3 seats. Restricted " \
        "access is blocking new users from being added to prevent overages. " \
        "Purchase more seats or turn off restricted access to allow new users."
      expect(page).to have_link 'Purchase more seats', href: group_usage_quotas_path(root_namespace)
      expect(page).to have_link 'Turn off restricted access'
    end
  end
end
