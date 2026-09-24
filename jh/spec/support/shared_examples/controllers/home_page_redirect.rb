# frozen_string_literal: true

RSpec.shared_examples 'SaaS landing page redirections' do |path_symbol|
  let_it_be(:path) { send(path_symbol) }
  let(:user) { create(:user) }

  subject(:sign_in) do
    post user_session_path(user: { login: user.username, password: user.password })
  end

  context 'when a landing page URL is defined' do
    before do
      stub_application_setting(home_page_url: 'https://www.jihulab.com')
    end

    context 'when SaaS', :saas do
      it 'redirects to landing page and redirects back after login', :saas do
        get path
        expect(response).to redirect_to ::Gitlab::CurrentSettings.home_page_url
        expect(request.session[:user_return_to]).to eq path

        sign_in
        expect(response).to redirect_to path
      end
    end

    context 'when Self-managed' do
      it 'redirects to the sign-in page' do
        get path

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context 'when a landing page URL is not defined', :saas do
    it 'redirects to the sign-in page' do
      get path

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
