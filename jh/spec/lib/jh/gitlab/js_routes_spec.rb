# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::Gitlab::JsRoutes, feature_category: :tooling do
  let(:ce_route) do
    instance_double(
      ActionDispatch::Journey::Route,
      name: 'projects',
      source_location: Rails.root.join('config/routes/project.rb:10').to_s
    )
  end

  let(:jh_route) do
    instance_double(
      ActionDispatch::Journey::Route,
      name: 'performance_measurement',
      source_location: Rails.root.join('jh/config/routes/performance_measurement.rb:3').to_s
    )
  end

  let(:cas3_route) do
    instance_double(
      ActionDispatch::Journey::Route,
      name: 'user_cas3_omniauth_authorize',
      source_location: Rails.root.join('config/routes/user.rb:42').to_s
    )
  end

  let(:dingtalk_route) do
    instance_double(
      ActionDispatch::Journey::Route,
      name: 'users_import_dingtalk_callback',
      source_location: Rails.root.join('config/routes/import.rb:9').to_s
    )
  end

  let(:wecom_route) do
    instance_double(
      ActionDispatch::Journey::Route,
      name: 'user_wecom_omniauth_authorize',
      source_location: Rails.root.join('config/routes/user.rb:42').to_s
    )
  end

  let(:routes) { [ce_route, jh_route, cas3_route, dingtalk_route, wecom_route] }

  before do
    allow(Rails.application.routes.routes).to receive(:to_a).and_return(routes)
    allow(::Routing::OrganizationsHelper::MappedHelpers).to receive(:find_route_pairs).and_return({})
  end

  describe '.route_pairs' do
    subject(:route_names) { Gitlab::JsRoutes.route_pairs.map { |global_route, _| global_route.name } }

    it 'excludes routes defined under jh/config/routes' do
      expect(route_names).not_to include('performance_measurement')
    end

    it 'excludes routes derived from JH-only omniauth providers' do
      expect(route_names).not_to include('user_cas3_omniauth_authorize')
      expect(route_names).not_to include('users_import_dingtalk_callback')
      expect(route_names).not_to include('user_wecom_omniauth_authorize')
    end

    it 'keeps CE routes' do
      expect(route_names).to include('projects')
    end
  end
end
