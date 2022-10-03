<script>
import { GlLink, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { IssuableStatus } from '~/issues/constants';
import {
  dateInWords,
  getTimeRemainingInWords,
  isInFuture,
  isInPast,
  isToday,
  newDateAsLocaleTime,
} from '~/lib/utils/datetime_utility';
import { __ } from '~/locale';

export default {
  components: {
    GlLink,
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    projectId: {
      type: String,
      required: true,
    },
    project: {
      type: Object,
      required: false,
    },
  },
  computed: {},
  methods: {},
};
</script>

<template>
  <div class="nav-sidebar-inner-scroll" style="">
    <ul class="sidebar-top-level-items" data-qa-selector="project_sidebar">
      <!-- BEGIN app/views/shared/nav/_scope_menu.html.haml -->
      <li
        data-track-label="scope_menu"
        data-container="body"
        data-placement="right"
        class="context-header has-tooltip"
        title="Flight"
      >
        <a
          aria-label="Flight"
          class="shortcuts-project rspec-project-link gl-link"
          data-qa-selector="sidebar_menu_link"
          data-qa-menu-item="Project scope"
          href="/flightjs/Flight"
        >
          <span class="avatar-container rect-avatar s32 project_avatar">
            <span class="avatar avatar-tile s32 identicon bg7">F</span>
          </span>
          <span class="sidebar-context-title"> Flight </span>
        </a>
      </li>
      <!-- END app/views/shared/nav/_scope_menu.html.haml -->

      <!-- BEGIN app/views/shared/nav/_sidebar_menu.html.haml -->
      <li data-track-label="project_information_menu" class="home">
        <a
          aria-label="Project information"
          class="shortcuts-project-information has-sub-items gl-link"
          data-qa-selector="sidebar_menu_link"
          data-qa-menu-item="Project information"
          href="/flightjs/Flight/activity"
        >
          <span class="nav-icon-container">
            <svg class="s16" data-testid="project-icon">
              <use
                href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#project"
              ></use>
            </svg>
          </span>
          <span class="nav-item-name"> Project information </span>
        </a>
        <!-- BEGIN app/views/shared/nav/_sidebar_submenu.html.haml -->
        <ul class="sidebar-sub-level-items">
          <li class="fly-out-top-item">
            <span class="fly-out-top-item-container">
              <strong class="fly-out-top-item-name"> Project information </strong>
            </span>
          </li>
          <li class="divider fly-out-top-item"></li>
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="activity" class="">
            <a
              aria-label="Activity"
              class="shortcuts-project-activity gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Activity"
              href="/flightjs/Flight/activity"
            >
              <span> Activity </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="labels" class="">
            <a
              aria-label="Labels"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Labels"
              href="/flightjs/Flight/-/labels"
            >
              <span> Labels </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="members" class="">
            <a
              aria-label="Members"
              id="js-onboarding-members-link"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Members"
              href="/flightjs/Flight/-/project_members"
            >
              <span> Members </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
        </ul>
        <!-- END app/views/shared/nav/_sidebar_submenu.html.haml -->
      </li>
      <!-- END app/views/shared/nav/_sidebar_menu.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_menu.html.haml -->
      <li data-track-label="repository_menu" class="">
        <a
          aria-label="Repository"
          class="shortcuts-tree has-sub-items gl-link"
          data-qa-selector="sidebar_menu_link"
          data-qa-menu-item="Repository"
          href="/flightjs/Flight/-/tree/master"
        >
          <span class="nav-icon-container">
            <svg class="s16" data-testid="doc-text-icon">
              <use
                href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#doc-text"
              ></use>
            </svg>
          </span>
          <span class="nav-item-name" id="js-onboarding-repo-link"> Repository </span>
        </a>
        <!-- BEGIN app/views/shared/nav/_sidebar_submenu.html.haml -->
        <ul class="sidebar-sub-level-items">
          <li class="fly-out-top-item">
            <span class="fly-out-top-item-container">
              <strong class="fly-out-top-item-name"> Repository </strong>
            </span>
          </li>
          <li class="divider fly-out-top-item"></li>
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="files" class="">
            <a
              aria-label="Files"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Files"
              href="/flightjs/Flight/-/tree/master"
            >
              <span> Files </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="commits" class="">
            <a
              aria-label="Commits"
              id="js-onboarding-commits-link"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Commits"
              href="/flightjs/Flight/-/commits/master"
            >
              <span> Commits </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="branches" class="">
            <a
              aria-label="Branches"
              id="js-onboarding-branches-link"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Branches"
              href="/flightjs/Flight/-/branches"
            >
              <span> Branches </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="tags" class="">
            <a
              aria-label="Tags"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Tags"
              href="/flightjs/Flight/-/tags"
            >
              <span> Tags </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="contributors" class="">
            <a
              aria-label="Contributors"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Contributors"
              href="/flightjs/Flight/-/graphs/master"
            >
              <span> Contributors </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="graphs" class="">
            <a
              aria-label="Graph"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Graph"
              href="/flightjs/Flight/-/network/master"
            >
              <span> Graph </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="compare" class="">
            <a
              aria-label="Compare"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Compare"
              href="/flightjs/Flight/-/compare?from=master&amp;to=master"
            >
              <span> Compare </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
        </ul>
        <!-- END app/views/shared/nav/_sidebar_submenu.html.haml -->
      </li>
      <!-- END app/views/shared/nav/_sidebar_menu.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_menu.html.haml -->
      <li data-track-label="issues_menu" class="active">
        <a
          aria-label="Issues"
          class="shortcuts-issues has-sub-items gl-link"
          data-qa-selector="sidebar_menu_link"
          data-qa-menu-item="Issues"
          href="/flightjs/Flight/-/issues"
        >
          <span class="nav-icon-container">
            <svg class="s16" data-testid="issues-icon">
              <use
                href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#issues"
              ></use>
            </svg>
          </span>
          <span class="nav-item-name" id="js-onboarding-issues-link"> Issues </span>
          <!-- BEGIN app/components/pajamas/badge_component.rb -->
          <span class="gl-badge badge badge-pill badge-info sm count issue_counter">4 </span>
          <!-- END app/components/pajamas/badge_component.rb -->
        </a>
        <!-- BEGIN app/views/shared/nav/_sidebar_submenu.html.haml -->
        <ul class="sidebar-sub-level-items">
          <li class="fly-out-top-item active">
            <span class="fly-out-top-item-container">
              <strong class="fly-out-top-item-name"> Issues </strong>
              <!-- BEGIN app/components/pajamas/badge_component.rb -->
              <span
                class="gl-badge badge badge-pill badge-info sm count fly-out-badge issue_counter"
                >4
              </span>
              <!-- END app/components/pajamas/badge_component.rb -->
            </span>
          </li>
          <li class="divider fly-out-top-item"></li>
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="issue_list" class="">
            <a
              aria-label="Issues"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="List"
              href="/flightjs/Flight/-/issues"
            >
              <span> List </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="boards" class="">
            <a
              aria-label="Boards"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Boards"
              href="/flightjs/Flight/-/boards"
            >
              <span> Boards </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="service_desk" class="">
            <a
              aria-label="Service Desk"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Service Desk"
              href="/flightjs/Flight/-/issues/service_desk"
            >
              <span> Service Desk </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="milestones" class="">
            <a
              aria-label="Milestones"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Milestones"
              href="/flightjs/Flight/-/milestones"
            >
              <span> Milestones </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
        </ul>
        <!-- END app/views/shared/nav/_sidebar_submenu.html.haml -->
      </li>
      <!-- END app/views/shared/nav/_sidebar_menu.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_menu.html.haml -->
      <li data-track-label="merge_requests_menu" class="">
        <a
          aria-label="Merge requests"
          class="shortcuts-merge_requests gl-link"
          data-qa-selector="sidebar_menu_link"
          data-qa-menu-item="Merge requests"
          href="/flightjs/Flight/-/merge_requests"
        >
          <span class="nav-icon-container">
            <svg class="s16" data-testid="git-merge-icon">
              <use
                href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#git-merge"
              ></use>
            </svg>
          </span>
          <span class="nav-item-name" id="js-onboarding-mr-link"> Merge requests </span>
          <!-- BEGIN app/components/pajamas/badge_component.rb -->
          <span class="gl-badge badge badge-pill badge-info sm count merge_counter js-merge-counter"
            >4
          </span>
          <!-- END app/components/pajamas/badge_component.rb -->
        </a>
        <!-- BEGIN app/views/shared/nav/_sidebar_submenu.html.haml -->
        <ul class="sidebar-sub-level-items is-fly-out-only">
          <li class="fly-out-top-item">
            <span class="fly-out-top-item-container">
              <strong class="fly-out-top-item-name"> Merge requests </strong>
              <!-- BEGIN app/components/pajamas/badge_component.rb -->
              <span
                class="gl-badge badge badge-pill badge-info sm count fly-out-badge merge_counter js-merge-counter"
                >4
              </span>
              <!-- END app/components/pajamas/badge_component.rb -->
            </span>
          </li>
        </ul>
        <!-- END app/views/shared/nav/_sidebar_submenu.html.haml -->
      </li>
      <!-- END app/views/shared/nav/_sidebar_menu.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_menu.html.haml -->
      <li data-track-label="ci_cd_menu" class="">
        <a
          aria-label="CI/CD"
          class="shortcuts-pipelines rspec-link-pipelines has-sub-items gl-link"
          data-qa-selector="sidebar_menu_link"
          data-qa-menu-item="CI/CD"
          href="/flightjs/Flight/-/pipelines"
        >
          <span class="nav-icon-container">
            <svg class="s16" data-testid="rocket-icon">
              <use
                href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#rocket"
              ></use>
            </svg>
          </span>
          <span class="nav-item-name" id="js-onboarding-pipelines-link"> CI/CD </span>
        </a>
        <!-- BEGIN app/views/shared/nav/_sidebar_submenu.html.haml -->
        <ul class="sidebar-sub-level-items" style="">
          <li class="fly-out-top-item">
            <span class="fly-out-top-item-container">
              <strong class="fly-out-top-item-name"> CI/CD </strong>
            </span>
          </li>
          <li class="divider fly-out-top-item"></li>
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="pipelines" class="">
            <a
              aria-label="Pipelines"
              class="shortcuts-pipelines gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Pipelines"
              href="/flightjs/Flight/-/pipelines"
            >
              <span> Pipelines </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="pipelines_editor" class="">
            <a
              aria-label="Editor"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Editor"
              href="/flightjs/Flight/-/ci/editor?branch_name=master"
            >
              <span> Editor </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="jobs" class="">
            <a
              aria-label="Jobs"
              class="shortcuts-builds gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Jobs"
              href="/flightjs/Flight/-/jobs"
            >
              <span> Jobs </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="pipeline_schedules" class="">
            <a
              aria-label="Schedules"
              class="shortcuts-builds gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Schedules"
              href="/flightjs/Flight/-/pipeline_schedules"
            >
              <span> Schedules </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
        </ul>
        <!-- END app/views/shared/nav/_sidebar_submenu.html.haml -->
      </li>
      <!-- END app/views/shared/nav/_sidebar_menu.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_menu.html.haml -->
      <li data-track-label="security_compliance_menu" class="">
        <a
          aria-label="Security &amp; Compliance"
          class="has-sub-items gl-link"
          data-qa-selector="sidebar_menu_link"
          data-qa-menu-item="Security &amp; Compliance"
          href="/flightjs/Flight/-/audit_events"
        >
          <span class="nav-icon-container">
            <svg class="s16" data-testid="shield-icon">
              <use
                href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#shield"
              ></use>
            </svg>
          </span>
          <span class="nav-item-name"> Security &amp; Compliance </span>
        </a>
        <!-- BEGIN app/views/shared/nav/_sidebar_submenu.html.haml -->
        <ul class="sidebar-sub-level-items" style="">
          <li class="fly-out-top-item">
            <span class="fly-out-top-item-container">
              <strong class="fly-out-top-item-name"> Security &amp; Compliance </strong>
            </span>
          </li>
          <li class="divider fly-out-top-item"></li>
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="audit_events" class="">
            <a
              aria-label="Audit events"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Audit events"
              href="/flightjs/Flight/-/audit_events"
            >
              <span> Audit events </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="configuration" class="">
            <a
              aria-label="Configuration"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Configuration"
              href="/flightjs/Flight/-/security/configuration"
            >
              <span> Configuration </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
        </ul>
        <!-- END app/views/shared/nav/_sidebar_submenu.html.haml -->
      </li>
      <!-- END app/views/shared/nav/_sidebar_menu.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_menu.html.haml -->
      <li data-track-label="deployments_menu" class="">
        <a
          aria-label="Deployments"
          class="shortcuts-deployments has-sub-items gl-link"
          data-qa-selector="sidebar_menu_link"
          data-qa-menu-item="Deployments"
          href="/flightjs/Flight/-/feature_flags"
        >
          <span class="nav-icon-container">
            <svg class="s16" data-testid="deployments-icon">
              <use
                href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#deployments"
              ></use>
            </svg>
          </span>
          <span class="nav-item-name"> Deployments </span>
        </a>
        <!-- BEGIN app/views/shared/nav/_sidebar_submenu.html.haml -->
        <ul class="sidebar-sub-level-items" style="">
          <li class="fly-out-top-item">
            <span class="fly-out-top-item-container">
              <strong class="fly-out-top-item-name"> Deployments </strong>
            </span>
          </li>
          <li class="divider fly-out-top-item"></li>
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="feature_flags" class="">
            <a
              aria-label="Feature Flags"
              class="shortcuts-feature-flags gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Feature Flags"
              href="/flightjs/Flight/-/feature_flags"
            >
              <span> Feature Flags </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="environments" class="">
            <a
              aria-label="Environments"
              class="shortcuts-environments gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Environments"
              href="/flightjs/Flight/-/environments"
            >
              <span> Environments </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="releases" class="">
            <a
              aria-label="Releases"
              class="shortcuts-deployments-releases gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Releases"
              href="/flightjs/Flight/-/releases"
            >
              <span> Releases </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
        </ul>
        <!-- END app/views/shared/nav/_sidebar_submenu.html.haml -->
      </li>
      <!-- END app/views/shared/nav/_sidebar_menu.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_menu.html.haml -->
      <li data-track-label="packages_registries_menu" class="">
        <a
          aria-label="Packages and registries"
          class="has-sub-items gl-link"
          data-qa-selector="sidebar_menu_link"
          data-qa-menu-item="Packages and registries"
          href="/flightjs/Flight/-/packages"
        >
          <span class="nav-icon-container">
            <svg class="s16" data-testid="package-icon">
              <use
                href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#package"
              ></use>
            </svg>
          </span>
          <span class="nav-item-name"> Packages and registries </span>
        </a>
        <!-- BEGIN app/views/shared/nav/_sidebar_submenu.html.haml -->
        <ul class="sidebar-sub-level-items">
          <li class="fly-out-top-item">
            <span class="fly-out-top-item-container">
              <strong class="fly-out-top-item-name"> Packages and registries </strong>
            </span>
          </li>
          <li class="divider fly-out-top-item"></li>
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="packages_registry" class="">
            <a
              aria-label="Package Registry"
              class="shortcuts-container-registry gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Package Registry"
              href="/flightjs/Flight/-/packages"
            >
              <span> Package Registry </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="infrastructure_registry" class="">
            <a
              aria-label="Infrastructure Registry"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Infrastructure Registry"
              href="/flightjs/Flight/-/infrastructure_registry"
            >
              <span> Infrastructure Registry </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
        </ul>
        <!-- END app/views/shared/nav/_sidebar_submenu.html.haml -->
      </li>
      <!-- END app/views/shared/nav/_sidebar_menu.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_menu.html.haml -->
      <li data-track-label="infrastructure_menu" class="">
        <a
          aria-label="Infrastructure"
          class="shortcuts-infrastructure has-sub-items gl-link"
          data-qa-selector="sidebar_menu_link"
          data-qa-menu-item="Infrastructure"
          href="/flightjs/Flight/-/clusters"
        >
          <span class="nav-icon-container">
            <svg class="s16" data-testid="cloud-gear-icon">
              <use
                href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#cloud-gear"
              ></use>
            </svg>
          </span>
          <span class="nav-item-name"> Infrastructure </span>
        </a>
        <!-- BEGIN app/views/shared/nav/_sidebar_submenu.html.haml -->
        <ul class="sidebar-sub-level-items" style="">
          <li class="fly-out-top-item">
            <span class="fly-out-top-item-container">
              <strong class="fly-out-top-item-name"> Infrastructure </strong>
            </span>
          </li>
          <li class="divider fly-out-top-item"></li>
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="kubernetes" class="">
            <a
              aria-label="Kubernetes clusters"
              class="shortcuts-kubernetes gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Kubernetes clusters"
              href="/flightjs/Flight/-/clusters"
            >
              <span> Kubernetes clusters </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="terraform" class="">
            <a
              aria-label="Terraform"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Terraform"
              href="/flightjs/Flight/-/terraform"
            >
              <span> Terraform </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
        </ul>
        <!-- END app/views/shared/nav/_sidebar_submenu.html.haml -->
      </li>
      <!-- END app/views/shared/nav/_sidebar_menu.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_menu.html.haml -->
      <li data-track-label="monitor_menu" class="">
        <a
          aria-label="Monitor"
          class="shortcuts-monitor has-sub-items gl-link"
          data-qa-selector="sidebar_menu_link"
          data-qa-menu-item="Monitor"
          href="/flightjs/Flight/-/metrics"
        >
          <span class="nav-icon-container">
            <svg class="s16" data-testid="monitor-icon">
              <use
                href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#monitor"
              ></use>
            </svg>
          </span>
          <span class="nav-item-name"> Monitor </span>
        </a>
        <!-- BEGIN app/views/shared/nav/_sidebar_submenu.html.haml -->
        <ul class="sidebar-sub-level-items" style="">
          <li class="fly-out-top-item">
            <span class="fly-out-top-item-container">
              <strong class="fly-out-top-item-name"> Monitor </strong>
            </span>
          </li>
          <li class="divider fly-out-top-item"></li>
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="metrics" class="">
            <a
              aria-label="Metrics"
              class="shortcuts-metrics gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Metrics"
              href="/flightjs/Flight/-/metrics"
            >
              <span> Metrics </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="error_tracking" class="">
            <a
              aria-label="Error Tracking"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Error Tracking"
              href="/flightjs/Flight/-/error_tracking"
            >
              <span> Error Tracking </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="alert_management" class="">
            <a
              aria-label="Alerts"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Alerts"
              href="/flightjs/Flight/-/alert_management"
            >
              <span> Alerts </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="incidents" class="">
            <a
              aria-label="Incidents"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Incidents"
              href="/flightjs/Flight/-/incidents"
            >
              <span> Incidents </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
        </ul>
        <!-- END app/views/shared/nav/_sidebar_submenu.html.haml -->
      </li>
      <!-- END app/views/shared/nav/_sidebar_menu.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_menu.html.haml -->
      <li data-track-label="analytics_menu" class="">
        <a
          aria-label="Analytics"
          class="shortcuts-analytics has-sub-items gl-link"
          data-qa-selector="sidebar_menu_link"
          data-qa-menu-item="Analytics"
          href="/flightjs/Flight/-/value_stream_analytics"
        >
          <span class="nav-icon-container">
            <svg class="s16" data-testid="chart-icon">
              <use
                href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#chart"
              ></use>
            </svg>
          </span>
          <span class="nav-item-name"> Analytics </span>
        </a>
        <!-- BEGIN app/views/shared/nav/_sidebar_submenu.html.haml -->
        <ul class="sidebar-sub-level-items" style="">
          <li class="fly-out-top-item">
            <span class="fly-out-top-item-container">
              <strong class="fly-out-top-item-name"> Analytics </strong>
            </span>
          </li>
          <li class="divider fly-out-top-item"></li>
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="cycle_analytics" class="">
            <a
              aria-label="Value stream"
              class="shortcuts-project-cycle-analytics gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Value stream"
              href="/flightjs/Flight/-/value_stream_analytics"
            >
              <span> Value stream </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="ci_cd_analytics" class="">
            <a
              aria-label="CI/CD"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="CI/CD"
              href="/flightjs/Flight/-/pipelines/charts"
            >
              <span> CI/CD </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="repository_analytics" class="">
            <a
              aria-label="Repository"
              class="shortcuts-repository-charts gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Repository"
              href="/flightjs/Flight/-/graphs/master/charts"
            >
              <span> Repository </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
        </ul>
        <!-- END app/views/shared/nav/_sidebar_submenu.html.haml -->
      </li>
      <!-- END app/views/shared/nav/_sidebar_menu.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_menu.html.haml -->
      <li data-track-label="wiki_menu" class="">
        <a
          aria-label="Wiki"
          class="shortcuts-wiki gl-link"
          data-qa-selector="sidebar_menu_link"
          data-qa-menu-item="Wiki"
          href="/flightjs/Flight/-/wikis/home"
        >
          <span class="nav-icon-container">
            <svg class="s16" data-testid="book-icon">
              <use
                href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#book"
              ></use>
            </svg>
          </span>
          <span class="nav-item-name"> Wiki </span>
        </a>
        <!-- BEGIN app/views/shared/nav/_sidebar_submenu.html.haml -->
        <ul class="sidebar-sub-level-items is-fly-out-only">
          <li class="fly-out-top-item">
            <span class="fly-out-top-item-container">
              <strong class="fly-out-top-item-name"> Wiki </strong>
            </span>
          </li>
        </ul>
        <!-- END app/views/shared/nav/_sidebar_submenu.html.haml -->
      </li>
      <!-- END app/views/shared/nav/_sidebar_menu.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_menu.html.haml -->
      <li data-track-label="snippets_menu" class="">
        <a
          aria-label="Snippets"
          class="shortcuts-snippets gl-link"
          data-qa-selector="sidebar_menu_link"
          data-qa-menu-item="Snippets"
          href="/flightjs/Flight/-/snippets"
        >
          <span class="nav-icon-container">
            <svg class="s16" data-testid="snippet-icon">
              <use
                href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#snippet"
              ></use>
            </svg>
          </span>
          <span class="nav-item-name"> Snippets </span>
        </a>
        <!-- BEGIN app/views/shared/nav/_sidebar_submenu.html.haml -->
        <ul class="sidebar-sub-level-items is-fly-out-only">
          <li class="fly-out-top-item">
            <span class="fly-out-top-item-container">
              <strong class="fly-out-top-item-name"> Snippets </strong>
            </span>
          </li>
        </ul>
        <!-- END app/views/shared/nav/_sidebar_submenu.html.haml -->
      </li>
      <!-- END app/views/shared/nav/_sidebar_menu.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_menu.html.haml -->
      <li data-track-label="settings_menu" class="">
        <a
          aria-label="Settings"
          class="has-sub-items gl-link"
          data-qa-selector="sidebar_menu_link"
          data-qa-menu-item="Settings"
          href="/flightjs/Flight/edit"
        >
          <span class="nav-icon-container">
            <svg class="s16" data-testid="settings-icon">
              <use
                href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#settings"
              ></use>
            </svg>
          </span>
          <span class="nav-item-name" id="js-onboarding-settings-link"> Settings </span>
        </a>
        <!-- BEGIN app/views/shared/nav/_sidebar_submenu.html.haml -->
        <ul class="sidebar-sub-level-items" style="">
          <li class="fly-out-top-item">
            <span class="fly-out-top-item-container">
              <strong class="fly-out-top-item-name"> Settings </strong>
            </span>
          </li>
          <li class="divider fly-out-top-item"></li>
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="general" class="">
            <a
              aria-label="General"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="General"
              href="/flightjs/Flight/edit"
            >
              <span> General </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="integrations" class="">
            <a
              aria-label="Integrations"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Integrations"
              href="/flightjs/Flight/-/settings/integrations"
            >
              <span> Integrations </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="webhooks" class="">
            <a
              aria-label="Webhooks"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Webhooks"
              href="/flightjs/Flight/-/hooks"
            >
              <span> Webhooks </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="access_tokens" class="">
            <a
              aria-label="Access Tokens"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Access Tokens"
              href="/flightjs/Flight/-/settings/access_tokens"
            >
              <span> Access Tokens </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="repository" class="">
            <a
              aria-label="Repository"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Repository"
              href="/flightjs/Flight/-/settings/repository"
            >
              <span> Repository </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="merge_requests" class="">
            <a
              aria-label="Merge requests"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Merge requests"
              href="/flightjs/Flight/-/settings/merge_requests"
            >
              <span> Merge requests </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="ci_cd" class="">
            <a
              aria-label="CI/CD"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="CI/CD"
              href="/flightjs/Flight/-/settings/ci_cd"
            >
              <span> CI/CD </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="packages_and_registries" class="">
            <a
              aria-label="Packages and registries"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Packages and registries"
              href="/flightjs/Flight/-/settings/packages_and_registries"
            >
              <span> Packages and registries </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="pages" class="">
            <a
              aria-label="Pages"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Pages"
              href="/flightjs/Flight/pages"
            >
              <span> Pages </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="monitor" class="">
            <a
              aria-label="Monitor"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Monitor"
              href="/flightjs/Flight/-/settings/operations"
            >
              <span> Monitor </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <!-- BEGIN app/views/shared/nav/_sidebar_menu_item.html.haml -->
          <li data-track-label="usage_quotas" class="">
            <a
              aria-label="Usage Quotas"
              class="gl-link"
              data-qa-selector="sidebar_menu_item_link"
              data-qa-menu-item="Usage Quotas"
              href="/flightjs/Flight/-/usage_quotas"
            >
              <span> Usage Quotas </span>
            </a>
          </li>
          <!-- END app/views/shared/nav/_sidebar_menu_item.html.haml -->
        </ul>
        <!-- END app/views/shared/nav/_sidebar_submenu.html.haml -->
      </li>
      <!-- END app/views/shared/nav/_sidebar_menu.html.haml -->

      <!-- BEGIN app/views/shared/nav/_sidebar_hidden_menu_item.html.haml -->
      <li class="hidden">
        <a
          aria-label="Activity"
          class="shortcuts-project-activity gl-link"
          href="/flightjs/Flight/activity"
          >Activity
        </a>
      </li>
      <!-- END app/views/shared/nav/_sidebar_hidden_menu_item.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_hidden_menu_item.html.haml -->
      <li class="hidden">
        <a
          aria-label="Graph"
          class="shortcuts-network gl-link"
          href="/flightjs/Flight/-/network/master"
          >Graph
        </a>
      </li>
      <!-- END app/views/shared/nav/_sidebar_hidden_menu_item.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_hidden_menu_item.html.haml -->
      <li class="hidden">
        <a
          aria-label="Create a new issue"
          class="shortcuts-new-issue gl-link"
          href="/flightjs/Flight/-/issues/new"
          >Create a new issue
        </a>
      </li>
      <!-- END app/views/shared/nav/_sidebar_hidden_menu_item.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_hidden_menu_item.html.haml -->
      <li class="hidden">
        <a aria-label="Jobs" class="shortcuts-builds gl-link" href="/flightjs/Flight/-/jobs"
          >Jobs
        </a>
      </li>
      <!-- END app/views/shared/nav/_sidebar_hidden_menu_item.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_hidden_menu_item.html.haml -->
      <li class="hidden">
        <a
          aria-label="Commits"
          class="shortcuts-commits gl-link"
          href="/flightjs/Flight/-/commits/master"
          >Commits
        </a>
      </li>
      <!-- END app/views/shared/nav/_sidebar_hidden_menu_item.html.haml -->
      <!-- BEGIN app/views/shared/nav/_sidebar_hidden_menu_item.html.haml -->
      <li class="hidden">
        <a
          aria-label="Issue Boards"
          class="shortcuts-issue-boards gl-link"
          href="/flightjs/Flight/-/boards"
          >Issue Boards
        </a>
      </li>
      <!-- END app/views/shared/nav/_sidebar_hidden_menu_item.html.haml -->
    </ul>
    <!-- BEGIN app/views/shared/_sidebar_toggle_button.html.haml -->
    <a
      class="toggle-sidebar-button js-toggle-sidebar rspec-toggle-sidebar"
      role="button"
      title="Toggle sidebar"
      type="button"
    >
      <svg class="s12 icon-chevron-double-lg-left" data-testid="chevron-double-lg-left-icon">
        <use
          href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#chevron-double-lg-left"
        ></use>
      </svg>
      <span class="collapse-text gl-ml-3">Collapse sidebar</span>
    </a>
    <button name="button" type="button" class="close-nav-button">
      <svg class="s16" data-testid="close-icon">
        <use
          href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#close"
        ></use>
      </svg>
      <span class="collapse-text gl-ml-3">Close sidebar</span>
    </button>
    <!-- END app/views/shared/_sidebar_toggle_button.html.haml -->
  </div>
</template>
