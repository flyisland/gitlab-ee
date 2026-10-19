import { n__, sprintf } from '~/locale';
import { AGENT_STEP_PILL_VARIANTS } from './constants';

export const getVariantColor = (variant) =>
  AGENT_STEP_PILL_VARIANTS[variant] ?? AGENT_STEP_PILL_VARIANTS.neutral;

export const getAwaitingInputLabel = (count) =>
  sprintf(
    n__(
      'AgentPlan|Awaiting input (%{count} question)',
      'AgentPlan|Awaiting input (%{count} questions)',
      count,
    ),
    { count },
  );
