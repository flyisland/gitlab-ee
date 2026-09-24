<script>
import { getTreeContentBlockedState } from 'jh/rest_api';
import TreeContent from '~/repository/components/tree_content.vue';
import ContentBlocked from 'jh/vue_shared/components/content_blocked.vue';
import FileTable from '~/repository/components/table/index.vue';
import { normalizeRender } from '~/lib/utils/vue3compat/normalize_render';

const { render, mounted, data, methods, ...otherOptions } = TreeContent;
export default normalizeRender({
  ...otherOptions,
  data() {
    return {
      ...data.call(this),
      contentBlockedState: '',
      isContentValidationLoading: false,
    };
  },
  async mounted() {
    mounted.call(this);
    await Promise.resolve();
    if (gon.content_validation_enabled) {
      this.getTreeContentBlockedState();
    }
  },
  methods: {
    ...methods,
    getTreeContentBlockedState() {
      this.isContentValidationLoading = true;
      const originalPath = this.path || '/';
      getTreeContentBlockedState(this.projectPath, { ref: this.ref, path: originalPath })
        .then((response) => {
          this.isContentValidationLoading = false;
          this.contentBlockedState = response.data;
        })
        .catch(() => {});
    },
  },
  render(createElement) {
    if (this.contentBlockedState) {
      return createElement(ContentBlocked, {
        props: {
          id: this.contentBlockedState.id,
          projectFullPath: this.contentBlockedState.project_full_path,
          path: this.contentBlockedState.path,
        },
      });
    }
    if (this.isContentValidationLoading) {
      return createElement(FileTable, {
        props: {
          isLoading: true,
          path: this.path,
          hasMore: this.hasShowMore,
        },
      });
    }
    const cache = {};
    return render.call(this, this, cache);
  },
});
</script>
