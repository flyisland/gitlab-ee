# frozen_string_literal: true

# MR: https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/3220
# rubocop: disable Cop/InjectEnterpriseEditionModule
Gitlab.jh do
  PreferredLanguageSwitcherHelper.prepend_mod

  Nav::GitlabDuoSettingsPage.prepend_mod_with('Nav::GitlabDuoSettingsPage')

  TrialRegistrationsHelper.prepend_mod
  MergeRequests::PushOptionsHandlerService.prepend_mod
  Gitlab::PushOptions.prepend_mod
  Gitlab::GitalyClient::CommitService.prepend_mod
  Gitlab::Database::RetentionPolicy.prepend_mod

  GitlabSubscriptions::UploadLicenseService.prepend_mod
  GitlabSubscriptions::SystemDefined::Plan.prepend_mod
  CloudConnector::CatalogDataLoader.prepend_mod

  Gitlab::Llm::AiGateway::ModelMetadata.prepend_mod

  Gitlab::JsRoutes.prepend_mod
  Gitlab::Saas.prepend_mod
  Gitlab::Llm::AiGateway::AgentPlatform::ModelMetadata.prepend_mod

  Ai::DuoWorkflows::StartWorkflowService.prepend_mod
  Ai::DuoWorkflows::CreateCompositeOauthAccessTokenService.prepend_mod
  Ai::FlowTriggers::RunService.prepend_mod
  Ai::Catalog::FoundationalFlow.prepend_mod
  Ai::Catalog::Flows::SeedFoundationalFlowsService.prepend_mod
  Ai::Catalog::ItemConsumers::CreateService.prepend_mod

  # Zeitwerk unload drops boot-time prepends together with the class object, so
  # this is re-applied on every reload. Its JH module only extends the class
  # methods, which prepend_mod_once below cannot check for.
  Gitlab::Application.config.to_prepare do
    Ai::Catalog::FoundationalFlow.prepend_mod unless
      Ai::Catalog::FoundationalFlow.singleton_class <= JH::Ai::Catalog::FoundationalFlow::ClassMethods
  end
  Gitlab::Ai::Catalog::ThirdPartyFlows::Seeder.prepend_mod
  Gitlab::TelemetryEndpoint.singleton_class.prepend_mod_with('Gitlab::TelemetryEndpoint')

  Ai::SelfHostedDapBilling.prepend_mod

  # Pass the JH module first so it is loaded before prepend_mod runs.
  # The ancestor check skips a second prepend on later to_prepare runs.
  prepend_mod_once = ->(mod, klass) { klass.prepend_mod unless klass <= mod }

  Gitlab::Application.config.to_prepare do
    prepend_mod_once.call(JH::API::CodeSuggestions, API::CodeSuggestions)
    prepend_mod_once.call(JH::CountriesController, CountriesController)
    prepend_mod_once.call(JH::SeatAlert::Namespace::BaseComponent, SeatAlert::Namespace::BaseComponent)
    prepend_mod_once.call(JH::Ai::Messaging::AdapterRegistry, Ai::Messaging::AdapterRegistry)
    prepend_mod_once.call(JH::Ai::DuoWorkflows::ResolveToolApprovalService, Ai::DuoWorkflows::ResolveToolApprovalService)
    prepend_mod_once.call(JH::Ai::DuoWorkflows::Workflow, Ai::DuoWorkflows::Workflow)
    prepend_mod_once.call(JH::Types::Ai::DuoWorkflows::WorkflowSourceTypeEnum,
      Types::Ai::DuoWorkflows::WorkflowSourceTypeEnum)
  end

  # Registry evaluates routing helpers at class load, so prepend after it is autoloaded.
  Rails.autoloaders.main.on_load('CloudConnector::StatusChecks::Probes::Registry') do |klass|
    klass.prepend_mod unless klass <= JH::CloudConnector::StatusChecks::Probes::Registry
  end
end
# rubocop:enable Cop/InjectEnterpriseEditionModule
