# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WikiPages::CreateService, feature_category: :wiki do
  it_behaves_like 'WikiPages::Create|Update|DestroyService#execute sends a Geo event update' do
    let(:opts) { { title: 'Title', content: 'Content for wiki page', format: 'markdown' } }

    subject(:service_execute) { described_class.new(container: container, current_user: user, params: opts).execute }
  end

  it_behaves_like 'WikiPages::CreateService#execute', :group
end
