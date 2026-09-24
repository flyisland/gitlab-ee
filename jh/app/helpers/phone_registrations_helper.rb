# frozen_string_literal: true

module PhoneRegistrationsHelper
  def phone_registration_enabled?
    ::Gitlab::RealNameSystem.enabled? && \
      ::Feature.enabled?(:registrations_with_phone)
  end

  def phone_presented?
    params[:registration_type] != 'email'
  end

  def registration_by_phone?
    phone_registration_enabled? && \
      phone_presented?
  end

  def registration_type
    registration_by_phone? ? :phone : :email
  end
end
