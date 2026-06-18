# frozen_string_literal: true

module Namespaces
  module FreeUserCap
    class PreEnforcementAlertComponent < BaseAlertComponent
      include SafeFormatHelper

      ENFORCEMENT_DATE = Date.new(2026, 8, 15)

      private

      def breached_cap_limit?
        return false unless Feature.enabled?(:free_user_cap_pre_enforcement_banner, namespace)
        return false unless ::Namespaces::FreeUserCap::PreEnforcement.new(namespace).qualifies?

        ::Namespaces::FreeUserCap::EnforcementWithoutStorage.new(namespace).over_limit?
      end

      def variant
        :warning
      end

      def dismissible
        false
      end

      def dismissed?
        false
      end

      def alert_attributes
        {
          title: alert_title,
          body: safe_format(
            _("Free top-level namespaces with private visibility cannot have more than %{free_limit} users. " \
              "From %{strong_start}%{enforcement_date}%{strong_end}, if your namespace has more than " \
              "%{free_limit} users, it will be placed in %{link_start}a read-only state%{link_end}. " \
              "To prevent this, reduce the number of users in the namespace, make the namespace " \
              "public, upgrade to a paid tier, or start a free %{duration}-day Ultimate trial."),
            tag_pair(tag.strong, :strong_start, :strong_end),
            tag_pair(read_only_namespaces_link, :link_start, :link_end),
            enforcement_date: l(ENFORCEMENT_DATE, format: :long),
            free_limit: free_user_limit,
            duration: trial_duration
          ),
          primary_cta: namespace_primary_cta,
          secondary_cta: namespace_secondary_cta
        }
      end

      def alert_title
        safe_format(
          _("Your namespace %{namespace_name} is over %{link_start}the %{free_limit} user limit%{link_end}"),
          tag_pair(free_user_limit_link, :link_start, :link_end),
          namespace_name: namespace.name,
          free_limit: free_user_limit
        )
      end

      def namespace_primary_cta
        render Pajamas::ButtonComponent.new(
          variant: :confirm,
          href: group_billings_path(namespace, source: 'user-limit-alert-notification'),
          button_options: {
            class: 'gl-alert-action',
            data: {
              track_action: 'click_button',
              track_label: 'explore_paid_plans',
              track_property: tracking_property,
              testid: 'pre-enforcement-user-limit-primary-cta'
            }
          }
        ) do
          _('Explore paid plans')
        end
      end

      def namespace_secondary_cta
        render Pajamas::ButtonComponent.new(
          href: 'https://about.gitlab.com/sales/',
          button_options: {
            class: 'gl-alert-action',
            data: {
              track_action: 'click_button',
              track_label: 'contact_sales',
              track_property: tracking_property,
              testid: 'pre-enforcement-user-limit-secondary-cta'
            }
          }
        ) do
          _('Contact sales')
        end
      end

      def base_alert_data
        {
          track_action: 'render',
          track_property: tracking_property,
          testid: 'pre-enforcement-user-limit-alert'
        }
      end

      def trial_duration
        ::GitlabSubscriptions::TrialDurationService.new.execute
      end

      def free_user_limit_link
        link_to(
          '',
          free_user_limit_url,
          target: '_blank',
          rel: 'noopener noreferrer',
          data: {
            track_action: 'click_link',
            track_label: 'free_user_limit',
            track_property: tracking_property
          }
        )
      end

      def read_only_namespaces_link
        link_to(
          '',
          read_only_namespaces_url,
          target: '_blank',
          rel: 'noopener noreferrer',
          data: {
            track_action: 'click_link',
            track_label: 'read_only_namespaces',
            track_property: tracking_property
          }
        )
      end

      def tracking_property
        'pre_enforcement_user_limit_banner'
      end

      def free_user_limit_url
        help_page_path('user/free_user_limit.md')
      end

      def read_only_namespaces_url
        help_page_path('user/read_only_namespaces.md', anchor: 'read-only-namespaces')
      end
    end
  end
end
