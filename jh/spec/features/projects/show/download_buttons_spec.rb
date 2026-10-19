# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Projects > Show > Download buttons' do
  let(:user) { create(:user, :with_namespace) }
  let(:role) { :developer }
  let(:status) { 'success' }
  let(:tag) { 'v1.0.0' }
  let(:project) { create(:project, :repository) }

  let(:pipeline) do
    create(:ci_pipeline,
      project: project,
      sha: project.commit(tag).sha,
      ref: tag,
      status: status)
  end

  let!(:build) do
    create(:ci_build, :success, :artifacts,
      pipeline: pipeline,
      status: pipeline.status,
      name: 'build')
  end

  before do
    sign_in(user)
    project.add_role(user, role)
    stub_licensed_features(disable_download_button: true)
  end

  context 'when `disable_download_button` is enabled' do
    before do
      stub_application_setting(disable_download_button: true)
    end

    let(:path_to_visit) { project_path(project) }
    let(:ref) { project.default_branch }

    context 'when static objects external storage is enabled' do
      before do
        allow_any_instance_of(ApplicationSetting).to receive(:static_objects_external_storage_url).and_return('https://cdn.gitlab.com')
        visit path_to_visit
      end

      context 'in private project' do
        it 'hides archive download buttons with external storage URL prepended ' \
          'and user token appended to their href' do
          Gitlab::Workhorse::ARCHIVE_FORMATS.each do |format|
            path = archive_path(project, ref, format)
            uri = URI('https://cdn.gitlab.com')
            uri.path = path
            uri.query = "token=#{user.static_object_token}"

            expect(page).not_to have_link format, href: uri.to_s
          end
        end
      end

      context 'in public project' do
        let(:project) { create(:project, :repository, :public) }

        it 'hides archive download buttons with external storage URL prepended to their href' do
          Gitlab::Workhorse::ARCHIVE_FORMATS.each do |format|
            path = archive_path(project, ref, format)
            uri = URI('https://cdn.gitlab.com')
            uri.path = path

            expect(page).not_to have_link format, href: uri.to_s
          end
        end
      end
    end

    context 'when static objects external storage is disabled' do
      before do
        visit path_to_visit
      end

      it 'hides default archive download buttons' do
        Gitlab::Workhorse::ARCHIVE_FORMATS.each do |format|
          path = archive_path(project, ref, format)

          expect(page).not_to have_link format, href: path
        end
      end
    end

    def archive_path(project, ref, format)
      project_archive_path(project, id: "#{ref}/#{project.path}-#{ref}", path: nil, format: format)
    end
  end
end
