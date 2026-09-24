# frozen_string_literal: true

module JH
  module ImportHelper
    # rubocop:disable Rails/OutputSafety
    def import_gitee_personal_access_token_message
      link_url = 'https://gitee.com/profile/personal_access_tokens'
      link_start = format('<a href="%{url}" target="_blank" rel="noopener noreferrer">'.html_safe, url: link_url)

      html_escape(
        format(s_('JH|Create and provide your Gitee %{link_start}Personal Access Token%{link_end}. ' \
          'You will need to select the %{code_open}repo%{code_close} scope, ' \
          'so we can display a list of your public and private repositories which are available to import.'),
          link_start: link_start,
          link_end: '</a>'.html_safe,
          code_open: '<code>'.html_safe,
          code_close: '</code>'.html_safe
        ).html_safe
      )
    end
    # rubocop:enable Rails/OutputSafety
  end
end
