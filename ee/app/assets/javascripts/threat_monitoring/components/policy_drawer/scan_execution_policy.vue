<script>
import { GlLink } from '@gitlab/ui';
import { fromYaml } from '../policy_editor/scan_execution_policy/lib';
import BasePolicy from './base_policy.vue';
import PolicyInfoRow from './policy_info_row.vue';

export default {
  components: {
    GlLink,
    BasePolicy,
    PolicyInfoRow,
  },
  props: {
    value: {
      type: String,
      required: true,
    },
  },
  computed: {
    policy() {
      return fromYaml(this.value);
    },
  },
};
</script>

<template>
  <base-policy :policy="policy">
    <template #type>{{ s__('SecurityPolicies|Scan execution') }}</template>

    <template #default="{ enforcementStatusLabel }">
      <div v-if="policy">
        <policy-info-row
          v-if="policy.description"
          data-testid="description"
          :label="s__('SecurityPolicies|Description')"
          >{{ policy.description }}</policy-info-row
        >

        <!-- TODO: humanize policy rules -->
        <!-- <policy-info-row
          v-if="policy.rules"
          data-testid="rules"
          :label="s__('SecurityPolicies|Rule')"
          >{{ policy.rules }}</policy-info-row
        > -->

        <!-- TODO: humanize policy actions -->
        <!-- <policy-info-row
          v-if="policy.actions"
          data-testid="actions"
          :label="s__('SecurityPolicies|Action')"
          >{{ policy.actions }}</policy-info-row
        > -->

        <policy-info-row :label="s__('SecurityPolicies|Enforcement status')">{{
          enforcementStatusLabel
        }}</policy-info-row>

        <policy-info-row
          v-if="policy.latestScan"
          data-testid="latest-scan"
          :label="s__('SecurityPolicies|Latest scan')"
          >{{ policy.latestScan.date }}
          <gl-link :href="policy.latestScan.pipelineUrl">{{
            s__('SecurityPolicies|view results')
          }}</gl-link></policy-info-row
        >
      </div>
    </template>
  </base-policy>
</template>
