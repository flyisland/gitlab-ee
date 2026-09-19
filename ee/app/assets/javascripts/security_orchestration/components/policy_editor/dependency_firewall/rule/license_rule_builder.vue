<script>
import { GlFormGroup } from '@gitlab/ui';
import { s__ } from '~/locale';
import {
  getRuleListKey,
  getRuleList,
  toggleRuleListKey,
  namesToItems,
  itemsToNames,
  exceptionsToLines,
  ruleWithUpdatedExceptions,
} from '../utils';
import RuleMultiSelect from '../../rule_multi_select.vue';
import AllowDenyToggle from './allow_deny_toggle.vue';
import NameListTextarea from './name_list_textarea.vue';

export default {
  name: 'LicenseRuleBuilder',
  components: { GlFormGroup, AllowDenyToggle, RuleMultiSelect, NameListTextarea },
  inject: ['parsedSoftwareLicenses'],
  i18n: {
    licensesLabel: s__('SecurityOrchestration|Licenses'),
    licensesItemTypeName: s__('SecurityOrchestration|Licenses'),
    exceptionsLabel: s__('SecurityOrchestration|Exceptions'),
    exceptionsPlaceholder: s__(
      'SecurityOrchestration|Enter package URLs (PURLs) to exempt, separated by commas',
    ),
  },
  props: {
    initRule: {
      type: Object,
      required: true,
    },
  },
  emits: ['changed'],
  computed: {
    listKey() {
      return getRuleListKey(this.initRule);
    },
    names() {
      return itemsToNames(getRuleList(this.initRule));
    },
    licenseItems() {
      return Object.fromEntries(
        this.parsedSoftwareLicenses.map(({ value, text }) => [value, text]),
      );
    },
    exceptionLines() {
      return exceptionsToLines(this.initRule.exceptions || []);
    },
  },
  methods: {
    handleToggleChange(newKey) {
      this.$emit('changed', toggleRuleListKey(this.initRule, newKey));
    },
    handleNamesChange(names) {
      this.$emit('changed', { ...this.initRule, [this.listKey]: namesToItems(names) });
    },
    handleExceptionsChange(lines) {
      this.$emit('changed', ruleWithUpdatedExceptions(this.initRule, lines));
    },
  },
};
</script>

<template>
  <div class="gl-w-full">
    <gl-form-group :label="$options.i18n.licensesLabel" class="gl-w-full">
      <allow-deny-toggle :list-key="listKey" class="gl-mb-3" @change="handleToggleChange" />
      <rule-multi-select
        :item-type-name="$options.i18n.licensesItemTypeName"
        :items="licenseItems"
        :value="names"
        searchable
        @input="handleNamesChange"
      />
    </gl-form-group>

    <gl-form-group :label="$options.i18n.exceptionsLabel" class="gl-w-full">
      <name-list-textarea
        :items="exceptionLines"
        :placeholder="$options.i18n.exceptionsPlaceholder"
        @input="handleExceptionsChange"
      />
    </gl-form-group>
  </div>
</template>
