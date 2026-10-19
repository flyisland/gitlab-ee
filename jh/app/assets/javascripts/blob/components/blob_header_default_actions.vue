<script>
import DefaultActions from '~/blob/components/blob_header_default_actions.vue';

export default gon.disable_download_button
  ? {
      render() {
        return null;
      },
    }
  : DefaultActions;
</script>
