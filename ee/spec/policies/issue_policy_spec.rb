# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssuePolicy, feature_category: :team_planning do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:admin, freeze: false) { create(:user, :admin) }
  let_it_be(:user, freeze: false) { create(:user) }
  let_it_be(:guest, freeze: false) { create(:user) }
  let_it_be(:planner, freeze: false) { create(:user) }
  let_it_be(:reporter, freeze: false) { create(:user) }
  let_it_be(:owner, freeze: false) { create(:user) }
  let_it_be(:non_member) { create(:user) }
  let_it_be(:developer) { create(:user) }
  let_it_be(:maintainer) { create(:user) }
  let_it_be(:security_manager) { create(:user) }
  let_it_be_with_refind(:project) { create(:project, :private) }
  let_it_be_with_refind(:issue) { create(:issue, project: project) }

  let_it_be(:root_group, freeze: false) do
    create(:group, :public).tap do |g|
      g.add_planner(planner)
      g.add_reporter(reporter)
      g.add_owner(owner)
    end
  end

  let_it_be(:group, freeze: false) do
    create(:group, :public, parent: root_group).tap do |g|
      g.add_guest(guest)
      g.add_planner(planner)
      g.add_reporter(reporter)
      g.add_owner(owner)
    end
  end

  let_it_be(:support_bot, freeze: false) { create(:support_bot) }

  subject { described_class.new(user, issue) }

  def permissions(user, issue)
    described_class.new(user, issue)
  end

  def add_members(project)
    project.add_guest(guest)
    project.add_planner(planner)
    project.add_reporter(reporter)
    project.add_security_manager(security_manager)
    project.add_developer(developer)
    project.add_maintainer(maintainer)
    project.add_owner(owner)
  end

  describe 'summarize_comments', :with_cloud_connector do
    let(:authorizer) { instance_double(::Gitlab::Llm::FeatureAuthorizer) }

    context 'when user is nil' do
      let(:user) { nil }
      let_it_be_with_refind(:project) { create(:project, :public) }

      before do
        allow(::Gitlab::Llm::FeatureAuthorizer).to receive(:new).and_return(authorizer)
      end

      it { is_expected.to be_disallowed(:summarize_comments, :generate_description) }
    end

    context 'when user is logged in' do
      before do
        allow(::Gitlab::Llm::FeatureAuthorizer).to receive(:new).and_return(authorizer)
        allow(project).to receive(:duo_features_enabled).and_return(true)
      end

      context "when feature is authorized" do
        before do
          allow(authorizer).to receive(:allowed?).and_return(true)
        end

        context 'when user can read issue' do
          before_all do
            project.add_guest(user)
          end

          it { is_expected.to be_allowed(:summarize_comments) }

          context 'when feature is not enabled' do
            before do
              allow(authorizer).to receive(:allowed?).and_return(false)
            end

            it { is_expected.to be_disallowed(:summarize_comments) }
          end
        end

        context 'when user cannot read issue' do
          it { is_expected.to be_disallowed(:summarize_comments) }

          context 'with confidential issue' do
            let_it_be(:confidential_issue, freeze: false) { create(:issue, :confidential, project: project) }

            it 'does not allow guest to summarize issue' do
              project.add_guest(guest)
              project.add_planner(planner)

              expect(permissions(guest, confidential_issue)).to be_disallowed(:read_issue, :summarize_comments)
              expect(permissions(planner, confidential_issue)).to be_allowed(:read_issue, :summarize_comments)
            end
          end
        end
      end

      context "when feature is not authorized" do
        before_all do
          project.add_guest(user)
        end

        before do
          allow(authorizer).to receive(:allowed?).and_return(false)
        end

        it { is_expected.to be_disallowed(:summarize_comments) }
      end
    end
  end

  describe 'reopen_issue for group level issue' do
    let(:non_member) { user }

    let_it_be_with_reload(:group_issue) { create(:issue, :group_level, namespace: group) }

    it 'does not allow non members' do
      expect(permissions(non_member, group_issue)).to be_disallowed(:reopen_issue)
    end

    it 'does not allow for anonymous' do
      expect(permissions(nil, group_issue)).to be_disallowed(:reopen_issue)
    end

    context 'without group level issue license' do
      it 'dis-allows it for members', :aggregate_failures do
        expect(permissions(guest, group_issue)).to be_disallowed(:reopen_issue)
        expect(permissions(reporter, group_issue)).to be_disallowed(:reopen_issue)
        expect(permissions(planner, group_issue)).to be_disallowed(:reopen_issue)
        expect(permissions(owner, group_issue)).to be_disallowed(:reopen_issue)
      end
    end

    context 'with group level issue license' do
      before do
        stub_licensed_features(epics: true)
      end

      it 'allows it for members', :aggregate_failures do
        expect(permissions(guest, group_issue)).to be_disallowed(:reopen_issue)
        expect(permissions(reporter, group_issue)).to be_allowed(:reopen_issue)
        expect(permissions(planner, group_issue)).to be_allowed(:reopen_issue)
        expect(permissions(owner, group_issue)).to be_allowed(:reopen_issue)
      end
    end
  end

  describe 'admin_issue_relation' do
    let(:non_member) { user }
    let_it_be_with_reload(:group_issue) { create(:issue, :group_level, namespace: group) }
    let_it_be(:public_project, freeze: false) { create(:project, :public, group: group) }
    let_it_be(:private_project, freeze: false) { create(:project, :private, group: group) }
    let_it_be(:public_issue, freeze: false) { create(:issue, project: public_project) }
    let_it_be(:private_issue, freeze: false) { create(:issue, project: private_project) }

    it 'allows non-members to admin_issue_relation in public projects' do
      expect(permissions(non_member, public_issue)).to be_allowed(:admin_issue_relation)
    end

    it 'does not allow non-members to admin_issue_relation in private projects or group issues' do
      expect(permissions(non_member, group_issue)).to be_disallowed(:admin_issue_relation)
      expect(permissions(non_member, private_issue)).to be_disallowed(:admin_issue_relation)
    end

    it 'allow guest to admin_issue_relation' do
      expect(permissions(guest, group_issue)).to be_disallowed(:admin_issue_relation)
      expect(permissions(guest, private_issue)).to be_allowed(:admin_issue_relation)
      expect(permissions(guest, public_issue)).to be_allowed(:admin_issue_relation)
    end

    context 'with group level issue license' do
      before do
        stub_licensed_features(epics: true)
      end

      it 'allows it for guest', :aggregate_failures do
        expect(permissions(guest, group_issue)).to be_allowed(:admin_issue_relation)
      end
    end

    context 'when issue is confidential' do
      let_it_be(:confidential_issue, freeze: false) { create(:issue, :confidential, project: public_project) }

      it 'does not allow guest to admin_issue_relation' do
        expect(permissions(guest, confidential_issue)).to be_disallowed(:admin_issue_relation)
      end

      it 'allow reporter to admin_issue_relation' do
        expect(permissions(reporter, confidential_issue)).to be_allowed(:admin_issue_relation)
      end
    end

    context 'when user is support bot and service desk is enabled' do
      before do
        allow(::Gitlab::Email::IncomingEmail).to receive_messages(enabled?: true, supports_wildcard?: true)
        allow(::ServiceDesk).to receive(:enabled?).and_return(true)
      end

      it 'allows support_bot to admin_issue_relation on project issues, but does not allow it on group issues' do
        expect(permissions(support_bot, group_issue)).to be_disallowed(:admin_issue_relation, :read_issue)
        expect(permissions(support_bot, public_issue)).to be_allowed(:admin_issue_relation)
        expect(permissions(support_bot, private_issue)).to be_allowed(:admin_issue_relation)
      end

      context 'with group level issue license' do
        before do
          stub_licensed_features(epics: true)
        end

        it 'allows it for support_bot', :aggregate_failures do
          expect(permissions(support_bot, group_issue)).to be_allowed(:admin_issue_relation, :read_issue)
        end
      end
    end

    context 'when user is support bot and service desk is disabled' do
      it 'does not allow support_bot to admin_issue_relation' do
        expect(permissions(support_bot, group_issue)).to be_disallowed(:admin_issue_relation, :read_issue)
        expect(permissions(support_bot, public_issue)).to be_disallowed(:admin_issue_relation)
        expect(permissions(support_bot, private_issue)).to be_disallowed(:admin_issue_relatio)
      end
    end

    context 'when issue has a synced epic' do
      let_it_be_with_reload(:group_issue) { create(:issue, :with_synced_epic, namespace: group) }

      before do
        stub_licensed_features(issuable_resource_links: true, epics: true)
      end

      context 'without group level issue license' do
        before do
          stub_licensed_features(epics: false)
        end

        it 'does not allow' do
          # allows some permissions as guest
          expect(permissions(guest, group_issue)).to be_disallowed(
            :read_issue, :read_issuable, :admin_issue_link, :read_issuable_participables, :read_note, :read_work_item,
            :read_issuable_metric_image, :read_incident_management_timeline_event, :read_cross_project
          )

          # allows read permissions
          expect(permissions(planner, group_issue)).to be_disallowed(:read_internal_note, :read_crm_contacts)
          expect(permissions(reporter, group_issue)).to be_disallowed(:read_internal_note, :read_crm_contacts)

          # allows some permissions that modify the issue
          expect(permissions(owner, group_issue)).to be_disallowed(
            :admin_issue, :update_issue, :set_issue_metadata, :create_note, :admin_issue_relation, :award_emoji,
            :create_todo, :update_subscription, :set_confidentiality, :set_issue_crm_contacts, :set_note_created_at,
            :mark_note_as_internal, :create_timelog, :destroy_issue, :admin_note,
            :move_issue, :clone_issue
          )
        end

        it 'does not allow' do
          # these read permissions are not yet defined for group level issues
          expect(permissions(owner, group_issue)).to be_disallowed(
            :read_issuable_resource_link, :read_issue_iid, :read_design
          )

          # these permissions are either not yet defined for group level issues or not allowed
          expect(permissions(owner, group_issue)).to be_disallowed(
            :create_requirement_test_report,
            :reposition_note, :create_design, :update_design, :destroy_design, :move_design,
            :upload_issuable_metric_image, :update_issuable_metric_image, :delete_issuable_metric_image,
            :admin_issuable_resource_link, :admin_timelog, :admin_issue_metrics, :admin_issue_metrics_list
          )
        end
      end

      context 'with group level issue license' do
        before do
          stub_licensed_features(epics: true)
        end

        it 'does allow' do
          # allows some permissions as guest
          expect(permissions(guest, group_issue)).to be_allowed(
            :read_issue, :read_issuable, :admin_issue_link, :read_issuable_participables, :read_note, :read_work_item,
            :read_incident_management_timeline_event, :read_cross_project
          )

          # allows read permissions
          expect(permissions(planner, group_issue)).to be_allowed(:read_internal_note, :read_crm_contacts)
          expect(permissions(reporter, group_issue)).to be_allowed(:read_internal_note, :read_crm_contacts)

          # allows some permissions that modify the issue
          expect(permissions(owner, group_issue)).to be_allowed(
            :admin_issue, :update_issue, :set_issue_metadata, :create_note, :admin_issue_relation, :award_emoji,
            :create_todo, :update_subscription, :set_confidentiality, :set_issue_crm_contacts, :set_note_created_at,
            :mark_note_as_internal, :create_timelog, :admin_timelog, :destroy_issue, :admin_note
          )

          # This group issue is actually an epic work item, and for now we only allow move and clone for:
          # Issue, Incident and Test Case, see Issue#supports_move_and_clone?
          expect(permissions(owner, group_issue)).to be_disallowed(
            :move_issue, :clone_issue
          )
        end

        it 'does not allow' do
          # metric images are only available on incidents
          expect(permissions(owner, group_issue)).to be_disallowed(
            :read_issuable_metric_image, :upload_issuable_metric_image, :update_issuable_metric_image,
            :delete_issuable_metric_image
          )

          # these read permissions are not yet defined for group level issues
          expect(permissions(owner, group_issue)).to be_disallowed(
            :read_issuable_resource_link, :read_issue_iid, :read_design,
            :create_requirement_test_report,
            :reposition_note, :create_design, :update_design, :destroy_design, :move_design,
            :admin_issuable_resource_link, :admin_issue_metrics, :admin_issue_metrics_list
          )
        end
      end

      context 'when external authorization is enabled' do
        include ExternalAuthorizationServiceHelpers

        before do
          enable_external_authorization_service_check
        end

        it 'disallows read_issue and read_note for the synced epic issue regardless of role' do
          expect(permissions(guest, group_issue)).to be_disallowed(:read_issue, :read_note)
          expect(permissions(reporter, group_issue)).to be_disallowed(:read_issue, :read_note)
          expect(permissions(owner, group_issue)).to be_disallowed(:read_issue, :read_note)
        end

        it 'disallows read_issue for an anonymous user' do
          expect(permissions(nil, group_issue)).to be_disallowed(:read_issue)
        end

        it 'allows read_issue for an admin with read_all_resources', :enable_admin_mode do
          expect(permissions(admin, group_issue)).to be_allowed(:read_issue)
        end

        it 'does not affect issues with no synced epic' do
          plain_issue = create(:issue, project: create(:project, group: group))

          expect(permissions(reporter, plain_issue)).to be_allowed(:read_issue)
        end
      end
    end
  end

  context 'when work item type is incident' do
    let_it_be(:incident_project) { create(:project, :private) }
    let_it_be(:incident) { create(:incident, project: incident_project) }
    let_it_be(:guest_incident) { create(:incident, project: incident_project, author: guest) }
    let_it_be(:planner_incident) { create(:incident, project: incident_project, author: planner) }

    before_all do
      incident_project.add_guest(guest)
      incident_project.add_planner(planner)
      incident_project.add_reporter(reporter)
    end

    it 'disallows guests and planners from managing metric images, even as the incident author', :aggregate_failures do
      expect(permissions(guest, incident)).to be_allowed(:read_issuable_metric_image)
      expect(permissions(guest, incident)).to be_disallowed(
        :upload_issuable_metric_image, :update_issuable_metric_image, :delete_issuable_metric_image
      )
      expect(permissions(guest, guest_incident)).to be_disallowed(
        :upload_issuable_metric_image, :update_issuable_metric_image, :delete_issuable_metric_image
      )

      expect(permissions(planner, incident)).to be_allowed(:read_issuable_metric_image)
      expect(permissions(planner, incident)).to be_disallowed(
        :upload_issuable_metric_image, :update_issuable_metric_image, :delete_issuable_metric_image
      )
      expect(permissions(planner, planner_incident)).to be_disallowed(
        :upload_issuable_metric_image, :update_issuable_metric_image, :delete_issuable_metric_image
      )
    end

    it 'allows reporters to manage metric images' do
      expect(permissions(reporter, incident)).to be_allowed(
        :read_issuable_metric_image, :upload_issuable_metric_image, :update_issuable_metric_image,
        :delete_issuable_metric_image
      )
    end
  end

  context 'when work item type is epic' do
    let_it_be(:author, freeze: false) { create(:user) }
    let_it_be(:assignee, freeze: false) { create(:user) }
    let_it_be(:project, freeze: false) { create(:project, :private, group: group) }
    let_it_be(:project_epic, freeze: false) { create(:issue, :epic, project: project) }

    context 'when epics feature is available' do
      before do
        stub_licensed_features(epics: true)
      end

      it 'allows read permissions for guest users' do
        expect(permissions(guest, project_epic)).to be_allowed(:read_issue)
      end

      context 'when project_work_item_epics feature flag is disabled' do
        before do
          stub_feature_flags(project_work_item_epics: false)
        end

        it_behaves_like 'prevents access to project-level {issues|work_items} with type Epic', :issue
      end
    end

    context 'when epics feature is not available' do
      before do
        stub_licensed_features(epics: false)
      end

      it_behaves_like 'prevents access to project-level {issues|work_items} with type Epic', :issue
    end
  end

  context 'when work item type is requirement' do
    let_it_be_with_refind(:project) { create(:project, :private, group: group) }
    let_it_be_with_refind(:requirement) { create(:work_item, :requirement, project: project) }

    before do
      stub_licensed_features(requirements: true)
    end

    it 'allows reporters to read and update the requirement' do
      expect(permissions(reporter, requirement)).to be_allowed(:read_issue, :update_issue)
    end

    context 'when the requirements project feature is disabled' do
      before do
        project.project_feature.update!(requirements_access_level: ::ProjectFeature::DISABLED)
      end

      it 'prevents reporters from reading or modifying the requirement', :aggregate_failures do
        expect(permissions(reporter, requirement)).to be_disallowed(
          :read_issue, :update_issue, :admin_issue, :destroy_issue
        )
      end

      it 'prevents guests from reading the requirement via the generic issues surface' do
        project.add_guest(guest)

        expect(permissions(guest, requirement)).to be_disallowed(:read_issue)
      end

      it 'still allows reporters to read regular issues in the same project' do
        regular_issue = build(:issue, project: project)

        expect(permissions(reporter, regular_issue)).to be_allowed(:read_issue)
      end
    end

    context 'when the requirements license is unavailable' do
      before do
        stub_licensed_features(requirements: false)
      end

      it 'prevents reporters from reading or modifying the requirement', :aggregate_failures do
        expect(permissions(reporter, requirement)).to be_disallowed(
          :read_issue, :update_issue, :admin_issue, :destroy_issue
        )
      end
    end
  end

  describe 'read_issuable_metric_image' do
    let_it_be(:public_project) { create(:project, :public) }
    let_it_be(:issues_private_project) { create(:project, :public, :issues_private) }
    let_it_be(:public_incident) { create(:incident, project: public_project) }
    let_it_be(:confidential_incident) { create(:incident, :confidential, project: public_project) }
    let_it_be(:members_only_incident) { create(:incident, project: issues_private_project) }
    let_it_be(:hidden_incident) { create(:incident, project: public_project, author: create(:user, :banned)) }
    let_it_be(:authored_confidential_incident) do
      create(:incident, :confidential, project: public_project, author: user)
    end

    before_all do
      public_project.add_guest(guest)
      public_project.add_planner(planner)
      issues_private_project.add_planner(planner)
    end

    where(:current_user, :incident, :allowed) do
      nil           | ref(:public_incident)       | true
      ref(:user)    | ref(:public_incident)       | true
      nil           | ref(:confidential_incident) | false
      ref(:user)    | ref(:confidential_incident) | false
      ref(:guest)   | ref(:confidential_incident) | false
      ref(:planner) | ref(:confidential_incident) | true
      ref(:user)    | ref(:authored_confidential_incident) | true
      nil           | ref(:members_only_incident) | false
      ref(:user)    | ref(:members_only_incident) | false
      ref(:planner) | ref(:members_only_incident) | true
      nil           | ref(:hidden_incident)       | false
      ref(:user)    | ref(:hidden_incident)       | false
      ref(:planner) | ref(:hidden_incident)       | false
    end

    with_them do
      subject { permissions(current_user, incident) }

      if params[:allowed]
        it { expect_allowed(:read_issuable_metric_image) }
      else
        it { expect_disallowed(:read_issuable_metric_image) }
      end
    end

    context 'when the incident is hidden' do
      subject { permissions(admin, hidden_incident) }

      context 'with admin mode enabled', :enable_admin_mode do
        it { expect_allowed(:read_issuable_metric_image) }
      end

      context 'without admin mode enabled' do
        it { expect_disallowed(:read_issuable_metric_image) }
      end
    end

    context 'in a private project' do
      let_it_be(:private_project) { create(:project, :private) }
      let_it_be(:private_incident) { create(:incident, project: private_project) }

      before_all do
        add_members(private_project)
      end

      subject { permissions(current_user, private_incident) }

      where(:current_user, :allowed) do
        ref(:non_member)       | false
        ref(:guest)            | true
        ref(:planner)          | true
        ref(:reporter)         | true
        ref(:security_manager) | true
        ref(:developer)        | true
        ref(:maintainer)       | true
        ref(:owner)            | true
      end

      with_them do
        if params[:allowed]
          it { expect_allowed(:read_issuable_metric_image) }
        else
          it { expect_disallowed(:read_issuable_metric_image) }
        end
      end

      context 'with admin mode enabled', :enable_admin_mode do
        let(:current_user) { admin }

        it { expect_allowed(:read_issuable_metric_image) }
      end

      context 'without admin mode enabled' do
        let(:current_user) { admin }

        it { expect_disallowed(:read_issuable_metric_image) }
      end

      context 'as an auditor' do
        subject { permissions(create(:user, :auditor), private_incident) }

        it { expect_allowed(:read_issuable_metric_image) }
      end

      context 'when the issue is not an incident' do
        let_it_be(:private_issue) { create(:issue, project: private_project) }

        subject { permissions(reporter, private_issue) }

        it { expect_disallowed(:read_issuable_metric_image) }
      end
    end
  end

  shared_examples 'a metric image write permission' do |permission|
    let_it_be(:private_project) { create(:project, :private) }
    let_it_be(:private_incident) { create(:incident, project: private_project) }

    before_all do
      add_members(private_project)
    end

    subject { permissions(current_user, private_incident) }

    where(:current_user, :allowed) do
      ref(:non_member)       | false
      ref(:guest)            | false
      ref(:planner)          | false
      ref(:reporter)         | true
      ref(:security_manager) | true
      ref(:developer)        | true
      ref(:maintainer)       | true
      ref(:owner)            | true
    end

    with_them do
      if params[:allowed]
        it { expect_allowed(permission) }
      else
        it { expect_disallowed(permission) }
      end
    end

    context 'as an auditor' do
      subject { permissions(create(:user, :auditor), private_incident) }

      it { expect_disallowed(permission) }
    end

    # Admins who are not members are denied by the ~is_container_member prevent.
    context 'with admin mode enabled', :enable_admin_mode do
      let(:current_user) { admin }

      it { expect_disallowed(permission) }
    end

    context 'when a guest or planner authored the incident' do
      let_it_be(:guest_incident) { create(:incident, project: private_project, author: guest) }
      let_it_be(:planner_incident) { create(:incident, project: private_project, author: planner) }

      where(:current_user, :incident) do
        ref(:guest)   | ref(:guest_incident)
        ref(:planner) | ref(:planner_incident)
      end

      with_them do
        subject { permissions(current_user, incident) }

        it { expect_disallowed(permission) }
      end
    end

    context 'when the incident is confidential' do
      let_it_be(:confidential_incident) { create(:incident, :confidential, project: private_project) }
      let(:current_user) { reporter }

      subject { permissions(current_user, confidential_incident) }

      it { expect_allowed(permission) }
    end

    context 'when the incident is hidden' do
      let_it_be(:hidden_incident) { create(:incident, project: private_project, author: create(:user, :banned)) }
      let(:current_user) { reporter }

      subject { permissions(current_user, hidden_incident) }

      it { expect_disallowed(permission) }
    end

    context 'when the issue is not an incident' do
      let_it_be(:private_issue) { create(:issue, project: private_project, author: reporter) }
      let(:current_user) { reporter }

      subject { permissions(current_user, private_issue) }

      it { expect_disallowed(permission) }
    end

    context 'when the project is archived' do
      let_it_be(:archived_project) { create(:project, :private, :archived) }
      let_it_be(:archived_incident) { create(:incident, project: archived_project) }
      let(:current_user) { reporter }

      before_all do
        archived_project.add_reporter(reporter)
      end

      subject { permissions(current_user, archived_incident) }

      it { expect_disallowed(permission) }
    end

    context 'when issues are disabled for the project' do
      let_it_be(:issues_disabled_project) { create(:project, :private, :issues_disabled) }
      let_it_be(:issues_disabled_incident) { create(:incident, project: issues_disabled_project) }
      let(:current_user) { reporter }

      before_all do
        issues_disabled_project.add_reporter(reporter)
      end

      subject { permissions(current_user, issues_disabled_incident) }

      it { expect_disallowed(permission) }
    end
  end

  describe 'upload_issuable_metric_image' do
    it_behaves_like 'a metric image write permission', :upload_issuable_metric_image
  end

  describe 'update_issuable_metric_image' do
    it_behaves_like 'a metric image write permission', :update_issuable_metric_image
  end

  describe 'delete_issuable_metric_image' do
    it_behaves_like 'a metric image write permission', :delete_issuable_metric_image
  end
end
