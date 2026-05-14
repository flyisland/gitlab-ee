import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { createMockSubscription as createMockApolloSubscription } from 'mock-apollo-client';
import { GlIcon, GlSprintf } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import MrWidgetSecurityPolicyPipelineNote from 'ee/vue_merge_request_widget/components/mr_widget_security_policy_pipeline_note.vue';
import mergeChecksQuery from '~/vue_merge_request_widget/queries/merge_checks.query.graphql';
import mergeChecksSubscription from '~/vue_merge_request_widget/queries/merge_checks.subscription.graphql';

Vue.use(VueApollo);

describe('MrWidgetSecurityPolicyPipelineNote', () => {
  let wrapper;

  const policiesPath = '/group/project/-/security/policies';

  const createMergeChecksResponse = (checks = []) => ({
    data: {
      project: {
        id: 'gid://gitlab/Project/1',
        mergeRequest: {
          id: 'gid://gitlab/MergeRequest/1',
          userPermissions: { canMerge: true },
          mergeabilityChecks: checks,
        },
      },
    },
  });

  function createComponent({
    securityPoliciesPath = policiesPath,
    isPipelinePassing = true,
    mergeChecks = [],
  } = {}) {
    const mergeChecksHandler = jest.fn().mockResolvedValue(createMergeChecksResponse(mergeChecks));

    const apolloProvider = createMockApollo([[mergeChecksQuery, mergeChecksHandler]]);

    apolloProvider.defaultClient.setRequestHandler(mergeChecksSubscription, () =>
      createMockApolloSubscription(),
    );

    wrapper = shallowMountExtended(MrWidgetSecurityPolicyPipelineNote, {
      propsData: {
        mr: {
          securityPoliciesPath,
          isPipelinePassing,
          targetProjectFullPath: 'group/project',
          iid: 1,
          id: 1,
        },
      },
      stubs: {
        GlSprintf,
      },
      apolloProvider,
    });
  }

  const findNote = () => wrapper.findByTestId('security-policy-pipeline-note');
  const findIcon = () => wrapper.findComponent(GlIcon);
  const findViewPoliciesLink = () => wrapper.findByTestId('view-policies-link');

  describe('when all conditions are met (pipeline passing + check blocking + path exists)', () => {
    beforeEach(async () => {
      createComponent({
        mergeChecks: [{ identifier: 'SECURITY_POLICY_PIPELINE_CHECK', status: 'FAILED' }],
      });
      await waitForPromises();
    });

    it('renders the note container', () => {
      expect(findNote().exists()).toBe(true);
    });

    it('renders a warning icon', () => {
      expect(findIcon().props('name')).toBe('status-alert');
      expect(findIcon().props('variant')).toBe('warning');
    });

    it('displays the failure message', () => {
      expect(findNote().text()).toContain(
        'Merge request pipeline has passed, but a security policy requires all pipelines to succeed. Another pipeline for this commit has failed.',
      );
    });

    it('renders the View policies link with correct href', () => {
      const link = findViewPoliciesLink();

      expect(link.exists()).toBe(true);
      expect(link.attributes('href')).toBe(policiesPath);
      expect(link.text()).toBe('View policies');
    });
  });

  describe('when security policy pipeline check has WARNING status', () => {
    beforeEach(async () => {
      createComponent({
        mergeChecks: [{ identifier: 'SECURITY_POLICY_PIPELINE_CHECK', status: 'WARNING' }],
      });
      await waitForPromises();
    });

    it('renders the note', () => {
      expect(findNote().exists()).toBe(true);
    });
  });

  describe('when the note should not show', () => {
    it('does not render when pipeline is not passing', async () => {
      createComponent({
        isPipelinePassing: false,
        mergeChecks: [{ identifier: 'SECURITY_POLICY_PIPELINE_CHECK', status: 'FAILED' }],
      });
      await waitForPromises();

      expect(findNote().exists()).toBe(false);
    });

    it('does not render when securityPoliciesPath is empty', async () => {
      createComponent({
        securityPoliciesPath: '',
        mergeChecks: [{ identifier: 'SECURITY_POLICY_PIPELINE_CHECK', status: 'FAILED' }],
      });
      await waitForPromises();

      expect(findNote().exists()).toBe(false);
    });

    it('does not render when check status is SUCCESS', async () => {
      createComponent({
        mergeChecks: [{ identifier: 'SECURITY_POLICY_PIPELINE_CHECK', status: 'SUCCESS' }],
      });
      await waitForPromises();

      expect(findNote().exists()).toBe(false);
    });

    it('does not render when check status is INACTIVE', async () => {
      createComponent({
        mergeChecks: [{ identifier: 'SECURITY_POLICY_PIPELINE_CHECK', status: 'INACTIVE' }],
      });
      await waitForPromises();

      expect(findNote().exists()).toBe(false);
    });

    it('does not render when no security policy pipeline check exists', async () => {
      createComponent({
        mergeChecks: [],
      });
      await waitForPromises();

      expect(findNote().exists()).toBe(false);
    });
  });
});
