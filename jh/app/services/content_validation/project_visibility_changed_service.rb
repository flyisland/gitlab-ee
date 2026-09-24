# frozen_string_literal: true

module ContentValidation
  class ProjectVisibilityChangedService
    attr_reader :project

    def initialize(project, user)
      @project = project
      @user = user
      @content_invalid_object = nil
    end

    def execute
      return unless ::ContentValidation::Setting.check_enabled?(project)
      return if content_validation_pass?

      project_params = ActionController::Parameters
                        .new({ visibility_level: ::Gitlab::VisibilityLevel::PRIVATE })
                        .permit(:visibility_level)
      ::Projects::UpdateService.new(@project, @user, project_params).execute

      Notify.rollback_visibility_level_email(@project.id, @user.id, @content_invalid_object).deliver_later
    end

    def content_validation_pass?
      project_content_validation_pass? &&
        relations_content_vallidation_pass?(project.issues) &&
        relations_content_vallidation_pass?(project.notes) &&
        relations_content_vallidation_pass?(project.merge_requests)
    end

    def project_content_validation_pass?
      project_valid = check_content_validation_by_object?(project)
      @content_invalid_object = project unless project_valid
      project_valid
    end

    def relations_content_vallidation_pass?(relations)
      pass = true
      relations.find_each do |obj|
        unless check_content_validation_by_object?(obj)
          pass = false
          @content_invalid_object = obj
          break
        end
      end
      pass
    end

    private

    def check_content_validation_by_object?(obj)
      # We don't add content validation into Note model
      if obj.is_a?(Note)
        content = obj.note
      else
        content_attributes = content_validation_attributes_by_object(obj)
        content = obj.attributes.values_at(*content_attributes).compact.join("\n")
      end

      content_validation_service.valid?(content)
    end

    def content_validation_attributes_by_object(obj)
      obj.class.validators.select { |x| x.is_a?(ContentValidationValidator) }.flat_map(&:attributes).map(&:to_s)
    end

    def content_validation_service
      @content_validation_service ||= ContentValidationService.new
    end
  end
end
