# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LegacyOnboardingExperiment, :experiment, feature_category: :acquisition do
  it_behaves_like 'defines control and candidate variants'
end
