# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Home when HA is blocked' do
  before do
    allow_any_instance_of(ApplicationController)
      .to receive(:should_block_instance?)
      .and_return(true)
  end

  it 'renders the HA unavailable error page on root path' do
    get root_path

    expect(response).to have_http_status(:payment_required)
    expect(response.body).to include('高可用架构不可用')
    expect(response.body).to include('购买新订阅')
  end
end
