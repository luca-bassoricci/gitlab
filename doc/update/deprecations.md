---
stage: none
group: none
info: "See the Technical Writers assigned to Development Guidelines: https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments-to-development-guidelines"
---

# Deprecations by milestone

DISCLAIMER:
This page contains information related to upcoming products, features, and functionality.
It is important to note that the information presented is for informational purposes only.
Please do not rely on this information for purchasing or planning purposes.
As with all projects, the items mentioned on this page are subject to change or delay.
The development, release, and timing of any products, features, or functionality remain at the
sole discretion of GitLab Inc.

<!-- vale off -->

<!--
DO NOT EDIT THIS PAGE DIRECTLY

This page is automatically generated from the YAML files in `/data/deprecations` by the rake task
located at `lib/tasks/gitlab/docs/compile_deprecations.rake`.

For deprecation authors (usually Product Managers and Engineering Managers):

- To add a deprecation, use the example.yml file in `/data/deprecations/templates` as a template.
- For more information about authoring deprecations, check the the deprecation item guidance:
  https://about.gitlab.com/handbook/marketing/blog/release-posts/#creating-a-deprecation-entry

For deprecation reviewers (Technical Writers only):

- To update the deprecation doc, run: `bin/rake gitlab:docs:compile_deprecations`
- To verify the deprecations doc is up to date, run: `bin/rake gitlab:docs:check_deprecations`
- For more information about updating the deprecation doc, see the deprecation doc update guidance:
  https://about.gitlab.com/handbook/marketing/blog/release-posts/#update-the-deprecations-doc
-->

## 14.0

### NFS for Git repository storage

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

With the general availability of Gitaly Cluster ([introduced in GitLab 13.0](https://about.gitlab.com/releases/2020/05/22/gitlab-13-0-released/)), we have deprecated development (bugfixes, performance improvements, etc) for NFS for Git repository storage in GitLab 14.0. We will continue to provide technical support for NFS for Git repositories throughout 14.x, but we will remove all support for NFS in GitLab 15.0. Please see our official [Statement of Support](https://about.gitlab.com/support/statement-of-support.html#gitaly-and-nfs) for further information.

Gitaly Cluster offers tremendous benefits for our customers such as:

- [Variable replication factors](https://docs.gitlab.com/ee/administration/gitaly/index.html#replication-factor).
- [Strong consistency](https://docs.gitlab.com/ee/administration/gitaly/index.html#strong-consistency).
- [Distributed read capabilities](https://docs.gitlab.com/ee/administration/gitaly/index.html#distributed-reads).

We encourage customers currently using NFS for Git repositories to plan their migration by reviewing our documentation on [migrating to Gitaly Cluster](https://docs.gitlab.com/ee/administration/gitaly/index.html#migrate-to-gitaly-cluster).

**Planned removal milestone: 15.0 (2022-05-22)**

### OAuth implicit grant

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The OAuth implicit grant authorization flow will be removed in our next major release, GitLab 15.0. Any applications that use OAuth implicit grant should switch to alternative [supported OAuth flows](https://docs.gitlab.com/ee/api/oauth2.html).

**Planned removal milestone: 15.0 (2022-05-22)**

## 14.2

### Release CLI distributed as a generic package

The [release-cli](https://gitlab.com/gitlab-org/release-cli) will be released as a [generic package](https://gitlab.com/gitlab-org/release-cli/-/packages) starting in GitLab 14.2. We will continue to deploy it as a binary to S3 until GitLab 14.5 and stop distributing it in S3 in GitLab 14.6.

**Planned removal milestone: 14.6 (2021-12-22)**

### Rename Task Runner pod to Toolbox

The Task Runner pod is used to execute periodic housekeeping tasks within the GitLab application and is often confused with the GitLab Runner. Thus, [Task Runner will be renamed to Toolbox](https://gitlab.com/groups/gitlab-org/charts/-/epics/25).

This will result in the rename of the sub-chart: `gitlab/task-runner` to `gitlab/toolbox`. Resulting pods will be named along the lines of `{{ .Release.Name }}-toolbox`, which will often be `gitlab-toolbox`. They will be locatable with the label `app=toolbox`.

**Planned removal milestone: 14.5 (2021-11-22)**

## 14.3

### Audit events for repository push events

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

Audit events for [repository events](https://docs.gitlab.com/ee/administration/audit_events.html#repository-push-deprecated) are now deprecated and will be removed in GitLab 15.0.

These events have always been disabled by default and had to be manually enabled with a
feature flag. Enabling them can cause too many events to be generated which can
dramatically slow down GitLab instances. For this reason, they are being removed.

**Planned removal milestone: 15.0 (2022-05-22)**

### GitLab Serverless

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

[GitLab Serverless](https://docs.gitlab.com/ee/user/project/clusters/serverless/) is a feature set to support Knative-based serverless development with automatic deployments and monitoring.

We decided to remove the GitLab Serverless features as they never really resonated with our users. Besides, given the continuous development of Kubernetes and Knative, our current implementations do not even work with recent versions.

**Planned removal milestone: 15.0 (2022-05-22)**

### Legacy database configuration

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The syntax of [GitLabs database](https://docs.gitlab.com/omnibus/settings/database.html)
configuration located in `database.yml` is changing and the legacy format is deprecated. The legacy format
supported using a single PostgreSQL adapter, whereas the new format is changing to support multiple databases. The `main:` database needs to be defined as a first configuration item.

This deprecation mainly impacts users compiling GitLab from source because Omnibus will handle this configuration automatically.

**Planned removal milestone: 15.0 (2022-05-22)**

### OmniAuth Kerberos gem

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The `omniauth-kerberos` gem will be removed in our next major release, GitLab 15.0.

This gem has not been maintained and has very little usage. We therefore plan to remove support for this authentication method and recommend using the Kerberos [SPNEGO](https://en.wikipedia.org/wiki/SPNEGO) integration instead. You can follow the [upgrade instructions](https://docs.gitlab.com/ee/integration/kerberos.html#upgrading-from-password-based-to-ticket-based-kerberos-sign-ins) to upgrade from the `omniauth-kerberos` integration to the supported one.

Note that we are not deprecating the Kerberos SPNEGO integration, only the old password-based Kerberos integration.

**Planned removal milestone: 15.0 (2022-05-22)**

## 14.5

### Certificate-based integration with Kubernetes

WARNING:
This feature will be changed or removed in 15.6
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

[We are deprecating the certificate-based integration with Kubernetes](https://about.gitlab.com/blog/2021/11/15/deprecating-the-cert-based-kubernetes-integration/).
The timeline of removal of the integration from the product is planned to happen in two steps, starting with milestone 15.0 and finishing in GitLab version 15.6.

In 15.0, we plan to introduce a feature flag that will allow GitLab Self-Managed customers to keep the certificate-based integration enabled, it will be disabled by default. We plan to remove this feature flag together with the underlying code in GitLab version 15.6.
The certificate-based integration will continue to receive security and
critical fixes, and features built on the integration will continue to work with supported Kubernetes
versions until the final removal in 15.6.

For a more robust, secure, forthcoming, and reliable integration with Kubernetes, we recommend the use of the
[Kubernetes Agent](https://docs.gitlab.com/ee/user/clusters/agent/) to connect Kubernetes clusters with GitLab. 
We provide [migration plans](https://docs.gitlab.com/ee/user/infrastructure/clusters/migrate_to_gitlab_agent.html) in the documentation. 

For updates and details around this deprecation, follow this [epic](https://gitlab.com/groups/gitlab-org/configure/-/epics/8).

**Planned removal milestone: 15.6 (2022-11-22)**

### Converting an instance (shared) runner to a project (specific) runner

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

In GitLab 15.0, we will remove the feature that enables you to convert an instance (shared) runner to a project (specific) runner. Users who need to add a runner to only a particular project can register a runner to the project directly.

**Planned removal milestone: 15.0 (2022-05-22)**

### Known host required for GitLab Runner SSH executor

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

In [GitLab 14.3](https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/3074), we added a configuration setting in the GitLab Runner `config.toml` file. This setting, [`[runners.ssh.disable_strict_host_key_checking]`](https://docs.gitlab.com/runner/executors/ssh.html#security), controls whether or not to use strict host key checking with the SSH executor.

In GitLab 15.0 and later, the default value for this configuration option will change from `true` to `false`. This means that strict host key checking will be enforced when using the GitLab Runner SSH executor.

**Planned removal milestone: 15.0 (2022-05-22)**

### Must explicitly assign `AuthenticationType` for `[runners.cache.s3]`

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

In GitLab 15.0 and later, to access the AWS S3 cache, you must specify the `AuthenticationType` for [`[runners.cache.s3]`](https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnerscaches3-section). The `AuthenticationType` must be `IAM` or `credentials`.

Prior to 14.5, if you did not define the `AuthenticationType`, GitLab Runner chose a type for you.

**Planned removal milestone: 15.0 (2022-05-22)**

### Package pipelines in API payload is paginated

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

A request to the API for `/api/v4/projects/:id/packages` returns a paginated result of packages. Each package lists all of its pipelines in this response. This is a performance concern, as it's possible for a package to have hundreds or thousands of associated pipelines.

In milestone 15.0, we will remove the `pipelines` attribute from the API response.

**Planned removal milestone: 15.0 (2022-05-22)**

### REST and GraphQL API Runner status will not return `paused`

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The GitLab Runner REST and GraphQL API endpoints will not return `paused` or `active` as a status in GitLab 15.0.

A runner's status will only relate to runner contact status, such as:
`online`, `offline`, or `not_connected`. Status `paused` or `active` will no longer appear.

When checking if a runner is `paused`, API users are advised to check the boolean attribute
`paused` to be `true` instead. When checking if a runner is `active`, check if `paused` is `false`.

**Planned removal milestone: 15.0 (2022-05-22)**

### Support for SLES 12 SP2

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

Long term service and support (LTSS) for SUSE Linux Enterprise Server (SLES) 12 SP2 [ended on March 31, 2021](https://www.suse.com/lifecycle/). The CA certificates on SP2 include the expired DST root certificate, and it's not getting new CA certificate package updates. We have implemented some [workarounds](https://gitlab.com/gitlab-org/gitlab-omnibus-builder/-/merge_requests/191), but we will not be able to continue to keep the build running properly.

**Planned removal milestone: 15.0 (2022-05-22)**

### Update to the Container Registry group-level API

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

In milestone 15.0, support for the `tags` and `tags_count` parameters will be removed from the Container Registry API that [gets registry repositories from a group](../api/container_registry.md#within-a-group).

The `GET /groups/:id/registry/repositories` endpoint will remain, but won't return any info about tags. To get the info about tags, you can use the existing `GET /registry/repositories/:id` endpoint, which will continue to support the `tags` and `tag_count` options as it does today. The latter must be called once per image repository.

**Planned removal milestone: 15.0 (2022-05-22)**

### Value Stream Analytics filtering calculation change

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

We are changing how the date filter works in Value Stream Analytics. Instead of filtering by the time that the issue or merge request was created, the date filter will filter by the end event time of the given stage. This will result in completely different figures after this change has rolled out.

If you monitor Value Stream Analytics metrics and rely on the date filter, to avoid losing data, you must save the data prior to this change.

**Planned removal milestone: 15.0 (2022-05-22)**

### `Versions` on base `PackageType`

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

As part of the work to create a [Package Registry GraphQL API](https://gitlab.com/groups/gitlab-org/-/epics/6318), the Package group deprecated the `Version` type for the basic `PackageType` type and moved it to [`PackageDetailsType`](https://docs.gitlab.com/ee/api/graphql/reference/index.html#packagedetailstype).

In milestone 15.0, we will completely remove `Version` from `PackageType`.

**Planned removal milestone: 15.0 (2022-05-22)**

### `defaultMergeCommitMessageWithDescription` GraphQL API field

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The GraphQL API field `defaultMergeCommitMessageWithDescription` has been deprecated and will be removed in GitLab 15.0. For projects with a commit message template set, it will ignore the template.

**Planned removal milestone: 15.0 (2022-05-22)**

### `dependency_proxy_for_private_groups` feature flag

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

We added a feature flag because [GitLab-#11582](https://gitlab.com/gitlab-org/gitlab/-/issues/11582) changed how public groups use the Dependency Proxy. Prior to this change, you could use the Dependency Proxy without authentication. The change requires authentication to use the Dependency Proxy.

In milestone 15.0, we will remove the feature flag entirely. Moving forward, you must authenticate when using the Dependency Proxy.

**Planned removal milestone: 15.0 (2022-05-22)**

### `pipelines` field from the `version` field

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

In GraphQL, there are two `pipelines` fields that you can use in a [`PackageDetailsType`](https://docs.gitlab.com/ee/api/graphql/reference/#packagedetailstype) to get the pipelines for package versions:

- The `versions` field's `pipelines` field. This returns all the pipelines associated with all the package's versions, which can pull an unbounded number of objects in memory and create performance concerns.
- The `pipelines` field of a specific `version`. This returns only the pipelines associated with that single package version.

To mitigate possible performance problems, we will remove the `versions` field's `pipelines` field in milestone 15.0. Although you will no longer be able to get all pipelines for all versions of a package, you can still get the pipelines of a single version through the remaining `pipelines` field for that version.

**Planned removal milestone: 15.0 (2022-05-22)**

### `promote-db` command from `gitlab-ctl`

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

In GitLab 14.5, we introduced the command `gitlab-ctl promote` to promote any Geo secondary node to a primary during a failover. This command replaces `gitlab-ctl promote-db` which is used to promote database nodes in multi-node Geo secondary sites. `gitlab-ctl promote-db` will continue to function as-is and be available until GitLab 15.0. We recommend that Geo customers begin testing the new `gitlab-ctl promote` command in their staging environments and incorporating the new command in their failover procedures.

**Planned removal milestone: 15.0 (2022-05-22)**

### `promote-to-primary-node` command from `gitlab-ctl`

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

In GitLab 14.5, we introduced the command `gitlab-ctl promote` to promote any Geo secondary node to a primary during a failover. This command replaces `gitlab-ctl promote-to-primary-node` which was only usable for single-node Geo sites. `gitlab-ctl promote-to-primary-node` will continue to function as-is and be available until GitLab 15.0. We recommend that Geo customers begin testing the new `gitlab-ctl promote` command in their staging environments and incorporating the new command in their failover procedures.

**Planned removal milestone: 15.0 (2022-05-22)**

### openSUSE Leap 15.2 packages

Distribution support and security updates for openSUSE Leap 15.2 are [ending December 2021](https://en.opensuse.org/Lifetime#openSUSE_Leap).

Starting in 14.5 we are providing packages for openSUSE Leap 15.3, and will stop providing packages for openSUSE Leap 15.2 in the 14.8 milestone.

**Planned removal milestone: 14.8 (2022-02-22)**

## 14.6

### API: `stale` status returned instead of `offline` or `not_connected`

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

A breaking change will occur for the Runner [API](https://docs.gitlab.com/ee/api/runners.html#runners-api) endpoints in 15.0.

Instead of the GitLab Runner API endpoints returning `offline` and `not_connected` for runners that have not contacted the GitLab instance in the past three months, the API endpoints will return the `stale` value, which was introduced in 14.6.

**Planned removal milestone: 15.0 (2022-05-22)**

### CI/CD job name length limit

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

In GitLab 15.0 we are going to limit the number of characters in CI/CD job names to 255. Any pipeline with job names that exceed the 255 character limit will stop working after the 15.0 release.

**Planned removal milestone: 15.0 (2022-05-22)**

### Legacy approval status names from License Compliance API

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

We deprecated legacy names for approval status of license policy (blacklisted, approved) in the `managed_licenses` API but they are still used in our API queries and responses. They will be removed in 15.0.

If you are using our License Compliance API you should stop using the `approved` and `blacklisted` query parameters, they are now `allowed` and `denied`. In 15.0 the responses will also stop using `approved` and `blacklisted` so you need to adjust any of your custom tools to use the old and new values so they do not break with the 15.0 release.

**Planned removal milestone: 15.0 (2022-05-22)**

### Runner status `not_connected` API value

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The GitLab Runner REST and GraphQL [API](https://docs.gitlab.com/ee/api/runners.html#runners-api) endpoints
will return `never_contacted` instead of `not_connected` as the status values in 15.0.

Runners that have never contacted the GitLab instance will also return `stale` if created more than 3 months ago.

**Planned removal milestone: 15.0 (2022-05-22)**

### `pipelines` fields in the Package GraphQL types

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

As part of the work to create a [Package Registry GraphQL API](https://gitlab.com/groups/gitlab-org/-/epics/6318), the Package group deprecated the `pipelines` fields in all Package-related GraphQL types. As of GitLab 14.6, the `pipelines` field is deprecated in [`Package`](https://docs.gitlab.com/ee/api/graphql/reference/index.html#package) and [`PackageDetailsType`](https://docs.gitlab.com/ee/api/graphql/reference/index.html#packagedetailstype) due to scalability and performance concerns.

In milestone 15.0, we will completely remove `pipelines` from `Package` and `PackageDetailsType`. You can follow and contribute to work on a replacement in the epic [GitLab-#7214](https://gitlab.com/groups/gitlab-org/-/epics/7214).

**Planned removal milestone: 15.0 (2022-05-22)**

### `type` and `types` keyword in CI/CD configuration

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The `type` and `types` CI/CD keywords will be removed in GitLab 15.0. Pipelines that use these keywords will stop working, so you must switch to `stage` and `stages`, which have the same behavior.

**Planned removal milestone: 15.0 (2022-05-22)**

### apiFuzzingCiConfigurationCreate GraphQL mutation

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The API Fuzzing configuration snippet is now being generated client-side and does not require an
API request anymore. We are therefore deprecating the `apiFuzzingCiConfigurationCreate` mutation
which isn't being used in GitLab anymore.

**Planned removal milestone: 15.0 (2022-05-22)**

### bundler-audit Dependency Scanning tool

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

As of 14.6 bundler-audit is being deprecated from Dependency Scanning. It will continue to be in our CI/CD template while deprecated. We are removing bundler-audit from Dependency Scanning on May 22, 2022 in 15.0. After this removal Ruby scanning functionality will not be affected as it is still being covered by Gemnasium.

If you have explicitly excluded bundler-audit using DS_EXCLUDED_ANALYZERS you will need to clean up (remove the reference) in 15.0. If you have customized your pipeline's Dependency Scanning configuration, for example to edit the `bundler-audit-dependency_scanning` job, you will want to switch to gemnasium-dependency_scanning before removal in 15.0, to prevent your pipeline from failing. If you have not used the DS_EXCLUDED_ANALYZERS to reference bundler-audit, or customized your template specifically for bundler-audit, you will not need to take action.

**Planned removal milestone: 15.0 (2022-05-22)**

## 14.7

### Container scanning schemas below 14.0.0

[Container scanning report schemas](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/releases)
versions earlier than 14.0.0 will no longer be supported in GitLab 15.0. Reports that do not pass validation
against the schema version declared in the report will also no longer be supported in GitLab 15.0.

Third-party tools that [integrate with GitLab by outputting a container scanning security report](https://docs.gitlab.com/ee/development/integrations/secure.html#report)
as a pipeline job artifact are affected. You must ensure that all output reports adhere to the correct schema with a minimum version of 14.0.0. Reports with a lower version or that fail to validate against the declared schema version will not be processed, and vulnerability findings will not display in MRs, pipelines, or Vulnerability Reports.

To help with the transition, from GitLab 14.10, non-compliant reports will display a
[warning](https://gitlab.com/gitlab-org/gitlab/-/issues/335789#note_672853791)
in the Vulnerability Report.

**Planned removal milestone: 15.0 (2022-05-22)**

### Coverage guided fuzzing schemas below 14.0.0

[Coverage guided fuzzing report schemas](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/releases)
below version 14.0.0 will no longer be supported in GitLab 15.0. Reports that do not pass validation
against the schema version declared in the report will also no longer be supported in GitLab 15.0.

Third-party tools that [integrate with GitLab by outputting a coverage guided fuzzing security report](https://docs.gitlab.com/ee/development/integrations/secure.html#report)
as a pipeline job artifact are affected. You must ensure that all output reports adhere to the correct
schema with a minimum version of 14.0.0. Any reports with a lower version or that fail to validate
against the declared schema version will not be processed, and vulnerability
findings will not display in MRs, pipelines, or Vulnerability Reports.

To help with the transition, from GitLab 14.10, non-compliant reports will display a
[warning](https://gitlab.com/gitlab-org/gitlab/-/issues/335789#note_672853791)
in the Vulnerability Report.

**Planned removal milestone: 15.0 (2022-05-22)**

### DAST schemas below 14.0.0

[DAST report schemas](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/releases)
versions earlier than 14.0.0 will no longer be supported in GitLab 15.0. Reports that do not pass validation
against the schema version declared in the report will also no longer be supported as of GitLab 15.0.

Third-party tools that [integrate with GitLab by outputting a DAST security report](https://docs.gitlab.com/ee/development/integrations/secure.html#report)
as a pipeline job artifact are affected. You must ensure that all output reports adhere to the correct
schema with a minimum version of 14.0.0. Reports with a lower version or that fail to validate
against the declared schema version will not be processed, and vulnerability
findings will not display in MRs, pipelines, or Vulnerability Reports.

To help with the transition, from GitLab 14.10, non-compliant reports will cause a
[warning to be displayed](https://gitlab.com/gitlab-org/gitlab/-/issues/335789#note_672853791)
in the Vulnerability Report.

**Planned removal milestone: 15.0 (2022-05-22)**

### Dependency scanning schemas below 14.0.0

[Dependency scanning report schemas](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/releases)
versions earlier than 14.0.0 will no longer be supported in GitLab 15.0. Reports that do not pass validation
against the schema version declared in the report will also no longer be supported as of GitLab 15.0.

Third-party tools that [integrate with GitLab by outputting a Dependency scanning security report](https://docs.gitlab.com/ee/development/integrations/secure.html#report)
as a pipeline job artifact are affected. You must ensure that all output reports adhere to the correct
schema with a minimum version of 14.0.0. Reports with a lower version or that fail to validate
against the declared schema version will not be processed, and vulnerability
findings will not display in MRs, pipelines, or Vulnerability Reports.

To help with the transition, from GitLab 14.10, non-compliant reports will cause a
[warning to be displayed](https://gitlab.com/gitlab-org/gitlab/-/issues/335789#note_672853791)
in the Vulnerability Report.

**Planned removal milestone: 15.0 (2022-05-22)**

### Enforced validation of security report schemas

[Security report schemas](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/releases)
versions earlier than 14.0.0 will no longer be supported in GitLab 15.0. Reports that do not pass validation
against the schema version declared in the report will also no longer be supported in GitLab 15.0.

Security tools that [integrate with GitLab by outputting security reports](https://docs.gitlab.com/ee/development/integrations/secure.html#report)
as pipeline job artifacts are affected. You must ensure that all output reports adhere to the correct
schema with a minimum version of 14.0.0. Reports with a lower version or that fail to validate
against the declared schema version will not be processed, and vulnerability
findings will not display in MRs, pipelines, or Vulnerability Reports.

To help with the transition, from GitLab 14.10, non-compliant reports will display a
[warning](https://gitlab.com/gitlab-org/gitlab/-/issues/335789#note_672853791)
in the Vulnerability Report.

**Planned removal milestone: 15.0 (2022-05-22)**

### Godep support in License Compliance

The Godep dependency manager for Golang was deprecated in 2020 by Go and
has been replaced with Go modules.
To reduce our maintenance cost we are deprecating License Compliance for Godep projects as of 14.7
and will remove it in GitLab 15.0

**Planned removal milestone: 15.0 (2022-05-22)**

### Logging in GitLab

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The logging features in GitLab allow users to install the ELK stack (Elasticsearch, Logstash, and Kibana) to aggregate and manage application logs. Users can search for relevant logs in GitLab. However, since deprecating certificate-based integration with Kubernetes clusters and GitLab Managed Apps, we don't have a recommended solution for logging within GitLab. For more information, you can follow the issue for [integrating Opstrace with GitLab](https://gitlab.com/groups/gitlab-org/-/epics/6976).

**Planned removal milestone: 15.0 (2022-05-22)**

### Monitor performance metrics through Prometheus

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

By displaying data stored in a Prometheus instance, GitLab allows users to view performance metrics. GitLab also displays visualizations of these metrics in dashboards. The user can connect to a previously-configured external Prometheus instance, or set up Prometheus as a GitLab Managed App.
However, since certificate-based integration with Kubernetes clusters is deprecated in GitLab, the metrics functionality in GitLab that relies on Prometheus is also deprecated. This includes the metrics visualizations in dashboards. GitLab is working to develop a single user experience based on [Opstrace](https://about.gitlab.com/press/releases/2021-12-14-gitlab-acquires-opstrace-to-expand-its-devops-platform-with-open-source-observability-solution.html). An [issue exists](https://gitlab.com/groups/gitlab-org/-/epics/6976) for you to follow work on the Opstrace integration.

**Planned removal milestone: 15.0 (2022-05-22)**

### Pseudonymizer

The Pseudonymizer feature is generally unused,
can cause production issues with large databases,
and can interfere with object storage development.
It is now considered deprecated, and will be removed in GitLab 15.0.

**Planned removal milestone: 15.0 (2022-05-22)**

### SAST schemas below 14.0.0

[SAST report schemas](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/releases)
versions earlier than 14.0.0 will no longer be supported in GitLab 15.0. Reports that do not pass validation
against the schema version declared in the report will also no longer be supported as of GitLab 15.0.

Third-party tools that [integrate with GitLab by outputting a SAST security report](https://docs.gitlab.com/ee/development/integrations/secure.html#report)
as a pipeline job artifact are affected. You must ensure that all output reports adhere to the correct
schema with a minimum version of 14.0.0. Reports with a lower version or that fail to validate
against the declared schema version will not be processed, and vulnerability
findings will not display in MRs, pipelines, or Vulnerability Reports.

To help with the transition, from GitLab 14.10, non-compliant reports will display a
[warning](https://gitlab.com/gitlab-org/gitlab/-/issues/335789#note_672853791)
in the Vulnerability Report.

**Planned removal milestone: 15.0 (2022-05-22)**

### Secret detection schemas below 14.0.0

[Secret detection report schemas](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/releases)
versions earlier than 14.0.0 will no longer be supported in GitLab 15.0. Reports that do not pass validation
against the schema version declared in the report will also no longer be supported as of GitLab 15.0.

Third-party tools that [integrate with GitLab by outputting a Secret detection security report](https://docs.gitlab.com/ee/development/integrations/secure.html#report)
as a pipeline job artifact are affected. You must ensure that all output reports adhere to the correct
schema with a minimum version of 14.0.0. Reports with a lower version or that fail to validate
against the declared schema version will not be processed, and vulnerability
findings will not display in MRs, pipelines, or Vulnerability Reports.

To help with the transition, from GitLab 14.10, non-compliant reports will display a
[warning](https://gitlab.com/gitlab-org/gitlab/-/issues/335789#note_672853791)
in the Vulnerability Report.

**Planned removal milestone: 15.0 (2022-05-22)**

### Sidekiq metrics and health checks configuration

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

Exporting Sidekiq metrics and health checks using a single process and port is deprecated.
Support will be removed in 15.0.

We have updated Sidekiq to export [metrics and health checks from two separate processes](https://gitlab.com/groups/gitlab-org/-/epics/6409)
to improve stability and availability and prevent data loss in edge cases.
As those are two separate servers, a configuration change will be required in 15.0
to explicitly set separate ports for metrics and health-checks.
The newly introduced settings for `sidekiq['health_checks_*']`
should always be set in `gitlab.rb`.
For more information, check the documentation for [configuring Sidekiq](https://docs.gitlab.com/ee/administration/sidekiq.html).

These changes also require updates in either Prometheus to scrape the new endpoint or k8s health-checks to target the new
health-check port to work properly, otherwise either metrics or health-checks will disappear.

For the deprecation period those settings are optional
and GitLab will default the Sidekiq health-checks port to the same port as `sidekiq_exporter`
and only run one server (not changing the current behaviour).
Only if they are both set and a different port is provided, a separate metrics server will spin up
to serve the Sidekiq metrics, similar to the way Sidekiq will behave in 15.0.

**Planned removal milestone: 15.0 (2022-05-22)**

### Static Site Editor

The Static Site Editor will no longer be available starting in GitLab 15.0. Improvements to the Markdown editing experience across GitLab will deliver smiliar benefit but with a wider reach. Incoming requests to the Static Site Editor will be redirected to the Web IDE. Current users of the Static Site Editor can view the [documentation](https://docs.gitlab.com/ee/user/project/static_site_editor/) for more information, including how to remove the configuration files from existing projects.

**Planned removal milestone: 15.0 (2022-05-22)**

### Tracing in GitLab

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

Tracing in GitLab is an integration with Jaeger, an open-source end-to-end distributed tracing system. GitLab users can navigate to their Jaeger instance to gain insight into the performance of a deployed application, tracking each function or microservice that handles a given request. Tracing in GitLab is deprecated in GitLab 14.7, and scheduled for removal in 15.0. To track work on a possible replacement, see the issue for [Opstrace integration with GitLab](https://gitlab.com/groups/gitlab-org/-/epics/6976).

**Planned removal milestone: 15.0 (2022-05-22)**

### `artifacts:report:cobertura` keyword

Currently, test coverage visualizations in GitLab only support Cobertura reports. Starting 15.0, the
`artifacts:report:cobertura` keyword will be replaced by
[`artifacts:reports:coverage_report`](https://gitlab.com/gitlab-org/gitlab/-/issues/344533). Cobertura will be the
only supported report file in 15.0, but this is the first step towards GitLab supporting other report types.

**Planned removal milestone: 15.0 (2022-05-22)**

### merged_by API field

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The `merged_by` field in the [merge request API](https://docs.gitlab.com/ee/api/merge_requests.html#list-merge-requests) is being deprecated and will be removed in GitLab 15.0. This field is being replaced with the `merge_user` field (already present in GraphQL) which more correctly identifies who merged a merge request when performing actions (merge when pipeline succeeds, add to merge train) other than a simple merge.

**Planned removal milestone: 15.0 (2022-05-22)**

## 14.8

### Container Network and Host Security

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

All functionality related to GitLab's Container Network Security and Container Host Security categories is deprecated in GitLab 14.8 and scheduled for removal in GitLab 15.0. Users who need a replacement for this functionality are encouraged to evaluate the following open source projects as potential solutions that can be installed and managed outside of GitLab: [AppArmor](https://gitlab.com/apparmor/apparmor), [Cilium](https://github.com/cilium/cilium), [Falco](https://github.com/falcosecurity/falco), [FluentD](https://github.com/fluent/fluentd), [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/). To integrate these technologies into GitLab, add the desired Helm charts into your copy of the [Cluster Management Project Template](https://docs.gitlab.com/ee/user/clusters/management_project_template.html). Deploy these Helm charts in production by calling commands through the GitLab [Secure CI/CD Tunnel](https://docs.gitlab.com/ee/user/clusters/agent/repository.html#run-kubectl-commands-using-the-cicd-tunnel).

As part of this change, the following specific capabilities within GitLab are now deprecated, and are scheduled for removal in GitLab 15.0:

- The **Security & Compliance > Threat Monitoring** page.
- The `Network Policy` security policy type, as found on the **Security & Compliance > Policies** page.
- The ability to manage integrations with the following technologies through GitLab: AppArmor, Cilium, Falco, FluentD, and Pod Security Policies.
- All APIs related to the above functionality.

For additional context, or to provide feedback regarding this change, please reference our open [deprecation issue](https://gitlab.com/groups/gitlab-org/-/epics/7476).

**Planned removal milestone: 15.0 (2022-05-22)**

### Dependency Scanning Python 3.9 and 3.6 image deprecation

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

For those using Dependency Scanning for Python projects, we are deprecating the default `gemnasium-python:2` image which uses Python 3.6 as well as the custom `gemnasium-python:2-python-3.9` image which uses Python 3.9. The new default image as of GitLab 15.0 will be for Python 3.9 as it is a [supported version](https://endoflife.date/python) and 3.6 [is no longer supported](https://endoflife.date/python).

For users using Python 3.9 or 3.9-compatible projects, you should not need to take action and dependency scanning should begin to work in GitLab 15.0. If you wish to test the new container now please run a test pipeline in your project with this container (which will be removed in 15.0). Use the Python 3.9 image:

```yaml
gemnasium-python-dependency_scanning:
  image:
    name: registry.gitlab.com/gitlab-org/security-products/analyzers/gemnasium-python:2-python-3.9
```

For users using Python 3.6, as of GitLab 15.0 you will no longer be able to use the default template for dependency scanning. You will need to switch to use the deprecated `gemnasium-python:2` analyzer image. If you are impacted by this please comment in [this issue](https://gitlab.com/gitlab-org/gitlab/-/issues/351503) so we can extend the removal if needed.

For users using the 3.9 special exception image, you must instead use the default value and no longer override your container. To verify if you are using the 3.9 special exception image, check your `.gitlab-ci.yml` file for the following reference: 

```yaml
gemnasium-python-dependency_scanning:
  image:
    name: registry.gitlab.com/gitlab-org/security-products/analyzers/gemnasium-python:2-python-3.9
```

**Planned removal milestone: 15.0 (2021-05-22)**

### Deprecate Geo Admin UI Routes

In GitLab 13.0, we introduced new project and design replication details routes in the Geo Admin UI. These routes are `/admin/geo/replication/projects` and `/admin/geo/replication/designs`. We kept the legacy routes and redirected them to the new routes. In GitLab 15.0, we will remove support for the legacy routes `/admin/geo/projects` and `/admin/geo/designs`. Please update any bookmarks or scripts that may use the legacy routes.

**Planned removal milestone: 15.0 (2022-05-22)**

### Deprecate custom Geo:db:* Rake tasks

In GitLab 14.8, we are [replacing the `geo:db:*` Rake tasks with built-in tasks](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/77269/diffs) that are now possible after [switching the Geo tracking database to use Rails' 6 support of multiple databases](https://gitlab.com/groups/gitlab-org/-/epics/6458).
The following `geo:db:*` tasks will be replaced with their corresponding `db:*:geo` tasks:

- `geo:db:drop` -> `db:drop:geo`
- `geo:db:create` -> `db:create:geo`
- `geo:db:setup` -> `db:setup:geo`
- `geo:db:migrate` -> `db:migrate:geo`
- `geo:db:rollback` -> `db:rollback:geo`
- `geo:db:version` -> `db:version:geo`
- `geo:db:reset` -> `db:reset:geo`
- `geo:db:seed` -> `db:seed:geo`
- `geo:schema:load:geo` -> `db:schema:load:geo`
- `geo:db:schema:dump` -> `db:schema:dump:geo`
- `geo:db:migrate:up` -> `db:migrate:up:geo`
- `geo:db:migrate:down` -> `db:migrate:down:geo`
- `geo:db:migrate:redo` -> `db:migrate:redo:geo`
- `geo:db:migrate:status` -> `db:migrate:status:geo`
- `geo:db:test:prepare` -> `db:test:prepare:geo`
- `geo:db:test:load` -> `db:test:load:geo`
- `geo:db:test:purge` -> `db:test:purge:geo`

**Planned removal milestone: 15.0 (2022-05-22)**

### Deprecate legacy Gitaly configuration methods

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

Using environment variables `GIT_CONFIG_SYSTEM` and `GIT_CONFIG_GLOBAL` to configure Gitaly is [deprecated](https://gitlab.com/gitlab-org/gitlab/-/issues/352609).
These variables are being replaced with standard [`config.toml` Gitaly configuration](https://docs.gitlab.com/ee/administration/gitaly/reference.html).

GitLab instances that use `GIT_CONFIG_SYSTEM` and `GIT_CONFIG_GLOBAL` to configure Gitaly should switch to configuring using
`config.toml`.

**Planned removal milestone: 15.0 (2022-05-22)**

### Elasticsearch 6.8

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

Elasticsearch 6.8 is deprecated in GitLab 14.8 and scheduled for removal in GitLab 15.0.
Customers using Elasticsearch 6.8 need to upgrade their Elasticsearch version to 7.x prior to upgrading to GitLab 15.0.
We recommend using the latest version of Elasticsearch 7 to benefit from all Elasticsearch improvements.

Elasticsearch 6.8 is also incompatible with Amazon OpenSearch, which we [plan to support in GitLab 15.0](https://gitlab.com/gitlab-org/gitlab/-/issues/327560).

**Planned removal milestone: 15.0 (2022-05-22)**

### External status check API breaking changes

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The [external status check API](https://docs.gitlab.com/ee/api/status_checks.html) was originally implemented to
support pass-by-default requests to mark a status check as passing. Pass-by-default requests are now deprecated.
Specifically, the following are deprecated:

- Requests that do not contain the `status` field.
- Requests that have the `status` field set to `approved`.

Beginning in GitLab 15.0, status checks will only be updated to a passing state if the `status` field is both present
and set to `pass`. Requests that:

- Do not contain the `status` field will be rejected with a `422` error. For more information, see [the relevant issue](https://gitlab.com/gitlab-org/gitlab/-/issues/338827).
- Contain any value other than `pass` will cause the status check to fail. For more information, see [the relevant issue](https://gitlab.com/gitlab-org/gitlab/-/issues/339039).

To align with this change, API calls to list external status checks will also return the value of `pass` rather than
`approved` for status checks that have passed.

**Planned removal milestone: 15.0 (2022-05-22)**

### OAuth tokens without expiration

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

By default, all new applications expire access tokens after 2 hours. In GitLab 14.2 and earlier, OAuth access tokens
had no expiration. In GitLab 15.0, an expiry will be automatically generated for any existing token that does not
already have one.

You should [opt in](https://docs.gitlab.com/ee/integration/oauth_provider.html#expiring-access-tokens) to expiring
tokens before GitLab 15.0 is released:

1. Edit the application.
1. Select **Expire access tokens** to enable them. Tokens must be revoked or they don’t expire.

**Planned removal milestone: 15.0 (2022-05-22)**

### Optional enforcement of PAT expiration

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The feature to disable enforcement of PAT expiration is unusual from a security perspective.
We have become concerned that this unusual feature could create unexpected behavior for users.
Unexpected behavior in a security feature is inherently dangerous, so we have decided to remove this feature.

**Planned removal milestone: 15.0 (2022-05-22)**

### Optional enforcement of SSH expiration

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The feature to disable enforcement of SSH expiration is unusual from a security perspective.
We have become concerned that this unusual feature could create unexpected behavior for users.
Unexpected behavior in a security feature is inherently dangerous, so we have decided to remove this feature.

**Planned removal milestone: 15.0 (2022-05-22)**

### Querying Usage Trends via the `instanceStatisticsMeasurements` GraphQL node

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The `instanceStatisticsMeasurements` GraphQL node has been renamed to `usageTrendsMeasurements` in 13.10 and the old field name has been marked as deprecated. To fix the existing GraphQL queries, replace `instanceStatisticsMeasurements` with `usageTrendsMeasurements`.

**Planned removal milestone: 15.0 (2022-05-22)**

### REST API Runner will not accept `status` filter values of `active` or `paused`

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The GitLab Runner REST endpoints will stop accepting `paused` or `active` as a status value in GitLab 15.0.

A runner's status will only relate to runner contact status, such as: `online`, `offline`.
Status values `paused` or `active` will no longer be accepted and will be replaced by the `paused` query parameter.

When checking for paused runners, API users are advised to specify `paused=true` as the query parameter.
When checking for active runners, specify `paused=false`.

**Planned removal milestone: 15.0 (2022-05-22)**

### REST API endpoint to list group runners no longer accepts `project_type` value for `type` argument

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The `GET /groups/:id/runners?type=project_type` endpoint will be removed in GitLab 15.0. The endpoint always returned an empty collection.

**Planned removal milestone: 15.0 (2022-05-22)**

### REST and GraphQL API Runner usage of `active` replaced by `paused`

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

Occurrences of the `active` identifier in the GitLab Runner REST and GraphQL API endpoints will be
renamed to `paused` in GitLab 15.0, namely:

- GraphQL API:
  - the `CiRunner` property;
  - the `RunnerUpdateInput` input type for the `runnerUpdate` mutation;
  - the `runners` and `Group.runners` queries.
- REST API:
  - endpoints taking or returning `active` properties, such as:
    - `GET /runners`
    - `GET /runners/all`
    - `GET /runners/:id` / `PUT /runners/:id`
    - `PUT --form "active=false" /runners/:runner_id`
    - `GET /projects/:id/runners` / `POST /projects/:id/runners`
    - `GET /groups/:id/runners`

The 15.0 release of the GitLab Runner will start using the `paused` property when registering runners, and therefore
will only be compatible with GitLab 15.0 and later. Until 15.0, GitLab will accept the deprecated `active` flag from
existing runners.

**Planned removal milestone: 15.0 (2022-05-22)**

### Reminder: support for NFS repository storage

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

As [announced](https://about.gitlab.com/releases/2021/06/22/gitlab-14-0-released/#nfs-for-git-repository-storage-deprecated) at the
release of GitLab 14.0, technical support for NFS storage for Git repositories is being removed. Please see our official
[Statement of Support](https://about.gitlab.com/support/statement-of-support.html#gitaly-and-nfs) for additional information.

We encourage customers currently using NFS for Git repositories to plan their migration by reviewing our documentation on
[migrating to Gitaly Cluster](https://docs.gitlab.com/ee/administration/gitaly/#migrating-to-gitaly-cluster).

Gitaly Cluster offers tremendous benefits for our customers such as:

- [Variable replication factors](https://docs.gitlab.com/ee/administration/gitaly/praefect.html#configure-replication-factor)
- [Strong consistency](https://docs.gitlab.com/ee/administration/gitaly/#strong-consistency)
- [Distributed read capabilities](https://docs.gitlab.com/ee/administration/gitaly/#distributed-reads)

**Planned removal milestone: 15.0 (2022-05-22)**

### Request profiling

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

[Request profiling](https://docs.gitlab.com/ee/administration/monitoring/performance/request_profiling.html) is deprecated in GitLab 14.8 and scheduled for removal in GitLab 15.0.

We're working on [consolidating our profiling tools](https://gitlab.com/groups/gitlab-org/-/epics/7327) and making them more easily accessible.
We [evaluated](https://gitlab.com/gitlab-org/gitlab/-/issues/350152) the use of this feature and we found that it is not widely used.
It also depends on a few third-party gems that are not actively maintained anymore, have not been updated for the latest version of Ruby, or crash frequently when profiling heavy page loads.

For more information, check the [summary section of the deprecation issue](https://gitlab.com/gitlab-org/gitlab/-/issues/352488#deprecation-summary).

**Planned removal milestone: 15.0 (2022-05-22)**

### Required pipeline configurations in Premium tier

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The [required pipeline configuration](https://docs.gitlab.com/ee/user/admin_area/settings/continuous_integration.html#required-pipeline-configuration) feature is deprecated in GitLab 14.8 for Premium customers and is scheduled for removal in GitLab 15.0. This feature is not deprecated for GitLab Ultimate customers.

This change to move the feature to GitLab's Ultimate tier is intended to help our features better align with our [pricing philosophy](https://about.gitlab.com/company/pricing/#three-tiers) as we see demand for this feature originating primarily from executives.

This change will also help GitLab remain consistent in its tiering strategy with the other related Ultimate-tier features of:
[Security policies](https://docs.gitlab.com/ee/user/application_security/policies/) and [compliance framework pipelines](https://docs.gitlab.com/ee/user/project/settings/index.html#compliance-pipeline-configuration).

**Planned removal milestone: 15.0 (2022-05-22)**

### Retire-JS Dependency Scanning tool

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

As of 14.8 the retire.js job is being deprecated from Dependency Scanning. It will continue to be included in our CI/CD template while deprecated. We are removing retire.js from Dependency Scanning on May 22, 2022 in GitLab 15.0. JavaScript scanning functionality will not be affected as it is still being covered by Gemnasium.

If you have explicitly excluded retire.js using DS_EXCLUDED_ANALYZERS you will need to clean up (remove the reference) in 15.0. If you have customized your pipeline's Dependency Scanning configuration related to the `retire-js-dependency_scanning` job you will want to switch to gemnasium-dependency_scanning before the removal in 15.0, to prevent your pipeline from failing. If you have not used the DS_EXCLUDED_ANALYZERS to reference retire.js, or customized your template specifically for retire.js, you will not need to take action.

**Planned removal milestone: 15.0 (2022-05-22)**

### Support for gRPC-aware proxy deployed between Gitaly and rest of GitLab

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

Although not recommended or documented, it was possible to deploy a gRPC-aware proxy between Gitaly and
the rest of GitLab. For example, NGINX and Envoy. The ability to deploy a gRPC-aware proxy is
[deprecated](https://gitlab.com/gitlab-org/gitlab/-/issues/352517). If you currently use a gRPC-aware proxy for
Gitaly connections, you should change your proxy configuration to use TCP or TLS proxying (OSI layer 4) instead.

Gitaly Cluster became incompatible with gRPC-aware proxies in GitLab 13.12. Now all GitLab installations will be incompatible with
gRPC-aware proxies, even without Gitaly Cluster.

By sending some of our internal RPC traffic through a custom protocol (instead of gRPC) we
increase throughput and reduce Go garbage collection latency. For more information, see
the [relevant epic](https://gitlab.com/groups/gitlab-com/gl-infra/-/epics/463).

**Planned removal milestone: 15.0 (2022-05-22)**

### Test coverage project CI/CD setting

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

To simplify setting a test coverage pattern, in GitLab 15.0 the
[project setting for test coverage parsing](https://docs.gitlab.com/ee/ci/pipelines/settings.html#add-test-coverage-results-to-a-merge-request-deprecated)
is being removed.

Instead, using the project’s `.gitlab-ci.yml`, provide a regular expression with the `coverage` keyword to set
testing coverage results in merge requests.

**Planned removal milestone: 15.0 (2022-05-22)**

### Vulnerability Check

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The vulnerability check feature is deprecated in GitLab 14.8 and scheduled for removal in GitLab 15.0. We encourage you to migrate to the new security approvals feature instead. You can do so by navigating to **Security & Compliance > Policies** and creating a new Scan Result Policy.

The new security approvals feature is similar to vulnerability check. For example, both can require approvals for MRs that contain security vulnerabilities. However, security approvals improve the previous experience in several ways:

- Users can choose who is allowed to edit security approval rules. An independent security or compliance team can therefore manage rules in a way that prevents development project maintainers from modifying the rules.
- Multiple rules can be created and chained together to allow for filtering on different severity thresholds for each scanner type.
- A two-step approval process can be enforced for any desired changes to security approval rules.
- A single set of security policies can be applied to multiple development projects to allow for ease in maintaining a single, centralized ruleset.

**Planned removal milestone: 15.0 (2022-05-22)**

### `fixup!` commit messages setting draft status of associated Merge Request

The use of `fixup!` as a commit message to trigger draft status
of the associated Merge Request is generally unused, and can cause
confusion with other uses of the term. "Draft" is the preferred
and supported trigger for triggering draft status from commit
messages, as part of our streamlining of the feature.
Support for `fixup!` is now considered deprecated, and will be
removed in GitLab 15.0.

**Planned removal milestone: 15.0 (2022-06-22)**

### `started` iterations API field

WARNING:
This feature will be changed or removed in 15.0
as a [breaking change](https://docs.gitlab.com/ee/development/contributing/#breaking-changes).
Before updating GitLab, review the details carefully to determine if you need to make any
changes to your code, settings, or workflow.

The `started` field in the [iterations API](https://docs.gitlab.com/ee/api/iterations.html#list-project-iterations) is being deprecated and will be removed in GitLab 15.0. This field is being replaced with the `current` field (already available) which aligns with the naming for other time-based entities, such as milestones.

**Planned removal milestone: 15.0 (2022-05-22)**
