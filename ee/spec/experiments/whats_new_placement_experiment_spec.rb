# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WhatsNewPlacementExperiment, :experiment, feature_category: :onboarding do
  it_behaves_like 'defines control and candidate variants'
end
