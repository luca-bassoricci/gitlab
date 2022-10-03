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
import ProjectMenu from './project_menu.vue';

export default {
  components: {
    ProjectMenu,
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
  <div
    class="layout-page hide-when-top-nav-responsive-open page-gutter right-sidebar-expanded page-with-contextual-sidebar"
  >
    <aside
      aria-label="Project navigation"
      class="nav-sidebar"
      data-track-action="render"
      data-track-label="projects_side_navigation"
      data-track-property="projects_side_navigation"
    >
      <project-menu project-id="projectId" />
    </aside>
    <div class="content-wrapper content-wrapper-margin">
      <div class="mobile-overlay"></div>
      <div class="alert-wrapper gl-force-block-formatting-context">
        <nav
          aria-label="Breadcrumbs"
          class="breadcrumbs container-fluid container-limited limit-container-width project-highlight-puc"
        >
          <div class="breadcrumbs-container">
            <button
              name="button"
              type="button"
              class="toggle-mobile-nav"
              data-qa-selector="toggle_mobile_nav_button"
            >
              <span class="sr-only">Open sidebar</span>
              <svg class="s18" data-testid="sidebar-icon">
                <use
                  href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#sidebar"
                ></use>
              </svg>
            </button>
            <div
              class="breadcrumbs-links"
              data-qa-selector="breadcrumb_links_content"
              data-testid="breadcrumb-links"
            >
              <ul class="list-unstyled breadcrumbs-list js-breadcrumbs-list">
                <!-- BEGIN app/views/layouts/nav/breadcrumbs/_collapsed_inline_list.html.haml -->
                <!-- END app/views/layouts/nav/breadcrumbs/_collapsed_inline_list.html.haml -->
                <li>
                  <a
                    class="group-path breadcrumb-item-text js-breadcrumb-item-text"
                    href="/flightjs"
                    >Flightjs</a
                  >
                  <svg class="s8 breadcrumbs-list-angle" data-testid="chevron-lg-right-icon">
                    <use
                      href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#chevron-lg-right"
                    ></use>
                  </svg>
                </li>
                <li>
                  <a href="/flightjs/Flight"
                    ><span class="breadcrumb-item-text js-breadcrumb-item-text">Flight</span></a
                  >
                  <svg class="s8 breadcrumbs-list-angle" data-testid="chevron-lg-right-icon">
                    <use
                      href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#chevron-lg-right"
                    ></use>
                  </svg>
                </li>
                <li>
                  <a href="/flightjs/Flight/-/issues">Issues</a>
                  <svg class="s8 breadcrumbs-list-angle" data-testid="chevron-lg-right-icon">
                    <use
                      href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#chevron-lg-right"
                    ></use>
                  </svg>
                </li>
                <!-- BEGIN app/views/layouts/nav/breadcrumbs/_collapsed_inline_list.html.haml -->
                <!-- END app/views/layouts/nav/breadcrumbs/_collapsed_inline_list.html.haml -->

                <li
                  data-qa-selector="breadcrumb_current_link"
                  data-testid="breadcrumb-current-link"
                >
                  <a href="/flightjs/Flight/-/issues/1">#1</a>
                </li>
              </ul>
            </div>
          </div>
        </nav>
        <!-- END app/views/layouts/nav/_breadcrumbs.html.haml -->
      </div>
      <div class="container-fluid container-limited limit-container-width project-highlight-puc">
        <slot name="main">
          <main
            class="content"
            id="content-body"
            itemscope=""
            itemtype="http://schema.org/SoftwareSourceCode"
          >
            <div
              class="flash-container flash-container-page sticky"
              data-qa-selector="flash_container"
            ></div>

            <aside
              aria-label="issue"
              aria-live="polite"
              class="right-sidebar js-right-sidebar js-issuable-sidebar right-sidebar-expanded"
              data-issuable-type="issue"
              data-signed-in=""
            >
              <div class="issuable-sidebar"></div>
            </aside>
          </main>
        </slot>
      </div>
    </div>
  </div>
</template>
