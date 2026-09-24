# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::RackAttack::LabkitRateLimit::ClassifiedRequest, feature_category: :rate_limiting do
  using RSpec::Parameterized::TableSyntax

  let(:request) { described_class.new(Rack::MockRequest.env_for('/')) }

  describe '#labkit_facts' do
    describe 'incident management notification enable setting' do
      it 'exposes the enable setting the incident rule matches on' do
        stub_application_setting(throttle_incident_management_notification_enabled: true)

        expect(request.labkit_facts).to include(setting_incident_management_notification: true)
      end

      it 'reflects the disabled setting' do
        stub_application_setting(throttle_incident_management_notification_enabled: false)

        expect(request.labkit_facts).to include(setting_incident_management_notification: false)
      end
    end

    # The geo-JWT skips are exposed as an EE fact for the should_be_skipped
    # path/JWT decomposition (the EE geo skip rule matches it). It lives in the EE
    # classifier (not CE) because the two predicates are EE-only - referencing them
    # from CE would raise under FOSS.
    describe 'the verified_geo_request fact' do
      it 'is true for a verified Geo request' do
        allow(request).to receive(:verified_geo_request?).and_return(true)

        expect(request.labkit_facts).to include(verified_geo_request: true)
      end

      it 'is true for a geo-proxy workhorse request' do
        allow(request).to receive_messages(verified_geo_request?: false, geo_proxy_workhorse_request?: true)

        expect(request.labkit_facts).to include(verified_geo_request: true)
      end

      it 'is false for a normal request' do
        allow(request).to receive_messages(verified_geo_request?: false, geo_proxy_workhorse_request?: false)

        expect(request.labkit_facts).to include(verified_geo_request: false)
      end
    end

    describe 'the unauthenticated throttle facts' do
      # Row 3: enforce alone does nothing, so info is the single off switch.
      where(:info, :enforce, :active_fact, :enforced_fact) do
        false | false | false | false
        true  | false | true  | false
        false | true  | false | false
        true  | true  | true  | true
      end

      with_them do
        it 'matches the flag state table for the unauthenticated throttle', :aggregate_failures do
          stub_feature_flags(
            rate_limiter_unauthenticated_limits_info: info,
            rate_limiter_unauthenticated_limits_enforce: enforce
          )

          expect(request.labkit_facts).to include(
            unauthenticated_limits_active: active_fact,
            unauthenticated_enforced: enforced_fact
          )
        end
      end

      it 'is strictly false rather than nil while both flags are off', :aggregate_failures do
        stub_feature_flags(
          rate_limiter_unauthenticated_limits_info: false,
          rate_limiter_unauthenticated_limits_enforce: false
        )

        facts = request.labkit_facts

        expect(facts[:unauthenticated_limits_active]).to be(false)
        expect(facts[:unauthenticated_enforced]).to be(false)
      end
    end

    # The dependency_proxy fact routes the Labkit rule through
    # #dependency_proxy_path?, so EE's virtual-registry exclusion applies to both
    # enforcement stacks from one definition rather than a mirrored path regex.
    describe 'the dependency_proxy fact' do
      def facts_for(path)
        described_class.new(Rack::MockRequest.env_for(path)).labkit_facts
      end

      it 'is true for a dependency proxy manifest path' do
        expect(facts_for('/v2/mygroup/dependency_proxy/containers/alpine/manifests/latest'))
          .to include(dependency_proxy: true)
      end

      it 'is false for a virtual registry container path' do
        expect(facts_for('/v2/virtual_registries/container/1/dependency_proxy/containers/img/manifests/latest'))
          .to include(dependency_proxy: false)
      end

      it 'is false for an unrelated path' do
        expect(facts_for('/dashboard/projects')).to include(dependency_proxy: false)
      end
    end
  end
end
