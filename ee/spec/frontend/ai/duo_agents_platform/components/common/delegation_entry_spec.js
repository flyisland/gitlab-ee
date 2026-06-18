import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import DelegationEntry from 'ee/ai/duo_agents_platform/components/common/delegation_entry.vue';
import { getDelegationData } from 'ee/ai/duo_agents_platform/utils';
import {
  mockDelegationItem,
  mockDelegationReturnItem,
  mockDelegationReturnFailureItem,
} from './mock';

describe('DelegationEntry', () => {
  let wrapper;

  const findPrefix = () => wrapper.findByTestId('delegation-entry-prefix');
  const findFallback = () => wrapper.findByTestId('delegation-entry-fallback');
  const findFailure = () => wrapper.findByTestId('delegation-entry-failure');
  const findTruncatedContent = () => wrapper.findByTestId('delegation-entry-truncated-content');

  const createWrapper = (propsData = {}) =>
    shallowMountExtended(DelegationEntry, {
      propsData: {
        item: mockDelegationItem,
        delegationData: getDelegationData(mockDelegationItem),
        ...propsData,
      },
    });

  describe('when delegation data is present', () => {
    beforeEach(() => {
      wrapper = createWrapper();
    });

    it('renders the delegation prefix with target name and subsession id', () => {
      expect(findPrefix().text()).toBe('Delegated to Developer (1) —');
    });

    it('renders the truncated delegation prompt', () => {
      expect(findTruncatedContent().text()).toBe('Implement fix...');
    });
  });

  describe('when delegation data is missing', () => {
    beforeEach(() => {
      wrapper = createWrapper({ delegationData: null });
    });

    it('renders fallback text', () => {
      expect(findFallback().text()).toBe('Delegated to subagent');
    });
  });

  describe('when the item is a successful return', () => {
    beforeEach(() => {
      wrapper = createWrapper({
        item: mockDelegationReturnItem,
        delegationData: null,
      });
    });

    it('renders the return prefix with component name and subsession id', () => {
      expect(findPrefix().text()).toBe('Developer (1) returned —');
    });

    it('renders the returned content', () => {
      expect(findTruncatedContent().text()).toBe('Fix applied, ready for review');
    });
  });

  describe('when the item is a failed return', () => {
    beforeEach(() => {
      wrapper = createWrapper({
        item: mockDelegationReturnFailureItem,
        delegationData: null,
      });
    });

    it('renders the failure text', () => {
      expect(findFailure().text()).toBe('Developer (1) did not produce an answer');
    });

    it('applies the danger text class', () => {
      expect(findFailure().classes()).toContain('gl-text-danger');
    });
  });

  describe('when the delegation prompt is long', () => {
    const longPrompt = 'Implement fix '.repeat(30);

    beforeEach(() => {
      wrapper = createWrapper({
        delegationData: {
          ...getDelegationData(mockDelegationItem),
          prompt: longPrompt,
        },
      });
    });

    it('renders the full prompt content', () => {
      expect(findTruncatedContent().text()).toBe(longPrompt.trim());
    });

    it('applies the truncation class', () => {
      expect(findTruncatedContent().classes()).toContain('gl-truncate');
    });
  });
});
