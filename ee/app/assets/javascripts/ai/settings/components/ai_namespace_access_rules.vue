<script>
import { GlTable, GlButton, GlFormCheckbox, GlFormGroup, GlLink, GlSprintf } from '@gitlab/ui';
import { partition } from 'lodash-es';
import { s__ } from '~/locale';
import { helpPagePath } from '~/helpers/help_page_helper';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import GroupSelector from './group_selector.vue';

const AVAILABLE_FEATURES = [
  {
    key: 'duo_classic',
    label: s__('AiPowered|GitLab Duo'),
  },
  {
    key: 'duo_agent_platform',
    label: s__('AiPowered|GitLab Duo Agent Platform'),
  },
];

const ensureNamespaceAccessRulesHasDefaultRow = (namespaceAccessRules) => {
  if (namespaceAccessRules.length === 0) return [];

  const [globalRules, namespaceRules] = partition(
    namespaceAccessRules,
    (rule) => !rule.throughNamespace,
  );

  return [
    ...namespaceRules,
    globalRules.pop() || {
      throughNamespace: null,
      features: [],
    },
  ];
};

export default {
  name: 'AiNamespaceAccessRules',
  components: {
    GlTable,
    GlButton,
    GlFormGroup,
    GlFormCheckbox,
    GlLink,
    GlSprintf,
    GroupSelector,
  },
  AVAILABLE_FEATURES,
  accessControlHelpPath: helpPagePath('administration/gitlab_duo/configure/access_control'),
  fields: [
    {
      key: 'namespaceName',
      label: s__('AiPowered|Members of group'),
      thStyle: { width: '40%' },
      tdClass: 'gl-max-w-0',
    },
    {
      key: 'features',
      label: s__('AiPowered|Have access to'),
      thStyle: { width: '40%' },
      tdClass: 'gl-max-w-0',
    },
    {
      key: 'actions',
      label: null,
      thStyle: { width: '20%' },
      tdClass: 'gl-max-w-0',
    },
  ],
  props: {
    initialNamespaceAccessRules: {
      type: Array,
      required: false,
      default: null,
    },
    disabledCheckbox: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['change'],
  data() {
    return {
      namespaceRulesWithDefault: ensureNamespaceAccessRulesHasDefaultRow(
        this.initialNamespaceAccessRules,
      ),
    };
  },
  computed: {
    namespaceRulesWithoutDefault() {
      return this.namespaceRulesWithDefault.filter(
        (rule) => !(rule.throughNamespace === null && rule.features.length === 0),
      );
    },
  },
  methods: {
    isFeatureEnabled(namespaceAccessRule, feature) {
      return namespaceAccessRule.features.includes(feature) || false;
    },
    onGroupSelected(group) {
      const id = getIdFromGraphQLId(group.id);
      const exists = this.namespaceRulesWithDefault.some(
        (rule) => rule.throughNamespace?.id === id,
      );

      if (exists) {
        return;
      }

      this.namespaceRulesWithDefault = ensureNamespaceAccessRulesHasDefaultRow([
        ...this.namespaceRulesWithDefault,
        {
          throughNamespace: {
            id,
            name: group.name,
            fullPath: group.fullPath,
          },
          features: AVAILABLE_FEATURES.map((rule) => rule.key),
        },
      ]);

      this.$emit('change', this.namespaceRulesWithoutDefault);
    },
    removeNamespaceAccessRule(namespaceId) {
      const newRules = this.namespaceRulesWithDefault.filter(
        (rule) => rule.throughNamespace?.id !== namespaceId,
      );

      // When only the default rule is present, remove it.
      if (newRules.length === 1 && newRules[0].features.length === 0) {
        this.namespaceRulesWithDefault = [];
      } else {
        this.namespaceRulesWithDefault = newRules;
      }

      this.$emit('change', this.namespaceRulesWithoutDefault);
    },
    toggleFeature(namespaceId, feature, isEnabled) {
      this.namespaceRulesWithDefault = this.namespaceRulesWithDefault.map((rule) => {
        if (rule.throughNamespace?.id !== namespaceId) return rule;

        const features = new Set(rule.features);

        if (isEnabled) {
          features.add(feature);
        } else {
          features.delete(feature);
        }

        return {
          ...rule,
          features: [...features],
        };
      });

      this.$emit('change', this.namespaceRulesWithoutDefault);
    },
  },
};
</script>

<template>
  <div class="gl-mb-4 gl-max-w-3xl">
    <gl-form-group :label="s__('AiPowered|Limit access based on group membership')">
      <p class="gl-mb-5 gl-text-subtle">
        <gl-sprintf
          :message="
            s__(
              'AiPowered|When configured, access to GitLab Duo or GitLab Duo Agent Platform can be restricted to selected groups. By default all eligible members can access all configured AI features. %{linkStart}How can I control access?%{linkEnd}',
            )
          "
        >
          <template #link="{ content }">
            <gl-link
              :href="$options.accessControlHelpPath"
              target="_blank"
              rel="noopener noreferrer"
              >{{ content }}</gl-link
            >
          </template>
        </gl-sprintf>
      </p>

      <template v-if="namespaceRulesWithDefault.length > 0">
        <gl-table
          :items="namespaceRulesWithDefault"
          :fields="$options.fields"
          show-empty
          bordered
          fixed
          thead-class="gl-bg-subtle"
        >
          <template #cell(namespaceName)="{ item }">
            <template v-if="item.throughNamespace">
              <gl-link
                :href="`/${item.throughNamespace.fullPath}`"
                target="_blank"
                rel="noopener noreferrer"
              >
                {{ item.throughNamespace.name }}
              </gl-link>
            </template>
            <template v-else>
              <div>
                <span class="gl-font-bold">{{ s__('AiPowered|All eligible users') }}</span>
                <p class="gl-mb-0 gl-mt-2 gl-text-sm gl-text-subtle">
                  {{
                    s__(
                      'AiPowered|Default access for users who can access AI features regardless of group membership.',
                    )
                  }}
                </p>
              </div>
            </template>
          </template>

          <template #cell(features)="{ item }">
            <div class="gl-display-flex gl-flex-direction-column gl-gap-3">
              <gl-form-checkbox
                v-for="feature in $options.AVAILABLE_FEATURES"
                :key="feature.key"
                :checked="isFeatureEnabled(item, feature.key)"
                :disabled="disabledCheckbox"
                @change="toggleFeature(item.throughNamespace?.id, feature.key, $event)"
              >
                {{ feature.label }}
              </gl-form-checkbox>
            </div>
          </template>

          <template #cell(actions)="{ item }">
            <gl-button
              v-if="item.throughNamespace"
              variant="link"
              category="secondary"
              :disabled="disabledCheckbox"
              @click="removeNamespaceAccessRule(item.throughNamespace.id)"
            >
              {{ s__('AiPowered|Remove') }}
            </gl-button>
          </template>
        </gl-table>
      </template>
      <template v-else>
        <p class="gl-text-subtle">
          {{
            s__('AiPowered|No limits applied. All eligible users have access to all AI features.')
          }}
        </p>
      </template>

      <group-selector :disabled="disabledCheckbox" @group-selected="onGroupSelected" />
    </gl-form-group>
  </div>
</template>
