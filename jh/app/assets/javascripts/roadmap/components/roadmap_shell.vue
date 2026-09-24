<script>
import RoadmapShell from 'ee/roadmap/components/roadmap_shell.vue';
import { normalizeRender } from '~/lib/utils/vue3compat/normalize_render';

const { render, ...options } = RoadmapShell;
const GLOBAL_FOOTER_HEIGHT = 47;
export default normalizeRender({
  ...options,
  methods: {
    ...options.methods,
    // The following is used by upstream component, we are simply overriding it
    getContainerStyles() {
      const { top } = this.$el.getBoundingClientRect();
      return {
        height: this.isScopedRoadmap ? '100%' : `calc(100vh - ${top + GLOBAL_FOOTER_HEIGHT}px)`,
      };
    },
  },
  render() {
    const cache = {};
    return render.call(this, this, cache);
  },
});
</script>
