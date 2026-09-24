# frozen_string_literal: true

module JH
  module BillingPlansHelper
    extend ::Gitlab::Utils::Override

    override :number_to_plan_currency
    def number_to_plan_currency(value)
      number_to_currency(value, unit: '¥', strip_insignificant_zeros: true, format: "%u%n")
    end

    override :billing_available_plans
    def billing_available_plans(plans_data, current_plan)
      filtered_data = super

      team_plan = filtered_data.find { |plan| plan.code == 'team' }
      filtered_data = filtered_data.reject { |plan| plan.code == 'team' || plan.code == 'free' }
      filtered_data.unshift(team_plan) if team_plan

      filtered_data
    end

    def show_start_free_trial_messages?(namespace)
      !namespace.free_personal? && namespace.eligible_for_trial?
    end

    def billing_plan_name(plan)
      plan_namespaces_map[plan]
    end

    override :plans_features
    def plans_features
      features = Hashie::Mash.new({
        free: [
          { title: s_('BillingPlans|Features include:'), highlight: true },
          { title: s_('BillingPlans|All stages of the DevOps lifecycle') },
          { title: s_('BillingPlans|Bring your own CI runners') },
          { title: s_('BillingPlans|Bring your own production environment') },
          { title: s_('BillingPlans|400 compute minutes') }
        ],
        premium: [
          { title: s_('BillingPlans|Everything from Free, plus:'), highlight: true },
          { title: s_('BillingPlans|Cross-team project management') },
          { title: s_('BillingPlans|Multiple approval rules') },
          { title: s_('BillingPlans|Multi-region support') },
          { title: s_('BillingPlans|Priority support') },
          { title: s_('BillingPlans|10000 compute minutes') }
        ],
        ultimate: [
          { title: s_('BillingPlans|Everything from Premium, plus:'), highlight: true },
          { title: s_('BillingPlans|Company wide portfolio management') },
          { title: s_('BillingPlans|Advanced application security') },
          { title: s_('BillingPlans|Executive level insights') },
          { title: s_('BillingPlans|Compliance automation') },
          { title: s_('BillingPlans|Free guest users') },
          { title: s_('BillingPlans|50000 compute minutes') }
        ]
      })

      features[:team] = [
        {
          title: s_('JH|BillingPlans|2000 CI/CD minutes per month')
        },
        {
          title: s_('JH|BillingPlans|Up to 10 users per top-level group')
        },
        {
          title: s_('JH|BillingPlans|AI empowered intelligent programming and DevOps')
        }
      ]

      features
    end

    override :free_trial_plan_billing_attributes
    def free_trial_plan_billing_attributes(namespace, plans_data, monthly_commitment_purchased: 0)
      return super unless ::Gitlab.jh?

      attrs = super

      team_plan = find_plan(plans_data, ::Plan::TEAM)

      return attrs if team_plan.blank?

      team_url = plan_purchase_url(namespace, team_plan)
      attrs.merge(upgradeToTeamUrl: team_url)
    end

    override :plan_purchase_url
    def plan_purchase_url(group, plan)
      new_subscriptions_path(plan_id: plan.id, namespace_id: group.id, source: params[:source])
    end

    private

    def plan_namespaces_map
      {
        free: s_('JH|License|Free'),
        team: s_('JH|License|Team'),
        premium: s_('JH|License|Premium'),
        ultimate: s_('JH|License|Ultimate'),
        starter: s_('JH|License|Starter'),
        premium_trial: s_('JH|License|Premium Trial'),
        ultimate_trial: s_('JH|License|Ultimate Trial')
      }.with_indifferent_access.freeze
    end
  end
end
