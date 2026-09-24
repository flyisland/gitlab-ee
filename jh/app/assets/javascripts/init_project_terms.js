import { sprintf } from '~/locale';
import { PROMO_URL } from 'jh/lib/utils/url_utility';
import {
  I18N_NEW_PROJECT_TERMS_DECLARATION,
  I18N_NEW_PROJECT_TERMS_ONE,
  I18N_NEW_PROJECT_TERMS_TWO,
  PUBLIC_VISIBILITY_LEVEL,
} from 'jh/projects/new/constants';

const PROJECT_VISIBILITY_INPUT_SELECTOR = '[name="project[visibility_level]"]';
const PROJECT_NAME_INPUT_SELECTOR = '[name="project[name]"]';
const PROJECT_PATH_INPUT_SELECTOR = '[name="project[path]"]';
const PROJECT_TERMS_SELECTOR = '.js-jh-new-project-terms';
const LINK_START_TOKEN = '__JH_TERMS_LINK_START__';
const LINK_END_TOKEN = '__JH_TERMS_LINK_END__';

function isNewProjectForm(form) {
  return Boolean(
    form?.querySelector(PROJECT_NAME_INPUT_SELECTOR) &&
    form.querySelector(PROJECT_PATH_INPUT_SELECTOR) &&
    form.querySelector(PROJECT_VISIBILITY_INPUT_SELECTOR),
  );
}

function isPublicProject(form) {
  return (
    Number(form.querySelector(`${PROJECT_VISIBILITY_INPUT_SELECTOR}:checked`)?.value) ===
    PUBLIC_VISIBILITY_LEVEL
  );
}

function buildLinkedLabelText(label) {
  const message = sprintf(I18N_NEW_PROJECT_TERMS_ONE, {
    linkStart: LINK_START_TOKEN,
    linkEnd: LINK_END_TOKEN,
  });
  const [beforeLink, afterStartToken = ''] = message.split(LINK_START_TOKEN);
  const [linkText, afterLink = ''] = afterStartToken.split(LINK_END_TOKEN);

  label.append(document.createTextNode(beforeLink));

  if (linkText) {
    const link = document.createElement('a');
    link.href = `${PROMO_URL}/terms/`;
    link.target = '_blank';
    // eslint-disable-next-line @gitlab/require-i18n-strings
    link.rel = 'noopener noreferrer';
    link.textContent = linkText;
    label.append(link);
  }

  label.append(document.createTextNode(afterLink));
}

function buildTermsCheckbox({ id, name, testid, trackProperty, labelText, withLink = false }) {
  const formGroup = document.createElement('div');
  formGroup.className = 'form-group';

  const formCheck = document.createElement('div');
  formCheck.className = 'form-check gl-mb-3';

  const input = document.createElement('input');
  input.id = id;
  input.type = 'checkbox';
  input.name = name;
  input.value = '1';
  input.className = 'form-check-input';
  input.dataset.testid = testid;
  input.dataset.trackLabel = 'blank_project';
  input.dataset.trackAction = 'activate_form_input';
  input.dataset.trackProperty = trackProperty;

  const label = document.createElement('label');
  label.className = 'form-check-label';
  label.htmlFor = id;

  if (withLink) {
    buildLinkedLabelText(label);
  } else {
    label.textContent = labelText;
  }

  formCheck.append(input, label);
  formGroup.append(formCheck);

  return formGroup;
}

function buildTermsElement() {
  const container = document.createElement('div');
  container.className = 'js-jh-new-project-terms';
  container.dataset.testid = 'new-project-terms';
  container.hidden = true;

  const declaration = document.createElement('label');
  declaration.className = 'label-bold';
  declaration.htmlFor = 'project_project_configuration';
  declaration.textContent = I18N_NEW_PROJECT_TERMS_DECLARATION;

  container.append(
    declaration,
    buildTermsCheckbox({
      id: 'project_agree_jihu_terms',
      name: 'project[agree_jihu_terms]',
      testid: 'agree-jihu-terms-checkbox',
      trackProperty: 'agree_jihu_terms',
      withLink: true,
    }),
    buildTermsCheckbox({
      id: 'project_agree_intellectual_property',
      name: 'project[agree_intellectual_property]',
      testid: 'agree-intellectual-property-checkbox',
      trackProperty: 'agree_intellectual_property',
      labelText: I18N_NEW_PROJECT_TERMS_TWO,
    }),
  );

  return container;
}

function findTermsInsertionTarget(form) {
  const submitButton = form.querySelector(
    '[data-testid="project-create-button"], [data-testid="import-project-by-url-button"], .js-create-project-button, button[type="submit"]',
  );

  return (
    submitButton?.closest('.gl-flex.gl-gap-3, .gl-flex.gl-justify-between, footer') || submitButton
  );
}

function syncTermsElement(form) {
  if (!isNewProjectForm(form)) {
    return;
  }

  let termsElement = form.querySelector(PROJECT_TERMS_SELECTOR);

  if (!termsElement) {
    const insertionTarget = findTermsInsertionTarget(form);
    if (!insertionTarget?.parentNode) {
      return;
    }

    termsElement = buildTermsElement();
    insertionTarget.parentNode.insertBefore(termsElement, insertionTarget);
  }

  const checkboxes = termsElement.querySelectorAll('input[type="checkbox"]');
  const shouldShow = isPublicProject(form);

  termsElement.hidden = !shouldShow;

  checkboxes.forEach((checkbox) => {
    const termsCheckbox = checkbox;
    termsCheckbox.required = shouldShow;

    if (!shouldShow) {
      termsCheckbox.checked = false;
    }
  });
}

function syncAllTermsElements() {
  document.querySelectorAll('form').forEach((form) => syncTermsElement(form));
}

export function initProjectTerms() {
  if (!window.gon?.dot_com || !document.body) {
    return;
  }

  syncAllTermsElements();

  document.body.addEventListener('change', (event) => {
    if (event.target.matches(PROJECT_VISIBILITY_INPUT_SELECTOR)) {
      syncTermsElement(event.target.form);
    }
  });

  const observer = new MutationObserver(() => {
    syncAllTermsElements();
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true,
  });
}
