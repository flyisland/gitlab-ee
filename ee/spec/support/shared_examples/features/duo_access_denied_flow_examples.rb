# frozen_string_literal: true

RSpec.shared_examples_for 'duo access denied flow' do
  it 'signs in and experiences the entire duo access denied flow' do
    gitlab_sign_in(:user)

    expect_on_root_path_for_back

    visit duo_path

    expect(page).to have_content('You do not have access to trial GitLab Duo To start a GitLab Duo trial')

    click_button 'Go back'

    expect(page).to have_current_path(root_path)

    visit duo_path

    click_button 'Sign in with a different account'

    expect(page).to have_current_path(new_user_session_path)
  end

  def expect_on_root_path_for_back
    expect(page).to have_current_path(root_path)
  end
end
