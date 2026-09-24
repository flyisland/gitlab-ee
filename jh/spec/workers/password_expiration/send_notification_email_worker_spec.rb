# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PasswordExpiration::SendNotificationEmailWorker do
  subject(:worker) { described_class.new }

  describe '#perform' do
    it 'execute SendNotificationEmailService' do
      expect_next_instance_of(PasswordExpiration::SendNotificationEmailService) do |service|
        expect(service).to receive(:execute).exactly(:once)
      end

      worker.perform
    end
  end
end
