# frozen_string_literal: true

module JH
  # User JH mixin
  #
  # This module is intended to encapsulate JH-specific model logic
  # and be prepended in the  model

  module Project
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Utils::StrongMemoize

    UPSTREAM_DISABLED_JH_INTEGRATIONS = %w[zentao].freeze

    prepended do
      include ContentValidateable
      validates :title, :description, content_validation: true, if: :should_validate_content?
      has_one :dingtalk_integration, class_name: 'Integrations::Dingtalk'
      has_one :feishu_integration, class_name: 'Integrations::Feishu'
      has_one :ones_integration, class_name: 'Integrations::Ones'
      has_one :shimo_integration, class_name: 'Integrations::Shimo'
      has_one :feishu_bot_integration, class_name: 'Integrations::FeishuBot'
      has_one :ligaai_integration, class_name: 'Integrations::Ligaai'
      has_one :wecom_integration, class_name: 'Integrations::Wecom'

      with_options to: :project_setting do
        delegate :has_shimo?
      end

      def breadcrumbs
        path_parts = full_path.split('/')
        path_parts.map.with_index do |path, index|
          {
            text: path,
            href: "/#{path_parts[0..index].join('/')}"
          }
        end
      end

      private

      def should_validate_content?
        !private? && super
      end
    end

    override :after_import
    def after_import
      super

      return unless ::ContentValidation::Setting.check_enabled?(self)

      ::ContentValidation::ContainerService.new(container: self, user: creator).execute
      ::ContentValidation::ContainerService.new(container: wiki, user: creator).execute if wiki.exists?
      ::ContentValidation::ProjectScanWorker.perform_async(id)
    end

    # rubocop:disable Gitlab/StrongMemoizeAttr -- override upstream strong_memoize key
    override :licensed_feature_available?
    def licensed_feature_available?(feature, _user = nil)
      available_features = strong_memoize(:jh_licensed_feature_available) do
        Hash.new do |h, f|
          h[f] = load_licensed_feature_available(f)
        end
      end

      available_features[feature]
    end
    # rubocop:enable Gitlab/StrongMemoizeAttr

    override :ci_template_variables
    def ci_template_variables
      return super if ::Gitlab.hk?

      ::Gitlab::Ci::Variables::Collection.new.tap do |variables|
        variables.append(key: 'CI_TEMPLATE_REGISTRY_HOST', value: 'registry.gitlab.cn')
      end
    end

    def import_from_gitee?
      'gitee' == import_type
    end

    def pages_available?
      if ::Gitlab::Saas.enabled?
        ::Gitlab::Pages.enabled? && jh_pages_enabled?
      else
        ::Gitlab::Pages.enabled?
      end
    end

    override :disabled_integrations
    def disabled_integrations
      # rubocop:disable Gitlab/StrongMemoizeAttr -- override upstream strong_memoize key
      disabled_integrations = []
      disabled_integrations << 'ligaai' unless ::Feature.enabled?(:integration_with_ligaai_issues, self)
      disabled_integrations << 'wecom' unless ::Feature.enabled?(:wecom_integration, self)

      disabled_integrations << 'zentao' unless licensed_feature_available?(:zentao_issues_integration)
      disabled_integrations << 'ones' unless licensed_feature_available?(:ones_issues_integration)
      strong_memoize(:jh_disabled_integrations) do
        super - UPSTREAM_DISABLED_JH_INTEGRATIONS + disabled_integrations
      end
      # rubocop:enable Gitlab/StrongMemoizeAttr
    end

    def jh_pages_enabled?
      ::Feature.enabled?(:jh_pages, self) || ::Feature.enabled?(:jh_pages, root_namespace)
    end

    override :merge_method
    def merge_method
      return super unless ::Feature.enabled?(:single_squash_merge_ff, self)

      return :single_squash_merge if merge_requests_ff_only_enabled? &&
        !merge_requests_rebase_enabled? &&
        squash_option == 'always'

      super
    end

    override :merge_method=
    def merge_method=(method)
      if method.to_sym == :single_squash_merge && ::Feature.enabled?(:single_squash_merge_ff, self)
        set_single_squash_merge
      else
        super
      end
    end

    override :ff_merge_must_be_possible?
    def ff_merge_must_be_possible?
      return super unless ::Feature.enabled?(:single_squash_merge_ff, self)

      merge_method.in? [:ff, :rebase_merge]
    end

    def set_single_squash_merge
      self.squash_option = 'always'
      self.merge_requests_ff_only_enabled = true
      self.merge_requests_rebase_enabled = false
    end
  end
end
