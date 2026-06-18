import { GlSprintf } from '@gitlab/ui';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import CreateGranularPersonalAccessTokenForm from '~/personal_access_tokens/components/create_granular_token/create_granular_personal_access_token_form.vue';
import PersonalAccessTokenPermissionsSelector from '~/personal_access_tokens/components/create_granular_token/personal_access_token_permissions_selector.vue';
import createGranularPersonalAccessTokenMutation from '~/personal_access_tokens/graphql/create_granular_personal_access_token.mutation.graphql';
import getAccessTokenPermissions from '~/personal_access_tokens/graphql/get_access_token_permissions.query.graphql';

jest.mock('~/alert');

Vue.use(VueApollo);

describe('CreateGranularPersonalAccessTokenForm - EE', () => {
  let wrapper;
  let mockApollo;

  const mockMutationHandler = jest.fn().mockResolvedValue({ data: {} });
  const mockPermissionsHandler = jest
    .fn()
    .mockResolvedValue({ data: { accessTokenPermissions: [] } });

  const createComponent = ({ provide = {} } = {}) => {
    mockApollo = createMockApollo([
      [createGranularPersonalAccessTokenMutation, mockMutationHandler],
      [getAccessTokenPermissions, mockPermissionsHandler],
    ]);

    wrapper = shallowMountExtended(CreateGranularPersonalAccessTokenForm, {
      apolloProvider: mockApollo,
      provide: {
        accessTokenMaxDate: '2025-12-31',
        accessTokenTableUrl: '/-/personal_access_tokens',
        ...provide,
      },
      stubs: {
        GlSprintf,
        GlTabs: { template: '<div><slot name="tabs-end" /><slot /></div>' },
        AskDapPermissions: true,
      },
    });
  };

  const findAskDapPermissions = () => wrapper.findComponent({ name: 'AskDapPermissions' });
  const findPermissionsSelectors = () =>
    wrapper.findAllComponents(PersonalAccessTokenPermissionsSelector);
  const findGroupPermissionsSelector = () => findPermissionsSelectors().at(0);
  const findUserPermissionsSelector = () => findPermissionsSelectors().at(1);

  describe('Duo permission suggestions', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the AskDapPermissions component', () => {
      expect(findAskDapPermissions().exists()).toBe(true);
    });

    describe('permissions-selected event', () => {
      it('passes selected permissions to both permission selectors', async () => {
        await findAskDapPermissions().vm.$emit('permissions-selected', ['read_project']);

        expect(findGroupPermissionsSelector().props('aiPermissions')).toEqual({
          suggested: ['read_project'],
          removed: [],
        });

        expect(findUserPermissionsSelector().props('aiPermissions')).toEqual({
          suggested: ['read_project'],
          removed: [],
        });
      });

      it('replaces previous selections on each emission', async () => {
        await findAskDapPermissions().vm.$emit('permissions-selected', ['read_project']);
        await findAskDapPermissions().vm.$emit('permissions-selected', ['write_project']);

        expect(findGroupPermissionsSelector().props('aiPermissions')).toEqual({
          suggested: ['write_project'],
          removed: [],
        });
      });
    });

    describe('permissions-cleared event', () => {
      it('passes cleared permissions to both permission selectors', async () => {
        await findAskDapPermissions().vm.$emit('permissions-cleared', ['read_project']);

        expect(findGroupPermissionsSelector().props('aiPermissions')).toEqual({
          suggested: [],
          removed: ['read_project'],
        });

        expect(findUserPermissionsSelector().props('aiPermissions')).toEqual({
          suggested: [],
          removed: ['read_project'],
        });
      });
    });
  });
});
