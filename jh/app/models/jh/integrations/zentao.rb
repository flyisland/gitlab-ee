# frozen_string_literal: true

module JH
  module Integrations
    module Zentao
      extend ::Gitlab::Utils::Override

      override :help
      def help
        link_start = ::Kernel.format('<a href="%{url}" target="_blank" rel="noopener noreferrer">'.html_safe,
          url: 'https://docs.gitlab.cn/jh/user/project/integrations/zentao.html')
        ::Kernel.format(s_("ZentaoIntegration|Before you enable this integration, you must configure ZenTao. " \
          "For more details, read the %{link_start}ZenTao integration documentation%{link_end}."),
          link_start: link_start,
          link_end: '</a>'.html_safe)
      end
    end
  end
end
