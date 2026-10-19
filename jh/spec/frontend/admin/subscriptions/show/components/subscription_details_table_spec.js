import Vue from 'vue';
import { mount } from '@vue/test-utils';
import { createTestingPinia } from '@pinia/testing';
import { PiniaVuePlugin } from 'pinia';
import SubscriptionDetailsTable from 'jh/admin/subscriptions/show/components/subscription_details_table.vue';
import SubscriptionSyncButton from 'jh/admin/subscriptions/show/components/subscription_sync_button.vue';
import { useAdminSubscription } from 'ee/admin/subscriptions/show/store';
import { subscriptionSyncStatus, subscriptionTypes } from 'ee/admin/subscriptions/show/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

Vue.use(PiniaVuePlugin);

describe('JH subscription details with Pinia', () => {
  let wrapper;
  let pinia;
  let store;

  beforeEach(() => {
    pinia = createTestingPinia();
    store = useAdminSubscription();
  });

  const createComponent = (props = {}) => {
    wrapper = extendedWrapper(
      mount(SubscriptionDetailsTable, {
        pinia,
        propsData: {
          details: [
            { detail: 'subscriptionName', value: 'A-S00000001' },
            { detail: 'plan', value: 'ultimate' },
            { detail: 'lastSync', value: 'just now' },
          ],
          ...props,
        },
      }),
    );
  };

  it('renders subscription details without a subscription type', () => {
    createComponent();

    expect(wrapper.text()).toContain('Subscription name:');
    expect(wrapper.text()).toContain('A-S00000001');
    expect(wrapper.text()).toContain('Ultimate');
    expect(wrapper.findComponent(SubscriptionSyncButton).exists()).toBe(false);
  });

  it('marks a failed sync using the Pinia state', () => {
    store.subscriptionSyncStatus = subscriptionSyncStatus.SYNC_FAILURE;
    createComponent();

    expect(wrapper.findByTestId('row-lastsync').classes()).toContain('gl-text-red-500');
  });

  it('dispatches the Pinia sync action for an online subscription', async () => {
    createComponent({ subscriptionType: subscriptionTypes.ONLINE_CLOUD });

    await wrapper.findComponent(SubscriptionSyncButton).find('button').trigger('click');

    expect(store.syncSubscription).toHaveBeenCalledTimes(1);
  });
});
