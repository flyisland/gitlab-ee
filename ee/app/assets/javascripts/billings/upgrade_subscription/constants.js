export const PLAN_PREMIUM = 'premium';
export const PLAN_ULTIMATE = 'ultimate';

export const CREDIT_OPTION_INCLUDED = 'included';
export const CREDIT_OPTION_MONTHLY = 'monthly';

export const STEP_STATUS_ACTIVE = 'active';
export const STEP_STATUS_COMPLETE = 'complete';
export const STEP_STATUS_DISABLED = 'disabled';

export const VALID_SUBSCRIPTION_STEP_STATUSES = [
  STEP_STATUS_ACTIVE,
  STEP_STATUS_COMPLETE,
  STEP_STATUS_DISABLED,
];

export const STEPS = {
  PLAN_SELECTION: 1,
  CREDIT_SELECTION: 2,
};

export const PLAN_CREDIT_DETAILS = {
  [PLAN_ULTIMATE]: { creditsPerUser: 24, maxCodeSuggestions: 1200, maxCodeReviews: 96 },
  [PLAN_PREMIUM]: { creditsPerUser: 12, maxCodeSuggestions: 600, maxCodeReviews: 48 },
};
