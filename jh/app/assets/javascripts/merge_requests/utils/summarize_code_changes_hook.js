import { removeParams, updateHistory } from '~/lib/utils/url_utility';

export default function jhSummarizeHook(component) {
  const params = new URLSearchParams(window.location.search);
  if (params.get('summarize_code_changes') === '1' && !component.disabled) {
    component.onClick();
    const url = removeParams(['summarize_code_changes'], window.location.href);
    updateHistory({ title: document.title, url, replace: true });
  }
}
