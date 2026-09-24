# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::GitAccess, :aggregate_failures do
  let(:user) { create(:user, :with_namespace) }
  let(:actor) { user }
  let(:project) { create(:project, :repository) }
  let(:repository_path) { "#{project.full_path}.git" }
  let(:protocol) { 'ssh' }
  let(:authentication_abilities) { %i[read_project download_code push_code] }
  let(:redirected_path) { nil }
  let(:auth_result_type) { nil }
  let(:changes) { Gitlab::GitAccess::ANY }
  let(:push_access_check) { access.check('git-receive-pack', changes) }
  let(:pull_access_check) { access.check('git-upload-pack', changes) }

  let(:access_class) do
    Class.new(described_class) do
      def push_ability
        :push_code
      end

      def download_ability
        :download_code
      end
    end
  end

  describe 'phone verification' do
    shared_examples 'access with verifing phone' do
      let(:actions) do
        [-> { pull_access_check },
          -> { push_access_check }]
      end

      context 'when it is not JH SaaS' do
        it 'allows access' do
          actions.each do |action|
            expect { action.call }.not_to raise_error
          end
        end
      end

      context 'when it is JH SaaS', :saas, :phone_verification_code_enabled do
        it 'blocks access when the user did not verify phone' do
          actions.each do |action|
            expect { action.call }.to raise_forbidden(/must verify your phone in order to perform this action/)
          end
        end

        it 'allows access when the user verified phone' do
          user.update!(phone: 'phone')

          actions.each do |action|
            expect { action.call }.not_to raise_error
          end
        end
      end
    end

    describe 'as an anonymous user to a public project' do
      let(:actor) { nil }
      let(:project) { create(:project, :public, :repository) }

      it { expect { pull_access_check }.not_to raise_error }
    end

    describe 'as a guest to a public project' do
      let(:project) { create(:project, :public, :repository) }

      it_behaves_like 'access with verifing phone' do
        let(:actions) { [-> { pull_access_check }] }
      end
    end

    describe 'as a reporter to the project' do
      before do
        project.add_reporter(user)
      end

      it_behaves_like 'access with verifing phone' do
        let(:actions) { [-> { pull_access_check }] }
      end
    end

    describe 'as a developer of the project' do
      before do
        project.add_developer(user)
      end

      it_behaves_like 'access with verifing phone'
    end

    describe 'as a maintainer of the project' do
      before do
        project.add_maintainer(user)
      end

      it_behaves_like 'access with verifing phone'
    end

    describe 'as an owner of the project' do
      let(:project) { create(:project, :repository, namespace: user.namespace) }

      it_behaves_like 'access with verifing phone'
    end

    describe 'when a ci build clones the project' do
      let(:protocol) { 'http' }
      let(:authentication_abilities) { [:build_download_code] }
      let(:auth_result_type) { :build }

      before do
        project.add_developer(user)
      end

      it "doesn't block http pull" do
        aggregate_failures do
          expect { pull_access_check }.not_to raise_error
        end
      end
    end
  end

  private

  def access
    access_class.new(actor, project, protocol,
      authentication_abilities: authentication_abilities,
      repository_path: repository_path,
      redirected_path: redirected_path, auth_result_type: auth_result_type)
  end

  def raise_forbidden(message)
    raise_error(described_class::ForbiddenError, message)
  end
end
