# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Snippets::UpdateService do
  describe '#execute' do
    let_it_be(:user) { create(:user) }
    let_it_be(:project) { create(:project) }

    let(:base_opts) do
      {
        title: 'Test snippet',
        file_name: 'snippet.rb',
        content: 'puts "hello world"',
        visibility_level: Gitlab::VisibilityLevel::PUBLIC
      }
    end

    let(:extra_opts) { {} }
    let(:options) { base_opts.merge(extra_opts) }
    let(:updater) { user }
    let(:spam_params) { double }
    let(:service) do
      described_class.new(project: project, current_user: updater, params: options, perform_spam_check: true)
    end

    subject { service.execute(snippet) }

    before_all do
      project.add_developer(user)
    end

    context "in content validation" do
      before do
        allow(ContentValidation::Setting).to receive(:check_enabled?).and_return(true)
      end

      context 'when update visibility level private to public' do
        let!(:snippet) { create(:project_snippet, :repository, :private, author: user, project: project) }
        let(:extra_opts) { { visibility_level: Gitlab::VisibilityLevel::PUBLIC } }

        it 'call ContentValidation::ContainerService#execute' do
          expect(ContentValidation::ContainerService).to receive(:new)
          .with(hash_including(container: snippet, user: user)).ordered.and_call_original

          subject
        end
      end

      context 'when update visibility level private to internal' do
        let!(:snippet) { create(:project_snippet, :repository, :private, author: user, project: project) }
        let(:extra_opts) { { visibility_level: Gitlab::VisibilityLevel::INTERNAL } }

        it 'call ContentValidation::ContainerService#execute' do
          expect(ContentValidation::ContainerService).to receive(:new)
          .with(hash_including(container: snippet, user: user)).ordered.and_call_original

          subject
        end
      end
    end
  end
end
