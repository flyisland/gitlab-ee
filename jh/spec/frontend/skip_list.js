// eslint-disable-next-line import/no-commonjs
module.exports = {
  by_file: [
    // For posthog, since the tracking tests were hardcoded `snowplow` in upstream, we will have to skip them.
    '<rootDir>/spec/frontend/tracking/tracking_spec.js',
    '<rootDir>/spec/frontend/tracking/tracking_initialization_spec.js',
    '<rootDir>/spec/frontend/tracking/get_standard_context_spec.js',
    '<rootDir>/spec/frontend/tracking/utils_spec.js',
    '<rootDir>/ee/spec/frontend/roadmap/components/roadmap_app_spec.js',
    '<rootDir>/spec/frontend/lib/logger/hello_spec.js',
    '<rootDir>/ee/spec/frontend/admin/subscriptions/show/components/subscription_activation_errors_spec.js',
    '<rootDir>/spec/frontend/ci/runner/components/registration/utils_spec.js',
  ],
  by_case: {
    'spec/frontend/terms/components/app_spec.js': [
      'TermsApp accept button is disabled until user scrolls to the bottom of the terms',
    ],
    'ee/spec/frontend/subscriptions/new/components/checkout/order_summary_spec.js': [
      'Order Summary Changing the number of users with the default of 1 selected user displays the correct formatted total amount',
      'Order Summary Changing the number of users with 3 selected users displays the correct multiplied formatted amount of the chosen plan',
      'Order Summary Changing the number of users with 3 selected users displays the correct formatted total amount',
      'Order Summary Changing the number of users date range shows the formatted date range from the start date to one year in the future',
      'Order Summary Changing the number of users tax rate a tax rate of 8% displays the total amount excluding vat',
      'Order Summary Changing the number of users tax rate a tax rate of 8% displays the vat amount',
      'Order Summary Changing the number of users tax rate a tax rate of 8% displays the total amount including the vat',
      'Order Summary changing the plan with the selected plan displays the correct formatted total amount',
      'Order Summary when use_invoice_preview_api_in_saas_purchase feature flag is disabled displays the correct formatted total amount',
      'Order Summary when use_invoice_preview_api_in_saas_purchase feature flag is disabled when changing plan displays the correct formatted total amount',
      'Order Summary when use_invoice_preview_api_in_saas_purchase feature flag is disabled when changing users displays the chosen plan',
      'Order Summary when use_invoice_preview_api_in_saas_purchase feature flag is disabled when changing users displays the correct multiplied formatted amount of the chosen plan',
      'Order Summary when use_invoice_preview_api_in_saas_purchase feature flag is disabled when changing users displays the correct formatted total amount',
      'Order Summary promo code when promo code is valid shows discount details',
      'Order Summary Changing the number of users with selected group displays the correct multiplied formatted amount of the chosen plan',
      'Order Summary Changing the number of users with selected group displays the correct formatted total amount',
      'Order Summary Changing the number of users tax rate with a tax rate of 0 contains a help link',
      'Order Summary Changing the number of users tax rate a tax rate of 8% contains a help link',
    ],
    'jh/spec/frontend/subscriptions/new/components/checkout/order_summary_spec.js': [
      'Order Summary promo code when promo code is valid shows success message for promo code',
      'Order Summary promo code when promo code is valid but price is not shown does not show success message for promo code',
    ],
    // Introduced in https://gitlab.com/gitlab-org/gitlab/-/commit/f7dca15d434405684d4729dc04c5c35ab6a532ea#eb60e7b9d01a04945f4a7dab3707f29604177814
    // TODO: fix the file import with jh_else_ee instead of ee/
    'ee/spec/frontend/subscriptions/new/components/app_spec.js': [
      'App component step order app renders checkout',
      'App component step order app renders OrderSummary',
      'App component when the children component emit events when function () {\n    return wrapper.findComponent(_checkout.default);\n  } emits an `error` event passes the correct props',
      'App component when the children component emit events when function () {\n    return wrapper.findComponent(_checkout.default);\n  } emits an `error` event captures the error',
      'App component when the children component emit events when function () {\n    return wrapper.findComponent(_checkout.default);\n  } emits an `error-reset` event does not the alert',
      'App component when the children component emit events when function () {\n    return wrapper.findComponent(_order_summary.default);\n  } emits an `error` event passes the correct props',
      'App component when the children component emit events when function () {\n    return wrapper.findComponent(_order_summary.default);\n  } emits an `error` event captures the error',
      'App component when the children component emit events when function () {\n    return wrapper.findComponent(_order_summary.default);\n  } emits an `error-reset` event does not the alert',
    ],
    'spec/frontend/vue_shared/components/markdown/toolbar_spec.js': [
      'toolbar with content editor switcher inserts a "getting started with rich text" template when switched for the first time',
    ],
    'ee/spec/frontend/issuable/linked_resources/components/resource_links_list_item_spec.js': [
      'ResourceLinkItem template matches the snapshot',
    ],
    'ee/spec/frontend/pages/projects/learn_gitlab/components/learn_gitlab_spec.js': [
      'Learn GitLab renders correctly',
      'Learn GitLab Initial rendering concerns renders correctly',
    ],
    'spec/frontend/work_items/components/work_item_attributes_wrapper_spec.js': [
      'WorkItemAttributesWrapper component upgrade banner renders upgrade banner when showPlanUpgradePromotion is true and banner is not dismissed',
    ],
    'ee/spec/frontend_integration/security_orchestration/policy_editor/policy_scope/specific_projects_spec.js':
      [
        'Policy Scope With Exceptions project level scan_execution_policy selects specific projects on project level for SPP',
      ],
    'spec/frontend/super_sidebar/components/promo_menu_spec.js': [
      'PromoMenu template renders all items when in SaaS mode',
    ],
    'ee/spec/frontend/subscriptions/buy_addons_shared/components/order_summary/summary_details_spec.js':
      [
        'SummaryDetails rendering displays a help link',
        'SummaryDetails when tax rate is applied displays a help link',
      ],
    'spec/frontend/ci/pipeline_editor/pipeline_editor_home_spec.js': [
      'Pipeline editor home wrapper job assistant drawer hides the job assistant drawer by default',
      'Pipeline editor home wrapper job assistant drawer toggles the job assistant drawer on button click',
      'Pipeline editor home wrapper job assistant drawer covers helper drawer when opened last',
      'Pipeline editor home wrapper job assistant drawer covered by helper drawer when opened first',
    ],
    'ee/spec/frontend/compliance_dashboard/components/standards_adherence_report/fix_suggestions_sidebar_spec.js':
      [
        'FixSuggestionsSidebar component content for each check type related to MRs for failed checks when check is PREVENT_APPROVAL_BY_MERGE_REQUEST_AUTHOR renders the `learn more` button with the correct href',
        'FixSuggestionsSidebar component content for each check type related to MRs for failed checks when check is PREVENT_APPROVAL_BY_MERGE_REQUEST_COMMITTERS renders the `learn more` button with the correct href',
        'FixSuggestionsSidebar component content for each check type related to MRs for failed checks when check is AT_LEAST_TWO_APPROVALS renders the `learn more` button with the correct href',
      ],
    'ee/spec/frontend/notes/components/note_actions/ai_summarize_notes_spec.js': [
      'AiSummarizeNotes component with summarizeNotesWithDuo feature flag disabled on click unsuccessful mutation shows error if no response within timeout limit',
    ],
  },
};
