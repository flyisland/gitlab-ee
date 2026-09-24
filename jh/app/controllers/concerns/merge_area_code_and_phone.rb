# frozen_string_literal: true

module MergeAreaCodeAndPhone
  include UserResourceKey

  private

  # e.g: "+86" + "15612341234" = "+8615612341234"
  def merge_area_code_and_phone
    return if params[:phone].start_with?("+")

    params[:phone] = params[:area_code] + params[:phone] if params[:area_code]
  end

  def merge_area_code_and_phone_with_user
    return if user_resource[:phone].start_with?("+") || user_resource[:area_code].blank?

    user_resource[:original_phone] = user_resource[:phone]
    user_resource[:phone] = user_resource[:area_code] + user_resource[:phone]
  end
end
