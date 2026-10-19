# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'layouts/header/_start_trial', feature_category: :navigation do
  context 'when trials_allowed? is true' do
    before do
      allow(view).to receive(:trials_allowed?).and_return(true)
    end

    it 'has a "Upgrade subscription" link' do
      render

      expect(rendered).to have_link(
        s_("CurrentUser|Upgrade subscription"),
        href: '/-/trials/new?glm_content=top-right-dropdown&glm_source=jihulab.com'
      )
    end
  end
end
