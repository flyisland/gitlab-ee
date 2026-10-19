# frozen_string_literal: true

module JH
  module Sms
    module AreaCode
      MAINLAND = '+86'
      HONGKONG = '+852'
      MACAO = '+853'

      private

      def mainland?(phone)
        phone.start_with? MAINLAND
      end

      def hongkong?(phone)
        phone.start_with? HONGKONG
      end

      def macao?(phone)
        phone.start_with? MACAO
      end

      def with_valid_area_code?(phone)
        (1..3).each do |i|
          return true if JH::Sms.config.area_codes.include?(phone[0..i])
        end

        false
      end
    end
  end
end
