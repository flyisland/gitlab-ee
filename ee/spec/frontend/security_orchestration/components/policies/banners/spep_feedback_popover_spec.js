import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import SpepFeedbackPopover from 'ee/security_orchestration/components/policies/banners/spep_feedback_popover.vue';

describe('SpepFeedbackPopover', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMountExtended(SpepFeedbackPopover);
  };

  const findPopover = () => wrapper.findByTestId('spep-feedback-popover');
  const findSurveyLink = () => wrapper.findByTestId('feedback-survey-link');
  const findExperimentBadge = () => wrapper.findByTestId('spep-experiment-badge');
  const findFeedbackButton = () => wrapper.findByTestId('spep-feedback-button');

  beforeEach(() => {
    createComponent();
  });

  it('renders experiment badge inside a button', () => {
    expect(findFeedbackButton().exists()).toBe(true);
    expect(findExperimentBadge().exists()).toBe(true);
    expect(findExperimentBadge().text()).toBe('Experiment');
  });

  it('renders popover targeting the feedback button', () => {
    expect(findPopover().exists()).toBe(true);
    expect(findPopover().attributes('target')).toBe('spep-feedback-badge-1');
  });

  it('renders popover with top placement', () => {
    expect(findPopover().attributes('placement')).toBe('top');
  });

  it('renders popover with hover, focus, and click triggers', () => {
    expect(findPopover().attributes('triggers')).toBe('hover focus click');
  });

  it('renders feedback text', () => {
    expect(wrapper.text()).toContain(
      'Help us improve scheduled pipeline execution policies by sharing your thoughts and suggestions.',
    );
  });

  it('renders survey link with correct attributes', () => {
    expect(findSurveyLink().exists()).toBe(true);
    expect(findSurveyLink().attributes('href')).toBe(
      'https://gitlab.fra1.qualtrics.com/jfe/form/SV_0iJvyxIEQxV4trU',
    );
    expect(findSurveyLink().attributes('target')).toBe('_blank');
    expect(findSurveyLink().attributes('rel')).toBe('noopener noreferrer');
    expect(findSurveyLink().text()).toContain('Give feedback');
  });
});
