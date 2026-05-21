# frozen_string_literal: true

module SeatAlert
  class BaseComponent < ViewComponent::Base
    private

    def render_component
      self.class::COMPONENT_BY_STATE.fetch(seat_state).new
    end

    def seat_state
      if remaining_user_count > 0
        :threshold
      elsif remaining_user_count == 0
        :reached
      else
        :overage
      end
    end
  end
end
