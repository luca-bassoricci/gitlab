---
stage: Enablement
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: howto
---

# Geo for multiple nodes **(PREMIUM SELF)**

This document describes a minimal reference architecture for running Geo
in a multi-node configuration. If your multi-node setup differs from the one
described, it is possible to adapt these instructions to your needs.

## Architecture overview

![Geo multi-node diagram](img/geo-ha-diagram.png)

_[diagram source - GitLab employees only](https://docs.google.com/drawings/d/1z0VlizKiLNXVVVaERFwgsIOuEgjcUqDTWPdQYsE7Z4c/edit)_

The topology above assumes the **primary** and **secondary** Geo sites
are located in two separate locations, on their own virtual network
with private IP addresses. The network is configured such that all machines in
one geographic location can communicate with each other using their private IP addresses.
The IP addresses given are examples and may be different depending on the
network topology of your deployment.

The only external way to access the two Geo sites is by HTTPS at
`gitlab.us.example.com` and `gitlab.eu.example.com` in the example above.

NOTE:
* The **primary** and **secondary** Geo sites must be able to communicate to each other over HTTPS.
* It is possible to use cloud hosted services for PostgreSQL and Redis, but this is beyond the scope of this document.

## Redis for multiple nodes

Geo supports Redis on **primary** and **secondary** sites configured for multiple nodes.

Because of the additional complexity involved in setting up this configuration
for Redis, it is not covered by this Geo multi-node documentation.

For more information on setting up a multi-node Redis cluster using the Omnibus GitLab package, see the [Redis multi-node documentation](../../redis/replication_and_failover.md)

## Prerequisites: Two working GitLab multi-node clusters

One cluster serves as the **primary** site. Use the
[GitLab multi-node documentation](../../reference_architectures/index.md) to set this up. If
you already have a working GitLab instance that is in-use, it can be used as a
**primary** site.

The second cluster serves as the **secondary** site. Again, use the
[GitLab multi-node documentation](../../reference_architectures/index.md) to set this up.
It's a good idea to log in and test it. However, be aware that its data is
wiped out as part of the process of replicating from the **primary** site.

## Configure the GitLab cluster to be the **primary** site

The following steps enable a GitLab cluster to serve as the **primary** site.

### Step 1: Configure the **primary** site's frontend servers

1. Edit `/etc/gitlab/gitlab.rb` and add the following:

   ```ruby
   ##
   ## Enable the Geo primary role
   ##
   roles ['geo_primary_role']

   ##
   ## The unique identifier for the Geo node.
   ##
   gitlab_rails['geo_node_name'] = '<node_name_here>'

   ##
   ## Disable automatic migrations
   ##
   gitlab_rails['auto_migrate'] = false
   ```

After making these changes, [reconfigure GitLab](../../restart_gitlab.md#omnibus-gitlab-reconfigure) so the changes take effect.

NOTE:
PostgreSQL and Redis should have already been disabled on the
application servers during normal GitLab multi-node setup. Connections
from the application servers to services on the backend servers should
have also been configured. See multi-node configuration documentation for
[PostgreSQL](../../postgresql/replication_and_failover.md#configuring-the-application-nodes)
and [Redis](../../redis/replication_and_failover.md#example-configuration-for-the-gitlab-application).

### Step 2: Configure the **primary** database

1. Edit `/etc/gitlab/gitlab.rb` and add the following:

   ```ruby
   ##
   ## Configure the Geo primary role and the PostgreSQL role
   ##
   roles ['geo_primary_role', 'postgres_role']
   ```

## Configure a **secondary** site

A **secondary** cluster is similar to any other GitLab multi-node cluster, with two
major differences:

- The main PostgreSQL database is a read-only replica of the **primary** node's
  PostgreSQL database.
- There is also a single PostgreSQL database for the **secondary** cluster,
  called the "tracking database", which tracks the synchronization state of
  various resources.

Therefore, we set up the multi-node components one by one and include deviations
from the normal multi-node setup. However, we highly recommend configuring a
brand-new cluster first, as if it were not part of a Geo setup. This allows
verifying that it is a working cluster. And only then should it be modified
for use as a Geo **secondary**. This helps to separate Geo setup problems from
unrelated problems.

### Step 1: Configure the Redis and Gitaly services on the **secondary** site

Configure the following services, again using the non-Geo multi-node
documentation:

- [Configuring Redis for GitLab](../../redis/replication_and_failover.md#example-configuration-for-the-gitlab-application) for multiple nodes.
- [Gitaly](../../gitaly/index.md), which stores data that is
  synchronized from the **primary** site.

NOTE:
[NFS](../../nfs.md) can be used in place of Gitaly but is not
recommended.

### Step 2: Configure the main read-only replica PostgreSQL database on the **secondary** node

NOTE:
The following documentation assumes the database runs on
a single node only. For multi-node PostgreSQL on a **secondary** site,
see [instructions to set up a Patroni standby cluster](../setup/database.md#multi-node-database-replication).

Configure the [**secondary** database](../setup/database.md) as a read-only replica of
the **primary** database. Use the following as a guide.

1. Generate an MD5 hash of the desired password for the database user that the
   GitLab application uses to access the read-replica database:

   Note that the username (`gitlab` by default) is incorporated into the hash.

   ```shell
   gitlab-ctl pg-password-md5 gitlab
   # Enter password: <your_password_here>
   # Confirm password: <your_password_here>
   # fca0b89a972d69f00eb3ec98a5838484
   ```

   Use this hash to fill in `<md5_hash_of_your_password>` in the next step.

1. Edit `/etc/gitlab/gitlab.rb` in the replica database machine, and add the
   following:

   ```ruby
   ##
   ## Configure the Geo secondary role and the PostgreSQL role
   ##
   roles ['geo_secondary_role', 'postgres_role']

   ##
   ## The unique identifier for the Geo node.
   ## This should match the secondary's application node.
   ##
   gitlab_rails['geo_node_name'] = '<node_name_here>'

   ##
   ## Secondary address
   ## - replace '<secondary_node_ip>' with the public or VPC address of your Geo secondary node
   ## - replace '<tracking_database_ip>' with the public or VPC address of your Geo tracking database node
   ##
   postgresql['listen_address'] = '<secondary_node_ip>'
   postgresql['md5_auth_cidr_addresses'] = ['<secondary_node_ip>/32', '<tracking_database_ip>/32']

   ##
   ## Database credentials password (defined previously in primary node)
   ## - replicate same values here as defined in primary node
   ##
   postgresql['sql_user_password'] = '<md5_hash_of_your_password>'
   gitlab_rails['db_password'] = '<your_password_here>'

   ##
   ## When running the Geo tracking database on a separate machine, disable it
   ## here and allow connections from the tracking database host. And ensure
   ## the tracking database IP is in postgresql['md5_auth_cidr_addresses'] above.
   ##
   geo_postgresql['enable'] = false

   ##
   ## Disable all other services that aren't needed. Note that we had to enable
   ## geo_secondary_role to cause some configuration changes to postgresql, but
   ## the role enables single-node services by default.
   ##
   alertmanager['enable'] = false
   consul['enable'] = false
   geo_logcursor['enable'] = false
   gitaly['enable'] = false
   gitlab_exporter['enable'] = false
   gitlab_workhorse['enable'] = false
   nginx['enable'] = false
   node_exporter['enable'] = false
   pgbouncer_exporter['enable'] = false
   prometheus['enable'] = false
   redis['enable'] = false
   redis_exporter['enable'] = false
   patroni['enable'] = false
   sidekiq['enable'] = false
   sidekiq_cluster['enable'] = false
   puma['enable'] = false
   ```

After making these changes, [reconfigure GitLab](../../restart_gitlab.md#omnibus-gitlab-reconfigure) so the changes take effect.

If using an external PostgreSQL instance, refer also to
[Geo with external PostgreSQL instances](../setup/external_database.md).

### Step 3: Configure the tracking database on the **secondary** node

NOTE:
This documentation assumes the tracking database runs on
only a single machine, rather than as a PostgreSQL cluster.
To run the tracking database as a PostgreSQL cluster,
see the [instructions to configure a Patroni cluster for the tracking database](../setup/database.md#migrating-a-single-tracking-database-node-to-patroni) after following
the steps below.

Configure the tracking database.

1. Generate an MD5 hash of the desired password for the database user that the
   GitLab application uses to access the tracking database:

   Note that the username (`gitlab_geo` by default) is incorporated into the
   hash.

   ```shell
   gitlab-ctl pg-password-md5 gitlab_geo
   # Enter password: <your_password_here>
   # Confirm password: <your_password_here>
   # fca0b89a972d69f00eb3ec98a5838484
   ```

   Use this hash to fill in `<tracking_database_password_md5_hash>` in the next
   step.

1. Edit `/etc/gitlab/gitlab.rb` in the tracking database machine, and add the
   following:

   ```ruby
   ##
   ## Enable the Geo secondary tracking database
   ##
   geo_postgresql['enable'] = true
   geo_postgresql['listen_address'] = '<ip_address_of_this_host>'
   geo_postgresql['sql_user_password'] = '<tracking_database_password_md5_hash>'

   ##
   ## Configure PostgreSQL connection to the replica database
   ##
   geo_postgresql['md5_auth_cidr_addresses'] = ['<replica_database_ip>/32']
   gitlab_rails['db_host'] = '<replica_database_ip>'

   # Prevent reconfigure from attempting to run migrations on the replica DB
   gitlab_rails['auto_migrate'] = false

   ##
   ## Ensure unnecessary services are disabled
   ##
   alertmanager['enable'] = false
   consul['enable'] = false
   geo_logcursor['enable'] = false
   gitaly['enable'] = false
   gitlab_exporter['enable'] = false
   gitlab_workhorse['enable'] = false
   nginx['enable'] = false
   node_exporter['enable'] = false
   pgbouncer_exporter['enable'] = false
   postgresql['enable'] = false
   prometheus['enable'] = false
   redis['enable'] = false
   redis_exporter['enable'] = false
   patroni['enable'] = false
   sidekiq['enable'] = false
   sidekiq_cluster['enable'] = false
   puma['enable'] = false
   ```

After making these changes, [reconfigure GitLab](../../restart_gitlab.md#omnibus-gitlab-reconfigure) so the changes take effect.

If using an external PostgreSQL instance, refer also to
[Geo with external PostgreSQL instances](../setup/external_database.md).

### Step 4: Configure the frontend application servers on the **secondary** site

In the architecture overview, there are two machines running the GitLab
application services. These services are enabled selectively in the
configuration.

Configure the GitLab Rails application servers following the relevant steps
outlined in the [reference architectures](../../reference_architectures/index.md),
then make the following modifications:

1. Edit `/etc/gitlab/gitlab.rb` on each application server in the **secondary**
   site, and add the following:

   ```ruby
   ##
   ## Enable the Geo secondary role
   ##
   roles ['geo_secondary_role', 'application_role']

   ##
   ## The unique identifier for the Geo node.
   ##
   gitlab_rails['geo_node_name'] = '<node_name_here>'

   ##
   ## Disable automatic migrations
   ##
   gitlab_rails['auto_migrate'] = false

   ##
   ## Configure the connection to the tracking DB. And disable application
   ## servers from running tracking databases.
   ##
   geo_secondary['db_host'] = '<geo_tracking_db_host>'
   geo_secondary['db_password'] = '<geo_tracking_db_password>'
   geo_postgresql['enable'] = false

   ##
   ## Configure connection to the streaming replica database, if you haven't
   ## already
   ##
   gitlab_rails['db_host'] = '<replica_database_host>'
   gitlab_rails['db_password'] = '<replica_database_password>'

   ##
   ## Configure connection to Redis, if you haven't already
   ##
   gitlab_rails['redis_host'] = '<redis_host>'
   gitlab_rails['redis_password'] = '<redis_password>'

   ##
   ## If you are using custom users not managed by Omnibus, you need to specify
   ## UIDs and GIDs like below, and ensure they match between servers in a
   ## cluster to avoid permissions issues
   ##
   user['uid'] = 9000
   user['gid'] = 9000
   web_server['uid'] = 9001
   web_server['gid'] = 9001
   registry['uid'] = 9002
   registry['gid'] = 9002
   ```

NOTE:
If you had set up PostgreSQL cluster using the omnibus package and had set
`postgresql['sql_user_password'] = 'md5 digest of secret'`, keep in
mind that `gitlab_rails['db_password']` and `geo_secondary['db_password']`
contains the plaintext passwords. This is used to let the Rails
servers connect to the databases.

NOTE:
Make sure that current node IP is listed in `postgresql['md5_auth_cidr_addresses']` setting of your remote database.

After making these changes [Reconfigure GitLab](../../restart_gitlab.md#omnibus-gitlab-reconfigure) so the changes take effect.

On the secondary the following GitLab frontend services are enabled:

- `geo-logcursor`
- `gitlab-pages`
- `gitlab-workhorse`
- `logrotate`
- `nginx`
- `registry`
- `remote-syslog`
- `sidekiq`
- `puma`

Verify these services by running `sudo gitlab-ctl status` on the frontend
application servers.

### Step 5: Set up the LoadBalancer for the **secondary** site

In this topology, a load balancer is required at each geographic location to
route traffic to the application servers.

See [Load Balancer for GitLab with multiple nodes](../../load_balancer.md) for
more information.

### Step 6: Configure the backend application servers on the **secondary** site

The minimal reference architecture diagram above shows all application services
running together on the same machines. However, for multiple nodes we
[strongly recommend running all services separately](../../reference_architectures/index.md).

For example, a Sidekiq server could be configured similarly to the frontend
application servers above, with some changes to run only the `sidekiq` service:

1. Edit `/etc/gitlab/gitlab.rb` on each Sidekiq server in the **secondary**
   site, and add the following:

   ```ruby
   ##
   ## Enable the Geo secondary role
   ##
   roles ['geo_secondary_role']

   ##
   ## Enable the Sidekiq service
   ##
   sidekiq['enable'] = true

   ##
   ## Ensure unnecessary services are disabled
   ##
   alertmanager['enable'] = false
   consul['enable'] = false
   gitaly['enable'] = false
   gitlab_exporter['enable'] = false
   gitlab_workhorse['enable'] = false
   nginx['enable'] = false
   node_exporter['enable'] = false
   pgbouncer_exporter['enable'] = false
   postgresql['enable'] = false
   prometheus['enable'] = false
   redis['enable'] = false
   redis_exporter['enable'] = false
   patroni['enable'] = false
   puma['enable'] = false

   ##
   ## The unique identifier for the Geo node.
   ##
   gitlab_rails['geo_node_name'] = '<node_name_here>'

   ##
   ## Disable automatic migrations
   ##
   gitlab_rails['auto_migrate'] = false

   ##
   ## Configure the connection to the tracking DB. And disable application
   ## servers from running tracking databases.
   ##
   geo_secondary['db_host'] = '<geo_tracking_db_host>'
   geo_secondary['db_password'] = '<geo_tracking_db_password>'
   geo_postgresql['enable'] = false

   ##
   ## Configure connection to the streaming replica database, if you haven't
   ## already
   ##
   gitlab_rails['db_host'] = '<replica_database_host>'
   gitlab_rails['db_password'] = '<replica_database_password>'

   ##
   ## Configure connection to Redis, if you haven't already
   ##
   gitlab_rails['redis_host'] = '<redis_host>'
   gitlab_rails['redis_password'] = '<redis_password>'

   ##
   ## If you are using custom users not managed by Omnibus, you need to specify
   ## UIDs and GIDs like below, and ensure they match between servers in a
   ## cluster to avoid permissions issues
   ##
   user['uid'] = 9000
   user['gid'] = 9000
   web_server['uid'] = 9001
   web_server['gid'] = 9001
   registry['uid'] = 9002
   registry['gid'] = 9002
   ```

   You can similarly configure a server to run only the `geo-logcursor` service
   with `geo_logcursor['enable'] = true` and disabling Sidekiq with
   `sidekiq['enable'] = false`.

   These servers do not need to be attached to the load balancer.
