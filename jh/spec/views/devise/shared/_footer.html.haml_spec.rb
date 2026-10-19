# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'devise/shared/_footer' do
  include ApplicationHelper

  before do
    render partial: 'devise/shared/footer', formats: [:html]
  end

  context 'when footer renders as JH edition' do
    it 'renders About JiHu GitLab' do
      expect(rendered).to have_content(_('About GitLab'))
    end
  end
end
