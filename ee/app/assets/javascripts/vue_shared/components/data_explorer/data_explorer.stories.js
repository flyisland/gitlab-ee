import DataExplorer from './data_explorer.vue';

export default {
  component: DataExplorer,
  title: 'ee/vue_shared/components/data_explorer',
};

const Template = () => ({
  components: { DataExplorer },
  data() {
    return { query: '' };
  },
  template: `<data-explorer v-model="query" />`,
});

export const Default = Template.bind({});
