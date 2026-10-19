<script>
/* eslint-disable @gitlab/no-runtime-template-compiler */
import GitlabVersionCheckBadge from '~/gitlab_version_check/components/gitlab_version_check_badge.vue';

const { computed, ...otherOptions } = GitlabVersionCheckBadge;
export default {
  ...otherOptions,
  computed: {
    ...computed,
  },
};
</script>
