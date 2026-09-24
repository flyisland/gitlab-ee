# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UserDetail do
  describe 'validations' do
    it_behaves_like "content validation", :user_detail, :pronouns
    it_behaves_like "content validation", :user_detail, :pronunciation
    it_behaves_like "content validation", :user_detail, :job_title
    it_behaves_like "content validation", :user_detail, :bio
    it_behaves_like "content validation", :user_detail, :linkedin
    it_behaves_like "content validation", :user_detail, :twitter
    it_behaves_like "content validation", :user_detail, :location
    it_behaves_like "content validation", :user_detail, :company
  end
end
