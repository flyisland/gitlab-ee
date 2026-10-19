import { GlButton } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import QueryDuoRequest from 'ee/orbit/dashboard/query_editor/query_duo_request.vue';

describe('QueryDuoRequest', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = mountExtended(QueryDuoRequest);
  };

  const findInput = () =>
    wrapper.findByRole('textbox', { name: 'Describe a query for GitLab Duo to write' });
  const findGenerate = () => wrapper.findComponent(GlButton);

  beforeEach(() => {
    createComponent();
  });

  describe('while the request is empty', () => {
    it('turns off Generate', () => {
      expect(findGenerate().props('disabled')).toBe(true);
    });
  });

  describe('when the user describes a query and submits', () => {
    beforeEach(async () => {
      await findInput().setValue('merge requests merged this week');
      await wrapper.find('form').trigger('submit');
    });

    it('turns on Generate and emits the request', () => {
      expect(findGenerate().props('disabled')).toBe(false);
      expect(wrapper.emitted('submit')).toEqual([['merge requests merged this week']]);
    });
  });
});
