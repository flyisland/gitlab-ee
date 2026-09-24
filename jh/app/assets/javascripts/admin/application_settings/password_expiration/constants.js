import { s__ } from '~/locale';

export const titleText = s__('JH|Password expiration policy');

export const labelText = {
  isEnableExpiration: s__('JH|Enable the password expiration policy'),
  inDays: s__('JH|Expires in days'),
  beforeDays: s__('JH|Set the number of days to notify before expiration'),
};

export const descriptionText = {
  inDays: s__(
    'JH|Set the number of days after which user passwords expire. Choose a number from 14 to 400.',
  ),
  beforeDays: s__(
    'JH|Set the number of days prior to password expiration that you want to notify users. Choose a number from 1 to 30.',
  ),
};
