# frozen_string_literal: true

module Ai
  module ModelSelection
    class UpdateNamespaceFeatureSettingService
      include Gitlab::InternalEventsTracking

      def initialize(feature_setting, user, params)
        @feature_setting = feature_setting
        @user = user
        @params = params
        @namespace = feature_setting.namespace
        # This class is misnamed. It only works for SAAS, namespace model selection
        # TODO: Rename class Ai::ModelSelection::Namespace::UpdateService https://gitlab.com/gitlab-org/gitlab/-/merge_requests/210463#note_2852763821
      end

      def execute
        return unless ::Gitlab::Saas.feature_available?(:gitlab_duo_saas_only)

        update_params = { offered_model_ref: params[:offered_model_ref] }

        fetch_model_definition = Ai::ModelSelection::FetchModelDefinitionsService
                                   .new(user, model_selection_scope: namespace)
                                   .execute

        return ServiceResponse.error(message: fetch_model_definition.message) if fetch_model_definition.error?

        update_params[:model_definitions] = merge_dev_selectable_models(fetch_model_definition.payload)

        if feature_setting.update(update_params)
          record_audit_event
          track_update_event

          ServiceResponse.success(payload: feature_setting)
        else
          ServiceResponse.error(payload: feature_setting,
            message: feature_setting.errors.full_messages.join(", "))
        end
      end

      private

      attr_accessor :feature_setting, :user, :namespace, :params

      def merge_dev_selectable_models(model_definitions)
        return model_definitions unless use_dev_overrides?(model_definitions)

        model_definitions = model_definitions.deep_dup

        model_definitions['unit_primitives']&.each do |unit_primitive|
          dev_config = unit_primitive['dev']
          next unless dev_config

          dev_models = dev_config['selectable_models']
          next if dev_models.blank?

          base_models = unit_primitive['selectable_models'] || []
          unit_primitive['selectable_models'] = (base_models + dev_models).uniq
        end

        model_definitions
      end

      def use_dev_overrides?(model_definitions)
        return false unless ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)
        return false unless user&.gitlab_team_member?

        group_id = namespace&.id
        return false if group_id.blank?

        model_definitions['unit_primitives']&.any? do |unit_primitive|
          dev_group_ids = unit_primitive.dig('dev', 'group_ids')
          dev_group_ids.present? && dev_group_ids.include?(group_id)
        end
      end

      def record_audit_event
        model = params[:offered_model_ref]
        feature = feature_setting.feature
        scope_type = namespace.class.name
        scope_id = namespace.id

        audit_context = {
          name: 'model_selection_feature_changed',
          author: user,
          scope: namespace,
          target: namespace,
          message: "The LLM #{model} has been selected for the feature #{feature} of #{scope_type} with ID #{scope_id}",
          additional_details: {
            model_ref: model,
            feature: feature
          }
        }

        ::Gitlab::Audit::Auditor.audit(audit_context)
      end

      def track_update_event
        selection_scope_gid = namespace.to_global_id.to_s

        track_internal_event(
          'update_model_selection_feature',
          user: user,
          additional_properties: {
            label: params[:offered_model_ref],
            property: feature_setting.feature,
            selection_scope_gid: selection_scope_gid
          }
        )
      end
    end
  end
end
