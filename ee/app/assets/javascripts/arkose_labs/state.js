import { observable } from '~/lib/utils/observable';

export const ARKOSE_STATE_KEY = 'arkose_signup_state';

export const arkoseState = observable(ARKOSE_STATE_KEY, {
  token: '',
  challengeBypassed: false,
  iframeShown: false,
  awaitingToken: false,
});

export const resetArkoseState = () => {
  arkoseState.token = '';
  arkoseState.challengeBypassed = false;
  arkoseState.iframeShown = false;
  arkoseState.awaitingToken = false;
};
