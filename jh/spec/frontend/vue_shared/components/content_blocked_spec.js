import { nextTick } from 'vue';
import { shallowMount } from '@vue/test-utils';
import { addAppealModalPopupListener } from 'jh/appeal';
import ContentBlocked from 'jh/vue_shared/components/content_blocked.vue';

describe('Content blocked component', () => {
  addAppealModalPopupListener();

  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(ContentBlocked, {
      propsData: {
        id: '1',
        projectFullPath: 'test/test',
        path: 'test',
      },
      attachTo: document.body,
    });
  });

  it('popup the appeal modal', async () => {
    wrapper.find('.js-appeal-modal').trigger('click');

    await nextTick();

    expect(Boolean(document.querySelector('[data-qa-selector="appeal_modal"]'))).not.toBeNull();
  });
});
