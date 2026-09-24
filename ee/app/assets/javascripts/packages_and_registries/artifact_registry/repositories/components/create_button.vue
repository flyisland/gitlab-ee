<script>
import { GlDisclosureDropdown } from '@gitlab/ui';
import { s__ } from '~/locale';
import {
  REPOSITORY_NEW_HOSTED_ROUTE_NAME,
  REPOSITORY_NEW_REMOTE_ROUTE_NAME,
} from '../../constants';

export default {
  name: 'ArtifactRegistryCreateButton',
  i18n: {
    // The toggle text is the toggle's accessible name, so it names the object it
    // creates rather than the verb alone: "Create" on its own is not understandable
    // out of context. Mirrors the "New file / project / issue" pattern.
    toggle: s__('ArtifactRegistry|New repository'),
  },
  components: {
    GlDisclosureDropdown,
  },
  props: {
    placement: {
      type: String,
      required: false,
      default: 'bottom-start',
    },
  },
  items: [
    {
      text: s__('ArtifactRegistry|Hosted repository'),
      to: { name: REPOSITORY_NEW_HOSTED_ROUTE_NAME },
    },
    {
      text: s__('ArtifactRegistry|Remote repository'),
      to: { name: REPOSITORY_NEW_REMOTE_ROUTE_NAME },
    },
  ],
};
</script>

<template>
  <gl-disclosure-dropdown
    variant="confirm"
    :placement="placement"
    :toggle-text="$options.i18n.toggle"
    :items="$options.items"
  />
</template>
