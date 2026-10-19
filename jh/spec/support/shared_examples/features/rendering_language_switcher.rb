# frozen_string_literal: true

RSpec.shared_examples 'rendering language switch selector' do |path|
  it 'renders language switch selector', :js do
    stub_feature_flags(disable_preferred_language_cookie: false)
    visit public_send(path)

    page.within('.jh-language-switcher') do
      expected_locale_text = Gitlab::I18n.selectable_locales
                                         .fetch(Gitlab::CurrentSettings.default_preferred_language)
                                         .split('-').last.strip
      expect(page).to have_content(expected_locale_text)
    end
  end
end
