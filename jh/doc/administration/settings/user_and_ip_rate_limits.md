---
stage: Production Engineering
group: Networking and Incident Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用户和 IP 速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

速率限制是一种常用技术，用于提升 Web 应用的安全性和持久性。更多详情，请参见[速率限制](../../rate_limits/_index.md)。

以下限制默认处于禁用状态：

- [未认证的 API 请求（按 IP）](#enable-unauthenticated-api-request-rate-limit)。
- [未认证的 Web 请求（按 IP）](#enable-unauthenticated-web-request-rate-limit)。
- [已认证的 API 请求（按用户）](#enable-authenticated-api-request-rate-limit)。
- [已认证的 Web 请求（按用户）](#enable-authenticated-web-request-rate-limit)。
- [已认证的依赖代理请求（按用户）](#enable-authenticated-dependency-proxy-request-rate-limit)。

> [!note]
> 默认情况下，所有 Git 操作都会先尝试以未认证方式进行。因此，HTTP Git 操作
> 可能会触发为未认证请求配置的速率限制。

API 请求的速率限制不会影响前端发出的请求，因为这些请求始终按 Web 流量计数。

<a id="prerequisites"></a>

## 先决条件

您必须具有管理员访问权限。

<a id="enable-unauthenticated-api-request-rate-limit"></a>

## 启用未认证 API 请求速率限制

要启用未认证 API 请求速率限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **网络**。
1. 展开**用户和 IP 速率限制**。
1. 选择**启用未认证 API 请求速率限制**。

   - 可选。更新**每个 IP 在每个速率限制周期内允许的最大未认证 API 请求数**值。
     默认为 `3600`。
   - 可选。更新**未认证速率限制周期（秒）**值。
     默认为 `3600`。

<a id="enable-unauthenticated-web-request-rate-limit"></a>

## 启用未认证 Web 请求速率限制

要启用未认证请求速率限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **网络**。
1. 展开**用户和 IP 速率限制**。
1. 选择**启用未认证 Web 请求速率限制**。

   - 可选。更新**每个 IP 在每个速率限制周期内允许的最大未认证 Web 请求数**值。
     默认为 `3600`。
   - 可选。更新**未认证速率限制周期（秒）**值。
     默认为 `3600`。

<a id="enable-authenticated-api-request-rate-limit"></a>

## 启用已认证 API 请求速率限制

要启用已认证 API 请求速率限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **网络**。
1. 展开**用户和 IP 速率限制**。
1. 选择**启用已认证 API 请求速率限制**。

   - 可选。更新**每个用户在每个速率限制周期内允许的最大已认证 API 请求数**值。
     默认为 `7200`。
   - 可选。更新**已认证 API 速率限制周期（秒）**值。
     默认为 `3600`。

<a id="enable-authenticated-web-request-rate-limit"></a>

## 启用已认证 Web 请求速率限制

要启用已认证请求速率限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **网络**。
1. 展开**用户和 IP 速率限制**。
1. 选择**启用已认证 Web 请求速率限制**。

   - 可选。更新**每个用户在每个速率限制周期内允许的最大已认证 Web 请求数**值。
     默认为 `7200`。
   - 可选。更新**已认证 Web 速率限制周期（秒）**值。
     默认为 `3600`。

<a id="enable-authenticated-dependency-proxy-request-rate-limit"></a>

## 启用已认证依赖代理请求速率限制

对[容器镜像依赖代理](../../user/packages/dependency_proxy/_index.md)的已认证请求默认会计入[已认证 Web 请求速率限制](#enable-authenticated-web-request-rate-limit)。因此，容器镜像拉取会与用户的其他 Web 流量共享配额。并行的 CI/CD 拉取可能会耗尽该配额，并以 `429` 错误失败。

要让依赖代理流量拥有自己的配额，可为 `/v2/<group>/dependency_proxy/containers/` 下的容器镜像清单和 blob 端点启用专用速率限制。此限制仅适用于已认证请求。极狐GitLab 不为未认证的依赖代理请求提供速率限制。

要启用已认证依赖代理速率限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **网络**。
1. 展开**依赖代理速率限制**。
1. 选择**启用已认证依赖代理请求速率限制**。

   - 可选。更新**每个用户在每个周期内允许的最大已认证依赖代理请求数**值。
     默认为 `1000`。
   - 可选。更新**已认证依赖代理速率限制周期（秒）**值。
     默认为 `15`。

此限制处于禁用状态时，依赖代理请求会继续计入已认证 Web 请求速率限制。

> [!note]
> 当您升级到极狐GitLab 19.4 或更高版本时，如果您的实例已启用
> 已认证 Web 请求速率限制，极狐GitLab 会自动启用此限制，并复制其
> 每周期请求数和周期秒数值。这只会放宽限制：此前与 Web 流量共享配额的依赖代理
> 流量将获得同等大小的独立配额。
> 如果已认证 Web 请求速率限制处于禁用状态，此限制也会保持禁用。

<a id="enable-authenticated-mcp-server-request-rate-limit"></a>

## 启用已认证 MCP 服务器请求速率限制

对[极狐GitLab MCP 服务器](../../user/model_context_protocol/mcp_server.md)的已认证请求会计入[已认证 API 请求速率限制](#enable-authenticated-api-request-rate-limit)。

要为 MCP 服务器流量添加限制，可为 `POST /api/v4/mcp` 端点启用速率限制。此限制会在已认证 API 速率限制之外额外生效。只要任一限制被超出，请求就会被拒绝。它会统计对该端点的每一次请求，而不仅仅是工具调用。此限制仅适用于已认证请求，且默认处于禁用状态。

要启用已认证 MCP 服务器速率限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **网络**。
1. 展开**极狐GitLab MCP 服务器速率限制**。
1. 选择**启用已认证 MCP 服务器请求速率限制**。

   - 可选。更新**每个用户在每个周期内允许的最大已认证 MCP 服务器请求数**值。
     默认为 `600`。
   - 可选。更新**已认证 MCP 服务器速率限制周期（秒）**值。
     默认为 `60`。

<a id="use-a-custom-rate-limit-response"></a>

## 使用自定义速率限制响应

超出速率限制的请求会返回 `429` 响应代码和纯文本正文，默认内容为 `Retry later`。

要使用自定义响应：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **网络**。
1. 展开**用户和 IP 速率限制**。
1. 在**发送给触发速率限制的客户端的纯文本响应**文本框中，
   添加纯文本响应消息。

<a id="maximum-authenticated-requests-to-projectidjobs-per-minute"></a>

## 每分钟对 `project/:id/jobs`的最大已认证请求数

为减少超时，`project/:id/jobs` 端点默认具有每个已认证用户 600 次调用的[速率限制](../../rate_limits/_index.md)。

要修改最大请求数：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **网络**。
1. 展开**用户和 IP 速率限制**。
1. 更新**每分钟对 `project/:id/jobs`的最大已认证请求数**值。

<a id="response-headers"></a>

## 响应头

响应头包含所有请求的速率限制信息。使用这些响应头可主动监控用量并调整请求模式，以避免被限流。

<a id="multiple-rate-limiting-systems"></a>

### 多个速率限制系统

速率限制通过两个独立系统强制执行：

- `Rack::Attack`中间件速率限制：在 HTTP 层应用。示例包括每个用户的已认证 API 请求，或每个 IP 的未认证 Web 请求。这些限制会反映在响应头中。
- 应用速率限制：在应用层应用。示例包括每个用户的议题创建，或每个用户的项目导出。这些限制不会包含在响应头中。

单个请求可以同时计入这两类速率限制。响应头仅显示限制最严格的 `Rack::Attack` 速率限制状态。

> [!note]
> 应用速率限制不会包含在响应头中。

<a id="example"></a>

#### 示例

通过 API 创建议题的请求会计入：

- 已认证 API 请求速率限制（`Rack::Attack`）。包含在响应头中。
- 议题创建速率限制（应用层）。不包含在响应头中。

超出议题创建限制会导致 `429` 响应，即使之前的响应头表明仍有足够的已认证 API 请求余量。

<a id="headers-returned-for-all-requests"></a>

### 所有请求都会返回的响应头

所有响应都会包含以下响应头，以帮助客户端跟踪其速率限制状态：

| 响应头                | 示例                      | 描述                                                                                                                                                                                                      |
|:----------------------|:-----------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `RateLimit-Limit`     | `60`                         | 客户端每分钟的请求配额。如果在**管理**区域中设置的速率限制周期不是 1 分钟，则此响应头的值会按最接近的 60 分钟周期进行近似调整。 |
| `RateLimit-Name`      | `throttle_authenticated_api` | 应用于该请求的限流器名称。                                                                                                                                                                     |
| `RateLimit-Observed`  | `67`                         | 时间窗口内与该客户端关联的请求数。                                                                                                                                                  |
| `RateLimit-Remaining` | `33`                         | 时间窗口内的剩余配额。结果为 `RateLimit-Limit` - `RateLimit-Observed`。                                                                                                                     |
| `RateLimit-Reset`     | `1609844400`                 | 请求配额重置的时间，采用 [Unix 时间](https://en.wikipedia.org/wiki/Unix_time) 格式。                                                                                                             |

<a id="additional-headers-for-throttled-requests"></a>

### 被限流请求的附加响应头

当客户端超出速率限制（HTTP 状态 `429`）时，会包含以下附加响应头：

| 响应头                | 示例                         | 描述                                                                                                                                                   |
|:----------------------|:--------------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `RateLimit-ResetTime` | `Tue, 05 Jan 2021 11:00:00 GMT` | 请求配额重置的日期和时间，采用 [RFC2616](https://www.rfc-editor.org/rfc/rfc2616#section-3.3.1) 格式。                                     |
| `Retry-After`         | `30`                            | 配额重置前的剩余时长（秒）。这是一个[标准 HTTP 响应头](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Retry-After)。 |

<a id="use-an-http-header-to-bypass-rate-limiting"></a>

## 使用 HTTP 请求头绕过速率限制

根据您组织的需求，您可能希望启用速率限制，但让某些请求绕过限流器。

您可以通过使用自定义请求头标记应绕过限流器的请求来实现这一点。您必须在极狐GitLab 前面的负载均衡器或反向代理中的某处执行此操作。例如：

1. 为您的绕过请求头选择一个名称。例如，`Gitlab-Bypass-Rate-Limiting`。
1. 配置您的负载均衡器，在应绕过极狐GitLab 速率限制的请求上设置 `Gitlab-Bypass-Rate-Limiting: 1`。
1. 配置您的负载均衡器，执行以下任一操作：
   - 清除 `Gitlab-Bypass-Rate-Limiting`。
   - 对所有应受速率限制影响的请求，将 `Gitlab-Bypass-Rate-Limiting` 设置为 `1` 以外的值。
1. 设置环境变量 `GITLAB_THROTTLE_BYPASS_HEADER`。
   - 对于 [Linux 软件包安装](https://gitlab.cn/docs/omnibus/settings/environment-variables/)，
     在 `gitlab_rails['env']` 中设置 `'GITLAB_THROTTLE_BYPASS_HEADER' => 'Gitlab-Bypass-Rate-Limiting'`。
   - 对于自行编译安装，在 `/etc/default/gitlab`中设置 `export GITLAB_THROTTLE_BYPASS_HEADER=Gitlab-Bypass-Rate-Limiting`。

您的负载均衡器必须清除或覆盖所有传入流量上的绕过请求头，这一点很重要。否则，您必须信任您的用户不会设置该请求头并绕过极狐GitLab 限流器。

仅当该请求头设置为 `1` 时，绕过才会生效。

因绕过请求头而绕过限流器的请求会在 [`production_json.log`](../logs/_index.md#production_jsonlog)中标记为 `"throttle_safelist":"throttle_bypass_header"`。

要禁用绕过机制，请确保环境变量 `GITLAB_THROTTLE_BYPASS_HEADER` 未设置或为空。

<a id="allow-specific-users-to-bypass-authenticated-request-rate-limiting"></a>

## 允许特定用户绕过已认证请求速率限制

与前面描述的绕过请求头类似，也可以允许特定的一组用户绕过限流器。这仅适用于已认证请求：对于未认证请求，极狐GitLab 从定义上并不知道用户是谁。

允许名单在 `GITLAB_THROTTLE_USER_ALLOWLIST` 环境变量中配置为以逗号分隔的用户 ID 列表。如果您希望用户 1、53 和 217 绕过已认证请求限流器，则允许名单配置为 `1,53,217`。

- 对于 [Linux 软件包安装](https://gitlab.cn/docs/omnibus/settings/environment-variables/)，
  在 `gitlab_rails['env']` 中设置 `'GITLAB_THROTTLE_USER_ALLOWLIST' => '1,53,217'`。
- 对于自行编译安装，在 `/etc/default/gitlab`中设置 `export GITLAB_THROTTLE_USER_ALLOWLIST=1,53,217`。

因用户允许名单而绕过限流器的请求会在 [`production_json.log`](../logs/_index.md#production_jsonlog)中标记为 `"throttle_safelist":"throttle_user_allowlist"`。

在应用启动时，允许名单会记录在 [`auth.log`](../logs/_index.md#authlog)中。

<a id="try-out-throttling-settings-before-enforcing-them"></a>

## 在强制执行限流设置前先试用

您可以通过将 `GITLAB_THROTTLE_DRY_RUN` 环境变量设置为以逗号分隔的限流器名称列表，来试用限流设置。

可用的名称包括：

- `throttle_unauthenticated`
  - 在极狐GitLab 14.3 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/335300)。请改用 `throttle_unauthenticated_api` 或 `throttle_unauthenticated_web`。
    `throttle_unauthenticated` 仍受支持，并会同时选择这两者。
- `throttle_unauthenticated_api`
- `throttle_unauthenticated_web`
- `throttle_authenticated_api`
- `throttle_authenticated_web`
- `throttle_unauthenticated_protected_paths`
- `throttle_authenticated_protected_paths_api`
- `throttle_authenticated_protected_paths_web`
- `throttle_unauthenticated_packages_api`
- `throttle_authenticated_packages_api`
- `throttle_authenticated_git_lfs`
- `throttle_unauthenticated_files_api`
- `throttle_authenticated_files_api`
- `throttle_unauthenticated_deprecated_api`
- `throttle_authenticated_deprecated_api`
- `throttle_unauthenticated_git_http`
- `throttle_authenticated_git_http`
- `throttle_authenticated_mcp`

例如，您可以通过设置 `GITLAB_THROTTLE_DRY_RUN='throttle_authenticated_web,throttle_authenticated_api'`，试用针对非受保护路径的所有已认证请求的限流器。

要为所有限流器启用试运行模式，可将该变量设置为 `*`。

在试运行模式下，极狐GitLab 不会阻止会触发某个限流器限制的请求。这些请求会照常继续处理。极狐GitLab 记录这些请求的位置取决于评估它们的速率限制器：

- 旧版 `Rack::Attack` 速率限制器：当请求会触发限制时，极狐GitLab 会向 [`auth.log`](../logs/_index.md#authlog)
  和 [`auth_json.log`](../logs/_index.md#auth_jsonlog) 记录一条消息。
  该日志消息包含一个 `env` 字段，其值为 `track`。
  `matched` 字段包含所触发的限流器名称。
- LabKit 速率限制器：极狐GitLab 不会为此事件单独发出 `auth.log` 或 `auth_json.log` 消息。
  相反，极狐GitLab 会将速率限制状态添加到
  [每请求结构化日志](../logs/_index.md#production_jsonlog)的 `rate_limit_state` 字段中，包括 `production_json.log` 和 `api_json.log`。
  每个条目的格式为 `<limiter>:<rule>:<result>`。
  当请求在试运行模式下会触发某个限流器的限制时，结果为 `log`
  （例如，对于返回 `200` 状态代码的请求，结果为 `["rack_request:unauthenticated_api:log"]`）。
  要确认试运行模式在此速率限制器下正常工作，请检查 `rate_limit_state` 字段，
  而不是 `auth.log`中的 `env` 字段。

在设置中启用速率限制之前先设置环境变量，这一点很重要。**管理**区域中的设置会立即生效，而设置环境变量需要重启所有 Puma 进程。

<a id="troubleshooting"></a>

## 故障排除

<a id="disable-throttling-after-accidentally-locking-administrators-out"></a>

### 意外将管理员锁定后禁用限流

如果许多用户通过同一代理或网络网关连接到极狐GitLab，那么当速率限制过低时，该限制也可能将管理员锁定，因为极狐GitLab 会看到他们与触发限流的请求使用相同的 IP。

管理员可以使用 [Rails 控制台](../operations/rails_console.md)来禁用与 [`GITLAB_THROTTLE_DRY_RUN` 变量](#try-out-throttling-settings-before-enforcing-them)所列相同的限制。例如：

```ruby
Gitlab::CurrentSettings.update!(throttle_authenticated_web_enabled: false)
```

在此示例中，`throttle_authenticated_web` 参数带有 `_enabled` 名称后缀。

要为限制设置数值，请将 `_enabled` 名称后缀替换为 `_period_in_seconds` 和 `_requests_per_period` 后缀。
