# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::OmniauthInitializer do
  let(:devise_config) { class_double(Devise) }

  subject(:initializer) { described_class.new(devise_config) }

  describe '#execute' do
    it 'configures on_single_sign_out proc for cas3' do
      cas3_config = { 'name' => 'cas3', 'args' => {} }

      expect(devise_config).to receive(:omniauth).with(:cas3, { on_single_sign_out: an_instance_of(Proc) })

      subject.execute([cas3_config])
    end
  end
end
