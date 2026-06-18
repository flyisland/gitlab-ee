import { convertGraphQLVarsToRestParams as ceConvertGraphQLVarsToRestParams } from '~/work_items/list/graphql/rest/rest_filter_params_mapper';

// eslint-disable-next-line @gitlab/require-i18n-strings
const WILDCARD_MAP = { ANY: 'Any', NONE: 'None', UPCOMING: 'Upcoming', STARTED: 'Started' };

const HEALTH_STATUS_GRAPHQL_TO_REST = {
  onTrack: 'on_track',
  needsAttention: 'needs_attention',
  atRisk: 'at_risk',
};

function mapHealthStatus(value) {
  if (Array.isArray(value)) {
    return value.map((v) => HEALTH_STATUS_GRAPHQL_TO_REST[v] ?? v);
  }
  return HEALTH_STATUS_GRAPHQL_TO_REST[value] ?? value;
}

function appendParam(params, key, value) {
  if (value === null || value === undefined) return;
  if (Array.isArray(value)) {
    value.forEach((v) => {
      if (v !== null && v !== undefined) params.append(`${key}[]`, v);
    });
  } else {
    params.append(key, value);
  }
}

export function convertGraphQLVarsToRestParams(vars) {
  const { healthStatusFilter: notHealthStatus, ...notRest } = vars.not ?? {};
  const { healthStatusFilter: orHealthStatus, ...orRest } = vars.or ?? {};

  const params = ceConvertGraphQLVarsToRestParams({
    ...vars,
    not: vars.not ? notRest : vars.not,
    or: vars.or ? orRest : vars.or,
  });

  appendParam(params, 'not[health_status_filter]', mapHealthStatus(notHealthStatus));
  appendParam(params, 'or[health_status_filter]', mapHealthStatus(orHealthStatus));

  appendParam(params, 'weight', vars.weight);
  appendParam(params, 'weight_wildcard_id', WILDCARD_MAP[vars.weightWildcardId]);
  appendParam(params, 'health_status_filter', mapHealthStatus(vars.healthStatusFilter));
  appendParam(params, 'iteration_id', vars.iterationId);
  appendParam(params, 'iteration_wildcard_id', WILDCARD_MAP[vars.iterationWildcardId]);
  appendParam(params, 'iteration_cadence_id', vars.iterationCadenceId);

  if (vars.status) {
    if (vars.status.id) {
      params.append('status[id]', vars.status.id);
    }
    if (vars.status.name) {
      params.append('status[name]', vars.status.name);
    }
  }

  if (vars.customField?.length) {
    vars.customField.forEach((field) => {
      if (field.fieldId && field.values) {
        field.values.forEach((value) => {
          params.append('custom_fields[]', `${field.fieldId}:${value}`);
        });
      }
    });
  }

  return params;
}
