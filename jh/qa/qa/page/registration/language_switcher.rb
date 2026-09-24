# frozen_string_literal: true

module QA
  module Page
    module Registration
      class LanguageSwitcher < QA::Page::Base
        view '/app/assets/javascripts/language_switcher/components/app.vue' do
          element :language_switcher_lang_en, 'itemTestSelector(locale.value)'
        end

        view 'app/assets/javascripts/authentication/sign_in/components/sign_in_form.vue' do
          element 'sign-in-button'
        end

        def click_drop_down_box
          Support::Waiter.wait_until(reload_page: page, retry_on_exception: true, raise_on_failure: true) do
            find('[data-testid="base-dropdown-toggle"] .gl-new-dropdown-button-text').click
          end
        end

        def switch_to_english
          click_element :language_switcher_lang_en
        end

        def has_sign_button_element?(text)
          has_element?('sign-in-button', text: text)
        end
      end
    end
  end
end
