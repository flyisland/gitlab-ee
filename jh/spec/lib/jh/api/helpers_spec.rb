# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::API::Helpers, feature_category: :api do
  include Rack::Test::Methods

  let_it_be(:user) { build(:user) }
  let_it_be(:project) { create(:project) }

  let(:helper) do
    Class.new do
      include API::Helpers
      include API::APIGuard::HelperMethods
      include JH::API::Helpers
    end
  end

  subject { helper.new }

  describe '#require_pages_enabled!' do
    before do
      subject.instance_variable_set(:@initial_current_user, user)

      allow(subject).to receive(:user_project).and_return(project)
      allow(project).to receive(:pages_available?).and_return(pages_enabled)
    end

    context 'when pages are enabled' do
      let(:pages_enabled) { true }

      it 'does not return not found' do
        expect(subject).not_to receive(:not_found!)

        subject.require_pages_enabled!
      end
    end

    context 'when pages are not enabled' do
      let(:pages_enabled) { false }

      it 'returns not found' do
        expect(subject).to receive(:not_found!)

        subject.require_pages_enabled!
      end
    end
  end

  describe '#validate_free_license_ha!' do
    let(:message) do
      '您当前实例订阅状态为极狐GitLab 基础版，并同时使用了专业版及旗舰版中的订阅功能"高可用架构"。请您购买新订阅：https://gitlab.cn/pricing'
    end

    it 'renders 402 when instance should be blocked' do
      allow(subject).to receive(:should_block_instance?).and_return(true)

      expect(subject).to receive(:render_api_error!).with(message, 402)
      subject.validate_free_license_ha!
    end

    it 'does nothing when instance should not be blocked' do
      allow(subject).to receive(:should_block_instance?).and_return(false)

      expect(subject).not_to receive(:render_api_error!)
      subject.validate_free_license_ha!
    end
  end
end
