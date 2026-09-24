# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Topic do
  describe 'validations' do
    it_behaves_like "content validation", :topic, :name
  end
end
