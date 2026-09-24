# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'CI shared runner limits' do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:user) { create(:user, :with_namespace) }

  let(:project) { create(:project, :repository, namespace: group, shared_runners_enabled: true) }
  let(:group) { create(:group) }
  let(:pipeline) { create(:ci_empty_pipeline, project: project, sha: project.commit.sha, ref: 'master') }
  let!(:job) { create(:ci_build, pipeline: pipeline) }

  before do
    group.add_member(user, membership_level)
    allow(user).to receive(:require_email_skippable?).and_return(false)
    allow(page).to receive(:current_user).and_return(user)
    sign_in(user)
  end

  where(:membership_level, :visible) do
    :owner | true
    :developer | false
  end

  with_them do
    context 'when on a project related page' do
      where(:membership_level, :visible) do
        :owner | true
        :developer | false
      end

      before do
        group.add_member(user, membership_level)
      end

      where(:case_name, :minutes_used, :minutes_limit, :displayed_usage) do
        'warning level' | 750 | 1000 | '250 / 1,000 (25%)'
        'danger level'  | 950 | 1000 | '50 / 1,000 (5%)'
      end

      with_them do
        context "when there is a notification and minutes still exist", :js do
          let(:message) do
            "#{group.name} namespace has #{displayed_usage} shared runner " \
              "compute minutes remaining. When all compute minutes are used up, no new jobs or pipelines will run " \
              "in this namespace's projects."
          end

          before do
            group.update!(shared_runners_minutes_limit: minutes_limit)
            allow_any_instance_of(::Ci::Minutes::Usage).to receive(:total_minutes_used).and_return(minutes_used)
          end

          it 'displays a warning message on pipelines page' do
            visit project_pipelines_path(project)

            alerts_according_to_role(visible: visible, message: message)
          end

          it 'displays a warning message on project homepage' do
            visit project_path(project)

            alerts_according_to_role(visible: visible, message: message)
          end

          it 'displays a warning message on a job page' do
            visit project_job_path(project, job)

            alerts_according_to_role(visible: visible, message: message)
          end
        end
      end

      context 'when limit is exceeded', :js do
        let(:group) { create(:group, :with_used_build_minutes_limit) }
        let(:message) do
          "#{group.name} namespace has reached its shared runner compute minutes quota. " \
            "To run new jobs and pipelines in this namespace's projects, buy additional compute minutes."
        end

        it 'displays a warning message on project homepage' do
          visit project_path(project)

          alerts_according_to_role(visible: visible, message: message)
        end

        it 'displays a warning message on pipelines page' do
          visit project_pipelines_path(project)

          alerts_according_to_role(visible: visible, message: message)
        end

        it 'displays a warning message on a job page' do
          visit project_job_path(project, job)

          alerts_according_to_role(visible: visible, message: message)
        end
      end

      context 'when limit not yet exceeded' do
        let(:group) { create(:group, :with_not_used_build_minutes_limit) }

        it 'does not display a warning message on project homepage' do
          visit project_path(project)

          expect_no_quota_exceeded_alert
        end

        it 'does not display a warning message on pipelines page' do
          visit project_pipelines_path(project)

          expect_no_quota_exceeded_alert
        end

        it 'displays a warning message on a job page' do
          visit project_job_path(project, job)

          expect_no_quota_exceeded_alert
        end
      end
    end

    context 'when on a group related page' do
      where(:case_name, :minutes_limit, :minutes_used, :minutes_left, :displayed_usage) do
        'warning level' | 1000 | 750 | 250 | '250 / 1,000 (25%)'
        'danger level'  | 1000 | 950 | 50  | '50 / 1,000 (5%)'
      end

      with_them do
        context "when there is a notification and minutes still exist", :js do
          let(:message) do
            "#{group.name} namespace has #{displayed_usage} shared runner " \
              "compute minutes remaining. When all compute minutes are used up, no new jobs or pipelines will run " \
              "in this namespace's projects."
          end

          before do
            group.update!(shared_runners_minutes_limit: minutes_limit)
            allow_any_instance_of(::Ci::Minutes::Usage).to receive(:total_minutes_used).and_return(minutes_used)
          end

          it 'displays a warning message on group information page' do
            visit group_path(group)

            alerts_according_to_role(visible: visible, message: message)
          end
        end
      end

      context 'when limit is exceeded', :js do
        let(:group) { create(:group, :with_used_build_minutes_limit) }
        let(:message) do
          "#{group.name} namespace has reached its shared runner compute minutes quota. " \
            "To run new jobs and pipelines in this namespace's projects, buy additional compute minutes."
        end

        it 'displays a warning message on group information page' do
          visit group_path(group)

          alerts_according_to_role(visible: visible, message: message)
        end
      end

      context 'when limit not yet exceeded' do
        let(:group) { create(:group, :with_not_used_build_minutes_limit) }

        it 'does not display a warning message on group information page' do
          visit group_path(group)

          expect_no_quota_exceeded_alert
        end
      end
    end
  end

  def alerts_according_to_role(visible: false, message: '')
    visible ? expect_quota_exceeded_alert(message) : expect_no_quota_exceeded_alert
  end

  def expect_quota_exceeded_alert(message)
    expect(has_testid?('ci-minute-limit-banner', count: 1)).to be true

    banner = find_by_testid('ci-minute-limit-banner')
    expect(banner).to match_selector('.js-minute-limit-banner')
    within(banner) do
      expect(page).to have_content(message)
      expect(page).to have_link 'Buy more compute minutes',
        href: ::Gitlab::Routing.url_helpers.buy_minutes_subscriptions_path(selected_group: group.root_ancestor.id)
    end
  end

  def alerts_according_to_role_for_old_flow(visible: false, message: '')
    visible ? expect_quota_exceeded_alert_for_old_flow(message) : expect_no_quota_exceeded_alert
  end

  def expect_quota_exceeded_alert_for_old_flow(message)
    expect(has_testid?('ci-minute-limit-banner', count: 1)).to be true

    banner = find_by_testid('ci-minute-limit-banner')
    expect(banner).to match_selector('.js-minute-limit-banner')
    within(banner) do
      expect(page).to have_content(message)
      expect(page).to have_link 'Buy more compute minutes',
        href: ::Gitlab::Routing.url_helpers.buy_minutes_subscriptions_path(selected_group: group.root_ancestor.id)
    end
  end

  def expect_no_quota_exceeded_alert
    expect(has_testid?('ci-minute-limit-banner')).to be false
  end
end
