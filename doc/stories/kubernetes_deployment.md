---
stage: Multiple stages
group: Macro UX
info: The page to describe a story related to Platform Engineer and Kubernetes Deployment.
---

# Platform Engineer and Kubernetes Deployment

## Introduction

I am a Platform Engineer in XYZ coorporation.
So far my career has been involved with Kubernetes and cloud deployments, therefore I have a strong knowledge on it,
for example, I know what services are needed to run a production-grade infrastructure
and comfortably author manifest files for it.

Recently, my company launched a new project that runs an ecommerce website.
My team consists of one developer, one product manager and me as a platform engineer.
I'm in a charge of deploying the web application to the production environment
in a scalable, safe and easy-maintenance fashion.

## Overview of the project hierarchy

In this story, the development project and the operation project are separated
in terms of [segregation of duties](https://medium.com/@jeehad.jebeile/devops-and-segregation-of-duties-9c1a1bea022e):

```
XYZ org
  - Development Group
    - ASP.NET project ... The main project to build, test and package the web application.
  - Operator Group
    - GitOps project  ... The main project to orchestrate the developed applications for production environment.
```

NOTE: More sidecar projects can be added to the development group in order for [Microservice architectures](https://about.gitlab.com/topics/microservices/).

## Chapter 1: Infrastructure Planning

_Related to Plan stage_

After a few weeks of the initial sprint, the very first GA version of application
has been developed.
Now we have to run the application on somewhere on cloud servers.

According to the development note,
the application is compatible with container orchestration platforms.
So I decided to use a Kubernetes cluster, however,
before making any changes,
I have to get an approval from the infrastructure lead if the proposed architecture
is along with the company standards.

### How I accomplished this task

- Create an issue.
- Create a diagram with mermaid.
- Discussion and get an approval.

## Chapter 2: Launch the website (1/2)

_Related to Create and Configure stages_

The proposed infrastructure has been approved. Now, I'm commiting the
plan to launch the website. I'll create a new cluster on [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine)
and author manifiest files to build the infrastucture.
As a preliminary step, I'll install an Ingress Controller to obtain the server address.

### How I accomplished this task

- Create a Kubernetes Cluster on GKE.
- Setup [Kubernetes Agent](https://docs.gitlab.com/ee/user/clusters/agent/install/index.html).
- Download Nginx Ingress official repository.
- Configure Agent Config files.
- Confirm the Nginx is responding.

## Chapter 3: Launch the website (2/2)

_Related to Create and Configure stages_

Now, the Ingress is running. I continue authoring manifest files to
deploy our web application into the Kubernetes and make sure that the website is up and running.

### How I accomplished this task

- Author manifest files for the web application.
- Access to the website.

## Chapter 4: Test and review manifest file changes before commiting

_Related to Verify stage_

The website was successfully launched. In order to expand the active user base,
our team decided to add a new feature every week.
To keep the production environment up-to-date, I have to repeat the manual deployment process
every week, however, I could mistakenly update manifest files that results in a deployment failure.
I have to setup CI pipeline to verify that manifest file changes are safe and valid, before actually provisning it to production.

### How I accomplished this task

- Setup `.gitlab-ci.yml`
- Add a job to run Lint job with [kubeval](https://hub.docker.com/r/garethr/kubeval).

## Chapter 5: Monitor the infrastructure

_Related to Configure and Monitor stages_

As the website grows, more users are visiting to the website, which means
more computation resource is required on the server.
I have to monitor the status of the performance load of the production cluster
to make sure that the server is not overwhelmed by many accesses.
I also have to setup an alert system to get a notification when the error rate of server responces goes up high,
so that I can quickly jump on the incident investigation and mitigation.

### How I accomplished this task

- Setup Promehteus instance in the cluster.
- Setup [Prometheus Integration](https://docs.gitlab.com/ee/user/project/integrations/prometheus.html)

## Chapter 6: Scale up the infrastructure

_Related to Configure stage_

One day I got a message from a product manager that
rendering website pages takes a long time, thus it's frustrating end-users.
After some investigation, I realized that CPU usage of the server is saturated at 100%,
so there are not enough resources to handle the large number of requests.
So I decided to scale up the computation resources to resolve the performance issue.

### How I accomplished this task

- Change the replica count of the Deployment resource in a manifest file.

## Chapter 7: Rollback when an incident happens

_Related to Release stage_

One day I got an alert that all HTTP requests to the web server were resulting in errors.
After some investigation, I realized that the latest application codebase had a critical bug.
So I decided to rollback to the previous stable version in order to quickly mitigate the
production incident.

### How I accomplished this task

- Change the version of the application image in a manifest file.
