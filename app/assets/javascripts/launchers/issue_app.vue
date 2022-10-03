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
    issue: {
      type: Object,
      required: false,
    },
  },
  computed: {
    initialIssueData() {
      console.log('Init display Issue App - ', this.issue);
      return JSON.stringify({
        endpoint: this.issue.webPath,
        updateEndpoint: `${this.issue.webPath}.json`,
        canUpdate: true,
        canDestroy: true,
        canUpdateTimelineEvent: true,
        issuableRef: `#${this.issue.id}`,
        markdownPreviewPath: `/flightjs/Flight/preview_markdown?target_id=${this.issue.id}&target_type=Issue`,
        markdownDocsPath: '/help/user/markdown',
        lockVersion: 4,
        state: this.issue.state,
        issuableTemplateNamesPath: '/flightjs/Flight/description_templates/names/issue',
        initialTitleHtml: this.issue.title,
        initialTitleText: this.issue.title,
        initialDescriptionHtml: this.issue.descriptionHtml,
        initialDescriptionText: this.issue.description,
        initialTaskStatus: '0 of 0 checklist items completed',
        hasClosingMergeRequest: false,
        issueType: this.issue.type,
        zoomMeetingUrl: null,
        sentryIssueIdentifier: null,
        iid: this.issue.iid,
        isHidden: false,
        canCreateIncident: true,
        publishedIncidentUrl: null,
        slaFeatureAvailable: 'false',
        uploadMetricsFeatureAvailable: 'false',
        projectId: 6,
        projectPath: 'Flight',
        projectNamespace: 'flightjs',
        updatedAt: this.issue.updatedAt,
        updatedBy: {
          name: 'Administrator',
          path: '/root',
        },
        canAdmin: true,
        hasIssueWeightsFeature: false,
      });
    },
    initialNoteableData() {
      return JSON.stringify({
        id: 41,
        iid: 1,
        description: 'Quidem aut et iusto consequatur.',
        title: 'This is a test issue 123',
        time_estimate: 0,
        total_time_spent: 0,
        human_time_estimate: null,
        human_total_time_spent: null,
        state: 'opened',
        milestone_id: 27,
        updated_by_id: 1,
        created_at: '2022-01-20T11:10:36.813Z',
        updated_at: '2022-09-22T10:50:14.423Z',
        milestone: {
          id: 27,
          iid: 2,
          project_id: 6,
          title: 'v1.0',
          description: 'Deserunt repellat voluptates fugit facere dicta facilis.',
          state: 'active',
          created_at: '2022-01-20T11:10:31.832Z',
          updated_at: '2022-01-20T11:10:31.832Z',
          due_date: null,
          start_date: null,
          expired: null,
          web_url: 'http://127.0.0.1:3000/flightjs/Flight/-/milestones/2',
        },
        labels: [
          {
            id: 99,
            title: 'Alero',
            color: '#6235f2',
            description: null,
            group_id: null,
            project_id: 6,
            template: false,
            text_color: '#FFFFFF',
            created_at: '2022-01-20T11:10:29.936Z',
            updated_at: '2022-01-20T11:10:29.936Z',
          },
          {
            id: 42,
            title: 'Brience',
            color: '#734797',
            description: null,
            group_id: 31,
            project_id: null,
            template: false,
            text_color: '#FFFFFF',
            created_at: '2022-01-20T11:10:29.762Z',
            updated_at: '2022-01-20T11:10:29.762Z',
          },
          {
            id: 98,
            title: 'Cobalt',
            color: '#ec489c',
            description: null,
            group_id: null,
            project_id: 6,
            template: false,
            text_color: '#FFFFFF',
            created_at: '2022-01-20T11:10:29.934Z',
            updated_at: '2022-01-20T11:10:29.934Z',
          },
        ],
        lock_version: 4,
        author_id: 6,
        confidential: false,
        discussion_locked: null,
        assignees: [
          {
            id: 4,
            username: 'chante',
            name: 'Marla Blanda',
            state: 'active',
            avatar_url:
              'https://www.gravatar.com/avatar/ad6fcb7cdc3c0fc8b9032a212fdcdc4d?s=80&d=identicon',
            web_url: 'http://127.0.0.1:3000/chante',
          },
        ],
        due_date: null,
        project_id: 6,
        moved_to_id: null,
        duplicated_to_id: null,
        web_url: '/flightjs/Flight/-/issues/1',
        current_user: {
          can_create_note: true,
          can_update: true,
          can_set_issue_metadata: true,
          can_award_emoji: true,
        },
        create_note_path: '/flightjs/Flight/notes?target_id=41&target_type=issue',
        preview_note_path: '/flightjs/Flight/preview_markdown?target_id=1&target_type=Issue',
        is_project_archived: false,
        issue_email_participants: [],
        type: 'ISSUE',
        blocked: false,
        blocked_by_issues: [],
      });
    },
    initialNotesData() {
      return JSON.stringify({
        discussionsPath: `${this.issue.webPath}/discussions.json`,
        registerPath: '/users/sign_in?redirect_to_referer=yes#register-pane',
        newSessionPath: '/users/sign_in?redirect_to_referer=yes',
        markdownDocsPath: '/help/user/markdown',
        quickActionsDocsPath: '/help/user/project/quick_actions',
        closePath: '/flightjs/Flight/-/issues/1.json?issue%5Bstate_event%5D=close',
        reopenPath: '/flightjs/Flight/-/issues/1.json?issue%5Bstate_event%5D=reopen',
        notesPath: `/flightjs/Flight/noteable/issue/${this.issue.id.replace(
          'gid://gitlab/Issue/',
          '',
        )}/notes`,
        prerenderedNotesCount: 10,
        lastFetchedAt: 1664787629000000,
        notesFilter: 0,
      });
    },
    emojiPath() {
      return `/api/v4/projects/6/issues/${this.issue.iid}/award_emoji`;
    },
  },
  methods: {},
};
</script>

<template>
  <main
    class="content"
    id="content-body"
    itemscope=""
    itemtype="http://schema.org/SoftwareSourceCode"
  >
    <!-- BEGIN app/views/layouts/_flash.html.haml -->
    <div
      class="flash-container flash-container-page sticky"
      data-qa-selector="flash_container"
    ></div>
    <!-- END app/views/layouts/_flash.html.haml -->

    <!-- BEGIN app/views/projects/issues/show.html.haml -->
    <!-- BEGIN app/views/projects/issuable/_show.html.haml -->

    <!-- BEGIN app/views/shared/issue_type/_details_header.html.haml -->
    <div class="detail-page-header">
      <div class="detail-page-header-body">
        <!-- BEGIN app/components/pajamas/badge_component.rb -->
        <span
          class="gl-badge badge badge-pill badge-info md hidden issuable-status-badge gl-mr-3 issuable-status-badge-closed"
        >
          <svg class="s16 gl-icon gl-badge-icon gl-mr-0! gl-mr-2" data-testid="issue-closed-icon">
            <use
              href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#issue-closed"
            ></use>
          </svg>
          <div class="gl-display-none gl-sm-display-block gl-ml-2">Closed</div>
        </span>
        <!-- END app/components/pajamas/badge_component.rb -->
        <!-- BEGIN app/components/pajamas/badge_component.rb -->
        <span
          class="gl-badge badge badge-pill badge-success md issuable-status-badge gl-mr-3 issuable-status-badge-open"
        >
          <svg class="s16 gl-icon gl-badge-icon gl-mr-0! gl-mr-2" data-testid="issues-icon">
            <use
              href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#issues"
            ></use>
          </svg>
          <span class="gl-display-none gl-sm-display-block gl-ml-2"> Open </span>
        </span>
        <!-- END app/components/pajamas/badge_component.rb -->
        <div class="issuable-meta">
          <div data-hidden="false" id="js-issuable-header-warnings"></div>
          <span class="gl-mr-2" aria-hidden="true">
            <svg
              class="s16 gl-icon gl-vertical-align-middle gl-text-gray-500"
              data-testid="issue-type-issue-icon"
            >
              <use
                href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#issue-type-issue"
              ></use>
            </svg>
          </span>
          Issue created
          <time
            class="js-timeago"
            title="Jan 20, 2022 11:10am"
            datetime="2022-01-20T11:10:36Z"
            data-toggle="tooltip"
            data-placement="top"
            data-container="body"
            >8 months ago</time
          >
          by
          <strong>
            <a
              class="author-link js-user-link d-none d-sm-inline"
              data-user-id="6"
              data-username="agnus"
              data-name="Sebastian Swift"
              href="/agnus"
            >
              <img
                width="24"
                class="avatar avatar-inline s24 js-lazy-loaded qa-js-lazy-loaded"
                alt=""
                src="https://www.gravatar.com/avatar/6ecef66e253cc68d0ddbfaf7f480e517?s=48&amp;d=identicon"
                loading="lazy"
              />
              <span class="author">Sebastian Swift</span>
            </a>
            <a
              class="author-link js-user-link d-inline d-sm-none"
              data-user-id="6"
              data-username="agnus"
              data-name="Sebastian Swift"
              href="/agnus"
              ><span class="author">@agnus</span></a
            >
          </strong>
          <span
            class="user-access-role has-tooltip d-none d-xl-inline-block gl-ml-3"
            title="This user has the reporter role in the Flight project."
            >Reporter</span
          ><span class="has-tooltip gl-ml-2" title="1st contribution!"></span>
          <span id="task_status" class="d-none d-md-inline-block gl-ml-3"></span
          ><span id="task_status_short" class="d-md-none"></span>
        </div>
        <a
          class="btn gl-button btn-default btn-icon float-right gl-display-block d-sm-none gutter-toggle issuable-gutter-toggle js-sidebar-toggle"
          href="#"
        >
          <svg class="s16" data-testid="chevron-double-lg-left-icon">
            <use
              href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#chevron-double-lg-left"
            ></use>
          </svg>
        </a>
      </div>
      <div
        class="js-issue-header-actions"
        data-can-create-incident="true"
        data-can-create-issue="true"
        data-can-destroy-issue="true"
        data-can-promote-to-epic="false"
        data-can-reopen-issue="true"
        data-can-report-spam="false"
        data-can-update-issue="true"
        data-iid="1"
        data-is-issue-author="false"
        data-issue-path="/flightjs/Flight/-/issues/1"
        data-issue-type="issue"
        data-new-issue-path="/flightjs/Flight/-/issues/new?add_related_issue=1"
        data-project-path="flightjs/Flight"
        data-report-abuse-path="/-/abuse_reports/new?ref_url=http%3A%2F%2F127.0.0.1%3A3000%2Fflightjs%2FFlight%2F-%2Fissues%2F1&amp;user_id=6"
        data-submit-as-spam-path="/flightjs/Flight/-/issues/1/mark_as_spam"
      ></div>
    </div>
    <!-- END app/views/shared/issue_type/_details_header.html.haml -->

    <!-- BEGIN app/views/shared/issue_type/_details_content.html.haml -->
    <div class="issue-details issuable-details js-issue-details">
      <div class="detail-page-description content-block js-detail-page-description">
        <div
          data-full-path="flightjs/Flight"
          :data-initial="initialIssueData"
          data-issuable-id="41"
          id="js-issuable-app"
        ></div>
      </div>
      <div class="js-issue-widgets">
        <!-- BEGIN app/views/projects/issues/_design_management.html.haml -->
        <div
          class="js-design-management"
          data-issue-iid="1"
          data-issue-path="/flightjs/Flight/-/issues/1"
          data-project-path="flightjs/Flight"
          data-register-path="/users/sign_up?redirect_to_referer=yes"
          data-sign-in-path="/users/sign_in?redirect_to_referer=yes"
        ></div>
        <!-- END app/views/projects/issues/_design_management.html.haml -->

        <!-- BEGIN app/views/projects/issues/_work_item_links.html.haml -->
        <div
          class="js-work-item-links-root"
          data-iid="1"
          data-issuable-id="41"
          data-project-path="flightjs/Flight"
          data-wi-full-path="flightjs/Flight"
          data-wi-has-issue-weights-feature="false"
          data-wi-issues-list-path="/flightjs/Flight/-/issues"
        ></div>
        <!-- END app/views/projects/issues/_work_item_links.html.haml -->

        <!-- BEGIN ee/app/views/projects/issues/_linked_resources.html.haml -->
        <!-- END ee/app/views/projects/issues/_linked_resources.html.haml -->

        <!-- BEGIN app/views/projects/issues/_related_issues.html.haml -->
        <div
          class="js-related-issues-root"
          data-can-add-related-issues="true"
          data-endpoint="/flightjs/Flight/-/issues/1/links"
          data-full-path="flightjs/Flight"
          data-has-issue-weights-feature="false"
          data-help-path="/help/user/project/issues/related_issues"
          data-show-categorized-issues="false"
        ></div>
        <!-- END app/views/projects/issues/_related_issues.html.haml -->

        <div
          data-endpoint="/api/v4/projects/6/issues/1/related_merge_requests"
          data-project-namespace="flightjs"
          data-project-path="Flight"
          id="js-related-merge-requests"
        ></div>
        <div data-url="/flightjs/Flight/-/issues/1/related_branches" id="related-branches"></div>
      </div>
      <div class="js-issue-widgets">
        <!-- BEGIN app/views/shared/issue_type/_emoji_block.html.haml -->
        <div class="content-block emoji-block emoji-block-sticky">
          <div class="row gl-m-0 gl-justify-content-space-between">
            <div class="js-noteable-awards">
              <!-- BEGIN app/views/award_emoji/_awards_block.html.haml -->
              <div class="gl-display-flex gl-flex-wrap gl-justify-content-space-between">
                <div
                  data-can-award-emoji="true"
                  :data-path="emojiPath"
                  id="js-vue-awards-block"
                ></div>
              </div>
              <!-- END app/views/award_emoji/_awards_block.html.haml -->
            </div>
            <div class="new-branch-col gl-display-flex gl-my-2 gl-font-size-0 gl-gap-3">
              <!-- BEGIN ee/app/views/projects/issues/_timeline_toggle.html.haml -->
              <!-- END ee/app/views/projects/issues/_timeline_toggle.html.haml -->

              <div
                data-default-filter="0"
                data-notes-filters='{"Show all activity":0,"Show comments only":1,"Show history only":2}'
                id="js-vue-discussion-filter"
              ></div>
              <!-- BEGIN app/views/projects/issues/_new_branch.html.haml -->
              <div
                class="create-mr-dropdown-wrap d-inline-block full-width-mobile js-create-mr"
                data-can-create-path="/flightjs/Flight/-/issues/1/can_create_branch"
                data-create-branch-path="/flightjs/Flight/-/branches?branch_name=1-this-is-a-test-issue-123&amp;format=json&amp;issue_iid=1&amp;ref=master"
                data-create-mr-path="/flightjs/Flight/-/merge_requests/new?merge_request%5Bissue_iid%5D=1&amp;merge_request%5Bsource_branch%5D=1-this-is-a-test-issue-123&amp;merge_request%5Btarget_branch%5D=master"
                data-is-confidential="false"
                data-project-id="6"
                data-project-path="flightjs/Flight"
                data-refs-path="/flightjs/Flight/refs?search="
              >
                <div class="btn-group unavailable">
                  <button class="gl-button btn" disabled="disabled" type="button">
                    <span
                      class="gl-spinner-container js-create-mr-spinner gl-button-icon gl-display-none"
                      role="status"
                    >
                      <span
                        class="gl-spinner gl-spinner-dark gl-spinner-sm gl-vertical-align-text-bottom!"
                        aria-label="Loading"
                      ></span>
                    </span>
                    <span class="text"> Checking branch availability… </span>
                  </button>
                </div>
                <div class="btn-group available hidden">
                  <button
                    class="gl-button btn js-create-merge-request btn-confirm"
                    data-action="create-mr"
                    type="button"
                  >
                    <div
                      class="gl-spinner-container js-create-mr-spinner js-spinner gl-mr-2 gl-display-none"
                      role="status"
                    >
                      <span
                        class="gl-spinner gl-spinner-dark gl-spinner-sm gl-vertical-align-text-bottom!"
                        aria-label="Loading"
                      ></span>
                    </div>
                    Create merge request
                  </button>
                  <button
                    class="gl-button btn btn-confirm btn-icon dropdown-toggle create-merge-request-dropdown-toggle js-dropdown-toggle"
                    data-display="static"
                    data-dropdown-trigger="#create-merge-request-dropdown"
                    type="button"
                  >
                    <svg class="s16" data-testid="chevron-down-icon">
                      <use
                        href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#chevron-down"
                      ></use>
                    </svg>
                  </button>
                  <div class="droplab-dropdown">
                    <ul
                      class="create-merge-request-dropdown-menu dropdown-menu dropdown-menu-right gl-show-field-errors"
                      data-dropdown=""
                      id="create-merge-request-dropdown"
                    >
                      <li
                        class="droplab-item-selected"
                        data-text="Create merge request"
                        data-value="create-mr"
                        role="button"
                      >
                        <div class="menu-item text-nowrap">
                          <svg class="s16 icon" data-testid="check-icon">
                            <use
                              href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#check"
                            ></use>
                          </svg>
                          Create merge request and branch
                        </div>
                      </li>
                      <li
                        class=""
                        data-text="Create branch"
                        data-value="create-branch"
                        role="button"
                      >
                        <div class="menu-item">
                          <svg class="s16 icon" data-testid="check-icon">
                            <use
                              href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#check"
                            ></use>
                          </svg>
                          Create branch
                        </div>
                      </li>
                      <li class="divider droplab-item-ignore"></li>
                      <li class="droplab-item-ignore gl-ml-3 gl-mr-3 gl-mt-5">
                        <div class="form-group">
                          <label for="new-branch-name"> Branch name </label>
                          <input
                            class="js-branch-name form-control gl-form-input"
                            id="new-branch-name"
                            placeholder="1-this-is-a-test-issue-123"
                            type="text"
                            value="1-this-is-a-test-issue-123"
                          />
                          <p class="gl-field-error hidden">This field is required.</p>
                          <span class="js-branch-message form-text"></span>
                        </div>
                        <div class="form-group">
                          <label for="source-name"> Source (branch or tag) </label>
                          <input
                            class="js-ref ref form-control gl-form-input"
                            data-value="master"
                            id="source-name"
                            placeholder="master"
                            type="text"
                            value="master"
                          />
                          <p class="gl-field-error hidden">This field is required.</p>
                          <span class="js-ref-message form-text"></span>
                        </div>
                        <div class="form-group">
                          <button
                            class="btn gl-button btn-confirm js-create-target"
                            data-action="create-mr"
                            type="button"
                          >
                            Create merge request
                          </button>
                        </div>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
              <!-- END app/views/projects/issues/_new_branch.html.haml -->
            </div>
          </div>
        </div>
        <!-- END app/views/shared/issue_type/_emoji_block.html.haml -->

        <!-- BEGIN app/views/projects/issues/_discussion.html.haml -->
        <section class="issuable-discussion js-vue-notes-event">
          <div
            data-can-add-timeline-events="true"
            data-current-user-data='{"id":1,"username":"root","name":"Administrator","state":"active","avatar_url":"https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon","web_url":"http://127.0.0.1:3000/root","show_status":false,"path":"/root","user_preference":{"issue_notes_filter":0,"merge_request_notes_filter":0,"notes_filters":{"Show all activity":0,"Show comments only":1,"Show history only":2},"default_notes_filter":0,"epic_notes_filter":0}}'
            :data-noteable-data="initialNoteableData"
            data-noteable-type="Issue"
            :data-notes-data="initialNotesData"
            data-target-type="issue"
            id="js-vue-notes"
          ></div>
        </section>
        <!-- END app/views/projects/issues/_discussion.html.haml -->
      </div>
    </div>
    <!-- BEGIN app/views/shared/issuable/_sidebar.html.haml -->
    <aside
      aria-label="issue"
      aria-live="polite"
      class="right-sidebar js-right-sidebar js-issuable-sidebar right-sidebar-expanded"
      data-issuable-type="issue"
      data-signed-in=""
    >
      <div class="issuable-sidebar">
        <div class="issuable-sidebar-header">
          <a
            aria-label="Toggle sidebar"
            class="gutter-toggle float-right js-sidebar-toggle has-tooltip"
            data-boundary="viewport"
            data-container="body"
            data-placement="left"
            href="#"
            role="button"
            title="Collapse sidebar"
          >
            <span class="js-sidebar-toggle-container" data-is-expanded="true">
              <svg class="s16 js-sidebar-expand hidden" data-testid="chevron-double-lg-left-icon">
                <use
                  href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#chevron-double-lg-left"
                ></use>
              </svg>
              <svg class="s16 js-sidebar-collapse" data-testid="chevron-double-lg-right-icon">
                <use
                  href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#chevron-double-lg-right"
                ></use>
              </svg>
            </span>
          </a>
          <div
            class="js-issuable-todo"
            data-id="41"
            data-iid="1"
            data-project-path="flightjs/Flight"
          ></div>
        </div>
        <form
          class="issuable-context-form inline-update js-issuable-update"
          action="/flightjs/Flight/-/issues/1.json"
          accept-charset="UTF-8"
          data-remote="true"
          method="post"
        >
          <div class="block assignee qa-assignee-block" data-qa-selector="assignee_block_container">
            <!-- BEGIN app/views/shared/issuable/_sidebar_assignees.html.haml -->
            <div
              data-directly-invite-members=""
              data-field="issue"
              data-max-assignees="1"
              data-signed-in=""
              id="js-vue-sidebar-assignees"
            >
              <div class="title hide-collapsed">
                Assignee
                <span class="gl-spinner-container" role="status"
                  ><span
                    class="gl-spinner gl-spinner-dark gl-spinner-sm gl-vertical-align-text-bottom!"
                    aria-label="Loading"
                  ></span
                ></span>
              </div>
            </div>
            <div class="js-sidebar-assignee-data selectbox hide-collapsed">
              <input
                type="hidden"
                name="issue[assignee_ids][]"
                value="4"
                data-avatar-url="https://www.gravatar.com/avatar/ad6fcb7cdc3c0fc8b9032a212fdcdc4d?s=80&amp;d=identicon"
                data-name="Marla Blanda"
                data-username="chante"
                autocomplete="off"
              />
              <!-- BEGIN app/views/shared/issuable/_sidebar_user_dropdown.html.haml -->
              <div class="dropdown js-sidebar-assignee-dropdown">
                <button
                  class="dropdown-menu-toggle js-user-search js-author-search js-multiselect js-save-user-data js-invite-members-track"
                  type="button"
                  data-first-user="root"
                  data-current-user="true"
                  data-iid="1"
                  data-issuable-type="issue"
                  data-project-id="6"
                  data-author-id="6"
                  data-field-name="issue[assignee_ids][]"
                  data-issue-update="/flightjs/Flight/-/issues/1.json"
                  data-ability-name="issue"
                  data-null-user="true"
                  data-display="static"
                  data-multi-select="true"
                  data-dropdown-title="Select assignee"
                  data-dropdown-header="Assignee"
                  data-max-select="1"
                  data-track-action="show_invite_members"
                  data-track-label="edit_assignee"
                  data-toggle="dropdown"
                >
                  <span class="dropdown-toggle-text">Select assignee</span>
                  <svg
                    class="s16 dropdown-menu-toggle-icon gl-top-3"
                    data-testid="chevron-down-icon"
                  >
                    <use
                      href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#chevron-down"
                    ></use>
                  </svg>
                </button>
                <div
                  class="dropdown-menu dropdown-select dropdown-menu-user dropdown-menu-selectable dropdown-menu-author dropdown-extended-height"
                >
                  <div class="dropdown-title gl-display-flex">
                    <span class="gl-ml-auto">Assign to</span>
                    <button
                      class="dropdown-title-button dropdown-menu-close gl-ml-auto"
                      aria-label="Close"
                      type="button"
                    >
                      <svg class="s16 dropdown-menu-close-icon" data-testid="close-icon">
                        <use
                          href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#close"
                        ></use>
                      </svg>
                    </button>
                  </div>
                  <div class="dropdown-input">
                    <input
                      type="search"
                      data-qa-selector="dropdown_input_field"
                      class="dropdown-input-field"
                      placeholder="Search users"
                      autocomplete="off"
                    />
                    <svg class="s16 dropdown-input-search" data-testid="search-icon">
                      <use
                        href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#search"
                      ></use>
                    </svg>
                    <svg
                      class="s16 dropdown-input-clear js-dropdown-input-clear"
                      data-testid="close-icon"
                    >
                      <use
                        href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#close"
                      ></use>
                    </svg>
                  </div>
                  <div data-qa-selector="dropdown_list_content" class="dropdown-content"></div>
                  <div class="dropdown-footer">
                    <ul class="dropdown-footer-list">
                      <li>
                        <div
                          class="js-invite-members-trigger"
                          data-display-text="Invite Members"
                          data-event="click_invite_members"
                          data-label="edit_assignee"
                          data-trigger-element="anchor"
                          data-trigger-source="issue-assignee-dropdown"
                        ></div>
                      </li>
                    </ul>
                  </div>
                  <div class="dropdown-loading">
                    <div class="gl-spinner-container gl-mt-7" role="status">
                      <span
                        class="gl-spinner gl-spinner-dark gl-spinner-md gl-vertical-align-text-bottom!"
                        aria-label="Loading"
                      ></span>
                    </div>
                  </div>
                </div>
              </div>
              <!-- END app/views/shared/issuable/_sidebar_user_dropdown.html.haml -->
            </div>
            <!-- END app/views/shared/issuable/_sidebar_assignees.html.haml -->
          </div>
          <!-- BEGIN app/views/shared/issuable/_sidebar_user_dropdown.html.haml -->
          <!-- BEGIN ee/app/views/shared/promotions/_promote_epics.html.haml -->
          <!-- END ee/app/views/shared/promotions/_promote_epics.html.haml -->

          <!-- END app/views/shared/issuable/_sidebar_user_dropdown.html.haml -->

          <div
            class="js-sidebar-labels"
            data-allow-label-create="true"
            data-allow-scoped-labels="false"
            data-can-edit="true"
            :data-iid="issue.iid"
            :data-issuable-type="issue.type"
            data-labels-fetch-path="/flightjs/Flight/-/labels.json?include_ancestor_groups=true"
            data-labels-manage-path="/flightjs/Flight/-/labels"
            data-project-issues-path="/flightjs/Flight/-/issues"
            data-project-path="flightjs/Flight"
            :data-selected-labels="JSON.stringify(issue.labels.nodes)"
          ></div>
          <div
            class="block milestone gl-border-b-0!"
            data-qa-selector="milestone_block"
            data-testid="sidebar-milestones"
          >
            <div
              class="js-milestone-select"
              data-can-edit="true"
              :data-issue-iid="issue.iid"
              data-project-path="flightjs/Flight"
            ></div>
          </div>
          <div
            class="block gl-collapse-empty"
            data-qa-selector="iteration_container"
            data-testid="iteration_container"
          >
            <!-- BEGIN ee/app/views/shared/issuable/_iteration_select.html.haml -->
            <!-- END ee/app/views/shared/issuable/_iteration_select.html.haml -->
          </div>
          <!-- BEGIN ee/app/views/shared/issuable/_sidebar_weight.html.haml -->
          <!-- BEGIN ee/app/views/shared/promotions/_promote_issue_weights.html.haml -->
          <div
            class="block js-weight-sidebar-callout promotion-issue-sidebar"
            data-uid="promote_weight_sidebar_dismissed"
          >
            <div
              class="sidebar-collapsed-icon"
              data-target=".js-weight-sidebar-callout"
              data-toggle="dropdown"
            >
              <span
                data-container="body"
                data-placement="left"
                data-toggle="tooltip"
                title="Weight"
              >
                <svg class="s16" data-testid="scale-icon">
                  <use
                    href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#scale"
                  ></use>
                </svg>
                <span>No</span>
              </span>
            </div>
            <div class="title hide-collapsed">Weight</div>
            <div class="hide-collapsed js-toggle-container promotion-issue-weight-sidebar-message">
              This feature is locked.
              <a class="btn-link js-toggle-button js-weight-sidebar-callout-btn" href="#">
                Learn more
                <svg class="s16 js-sidebar-collapse hidden" data-testid="chevron-up-icon">
                  <use
                    href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#chevron-up"
                  ></use>
                </svg>
                <svg class="s16 js-sidebar-expand" data-testid="chevron-down-icon">
                  <use
                    href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#chevron-down"
                  ></use>
                </svg>
              </a>
              <div class="js-toggle-content" style="display: none">
                <div>
                  <h4>Weighting your issue</h4>
                  <p>
                    <img
                      class="w-100 box-shadow-default js-lazy-loaded qa-js-lazy-loaded"
                      src="/assets/promotions/img-paid-feature-weight-sidebar-fc9e2c924b3d18f097776fd74202e4b2d55bd1dd678737e5c64e61d8ec6fc8a6.png"
                      loading="lazy"
                    />
                  </p>
                  <p>
                    When you have a lot of issues, it can be hard to get an overview. By adding a
                    weight to your issues, you can get a better idea of the effort, cost, required
                    time, or value of each, and so better manage them.
                  </p>
                  <p>Improve issues management with Issue weight and GitLab Enterprise Edition.</p>
                  <div>
                    <!-- BEGIN ee/app/views/shared/promotions/_promotion_link_project.html.haml -->
                    <a
                      class="gl-button btn btn-confirm gl-mb-3"
                      href="https://customers.staging.gitlab.com/trials/new?return_to=http%3A%2F%2F127.0.0.1%3A3000&amp;id=YWRtaW5AZXhhbXBsZS5jb20="
                      >Start GitLab Ultimate trial</a
                    >
                    <!-- END ee/app/views/shared/promotions/_promotion_link_project.html.haml -->

                    <a
                      class="gl-button btn js-close js-close-callout gl-mt-3 js-close-session tr-issue-weights-not-now-cta"
                      href="#"
                      >Not now, thanks!</a
                    >
                  </div>
                </div>
              </div>
            </div>
          </div>
          <!-- END ee/app/views/shared/promotions/_promote_issue_weights.html.haml -->

          <!-- END ee/app/views/shared/issuable/_sidebar_weight.html.haml -->

          <div id="js-due-date-entry-point"></div>
          <div class="block" id="issuable-time-tracker">
            <!-- / Fallback while content is loading -->
            <div class="title hide-collapsed">
              Time tracking
              <span class="gl-spinner-container" role="status"
                ><span
                  class="gl-spinner gl-spinner-dark gl-spinner-sm gl-vertical-align-text-bottom!"
                  aria-label="Loading"
                ></span
              ></span>
            </div>
          </div>
          <script id="js-confidential-issue-data" type="application/json">
            { "is_confidential": false, "is_editable": true }
          </script>
          <div id="js-confidential-entry-point"></div>
          <!-- BEGIN ee/app/views/shared/promotions/_promotion_link_project.html.haml -->
          <!-- END ee/app/views/shared/promotions/_promotion_link_project.html.haml -->

          <div id="js-lock-entry-point"></div>
          <div class="js-sidebar-subscriptions-entry-point"></div>
          <div class="js-sidebar-participants-entry-point"></div>
          <div class="block with-sub-blocks">
            <div id="js-reference-entry-point"></div>
          </div>
          <div class="block js-sidebar-move-issue-block">
            <div
              class="sidebar-collapsed-icon"
              data-boundary="viewport"
              data-container="body"
              data-placement="left"
              data-toggle="tooltip"
              title="Move issue"
            >
              <svg class="s16" data-testid="long-arrow-icon">
                <use
                  href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#long-arrow"
                ></use>
              </svg>
            </div>
            <div class="dropdown sidebar-move-issue-dropdown hide-collapsed">
              <!-- BEGIN app/components/pajamas/button_component.rb -->
              <button
                class="gl-button btn btn-block btn-md btn-default js-sidebar-dropdown-toggle js-move-issue"
                data-toggle="dropdown"
                data-display="static"
                data-track-label="right_sidebar"
                data-track-property="move_issue"
                data-track-action="click_button"
                data-track-value=""
                type="button"
              >
                <span class="gl-button-text"> Move issue </span>
              </button>
              <!-- END app/components/pajamas/button_component.rb -->
              <div class="dropdown-menu dropdown-menu-selectable dropdown-extended-height">
                <div class="dropdown-title gl-display-flex">
                  <span class="gl-ml-auto">Move issue</span>
                  <button
                    class="dropdown-title-button dropdown-menu-close gl-ml-auto"
                    aria-label="Close"
                    type="button"
                  >
                    <svg class="s16 dropdown-menu-close-icon" data-testid="close-icon">
                      <use
                        href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#close"
                      ></use>
                    </svg>
                  </button>
                </div>
                <div class="dropdown-input">
                  <input
                    type="search"
                    name="sidebar-move-issue-dropdown-search"
                    data-qa-selector="dropdown_input_field"
                    class="dropdown-input-field"
                    placeholder="Search project"
                    autocomplete="off"
                  />
                  <svg class="s16 dropdown-input-search" data-testid="search-icon">
                    <use
                      href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#search"
                    ></use>
                  </svg>
                  <svg
                    class="s16 dropdown-input-clear js-dropdown-input-clear"
                    data-testid="close-icon"
                  >
                    <use
                      href="/assets/icons-7b0fcccb8dc2c0d0883e05f97e4678621a71b996ab2d30bb42fafc906c1ee13f.svg#close"
                    ></use>
                  </svg>
                </div>
                <div class="dropdown-content"></div>
                <div class="dropdown-loading">
                  <div class="gl-spinner-container gl-mt-7" role="status">
                    <span
                      class="gl-spinner gl-spinner-dark gl-spinner-md gl-vertical-align-text-bottom!"
                      aria-label="Loading"
                    ></span>
                  </div>
                </div>
                <div class="dropdown-footer">
                  <div class="dropdown-footer-content">
                    <button
                      class="gl-button btn btn-confirm sidebar-move-issue-confirmation-button js-move-issue-confirmation-button"
                      disabled=""
                      type="button"
                    >
                      <span
                        class="gl-spinner-container sidebar-move-issue-confirmation-loading-icon gl-mr-2"
                        role="status"
                      >
                        <span
                          class="gl-spinner gl-spinner-dark gl-spinner-sm gl-vertical-align-text-bottom!"
                          aria-label="Loading"
                        ></span>
                      </span>
                      Move
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </form>
        <script class="js-sidebar-options" type="application/json">
          {
            "endpoint": "/flightjs/Flight/-/issues/{{issue.iid}}.json?serializer=sidebar_extras",
            "toggleSubscriptionEndpoint": "/flightjs/Flight/-/issues/{{issue.iid}}/toggle_subscription",
            "moveIssueEndpoint": "/flightjs/Flight/-/issues/{{issue.iid}}/move",
            "projectsAutocompleteEndpoint": "/-/autocomplete/projects?project_id=6",
            "editable": true,
            "currentUser": {
              "id": 1,
              "username": "root",
              "name": "Administrator",
              "state": "active",
              "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon",
              "web_url": "http://127.0.0.1:3000/root",
              "todo": null,
              "can_edit": true,
              "can_move": true,
              "can_admin_label": true
            },
            "rootPath": "/",
            "fullPath": "flightjs/Flight",
            "iid": {{issue.iid}},
            "id": 41,
            "severity": "unknown",
            "timeTrackingLimitToHours": false,
            "createNoteEmail": null,
            "issuableType": "issue",
            "weightOptions": [
              "None",
              "Any",
              0,
              1,
              2,
              3,
              4,
              5,
              6,
              7,
              8,
              9,
              10,
              11,
              12,
              13,
              14,
              15,
              16,
              17,
              18,
              19,
              20
            ],
            "weightNoneValue": "None"
          }
        </script>
      </div>
    </aside>
    <!-- END app/views/shared/issuable/_sidebar.html.haml -->

    <!-- END app/views/shared/issue_type/_details_content.html.haml -->

    <!-- END app/views/projects/issuable/_show.html.haml -->

    <!-- END app/views/projects/issues/show.html.haml -->
  </main>
</template>
