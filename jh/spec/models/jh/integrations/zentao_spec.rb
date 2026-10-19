# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Integrations::Zentao do
  include Gitlab::Routing

  let(:zentao_integration) { create(:zentao_integration) }

  describe '#help' do
    it 'renders help information' do
      expect(zentao_integration.help).to include 'https://docs.gitlab.cn/jh/user/project/integrations/zentao.html'
    end
  end
end
