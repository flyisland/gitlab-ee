---
stage: Security Platform
group: Secrets Manager OpenBao
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: OpenBao 故障排查
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Status: 测试版

{{< /details >}}

有关恢复密钥任务和紧急 root token，请参阅[恢复密钥管理](recovery_key.md)。
有关 Geo 故障转移，请参阅
[Geo 灾难恢复](../geo/disaster_recovery/_index.md#step-4-optional-promote-the-openbao-ha-cluster)。

<a id="where-openbao-runs"></a>

## OpenBao 运行位置

即使极狐GitLab 使用 Linux 软件包，OpenBao 也始终在 Kubernetes 中运行。命名空间和部署名称取决于安装方法：

| 安装方法 | 命名空间 | 部署       | Pod 容器    |
|---------------------|-----------|------------------|------------------|
| Cloud Native GitLab | `gitlab`  | `gitlab-openbao` | `openbao-server` |
| Linux 软件包       | `openbao` | `openbao`        | `openbao-server` |

这些示例使用 Cloud Native 命名空间 `gitlab`。对于 Linux 软件包安装，请在 `kubectl` 命令中将 `gitlab` 替换为 `openbao`。

OpenBao Pod 带有标签 `app.kubernetes.io/name=openbao`。活动节点还带有
`openbao-active=true`。

<a id="find-openbao-logs"></a>

## 查找 OpenBao 日志

使用 `kubectl logs` 读取 OpenBao 日志。相关的 GitLab Rails 和 Sidekiq 日志根据安装方法单独存储：

| 来源         | Cloud Native GitLab                              | Linux 软件包                                      |
|----------------|--------------------------------------------------|----------------------------------------------------|
| OpenBao 服务器 | `kubectl logs` 在 `openbao-server` 容器上 | `kubectl logs` 在 `openbao-server` 容器上   |
| GitLab Rails   | `kubectl logs` 在 `webservice` Pod 上          | `/var/log/gitlab/gitlab-rails/production_json.log` |
| Sidekiq        | `kubectl logs` 在 `sidekiq` Pod 上             | `/var/log/gitlab/sidekiq/current`                  |
| 极狐GitLab Runner  | 极狐GitLab UI 中的 CI/CD 作业日志                   | 极狐GitLab UI 中的 CI/CD 作业日志                     |

OpenBao 将审计事件发布到极狐GitLab，并将其写入 OpenBao Pod 日志。

<a id="find-the-openbao-pods"></a>

### 查找 OpenBao Pod

要列出 OpenBao Pod 并查看哪个节点处于活动状态：

```shell
kubectl get pods -n gitlab -l app.kubernetes.io/name=openbao \
  --label-columns openbao-active,openbao-sealed
```

`OPENBAO-ACTIVE` 设置为 `true` 的 Pod 是活动节点。其他节点是备用节点。

<a id="check-openbao-status"></a>

### 检查 OpenBao 状态

OpenBao 必须解除封印才能处理请求。要进行检查，请在 Pod 中运行 `bao status`：

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
> `bao` 二进制文件存在于 Pod 中。从 Pod 内部进行端点查询时，请使用 `bao read`。

在日志中，成功解除封印的节点会记录 `vault is unsealed`。活动节点记录
`acquired lock, enabling active operation`，备用节点记录 `entering standby mode`：

```shell
OPENBAO_POD=$(kubectl get pods -n gitlab -l app.kubernetes.io/name=openbao -o name | head -1)
kubectl logs -n gitlab "$OPENBAO_POD" -c openbao-server \
  | grep -E "acquired lock, enabling active operation|entering standby mode"
```

<a id="find-errors-in-a-time-window"></a>

### 在时间窗口内查找错误

要读取某个时间窗口内的 OpenBao 日志，请使用 `--since`：

```shell
OPENBAO_POD=$(kubectl get pods -n gitlab -l app.kubernetes.io/name=openbao -o name | head -1)
kubectl logs -n gitlab "$OPENBAO_POD" -c openbao-server --since=30m \
  | grep -iE "error|warn|failed"
```

对于 Linux 软件包安装，请按时间搜索 Rails 和 Sidekiq 日志文件。这些日志是 JSON 格式，每行一个事件。

> [!note]
> OpenBao 将所有输出写入标准错误，因此某些日志平台会将每一行都标记为错误。
> 请信任消息正文中的级别（`[info]`、`[warn]`），而不是平台的标签。

<a id="gitlab-rails-logs"></a>

### GitLab Rails 日志

Rails 日志涵盖来自 UI 和 GraphQL API 的密钥操作，以及来自 OpenBao 的审计回调。

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

GraphQL 操作会显示 `caller_id`，例如 `graphql:createProjectSecret` 或
`graphql:getGroupSecrets`。审计回调显示为路径
`/api/v4/internal/secrets_manager/audit_logs`。

<a id="sidekiq-logs"></a>

### Sidekiq 日志

负责预配、取消预配和维护 Secrets Manager 记录的工作进程在
`SecretsManagement::` 命名空间下运行。

对于 Cloud Native 安装：

```shell
kubectl logs -n gitlab -l app=sidekiq -c sidekiq | grep "SecretsManagement::"
```

对于 Linux 软件包安装：

```shell
grep "SecretsManagement::" /var/log/gitlab/sidekiq/current
```

对于预配问题，请筛选 `ProvisionProjectSecretsManagerWorker` 或
`ProvisionGroupSecretsManagerWorker`。

<a id="gitlab-runner-logs"></a>

### 极狐GitLab Runner 日志

当 CI/CD 作业无法获取密钥时，原因会显示在极狐GitLab UI 的作业日志中。请在作业日志中搜索以下字符串：

| 字符串                                           | 含义                                                            |
|--------------------------------------------------|--------------------------------------------------------------------|
| `Resolving secrets`                              | Runner 开始解析作业的密钥。                    |
| `Using "gitlab_secrets_manager" secret resolver` | Runner 选择了极狐GitLab Secrets Manager 解析器。           |
| `not initialized or sealed Vault server`         | OpenBao 已封印或未初始化。                              |
| `api error: status code 403: permission denied`  | OpenBao 拒绝了请求，通常是受众或权限问题。 |
| `inline auth JWT is required`                    | Runner 无法构建身份验证请求。            |

<a id="healthy-startup-logs"></a>

### 健康的启动日志

重启后，活动节点会记录以下序列。备用节点在 `vault is unsealed` 处停止，然后记录 `entering standby mode`。行格式因配置而异，因此请匹配消息文本而不是前缀。

| 日志消息                                | 含义                              | 如果缺失                                            |
|--------------------------------------------|--------------------------------------|-------------------------------------------------------|
| `==> OpenBao server started!`              | 进程已启动并读取配置。 | Pod 启动失败。检查 Pod 事件。        |
| `vault is unsealed`                        | 自动解除封印成功。               | 自动解除封印失败。检查解除封印密钥或 KMS。   |
| `acquired lock, enabling active operation` | 此节点变为活动节点。             | 没有活动节点。检查数据库和 HA 锁。    |
| `post-unseal setup complete`               | 活动节点已完成设置。      | 设置未完成。检查数据库连接。  |

<a id="error-messages"></a>

### 错误消息

OpenBao 消息来自 `openbao-server` 容器。极狐GitLab 消息来自 Rails 或 Sidekiq 日志。

| 容器        | 消息                                                       | 说明                                                        | 操作                                                              |
|------------------|---------------------------------------------------------------|--------------------------------------------------------------------|---------------------------------------------------------------------|
| `openbao-server` | `cipher: message authentication failed`                       | 封印密钥无法解密存储的数据。                       | 对于静态解除封印，请从主站点复制解除封印密钥。对于 KMS 封印，请检查 KMS 密钥。请参阅[排查 Geo 部署](#troubleshoot-geo-deployments)。 |
| `openbao-server` | `unknown key ID`                                              | 静态解除封印密钥 ID 与数据库中的数据不匹配。  | 从主站点复制解除封印密钥。请参阅[排查 Geo 部署](#troubleshoot-geo-deployments)。 |
| `openbao-server` | `failed to acquire lock`                                      | 备用节点无法在只读数据库上获取 HA 锁。 | 在 Geo 从节点上属预期行为。无需操作。                    |
| `openbao-server` | `cannot execute INSERT in a read-only transaction`            | 备用节点尝试写入只读副本。                   | 在 Geo 从节点上属预期行为。否则，请确保 OpenBao 对数据库具有写入权限，并检查数据库权限。 |
| `openbao-server` | `post-unseal upgrade seal keys failed: error="no recovery key found"` | 恢复密钥从未存储。                         | 无害。运行 `recovery_key:store`。 |
| Rails 或 Sidekiq | `[OpenBao] health check returned unhealthy`                   | OpenBao 已响应，但报告了不健康状态。                 | 检查 `bao status` 和 OpenBao 日志。                            |
| Rails 或 Sidekiq | `[OpenBao] health check failed`                               | 极狐GitLab 无法访问 OpenBao。                                    | 检查连接。请参阅[极狐GitLab 无法连接到 OpenBao](#gitlab-cannot-connect-to-openbao)。 |
| Rails 或 Sidekiq | `Failed to authenticate with OpenBao`                         | OpenBao 拒绝了 JWT。                                          | 检查受众。请参阅[JWT 身份验证失败](#jwt-authentication-fails)。 |
| Rails 或 Sidekiq | `Failed to open TCP connection to <host>:443 (execution expired)` | Sidekiq 无法访问 OpenBao URL。                       | 从 Sidekiq Pod 检查 DNS 和 OpenBao URL。                   |
| Rails 或 Sidekiq | `SSL_connect ... state=error: wrong version number`           | `https` URL 指向提供 `http` 服务的 OpenBao 监听器。   | 将 URL 方案与监听器匹配。请参阅[极狐GitLab 无法连接到 OpenBao](#gitlab-cannot-connect-to-openbao)。 |
| Rails 或 Sidekiq | `Retrying failed secrets_manager maintenance task`            | 正在重试预配或取消预配任务。            | 检查同一日志中的工作进程错误。重试在三次尝试后停止。 |

<a id="secrets-manager-is-stuck-in-provisioning"></a>

## Secrets Manager 卡在预配中

当您启用 Secrets Manager 时，开关可能会停留在加载状态，状态为
`provisioning`。Secrets Manager 没有 `failed` 状态，因此在激活前任何步骤失败都会使记录卡住。通常原因是 Sidekiq 无法访问 OpenBao。

要诊断：

1. 在 Sidekiq 日志中检查预配工作进程：

   ```shell
   kubectl logs -n gitlab -l app=sidekiq -c sidekiq \
     | grep -E "ProvisionProjectSecretsManagerWorker|ProvisionGroupSecretsManagerWorker"
   ```

1. 从 Sidekiq Pod 或节点测试 Sidekiq 是否可以访问 OpenBao：

   ```shell
   curl "https://openbao.example.com/v1/sys/health"
   ```

维护工作进程最多重试过期任务三次，然后停止。之后，记录
保持在 `provisioning` 状态，没有自动恢复，重试会记录 `Retrying failed
secrets_manager maintenance task`。

修复连接后，请禁用并重新启用 Secrets Manager 以重新预配。

<a id="authentication-mount-missing-after-self-initialization"></a>

### 自初始化后缺少身份验证挂载

在具有多个 OpenBao Pod 的全新安装中，自初始化竞争可能导致 OpenBao
已解除封印，但缺少 `gitlab_rails_jwt/` 身份验证挂载。Pod 看起来健康，但密钥操作会因权限拒绝而失败。使用 root token 运行 `bao auth list` 以确认挂载存在。为防止竞争，请使用单个副本启动全新安装，确认初始化完成，然后再扩容。

<a id="gitlab-cannot-connect-to-openbao"></a>

## 极狐GitLab 无法连接到 OpenBao

GitLab Rails 和 Sidekiq 通过 HTTP 连接到 OpenBao。Rails 使用 `internal_url`，并在未设置 `internal_url` 时回退到
`url`。要检查配置，请在
[Rails 控制台](../operations/rails_console.md)中运行：

```ruby
Gitlab.config.openbao.to_h
```

常见原因：

- 针对提供 `http` 服务的 OpenBao 监听器使用 `https://` URL 会失败，并显示
  `wrong version number`。`global.openbao.https` 设置极狐GitLab 连接时使用的方案，而不是
  OpenBao 监听器 TLS。监听器默认提供纯 HTTP 服务。要么保持
  `global.openbao.https` 未设置以匹配，要么使用
  `openbao.config.tlsDisable: false` 启用监听器 TLS，并将 `global.openbao.https` 设置为 `true`。
- OIDC 发现和审计日志记录在不受信任的 TLS 证书下会失败。请使用极狐GitLab 信任的证书。
- 未产生 OpenBao 审计条目的请求从未到达身份验证后端。请检查 Ingress 或反向代理。

对于 Cloud Native 安装，有效的配置如下所示：

```yaml
global:
  openbao:
    enabled: true
    url: http://gitlab-openbao-active:8200
    internal_url: http://gitlab-openbao-active:8200
```

对于 Linux 软件包安装，极狐GitLab 使用 `gitlab_rails['openbao']['url']` 设置（位于
`/etc/gitlab/gitlab.rb`）连接到 OpenBao。内置的 NGINX 反向代理使用
`oak['components']['openbao']` 设置将流量路由到 OpenBao。有关更多信息，请参阅
[为 Linux 软件包部署安装 OpenBao](linux_package_integration.md)。

<a id="jwt-authentication-fails"></a>

## JWT 身份验证失败

极狐GitLab 使用 JWT 向 OpenBao 进行身份验证。JWT 中的 `aud`（受众）声明必须与
OpenBao 身份验证角色上的 `bound_audiences` 值完全匹配。任何差异都会导致身份验证失败，包括尾部斜杠、`http` 与 `https` 的差异，或端口不同。

OpenBao 在初始化时存储 `bound_audiences`，该值源自 OpenBao URL。当您稍后更改 URL 时，存储的值不会改变。因此，更改 URL 会破坏身份验证，因为存储的 `bound_audiences` 不再与极狐GitLab 发送的 `aud` 匹配。要独立于连接 URL 设置受众，请使用 `global.openbao.jwt_audience`。

要查找极狐GitLab 发送的受众，请在 Rails 控制台中运行：

```ruby
SecretsManagement::ProjectSecretsManager.jwt_audience
```

该方法返回配置的 `jwt_audience`，如果未设置 `jwt_audience`，则返回 OpenBao `url`。要检查存储的值，请使用 root token 读取身份验证角色，并将
`bound_audiences` 与该受众进行比较。

> [!warning]
> 没有特权访问权限，您无法修复此问题。root token 在
> 自初始化后被撤销，解除封印密钥不能替代它。解除封印 Secret 中只包含
> 解除封印密钥，不包含 root token。

要在不删除存储的密钥的情况下修复不匹配，请使用恢复密钥重新配置身份验证。有关步骤，请参阅
[使用恢复密钥重新配置身份验证](maintenance.md#reconfigure-authentication-with-a-recovery-key)。

如果您没有恢复密钥，请[重置 OpenBao 数据](maintenance.md#reset-openbao-data)。这将
删除所有存储的密钥。

<a id="openbao-pods-are-sealed"></a>

## OpenBao Pod 已封印

如果 `bao status` 在启动时报告 `Sealed    true`，则自动解除封印失败：

- 使用默认的静态解除封印，原因通常是解除封印密钥缺失或不正确。该
  密钥在 Cloud Native 安装中为 `gitlab-openbao-unseal`，在
  Linux 软件包安装中为 `openbao-static-unseal`。
- 使用 KMS 自动解除封印（目前为 AWS KMS (`awskms`)），原因通常是 OpenBao 无法访问
  KMS。

要检查封印状态，请参阅[检查 OpenBao 状态](#check-openbao-status)。

> [!warning]
> 如果您轮换静态解除封印密钥，但未保留以前的密钥，OpenBao 将无法
> 解密现有数据。请将以前的密钥与新密钥一起添加，并且仅在所有
> Pod 都使用新密钥运行后才将其移除。

<a id="database-problems"></a>

## 数据库问题

OpenBao 需要自己的 PostgreSQL 数据库。如果您在未使用专用数据库的情况下启用 OpenBao，GitLab chart 将导致安装或升级失败。

其他数据库问题：

- 连接池耗尽或高延迟会导致间歇性超时。
- Linux 软件包 PostgreSQL 配置中不正确的 `md5_auth_cidr_addresses`、`sslMode` 或密码值会使 OpenBao Pod 进入 `CrashLoopBackOff` 状态。有关正确的设置，请参阅
  [为 Linux 软件包部署安装 OpenBao](linux_package_integration.md)。

<a id="audit-events-are-missing"></a>

## 审计事件缺失

OpenBao 将审计事件发布到极狐GitLab 的 `/api/v4/internal/secrets_manager/audit_logs`。GitLab chart 默认启用审计日志记录。如果审计事件未到达：

- 将 `config.audit.http.enabled` 设置为 `false` 会阻止 OpenBao 发布事件。请确认
  审计日志记录已启用。
- 共享审计令牌不匹配会在审计端点上返回 `401`。请确认极狐GitLab 和
  OpenBao 使用相同的审计令牌。

<a id="troubleshoot-geo-deployments"></a>

## 排查 Geo 部署

OpenBao 在 Geo 主站点上作为活动节点运行，在每个从站点上作为备用节点运行。
从节点连接到只读 PostgreSQL 副本，因此会记录 `failed to acquire lock` 和
`cannot execute INSERT in a read-only transaction`。这些消息是预期行为。

如果从节点记录 `cipher: message authentication failed` 或 `unknown key ID`，则其封印密钥
与主节点不匹配。修复方法取决于封印机制：

- 使用静态解除封印，请将 `gitlab-openbao-unseal` 密钥从主集群复制到
  从集群，然后重启 OpenBao Pod：

  ```shell
  kubectl -n gitlab get secret gitlab-openbao-unseal -o yaml
  ```

- 使用 KMS 封印，请将两个站点配置为使用相同的 KMS 密钥。

如果故障转移后 JWT 身份验证失败，则受众不再与存储的
`bound_audiences` 匹配。修复方法取决于域：

- 如果两个站点都使用主 OpenBao URL，请在两个
  站点上将 `jwt_audience` 设置为主 OpenBao URL。请参阅[在从站点上安装 OpenBao](_index.md#install-openbao-on-a-secondary-site)。
- 如果从站点使用不同的域，则不支持此配置。重新配置
  受众不会恢复身份验证，因为每个项目和群组命名空间也需要
  重新预配。请更新 DNS，使主域指向已提升的从站点。有关更多
  信息，请参阅[Geo 部署](_index.md#geo-deployment)。

<a id="diagnose-slow-secret-operations"></a>

## 诊断慢速密钥操作

当 CI/CD 作业获取密钥缓慢，或密钥操作超时时，请使用以下查询
来查找原因。
请在抓取 OpenBao 指标的 Prometheus 或 Grafana 实例中运行这些查询。
要公开这些指标，请参阅[OpenBao 指标](_index.md#openbao-metrics)。

<a id="confirm-latency-is-elevated"></a>

### 确认延迟升高

使用以下查询测量平均请求延迟（毫秒）。该查询适用于任何
流量级别，包括低流量部署：

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

正常 P99 低于 10 毫秒。当 OpenBao 空闲时，此查询返回 `NaN`，因为摘要窗口
没有最近的观测值。在这种情况下，请使用基于速率的查询。

<a id="identify-potential-issues"></a>

### 识别潜在问题

| 潜在问题             | 检查内容                   | 查询                                                                       | 阈值           | 操作                                                             |
|-----------------------------|---------------------------------|-----------------------------------------------------------------------------|---------------------|--------------------------------------------------------------------|
| CPU 限制过低           | CFS 节流比率              | [CPU 节流查询](_index.md#cpu-throttling)                            | > 25%               | 增加 CPU 限制                                                 |
| 需求超过 CPU 容量 | CPU 利用率                 | [CPU 利用率查询](_index.md#cpu-utilization)                          | > 请求的 50%    | 扩展到[大小调整表](_index.md#pod-resources)中的下一行 |
| 请求激增               | 进行中的请求              | `openbao_core_in_flight_requests`                                           | 持续高于 5   | 暂时性。监控是否复发。                                 |
| PostgreSQL 瓶颈       | 平均 PostgreSQL 读取延迟 | `rate(openbao_postgres_get_sum[5m]) / rate(openbao_postgres_get_count[5m])` | > 5 毫秒              | 检查 PostgreSQL 资源和连接池                     |
| 内存压力             | 内存利用率              | [内存利用率查询](_index.md#memory-utilization)                    | 接近内存请求 | 使用[命名空间公式](_index.md#memory-utilization)增加内存 |

如果 PostgreSQL 延迟升高，请检查连接池是否已饱和。如果所有
连接都忙，额外的请求将排队并导致延迟。有关连接池
配置，请参阅[数据库资源](_index.md#database-resources)。
