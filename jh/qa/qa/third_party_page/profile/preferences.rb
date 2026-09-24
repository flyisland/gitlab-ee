# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module Profile
      class Preferences < ::QA::Page::Base
        def choose_language(language)
          find("#localization").find(:xpath, "..").find("button[data-testid=base-dropdown-toggle]").click
          QA::Runtime::Logger.info("Language label clicked")
          case language.downcase
          when 'english'
            find('li[data-testid=listbox-item-zh_CN]').click
          when 'chinese'
            find('li[data-testid=listbox-item-en').click
          end
          QA::Runtime::Logger.info("#{language} is already selected")
          find("button[name=commit]").click
          QA::Runtime::Logger.info("Save button is clicked")

          if has_text?(/Preferences saved./) || has_text?(/偏好设置已保存/)
            QA::Runtime::Logger.info("Saved successfully.")
          else
            QA::Runtime::Logger.info("Saved failed.")
          end
        end
      end
    end
  end
end
