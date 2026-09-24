# frozen_string_literal: true

module JH
  module SessionsController
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      prepend_around_action :set_locale
    end
  end
end
