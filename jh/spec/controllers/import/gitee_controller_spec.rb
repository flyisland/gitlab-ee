# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Import::GiteeController, :with_current_organization do
  include ImportSpecHelper

  let(:user) { create(:user, :with_namespace) }

  let_it_be(:token) { "asdasd12345" }
  let_it_be(:refresh_token) { SecureRandom.hex(15) }
  let_it_be(:access_params) { { gitee_access_token: token } }
  let_it_be(:code) { SecureRandom.hex(8) }

  def assign_session_token
    session[:gitee_access_token] = token
  end

  def clear_session_token
    session[:gitee_access_token] = nil
  end

  before do
    sign_in(user)
    allow(controller).to receive(:gitee_import_enabled?).and_return(true)
    stub_feature_flags(require_organization: false)
  end

  describe "GET new" do
    context 'when session key exists' do
      before do
        assign_session_token
      end

      it 'redirects to status_gitee_url' do
        get :new

        expect(controller).to redirect_to(status_import_gitee_url)
      end
    end

    context 'when session key not exists' do
      before do
        clear_session_token
      end

      it 'does not redirect' do
        get :new

        expect(controller).not_to have_http_status(:redirect)
      end
    end
  end

  describe "GET personal_access_token" do
    it 'redirects to new_import_gitee_url when gitee_access_token is blank' do
      get :personal_access_token, params: {}

      expect(controller).to redirect_to(new_import_gitee_url)
      expect(flash[:alert]).to eq(s_('JH|Access token cannot be blank.'))
    end

    it 'redirects to status_import_url when gitee_access_token is valid' do
      allow_next_instance_of(Gitee::Client) do |client|
        allow(client).to receive_message_chain(:user, :username).and_return('Tom')
      end

      get :personal_access_token, params: { personal_access_token: token }

      expect(controller).to redirect_to(status_import_gitee_url)
    end

    it 'redirects to new_import_gitee_url when gitee_access_token is not valid' do
      allow_next_instance_of(Gitee::Client) do |client|
        allow(client).to receive_message_chain(:user, :username).and_return(nil)
      end

      get :personal_access_token, params: { personal_access_token: token }

      expect(controller).to redirect_to(new_import_gitee_url)
    end
  end

  describe "GET status" do
    let(:repo) do
      instance_double(
        Gitee::Representation::Repo,
        name: 'vim',
        slug: 'vim',
        owner: 'asd',
        full_name: 'asd/vim',
        clone_url: 'http://test.host/demo/url.git')
    end

    context "when token is blank" do
      it 'redirects to new_import_gitee_url' do
        clear_session_token
        get :status

        expect(controller).to redirect_to(new_import_gitee_url)
      end
    end

    context "when token is valid" do
      before do
        assign_session_token
      end

      it_behaves_like 'import controller status' do
        let(:repo_id) { repo.full_name }
        let(:import_source) { repo.full_name }

        let_it_be(:client_repos_field) { :repos }
        let_it_be(:provider_name) { 'gitee' }
      end

      it 'returns invalid repos' do
        allow_any_instance_of(Gitee::Client).to receive(:repos).and_return([repo])

        get :status, format: :json

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response['incompatible_repos'].length).to eq(0)
        expect(json_response['provider_repos'].length).to eq(1)
        expect(json_response.dig("provider_repos", 0, "id")).to eq(repo.full_name)
      end

      context 'when filtering' do
        let_it_be(:filter) { '<html>test</html>' }
        let_it_be(:expected_filter) { 'test' }

        subject(:get_status) { get :status, params: { filter: filter }, as: :json }

        it 'passes sanitized filter param to bitbucket client' do
          expect_next_instance_of(Gitee::Client) do |client|
            expect(client).to receive(:repos).with(filter: expected_filter).and_return([repo])
          end

          get_status
        end
      end
    end
  end

  describe "POST create" do
    let(:gitee_username) { user.username }

    let(:gitee_user) do
      instance_double(
        ::Gitee::Representation::User,
        username: gitee_username)
    end

    let(:gitee_repo) do
      instance_double(
        ::Gitee::Representation::Repo,
        slug: "vim",
        owner: gitee_username,
        name: 'vim')
    end

    let(:project) { create(:project) }

    before do
      allow_any_instance_of(Gitee::Client).to receive(:repo).and_return(gitee_repo)
      allow_any_instance_of(Gitee::Client).to receive(:user).and_return(gitee_user)
      assign_session_token
    end

    it 'returns 200 response when the project is imported successfully' do
      allow(Gitlab::GiteeImport::ProjectCreator)
        .to receive(:new).with(gitee_repo, gitee_repo.name, user.namespace, user, access_params)
        .and_return(instance_double(Gitlab::GiteeImport::ProjectCreator, execute: project))

      post :create, format: :json

      expect(response).to have_gitlab_http_status(:ok)
    end

    it 'returns 422 response when the project could not be imported' do
      allow(Gitlab::GiteeImport::ProjectCreator)
        .to receive(:new).with(gitee_repo, gitee_repo.name, user.namespace, user, access_params)
        .and_return(instance_double(Gitlab::GiteeImport::ProjectCreator, execute: build(:project)))

      post :create, format: :json

      expect(response).to have_gitlab_http_status(:unprocessable_entity)
    end

    context "when the repository owner is the Gitee user" do
      context "when the Gitee user and GitLab user's usernames match" do
        it "takes the current user's namespace" do
          expect(Gitlab::GiteeImport::ProjectCreator)
            .to receive(:new).with(gitee_repo, gitee_repo.name, user.namespace, user, access_params)
            .and_return(instance_double(Gitlab::GiteeImport::ProjectCreator, execute: project))

          post :create, format: :json
        end
      end

      context "when the Gitee user and GitLab user's usernames don't match" do
        let_it_be(:gitee_username) { "someone_else" }

        it "takes the current user's namespace" do
          expect(Gitlab::GiteeImport::ProjectCreator)
            .to receive(:new).with(gitee_repo, gitee_repo.name, user.namespace, user, access_params)
            .and_return(instance_double(Gitlab::GiteeImport::ProjectCreator, execute: project))

          post :create, format: :json
        end
      end
    end

    context "when the repository owner is not the Gitee user" do
      let_it_be(:other_username) { "someone_else" }

      before do
        allow(gitee_repo).to receive(:owner).and_return(other_username)
      end

      context "when a namespace with the Bitbucket user's username already exists" do
        let!(:existing_namespace) { create(:group, name: other_username) }

        context "when the namespace is owned by the GitLab user" do
          before do
            existing_namespace.add_owner(user)
          end

          it "takes the existing namespace" do
            expect(Gitlab::GiteeImport::ProjectCreator)
              .to receive(:new).with(gitee_repo, gitee_repo.name, existing_namespace, user, access_params)
              .and_return(instance_double(Gitlab::GiteeImport::ProjectCreator, execute: project))

            post :create, format: :json
          end
        end

        context "when the namespace is not owned by the GitLab user" do
          it "doesn't create a project" do
            expect(Gitlab::GiteeImport::ProjectCreator)
              .not_to receive(:new)

            post :create, format: :json
          end
        end
      end

      context "when a namespace with the Gitee user's username doesn't exist" do
        context "when current user can create namespaces" do
          let(:user) { create(:user, organizations: [current_organization]) }

          it "creates the namespace" do
            expect(Gitlab::GiteeImport::ProjectCreator)
              .to receive(:new).and_return(instance_double(Gitlab::GiteeImport::ProjectCreator, execute: project))

            expect { post :create, format: :json }.to change { Namespace.count }.by(1)
          end

          it "takes the new namespace" do
            expect(Gitlab::GiteeImport::ProjectCreator)
              .to receive(:new).with(gitee_repo, gitee_repo.name, an_instance_of(Group), user, access_params)
              .and_return(instance_double(Gitlab::GiteeImport::ProjectCreator, execute: project))

            post :create, format: :json
          end
        end

        context "when current user can't create namespaces" do
          before do
            user.update_attribute(:can_create_group, false)
          end

          it "doesn't create the namespace" do
            expect(Gitlab::GiteeImport::ProjectCreator)
              .to receive(:new).and_return(instance_double(Gitlab::GiteeImport::ProjectCreator, execute: project))

            expect { post :create, format: :json }.not_to change { Namespace.count }
          end

          it "takes the current user's namespace" do
            expect(Gitlab::GiteeImport::ProjectCreator)
              .to receive(:new).with(gitee_repo, gitee_repo.name, user.namespace, user, access_params)
              .and_return(instance_double(Gitlab::GiteeImport::ProjectCreator, execute: project))

            post :create, format: :json
          end
        end
      end

      context "when exceptions occur" do
        shared_examples "handles exceptions" do
          it "logs an exception" do
            expect(Gitee::Client).to receive(:new).and_raise(error)
            expect(controller).to receive(:log_exception)

            post :create, format: :json
          end
        end
      end
    end

    context 'when user chose an existing nested namespace and name for the project' do
      let(:parent_namespace) { create(:group, name: 'foo') }
      let(:nested_namespace) { create(:group, name: 'bar', parent: parent_namespace) }

      let_it_be(:test_name) { 'test_name' }

      before do
        parent_namespace.add_owner(user)
        nested_namespace.add_owner(user)
      end

      it 'takes the selected namespace and name' do
        expect(Gitlab::GiteeImport::ProjectCreator)
          .to receive(:new).with(gitee_repo, test_name, nested_namespace, user, access_params)
            .and_return(instance_double(Gitlab::GiteeImport::ProjectCreator, execute: project))

        post :create, params: { target_namespace: nested_namespace.full_path, new_name: test_name }, format: :json
      end
    end

    context 'when user chose a non-existent nested namespaces and name for the project' do
      let_it_be(:test_name) { 'test_name' }
      let(:user) { create(:user, organizations: [current_organization]) }

      it 'takes the selected namespace and name' do
        expect(Gitlab::GiteeImport::ProjectCreator)
          .to receive(:new).with(gitee_repo, test_name, kind_of(Namespace), user, access_params)
            .and_return(instance_double(Gitlab::GiteeImport::ProjectCreator, execute: project))

        post :create, params: { target_namespace: 'foo/bar', new_name: test_name }, format: :json
      end

      it 'creates the namespaces' do
        allow(Gitlab::GiteeImport::ProjectCreator)
          .to receive(:new).with(gitee_repo, test_name, kind_of(Namespace), user, access_params)
            .and_return(instance_double(Gitlab::GiteeImport::ProjectCreator, execute: project))

        expect { post :create, params: { target_namespace: 'foo/bar', new_name: test_name }, format: :json }
          .to change { Namespace.count }.by(2)
      end

      it 'new namespace has the right parent' do
        allow(Gitlab::GiteeImport::ProjectCreator)
          .to receive(:new).with(gitee_repo, test_name, kind_of(Namespace), user, access_params)
            .and_return(instance_double(Gitlab::GiteeImport::ProjectCreator, execute: project))

        post :create, params: { target_namespace: 'foo/bar', new_name: test_name }, format: :json

        expect(Namespace.find_by_path_or_name('bar').parent.path).to eq('foo')
      end
    end

    context 'when user chose existent and non-existent nested namespaces and name for the project' do
      let_it_be(:test_name) { 'test_name' }

      let!(:parent_namespace) { create(:group, name: 'foo') }

      before do
        parent_namespace.add_owner(user)
      end

      it 'takes the selected namespace and name' do
        expect(Gitlab::GiteeImport::ProjectCreator)
          .to receive(:new).with(gitee_repo, test_name, kind_of(Namespace), user, access_params)
            .and_return(instance_double(Gitlab::GiteeImport::ProjectCreator, execute: project))

        post :create, params: { target_namespace: 'foo/foobar/bar', new_name: test_name }, format: :json
      end

      it 'creates the namespaces' do
        allow(Gitlab::GiteeImport::ProjectCreator)
          .to receive(:new).with(gitee_repo, test_name, kind_of(Namespace), user, access_params)
            .and_return(instance_double(Gitlab::GiteeImport::ProjectCreator, execute: project))

        expect { post :create, params: { target_namespace: 'foo/foobar/bar', new_name: test_name }, format: :json }
          .to change { Namespace.count }.by(2)
      end
    end

    context 'when user can not create projects in the chosen namespace' do
      it 'returns 422 response' do
        other_namespace = create(:group, name: 'other_namespace')

        post :create, params: { target_namespace: other_namespace.name }, format: :json

        expect(response).to have_gitlab_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET reset_access_token' do
    it 'redirects to new_import_gitee_url' do
      get :reset_access_token

      expect(session[:gitee_access_token]).to be_nil
      expect(controller).to redirect_to(new_import_gitee_url)
    end
  end
end
