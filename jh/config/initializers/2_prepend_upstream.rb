# frozen_string_literal: true

# MR: https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/3220
# rubocop: disable Cop/InjectEnterpriseEditionModule
Gitlab.jh do
  CountriesController.prepend_mod
  PreferredLanguageSwitcherHelper.prepend_mod

  Nav::GitlabDuoSettingsPage.prepend_mod_with('Nav::GitlabDuoSettingsPage')

  TrialRegistrationsHelper.prepend_mod
  MergeRequests::PushOptionsHandlerService.prepend_mod
  Gitlab::PushOptions.prepend_mod
  Gitlab::Database::RetentionPolicy.prepend_mod

  GitlabSubscriptions::UploadLicenseService.prepend_mod
  GitlabSubscriptions::SystemDefined::Plan.prepend_mod
  CloudConnector::CatalogDataLoader.prepend_mod

  Gitlab::Llm::AiGateway::ModelMetadata.prepend_mod

  Gitlab::JsRoutes.prepend_mod
  Gitlab::Saas.prepend_mod
  Gitlab::Llm::AiGateway::AgentPlatform::ModelMetadata.prepend_mod

  Ai::DuoWorkflows::StartWorkflowService.prepend_mod
  Ai::FlowTriggers::RunService.prepend_mod
  Ai::Catalog::FoundationalFlow.prepend_mod
  Ai::Catalog::ItemConsumers::CreateService.prepend_mod
  Gitlab::Ai::Catalog::ThirdPartyFlows::Seeder.prepend_mod

  Ai::SelfHostedDapBilling.prepend_mod

  # ViewComponents are loaded lazily, so prepend_mod must run after autoloading is ready.
  Gitlab::Application.config.to_prepare do
    jh_module = JH::SeatAlert::Namespace::BaseComponent

    next if SeatAlert::Namespace::BaseComponent <= jh_module

    SeatAlert::Namespace::BaseComponent.prepend_mod
  end
end
# rubocop:enable Cop/InjectEnterpriseEditionModule
