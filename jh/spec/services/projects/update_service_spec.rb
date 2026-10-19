# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::UpdateService do
  describe '#after_update' do
    context 'in content validation' do
      let(:user) { create(:user, :with_namespace) }
      let(:project) { create(:project, :wiki_repo, creator: user, namespace: user.namespace) }
      let(:wiki) { project.wiki }
      let(:wiki_page) { create(:wiki_page, wiki: wiki) }

      before do
        allow(ContentValidation::Setting).to receive(:check_enabled?).and_return(true)
        project
        wiki_page
      end

      context 'when changing visibility level' do
        context 'when visibility_level changes to INTERNAL' do
          context 'and project is PRIVATE' do
            it 'call ContentValidation::ContainerService' do
              expect(ContentValidation::ContainerService).to receive(:new)
                .with(hash_including(container: project, user: user)).ordered.and_call_original
              expect(ContentValidation::ContainerService).to receive(:new)
                .with(hash_including(container: wiki, user: user)).ordered.and_call_original

              update_project(project, user, visibility_level: Gitlab::VisibilityLevel::INTERNAL)
            end
          end
        end

        context 'when visibility_level changes to PUBLIC' do
          context 'and project is PRIVATE' do
            it 'call ContentValidation::ContainerService' do
              expect(ContentValidation::ContainerService).to receive(:new)
                .with(hash_including(container: project, user: user)).ordered.and_call_original
              expect(ContentValidation::ContainerService).to receive(:new)
                .with(hash_including(container: wiki, user: user)).ordered.and_call_original

              update_project(project, user, visibility_level: Gitlab::VisibilityLevel::PUBLIC)
            end
          end
        end
      end
    end
  end

  def update_project(project, user, opts)
    described_class.new(project, user, opts).execute
  end
end
