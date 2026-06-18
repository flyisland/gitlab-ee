/**
 * Toggle the AI panel maximized state in the DOM
 * @param {boolean} isMaximized - Whether the panel is maximized
 */
export const toggleAiPanelMaximizedClass = (isMaximized) => {
  document
    .querySelector('.js-page-layout')
    ?.classList.toggle('ai-panel-maximized', isMaximized ?? false);
};
