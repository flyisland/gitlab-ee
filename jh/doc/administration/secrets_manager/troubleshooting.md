---
stage: Security Platform
group: Secrets Manager OpenBao
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 OpenBao
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Status: 测试版

{{< /details >}}

有关恢复密钥任务和根令牌生成，请参阅[恢复密钥管理](recovery_key.md)。有关 Geo 故障转移，请参阅 [Geo 灾难恢复](../geo/disaster_recovery/_index.md#step-4-optional-promote-the-openbao-ha-cluster)。

<a id="where-openbao-runs"></a>

## OpenBao 的运行位置

OpenBao 始终在 Kubernetes 中运行，即使极狐GitLab 使用 Linux 软件包也是如此。命名空间和
部署名称取决于安装方式：

| 安装方式 | 命名空间 | 部署       | Pod 容器    |
|---------------------|-----------|------------------|------------------|
| Cloud Native GitLab | `gitlab`  | `gitlab-openbao` | `openbao-server` |
| Linux 软件包       | `openbao` | `openbao`        | `openbao-server` |

这些示例使用 Cloud Native 命名空间 `gitlab`。对于 Linux 软件包
安装，请在 `kubectl` 命令中将 `gitlab` 替换为 `openbao`。

OpenBao Pod 带有标签 `app.kubernetes.io/name=openbao`。活动节点还带有
`openbao-active=true`。

<a id="find-openbao-logs"></a>

## 查找 OpenBao 日志

使用 `kubectl logs` 读取 OpenBao 日志。相关的 GitLab Rails 和 Sidekiq 日志
单独存储，具体取决于安装方式：

| 来源         | Cloud Native GitLab                              | Linux 软件包                                      |
|----------------|--------------------------------------------------|----------------------------------------------------|
| OpenBao 服务器 | `openbao-server` 容器上的 `kubectl logs` | `openbao-server` 容器上的 `kubectl logs`   |
| GitLab Rails   | `webservice` Pod 上的 `kubectl logs`          | `/var/log/gitlab/gitlab-rails/production_json.log` |
| Sidekiq        | `sidekiq` Pod 上的 `kubectl logs`             | `/var/log/gitlab/sidekiq/current`                  |
| 极狐GitLab Runner  | 极狐GitLab UI 中的 CI/CD 作业日志                   | 极狐GitLab UI 中的 CI/CD 作业日志                     |

OpenBao 会将审计事件发送到极狐GitLab，同时也会将其写入 OpenBao Pod 日志。

<a id="find-the-openbao-pods"></a>

### 查找 OpenBao Pod

要列出 OpenBao Pod 并查看哪个节点处于活动状态：

```shell
kubectl get pods -n gitlab -l app.kubernetes.io/name=openbao \
  --label-columns openbao-active,openbao-sealed
```

`OPENBAO-ACTIVE` 设置为 `true`的 Pod 是活动节点。其他节点为备用节点。

<a id="check-openbao-status"></a>

### 检查 OpenBao 状态

OpenBao 必须解封才能处理请求。要进行检查，请在 Pod 中运行 `bao status`：

```shell
OPENBAO_POD=$(kubectl get pods -n gitlab -l app.kubernetes.io/name=openbao -o name | head -1)
kubectl exec -n gitlab "$OPENBAO_POD" -c openbao-server -- \
  sh -c "BAO_ADDR=http://127.0.0.1:8200 bao status"
```

在输出中，`Sealed` 必须为 `false`。活动节点显示 `HA Mode    active`，备用节点显示 `HA Mode    standby`：

```plaintext
Seal Type       static
Initialized     true
Sealed          false
Storage Type    postgresql
HA Enabled      true
HA Mode         active
```

`sys/seal-status` 端点报告的状态与 `"sealed":false` 相同：

```shell
kubectl exec -n gitlab "$OPENBAO_POD" -c openbao-server -- \
  sh -c "BAO_ADDR=http://127.0.0.1:8200 bao read sys/seal-status"
```

> [!note]
> Pod 中存在 `bao` 二进制文件。在 Pod 内部进行端点查询时，请使用 `bao read`。

在日志中，成功解封的节点会记录 `vault is unsealed`。活动节点会记录 `acquired lock, enabling active operation`，备用节点会记录 `entering standby mode`：

```shell
OPENBAO_POD=$(kubectl get pods -n gitlab -l app.kubernetes.io/name=openbao -o name | head -1)
kubectl logs -n gitlab "$OPENBAO_POD" -c openbao-server \
  | grep -E "acquired lock, enabling active operation|entering standby mode"
```

<a id="find-errors-in-a-time-window"></a>

### 查找某个时间窗口内的错误

要读取某个时间窗口内的 OpenBao 日志，请使用 `--since`：

```shell
OPENBAO_POD=$(kubectl get pods -n gitlab -l app.kubernetes.io/name=openbao -o name | head -1)
kubectl logs -n gitlab "$OPENBAO_POD" -c openbao-server --since=30m \
  | grep -iE "error|warn|failed"
```

对于 Linux 软件包安装，请按时间搜索 Rails 和 Sidekiq 日志文件。日志为 JSON 格式，每行一个事件。

> [!note]
> OpenBao 将所有输出写入标准错误，因此某些日志平台会将每一行都标记为错误。
> 请以消息正文中的级别（`[info]`、`[warn]`）为准，而不是平台的标签。

<a id="gitlab-rails-logs"></a>

### GitLab Rails 日志

Rails 日志涵盖来自 UI 和 GraphQL API 的密钥操作，以及来自
OpenBao 的审计回调。

对于 Cloud Native 安装：

```shell
kubectl logs -n gitlab -l app=webservice -c webservice \
  | grep -E "Projects::SecretsController|Groups::SecretsController|secrets_manager/audit_logs"
```

对于 Linux 软件包安装：

```shell
grep -E "Projects::SecretsController|Groups::SecretsController|secrets_manager/audit_logs" \
  /var/log/gitlab/gitlab-rails/production_json.log
```

GraphQL 操作会显示 `caller_id`，例如 `graphql:createProjectSecret` 或 `graphql:getGroupSecrets`。审计回调显示为路径
`/api/v4/internal/secrets_manager/audit_logs`。

<a id="sidekiq-logs"></a>

### Sidekiq 日志

负责预配、取消预配和维护密钥管理器记录的工作进程在 `SecretsManagement::` 命名空间下运行。

对于 Cloud Native 安装：

```shell
kubectl logs -n gitlab -l app=sidekiq -c sidekiq | grep "SecretsManagement::"
```

对于 Linux 软件包安装：

```shell
grep "SecretsManagement::" /var/log/gitlab/sidekiq/current
```

对于预配问题，请筛选 `ProvisionProjectSecretsManagerTaskWorker` 或
`ProvisionGroupSecretsManagerTaskWorker`。

<a id="gitlab-runner-logs"></a>

### 极狐GitLab Runner 日志

当 CI/CD 作业无法获取密钥时，原因会显示在极狐GitLab UI 的作业日志中。请在作业日志中搜索以下字符串：

| 字符串                                           | 含义                                                            |
|--------------------------------------------------|--------------------------------------------------------------------|
| `Resolving secrets`                              | Runner 开始解析该作业的密钥。                    |
| `Using "gitlab_secrets_manager" secret resolver` | Runner 选择了极狐GitLab 密钥管理器解析器。           |
| `not initialized or sealed Vault server`         | OpenBao 已密封或未初始化。                              |
| `api error: status code 403: permission denied`  | OpenBao 拒绝了请求，通常是受众或权限问题。 |
| `inline auth JWT is required`                    | Runner 无法构建认证请求。            |

<a id="healthy-startup-logs"></a>

### 正常启动日志

重启后，活动节点会记录以下序列。备用节点会停在 `vault is unsealed` 处，然后记录 `entering standby mode`。行格式因配置而异，因此请匹配消息文本，而不是前缀。

| 日志消息                                | 含义                              | 如果缺失                                            |
|--------------------------------------------|--------------------------------------|-------------------------------------------------------|
| `==> OpenBao server started!`              | 进程已启动并读取了配置。 | Pod 启动失败。请检查 Pod 事件。        |
| `vault is unsealed`                        | 自动解封成功。               | 自动解封失败。请检查解封凭据或 KMS。   |
| `acquired lock, enabling active operation` | 此节点已成为活动节点。             | 没有活动节点。请检查数据库和 HA 锁。    |
| `post-unseal setup complete`               | 活动节点已完成设置。      | 设置未完成。请检查数据库连接。  |

<a id="error-messages"></a>

### 错误消息

OpenBao 消息来自 `openbao-server` 容器。极狐GitLab 消息来自 Rails 或
Sidekiq 日志。

| 容器        | 消息                                                       | 说明                                                        | 操作                                                              |
|------------------|---------------------------------------------------------------|--------------------------------------------------------------------|---------------------------------------------------------------------|
| `openbao-server` | `cipher: message authentication failed`                       | 密封密钥无法解密已存储的数据。                       | 对于静态解封，请从主站点复制解封凭据。对于 KMS 密封，请检查 KMS 密钥。请参阅[排查 Geo 部署问题](#troubleshoot-geo-deployments)。 |
| `openbao-server` | `unknown key ID`                                              | 静态解封密钥 ID 与数据库中的数据不匹配。  | 从主站点复制解封凭据。请参阅[排查 Geo 部署问题](#troubleshoot-geo-deployments)。 |
| `openbao-server` | `failed to acquire lock`                                      | 备用节点无法在只读数据库上获取 HA 锁。 | 在 Geo 从站点上属于预期情况。无需操作。                    |
| `openbao-server` | `cannot execute INSERT in a read-only transaction`            | 备用节点尝试写入只读副本。                   | 在 Geo 从站点上属于预期情况。否则，请确保 OpenBao 对数据库具有写入权限，并检查数据库权限。 |
| `openbao-server` | `post-unseal upgrade seal keys failed: error="no recovery key found"` | 恢复密钥从未存储。                         | 无害。请运行 `recovery_key:store`。 |
| Rails 或 Sidekiq | `[OpenBao] health check returned unhealthy`                   | OpenBao 已响应，但报告了不健康状态。                 | 请检查 `bao status` 和 OpenBao 日志。                            |
| Rails 或 Sidekiq | `[OpenBao] health check failed`                               | 极狐GitLab 无法访问 OpenBao。                                    | 请检查连接性。请参阅[极狐GitLab 无法连接到 OpenBao](#gitlab-cannot-connect-to-openbao)。 |
| Rails 或 Sidekiq | `Failed to authenticate with OpenBao`                         | OpenBao 拒绝了 JWT。                                          | 请检查受众和签发者。请参阅 [JWT 认证失败](#jwt-authentication-fails)。 |
| Rails 或 Sidekiq | `Failed to open TCP connection to <host>:443 (execution expired)` | Sidekiq 无法访问 OpenBao URL。                       | 请从 Sidekiq Pod 检查 DNS 和 OpenBao URL。                   |
| Rails 或 Sidekiq | `SSL_connect ... state=error: wrong version number`           | `https` URL 指向提供 `http`的 OpenBao 监听器。   | 使 URL 方案与监听器匹配。请参阅[极狐GitLab 无法连接到 OpenBao](#gitlab-cannot-connect-to-openbao)。 |
| Rails 或 Sidekiq | `Retrying failed secrets_manager maintenance task`            | 正在重试预配或取消预配任务。            | 请在同一日志中检查工作进程错误。重试在三次尝试后停止。 |

<a id="secrets-manager-is-stuck-in-provisioning"></a>

## 密钥管理器卡在预配状态

启用密钥管理器时，开关可能会一直处于加载状态，状态为 `provisioning`。密钥管理器没有 `failed` 状态，因此任何在激活前失败的步骤都会使记录卡住。常见原因是 Sidekiq 无法访问 OpenBao。

诊断方法：

1. 在 Sidekiq 日志中检查预配工作进程：

   ```shell
   kubectl logs -n gitlab -l app=sidekiq -c sidekiq \
     | grep -E "ProvisionProjectSecretsManagerTaskWorker|ProvisionGroupSecretsManagerTaskWorker"
   ```

1. 从 Sidekiq Pod 或节点测试 Sidekiq 能否访问 OpenBao：

   ```shell
   curl "https://openbao.example.com/v1/sys/health"
   ```

`ProjectSecretsManagerMaintenanceTasksCronWorker` 和 `GroupSecretsManagerMaintenanceTasksCronWorker` 工作进程最多重试过期任务三次。每次重试都会记录 `Retrying failed secrets_manager maintenance task`。第三次重试后，`ProjectSecretsManagerReapOrphanTasksCronWorker` 和 `GroupSecretsManagerReapOrphanTasksCronWorker` 工作进程会移除卡住的密钥管理器。移除操作需要与 OpenBao 的正常连接，并且在第三次重试后最多可能需要 45 分钟。

修复连接性并移除卡住的密钥管理器后，请再次开启密钥管理器。如果出现 `Secrets manager deprovision is in progress`，请稍候再试。

<a id="authentication-mount-missing-after-self-initialization"></a>

### 自初始化后缺少认证挂载

在具有多个 OpenBao Pod 的全新安装中，自初始化竞态可能导致 OpenBao 已解封但缺少 `gitlab_rails_jwt/` 认证挂载。Pod 看起来健康，但密钥管理器会一直处于 `provisioning` 状态，且预配工作进程会记录 `permission denied`。
某个 OpenBao Pod 会记录 `initializing node did not win leadership election`。

要解决此问题，请[重置 OpenBao 数据](maintenance.md#reset-openbao-data)。

要在安装期间防止此问题，请在安装 OpenBao 时将 `openbao.autoscaling.minReplicas` 和 `openbao.autoscaling.maxReplicas` 设置为 `1`。在您[确认 OpenBao 已初始化](#check-openbao-status)后，将这两个值改回您通常的副本数并重新部署。

<a id="gitlab-cannot-connect-to-openbao"></a>

## 极狐GitLab 无法连接到 OpenBao

GitLab Rails 和 Sidekiq 通过 HTTP 连接到 OpenBao。Rails 使用 `internal_url`，并在
未设置 `internal_url` 时回退到 `url`。要检查配置，请在 [Rails 控制台](../operations/rails_console.md)中运行以下命令：

```ruby
Gitlab.config.openbao.to_h
```

常见原因：

- `https://` URL 指向提供 `http`的 OpenBao 监听器时，会失败并显示
  `wrong version number`。`global.openbao.https` 设置的是极狐GitLab 连接所用的方案，而不是
  OpenBao 监听器的 TLS。监听器默认提供纯 HTTP。您可以保持
  `global.openbao.https` 未设置以与之匹配，或者使用
  `openbao.config.tlsDisable: false` 启用监听器 TLS，并将 `global.openbao.https` 设置为 `true`。
- OIDC 发现和审计日志记录在不受信任的 TLS 证书下会失败。请使用
  极狐GitLab 信任的证书。
- 未产生任何 OpenBao 审计条目的请求从未到达认证后端。请检查
  Ingress 或反向代理。

对于 Cloud Native 安装，可用的配置如下所示：

```yaml
global:
  openbao:
    enabled: true
    url: http://gitlab-openbao-active:8200
    internal_url: http://gitlab-openbao-active:8200
```

对于 Linux 软件包安装，极狐GitLab 使用 `/etc/gitlab/gitlab.rb`中的 `gitlab_rails['openbao']['url']` 设置连接到 OpenBao。内置的 NGINX 反向代理使用 `oak['components']['openbao']` 设置路由到 OpenBao。有关更多信息，请参阅
[为 Linux 软件包部署安装 OpenBao](linux_package_integration.md)。

<a id="jwt-authentication-fails"></a>

## JWT 认证失败

极狐GitLab 使用 JWT 向 OpenBao 进行认证。如果某个 JWT 声明与 OpenBao
存储的值不匹配，OpenBao 会使用以下错误之一拒绝该 JWT：

- `error validating token: invalid audience (aud) claim: audience claim does not match any expected audience`
- `error validating token: invalid issuer (iss) claim`

JWT 中的 `aud`（受众）声明必须与 OpenBao
认证角色上的 `bound_audiences` 值完全匹配。任何差异都会导致认证失败，包括末尾斜杠、`http` 与 `https`的差异，或端口差异。

OpenBao 在初始化时存储 `bound_audiences`，其值派生自 OpenBao URL。存储的
值不会在您之后更改 URL 时改变。因此，更改 URL 会破坏认证，因为存储的 `bound_audiences` 不再与极狐GitLab 发送的 `aud` 匹配。要独立于连接 URL 设置受众，请使用 `global.openbao.jwt_audience`。

要查找极狐GitLab 发送的受众，请在 Rails 控制台中运行以下命令：

```ruby
SecretsManagement::ProjectSecretsManager.jwt_audience
```

该方法返回配置的 `jwt_audience`，或在未设置 `jwt_audience` 时返回 OpenBao `url`。要查找 OpenBao 存储的受众，请参阅[查找存储的 JWT 受众](maintenance.md#find-the-stored-jwt-audience)。

`iss`（签发者）声明是极狐GitLab URL。OpenBao 也会将极狐GitLab URL 存储为预期的
签发者，因此更改极狐GitLab URL 会以相同方式破坏认证。

要修复受众不匹配，请[恢复 JWT 受众](maintenance.md#restore-the-jwt-audience)。要修复签发者不匹配，请[恢复 JWT 签发者](maintenance.md#restore-the-jwt-issuer)。

<a id="openbao-pods-are-sealed"></a>

## OpenBao Pod 已密封

如果 `bao status` 在启动时报告 `Sealed    true`，则自动解封失败：

- 使用默认静态解封时，原因通常是缺少或不正确的解封凭据。该
  密钥对于 Cloud Native 安装为 `gitlab-openbao-unseal`，对于
  Linux 软件包安装为 `openbao-static-unseal`。
- 使用 KMS 自动解封（目前为 AWS KMS（`awskms`））时，原因通常是 OpenBao 无法访问
  KMS。

要检查密封状态，请参阅[检查 OpenBao 状态](#check-openbao-status)。

> [!warning]
> 如果您轮换静态解封密钥但未保留先前的密钥可用，OpenBao 将无法
> 解密现有数据。请将先前的密钥与新密钥一起添加，并且仅在所有
> Pod 都使用新密钥运行后再移除它。

<a id="database-problems"></a>

## 数据库问题

OpenBao 需要自己的 PostgreSQL 数据库。如果您在没有专用数据库的情况下
启用 OpenBao，GitLab chart 会使安装或升级失败。

其他数据库问题：

- 连接池耗尽或高延迟会导致间歇性超时。
- Linux 软件包 PostgreSQL 配置中不正确的 `md5_auth_cidr_addresses`、`sslMode` 或密码值
  会使 OpenBao Pod 进入 `CrashLoopBackOff`。有关正确的设置，请参阅
  [为 Linux 软件包部署安装 OpenBao](linux_package_integration.md)。

<a id="audit-events-are-missing"></a>

## 审计事件缺失

OpenBao 会在 `/api/v4/internal/secrets_manager/audit_logs` 向极狐GitLab 发送审计事件。GitLab chart
默认启用审计日志记录。如果审计事件未到达：

- 将 `config.audit.http.enabled` 设置为 `false` 会阻止 OpenBao 发送事件。请确认
  审计日志记录已启用。
- 共享审计令牌不匹配会在审计端点上返回 `401`。请确认极狐GitLab 和
  OpenBao 使用相同的审计令牌。

<a id="troubleshoot-geo-deployments"></a>

## 排查 Geo 部署问题

OpenBao 在 Geo 主站点上作为活动节点运行，并在每个从站点上作为备用节点运行。从节点连接到只读 PostgreSQL 副本，因此它会记录 `failed to acquire lock` 和 `cannot execute INSERT in a read-only transaction`。这些消息属于预期情况。

如果从节点记录 `cipher: message authentication failed` 或 `unknown key ID`，则其密封密钥与主站点不匹配。修复方法取决于密封机制：

- 使用静态解封时，请将 `gitlab-openbao-unseal` 密钥从主集群复制到
  从集群，然后重启 OpenBao Pod：

  ```shell
  kubectl -n gitlab get secret gitlab-openbao-unseal -o yaml
  ```

- 使用 KMS 密封时，请将两个站点配置为使用相同的 KMS 密钥。

如果故障转移后 JWT 认证失败，则受众不再与存储的 `bound_audiences` 匹配。修复方法取决于域：

- 如果两个站点都使用主 OpenBao URL，请将两个站点上的 `jwt_audience` 设置为主 OpenBao URL。
  请参阅[在从站点上安装 OpenBao](_index.md#install-openbao-on-a-secondary-site)。
- 如果从站点使用不同的域，则不支持此配置。重新配置
  受众不会恢复认证，因为每个项目和群组命名空间也都需要
  重新预配。请更新 DNS，使主域指向已提升的从站点。有关更多
  信息，请参阅 [Geo 部署](_index.md#geo-deployment)。

<a id="diagnose-slow-secret-operations"></a>

## 诊断缓慢的密钥操作

当 CI/CD 作业获取密钥缓慢，或密钥操作超时时，请使用以下查询查找原因。
请在抓取 OpenBao 指标的 Prometheus 或 Grafana 实例中运行这些查询。
要公开这些指标，请参阅 [OpenBao 指标](_index.md#openbao-metrics)。

<a id="confirm-latency-is-elevated"></a>

### 确认延迟升高

使用以下查询以毫秒为单位测量平均请求延迟。该查询适用于任何流量水平，包括低流量部署：

```prometheus
rate(openbao_core_handle_request_sum[5m])
/
rate(openbao_core_handle_request_count[5m])
```

在正常负载下，所有请求类型的平均延迟通常为 3 到 7 毫秒。如果平均延迟持续超过 20 毫秒，请进行调查。

当 OpenBao 正在积极处理请求时，请使用以下查询获取 P99 延迟：

```prometheus
openbao_core_handle_request{quantile="0.99"}
```

正常 P99 低于 10 毫秒。当 OpenBao 空闲时，此查询会返回 `NaN`，因为摘要窗口没有最近的观测值。在这种情况下，请使用基于速率的查询。

<a id="identify-potential-issues"></a>

### 识别潜在问题

| 潜在问题             | 需要检查的内容                   | 查询                                                                       | 阈值           | 操作                                                             |
|-----------------------------|---------------------------------|-----------------------------------------------------------------------------|---------------------|--------------------------------------------------------------------|
| CPU 限制过低           | CFS 节流比率              | [CPU 节流查询](_index.md#cpu-throttling)                            | > 25%               | 提高 CPU 限制                                                 |
| 需求超过 CPU 容量 | CPU 利用率                 | [CPU 利用率查询](_index.md#cpu-utilization)                          | > 请求量的 50%    | 扩展到[规模调整表](_index.md#pod-resources)中的下一行 |
| 请求激增               | 进行中的请求              | `openbao_core_in_flight_requests`                                           | 持续高于 5   | 暂时性。请监控是否再次出现。                                 |
| PostgreSQL 瓶颈       | 平均 PostgreSQL 读取延迟 | `rate(openbao_postgres_get_sum[5m]) / rate(openbao_postgres_get_count[5m])` | > 5 ms              | 检查 PostgreSQL 资源和连接池                     |
| 内存压力             | 内存利用率              | [内存利用率查询](_index.md#memory-utilization)                    | 接近内存请求量 | 使用[命名空间公式](_index.md#memory-utilization)增加内存 |

如果 PostgreSQL 延迟升高，请检查连接池是否已饱和。如果所有连接都处于忙碌状态，额外的请求会排队并导致延迟。有关连接池配置，请参阅[数据库资源](_index.md#database-resources)。
