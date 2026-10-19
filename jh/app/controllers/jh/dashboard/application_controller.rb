# frozen_string_literal: true

module JH
  module Dashboard
    module ApplicationController
      include RedirectHomePageWhenNonlogin
    end
  end
end
