# frozen_string_literal: true

RSpec.configure do |config|
  config.before(
    rerun_file_path: %r{
      /ee/spec/(?:lib/onboarding/default_country|components/registrations/welcome/form_component)_spec\.rb\z
    }x
  ) do |example|
    next unless example.full_description.include?('when the resolved country is not offered by the selector') ||
      example.full_description.include?('when the resolved country is not selectable')

    # CN is selectable in JH; these upstream scenarios need an unavailable country to test the fallback.
    countries = World.countries_for_select.reject { |_name, code| code == 'CN' }
    allow(World).to receive(:countries_for_select).and_return(countries)
  end
end
