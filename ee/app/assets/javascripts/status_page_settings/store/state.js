import { parseBoolean } from '@gitlab/frontend-utils';

export default (initialState = {}) => ({
  enabled: parseBoolean(initialState.enabled) || false,
  url: initialState.url || '',
  bucketName: initialState.bucketName || '',
  region: initialState.region || '',
  awsAccessKey: initialState.awsAccessKey || '',
  awsSecretKey: initialState.awsSecretKey || '',
  operationsSettingsEndpoint: initialState.operationsSettingsEndpoint || '',
  loading: false,
});
