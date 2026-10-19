import { GlSkeletonLoader, GlEmptyState } from '@gitlab/ui';
import JobTemplate from 'jh/ci/pipeline_editor/components/job_assistant_drawer/job_template.vue';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import { mockJobTemplateList } from './mock_data';

describe('job template', () => {
  let wrapper;

  const findSkeletonLoader = () => wrapper.findComponent(GlSkeletonLoader);
  const findEmptyState = () => wrapper.findComponent(GlEmptyState);
  const findCreateBlankTemplateButton = () => wrapper.findByTestId('create-blank-template-button');
  const findEmptyStateCreateActionButton = () => wrapper.findByTestId('create-new-template-button');

  const createComponent = ({ propsData }) => {
    wrapper = mountExtended(JobTemplate, {
      propsData,
    });
  };

  describe('still loading', () => {
    beforeEach(() => {
      createComponent({
        propsData: {
          loading: true,
          jobTemplateList: [],
        },
      });
    });

    it('should show skeleton loader', () => {
      expect(findSkeletonLoader().exists()).toBe(true);
      expect(findEmptyState().exists()).toBe(false);
    });

    it('should emit hide event when click blank template button', () => {
      findCreateBlankTemplateButton().trigger('click');

      expect(wrapper.emitted('hide')).toHaveLength(1);
    });
  });

  describe('empty template list is loaded', () => {
    beforeEach(() => {
      createComponent({
        propsData: {
          loading: false,
          jobTemplateList: [],
        },
      });
    });

    it('should show empty state', () => {
      expect(findSkeletonLoader().exists()).toBe(false);
      expect(findEmptyState().exists()).toBe(true);
    });

    it('should emit hide event when click confirm action button', () => {
      findEmptyStateCreateActionButton().trigger('click');

      expect(wrapper.emitted('hide')).toHaveLength(1);
    });
  });

  describe('template list is loaded', () => {
    beforeEach(() => {
      createComponent({
        propsData: {
          loading: false,
          jobTemplateList: mockJobTemplateList,
        },
      });
    });

    it('should not show skeleton loader and empty state', () => {
      expect(findSkeletonLoader().exists()).toBe(false);
      expect(findEmptyState().exists()).toBe(false);
    });

    it('should emit hide event when click blank template button', () => {
      findCreateBlankTemplateButton().trigger('click');

      expect(wrapper.emitted('hide')).toHaveLength(1);
    });
  });
});
