# frozen_string_literal: true

class WhatsNewPlacementExperiment < ApplicationExperiment
  control
  variant(:candidate)

  private

  def control_behavior; end
  def candidate_behavior; end
end
