import { GlFormSelect, GlFormInput } from '@gitlab/ui';
import { nextTick } from 'vue';
import MockAdapter from 'axios-mock-adapter';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import axios from '~/lib/utils/axios_utils';
import { HTTP_STATUS_OK, HTTP_STATUS_UNPROCESSABLE_ENTITY } from '~/lib/utils/http_status';
import { visitUrl } from '~/lib/utils/url_utility';
import waitForPromises from 'helpers/wait_for_promises';
import TargetedMessageForm from '~/admin/targeted_messages/components/targeted_message_form.vue';

jest.mock('~/lib/utils/url_utility');

describe('TargetedMessageForm', () => {
  let wrapper;
  let mockAxios;

  const defaultProps = {
    targetTypes: [{ value: 'banner_page_level', text: 'Banner page level' }],
    formAction: '/admin/targeted_messages',
    isAddForm: true,
    initialTargetType: '',
    maxNamespaceIds: 10000,
    messagesPath: '/admin/targeted_messages',
  };

  const findForm = () => wrapper.find('form');
  const findTargetTypeSelect = () => wrapper.findComponent(GlFormSelect);
  const findFileInput = () => wrapper.findByTestId('namespace-ids-csv-input');
  const findSubmitButton = () => wrapper.findByTestId('submit-button');
  const findStartsAtField = () => wrapper.findByTestId('starts-at-field');
  const findEndsAtField = () => wrapper.findByTestId('ends-at-field');
  const findStartsAtInput = () => findStartsAtField().findComponent(GlFormInput);
  const findEndsAtInput = () => findEndsAtField().findComponent(GlFormInput);
  const findGlFormFields = () => wrapper.findComponent({ name: 'GlFormFields' });
  const emitSubmitForm = () => {
    wrapper.vm.onSubmit();
  };

  const createComponent = (props = {}) => {
    wrapper = mountExtended(TargetedMessageForm, {
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  const setupFormWithData = async () => {
    const file = new File(['1,2,3'], 'namespaces.csv', { type: 'text/csv' });
    const fileInput = findFileInput();

    Object.defineProperty(fileInput.element, 'files', {
      value: [file],
      writable: false,
    });

    await fileInput.trigger('change');
  };

  const submitForm = async () => {
    emitSubmitForm();
    await waitForPromises();
  };

  beforeEach(() => {
    mockAxios = new MockAdapter(axios);
  });

  afterEach(() => {
    mockAxios.restore();
  });

  describe('rendering', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the form', () => {
      expect(findForm().exists()).toBe(true);
    });

    it('renders target type select', () => {
      expect(findTargetTypeSelect().exists()).toBe(true);
    });

    it('renders file input', () => {
      expect(findFileInput().attributes()).toMatchObject({
        type: 'file',
        accept: '.csv',
      });
    });

    it('renders submit button with correct text', () => {
      expect(findSubmitButton().text()).toBe('Create');
    });
  });

  describe('target type options', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders target type select with correct options', () => {
      const select = findTargetTypeSelect();
      expect(select.exists()).toBe(true);
    });
  });

  describe('edit mode', () => {
    beforeEach(() => {
      createComponent({
        isAddForm: false,
        initialTargetType: 'banner_page_level',
      });
    });

    it('renders target type select in edit mode', () => {
      expect(findTargetTypeSelect().exists()).toBe(true);
    });

    it('renders update button text', () => {
      expect(findSubmitButton().text()).toBe('Update');
    });
  });

  describe('file selection', () => {
    beforeEach(() => {
      createComponent();
    });

    it('handles file selection', async () => {
      const file = new File(['content'], 'namespaces.csv', { type: 'text/csv' });
      const fileInput = findFileInput();

      Object.defineProperty(fileInput.element, 'files', {
        value: [file],
        writable: false,
      });

      await fileInput.trigger('change');
      await nextTick();

      expect(fileInput.element.files[0]).toBe(file);
    });
  });

  describe('datetime fields', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders two datetime pickers', () => {
      expect(findStartsAtField().exists()).toBe(true);
      expect(findEndsAtField().exists()).toBe(true);
    });

    it('initializes datetime fields as null for new form', () => {
      expect(findStartsAtInput().props('value')).toBeNull();
      expect(findEndsAtInput().props('value')).toBeNull();
    });

    it('initializes datetime fields with values for edit form', async () => {
      const startsAt = '2025-12-20T10:00:00Z';
      const endsAt = '2025-12-20T12:00:00Z';

      createComponent({
        isAddForm: false,
        initialStartsAt: startsAt,
        initialEndsAt: endsAt,
      });

      await nextTick();

      expect(findStartsAtInput().props('value')).toBe('2025-12-20T10:00');
      expect(findEndsAtInput().props('value')).toBe('2025-12-20T12:00');
    });

    it('includes datetime values in form submission when set', async () => {
      mockAxios.onPost('/admin/targeted_messages').reply(HTTP_STATUS_OK);

      createComponent({
        initialTargetType: 'banner_page_level',
        initialStartsAt: '2025-12-20T10:00:00Z',
        initialEndsAt: '2025-12-20T12:00:00Z',
      });
      await setupFormWithData();
      await submitForm();

      const postRequest = mockAxios.history.post[0];
      expect(postRequest.data).toBeInstanceOf(FormData);
      expect(postRequest.data.get('targeted_message[starts_at]')).toBe('2025-12-20T10:00:00.000Z');
      expect(postRequest.data.get('targeted_message[ends_at]')).toBe('2025-12-20T12:00:00.000Z');
    });

    it('does not include datetime values in form submission when null', async () => {
      mockAxios.onPost('/admin/targeted_messages').reply(HTTP_STATUS_OK);

      createComponent({
        initialTargetType: 'banner_page_level',
      });
      await nextTick();
      await submitForm();

      const postRequest = mockAxios.history.post[0];
      expect(postRequest.data).toBeInstanceOf(FormData);
      expect(postRequest.data.get('targeted_message[starts_at]')).toBeNull();
      expect(postRequest.data.get('targeted_message[ends_at]')).toBeNull();
    });
  });

  describe('form validation', () => {
    beforeEach(() => {
      createComponent({
        initialTargetType: 'banner_page_level',
      });
    });

    it('submits form even when fields are empty', async () => {
      mockAxios.onPost('/admin/targeted_messages').reply(HTTP_STATUS_OK);

      await submitForm();

      expect(mockAxios.history.post).toHaveLength(1);
      expect(visitUrl).toHaveBeenCalledWith('/admin/targeted_messages');
    });

    it('submits form when all required fields are filled', async () => {
      mockAxios.onPost('/admin/targeted_messages').reply(HTTP_STATUS_OK);

      await setupFormWithData();
      await submitForm();

      expect(mockAxios.history.post).toHaveLength(1);
    });
  });

  describe('form submission', () => {
    describe('when creating a new message', () => {
      beforeEach(() => {
        createComponent({
          initialTargetType: 'banner_page_level',
        });
      });

      it('sends a POST request with form data and redirects on success', async () => {
        mockAxios.onPost('/admin/targeted_messages').reply(HTTP_STATUS_OK);

        await setupFormWithData();
        await submitForm();

        expect(mockAxios.history.post).toHaveLength(1);
        expect(mockAxios.history.post[0].url).toBe('/admin/targeted_messages');
        expect(visitUrl).toHaveBeenCalledWith('/admin/targeted_messages');
      });

      it('redirects to edit page when redirect_to is provided', async () => {
        mockAxios.onPost('/admin/targeted_messages').reply(HTTP_STATUS_OK, {
          redirect_to: '/admin/targeted_messages/1/edit',
        });

        await setupFormWithData();
        await submitForm();

        expect(visitUrl).toHaveBeenCalledWith('/admin/targeted_messages/1/edit');
      });

      it('displays inline errors on validation failure', async () => {
        const errors = {
          target_type: ["can't be blank"],
          targeted_message_namespaces: ["can't be blank"],
        };
        mockAxios
          .onPost('/admin/targeted_messages')
          .reply(HTTP_STATUS_UNPROCESSABLE_ENTITY, { message: errors });

        await setupFormWithData();
        await submitForm();

        expect(findGlFormFields().props('serverValidations')).toEqual({
          targetType: "Target Type can't be blank",
          namespaceIdsCsvFile: "Namespace IDs can't be blank",
        });
      });

      it('passes server validation errors to GlFormFields', async () => {
        const errors = {
          target_type: ["can't be blank"],
          targeted_message_namespaces: ["can't be blank"],
        };
        mockAxios
          .onPost('/admin/targeted_messages')
          .reply(HTTP_STATUS_UNPROCESSABLE_ENTITY, { message: errors });

        await setupFormWithData();
        await submitForm();

        expect(findGlFormFields().props('serverValidations')).toEqual({
          targetType: "Target Type can't be blank",
          namespaceIdsCsvFile: "Namespace IDs can't be blank",
        });
      });

      it('does not display errors when response has no error data', async () => {
        mockAxios.onPost('/admin/targeted_messages').reply(500);

        await setupFormWithData();
        await submitForm();

        expect(findGlFormFields().props('serverValidations')).toEqual({});
      });
    });

    describe('when editing an existing message', () => {
      beforeEach(() => {
        createComponent({
          isAddForm: false,
          formAction: '/admin/targeted_messages/1',
          initialTargetType: 'banner_page_level',
        });
      });
      it('sends a PATCH request with form data and redirects on success', async () => {
        mockAxios.onPatch('/admin/targeted_messages/1').reply(HTTP_STATUS_OK);

        await setupFormWithData();
        await submitForm();

        expect(mockAxios.history.patch).toHaveLength(1);
        expect(mockAxios.history.patch[0].url).toBe('/admin/targeted_messages/1');
        expect(visitUrl).toHaveBeenCalledWith('/admin/targeted_messages');
      });

      it('redirects to edit page when redirect_to is provided', async () => {
        mockAxios.onPatch('/admin/targeted_messages/1').reply(HTTP_STATUS_OK, {
          redirect_to: '/admin/targeted_messages/1/edit',
        });

        await setupFormWithData();
        await submitForm();

        expect(visitUrl).toHaveBeenCalledWith('/admin/targeted_messages/1/edit');
      });

      it('displays inline errors on validation failure', async () => {
        const errors = { target_type: ['cannot be changed'] };
        mockAxios
          .onPatch('/admin/targeted_messages/1')
          .reply(HTTP_STATUS_UNPROCESSABLE_ENTITY, { message: errors });

        await setupFormWithData();
        await submitForm();

        expect(findGlFormFields().props('serverValidations')).toEqual({
          targetType: 'Target Type cannot be changed',
        });
      });
    });

    describe('error handling', () => {
      beforeEach(() => {
        createComponent({
          initialTargetType: 'banner_page_level',
        });
      });
      it('clears previous errors on new submission', async () => {
        const errors = { target_type: ["can't be blank"] };
        mockAxios
          .onPost('/admin/targeted_messages')
          .replyOnce(HTTP_STATUS_UNPROCESSABLE_ENTITY, { message: errors });

        await setupFormWithData();
        await submitForm();

        expect(findGlFormFields().props('serverValidations')).toEqual({
          targetType: "Target Type can't be blank",
        });

        mockAxios.onPost('/admin/targeted_messages').replyOnce(HTTP_STATUS_OK);
        await submitForm();

        expect(findGlFormFields().props('serverValidations')).toEqual({});
      });
    });
  });
});
