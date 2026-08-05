<script>
import { GlLink, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import { artifactRegistryOrganizationIndexPath } from 'ee/lib/utils/path_helpers/organizations';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import HelpPageLink from '~/vue_shared/components/help_page_link/help_page_link.vue';
import CeOrganizationShowApp from '~/organizations/show/components/app.vue';

export default {
  name: 'OrganizationShowAppEE',
  components: { CeOrganizationShowApp, GlLink, GlSprintf, HelpPageLink },
  mixins: [glFeatureFlagsMixin()],
  props: {
    organization: {
      type: Object,
      required: true,
    },
    canReadArtifactRegistry: {
      type: Boolean,
      required: true,
    },
    canAdminOrganization: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    showArtifactRegistry() {
      return this.canReadArtifactRegistry && this.glFeatures.artifactRegistryUi;
    },
    artifactRegistryEmptyStateDescription() {
      if (this.canAdminOrganization) {
        return s__(
          "Organization|%{organizationName} is your organization's home. Manage Artifact Registry and settings from the sidebar. %{linkStart}Learn more%{linkEnd}.",
        );
      }

      return s__(
        "Organization|%{organizationName} is your organization's home. Manage Artifact Registry from the sidebar. %{linkStart}Learn more%{linkEnd}.",
      );
    },
  },
  methods: {
    artifactRegistryOrganizationIndexPath,
  },
};
</script>

<template>
  <ce-organization-show-app
    :organization="organization"
    :can-admin-organization="canAdminOrganization"
  >
    <template v-if="showArtifactRegistry" #description>
      <gl-sprintf :message="artifactRegistryEmptyStateDescription">
        <template #organizationName>{{ organization.name }}</template>
        <template #link="{ content }">
          <help-page-link href="/user/organization/_index.md">{{ content }}</help-page-link>
        </template>
      </gl-sprintf>
    </template>
    <template v-if="showArtifactRegistry" #actions>
      <gl-link :href="artifactRegistryOrganizationIndexPath(organization.path)">{{
        s__('Organization|Go to Artifact Registry')
      }}</gl-link>
    </template>
  </ce-organization-show-app>
</template>
