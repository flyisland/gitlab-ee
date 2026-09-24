# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ImportHelper do
  describe '#import_gitee_personal_access_token_message' do
    it 'shows the gitee personal access token message' do
      expect(helper.import_gitee_personal_access_token_message).to include('https://gitee.com/profile/personal_access_tokens')
    end
  end
end
