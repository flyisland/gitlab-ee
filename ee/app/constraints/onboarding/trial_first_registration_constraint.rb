# frozen_string_literal: true

module Onboarding
  class TrialFirstRegistrationConstraint
    include Gitlab::Experiment::Dsl

    def matches?(request)
      return false unless Gitlab::Saas.feature_available?(:onboarding)
      # This covers the case of snowplow partial calling this and our referrer is always filled out
      # for our assignment case anyway.
      # This way the mock request that the `masked_referrer_url(request.referer)` uses won't cause us
      # to hit the experiment block and perhaps unintentionally perform a reassignment.
      return false if request.referer.nil?
      return false unless ::Gitlab::Utils.to_boolean(request.params[:from_sign_in], default: false)

      # rubocop:disable Cop/ExperimentsTestCoverage -- stub_experiments don't work because of request
      experiment(:trial_first_registration, actor: nil, request: request) do |e|
        e.control { false }
        e.candidate { true }
        e.track(:render_signup)
      end.run
      # rubocop:enable Cop/ExperimentsTestCoverage
    end
  end
end
