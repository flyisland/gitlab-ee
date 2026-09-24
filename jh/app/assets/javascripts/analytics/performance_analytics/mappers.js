import { mapValues } from 'lodash-es';
import { convertToSnakeCase } from '~/lib/utils/text_utility';
import {
  DEFAULT_TABLE_CONFIG,
  PERFORMANCE_TYPE_COMMITS_NUMBER,
} from 'jh/analytics/performance_analytics/constants';

export const mapTableRequest = (payload) => {
  let req = payload || DEFAULT_TABLE_CONFIG;

  req = mapValues(req, (val) => {
    return typeof val === 'string' ? convertToSnakeCase(val) : val;
  });

  return {
    page: req.page || DEFAULT_TABLE_CONFIG.page,
    sort: req.sort || DEFAULT_TABLE_CONFIG.sort,
    direction: req.direction || DEFAULT_TABLE_CONFIG.direction,
  };
};

export const mapRankRequest = (payload) => {
  let req = payload || PERFORMANCE_TYPE_COMMITS_NUMBER;
  req = convertToSnakeCase(req);

  return {
    rankType: req,
  };
};
