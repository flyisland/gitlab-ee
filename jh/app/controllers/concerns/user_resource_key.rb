# frozen_string_literal: true

module UserResourceKey
  private

  def user_resource_key
    @user_resource_key ||= if params[:new_user]
                             :new_user
                           else
                             :user
                           end
  end

  def user_resource
    user_resource = params[user_resource_key]
    user_resource ||= params[:user]
    user_resource
  end
end
