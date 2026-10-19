# frozen_string_literal: true

module JH
  module IssuablesDescriptionTemplatesHelper
    extend ::Gitlab::Utils::Override

    override :selected_template_name
    def selected_template_name(template_names)
      if ::Feature.enabled?(:jh_mr_use_target_branch_description_template) && params[:merge_request]
        target_branch = params[:merge_request][:target_branch] || ref_project&.default_branch

        template_base_on_target_branch =
          template_names.find { |tmpl_name| tmpl_name == target_branch }
        return template_base_on_target_branch if template_base_on_target_branch.present?
      end

      super
    end
  end
end
