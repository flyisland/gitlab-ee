import { s__ } from '~/locale';
import { DUO_CHAT_AGENT_PLANNER } from '~/ai/constants';

export const WORK_PLAN_PROMPT = s__(
  `AgentPlan|You are here to help refine a plan for the user from the Work Item context to a Markdown output with key information required for Agent to pick off the work. The template should have a Why, How, What format with key insights and list of steps. If the issue is lacking details, start by reading the comments. Then, ask clarifying questions to the users in Chat until you are confident. If there are pending questions, please preserve them inside the plan. Then, please proceed with updating the work item 'Workplan' widget with your output. You can erase everything was there before and add your new plan entirely. Don't preserve existing notes if they dont align with what you wrote. If there is enough information but the title or description is lacking, please propose to update it minimally with key insights. Try to preserve anything that is already present, just add on top and dont repeat the full plan. What is important is syncing up enough to preserve the intent and adding data where we had none before.`,
);

export const WORK_PLAN_CHAT_COMMAND = {
  agent: { name: DUO_CHAT_AGENT_PLANNER },
  agenticPrompt: WORK_PLAN_PROMPT,
};
