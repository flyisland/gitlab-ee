# frozen_string_literal: true

module EE
  module Notes
    module CreateService
      include ::Ai::DuoWorkflows::Concerns::LinkArtifact
      extend ::Gitlab::Utils::Override

      private

      override :when_saved
      def when_saved(note, **)
        super

        workflow = creating_duo_workflow
        return unless workflow

        link_artifact(workflow, note, link_type: :created)
        create_duo_question_decision(note, workflow)
      end

      # The header is client-supplied, so authorize the current user against the workflow
      def creating_duo_workflow
        workflow_id = ::Gitlab::ApplicationContext.current_context_attribute(:duo_workflow_id)
        return unless workflow_id

        workflow = ::Ai::DuoWorkflows::Workflow.find_by_id(workflow_id)
        workflow if workflow && ::Ability.allowed?(current_user, :update_duo_workflow, workflow)
      rescue StandardError => e
        ::Gitlab::ErrorTracking.track_exception(e, workflow_id: workflow_id)
        nil
      end

      def create_duo_question_decision(note, workflow)
        ::WorkItems::Decisions::CreateFromDuoQuestionService.new(
          note: note,
          workflow: workflow,
          current_user: current_user
        ).execute
      rescue StandardError => e
        ::Gitlab::ErrorTracking.track_exception(e, workflow_id: workflow.id, note_id: note.id)
      end

      override :track_event
      def track_event(note, user)
        track_note_creation_usage_for_epics(user, note) if note.for_epic?

        super(note, user)
      end

      def track_note_creation_usage_for_epics(user, note)
        ::Gitlab::UsageDataCounters::EpicActivityUniqueCounter.track_epic_note_created_action(
          author: user,
          namespace: note.noteable.group
        )
      end
    end
  end
end
