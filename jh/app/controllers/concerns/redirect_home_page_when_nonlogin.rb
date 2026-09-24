# frozen_string_literal: true

module RedirectHomePageWhenNonlogin
  extend ::Gitlab::Utils::Override

  override :authenticate_user!
  def authenticate_user!
    if should_redirect_to_home_page?
      store_location_for(:user, request.fullpath) unless request.xhr?
      return redirect_to ::Gitlab::CurrentSettings.home_page_url
    end

    super
  end
end
