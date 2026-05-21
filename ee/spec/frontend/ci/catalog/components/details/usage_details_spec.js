import { GlTable, GlLink, GlIcon, GlTruncateText, GlKeysetPagination } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import UsageDetails from 'ee/ci/catalog/components/details/usage_details.vue';
import {
  mockComponentUsages,
  mockOutdatedComponentUsages,
  mockMultipleComponentUsages,
  mockNullProjectComponentUsages,
  mockPageInfo,
  mockPageInfoPage2,
} from './mock_data';

describe('UsageDetails', () => {
  let wrapper;

  const createComponent = ({
    componentUsages = mockComponentUsages,
    pageInfo = mockPageInfo,
  } = {}) => {
    wrapper = mountExtended(UsageDetails, {
      propsData: {
        componentUsages,
        pageInfo,
      },
    });
  };

  const findTable = () => wrapper.findComponent(GlTable);
  const findAllTableRows = () => findTable().findAll('tbody > tr');
  const findProjectLinks = () => wrapper.findAllComponents(GlLink);
  const findStatusIcons = () => wrapper.findAllComponents(GlIcon);
  const findTruncateText = () => wrapper.findComponent(GlTruncateText);
  const findPagination = () => wrapper.findComponent(GlKeysetPagination);

  describe('table structure', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the table with correct fields', () => {
      expect(findTable().props('fields')).toMatchObject([
        expect.objectContaining({ key: 'project', label: 'Project path' }),
        expect.objectContaining({ key: 'status', label: 'Status' }),
        expect.objectContaining({ key: 'componentsUsed', label: 'Components used' }),
      ]);
    });
  });

  describe('with up-to-date components', () => {
    beforeEach(() => {
      createComponent({ componentUsages: mockComponentUsages });
    });

    it('displays project path', () => {
      const projectLink = findProjectLinks().at(0);
      const { project } = mockComponentUsages[0];
      expect(projectLink.attributes('href')).toBe(project.webPath);
      expect(projectLink.text()).toBe(project.nameWithNamespace);
    });

    it('shows up-to-date status with success icon', () => {
      const statusIcon = findStatusIcons().at(0);
      expect(statusIcon.props('name')).toBe('status_success');
      expect(findAllTableRows().at(0).text()).toContain('Up to date');
      expect(findAllTableRows().at(0).text()).toContain('1.0.0');
    });

    it('displays components used', () => {
      expect(findTruncateText().text()).toContain('component-1 (1.0.0)');
    });
  });

  describe('with outdated components', () => {
    beforeEach(() => {
      createComponent({ componentUsages: mockOutdatedComponentUsages });
    });

    it('shows outdated status with warning icon', () => {
      const statusIcon = findStatusIcons().at(0);
      expect(statusIcon.props('name')).toBe('warning');
      expect(findAllTableRows().at(0).text()).toContain('Outdated');
      expect(findAllTableRows().at(0).text()).toContain('0.9.0');
    });
  });

  describe('with multiple components', () => {
    beforeEach(() => {
      createComponent({ componentUsages: mockMultipleComponentUsages });
    });

    it('displays all components in sorted order', () => {
      expect(findAllTableRows().at(0).text()).toContain('component-b (1.5.0), component-a (2.0.0)');
    });

    it('uses truncate text for long component lists', () => {
      expect(findTruncateText().props('lines')).toBe(2);
      expect(findTruncateText().props('mobileLines')).toBe(4);
    });
  });

  describe('with null project (private/inaccessible)', () => {
    beforeEach(() => {
      createComponent({
        componentUsages: [...mockComponentUsages, ...mockNullProjectComponentUsages],
      });
    });

    it('renders "Private project" text instead of a link', () => {
      expect(findAllTableRows().at(1).text()).toContain('Private project');
    });

    it('displays components used for the null project row', () => {
      const rows = findAllTableRows();
      expect(rows.at(1).text()).toContain('component-5 (1.2.0)');
    });
  });

  describe('with multiple projects', () => {
    beforeEach(() => {
      createComponent({
        componentUsages: [...mockComponentUsages, ...mockOutdatedComponentUsages],
      });
    });

    it('renders a row for each project', () => {
      expect(findTable().props('items')).toHaveLength(2);
    });

    it('displays correct status for each project', () => {
      expect(findAllTableRows().at(0).text()).toContain('Up to date');
      expect(findAllTableRows().at(1).text()).toContain('Outdated');
    });
  });

  describe('pagination', () => {
    it('renders keyset pagination with correct page info', () => {
      createComponent();

      expect(findPagination().exists()).toBe(true);
      expect(findPagination().props()).toMatchObject({
        hasNextPage: mockPageInfo.hasNextPage,
        hasPreviousPage: mockPageInfo.hasPreviousPage,
        prevText: 'Previous',
        nextText: 'Next',
      });
    });

    it('emits next-page when next button is clicked', () => {
      createComponent();

      findPagination().vm.$emit('next');

      expect(wrapper.emitted('next-page')).toHaveLength(1);
    });

    it('emits prev-page when previous button is clicked', () => {
      createComponent({
        pageInfo: mockPageInfoPage2,
      });

      findPagination().vm.$emit('prev');

      expect(wrapper.emitted('prev-page')).toHaveLength(1);
    });
  });
});
