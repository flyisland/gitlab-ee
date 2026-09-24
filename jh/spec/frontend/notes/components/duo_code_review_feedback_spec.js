import { GlButton } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import DuoCodeReviewFeedback from 'jh/notes/components/duo_code_review_feedback.vue';

describe('DuoCodeReviewFeedback', () => {
  let wrapper;

  const createWrapper = () => {
    wrapper = mount(DuoCodeReviewFeedback, {
      stubs: {
        UserFeedback: true,
      },
    });
  };

  beforeEach(() => {
    createWrapper();
  });

  it('renders rating and feedback link for users', () => {
    const userFeedback = wrapper.findComponent({ name: 'UserFeedback' });
    expect(userFeedback.exists()).toBe(true);
    expect(userFeedback.props('feedbackLinkText')).toBe('Rate the review');
    expect(userFeedback.props('eventName')).toBe('duo_code_review');

    const feedbackLink = wrapper.findComponent(GlButton);
    expect(feedbackLink.text()).toBe('Leave feedback');
    expect(feedbackLink.attributes('href')).toBe(
      'https://jihulab.com/gitlab-cn/gitlab/-/issues/4987',
    );
    expect(feedbackLink.props('disabled')).toBe(false);
  });
});
