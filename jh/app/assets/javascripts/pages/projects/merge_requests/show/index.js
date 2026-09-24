import 'ee/pages/projects/merge_requests/show';
import createDefaultClient from '~/lib/graphql';
import toast from '~/vue_shared/plugins/global_toast';
import { __ } from '~/locale';
import setReviewersMutation from '~/merge_requests/components/reviewers/queries/set_reviewers.mutation.graphql';
import { parseBoolean } from '~/lib/utils/common_utils';
import getMergeRequestReviewersQuery from '~/sidebar/queries/get_merge_request_reviewers.query.graphql';
import reviewerRereviewMutation from '~/sidebar/queries/reviewer_rereview.mutation.graphql';
import { scrollTo } from '~/lib/utils/scroll_utils';
import { getScrollingElement } from '~/lib/utils/panels';

async function initJhMrAssignDuo() {
  const header = document.querySelector('.js-jh-only-data');
  if (!header) return;

  const { canSummarizeChanges, duoFeaturesEnabled, iid, projectPath } = header.dataset;
  const canSummarize = parseBoolean(canSummarizeChanges);
  const duoEnabled = parseBoolean(duoFeaturesEnabled);
  if (!duoEnabled && !canSummarize) return;

  const awardsContainer = document.querySelector('.js-noteable-awards');
  if (!awardsContainer) return;

  const appendAiIconAndText = (el, text) => {
    const svgNs = 'http://www.w3.org/2000/svg';
    const xlinkNs = 'http://www.w3.org/1999/xlink';
    const iconEl = document.createElementNS(svgNs, 'svg');
    iconEl.setAttribute('class', 'gl-icon s16 gl-button-icon');
    const useEl = document.createElementNS(svgNs, 'use');
    useEl.setAttributeNS(xlinkNs, 'xlink:href', `${gon.sprite_icons}#tanuki-ai`);
    iconEl.appendChild(useEl);
    el.appendChild(iconEl);
    const textEl = document.createElement('span');
    textEl.className = 'gl-button-text';
    textEl.textContent = text;
    el.appendChild(textEl);
  };

  let assignDuoButton = awardsContainer.querySelector('.js-assign-to-gitlabduo');
  if (!assignDuoButton) {
    const wrapper = document.createElement('span');
    wrapper.className = 'gl-ml-auto gl-flex gl-items-center gl-gap-2 gl-my-2';

    if (duoEnabled) {
      assignDuoButton = document.createElement('button');
      assignDuoButton.className = 'js-assign-to-gitlabduo btn btn-default gl-button';
      appendAiIconAndText(assignDuoButton, __('Code review'));
      assignDuoButton.dataset.iid = iid;
      assignDuoButton.dataset.projectPath = projectPath;
      wrapper.appendChild(assignDuoButton);
    }

    if (canSummarize) {
      const summarizeLink = document.createElement('a');
      summarizeLink.className = 'js-summarize-code-changes btn btn-default gl-button';
      appendAiIconAndText(summarizeLink, __('Summarize code changes'));
      summarizeLink.href = `/${projectPath}/-/merge_requests/${iid}/edit?summarize_code_changes=1`;
      wrapper.appendChild(summarizeLink);
    }

    const awards = awardsContainer.querySelector('.awards');
    if (awards && awards.parentNode) {
      awards.parentNode.insertBefore(wrapper, awards.nextSibling);
    } else {
      awardsContainer.appendChild(wrapper);
    }
  }

  if (assignDuoButton) {
    const apolloClient = createDefaultClient();
    assignDuoButton.addEventListener('click', async () => {
      scrollTo({ top: getScrollingElement().scrollHeight, behavior: 'smooth' });

      try {
        const { data } = await apolloClient.query({
          query: getMergeRequestReviewersQuery,
          variables: { fullPath: projectPath, iid },
          fetchPolicy: 'network-only',
        });
        const nodes = data?.workspace?.issuable?.reviewers?.nodes || [];
        const duo = nodes.find((u) => u?.username === 'GitLabDuo');

        if (duo?.id) {
          await apolloClient.mutate({
            mutation: reviewerRereviewMutation,
            variables: { projectPath, iid, userId: duo.id },
          });
        } else {
          await apolloClient.mutate({
            mutation: setReviewersMutation,
            variables: { iid, projectPath, reviewerUsernames: ['GitLabDuo'] },
          });
        }
        toast(__('Requested review'));
      } catch (error) {
        toast(`${'Failed to assign reviewer @GitLabDuo'}: ${error?.message || ''}`);
      }
    });
  }
}

initJhMrAssignDuo();
