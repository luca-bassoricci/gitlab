## DevOps Research and Assessment (DORA) key metrics **(ULTIMATE)**

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/275991) in GitLab 13.7.
> - [Added support](https://gitlab.com/gitlab-org/gitlab/-/issues/291746) for lead time for changes in GitLab 13.10.

The [DevOps Research and Assessment (DORA)](https://cloud.google.com/blog/products/devops-sre/using-the-four-keys-to-measure-your-devops-performance)
team has created a list of four metrics that are straightforward, focused, and easy to implement. They form an excellent foundation for metrics initiatives, helping to improve existing DevOps efficiency while also building a bridge to business stakeholders. DORA's research continues to show that excellence in software delivery accelerates business results.

There are four key metrics in DORA, divided into two core areas of DevOps. Deployment Frequency and Lead Time for Change are used to measure team velocity, while Change Failure Rate and Time to Restore Service are used to measure stability. 

For software leaders, tracking velocity alongside quality metrics ensures they're not sacrificing quality for speed.


### DORA Metrics dashboard in Value Stream Analytics

The four DORA metrics avaialble out-of-the-box in the Value Stream Analytics (VSA) overview dashboard to visulziae the engineering work in the context of the end to end value delivery.
Value Stream Analytics (VSA) overview dashboard includes four DORA metrics for analyzing engineering work in the context of end-to-end value delivery.

Using The One DevOps Platform [Value Stream Management](https://gitlab.com/gitlab-org/gitlab/-/value_stream_analytics) provides end-to-end visibility to the entire software delivery lifecycle - enabling teams and managers to understand all aspects of productivity, quality and delivery without the [“toolchain tax”](https://about.gitlab.com/solutions/value-stream-management/).

  
### Deployment frequency

Deployment frequency is the frequency of successful deployments to production (hourly, daily, weekly, monthly, or yearly).
This measures how often you deliver value to end users. A higher deployment frequency means you can
get feedback sooner and iterate faster to deliver improvements and features. GitLab measures this as the number of
deployments to a production environment in the given time period.

Deployment frequency displays in several charts:

- [Group-level value stream analytics](../group/value_stream_analytics/index.md)
- [Project-level value stream analytics](value_stream_analytics.md)
- [CI/CD analytics](ci_cd_analytics.md)

To retrieve metrics for deployment frequency, use the [GraphQL](../../api/graphql/reference/index.md) or the [REST](../../api/dora/metrics.md) APIs.

### Lead time for changes

Lead time for changes measures the time to deliver a feature once it has been developed,
as described in [Measuring DevOps Performance](https://devops.com/measuring-devops-performance/).

Lead time for changes displays in several charts:

- [Group-level value stream analytics](../group/value_stream_analytics/index.md)
- [Project-level value stream analytics](value_stream_analytics.md)
- [CI/CD analytics](ci_cd_analytics.md)

To retrieve metrics for lead time for changes, use the [GraphQL](../../api/graphql/reference/index.md) or the [REST](../../api/dora/metrics.md) APIs.

### Time to restore service

Time to restore service measures how long it takes an organization to recover from a failure in production.
GitLab measures this as the average time required to close the incidents
in the given time period. This assumes:

- All incidents are related to a production environment.
- Incidents and deployments have a strictly one-to-one relationship. An incident is related to only
one production deployment, and any production deployment is related to no more than one incident).

Time to restore service displays in several charts:

- [Group-level value stream analytics](../group/value_stream_analytics/index.md)
- [Project-level value stream analytics](value_stream_analytics.md)
- [CI/CD analytics](ci_cd_analytics.md)

To retrieve metrics for time to restore service, use the [GraphQL](../../api/graphql/reference/index.md) or the [REST](../../api/dora/metrics.md) APIs.

### Change failure rate

Change failure rate measures the percentage of deployments that cause a failure in production. GitLab measures this as the number
of incidents divided by the number of deployments to a
production environment in the given time period. This assumes:

- All incidents are related to a production environment.
- Incidents and deployments have a strictly one-to-one relationship. An incident is related to only
one production deployment, and any production deployment is related to no
more than one incident.

To retrieve metrics for change failure rate, use the [GraphQL](../../api/graphql/reference/index.md) or the [REST](../../api/dora/metrics.md) APIs.

### Insights: Custom DORA reporting

Custom charts to visualize DORA data with Insights YAML-based reports. 

With this new visualization, software leaders can track metrics improvements, understand patterns in their metrics trends, and compare performance between groups and projects.

### Supported DORA metrics in GitLab

| Metric                    | Level             | API                                                 | UI chart               | Comments |
|---------------------------|-------------------|-----------------------------------------------------|------------------------|----------|
| `deployment_frequency`    | Project           | [GitLab 13.7 and later](../../api/dora/metrics.md)  | GitLab 14.8 and later  | The previous API endpoint was [deprecated](https://gitlab.com/gitlab-org/gitlab/-/issues/323713) in 13.10. |
| `deployment_frequency`    | Group             | [GitLab 13.10 and later](../../api/dora/metrics.md) | GitLab 13.12 and later |          |
| `lead_time_for_changes`   | Project           | [GitLab 13.10 and later](../../api/dora/metrics.md) | GitLab 13.11 and later | Unit in seconds. Aggregation method is median. |
| `lead_time_for_changes`   | Group             | [GitLab 13.10 and later](../../api/dora/metrics.md) | GitLab 14.0 and later  | Unit in seconds. Aggregation method is median. |
| `time_to_restore_service` | Project and group | [GitLab 14.9 and later](../../api/dora/metrics.md)  | GitLab 15.1 and later  | Unit in days. Aggregation method is median. |
| `change_failure_rate`     | Project and group | [GitLab 14.10 and later](../../api/dora/metrics.md) | GitLab 15.2 and later  | Percentage of deployments. |

