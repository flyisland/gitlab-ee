# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::Sms::TencentSms do
  describe '.validate_phone_number!' do
    it 'is ok if phone is China Mainland/HongKong/Macao' do
      expect { described_class.validate_phone_number!("+8615623886888") }.not_to raise_error
      expect { described_class.validate_phone_number!("+85292318788") }.not_to raise_error
      expect { described_class.validate_phone_number!("+85292318799") }.not_to raise_error
    end

    it 'is ok if phone area code is valid' do
      expect { described_class.validate_phone_number!("+192318799") }.not_to raise_error
      expect { described_class.validate_phone_number!("+8192318799") }.not_to raise_error
      expect { described_class.validate_phone_number!("+4792318799") }.not_to raise_error
      expect { described_class.validate_phone_number!("+3392318799") }.not_to raise_error
    end

    it 'raises an error if phone includes illigal chars' do
      expect { described_class.validate_phone_number!("+86-<javascript>") }.to \
        raise_error(described_class::PhoneNumberError, "Invalid Phone Number")
    end

    it 'raises an error if phone is unsupported region' do
      expect { described_class.validate_phone_number!("+8540861212") }.to \
        raise_error(described_class::PhoneNumberError, "Unsupported Region Phone Number")
    end

    it 'raises an error if length of China Mainland phone is not 14' do
      expect { described_class.validate_phone_number!("+86156238876") }.to \
        raise_error(described_class::PhoneNumberError, "Invalid China Mainland Phone Number")
    end

    it 'raises an error if length of China HongKong phone is not 11 or 12' do
      expect { described_class.validate_phone_number!("+85212344") }.to \
        raise_error(described_class::PhoneNumberError, "Invalid China HongKong Phone Number")
    end

    it 'raises an error if length of China Macao phone is not 11 or 12' do
      expect { described_class.validate_phone_number!("+85312344") }.to \
        raise_error(described_class::PhoneNumberError, "Invalid China Macao Phone Number")
    end
  end

  describe '.send_code' do
    let(:phone) { '15688886666' }

    it 'returns nil if TC_ID TC_KEY not set' do
      expect(described_class.send_code(phone)).to be_falsey
    end
  end
end
