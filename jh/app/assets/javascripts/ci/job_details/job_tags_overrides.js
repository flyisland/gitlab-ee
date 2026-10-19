import JobSidebar from '~/ci/job_details/components/sidebar/sidebar.vue';
import JobTagsEditor from './components/job_tags_editor.vue';

const { JobSidebarDetailsContainer } = JobSidebar.components;

JobSidebar.components.JobSidebarDetailsContainer = {
  name: 'JobSidebarDetailsWithTagsEditor',
  render(createElement) {
    return createElement('div', [
      createElement(JobSidebarDetailsContainer),
      createElement(JobTagsEditor),
    ]);
  },
};
