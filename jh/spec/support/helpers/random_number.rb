# frozen_string_literal: true

module RandomNumberString
  def random_number_string(len)
    Array.new(len) { rand(0..9) }.join
  end
end
