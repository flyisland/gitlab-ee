# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Search::Zoekt::IndexingSettingsService, :silence_stdout, feature_category: :global_search do
  let(:logger) { instance_double(Logger, info: nil, error: nil) }
  let(:service) { described_class.new(logger: logger) }

  describe '#index' do
    let(:update_service) { instance_double(ApplicationSettings::UpdateService, execute: true) }

    before do
      allow(ApplicationSettings::UpdateService).to receive(:new).and_return(update_service)
      allow(logger).to receive(:info)
    end

    context 'when everything is already enabled' do
      before do
        stub_application_setting(
          zoekt_indexing_enabled: true,
          zoekt_search_enabled: true,
          zoekt_auto_index_root_namespace: true,
          zoekt_indexing_paused: false
        )
      end

      it 'logs that everything is already enabled' do
        expect(logger).to receive(:info).with(anything)
        expect(update_service).not_to receive(:execute)

        service.index
      end
    end

    context 'when everything is disabled' do
      before do
        stub_application_setting(
          zoekt_indexing_enabled: false,
          zoekt_search_enabled: false,
          zoekt_auto_index_root_namespace: false,
          zoekt_indexing_paused: false
        )
      end

      it 'enables indexing, search, auto-indexing, and unpauses' do
        expect(ApplicationSettings::UpdateService).to receive(:new).with(
          Gitlab::CurrentSettings.current_application_settings,
          nil,
          {
            zoekt_indexing_enabled: true,
            zoekt_search_enabled: true,
            zoekt_auto_index_root_namespace: true,
            zoekt_indexing_paused: false
          }
        ).and_return(update_service)
        expect(update_service).to receive(:execute)
        expect(logger).to receive(:info).at_least(:once)

        service.index
      end
    end

    context 'when indexing is enabled but search and auto-indexing are disabled' do
      before do
        stub_application_setting(
          zoekt_indexing_enabled: true,
          zoekt_search_enabled: false,
          zoekt_auto_index_root_namespace: false,
          zoekt_indexing_paused: false
        )
      end

      it 'enables search, auto-indexing, and unpauses' do
        expect(ApplicationSettings::UpdateService).to receive(:new).with(
          Gitlab::CurrentSettings.current_application_settings,
          nil,
          {
            zoekt_indexing_enabled: true,
            zoekt_search_enabled: true,
            zoekt_auto_index_root_namespace: true,
            zoekt_indexing_paused: false
          }
        ).and_return(update_service)
        expect(update_service).to receive(:execute)
        expect(logger).to receive(:info).at_least(:once)

        service.index
      end
    end

    context 'when everything is enabled but indexing is paused' do
      before do
        stub_application_setting(
          zoekt_indexing_enabled: true,
          zoekt_search_enabled: true,
          zoekt_auto_index_root_namespace: true,
          zoekt_indexing_paused: true
        )
      end

      it 'unpauses indexing' do
        expect(ApplicationSettings::UpdateService).to receive(:new).with(
          Gitlab::CurrentSettings.current_application_settings,
          nil,
          {
            zoekt_indexing_enabled: true,
            zoekt_search_enabled: true,
            zoekt_auto_index_root_namespace: true,
            zoekt_indexing_paused: false
          }
        ).and_return(update_service)
        expect(update_service).to receive(:execute)
        expect(logger).to receive(:info).at_least(:once)

        service.index
      end
    end

    context 'when update fails with validation errors' do
      let(:update_service) { instance_double(ApplicationSettings::UpdateService, execute: false) }
      let(:errors) { instance_double(ActiveModel::Errors, any?: true, full_messages: ['Validation error']) }
      let(:app_setting) do
        instance_double(ApplicationSetting,
          errors: errors,
          valid?: false,
          zoekt_indexing_enabled?: false,
          zoekt_search_enabled?: false,
          zoekt_auto_index_root_namespace?: false,
          zoekt_indexing_paused?: false)
      end

      before do
        allow(Gitlab::CurrentSettings).to receive(:current_application_settings).and_return(app_setting)
        allow(ApplicationSettings::UpdateService).to receive(:new).and_return(update_service)
      end

      it 'logs an error and returns false' do
        expect(logger).to receive(:error).with(/Failed to update Zoekt settings/)
        expect(logger).to receive(:error).with(/Validation errors: Validation error/)

        result = service.index

        expect(result).to be false
      end
    end

    context 'when update fails without validation errors' do
      let(:update_service) { instance_double(ApplicationSettings::UpdateService, execute: false) }
      let(:errors) { instance_double(ActiveModel::Errors, any?: false, full_messages: []) }
      let(:app_setting) do
        instance_double(ApplicationSetting,
          errors: errors,
          valid?: true,
          zoekt_indexing_enabled?: false,
          zoekt_search_enabled?: false,
          zoekt_auto_index_root_namespace?: false,
          zoekt_indexing_paused?: false)
      end

      before do
        allow(Gitlab::CurrentSettings).to receive(:current_application_settings).and_return(app_setting)
        allow(ApplicationSettings::UpdateService).to receive(:new).and_return(update_service)
      end

      it 'logs the failure but not validation errors and returns false' do
        expect(logger).to receive(:error).with(/Failed to update Zoekt settings/)
        expect(logger).not_to receive(:error).with(/Validation errors/)

        result = service.index

        expect(result).to be false
      end
    end
  end

  describe '#disable' do
    let(:update_service) { instance_double(ApplicationSettings::UpdateService, execute: true) }

    before do
      allow(ApplicationSettings::UpdateService).to receive(:new).and_return(update_service)
      allow(logger).to receive(:info)
    end

    context 'when indexing and search are already disabled' do
      before do
        stub_application_setting(zoekt_indexing_enabled: false, zoekt_search_enabled: false)
      end

      it 'logs that everything is already disabled' do
        expect(logger).to receive(:info).with(anything)
        expect(update_service).not_to receive(:execute)

        service.disable
      end
    end

    context 'when indexing and search are enabled' do
      before do
        stub_application_setting(zoekt_indexing_enabled: true, zoekt_search_enabled: true)
      end

      it 'disables indexing and search and logs success' do
        expect(ApplicationSettings::UpdateService).to receive(:new).with(
          Gitlab::CurrentSettings.current_application_settings,
          nil,
          { zoekt_indexing_enabled: false, zoekt_search_enabled: false }
        ).and_return(update_service)
        expect(update_service).to receive(:execute)
        expect(logger).to receive(:info).at_least(:once)

        service.disable
      end
    end

    context 'when only indexing is enabled' do
      before do
        stub_application_setting(zoekt_indexing_enabled: true, zoekt_search_enabled: false)
      end

      it 'disables indexing' do
        expect(ApplicationSettings::UpdateService).to receive(:new).with(
          Gitlab::CurrentSettings.current_application_settings,
          nil,
          { zoekt_indexing_enabled: false, zoekt_search_enabled: false }
        ).and_return(update_service)
        expect(update_service).to receive(:execute)
        expect(logger).to receive(:info).at_least(:once)

        service.disable
      end
    end

    context 'when update fails' do
      let(:update_service) { instance_double(ApplicationSettings::UpdateService, execute: false) }
      let(:errors) { instance_double(ActiveModel::Errors, any?: true, full_messages: ['Validation error']) }
      let(:app_setting) do
        instance_double(ApplicationSetting,
          errors: errors,
          valid?: false,
          zoekt_indexing_enabled?: true,
          zoekt_search_enabled?: true)
      end

      before do
        allow(Gitlab::CurrentSettings).to receive_messages(current_application_settings: app_setting,
          zoekt_indexing_enabled?: true, zoekt_search_enabled?: true)
        allow(ApplicationSettings::UpdateService).to receive(:new).and_return(update_service)
      end

      it 'logs an error and returns false' do
        expect(logger).to receive(:error).with(/Failed to update Zoekt settings/)
        expect(logger).to receive(:error).with(/Validation errors: Validation error/)

        result = service.disable

        expect(result).to be false
      end
    end
  end

  describe '#pause_indexing' do
    let(:update_service) { instance_double(ApplicationSettings::UpdateService, execute: true) }

    before do
      allow(ApplicationSettings::UpdateService).to receive(:new).and_return(update_service)
      allow(logger).to receive(:info)
    end

    context 'when indexing is already paused' do
      before do
        stub_application_setting(zoekt_indexing_paused: true)
      end

      it 'logs that indexing is already paused' do
        expect(logger).to receive(:info).with(anything)
        expect(update_service).not_to receive(:execute)

        service.pause_indexing
      end
    end

    context 'when indexing is not paused' do
      before do
        stub_application_setting(zoekt_indexing_paused: false)
      end

      it 'pauses indexing and logs success' do
        expect(ApplicationSettings::UpdateService).to receive(:new).with(
          Gitlab::CurrentSettings.current_application_settings,
          nil,
          { zoekt_indexing_paused: true }
        ).and_return(update_service)
        expect(update_service).to receive(:execute)
        expect(logger).to receive(:info).at_least(:once)

        service.pause_indexing
      end
    end

    context 'when update fails' do
      let(:update_service) { instance_double(ApplicationSettings::UpdateService, execute: false) }
      let(:errors) { instance_double(ActiveModel::Errors, any?: true, full_messages: ['Validation error']) }
      let(:app_setting) do
        instance_double(ApplicationSetting,
          errors: errors,
          valid?: false,
          zoekt_indexing_paused?: false)
      end

      before do
        allow(Gitlab::CurrentSettings).to receive_messages(current_application_settings: app_setting,
          zoekt_indexing_paused?: false)
        allow(ApplicationSettings::UpdateService).to receive(:new).and_return(update_service)
      end

      it 'logs an error and returns false' do
        expect(logger).to receive(:error).with(/Failed to update Zoekt settings/)
        expect(logger).to receive(:error).with(/Validation errors: Validation error/)

        result = service.pause_indexing

        expect(result).to be false
      end
    end
  end

  describe '#resume_indexing' do
    let(:update_service) { instance_double(ApplicationSettings::UpdateService, execute: true) }

    before do
      allow(ApplicationSettings::UpdateService).to receive(:new).and_return(update_service)
      allow(logger).to receive(:info)
      allow(logger).to receive(:error)
    end

    context 'when indexing is not paused' do
      before do
        stub_application_setting(zoekt_indexing_paused: false)
      end

      it 'logs that indexing is already running' do
        expect(logger).to receive(:info).with(anything)
        expect(update_service).not_to receive(:execute)

        service.resume_indexing
      end
    end

    context 'when indexing is paused but disabled' do
      before do
        stub_application_setting(zoekt_indexing_paused: true, zoekt_indexing_enabled: false)
      end

      it 'logs an error and does not resume' do
        expect(logger).to receive(:error).with(anything)
        expect(update_service).not_to receive(:execute)

        service.resume_indexing
      end
    end

    context 'when indexing is paused and enabled' do
      before do
        stub_application_setting(zoekt_indexing_paused: true, zoekt_indexing_enabled: true)
      end

      it 'resumes indexing and logs success' do
        expect(ApplicationSettings::UpdateService).to receive(:new).with(
          Gitlab::CurrentSettings.current_application_settings,
          nil,
          { zoekt_indexing_paused: false }
        ).and_return(update_service)
        expect(update_service).to receive(:execute)
        expect(logger).to receive(:info).at_least(:once)

        service.resume_indexing
      end
    end

    context 'when update fails' do
      let(:update_service) { instance_double(ApplicationSettings::UpdateService, execute: false) }
      let(:errors) { instance_double(ActiveModel::Errors, any?: true, full_messages: ['Validation error']) }
      let(:app_setting) do
        instance_double(ApplicationSetting,
          errors: errors,
          valid?: false,
          zoekt_indexing_paused?: true,
          zoekt_indexing_enabled?: true)
      end

      before do
        allow(Gitlab::CurrentSettings).to receive_messages(current_application_settings: app_setting,
          zoekt_indexing_paused?: true, zoekt_indexing_enabled?: true)
        allow(ApplicationSettings::UpdateService).to receive(:new).and_return(update_service)
      end

      it 'logs an error and returns false' do
        expect(logger).to receive(:error).with(/Failed to update Zoekt settings/)
        expect(logger).to receive(:error).with(/Validation errors: Validation error/)

        result = service.resume_indexing

        expect(result).to be false
      end
    end
  end

  describe '#reindex_projects' do
    let(:update_service) { instance_double(ApplicationSettings::UpdateService, execute: true) }
    let_it_be(:projects) { create_list(:project, 3) }

    before do
      allow(ApplicationSettings::UpdateService).to receive(:new).and_return(update_service)
      allow(logger).to receive(:info)
    end

    context 'when zoekt_indexing_enabled is false' do
      before do
        stub_ee_application_setting(zoekt_indexing_enabled: false, zoekt_indexing_paused: false)
      end

      it 'logs error and aborts indexing' do
        expect(logger).to receive(:error)
          .with('Cannot perform indexing: Zoekt indexing is disabled. Enable indexing first.')
        expect(Search::Zoekt::IndexingTaskWorker).not_to receive(:perform_async)
        service.reindex_projects
      end
    end

    context 'when zoekt_indexing_paused is true' do
      before do
        stub_ee_application_setting(zoekt_indexing_enabled: true, zoekt_indexing_paused: true)
      end

      it 'logs error and aborts indexing' do
        expect(logger).to receive(:error)
          .with('Cannot perform indexing: Zoekt indexing is paused. Resume indexing first.')
        expect(Search::Zoekt::IndexingTaskWorker).not_to receive(:perform_async)
        service.reindex_projects
      end
    end

    context 'for ENV ID_FROM and ENV ID_TO', :zoekt_settings_enabled do
      let(:project_1_id) { projects[0].id.to_s }
      let(:project_2_id) { projects[1].id.to_s }
      let(:project_3_id) { projects[2].id.to_s }

      using RSpec::Parameterized::TableSyntax

      where(:id_from, :id_to, :reindexed_project_ids) do
        ref(:project_1_id)  | ref(:project_2_id)  | [ref(:project_1_id), ref(:project_2_id)]
        nil                 | nil                 | [ref(:project_1_id), ref(:project_2_id), ref(:project_3_id)]
        nil                 | ref(:project_1_id)  | [ref(:project_1_id)]
        ref(:project_3_id)  | ref(:project_3_id)  | [ref(:project_3_id)]
        ref(:project_2_id)  | ref(:project_1_id)  | []
        '-1'                | ref(:project_1_id)  | [ref(:project_1_id)]
        'foo'               | ref(:project_1_id)  | []
      end

      with_them do
        before do
          stub_env('ID_FROM', id_from)
          stub_env('ID_TO', id_to)
        end

        it 'performs force reindexing for the range of projects' do
          expect(logger).to receive(:info).with('Enqueueing projects for force reindexing...')
          expect(logger).to receive(:info)
            .with("#{reindexed_project_ids.size} project(s) have been enqueued for force reindexing...")
          reindexed_project_ids.each do |id|
            expect(Search::Zoekt::IndexingTaskWorker).to receive(:perform_async).with(id.to_i, 'force_index_repo')
          end
          service.reindex_projects
        end
      end
    end
  end
end
