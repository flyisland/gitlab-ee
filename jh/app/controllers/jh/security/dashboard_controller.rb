# frozen_string_literal: true

module JH
  module Security
    module DashboardController
      include RedirectHomePageWhenNonlogin
    end
  end
end
