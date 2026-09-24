---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 容器镜像仓库故障排除
description: 排查极狐GitLab 容器镜像仓库的常见问题。
---

在调查具体问题之前，请先尝试以下故障排除步骤：

1. 验证您的 Docker 客户端和极狐GitLab 服务器上的系统时钟已同步（例如，通过 NTP）。
1. 对于使用 S3 存储的镜像仓库，请验证您的 IAM 权限和 S3 凭据（包括区域）是否正确。
   更多信息，请参阅 [示例 IAM 策略](https://distribution.github.io/distribution/storage-drivers/s3/)。
1. 检查镜像仓库日志（例如，`/var/log/gitlab/registry/current`）和极狐GitLab 生产日志中的错误
   （例如，`/var/log/gitlab/gitlab-rails/production.log`）。
1. 检查容器镜像仓库的 NGINX 配置文件（例如，`/var/opt/gitlab/nginx/conf/gitlab-registry.conf`）
   以确认哪个端口接收请求。
1. 验证请求是否正确转发到容器镜像仓库：

   ```shell
   curl --verbose --noproxy "*" https://<hostname>:<port>/v2/_catalog
   ```

   响应应包含一行带有 `Www-Authenticate: Bearer` 的内容，其中包含 `service="container_registry"`。例如：

   ```plaintext
   < HTTP/1.1 401 Unauthorized
   < Server: nginx
   < Date: Fri, 07 Mar 2025 08:24:43 GMT
   < Content-Type: application/json
   < Content-Length: 162
   < Connection: keep-alive
   < Docker-Distribution-Api-Version: registry/2.0
   < Www-Authenticate: Bearer realm="https://<hostname>/jwt/auth",service="container_registry",scope="registry:catalog:*"
   < X-Content-Type-Options: nosniff
   <
   {"errors":[{"code":"UNAUTHORIZED","message":"authentication required","detail":
   [{"Type":"registry","Class":"","Name":"catalog","ProjectPath":"","Action":"*"}]}]}
   * Connection #0 to host <hostname> left intact
   ```

<a id="error-there-are-pending-migrations"></a>

## 错误：`There are pending migrations`

在排查待处理的镜像仓库数据库迁移问题时，首先检查当前的迁移状态。要检查所有已知迁移的状态以及每个迁移是否已应用，请运行：

```shell
sudo gitlab-ctl registry-database migrate status
```

要检查所有迁移是否都已应用，请运行：

```shell
sudo gitlab-ctl registry-database migrate status --up-to-date
```

此命令仅返回 `true` 或 `false`：

- `true`：所有已知的镜像仓库数据库迁移均已应用。
- `false`：一个或多个镜像仓库数据库迁移仍处于待处理状态。

在升级之前或之后验证迁移状态，或确认镜像仓库是否因待处理迁移而被阻止时，`--up-to-date` 选项非常有用。

如果输出为 `false`，请按照 [应用数据库迁移的步骤](container_registry_metadata_database.md#apply-database-migrations) 操作。

<a id="error--x509-certificate-signed-by-unknown-authority"></a>

## 错误：`... x509: certificate signed by unknown authority`

在容器镜像仓库中使用自签名证书时，您可能会在 CI/CD 流水线作业中遇到类似错误：

```plaintext
Error response from daemon: Get registry.example.com/v1/users/: x509: certificate signed by unknown authority
```

发生此错误是因为运行命令的 Docker 守护进程期望由受信任的证书颁发机构签名的证书，而不是自签名证书。

要解决此错误，请配置 Docker 以信任自签名证书。有关 Docker 配置的帮助，
请参阅 [配置自签名证书](container_registry.md#configure-self-signed-certificates)。

更多信息，请参阅 [议题 18239](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/18239)。

<a id="docker-login-attempt-fails-with-token-signed-by-untrusted-key"></a>

## Docker 登录尝试失败，提示：'token signed by untrusted key'

[镜像仓库依赖极狐GitLab 验证凭据](container_registry.md#container-registry-architecture)
如果镜像仓库无法验证有效的登录尝试，您会收到以下错误消息：

```shell
# docker login gitlab.company.com:4567
Username: user
Password:
Error response from daemon: login attempt to https://gitlab.company.com:4567/v2/ failed with status: 401 Unauthorized
```

更具体地说，这出现在 `/var/log/gitlab/registry/current` 日志文件中：

```plaintext
level=info
msg="token signed by untrusted key with ID: "TOKE:NL6Q:7PW6:EXAM:PLET:OKEN:BG27:RCIB:D2S3:EXAM:PLET:OKEN""
level=warning msg="error authorizing context: invalid token" go.version=go1.12.7 http.request.host="gitlab.company.com:4567"
http.request.id=74613829-2655-4f96-8991-1c9fe33869b8 http.request.method=GET http.request.remoteaddr=10.72.11.20
http.request.uri="/v2/" http.request.useragent="docker/19.03.2 go/go1.12.8 git-commit/6a30dfc
kernel/3.10.0-693.2.2.el7.x86_64 os/linux arch/amd64 UpstreamClient(Docker-Client/19.03.2 \(linux\))"
```

（为便于阅读，添加了换行。）

极狐GitLab 使用证书密钥对两面的内容来加密镜像仓库的身份验证令牌。此消息表示这些内容不一致。

检查正在使用的文件：

- `grep -A6 'auth:' /var/opt/gitlab/registry/config.yml`

  ```yaml
  ## Container registry certificate
     auth:
       token:
         realm: https://gitlab.my.net/jwt/auth
         service: container_registry
         issuer: omnibus-gitlab-issuer
    -->  rootcertbundle: /var/opt/gitlab/registry/gitlab-registry.crt
         autoredirect: false
  ```

- `grep -A9 'Container Registry' /var/opt/gitlab/gitlab-rails/etc/gitlab.yml`

  ```yaml
  ## Container registry key
     registry:
       enabled: true
       host: gitlab.company.com
       port: 4567
       api_url: http://127.0.0.1:5000 # internal address to the registry, is used by GitLab to directly communicate with API
       path: /var/opt/gitlab/gitlab-rails/shared/registry
  -->  key: /var/opt/gitlab/gitlab-rails/etc/gitlab-registry.key
       issuer: omnibus-gitlab-issuer
       notification_secret:
  ```

这些 `openssl` 命令的输出应匹配，以证明证书-密钥对是匹配的：

```shell
/opt/gitlab/embedded/bin/openssl x509 -noout -modulus -in /var/opt/gitlab/registry/gitlab-registry.crt | /opt/gitlab/embedded/bin/openssl sha256
/opt/gitlab/embedded/bin/openssl rsa -noout -modulus -in /var/opt/gitlab/gitlab-rails/etc/gitlab-registry.key | /opt/gitlab/embedded/bin/openssl sha256
```

如果证书的两部分不一致，请删除这些文件并运行 `gitlab-ctl reconfigure` 以重新生成该对。如果 `/etc/gitlab/gitlab-secrets.json` 中存在现有值，则使用这些值重新创建该对。要生成新对，请在运行 `gitlab-ctl reconfigure` 之前删除 `registry` 部分（位于 `/etc/gitlab/gitlab-secrets.json` 文件中）。

如果您已使用自己的证书覆盖了自动生成的自签名对，并确保其内容一致，则可以删除
`/etc/gitlab/gitlab-secrets.json` 中的 'registry' 部分并运行 `gitlab-ctl reconfigure`。

<a id="aws-s3-with-the-gitlab-registry-error-when-pushing-large-images"></a>

## 使用 AWS S3 和极狐GitLab 镜像仓库时，推送大型镜像出错

将 AWS S3 与极狐GitLab 镜像仓库一起使用时，推送大型镜像时可能会出错。请在镜像仓库日志中查找以下错误：

```plaintext
level=error msg="response completed with error" err.code=unknown err.detail="unexpected EOF" err.message="unknown error"
```

要解决此错误，请在镜像仓库配置中指定一个 `chunksize` 值。从 `25000000`（25 MB）到 `50000000`（50 MB）之间的值开始。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   registry['storage'] = {
     's3' => {
       'accesskey' => 'AKIAKIAKI',
       'secretkey' => 'secret123',
       'bucket'    => 'gitlab-registry-bucket-AKIAKIAKI',
       'chunksize' => 25000000
     }
   }
   ```

1. 保存文件并 [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `config/gitlab.yml`：

   ```yaml
   storage:
     s3:
       accesskey: 'AKIAKIAKI'
       secretkey: 'secret123'
       bucket: 'gitlab-registry-bucket-AKIAKIAKI'
       chunksize: 25000000
   ```

1. 保存文件并 [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations) 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="error-403-forbidden-when-pulling-images-after-upgrading-to-gitlab-190"></a>

## 错误：升级到极狐GitLab 19.0 后拉取镜像时出现 `403 Forbidden`

在极狐GitLab 19.0 中，`s3` 和 `s3aws` 容器镜像仓库存储驱动名称成为
`s3_v2` 驱动的别名，后者使用 AWS SDK v2。在 AWS S3 上，客户端下载 blob 时遵循的预签名 URL
可能会从全局 `s3.amazonaws.com` 主机名更改为区域主机名，例如
`s3.us-east-1.amazonaws.com`。

如果代理、防火墙或安全 Web 网关仅允许 `s3.amazonaws.com`，则重定向到区域主机名会被阻止，镜像拉取会因 `403 Forbidden` 而失败。`403 Forbidden` 响应来自过滤设备，而不是来自 Amazon S3 或镜像仓库，因此镜像仓库日志显示 blob 请求成功完成。

要确认此原因，请请求一个 blob 并检查重定向目标：

```shell
curl --head "https://gitlab.example.com:5050/v2/mygroup/myproject/myimage/blobs/<digest>"
```

检查 `location` 响应头。如果该响应头中的主机名不被您的出口控制允许，请将您存储桶区域的区域主机名添加到过滤设备上的允许名单中。使用特定的区域主机名，而不是覆盖所有 Amazon S3 的通配符。

或者，将 `regionendpoint` 设置为 S3 VPC 端点或其他固定端点，以便预签名 URL 使用您控制的主机名。更多信息，请参阅
[使用对象存储](container_registry.md#use-object-storage)。

<a id="supporting-older-docker-clients"></a>

## 支持旧版 Docker 客户端

极狐GitLab 附带的 Docker 容器镜像仓库默认禁用 schema1 清单。
如果您仍在使用旧版 Docker 客户端（1.9 或更早版本），您可能会在推送镜像时遇到错误。请参阅
[议题 4145](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/4145) 了解更多详情。

您可以添加一个配置选项以实现向后兼容。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   registry['compatibility_schema1_enabled'] = true
   ```

1. 保存文件并 [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑您部署镜像仓库时创建的 YAML 配置文件。添加以下片段：

   ```yaml
   compatibility:
       schema1:
           enabled: true
   ```

1. 重启镜像仓库以使更改生效。

{{< /tab >}}

{{< /tabs >}}

<a id="docker-connection-error"></a>

## Docker 连接错误

当群组、项目或分支名称中包含特殊字符时，可能会发生 Docker 连接错误。特殊字符可能包括：

- 前导下划线
- 尾随连字符/破折号
- 双连字符/破折号

要解决此问题，您可以 [更改群组路径](../../user/group/manage.md#change-a-groups-path)、
[更改项目路径](../../user/project/working_with_projects.md#rename-a-repository) 或更改
分支名称。另一种选择是创建 [推送规则](../../user/project/repository/push_rules.md) 以防止
整个实例出现此错误。

<a id="image-push-errors"></a>

## 镜像推送错误

即使 `docker login` 成功，您在推送 Docker 镜像时也可能陷入重试循环。

当 NGINX 未正确将请求头转发到镜像仓库时，通常会发生此问题，尤其是在 SSL 卸载到第三方反向代理的自定义设置中。

更多信息，请参阅 [通过 NGINX 代理推送 Docker 时尝试发送 32B 层失败 #970](https://github.com/distribution/distribution/issues/970)。

要解决此问题，请更新您的 NGINX 配置以在镜像仓库中启用相对 URL：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   registry['env'] = {
     "REGISTRY_HTTP_RELATIVEURLS" => true
   }
   ```

1. 保存文件并 [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑您部署镜像仓库时创建的 YAML 配置文件。添加以下片段：

   ```yaml
   http:
       relativeurls: true
   ```

1. 保存文件并 [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations) 以使更改生效。

{{< /tab >}}

{{< tab title="Docker Compose" >}}

1. 编辑您的 `docker-compose.yaml` 文件：

   ```yaml
   GITLAB_OMNIBUS_CONFIG: |
     registry['env'] = {
       "REGISTRY_HTTP_RELATIVEURLS" => true
     }
   ```

1. 如果问题仍然存在，请确保两个 URL 都使用 HTTPS：

   ```yaml
   GITLAB_OMNIBUS_CONFIG: |
     external_url 'https://git.example.com'
     registry_external_url 'https://git.example.com:5050'
   ```

1. 保存文件并重启容器：

   ```shell
   sudo docker restart gitlab
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="enable-the-registry-debug-server"></a>

## 启用镜像仓库调试服务器

您可以使用容器镜像仓库调试服务器来诊断问题。调试端点可以监控指标和健康状况，以及进行分析。

> [!warning]
> 调试端点可能提供敏感信息。
> 在生产环境中，必须限制对调试端点的访问。

可以通过在您的 `gitlab.rb` 配置中设置镜像仓库调试地址来启用可选的调试服务器。

```ruby
registry['debug_addr'] = "localhost:5001"
```

添加设置后，[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以应用更改。

使用 curl 从调试服务器请求调试输出：

```shell
curl "localhost:5001/debug/health"
curl "localhost:5001/debug/vars"
```

<a id="prometheus-metrics"></a>

### Prometheus 指标

Prometheus 提供指标，您可以使用这些指标来监控和排查容器镜像仓库中的性能问题。

以下部分：

- 向您展示如何启用 Prometheus 指标
- 按组件分类列出容器镜像仓库导出的所有 Prometheus 指标

<a id="enable-prometheus-metrics"></a>

#### 启用 Prometheus 指标

先决条件：

- 您必须 [启用镜像仓库调试服务器](#enable-the-registry-debug-server)。

要启用 Prometheus 指标，请在 `gitlab.rb` 中添加以下配置：

```ruby
# Enable Prometheus metrics
registry['debug'] = {
  'prometheus' => {
    'enabled' => true,
    'path' => '/metrics'
  }
}
```

要应用更改，请 [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

使用 curl 从调试服务器请求指标：

```shell
curl "localhost:5001/metrics"
```

<a id="counters"></a>

#### 计数器

| 指标名称 | 描述 | 标签 | 标签值 |
|-------------|-------------|--------|--------------|
| `registry_notifications_events_total` | 事件总数。 | `type`, `action`, `artifact`, `endpoint` | `type`: `Successes`, `Failures`, `Events`, `Dropped` |
| `registry_notifications_status_total` | 从通知端点收到的每个状态码的 HTTP 响应数。 | `code`, `endpoint` | `code`: HTTP 状态码（例如，`200 OK` 或 `404 Not Found`） |
| `registry_notifications_errors_total` | 发送期间出错的事件数。发送请求可能会重试。 | `endpoint` | 字符串：`'...'` |
| `registry_notifications_delivery_total` | 已送达或丢失的事件数。一旦重试次数用尽，事件即视为丢失。 | `endpoint`, `delivery_type` | `delivery_type`: `delivered`, `lost` |

<a id="gauges"></a>

#### 仪表

| 指标名称 | 描述 | 标签 | 标签值 |
|-------------|-------------|--------|--------------|
| `registry_notifications_pending` | 队列中待处理事件的仪表，以队列长度表示。 | `endpoint` | 字符串：`'...'` |

<a id="histograms"></a>

#### 直方图

| 指标名称 | 描述 | 标签 | 桶 |
|-------------|-------------|--------|---------|
| `registry_notifications_retries_count` | 累计投递重试次数的直方图。 | `endpoint` | `[0, 1, 2, 3, 5, 10, 15, 20, 30, 50]` |
| `registry_notifications_http_latency_seconds` | HTTP 投递延迟的直方图。 | `endpoint` | `[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10, 25, 50, 100]`（秒） |
| `registry_notifications_total_latency_seconds` | 总投递延迟的直方图。 | `endpoint` | `[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10, 25, 50, 100]`（秒） |

<a id="batched-background-migration-bbm-metrics"></a>

#### 批量后台迁移（BBM）指标

<a id="counters-1"></a>

##### 计数器

| 指标名称 | 描述 | 标签 | 标签值 |
|-------------|-------------|--------|--------------|
| `registry_bbm_runs_total` | 批量迁移工作进程运行的计数器。 | 无 | 无 |
| `registry_bbm_migrated_tuples_total` | 已迁移的批量迁移记录总数的计数器。 | `migration_name`, `migration_id` | 字符串：`'...'` |

<a id="gauges-1"></a>

##### 仪表

| 指标名称 | 描述 | 标签 | 标签值 |
|-------------|-------------|--------|--------------|
| `registry_bbm_job_batch_size` | 批量迁移作业的批次大小的仪表。 | `migration_name`, `migration_id` | 字符串：`'...'` |
| `registry_database_bbm_progress_percent` | 后台迁移进度百分比（0-100）。 | `migration_id`, `migration_name`, `status` | 字符串：`'...'` |

<a id="histograms-1"></a>

##### 直方图

| 指标名称 | 描述 | 标签 | 桶 |
|-------------|-------------|--------|---------|
| `registry_bbm_run_duration_seconds` | 批量迁移工作进程运行延迟的直方图。 | 无 | `[0.5, 1, 2, 5, 10, 15, 30, 60, 120, 300, 600, 900, 1800, 3600]`（0.5 秒至 1 小时） |
| `registry_bbm_job_duration_seconds` | 批量迁移作业延迟的直方图。 | `migration_name`, `migration_id` | `[0.5, 1, 2, 5, 10, 15, 30, 60, 120, 300, 600, 900, 1800, 3600]`（0.5 秒至 1 小时） |
| `registry_bbm_query_duration_seconds` | 批量迁移数据库查询延迟的直方图。 | `migration_name`, `migration_id` | `[0.5, 1, 2, 5, 10, 15, 30, 60, 120, 300, 600, 900, 1800, 3600]`（0.5 秒至 1 小时） |
| `registry_bbm_sleep_duration_seconds` | BBM 工作进程运行之间休眠时长的直方图。 | `worker` | `[0.5, 1, 5, 15, 30, 60, 300, 600, 900, 1800, 3600, 7200, 10800, 21600, 43200, 86400]`（500 毫秒至 24 小时） |

<a id="database-metrics"></a>

#### 数据库指标

<a id="counters-2"></a>

##### 计数器

| 指标名称 | 描述 | 标签 | 标签值 |
|-------------|-------------|--------|--------------|
| `registry_database_queries_total` | 数据库查询的计数器。 | `name` | 字符串：`'...'` |
| `registry_database_lb_lsn_cache_hits_total` | 数据库负载均衡 LSN 缓存命中和未命中的计数器。 | `result` | `result`: `hit`, `miss` |
| `registry_database_lb_pool_events_total` | 从数据库负载均衡器池中添加或移除副本的计数器。 | `event`, `reason` | `event`: `replica_added`, `replica_removed`, `replica_quarantined`, `replica_reintegrated`<br>`reason`: `replication_lag`, `connectivity`, `removed_from_dns`, `discovered` |
| `registry_database_lb_targets_total` | 数据库负载均衡期间主节点与副本节点目标选举的计数器。 | `target_type`, `fallback`, `reason` | `target_type`: `primary`, `replica`<br>`fallback`: `true`, `false`<br>`reason`: `selected`, `no_cache`, `no_replica`, `error`, `not_up_to_date`, `all_quarantined` |

<a id="gauges-2"></a>

##### 仪表

| 指标名称 | 描述 | 标签 | 标签值 |
|-------------|-------------|--------|--------------|
| `registry_database_lb_pool_size` | 负载均衡器池中当前副本数的仪表。 | 无 | 无 |
| `registry_database_lb_pool_status` | 负载均衡器池中每个副本当前状态的仪表。 | `replica`, `status` | `status`: `online`, `quarantined` |
| `registry_database_lb_lag_bytes` | 每个副本的复制延迟（以字节为单位）的仪表。 | `replica` | 字符串：`'...'` |
| `registry_database_migrations_total` | 数据库迁移总数（已应用 + 待处理）的仪表 | `migration_type` | `migration_type`: `pre_deployment`, `post_deployment` |
| `registry_database_rows` | 由 `query_name` 标签定义的数据库表中的行数的仪表。 | `query_name` | `query_name`: `gc_blob_review_queue`, `gc_manifest_review_queue`, `gc_blob_review_queue_overdue`, `gc_manifest_review_queue_overdue`, `applied_pre_migrations`, `applied_post_migrations` |

<a id="histograms-2"></a>

##### 直方图

| 指标名称 | 描述 | 标签 | 桶 |
|-------------|-------------|--------|---------|
| `registry_database_query_duration_seconds` | 数据库查询延迟的直方图。 | `name` | Prometheus 默认桶。 <sup>1</sup> |
| `registry_database_lb_lsn_cache_operation_duration_seconds` | 数据库负载均衡 LSN 缓存操作延迟的直方图。 | `operation`, `error` | `operation`: `set`, `get`<br>`error`: `true`, `false`<br>Prometheus 默认桶。 <sup>1</sup> |
| `registry_database_lb_lookup_seconds` | 数据库负载均衡 DNS 查找延迟的直方图。 | `lookup_type`, `error` | `lookup_type`: `srv`, `host`<br>`error`: `true`, `false`<br>Prometheus 默认桶。 <sup>1</sup>  |
| `registry_database_lb_lag_seconds` | 每个副本的复制延迟（以秒为单位）的直方图。 | `replica` | `[0.001, 0.01, 0.1, 0.5, 1, 5, 10, 20, 30, 60]`（1 毫秒至 60 秒） |
| `registry_database_row_count_collection_duration_seconds` | 单次运行中收集所有数据库行数查询的总时长的直方图。 | 无 | `[0.1, 0.5, 1, 2, 5, 10, 30, 60]`（100 毫秒至 60 秒） |

**脚注**：

1. Prometheus 默认桶值：`[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10]`（秒）

<a id="garbage-collection-gc-metrics"></a>

#### 垃圾回收（GC）指标

<a id="counters-3"></a>

##### 计数器

| 指标名称 | 描述 | 标签 | 标签值 |
|-------------|-------------|--------|--------------|
| `registry_gc_runs_total` | 在线 GC 工作进程运行的计数器。 | `worker`, `noop`, `error`, `dangling`, `event` | `noop`: `true`, `false`<br>`error`: `true`, `false`<br>`dangling`: `true`, `false` |
| `registry_gc_deletes_total` | 在线 GC 期间删除的产物数量的计数器。 | `backend`, `artifact` | `backend`: `storage`, `database`<br>`artifact`: `blob`, `manifest` |
| `registry_gc_storage_deleted_bytes_total` | 在线 GC 期间从存储中删除的字节数的计数器。 | `media_type` | 字符串：`'...'` |
| `registry_gc_postpones_total` | 在线 GC 审查延期的计数器。 | `worker` | 字符串：`'...'` |

<a id="histograms-3"></a>

##### 直方图

| 指标名称 | 描述 | 标签 | 桶 |
|-------------|-------------|--------|---------|
| `registry_gc_run_duration_seconds` | 在线 GC 工作进程运行延迟的直方图。 | `worker`, `noop`, `error`, `dangling`, `event` | `noop`: `true`, `false`<br>`error`: `true`, `false`<br>`dangling`: `true`, `false`<br>Prometheus 默认桶。 <sup>1</sup> |
| `registry_gc_delete_duration_seconds` | 在线 GC 期间产物删除延迟的直方图。 | `backend`, `artifact`, `error` | `backend`: `storage`, `database`<br>`artifact`: `blob`, `manifest`<br>`error`: `true`, `false`<br>Prometheus 默认桶。 <sup>1</sup> |
| `registry_gc_sleep_duration_seconds` | 在线 GC 工作进程运行之间休眠时长的直方图。 | `worker` | `[0.5, 1, 5, 15, 30, 60, 300, 600, 900, 1800, 3600, 7200, 10800, 21600, 43200, 86400]`（500 毫秒至 24 小时） |

**脚注**：

1. Prometheus 默认桶值：`[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10]`（秒）

<a id="storage-metrics"></a>

#### 存储指标

<a id="counters-4"></a>

##### 计数器

| 指标名称 | 描述 | 标签 | 标签值 |
|-------------|-------------|--------|--------------|
| `registry_storage_cdn_redirects_total` | blob 下载的 CDN 重定向计数器。 | `backend`, `bypass`, `bypass_reason` | `bypass`: `true`, `false` |
| `registry_storage_rate_limit_total` | 命中速率限制的存储驱动请求计数器。 | 无 | 无 |
| `registry_storage_storage_backend_retries_total` | 与存储后端通信时重试次数的计数器。 | `retry_type` | `retry_type`: `native`, `custom` |
| `registry_storage_urlcache_requests_total` | URL 缓存中间件请求的计数器。 | `result`, `reason` | `result`: `hit`, `miss` |
| `registry_storage_access_tracker_dropped_events` | 访问跟踪器中因超时而丢弃的事件计数器。 | 无 | 无 |

<a id="gauges-3"></a>

##### 仪表

| 指标名称 | 描述 | 标签 | 标签值 |
|-------------|-------------|--------|--------------|
| `registry_storage_object_accesses_topn` | 访问频率最高的前 N 个对象的总访问次数。 | `top_n` | `top_n`: `1`, `10`, `100`, `1000`, `10000`, `all` |

<a id="histograms-4"></a>

##### 直方图

| 指标名称 | 描述 | 标签 | 桶 |
|-------------|-------------|--------|---------|
| `registry_storage_blob_download_bytes` | 存储后端 blob 下载大小的直方图。 | `redirect` | `redirect`: `true`, `false`<br>`[524288, 1048576, 67108864, 134217728, 268435456, 536870912, 1073741824, 2147483648, 3221225472, 4294967296, 5368709120, 6442450944, 7516192768, 8589934592, 9663676416, 10737418240, 21474836480, 32212254720, 42949672960, 53687091200]`（512 KiB 至 50 GiB） |
| `registry_storage_blob_upload_bytes` | 存储后端新 blob 上传字节数的直方图。 | 无 | `[524288, 1048576, 67108864, 134217728, 268435456, 536870912, 1073741824, 2147483648, 3221225472, 4294967296, 5368709120, 6442450944, 7516192768, 8589934592, 9663676416, 10737418240, 21474836480, 32212254720, 42949672960, 53687091200]`（512 KiB 至 50 GiB） |
| `registry_storage_urlcache_object_size` | URL 缓存中对象大小的直方图。 | 无 | `[100, 250, 500, 750, 1000, 1500, 2048, 3072, 5120, 10240]`（100 字节至 10 KiB） |
| `registry_storage_object_accesses_distribution` | 所有对象的访问次数分布。 | 无 | 指数桶：`[10, 20, 40, 80, 160, 320, 640, 1280, 2560, 5120, 10240]` |

<a id="enable-registry-debug-logs"></a>

## 启用镜像仓库调试日志

您可以启用调试日志来帮助排查容器镜像仓库的问题。

> [!warning]
> 调试日志可能包含敏感信息，例如身份验证详细信息、令牌或代码仓库信息。
> 仅在必要时启用调试日志，并在故障排除完成后将其禁用。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/var/opt/gitlab/registry/config.yml`：

   ```yaml
   level: debug
   ```

1. 保存文件并重启镜像仓库：

   ```shell
   sudo gitlab-ctl restart registry
   ```

此配置是临时的，在您运行 `gitlab-ctl reconfigure` 时会被丢弃。

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   registry:
     log:
       level: debug
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab --namespace <namespace>
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="enable-registry-prometheus-metrics"></a>

### 启用镜像仓库 Prometheus 指标

如果调试服务器已启用，您也可以启用 Prometheus 指标。此端点公开与几乎所有镜像仓库操作相关的高度详细的遥测数据。

```ruby
registry['debug'] = {
  'prometheus' => {
    'enabled' => true,
    'path' => '/metrics'
  }
}
```

使用 curl 从 Prometheus 请求调试输出：

```shell
curl "localhost:5001/debug/metrics"
```

<a id="tags-with-an-empty-name"></a>

## 名称为空的标签

如果使用 [AWS DataSync](https://aws.amazon.com/datasync/)
将镜像仓库数据复制到 S3 存储桶或在其间复制，则会在目标存储桶中每个容器仓库的根路径下创建一个空元数据对象。这会导致镜像仓库将此类文件解释为在极狐GitLab UI 和 API 中显示为无名称的标签。更多信息，请参阅
[此议题](https://gitlab.com/gitlab-org/container-registry/-/issues/341)。

要解决此问题，您可以执行以下两种操作之一：

- 使用 AWS CLI [`rm`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3/rm.html)
  命令从每个受影响仓库的根路径中删除空对象。请特别
  注意尾随的 `/`，并确保不要使用 `--recursive` 选项：

  ```shell
  aws s3 rm s3://<bucket>/docker/registry/v2/repositories/<path to repository>/
  ```

- 使用 AWS CLI [`sync`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3/sync.html)
  命令将镜像仓库数据复制到新存储桶，并配置镜像仓库使用该存储桶。这样
  会将空对象留在原处。

<a id="advanced-troubleshooting"></a>

## 高级故障排除

我们使用一个具体示例来说明如何诊断 S3 设置的问题。

<a id="investigate-a-cleanup-policy"></a>

### 调查清理策略

如果您不确定清理策略为何删除或未删除某个标签，请通过从 [Rails 控制台](../operations/rails_console.md) 运行以下脚本，逐行执行该策略。这有助于诊断策略问题。

```ruby
repo = ContainerRepository.find(<repository_id>)
policy = repo.project.container_expiration_policy

tags = repo.tags
tags.map(&:name)

tags.reject!(&:latest?)
tags.map(&:name)

regex_delete = ::Gitlab::UntrustedRegexp.new("\\A#{policy.name_regex}\\z")
regex_retain = ::Gitlab::UntrustedRegexp.new("\\A#{policy.name_regex_keep}\\z")

tags.select! { |tag| regex_delete.match?(tag.name) && !regex_retain.match?(tag.name) }

tags.map(&:name)

now = DateTime.current
tags.sort_by! { |tag| tag.created_at || now }.reverse! # Lengthy operation

tags = tags.drop(policy.keep_n)
tags.map(&:name)

older_than_timestamp = ChronicDuration.parse(policy.older_than).seconds.ago

tags.select! { |tag| tag.created_at && tag.created_at < older_than_timestamp }

tags.map(&:name)
```

- 该脚本构建要删除的标签列表（`tags`）。
- `tags.map(&:name)` 打印要删除的标签列表。这可能是一个耗时的操作。
- 在每个过滤器之后，检查 `tags` 列表，看它是否包含要销毁的预期标签。

<a id="unexpected-403-error-during-push"></a>

### 推送期间出现意外的 403 错误

用户尝试启用 S3 支持的镜像仓库。`docker login` 步骤正常。但是，在推送镜像时，输出显示：

```plaintext
The push refers to a repository [s3-testing.myregistry.com:5050/root/docker-test/docker-image]
dc5e59c14160: Pushing [==================================================>] 14.85 kB
03c20c1a019a: Pushing [==================================================>] 2.048 kB
a08f14ef632e: Pushing [==================================================>] 2.048 kB
228950524c88: Pushing 2.048 kB
6a8ecde4cc03: Pushing [==>                                                ] 9.901 MB/205.7 MB
5f70bf18a086: Pushing 1.024 kB
737f40e80b7f: Waiting
82b57dbc5385: Waiting
19429b698a22: Waiting
9436069b92a3: Waiting
error parsing HTTP 403 response body: unexpected end of JSON input: ""
```

此错误不明确，因为不清楚 403 是来自 GitLab Rails 应用程序、Docker 镜像仓库还是其他组件。在这种情况下，因为我们知道登录成功，所以可能需要查看客户端和镜像仓库之间的通信。

Docker 客户端和镜像仓库之间的 REST API 在
[Docker 文档](https://distribution.github.io/distribution/spec/api/) 中有描述。通常，人们会直接
使用 Wireshark 或 tcpdump 捕获流量，看看哪里出了问题。但是，由于 Docker 客户端和服务器之间的所有通信都是通过 HTTPS 进行的，即使您知道私钥，快速解密流量也有些困难。我们可以怎么做呢？

一种方法是设置一个
[不安全镜像仓库](https://distribution.github.io/distribution/about/insecure/) 来禁用 HTTPS。这可能会引入
安全漏洞，仅建议用于本地测试。如果您有生产系统并且不能或不想这样做，还有另一种方法：
使用 mitmproxy，即中间人代理。

<a id="mitmproxy"></a>

### mitmproxy

[mitmproxy](https://mitmproxy.org/) 允许您在客户端和服务器之间放置代理以检查所有流量。一个问题是您的系统需要信任 mitmproxy SSL 证书才能使其工作。

以下安装说明假设您运行的是 Ubuntu：

1. [安装 mitmproxy](https://docs.mitmproxy.org/stable/overview-installation/)。
1. 运行 `mitmproxy --port 9000` 以生成其证书。
   输入 <kbd>Control</kbd>-<kbd>C</kbd> 退出。
1. 将 `~/.mitmproxy` 中的证书安装到您的系统：

   ```shell
   sudo cp ~/.mitmproxy/mitmproxy-ca-cert.pem /usr/local/share/ca-certificates/mitmproxy-ca-cert.crt
   sudo update-ca-certificates
   ```

如果成功，输出应指示已添加证书：

```shell
Updating certificates in /etc/ssl/certs... 1 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d....done.
```

要验证证书是否正确安装，请运行：

```shell
mitmproxy --listen-port 9000
```

此命令在端口 `9000` 上运行 mitmproxy。在另一个窗口中，运行：

```shell
curl --proxy "http://localhost:9000" "https://httpbin.org/status/200"
```

如果一切设置正确，mitmproxy 窗口会显示信息，并且 curl 命令不会产生错误。

<a id="running-the-docker-daemon-with-a-proxy"></a>

### 使用代理运行 Docker 守护进程

为了让 Docker 通过代理连接，您必须使用正确的环境变量启动 Docker 守护进程。最简单的方法是关闭 Docker（例如 `sudo initctl stop docker`），然后手动运行 Docker。以 root 身份运行：

```shell
export HTTP_PROXY="http://localhost:9000"
export HTTPS_PROXY="http://localhost:9000"
docker daemon --debug # or dockerd --debug
```

此命令启动 Docker 守护进程，并通过 mitmproxy 代理所有连接。

<a id="running-the-docker-client"></a>

### 运行 Docker 客户端

现在我们已经运行了 mitmproxy 和 Docker，我们可以尝试登录并推送容器镜像。您可能需要以 root 身份执行此操作。例如：

```shell
docker login example.s3.amazonaws.com:5050
docker push example.s3.amazonaws.com:5050/root/docker-test/docker-image
```

在上一个示例中，我们在 mitmproxy 窗口上看到以下跟踪：

```plaintext
PUT https://example.s3.amazonaws.com:4567/v2/root/docker-test/blobs/uploads/(UUID)/(QUERYSTRING)
    ← 201 text/plain [no content] 661ms
HEAD https://example.s3.amazonaws.com:4567/v2/root/docker-test/blobs/sha256:(SHA)
    ← 307 application/octet-stream [no content] 93ms
HEAD https://example.s3.amazonaws.com:4567/v2/root/docker-test/blobs/sha256:(SHA)
    ← 307 application/octet-stream [no content] 101ms
HEAD https://example.s3.amazonaws.com:4567/v2/root/docker-test/blobs/sha256:(SHA)
    ← 307 application/octet-stream [no content] 87ms
HEAD https://amazonaws.example.com/docker/registry/vs/blobs/sha256/dd/(UUID)/data(QUERYSTRING)
    ← 403 application/xml [no content] 80ms
HEAD https://amazonaws.example.com/docker/registry/vs/blobs/sha256/dd/(UUID)/data(QUERYSTRING)
    ← 403 application/xml [no content] 62ms
```

此输出显示：

- 初始 PUT 请求成功，状态码为 `201`。
- `201` 将客户端重定向到 Amazon S3 存储桶。
- 对 AWS 存储桶的 HEAD 请求报告了 `403 Unauthorized`。

这意味着什么？这强烈表明 S3 用户没有正确的
[执行 HEAD 请求的权限](https://docs.aws.amazon.com/AmazonS3/latest/API/API_HeadObject.html)。
解决方案：再次检查 [IAM 权限](https://distribution.github.io/distribution/storage-drivers/s3/)。
设置正确的权限后，错误消失了。

<a id="missing-gitlab-registrykey-prevents-container-repository-deletion"></a>

## 缺少 `gitlab-registry.key` 阻止容器仓库删除

如果您禁用极狐GitLab 实例的容器镜像仓库并尝试删除具有容器仓库的项目，则会发生以下错误：

```plaintext
Errno::ENOENT: No such file or directory @ rb_sysopen - /var/opt/gitlab/gitlab-rails/etc/gitlab-registry.key
```

在这种情况下，请按照以下步骤操作：

1. 在您的 `gitlab.rb` 中临时启用容器镜像仓库的实例级设置：

   ```ruby
   gitlab_rails['registry_enabled'] = true
   ```

1. 保存文件并 [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效。
1. 再次尝试删除。

如果您仍然无法使用常用方法删除仓库，您可以使用
[GitLab Rails 控制台](../operations/rails_console.md)
强制删除项目：

```ruby
# Path to the project you'd like to remove
prj = Project.find_by_full_path(<project_path>)

# The following will delete the project's container registry, so be sure to double-check the path beforehand!
if prj.has_container_registry_tags?
  prj.container_repositories.each { |p| p.destroy }
end
```

<a id="registry-service-listens-on-ipv6-address-instead-of-ipv4"></a>

## 镜像仓库服务监听 IPv6 地址而不是 IPv4

如果 `localhost` 主机名在您的极狐GitLab 服务器上解析为 IPv6 回环地址（`::1`），而极狐GitLab 期望镜像仓库服务在 IPv4 回环地址（`127.0.0.1`）上可用，您可能会看到以下错误：

```plaintext
request: "GET /v2/ HTTP/1.1", upstream: "http://[::1]:5000/v2/", host: "registry.example.com:5005"
[error] 1201#0: *13442797 connect() failed (111: Connection refused) while connecting to upstream, client: x.x.x.x, server: registry.example.com, request: "GET /v2/<path> HTTP/1.1", upstream: "http://[::1]:5000/v2/<path>", host: "registry.example.com:5005"
```

要修复此错误，请在 `/etc/gitlab/gitlab.rb` 中将 `registry['registry_http_addr']` 更改为 IPv4 地址。例如：

```ruby
registry['registry_http_addr'] = "127.0.0.1:5000"
```

更多详情，请参阅 [议题 5449](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/5449)。

<a id="push-failures-and-high-cpu-usage-with-google-cloud-storage-gcs"></a>

## 使用 Google Cloud Storage (GCS) 时推送失败且 CPU 使用率高

当向使用 GCS 作为后端的镜像仓库推送容器镜像时，您可能会收到 `502 Bad Gateway` 错误。推送大型镜像时，镜像仓库也可能遇到 CPU 使用率飙升。

当镜像仓库使用 HTTP/2 协议与 GCS 通信时，会发生此问题。

变通方法是通过将 `GODEBUG` 环境变量设置为 `http2client=0` 来在镜像仓库部署中禁用 HTTP/2。

更多信息，请参阅 [议题 1425](https://gitlab.com/gitlab-org/container-registry/-/issues/1425)。
