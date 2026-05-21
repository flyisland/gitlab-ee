<script>
import PoliciesList from './list/policies_list.vue';
import CreatePolicyWizard from './create/create_policy_wizard.vue';

export default {
  name: 'SecurityPoliciesApp',
  components: {
    PoliciesList,
    CreatePolicyWizard,
  },
  data() {
    return {
      currentView: 'list',
    };
  },
  methods: {
    handleSubmit() {
      this.currentView = 'list';
    },
  },
};
</script>

<template>
  <div>
    <policies-list v-if="currentView === 'list'" @create="currentView = 'create'" />
    <create-policy-wizard
      v-else-if="currentView === 'create'"
      @cancel="currentView = 'list'"
      @submit="handleSubmit"
    />
  </div>
</template>
