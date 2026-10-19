<script>
/* eslint-disable @gitlab/no-runtime-template-compiler */
import EEPasswordRequirementList from 'ee/password/components/password_requirement_list.vue';

import { COMMON } from 'ee/password/constants';

export default {
  ...EEPasswordRequirementList,
  computed: {
    ...EEPasswordRequirementList.computed,
    // The following is used by upstream component, we are simply overriding it
    /* eslint-disable vue/no-unused-properties */
    // differ from the ee version, we do not verify the validity of the user info for now.
    firstName() {
      return null;
    },
    lastName() {
      return null;
    },
    username() {
      return null;
    },
    email() {
      return null;
    },
    displayPasswordRequirements() {
      return this.ruleTypes.includes(COMMON);
    },
  },
  methods: {
    ...EEPasswordRequirementList.methods,
    checkValidity(rule) {
      if ([COMMON].includes(rule.type)) {
        this.checkComplexity(rule);
      } else {
        this.setRuleValidity(rule.type, rule.reg.test(this.password));
      }
    },
    /* eslint-enable vue/no-unused-properties */
  },
};
</script>
