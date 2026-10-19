<script>
import DiffContent from '~/diffs/components/diff_content.vue';
import ContentBlocked from 'jh/vue_shared/components/content_blocked.vue';
import { normalizeRender } from '~/lib/utils/vue3compat/normalize_render';

const { render, ...otherOptions } = DiffContent;
export default normalizeRender({
  ...otherOptions,
  render(createElement) {
    if (this.diffFile.content_blocked_state) {
      return createElement(ContentBlocked, {
        props: {
          id: this.diffFile.content_blocked_state.id,
          projectFullPath: this.diffFile.content_blocked_state.project_full_path,
          path: this.diffFile.content_blocked_state.path,
        },
      });
    }
    const cache = {};
    return render.call(this, this, cache);
  },
});
</script>
