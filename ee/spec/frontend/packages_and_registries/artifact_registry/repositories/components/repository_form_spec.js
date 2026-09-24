import { GlFormRadio, GlIcon } from '@gitlab/ui';
import waitForPromises from 'helpers/wait_for_promises';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import ErrorsAlert from '~/vue_shared/components/errors_alert.vue';
import FormatLogo from 'ee/packages_and_registries/artifact_registry/repositories/components/format_logo.vue';
import RemoteSourceSection from 'ee/packages_and_registries/artifact_registry/repositories/components/remote_source_section.vue';
import RepositoryForm from 'ee/packages_and_registries/artifact_registry/repositories/components/repository_form.vue';
import { createRouter } from 'ee/packages_and_registries/artifact_registry/router';
import { BASE_PATH } from '../../mock_data';

describe('ArtifactRegistryRepositoryForm', () => {
  let wrapper;

  const NEW_REPOSITORY = {
    format: 'DOCKER',
    name: '',
    description: '',
    visibility: 'PRIVATE',
  };

  const EXISTING_REPOSITORY = {
    format: 'MAVEN',
    name: 'my-repository',
    description: 'A hosted Maven repository',
    visibility: 'PRIVATE',
  };

  const REMOTE_REPOSITORY = { ...EXISTING_REPOSITORY, kind: 'REMOTE' };

  const findErrorsAlert = () => wrapper.findComponent(ErrorsAlert);
  const findNameInput = () => wrapper.findByTestId('repository-name');
  const findDescription = () => wrapper.findByTestId('repository-description');
  const findFormatListbox = () => wrapper.findComponentByTestId('repository-format');
  const findVisibilityRadios = () => wrapper.findAllComponents(GlFormRadio);
  const findVisibilityIcon = () => findVisibilityRadios().at(0).findComponent(GlIcon);
  const findFormatToggleLogo = () => wrapper.findComponentByTestId('repository-format-toggle-logo');
  const findSourceSection = () => wrapper.findComponent(RemoteSourceSection);
  const findSubmitButton = () => wrapper.findComponentByTestId('submit-repository');
  const findCancelButton = () => wrapper.findComponentByTestId('cancel-repository');
  const findFormatOptions = () =>
    findFormatListbox()
      .props('items')
      .map(({ value, text }) => [value, text]);

  const createComponent = ({ props = {} } = {}) => {
    wrapper = mountExtended(RepositoryForm, {
      router: createRouter(BASE_PATH),
      propsData: {
        repository: NEW_REPOSITORY,
        submitText: 'Create repository',
        ...props,
      },
      attachTo: document.body,
    });
  };

  const updateForm = async ({ name, description } = {}) => {
    await findNameInput().setValue(name);
    await findDescription().setValue(description);
    await waitForPromises();
  };

  const submitForm = async () => {
    await wrapper.find('form').trigger('submit');
    await waitForPromises();
  };

  const lastSubmitPayload = () => wrapper.emitted('submit')?.at(-1)[0];

  describe('whichever action wraps it', () => {
    beforeEach(() => {
      createComponent();
    });

    it('labels the submit button with the verb the wrapper supplies', () => {
      expect(findSubmitButton().text()).toBe('Create repository');
    });

    it('cancels back to the repositories list', () => {
      expect(findCancelButton().props('to')).toEqual({ name: 'repositories_list' });
    });

    // Where cancel goes depends on where the flow started, which only the page hosting
    // the form knows, so the list is a default rather than the one answer.
    it('cancels to the route the wrapper supplies instead', () => {
      const cancelRoute = { name: 'repository_detail', params: { id: 'payment-core' } };

      createComponent({ props: { cancelRoute } });

      expect(findCancelButton().props('to')).toEqual(cancelRoute);
    });

    // Private is the only visibility the beta supports, so the control is off unless a
    // wrapper asks for it.
    it('offers no visibility control', () => {
      expect(findVisibilityRadios()).toHaveLength(0);
    });

    it('renders no errors until the wrapper hands it some', () => {
      expect(findErrorsAlert().props('errors')).toEqual([]);
    });
  });

  describe('when the wrapper asks for the visibility control', () => {
    beforeEach(() => {
      createComponent({ props: { showVisibility: true } });
    });

    it('offers private as the only visibility', () => {
      expect(findVisibilityRadios()).toHaveLength(1);
      expect(findVisibilityRadios().at(0).props('value')).toBe('PRIVATE');
      expect(findVisibilityRadios().at(0).text()).toContain('Private');
    });

    it('gives the visibility its icon and the consequence of choosing it', () => {
      expect(findVisibilityIcon().props('name')).toBe('lock');
      expect(findVisibilityRadios().at(0).text()).toContain(
        'Access is limited to members with explicit permissions only.',
      );
    });

    it('sends the visibility it collected', async () => {
      await updateForm({ name: 'my-repository', description: 'A hosted repository' });
      await submitForm();

      expect(lastSubmitPayload()).toMatchObject({ visibility: 'PRIVATE' });
    });
  });

  describe('while the wrapper is submitting', () => {
    beforeEach(() => {
      createComponent({ props: { submitting: true } });
    });

    it('shows the submit button as loading and blocks the cancel', () => {
      expect(findSubmitButton().props('loading')).toBe(true);
      expect(findCancelButton().props('disabled')).toBe(true);
    });
  });

  describe('when the wrapper hands it errors', () => {
    beforeEach(() => {
      createComponent({ props: { errorMessages: ['Name has already been taken.'] } });
    });

    it('renders them above the fields', () => {
      expect(findErrorsAlert().props('errors')).toEqual(['Name has already been taken.']);
    });

    it('asks the wrapper to clear them when the alert is dismissed', () => {
      findErrorsAlert().vm.$emit('dismiss');

      expect(wrapper.emitted('dismiss-errors')).toHaveLength(1);
    });
  });

  describe('format field', () => {
    beforeEach(() => {
      createComponent();
    });

    it('offers the MVP formats', () => {
      expect(findFormatOptions()).toEqual([
        ['DOCKER', 'Docker'],
        ['MAVEN', 'Maven'],
        ['NPM', 'npm'],
        ['OCI', 'OCI'],
      ]);
    });

    it('opens on the format the wrapper seeded it with', () => {
      expect(findFormatListbox().props('selected')).toBe('DOCKER');
      expect(findFormatListbox().props('toggleText')).toBe('Docker');
    });

    it('says the format is fixed once the repository exists', () => {
      expect(wrapper.text()).toContain(
        'The format cannot be changed after the repository is created.',
      );
    });

    it('keeps the logo of the chosen format on the closed toggle', async () => {
      expect(findFormatToggleLogo().props('format')).toBe('DOCKER');

      findFormatListbox().vm.$emit('select', 'MAVEN');
      await waitForPromises();

      expect(findFormatToggleLogo().props('format')).toBe('MAVEN');
    });

    it.each(['DOCKER', 'MAVEN', 'NPM', 'OCI'])('pairs %s with its own logo', (format) => {
      const option = wrapper.findByTestId(`listbox-item-${format}`);

      expect(option.findComponent(FormatLogo).props('format')).toBe(format);
    });

    it('submits the chosen format', async () => {
      findFormatListbox().vm.$emit('select', 'NPM');
      await updateForm({ name: 'my-repository' });
      await submitForm();

      expect(lastSubmitPayload()).toMatchObject({ format: 'NPM' });
    });
  });

  describe('name field', () => {
    beforeEach(() => {
      createComponent();
    });

    it('shows an example name and the rules it has to satisfy', () => {
      expect(findNameInput().attributes('placeholder')).toBe('my-hosted-repository');
      expect(wrapper.text()).toContain(
        'Lowercase letters, numbers, hyphens (-), and underscores (_) only. The repository name cannot be changed after creation.',
      );
    });

    it.each([
      ['HOSTED', 'my-hosted-repository'],
      ['REMOTE', 'my-remote-repository'],
    ])('names the %s kind in the example name', (kind, placeholder) => {
      createComponent({ props: { kind } });

      expect(findNameInput().attributes('placeholder')).toBe(placeholder);
    });

    it('requires a name', async () => {
      await updateForm({ name: '' });
      await submitForm();

      expect(wrapper.text()).toContain('Repository name is required.');
      expect(wrapper.emitted('submit')).toBeUndefined();
    });

    it.each(['-', '?', 'UPPERCASE', 'trailing-', '.leading', 'has space', 'sla/sh'])(
      'rejects %p before it reaches the wrapper',
      async (name) => {
        await updateForm({ name });
        await submitForm();

        expect(wrapper.text()).toContain(
          'Name must use lowercase letters, digits, periods, underscores, and hyphens, and start and end with a letter or digit.',
        );
        expect(wrapper.emitted('submit')).toBeUndefined();
      },
    );

    it.each(['a', 'my-repo', 'my.repo_1', '0abc'])('accepts %p', async (name) => {
      await updateForm({ name });
      await submitForm();

      expect(lastSubmitPayload()).toMatchObject({ name });
    });

    it('rejects a name longer than 255 characters', async () => {
      await updateForm({ name: 'a'.repeat(256) });
      await submitForm();

      expect(wrapper.text()).toContain('Name cannot be longer than 255 characters.');
      expect(wrapper.emitted('submit')).toBeUndefined();
    });
  });

  describe('description field', () => {
    beforeEach(() => {
      createComponent();
    });

    it('counts down the remaining description characters', async () => {
      expect(wrapper.text()).toContain('1024 characters remaining.');

      await updateForm({ description: 'a'.repeat(24) });

      expect(wrapper.text()).toContain('1000 characters remaining.');

      await updateForm({ description: 'a'.repeat(1025) });

      expect(wrapper.text()).toContain('1 character over limit.');
    });

    it('rejects a description longer than 1024 characters', async () => {
      await updateForm({ name: 'my-repository', description: 'a'.repeat(1025) });
      await submitForm();

      expect(wrapper.text()).toContain('Description cannot be longer than 1024 characters.');
      expect(wrapper.emitted('submit')).toBeUndefined();
    });
  });

  describe('when the name is read-only and the format is hidden', () => {
    beforeEach(() => {
      createComponent({
        props: {
          repository: EXISTING_REPOSITORY,
          submitText: 'Save changes',
          nameReadonly: true,
          showFormat: false,
        },
      });
    });

    it('does not offer the format at all, because it cannot be changed', () => {
      expect(findFormatListbox().exists()).toBe(false);
    });

    // Read-only rather than disabled, so the field a viewer cannot change is still one
    // they can reach with the keyboard and hear read out.
    it('shows the name without offering to change it', () => {
      expect(findNameInput().element.value).toBe('my-repository');
      expect(findNameInput().element.readOnly).toBe(true);
      expect(findNameInput().element.disabled).toBe(false);
    });

    it('prefills the description it was given', () => {
      expect(findDescription().element.value).toBe('A hosted Maven repository');
    });

    it('submits without the format, and without validating the untouched name', async () => {
      await submitForm();

      expect(lastSubmitPayload()).toEqual({
        name: 'my-repository',
        description: 'A hosted Maven repository',
      });
    });
  });

  describe('when the repository has no description', () => {
    beforeEach(() => {
      createComponent({
        props: {
          repository: { ...EXISTING_REPOSITORY, description: null },
          nameReadonly: true,
          showFormat: false,
        },
      });
    });

    it('renders an empty field rather than the string "null"', () => {
      expect(findDescription().element.value).toBe('');
    });
  });

  describe('the remote source section', () => {
    it('renders it for a remote repository, seeded from what the read resolved', () => {
      const settings = { url: 'https://repo.example.com/maven2' };

      createComponent({ props: { repository: { ...REMOTE_REPOSITORY, settings } } });

      expect(findSourceSection().props()).toEqual({
        format: 'MAVEN',
        // The repository-scoped probe is addressed by name, and the stored name is the one
        // that names a repository Artifact Registry has.
        name: 'my-repository',
        settings,
        createMode: false,
      });
    });

    it('seeds it empty when the read resolved no settings', () => {
      createComponent({ props: { repository: REMOTE_REPOSITORY } });

      expect(findSourceSection().props('settings')).toEqual({});
    });

    it('renders it after the common fields and before the actions', () => {
      createComponent({ props: { repository: REMOTE_REPOSITORY } });

      const order = wrapper
        .findAll('[data-testid]')
        .wrappers.map((element) => element.attributes('data-testid'))
        .filter((testId) =>
          ['repository-name', 'remote-source-section', 'submit-repository'].includes(testId),
        );

      expect(order).toEqual(['repository-name', 'remote-source-section', 'submit-repository']);
    });

    it('renders none for a hosted repository', () => {
      createComponent({ props: { repository: { ...EXISTING_REPOSITORY, kind: 'HOSTED' } } });

      expect(findSourceSection().exists()).toBe(false);
    });

    it('renders it in create mode on a create form for a remote kind', () => {
      createComponent({ props: { repository: NEW_REPOSITORY, kind: 'REMOTE', createMode: true } });

      expect(findSourceSection().props('createMode')).toBe(true);
    });

    it('follows the format control in create mode', async () => {
      createComponent({ props: { repository: NEW_REPOSITORY, kind: 'REMOTE', createMode: true } });

      findFormatListbox().vm.$emit('select', 'NPM');
      await waitForPromises();

      expect(findSourceSection().props('format')).toBe('NPM');
    });
  });

  describe('the fields Artifact Registry requires', () => {
    const findNameTextbox = () => wrapper.findByRole('textbox', { name: 'Repository name' });
    const findFormatCombobox = () => findFormatListbox().find('[role="combobox"]');

    it('announces the name and the format as required on a create', () => {
      createComponent();

      expect(findNameTextbox().attributes('aria-required')).toBe('true');
      expect(findFormatCombobox().attributes('aria-required')).toBe('true');
    });

    it('announces nothing required on an edit, whose name and format are immutable', () => {
      createComponent({
        props: { repository: EXISTING_REPOSITORY, nameReadonly: true, showFormat: false },
      });

      expect(findNameTextbox().attributes('aria-required')).toBeUndefined();
      expect(findFormatListbox().exists()).toBe(false);
    });
  });

  describe('every submit attempt', () => {
    it('asks the wrapper to drop its errors, and submits, when the form is valid', async () => {
      createComponent();
      await updateForm({ name: 'my-repository', description: '' });
      await submitForm();

      expect(wrapper.emitted('dismiss-errors')).toHaveLength(1);
      expect(wrapper.emitted('submit')).toHaveLength(1);
    });

    it('asks the wrapper to drop its errors even when the section rejects the attempt', async () => {
      createComponent({ props: { repository: REMOTE_REPOSITORY, nameReadonly: true } });
      await submitForm();

      expect(wrapper.emitted('dismiss-errors')).toHaveLength(1);
      expect(wrapper.emitted('submit')).toBeUndefined();
    });
  });
});
