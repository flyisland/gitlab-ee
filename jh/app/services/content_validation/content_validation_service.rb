# frozen_string_literal: true

# call extra api for string validate
module ContentValidation
  class ContentValidationService
    def valid?(str)
      client.valid?(str)
    end

    private

    def client
      @client ||= Gitlab::ContentValidation::Client.new
    end
  end
end
