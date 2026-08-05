import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import EnvironmentsIndex from 'ee/cd/components/environments_index.vue';
import EnvironmentCard from 'ee/cd/components/environment_card.vue';
import EnvironmentList from 'ee/cd/components/environment_list.vue';
import NewEnvironmentPanel from 'ee/cd/components/new_environment_panel.vue';
import FilterBar from 'ee/cd/components/shared/filter_bar.vue';
import cdEnvironmentsQuery from 'ee/cd/graphql/cd_environments.query.graphql';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import { buildEnvironmentsQueryResponse } from './mock_data';

jest.mock('~/sentry/sentry_browser_wrapper');

Vue.use(VueApollo);

describe('EnvironmentsIndex', () => {
  let wrapper;

  const environments = [
    {
      __typename: 'CdEnvironment',
      id: 'gid://gitlab/Cd::Environment/1',
      name: 'prod-eu-west-1',
      tier: 'PRODUCTION',
    },
    {
      __typename: 'CdEnvironment',
      id: 'gid://gitlab/Cd::Environment/2',
      name: 'staging-us-east-1',
      tier: 'STAGING',
    },
  ];

  const defaultQueryHandler = jest.fn().mockResolvedValue(buildEnvironmentsQueryResponse());

  const findPageHeading = () => wrapper.findComponent(PageHeading);
  const findFilterBar = () => wrapper.findComponent(FilterBar);
  const findEnvironmentCards = () => wrapper.findAllComponents(EnvironmentCard);
  const findEnvironmentList = () => wrapper.findComponent(EnvironmentList);
  const findRegisterButton = () => wrapper.findByTestId('register-environment-button');
  const findNewEnvironmentPanel = () => wrapper.findComponent(NewEnvironmentPanel);

  const createComponent = ({ queryHandler = defaultQueryHandler } = {}) => {
    wrapper = shallowMountExtended(EnvironmentsIndex, {
      apolloProvider: createMockApollo([[cdEnvironmentsQuery, queryHandler]]),
    });
  };

  beforeEach(async () => {
    createComponent();
    await waitForPromises();
  });

  describe('page heading', () => {
    it('renders the Environments title', () => {
      expect(findPageHeading().props('heading')).toBe('Environments');
    });

    it('renders the Register environment button', () => {
      const button = findRegisterButton();

      expect(button.text()).toBe('Register environment');
      expect(button.props('variant')).toBe('confirm');
    });
  });

  describe('filter bar', () => {
    it('passes the environment tier filters to the filter bar', () => {
      expect(findFilterBar().props('filters')).toEqual([
        { id: 'ALL', text: 'All types' },
        { id: 'DEVELOPMENT', text: 'Development' },
        { id: 'QA', text: 'QA' },
        { id: 'STAGING', text: 'Staging' },
        { id: 'PRODUCTION', text: 'Production' },
      ]);
    });
  });

  describe('when there are no environments', () => {
    it('renders the empty environment list', () => {
      expect(findEnvironmentList().exists()).toBe(true);
    });

    it('does not render environment cards', () => {
      expect(findEnvironmentCards()).toHaveLength(0);
    });
  });

  describe('when the query returns environments', () => {
    beforeEach(async () => {
      createComponent({
        queryHandler: jest.fn().mockResolvedValue(buildEnvironmentsQueryResponse(environments)),
      });
      await waitForPromises();
    });

    it('renders a card with the name of each environment', () => {
      expect(findEnvironmentCards()).toHaveLength(2);
      expect(findEnvironmentCards().at(0).props('name')).toBe('prod-eu-west-1');
      expect(findEnvironmentCards().at(1).props('name')).toBe('staging-us-east-1');
    });

    it('does not render the empty environment list', () => {
      expect(findEnvironmentList().exists()).toBe(false);
    });
  });

  describe('when the environments query fails', () => {
    beforeEach(async () => {
      createComponent({ queryHandler: jest.fn().mockRejectedValue(new Error('GraphQL error')) });
      await waitForPromises();
    });

    it('reports the exception to Sentry', () => {
      expect(Sentry.captureException).toHaveBeenCalledWith(new Error('GraphQL error'));
    });

    it('renders the empty environment list', () => {
      expect(findEnvironmentList().exists()).toBe(true);
    });
  });

  describe('register environment panel', () => {
    it('renders the panel closed by default', () => {
      expect(findNewEnvironmentPanel().props('open')).toBe(false);
    });

    describe('when the register button is clicked', () => {
      beforeEach(async () => {
        await findRegisterButton().vm.$emit('click');
      });

      it('opens the panel', () => {
        expect(findNewEnvironmentPanel().props('open')).toBe(true);
      });

      describe('when the panel emits close', () => {
        beforeEach(async () => {
          await findNewEnvironmentPanel().vm.$emit('close');
        });

        it('closes the panel', () => {
          expect(findNewEnvironmentPanel().props('open')).toBe(false);
        });
      });
    });

    describe('when the environment list emits register', () => {
      beforeEach(async () => {
        await findEnvironmentList().vm.$emit('register');
      });

      it('opens the panel', () => {
        expect(findNewEnvironmentPanel().props('open')).toBe(true);
      });
    });
  });
});
