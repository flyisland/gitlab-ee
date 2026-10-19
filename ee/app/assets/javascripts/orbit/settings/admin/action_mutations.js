import excludedNamespaceCreateMutation from '../../graphql/mutations/excluded_namespace_create.mutation.graphql';
import excludedNamespaceDestroyMutation from '../../graphql/mutations/excluded_namespace_destroy.mutation.graphql';
import orbitUpdateMutation from '../../graphql/mutations/orbit_update.mutation.graphql';
import {
  ACTION_ERROR_KIND,
  ACTION_EXCLUDE,
  ACTION_INCLUDE,
  ACTION_TURN_OFF,
  ACTION_TURN_ON,
} from './constants';
import { requestErrorFor } from './utils';

const ACTION_MUTATIONS = {
  [ACTION_TURN_ON]: {
    mutation: orbitUpdateMutation,
    payload: 'orbitUpdate',
    input: (group) => ({ groupPath: group.fullPath, enabled: true }),
  },
  [ACTION_TURN_OFF]: {
    mutation: orbitUpdateMutation,
    payload: 'orbitUpdate',
    input: (group) => ({ groupPath: group.fullPath, enabled: false }),
  },
  [ACTION_EXCLUDE]: {
    mutation: excludedNamespaceCreateMutation,
    payload: 'knowledgeGraphExcludedNamespaceCreate',
    input: (group) => ({ groupPath: group.fullPath }),
  },
  [ACTION_INCLUDE]: {
    mutation: excludedNamespaceDestroyMutation,
    payload: 'knowledgeGraphExcludedNamespaceDestroy',
    input: (group) => ({ groupPath: group.fullPath }),
  },
};

/**
 * Runs an action on one group. Returns the failure to show, and the request error when the request
 * failed, so that a bulk action can report one error to Sentry instead of one for each group.
 */
export async function mutateGroup(apollo, action, group) {
  const { mutation, payload, input } = ACTION_MUTATIONS[action];

  try {
    const { data } = await apollo.mutate({ mutation, variables: { input: input(group) } });
    const { errors } = data[payload];
    const failure = errors.length
      ? { kind: ACTION_ERROR_KIND.REJECTED, message: errors.join(' ') }
      : null;
    return { failure };
  } catch (error) {
    return { failure: requestErrorFor(error), error };
  }
}
