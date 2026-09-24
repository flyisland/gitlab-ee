export default {
  computed: {
    canDownload() {
      return !window.gon.disable_download_button;
    },
  },
};
