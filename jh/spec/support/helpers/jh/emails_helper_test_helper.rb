# frozen_string_literal: true

module JH
  module EmailsHelperTestHelper
    def default_header_logo
      %r{<img alt="Jihu GitLab" src="http://test.host/images/mailers/gitlab_logo\.(?:gif|png)" width="\d+" height="\d+" />}
    end
  end
end
