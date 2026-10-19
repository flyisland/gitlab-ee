# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UserStatus do
  describe 'validations' do
    it_behaves_like "content validation", :user_status, :message
  end
end
