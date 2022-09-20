---
stage: DevSecOps
group: Technical writing
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# GitLab application security tutorial

This tutorial walks you through setting up GitLab application security using Google Cloud and a Kubernetes cluster.

You may use the provided project, or your own application, to learn how to configure your security settings.

<i class="fa fa-youtube-play youtube" aria-hidden="true"></i>
For a great introduction to how GitLab does DevSecOps, see [GitLab DevSecOps webinar](https://www.youtube.com/watch?v=PH9Z_znll40).
 
## Prerequisites

- A GitLab account with an Ultimate license.
- A Google Cloud account.

## Create a group

If you don't have a group to contain your project, create a group named `security-demo`. For details, see [Create a group](../group/index.md#create-a-group).

## Import and configure deployment of the project

If you don't have a project for the purposes of this guide, follow these instructions to import and
configure deployment of the example project. If you **do** already have a project for use with this
guide, and deployment is already configured, skip to [Set up merge request approvals](#set-up-merge-request-approvals).

### Import the example project

Import the example project, `workshop-notes`.

1. Select **New project** from the top bar.
1. Select **Import project**.
1. Select **Repository by URL**.
1. In the `Git repository URL` field, add `https://gitlab.com/tech-marketing/devsecops/devsecops-workshop/workshop-notes.git`.
1. Select **Public** visibility level.
1. Select **Create project**. When the job is complete, GitLab displays `The project was successfully imported`.

### Configure deployment of the example project

In this section we configure a Kubernetes cluster to which we can deploy the demonstration project.

#### Prepare to set up a Kubernetes cluster (GKE)

Install the command-line interface tools needed to configure the Kubernetes cluster.

1. [Install Google Cloud SDK](https://cloud.google.com/sdk/docs/quickstart). This allows you to interact with the cluster using the command line.
1. [Install KubeCtl](https://kubernetes.io/docs/tasks/tools/). This allows you to run commands on the cluster we create.

#### Set up a Kubernetes cluster

Set up the Kubernetes cluster.

1. Go to the [Google Cloud Console](https://console.cloud.google.com).
1. In the left sidebar, select `Kubernetes Engine` then `Clusters`.
1. If you have not enabled Kubernetes clusters yet, select `Enable` to allow creation of a new cluster.
1. Select **Create**.
1. Select **Configure** for the GKE Standard feature.
1. Name the cluster.
1. Select **Add node pool**. This adds a single node pool. Add a second node pool for a total of 3 in the `Node Pools` list on the left.
1. Select **Nodes** from the left sidebar. The default settings are adequate for this tutorial project.
1. Select **Networking** from the left sidebar. Verify that `HTTP load balancing` is enabled.
1. Select **Create** at the bottom of the page. Google Cloud creates the new cluster. When it completes the job, your new rendered cluster is available.

#### Configure the connection to the Kubernetes cluster

Configure the connection from your project to the Kubernetes cluster.

1. Go to your GitLab project.
1. In the left sidebar, select **Clusters**.
1. Select your new cluster.
1. Select **Connect** from the top bar of the page.
1. Copy the `command-line access` text.
1. Paste the `command-line access` text into your terminal window and run the command.
1. In your terminal window, run `$ kubectl cluster-info`. If the cluster is working, the response should show the cluster running.
1. In your terminal window, run `$ kubectl get nodes`. If the nodes are in a `Ready` status, the configuration is successful.

#### Install Helm

Install Helm, a package manager for Kubernetes. It allows us to install applications containing
several Kubernetes manifests, such as Deployments, Services, and Ingress.

1. Download the installation file. `$ curl --fail --silent --show-error --location --output get_helm.sh "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"`.
1. Make the downloaded file executable `$ chmod 700 get_helm.sh`.
1. Run the installation `$ ./get_helm.sh`.

#### Install Ingress-NGINX

Using Helm, install the Ingress-NGINX controller.

1. Run the installation command.

   ```plaintext
   $ helm upgrade --install ingress-nginx ingress-nginx \
   --repo https://kubernetes.github.io/ingress-nginx \
   --namespace ingress-nginx --create-namespace
   ```

1. To verify the pods are running, run `$ kubectl get pods --namespace=ingress-nginx`.
1. To get the external IP address of the load balancer, run `kubectl --namespace ingress-nginx get services -o wide -w ingress-nginx-controller`. The Ingress controller automatically creates an external IP address using the Google load balancer.

You now have a working Kubernetes cluster and can move on to deploy an application.

#### Deploy an application with GitLab pipeline

In this section you deploy your application to the Kubernetes cluster, along with an Ingress
controller. This allows you to access the application from the outside world.

### Clone the compliance and deployment manifests

In this section we install the GitLab Kubernetes Agent to interact with the cluster and deploy our Kubernetes manifests.

1. Select **New project** from the top bar.
1. Select **Import project**.
1. Select **Repository by URL**.
1. In the `Git repository URL` field, add `https://gitlab.com/tech-marketing/devsecops/devsecops-workshop/workshop-manifests.git`.
1. Select **Public** visibility level.
1. Select **Create project**. When the job is complete, GitLab displays `The project was successfully imported`.

### Install the Kubernetes agent to use the cluster

1. Select the `workshop-notes` project.
1. Select **Web IDE**.
1. Open the `.gitlab/agents/kube-agent/config.yaml` file from the left sidebar. Configure the path to your project. For example, `yourprojectname/workshop-manifests`.
1. Select **Create commit..** to commit the change.
1. Select **Commit to main branch**.
1. Select **Commit**. You can now deploy the Kubernetes agent to your cluster. Return to your `Workshop Notes` project from the left sidebar.
1. On the left sidebar, select **Infrastructure > Kubernetes clusters**.
1. Select **Connect a cluster**.
1. Select `kube-agent` from the dropdown list and select **Register**.
1. Copy the agent access token and save it. It is not be available after you close this window.
1. Copy the **Install using Helm (recommended)** text.
1. Open a terminal window. Paste the copied text and run the command.
1. To verify the Kubernetes agent is running, run `$ kubectl get pods -n gitlab-kubernetes-agent`.

## Access your application

In this section we use Ingress to access the application. The default settings include the load
balancer IP address in the `/notes` path. You may configure these by editing the `values.yaml` in
the Helm path.

1. In your terminal window, run `$ kubectl get svc -n ingress-nginx` to determine the load balancer's IP address.
1. In your browser, go to `http://[Load balancer IP]/notes`.

Your application is now successfully deployed.

## Test vulnerability detection

GitLab offers a variety of security scans to enhance application security. Some scanners scan the
static source code (SAST), and others scan the running application for vulnerabilities (DAST).

### Enable the security analyzers

In this section we enable all the security analyzers. Each time we commit a code change on any
branch, the pipeline runs the security scans.

1. Go to your GitLab project.
1. Select **Web IDE** to edit your project.
1. Open the `.gitlab-ci.yml` file from the left sidebar.
1. Use the `include` block to add these templates to the file.

   ```plaintext
   include:
   - template: Security/SAST.gitlab-ci.yml
   - template: Security/DAST.gitlab-ci.yml
   - template: Security/License-Scanning.gitlab-ci.yml
   - template: Security/Container-Scanning.gitlab-ci.yml
   - template: Security/Dependency-Scanning.gitlab-ci.yml
   - template: Security/SAST-IaC.latest.gitlab-ci.yml
   ```

1. Add the DAST scan location for the application to the variables. This is the URL used to access
   the application. `variables: DAST_WEBSITE: http://LOADBALANCER_IP/notes`
1. Add `dast` to the **stages** section.

   ```plaintext
   stages:
      build
      test
      staging
      dast
   ```

1. Select **Create commit**.
1. Select **Commit to main branch** and select **Commit**.

### Set up merge request approvals

In this section, we set up protection to identify and prevent vulnerabilities in your code. This
also includes incompatible licenses.

1. Go to your GitLab project.
1. From the left sidebar, select **Security & Compliance > Policies**.
1. Select **New policy**.
1. Select **Scan result** from the **Policy type** dropdown list.
1. Fill out the policy name and description.
1. Enable **Policy status**.
1. Create the rule `IF Select all find(s) more than 0 Select all Newly detected vulnerabilities in an open merge request targeting main`.
1. Create the action `THEN Require approval from 1 of the following approvers`
1. Add yourself in the **Search users or groups** dropdown list.
1. Select **Configure with a merge request**.
1. Merge the new code. Your new project is created to store the policies.

### Create a license policy

License policies allow you to declare licenses as either approved or denied. When merge request
approvals are set up, a denied license blocks an MR from being merged.

1. From the left sidebar, go to **Security & Compliance > License compliance**.
1. Select **Policies**.
1. Select **Add license and related policy**.
1. Enter **Apache License 2.0**, then select **Deny**.
1. Select **Submit**.

GitLab confirms the addition.

### Set up merge request approvals for licenses

Setting up license check enables us to require approval if any licenses in the denylist are present.
The denylist is set up in [Create a license policy](#create-a-license-policy).

1. In the left sidebar, select **Settings > General**.
1. Expand **Merge request approvals**.
1. Select **Enable** for **License check**.
1. Select your username in the **Approvers** dropdown list.
1. Select **Add approval rule**.

Security scans and DevSecOps are now enabled for your application.

## View vulnerabilities in a merge request

In this section, we introduce some vulnerable code to a feature branch to see how the scanners identify and display vulnerabilities.

### Add vulnerable code for testing

1. Go to your GitLab project.
1. Select **Web IDE**.
1. Open `notes/db.py` and add the following text after `conn = sqlite3.connect(name)`.

   ```plaintext
   os chmod(name, 777)
   ```

   This step gives the database file global permissions, which is a security issue.

1. Add the following text at the end of the file.

   ```plaintext
   @note.route('/get-with-vuln', methods=['GET'])
   def get_note_with_vulnerability():
      id = request.args.get('id')
      conn = db.create_connection()

      with conn:
         try:
               return str(db.select_note_by_id(conn, id))
         except Exception as e:
               return "Failed to delete Note: %s" % e
   ```

   This step adds a new route that we can access from the `/get-with-vuln` URI path, and allows us to test DAST.

1. In Web IDE, create a new file in `chart/templates` and name it `vulns.yaml`.
1. Add the following text to the new file.

   ```plaintext
   apiVersion: v1
   kind: Pod
   metadata:
      name: kubesec-demo
   spec:
      containers:
      - name: kubesec-demo
         image: gcr.io/google-samples/node-hello:1.0
         securityContext:
         readOnlyRootFilesystem: true
   ```

1. In Web IDE, open `requirements.txt` and change the content to the following.

   ```plaintext
   Flask==0.12.2
   django==2.0.0
   flask_wtf
   wtforms
   flask-bootstrap
   pysqlite3
   dubbo-client
   ```

1. Open `Dockerfile` and change the alpine version to the following.

   ```plaintext
   FROM python:alpine3.7
   ```

1. Select **Commit**.
1. Select **Create new branch** and name the branch.
1. Select **Start a new merge request**.
1. Select **Commit**.
1. Create the merge request and select **Submit merge request**.

This process may take several minutes to complete.

### View vulnerable code

This step shows how to see the vulnerabilities we introduced.

1. Open the merge request created in the [previous step](#add-vulnerable-code-for-testing).
1. Select **Expand** in **Security scans**.
1. Select the **Chmod setting a permissive mask 0o1411 on file (name)** vulnerability. The scan
   generates a pop-up.
1. Select **Dismiss vulnerability**. You now see a label next to the dismissed vulnerability. This
   allows the AppSec team to see what developers are dismissing and why. Merging this request tags
   the vulnerability as dismissed in reports.
1. Select the same vulnerability.
1. Select **Create issue**.
1. Select your browser's **back** button to go back to the merge request.

### View denied licenses

In this step we see which licenses are approved or denied according to the policy we set previously.

In the merge request, expand the **License** section. Note that `Apache License 2.0` has been denied.

### Merge the code

We can now merge the new code. This step populates the vulnerability report for testing.

1. In the merge request, select **View eligible approvers**. Merge request approvals are active.
1. Select **Merge**.

### View vulnerability reports

Each vulnerability report contains vulnerabilities from the scans of the most recent branch merged
into the default branch.

The vulnerability reports display the total number of vulnerabilities by severity. For example,
`Critical`, `High`, `Medium`, `Low`, `Info`, `Unknown`.

The report table shows each vulnerability's:

- Detected date
- Status
- Severity
- Description
- Identifier
- The scanner where it was detected
- Activity, including related issues or available solutions

By default, the vulnerability report is filtered to display all detected and confirmed vulnerabilities.

1. Go to your GitLab project.
1. In the left sidebar, select **Security & Compliance > Vulnerability Reports**.
1. Filter by **Scanner** and select **SAST**.
1. Select the **Possible binding to all interfaces** description.
1. Enable **Status**.
1. Select **Confirm**.
1. Select **Change status**. This allows better filtering and enables your security team to
   effectively triage issues.
1. Move to the bottom of the page and add a comment in the text box. Select **Save comment**. This
   saves the comment in the vulnerability page and enables collaboration in the AppSec team.

You now know how to view vulnerabilities in an MR, and to find the suggested details to resolve them.
