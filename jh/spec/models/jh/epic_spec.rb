# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Epic do
  describe 'validations' do
    it_behaves_like "content validation", :epic, :title
    it_behaves_like "content validation", :epic, :description
  end
end
