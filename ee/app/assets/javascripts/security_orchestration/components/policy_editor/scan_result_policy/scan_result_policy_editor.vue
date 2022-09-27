<script>
import { GlEmptyState, GlButton } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import { joinPaths, visitUrl, setUrlFragment } from '~/lib/utils/url_utility';
import { __, s__ } from '~/locale';
import { NAMESPACE_TYPES } from 'ee/security_orchestration/constants';
import {
  EDITOR_MODE_YAML,
  EDITOR_MODE_RULE,
  SECURITY_POLICY_ACTIONS,
  GRAPHQL_ERROR_MESSAGE,
  PARSING_ERROR_MESSAGE,
  ACTIONS_LABEL,
  ADD_RULE_LABEL,
  RULES_LABEL,
} from '../constants';
import PolicyEditorLayout from '../policy_editor_layout.vue';
import { assignSecurityPolicyProject, modifyPolicy } from '../utils';
import DimDisableContainer from '../dim_disable_container.vue';
import PolicyActionBuilder from './policy_action_builder.vue';
import PolicyRuleBuilder from './policy_rule_builder.vue';

// import {
//   DEFAULT_SCAN_RESULT_POLICY,
//   fromYaml,
//   toYaml,
//   buildRule,
//   approversOutOfSync,
//   invalidScanners,
//   humanizeInvalidBranchesError,
// } from './lib';

/* 
 * Imports common between all scan result types
 * TODO: Remove unused scan result policy type specific code
 */
import {
  fromYaml,
  SCAN_POLICY_TYPES,
} from './lib';

import * as SECURITY_SCANNING_MODULE from './lib/security_scanning/export';
import * as LICENSE_SCANNING_MODULE from './lib/license_scanning/export';

export default {
  ADD_RULE_LABEL,
  RULES_LABEL,
  SECURITY_POLICY_ACTIONS,
  EDITOR_MODE_YAML,
  EDITOR_MODE_RULE,
  i18n: {
    PARSING_ERROR_MESSAGE,
    createMergeRequest: __('Configure with a merge request'),
    notOwnerButtonText: __('Learn more'),
    notOwnerDescription: s__(
      'SecurityOrchestration|Scan result policies can only be created by project owners.',
    ),
    yamlPreview: s__('SecurityOrchestration|.yaml preview'),
    ACTIONS_LABEL,
  },
  components: {
    GlEmptyState,
    GlButton,
    PolicyActionBuilder,
    PolicyRuleBuilder,
    PolicyEditorLayout,
    DimDisableContainer,
  },
  inject: [
    'disableScanPolicyUpdate',
    'policyEditorEmptyStateSvgPath',
    'namespaceId',
    'namespacePath',
    'scanPolicyDocumentationPath',
    'scanResultPolicyApprovers',
    'namespaceType',
  ],
  props: {
    assignedPolicyProject: {
      type: Object,
      required: true,
    },
    existingPolicy: {
      type: Object,
      required: false,
      default: null,
    },
    scanResultPolicyType: {
      type: String,
      required: false,
      default: SCAN_POLICY_TYPES.SECURITY_SCANNING,
    },
    isEditing: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    /*
     *  toYaml is the same between both scan result policies, no need to distingish.
     *  When createding a new scan policy the prop is set from the parent component, dependent
     *  on which Card was selected from the intial menu screen
     */
    const yamlEditorValue = this.existingPolicy
      ? this.toYaml(this.existingPolicy)
      : this.scanPolicy(this.scanResultPolicyType).DEFAULT_SCAN_RESULT_POLICY;

    /*
     * For parssing purposes, we need to distinguish the scan result type.
     * fromYaml in this instance is the COMMON fromYaml function
     */ 
    const scanPolicyType = fromYaml(yamlEditorValue).type;

    return {
      error: '',
      isCreatingMR: false,
      isRemovingPolicy: false,
      newlyCreatedPolicyProject: null,
      // Allows us to call this.scanPolicy() without having to specify the type every time 
      // when invoked outside the data() function. 
      scanPolicyType,
      // Call the scan result type specific fromYaml function
      policy: this.scanPolicy(scanPolicyType).fromYaml(yamlEditorValue),
      yamlEditorValue,
      documentationPath: setUrlFragment(
        this.scanPolicyDocumentationPath,
        'scan-result-policy-editor',
      ),
      yamlEditorError: null,
      mode: EDITOR_MODE_RULE,
      existingApprovers: this.scanResultPolicyApprovers,
    };
  },
  computed: {
    ...mapState('scanResultPolicies', ['invalidBranches']),
    originalName() {
      return this.existingPolicy?.name;
    },
    policyActionName() {
      return this.isEditing
        ? this.$options.SECURITY_POLICY_ACTIONS.REPLACE
        : this.$options.SECURITY_POLICY_ACTIONS.APPEND;
    },
    policyYaml() {
      return this.hasParsingError ? '' : this.scanPolicy().toYaml(this.policy);
    },
    hasParsingError() {
      return Boolean(this.yamlEditorError);
    },
    isWithinLimit() {
      return this.policy.rules.length < 5;
    },
  },
  watch: {
    invalidBranches(branches) {
      if (branches.length > 0) {
        this.handleError(new Error(this.scanPolicy().humanizeInvalidBranchesError([...branches])));
      } else {
        this.$emit('error', '');
      }
    },
  },
  methods: {
    ...mapActions('scanResultPolicies', ['fetchBranches']),
    scanPolicy(type='') {
      /* 
       * We need to explicitly define the type when invoked from data() because
       * the data isn't set yet, otherwise determine the value from data.scanPolicyType
       */
      switch (type || this.scanPolicyType) {
        case SCAN_POLICY_TYPES.SECURITY_SCANNING:
          return SECURITY_SCANNING_MODULE;      
        case SCAN_POLICY_TYPES.LICENSE_SCANNING:
          return LICENSE_SCANNING_MODULE;
        default:
          return SECURITY_SCANNING_MODULE;
      }
    },
    updateAction(actionIndex, values) {
      this.policy.actions.splice(actionIndex, 1, values);
    },
    addRule() {
      this.policy.rules.push(this.scanPolicy().buildRule());
    },
    removeRule(ruleIndex) {
      this.policy.rules.splice(ruleIndex, 1);
    },
    updateRule(ruleIndex, values) {
      this.policy.rules.splice(ruleIndex, 1, values);
    },
    handleError(error) {
      if (error.message.toLowerCase().includes('graphql')) {
        this.$emit('error', GRAPHQL_ERROR_MESSAGE);
      } else {
        this.$emit('error', error.message);
      }
    },
    async getSecurityPolicyProject() {
      if (!this.newlyCreatedPolicyProject && !this.assignedPolicyProject.fullPath) {
        this.newlyCreatedPolicyProject = await assignSecurityPolicyProject(this.namespacePath);
      }

      return this.newlyCreatedPolicyProject || this.assignedPolicyProject;
    },
    async handleModifyPolicy(act) {
      const action = act || this.policyActionName;

      this.$emit('error', '');
      this.setLoadingFlag(action, true);

      try {
        const assignedPolicyProject = await this.getSecurityPolicyProject();
        const yamlValue =
          this.mode === EDITOR_MODE_YAML ? this.yamlEditorValue : this.scanPolicy().toYaml(this.policy);
        const mergeRequest = await modifyPolicy({
          action,
          assignedPolicyProject,
          name: this.originalName || this.scanPolicy().fromYaml(yamlValue)?.name,
          namespacePath: this.namespacePath,
          yamlEditorValue: yamlValue,
        });

        this.redirectToMergeRequest({ mergeRequest, assignedPolicyProject });
      } catch (e) {
        this.handleError(e);
        this.setLoadingFlag(action, false);
      }
    },
    setLoadingFlag(action, val) {
      if (action === SECURITY_POLICY_ACTIONS.REMOVE) {
        this.isRemovingPolicy = val;
      } else {
        this.isCreatingMR = val;
      }
    },
    handleSetPolicyProperty(property, value) {
      this.policy[property] = value;
    },
    redirectToMergeRequest({ mergeRequest, assignedPolicyProject }) {
      visitUrl(
        joinPaths(
          gon.relative_url_root || '/',
          assignedPolicyProject.fullPath,
          '/-/merge_requests',
          mergeRequest.id,
        ),
      );
    },
    updateYaml(manifest) {
      this.yamlEditorValue = manifest;
      this.yamlEditorError = null;

      try {
        const newPolicy = this.scanPolicy().fromYaml(manifest);
        if (newPolicy.error) {
          throw new Error(newPolicy.error);
        }
        this.policy = { ...this.policy, ...newPolicy };
      } catch (error) {
        this.yamlEditorError = error;
      }
    },
    changeEditorMode(mode) {
      this.mode = mode;
      if (mode === EDITOR_MODE_YAML && !this.hasParsingError) {
        this.yamlEditorValue = this.scanPolicy().toYaml(this.policy);
      } else if (mode === EDITOR_MODE_RULE && !this.hasParsingError) {
        if (this.invalidForRuleMode()) {
          this.yamlEditorError = new Error();
        } else if (this.namespaceType === NAMESPACE_TYPES.PROJECT) {
          this.fetchBranches({ branches: this.allBranches(), projectId: this.namespaceId });
        }
      }
    },
    updatePolicyApprovers(values) {
      this.existingApprovers = values;
    },
    invalidForRuleMode() {
      return (
        this.scanPolicy().approversOutOfSync(this.policy.actions[0], this.existingApprovers) ||
        this.scanPolicy().invalidScanners(this.policy.rules)
      );
    },
    allBranches() {
      return this.policy.rules.flatMap((rule) => rule.branches);
    },
  },
};
</script>

<template>
  <policy-editor-layout
    v-if="!disableScanPolicyUpdate"
    :custom-save-button-text="$options.i18n.createMergeRequest"
    :has-parsing-error="hasParsingError"
    :is-editing="isEditing"
    :is-removing-policy="isRemovingPolicy"
    :is-updating-policy="isCreatingMR"
    :parsing-error="$options.i18n.PARSING_ERROR_MESSAGE"
    :policy="policy"
    :policy-yaml="policyYaml"
    :yaml-editor-value="yamlEditorValue"
    @remove-policy="handleModifyPolicy($options.SECURITY_POLICY_ACTIONS.REMOVE)"
    @save-policy="handleModifyPolicy()"
    @set-policy-property="handleSetPolicyProperty"
    @update-yaml="updateYaml"
    @update-editor-mode="changeEditorMode"
  >
    <template #rules>
      <dim-disable-container data-testid="rule-builder-container" :disabled="hasParsingError">
        <template #title>
          <h4>{{ $options.RULES_LABEL }}</h4>
        </template>

        <template #disabled>
          <div class="gl-bg-gray-10 gl-rounded-base gl-p-6"></div>
        </template>

        <policy-rule-builder
          v-for="(rule, index) in policy.rules"
          :key="index"
          class="gl-mb-4"
          :init-rule="rule"
          @changed="updateRule(index, $event)"
          @remove="removeRule(index)"
        />

        <div v-if="isWithinLimit" class="gl-bg-gray-10 gl-rounded-base gl-p-5 gl-mb-5">
          <gl-button variant="link" data-testid="add-rule" icon="plus" @click="addRule">
            {{ $options.ADD_RULE_LABEL }}
          </gl-button>
        </div>
      </dim-disable-container>
    </template>
    <template #actions>
      <dim-disable-container data-testid="action-container" :disabled="hasParsingError">
        <template #title>
          <h4>{{ $options.i18n.ACTIONS_LABEL }}</h4>
        </template>

        <template #disabled>
          <div class="gl-bg-gray-10 gl-rounded-base gl-p-6"></div>
        </template>

        <policy-action-builder
          v-for="(action, index) in policy.actions"
          :key="index"
          class="gl-mb-4"
          :init-action="action"
          :existing-approvers="existingApprovers"
          @changed="updateAction(index, $event)"
          @approversUpdated="updatePolicyApprovers"
        />
      </dim-disable-container>
    </template>
  </policy-editor-layout>
  <gl-empty-state
    v-else
    :description="$options.i18n.notOwnerDescription"
    :primary-button-link="documentationPath"
    :primary-button-text="$options.i18n.notOwnerButtonText"
    :svg-path="policyEditorEmptyStateSvgPath"
    title=""
  />
</template>
