import { useMockMutationObserver } from 'helpers/mock_dom_observer';
import { initProjectTerms } from 'jh/init_project_terms';

describe('initProjectTerms', () => {
  const { trigger: triggerMutate } = useMockMutationObserver();

  const createNewProjectForm = ({ submitTestId = 'import-project-by-url-button' } = {}) => `
    <form action="/projects" method="post">
      <input name="project[name]" />
      <input name="project[path]" />
      <input id="project_visibility_level_0" type="radio" name="project[visibility_level]" value="0" checked />
      <input id="project_visibility_level_20" type="radio" name="project[visibility_level]" value="20" />
      <button type="submit" data-testid="${submitTestId}">Create project</button>
    </form>
  `;

  const findTerms = () => document.querySelector('[data-testid="new-project-terms"]');
  const findJihuTermsCheckbox = () => document.querySelector('#project_agree_jihu_terms');
  const findIntellectualPropertyCheckbox = () =>
    document.querySelector('#project_agree_intellectual_property');
  const findSubmitButton = () => document.querySelector('[type="submit"]');
  const setPublicVisibility = () => {
    const privateInput = document.querySelector('#project_visibility_level_0');
    const publicInput = document.querySelector('#project_visibility_level_20');

    privateInput.checked = false;
    publicInput.checked = true;
    publicInput.dispatchEvent(new Event('change', { bubbles: true }));
  };
  const setPrivateVisibility = () => {
    const privateInput = document.querySelector('#project_visibility_level_0');
    const publicInput = document.querySelector('#project_visibility_level_20');

    publicInput.checked = false;
    privateInput.checked = true;
    privateInput.dispatchEvent(new Event('change', { bubbles: true }));
  };

  beforeEach(() => {
    window.gon = {
      dot_com: true,
    };
  });

  afterEach(() => {
    document.body.innerHTML = '';
    jest.resetModules();
  });

  it('inserts project terms and toggles checkbox validation with visibility changes', () => {
    document.body.innerHTML = createNewProjectForm();

    initProjectTerms();

    expect(findTerms().hidden).toBe(true);
    expect(findJihuTermsCheckbox().required).toBe(false);
    expect(findIntellectualPropertyCheckbox().required).toBe(false);

    setPublicVisibility();

    expect(findTerms().hidden).toBe(false);
    expect(findTerms().nextElementSibling).toBe(findSubmitButton());
    expect(findJihuTermsCheckbox().required).toBe(true);
    expect(findIntellectualPropertyCheckbox().required).toBe(true);
    expect(findTerms().querySelector('a').getAttribute('href')).toBe(
      'https://about.gitlab.cn/terms/',
    );

    findJihuTermsCheckbox().checked = true;
    findIntellectualPropertyCheckbox().checked = true;

    setPrivateVisibility();

    expect(findTerms().hidden).toBe(true);
    expect(findJihuTermsCheckbox().required).toBe(false);
    expect(findIntellectualPropertyCheckbox().required).toBe(false);
    expect(findJihuTermsCheckbox().checked).toBe(false);
    expect(findIntellectualPropertyCheckbox().checked).toBe(false);
  });

  it('inserts project terms for forms that appear after initialization', () => {
    initProjectTerms();

    document.body.innerHTML = createNewProjectForm({ submitTestId: 'project-create-button' });
    document.querySelector('#project_visibility_level_0').checked = false;
    document.querySelector('#project_visibility_level_20').checked = true;

    triggerMutate(document.body, { options: { childList: true, subtree: true } });

    expect(findTerms().hidden).toBe(false);
    expect(findJihuTermsCheckbox().required).toBe(true);
    expect(findIntellectualPropertyCheckbox().required).toBe(true);
  });
});
