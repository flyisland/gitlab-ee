import { REPOSITORY_FORMAT_MAVEN, REPOSITORY_FORMAT_NPM } from '../../../constants';
import { mockArtifacts, versionLadderFor } from '../../../graphql/mock_artifacts';
import FilesTable from './files_table.vue';

const REPOSITORY_NAMES = {
  [REPOSITORY_FORMAT_MAVEN]: 'maven-releases',
  [REPOSITORY_FORMAT_NPM]: 'npm-internal',
};

const filesFor = (format) => {
  const [artifact] = mockArtifacts(REPOSITORY_NAMES[format], format);

  return versionLadderFor(artifact.id, format)[0].storedFiles;
};

export default {
  component: FilesTable,
  title: 'ee/artifact_registry/repositories/versions/detail/files_table',
};

const Template =
  ({ format, expanded = false, isLoading = false }) =>
  () => ({
    components: { FilesTable },
    data() {
      return {
        format,
        isLoading,
        files: filesFor(format),
      };
    },
    async mounted() {
      if (!expanded) return;

      await this.$nextTick();

      this.$el
        .querySelectorAll('[data-testid="toggle-checksums"]')
        .forEach((toggle) => toggle.click());
    },
    template: '<files-table :files="files" :format="format" :is-loading="isLoading" />',
  });

// Works around bootstrap-vue putting `aria-owns` on an open row, which breaks
// `aria-required-children`. Only the disclosed stories, so the rest still check the rule.
const disclosedA11y = {
  a11y: { config: { rules: [{ id: 'aria-required-children', enabled: false }] } },
};

export const Maven = Template({ format: REPOSITORY_FORMAT_MAVEN });

export const MavenChecksumsDisclosed = Template({
  format: REPOSITORY_FORMAT_MAVEN,
  expanded: true,
});
MavenChecksumsDisclosed.parameters = disclosedA11y;

export const Npm = Template({ format: REPOSITORY_FORMAT_NPM });

export const NpmChecksumsDisclosed = Template({ format: REPOSITORY_FORMAT_NPM, expanded: true });
NpmChecksumsDisclosed.parameters = disclosedA11y;

export const Loading = Template({ format: REPOSITORY_FORMAT_MAVEN, isLoading: true });
