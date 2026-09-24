# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'layouts/performance_measurement', feature_category: :groups_and_projects do
  let_it_be(:current_user) { build_stubbed(:user, :admin) }

  before do
    allow(view).to receive_messages(current_user: current_user,
      current_user_mode: Gitlab::Auth::CurrentUserMode.new(current_user), users_path: '/root')
  end

  subject(:do_render) do
    render

    rendered
  end

  describe 'navigation' do
    context 'when action is #index' do
      before do
        allow(view).to receive(:params).and_return({ action: 'index' })
      end

      it 'renders your_work navigation' do
        do_render

        expect(view.instance_variable_get(:@nav)).to eq('your_work')
      end
    end
  end
end
