import Vue, { watch } from 'vue';
import { groupBy } from 'lodash-es';
import { n__ } from '~/locale';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { pinia } from '~/pinia/instance';
import { EXPANDED_LINES, MOUNTED } from '~/rapid_diffs/adapter_events';
import { useCodeQuality } from '~/rapid_diffs/stores/code_quality';
import { SEVERITIES } from '~/ci/reports/codequality_report/constants';
import InlineFindingsGutterIconDropdown from 'ee/diffs/components/inline_findings_gutter_icon_dropdown.vue';

const SVG_NS = 'http://www.w3.org/2000/svg';
const CLICK_ACTION = 'showCodeQualityFindings';
const normalize = (severity) => (SEVERITIES[severity] ? severity : 'unknown');

const TOGGLE_ICON_SIZE = 14;
const TOGGLE_ICON_CLASS = 'inline-findings-severity-icon';

function buildSeverityIcon(severity) {
  const { name, class: colorClass } = SEVERITIES[normalize(severity)];
  const svg = document.createElementNS(SVG_NS, 'svg');
  svg.setAttribute('class', `gl-icon s${TOGGLE_ICON_SIZE} ${TOGGLE_ICON_CLASS} ${colorClass}`);
  const use = document.createElementNS(SVG_NS, 'use');
  use.setAttribute('href', `${window.gon?.sprite_icons || ''}#${name}`);
  svg.appendChild(use);
  return svg;
}

function buildTrigger(findings) {
  const button = document.createElement('button');
  button.type = 'button';
  button.className = 'rd-codequality-toggle';
  button.dataset.click = CLICK_ACTION;
  button.setAttribute(
    'aria-label',
    n__(
      'InlineFindings|1 Code Quality finding detected',
      'InlineFindings|%d Code Quality findings detected',
      findings.length,
    ),
  );
  button.appendChild(buildSeverityIcon(findings[0].severity));
  return button;
}

/* eslint-disable no-param-reassign */
function decorateSlot(slot, findings) {
  if (slot.dataset.codequalityHasFindings) return;
  slot.dataset.codequalityHasFindings = 'true';
  slot.appendChild(buildTrigger(findings));
}

function mountFindings(slot, filePath, lineFindings) {
  const codeQuality = lineFindings.map((finding) => convertObjectPropsToCamelCase(finding));
  const placeholder = document.createElement('div');
  slot.replaceChildren(placeholder);
  const instance = new Vue({
    el: placeholder,
    pinia,
    name: 'CodeQualityGutterRoot',
    render: (h) =>
      h(InlineFindingsGutterIconDropdown, {
        class: 'rd-codequality-toggle',
        props: { filePath, codeQuality, startOpened: true, compact: true },
      }),
  });
  slot.destroyFindings = () => instance.$destroy();
}
/* eslint-enable no-param-reassign */

function decorateCodeQuality(diffElement, findings) {
  if (!findings) return;

  // eslint-disable-next-line no-param-reassign
  diffElement.dataset.codequalityHasFindings = 'true';

  const lineMap = groupBy(findings, 'line');
  diffElement
    .querySelectorAll('[data-line-codequality]:not([data-codequality-has-findings])')
    .forEach((slot) => {
      const lineFindings = lineMap[slot.dataset.lineCodequality];
      if (lineFindings) decorateSlot(slot, lineFindings);
    });
}

export const lineCodeQualityAdapter = {
  [MOUNTED](addCleanup) {
    const { diffElement } = this;
    const { newPath } = this.data;
    if (!newPath) return;

    const store = useCodeQuality(pinia);
    const stopWatch = watch(
      () => store.findingsForFile(newPath),
      (findings) => decorateCodeQuality(diffElement, findings),
      { immediate: true },
    );
    addCleanup(() => {
      stopWatch();
      diffElement
        .querySelectorAll('[data-line-codequality]')
        .forEach((slot) => slot.destroyFindings?.());
    });
  },
  [EXPANDED_LINES]() {
    const { newPath } = this.data;
    if (!newPath) return;
    const store = useCodeQuality(pinia);
    decorateCodeQuality(this.diffElement, store.findingsForFile(newPath));
  },
  clicks: {
    [CLICK_ACTION](event, button) {
      const { newPath } = this.data;
      const findings = useCodeQuality(pinia).findingsForFile(newPath);
      if (!findings) return;
      const slot = button.closest('[data-line-codequality]');
      if (!slot) return;
      const lineFindings = groupBy(findings, 'line')[slot.dataset.lineCodequality];
      if (lineFindings) mountFindings(slot, newPath, lineFindings);
    },
  },
};
