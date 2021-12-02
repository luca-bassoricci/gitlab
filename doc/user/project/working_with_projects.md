---
stage: Manage
group: Workspace
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments"
---

# Working with projects **(FREE)**

Most work in GitLab is done in a [project](../../user/project/index.md). Files and
code are saved in projects, and most features are in the scope of projects.

## Explore projects

Use **Explore projects** to explore projects on GitLab. 

To explore projects:

1. On the top bar, select **Menu > Project**.
1. Select **Explore projects**.

GitLab displays a list of projects, sorted by last updated date. 

- To view projects with the most [stars](#star-a-project), select **Most stars**. 
- To view projects with the largest number of comments in the past month, select **Trending**.

NOTE:
By default, `/explore` is visible to unauthenticated users. If the
[**Public** visibility level](../admin_area/settings/visibility_and_access_controls.md#restrict-visibility-levels)
is restricted, `/explore` is visible only to signed-in users.

## Create a project

To create a project in GitLab:

1. On the top bar, select **Menu > Project**. 
1. Select **Create new project**.
1. On the **New project** page, choose if you want to:
   - Create a [blank project](#create-a-blank-project).
   - Create a project with a:
      - [built-in template](#create-a-project-with-a-built-in-template) 
      - [custom template](#create-a-project-with-a-custom-template)  
      - [enterprise template](#create-a-project-with-the-hipaa-audit-protocol-template)
   - If enabled in your GitLab instance, [import a project](#import-a-project) from a different repository.
     Contact your GitLab administrator if this is unavailable.
   - [Connect an external repository to GitLab CI/CD](../../ci/ci_cd_for_external_repos/index.md).

NOTE:
For a list of words that can't be used as project names see
[reserved project and group names](../../user/reserved_names.md).

## Create a blank project

To create a blank project:

1. On the top bar, select **Menu > Project**. 
1. Select **Create new project**.
1. Select **Create blank project**.
1. Enter the project details:
   - The name of your project in the **Project name** field. You can use spaces, hyphens, 
     underscores, and emoji. You cannot use special characters. After you enter the name, 
     the **Project slug** populates.
   - The path to your project in the **Project slug** field. The GitLab instance uses the 
     slug as the URL path to the project. To change the slug, first enter the project name, 
     then change the slug. 
   - The description of your project's dashboard in the **Project description (optional)** field.
   - To modify the project's [viewing and access rights](../../public_access/public_access.md) for users, change the **Visibility Level**.
   - To create README file so that the Git repository is initialized, has a default branch, and
     can be cloned, select **Initialize repository with a README**.
   - To analyze the source code in the project for known security vulnerabilities, select **Enable Static Application Security Testing (SAST)**.   
1. Select **Create project**.

## Create a project with a built-in template

A built-in project template populates a new project with files to get you started.
Built-in templates are sourced from the following groups:

- [`project-templates`](https://gitlab.com/gitlab-org/project-templates)
- [`pages`](https://gitlab.com/pages)

Anyone can contribute a built-in template by following [these steps](https://about.gitlab.com/community/contribute/project-templates/).

To create a project with a built-in template:

1. On the top bar, select **Menu > Project**.
1. Select **Create new project**.
1. Select **Create from template**.
1. Select the **Built-in** tab.
1. From the list of available templates:
   - To view a preview of the template, select **Preview**.
   - To use a template for the project, select **Use template**.
1. Enter the project details:
   - In the **Project name** field, enter the name of your project. You can use spaces, hyphens, 
     underscores, and emoji. You cannot use special characters. After you enter the name, 
     the **Project slug** populates.
   - In the **Project slug** field, enter the path to your project. The GitLab instance uses the 
     slug as the URL path to the project. To change the slug, first enter the project name, 
     then change the slug. 
   - In the **Project description (optional)** field, enter the description of your project's dashboard.
   - To modify the project's [viewing and access rights](../../public_access/public_access.md) for users, 
      change the **Visibility Level**.
1. Select **Create project**.      

## Create a project with a custom template (**PREMIUM**)

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/6860) in [GitLab Premium](https://about.gitlab.com/pricing/) 11.2.

GitLab configures custom project templates that are available at:

- The [instance-level](../../user/admin_area/custom_project_templates.md)
- The [group-level](../../user/group/custom_project_templates.md)

1. On the top bar, select **Menu > Project**. 
1. Select **Create new project**.
1. Select **Create from template**.
1. Select the **Instance** or **Group** tab.
1. From the list of templates:
   - To view a preview of the template, select **Preview**.
   - To use a template for the project, select **Use template**.
1. Enter the project details:
   - In the **Project name** field, enter the name of your project. You can use spaces, hyphens, 
     underscores, and emoji. You cannot use special characters. After you enter the name, 
     the **Project slug** populates.
   - In the **Project slug** field, enter the path to your project. The GitLab instance uses the 
     slug as the URL path to the project. To change the slug, first enter the project name, 
     then change the slug. 
   - The description of your project's dashboard in the **Project description (optional)** field.
   - To modify the project's [viewing and access rights](../../public_access/public_access.md) for users, 
      change the **Visibility Level**.
1. Select **Create project**.

## Create a project with the HIPAA Audit Protocol template **(ULTIMATE)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/13756) in GitLab 12.10

The HIPAA Audit Protocol template contains issues for each audit inquiry in the 
HIPAA Audit Protocol, published by the U.S Department of Health and Human Service.

To create a project with the HIPAA Audit Protocol template:

1. On the top bar, select **Menu > Project**.
1. Select **Create new project**.
1. Select **Create from template**.
1. Select the **Built-in** tab.
1. Locate the **HIPAA Audit Protocol** template:
   - To view a preview of the template, select **Preview**.
   - To use the template for the project, select **Use template**.
1. Enter the project details:
   - In the **Project name** field, enter the name of your project. You can use spaces, hyphens, 
     underscores, and emoji. You cannot use special characters. After you enter the name, 
     the **Project slug** populates.
   - In the **Project slug** field, enter the path to your project. The GitLab instance uses the 
     slug as the URL path to the project. To change the slug, first enter the project name, 
     then change the slug. 
   - In the **Project description (optional)** field, enter the description of your project's dashboard.
   - To modify the project's [viewing and access rights](../../public_access/public_access.md) for users, 
      change the **Visibility Level**.
1. Select **Create project**.

## Push to create a new project

> [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/26388) in GitLab 10.5.

When you create a new repository locally, you don't have to sign in to the GitLab
interface to create a project and
[clone its repository](../../gitlab-basics/start-using-git.md#clone-a-repository).
You can directly push your new repository to GitLab, which creates your new project
without leaving your terminal.

To push a new project:

1. Identify the [namespace](../group/index.md#namespaces) you want to add the new
   project to, as you need this information in a future step. To determine if you have
   permission to create new projects in a namespace, view the group's page in a
   web browser and confirm the page displays a **New project** button.

   NOTE:
   As project creation permissions can have many factors, contact your
   GitLab administrator if you're unsure.

1. If you want to push using SSH, ensure you have [created a SSH key](../../ssh/index.md) and
   [added it to your GitLab account](../../ssh/index.md#add-an-ssh-key-to-your-gitlab-account).
1. Push with one of the following methods. Replace `gitlab.example.com` with the
   domain name of the machine that hosts your Git repository, `namespace` with the name of
   your namespace, and `myproject` with the name of your new project:
   - To push with SSH: `git push --set-upstream git@gitlab.example.com:namespace/myproject.git master`
   - To push with HTTPS: `git push --set-upstream https://gitlab.example.com/namespace/myproject.git master`
   Optional: to export existing repository tags, append the `--tags` flag to your `git push` command.
1. When the push completes, GitLab displays a message:

   ```plaintext
   remote: The private project namespace/myproject was created.
   ```

1. (Optional) To configure the remote, alter the command
   `git remote add origin https://gitlab.example.com/namespace/myproject.git`
   to match your namespace and project names.

You can view your new project at `https://gitlab.example.com/namespace/myproject`.
Your project's visibility is set to **Private** by default, but you can change it
in your [project's settings](../../public_access/public_access.md#change-project-visibility)).

This feature does not work for project paths that have previously been in use and
[renamed](settings/index.md#renaming-a-repository). A redirect exists over the previous project path
that causes push attempts to redirect requests to the renamed project location, instead of creating
a new project. To create a new project, use the [Web UI](#create-a-project) or the
[Projects API](../../api/projects.md#create-project).

## Import a project

If enabled on your GitLab instance, you can [Import a project](../../user/project/import/index.md) from a 
different repository. Contact your GitLab administrator if this is unavailable.

## Connect an external repository to GitLab CI/CD **(PREMIUM)**

Instead of moving your entire project to GitLab, you can 
[connect your external repository](../../ci/ci_cd_for_external_repos/index.md) to get the benefits 
of GitLab CI/CD.

## Fork a project

A fork is a copy of an original repository that you put in another namespace.
You can fork a project to experiment and apply changes, without affecting 
the original project.

To fork a project in GitLab, [complete these steps](repository/forking_workflow.md#creating-a-fork).

## Star a project

You can star a project to make it easier to find projects you frequently use.
The number of stars a project has can indicate its popularity.

To star a project:

1. On the top bar, select **Menu > Project**.
1. Select **Your projects** or **Explore projects**.
1. Select a project.
1. In the upper right corner of the page, select **Star**.

## View starred projects

1. On the top bar, select **Menu > Project**.
1. Select **Starred Projects**.
1. GitLab displays information about your starred projects, including:

   - Project description, including name, description, and icon
   - Number of times this project has been starred
   - Number of times this project has been forked
   - Number of open merge requests
   - Number of open issues

## Delete a project

To delete a project, first navigate to the home page for that project.

1. On the top bar, select **Menu > Project**.
1. Select **Your projects** or **Explore projects**.
1. Select a project.
1. Select **Settings > General**.
1. Expand the **Advanced** section.
1. Scroll down to the **Delete project** section.
1. Select **Delete project**
1. Confirm this action by completing the field.

Projects in personal namespaces are deleted immediately on request. For information on delayed deletion of projects in a group, please see [Enable delayed project removal](../group/index.md#enable-delayed-project-removal).

## Project settings

Set the project's visibility level and the access levels to its various pages
and perform actions like archiving, renaming or transferring a project.

Read through the documentation on [project settings](settings/index.md).

## Project activity

To view the activity of a project:

1. On the top bar, select **Menu > Project**.
1. Select **Your projects** or **Explore projects**.
1. Select a project.
1. On the left sidebar, select **Project information > Activity**.
1. Select a tab to view the project activity.

### Leave a project

If you leave a project you are no longer a project
member, and cannot contribute.

The **Leave project** option only displays on the project's dashboard
when a project is part of a group under a
[group namespace](../group/index.md#namespaces).

## Use your project as a Go package

Any project can be used as a Go package. GitLab responds correctly to `go get`
and `godoc.org` discovery requests, including the
[`go-import`](https://golang.org/cmd/go/#hdr-Remote_import_paths) and
[`go-source`](https://github.com/golang/gddo/wiki/Source-Code-Links) meta tags.

Private projects, including projects in subgroups, can be used as a Go package,
but may require configuration to work correctly. GitLab responds correctly
to `go get` discovery requests for projects that *are not* in subgroups,
regardless of authentication or authorization.
[Authentication](#authenticate-go-requests) is required to use a private project
in a subgroup as a Go package. Otherwise, GitLab truncates the path for
private projects in subgroups to the first two segments, causing `go get` to
fail.

GitLab implements its own Go proxy. This feature must be enabled by an
administrator and requires additional configuration. See [GitLab Go
Proxy](../packages/go_proxy/index.md).

### Disable Go module features for private projects

In Go 1.12 and later, Go queries module proxies and checksum databases in the
process of [fetching a
module](../../development/go_guide/dependencies.md#fetching). This can be
selectively disabled with `GOPRIVATE` (disable both),
[`GONOPROXY`](../../development/go_guide/dependencies.md#proxies) (disable proxy
queries), and [`GONOSUMDB`](../../development/go_guide/dependencies.md#fetching)
(disable checksum queries).

`GOPRIVATE`, `GONOPROXY`, and `GONOSUMDB` are comma-separated lists of Go
modules and Go module prefixes. For example,
`GOPRIVATE=gitlab.example.com/my/private/project` disables queries for that
one project, but `GOPRIVATE=gitlab.example.com` disables queries for *all*
projects on GitLab.com. Go does not query module proxies if the module name or a
prefix of it appears in `GOPRIVATE` or `GONOPROXY`. Go does not query checksum
databases if the module name or a prefix of it appears in `GONOPRIVATE` or
`GONOSUMDB`.

### Authenticate Go requests

To authenticate requests to private projects made by Go, use a [`.netrc`
file](https://everything.curl.dev/usingcurl/netrc) and a [personal access
token](../profile/personal_access_tokens.md) in the password field. **This only
works if your GitLab instance can be accessed with HTTPS.** The `go` command
does not transmit credentials over insecure connections. This authenticates
all HTTPS requests made directly by Go, but does not authenticate requests made
through Git.

For example:

```plaintext
machine gitlab.example.com
login <gitlab_user_name>
password <personal_access_token>
```

NOTE:
On Windows, Go reads `~/_netrc` instead of `~/.netrc`.

### Authenticate Git fetches

If a module cannot be fetched from a proxy, Go falls back to using Git (for
GitLab projects). Git uses `.netrc` to authenticate requests. You can also
configure Git to either:

- Embed specific credentials in the request URL.
- Use SSH instead of HTTPS, as Go always uses HTTPS to fetch Git repositories.

```shell
# Embed credentials in any request to GitLab.com:
git config --global url."https://${user}:${personal_access_token}@gitlab.example.com".insteadOf "https://gitlab.example.com"

# Use SSH instead of HTTPS:
git config --global url."git@gitlab.example.com".insteadOf "https://gitlab.example.com"
```

### Fetch Go modules from Geo secondary sites

As Go modules are stored in Git repositories, you can use the [Geo](../../administration/geo/index.md)
feature that allows Git repositories to be accessed on the secondary Geo servers.

In the following examples, the primary's site domain name is `gitlab.example.com`,
and the secondary's is `gitlab-secondary.example.com`.

`go get` will initially generate some HTTP traffic to the primary, but when the module
download commences, the `insteadOf` configuration sends the traffic to the secondary.

#### Use SSH to access the Geo secondary

To fetch Go modules from the secondary using SSH:

1. Reconfigure Git on the client to send traffic for the primary to the secondary:

   ```plaintext
   git config --global url."git@gitlab-secondary.example.com".insteadOf "https://gitlab.example.com"
   git config --global url."git@gitlab-secondary.example.com".insteadOf "http://gitlab.example.com"
   ```

1. Ensure the client is set up for SSH access to GitLab repositories. This can be tested on the primary,
   and GitLab will replicate the public key to the secondary.

#### Use HTTP to access the Geo secondary

Using HTTP to fetch Go modules does not work with CI/CD job tokens, only with
persistent access tokens that are replicated to the secondary.

To fetch Go modules from the secondary using HTTP:

1. Put in place a Git `insteadOf` redirect on the client:

   ```plaintext
   git config --global url."https://gitlab-secondary.example.com".insteadOf "https://gitlab.example.com"
   ```

1. Generate a [personal access token](../profile/personal_access_tokens.md) and
   provide those credentials in the client's `~/.netrc` file:

   ```plaintext
   machine gitlab.example.com login USERNAME password TOKEN
   machine gitlab-secondary.example.com login USERNAME password TOKEN
   ```

## Access project page with project ID

> [Introduced](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/53671) in GitLab 11.8.

To quickly access a project from the GitLab UI using the project ID,
visit the `/projects/:id` URL in your browser or other tool accessing the project.

## Project's landing page

The project's landing page shows different information depending on
the project's visibility settings and user permissions.

For public projects, and to members of internal and private projects
with [permissions to view the project's code](../permissions.md#project-members-permissions):

- The content of a
  [`README` or an index file](repository/index.md#readme-and-index-files)
  is displayed (if any), followed by the list of directories in the
  project's repository.
- If the project doesn't contain either of these files, the
  visitor sees the list of files and directories of the repository.

For users without permissions to view the project's code, GitLab displays:

- The wiki homepage, if any.
- The list of issues in the project.
