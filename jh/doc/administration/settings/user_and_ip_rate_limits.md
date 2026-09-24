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

速率限制是提高 Web 应用程序安全性和持久性的常用技术。有关更多详细信息，请参阅
[速率限制](../../rate_limits/_index.md)。

以下限制默认处于禁用状态：

- [未认证 API 请求（按 IP）](#enable-unauthenticated-api-request-rate-limit)。
- [未认证 Web 请求（按 IP）](#enable-unauthenticated-web-request-rate-limit)。
- [已认证 API 请求（按用户）](#enable-authenticated-api-request-rate-limit)。
- [已认证 Web 请求（按用户）](#enable-authenticated-web-request-rate-limit)。

> [!note]
> 默认情况下，所有 Git 操作首先以未认证方式尝试。因此，HTTP Git 操作
> 可能会触发为未认证请求配置的速率限制。

API 请求的速率限制不影响前端发出的请求，因为这些请求始终计为 Web 流量。

<a id="prerequisites"></a>

## 先决条件

您必须具有管理员访问权限。

<a id="enable-unauthenticated-api-request-rate-limit"></a>

## 启用未认证 API 请求速率限制

要启用未认证 API 请求速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **用户和 IP 速率限制**。
1. 选择 **启用未认证 API 请求速率限制**。

   - 可选。更新 **每个速率限制周期内每个 IP 的最大未认证 API 请求数** 值。
     默认为 `3600`。
   - 可选。更新 **未认证速率限制周期（秒）** 值。
     默认为 `3600`。

<a id="enable-unauthenticated-web-request-rate-limit"></a>

## 启用未认证 Web 请求速率限制

要启用未认证请求速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **用户和 IP 速率限制**。
1. 选择 **启用未认证 Web 请求速率限制**。

   - 可选。更新 **每个速率限制周期内每个 IP 的最大未认证 Web 请求数** 值。
     默认为 `3600`。
   - 可选。更新 **未认证速率限制周期（秒）** 值。
     默认为 `3600`。

<a id="enable-authenticated-api-request-rate-limit"></a>

## 启用已认证 API 请求速率限制

要启用已认证 API 请求速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **用户和 IP 速率限制**。
1. 选择 **启用已认证 API 请求速率限制**。

   - 可选。更新 **每个速率限制周期内每个用户的最大已认证 API 请求数** 值。
     默认为 `7200`。
   - 可选。更新 **已认证 API 速率限制周期（秒）** 值。
     默认为 `3600`。

<a id="enable-authenticated-web-request-rate-limit"></a>

## 启用已认证 Web 请求速率限制

要启用已认证请求速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **用户和 IP 速率限制**。
1. 选择 **启用已认证 Web 请求速率限制**。

   - 可选。更新 **每个速率限制周期内每个用户的最大已认证 Web 请求数** 值。
     默认为 `7200`。
   - 可选。更新 **已认证 Web 速率限制周期（秒）** 值。
     默认为 `3600`。

<a id="use-a-custom-rate-limit-response"></a>

## 使用自定义速率限制响应

超过速率限制的请求会返回 `429` 响应代码和纯文本正文，默认情况下为 `Retry later`。

要使用自定义响应：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **用户和 IP 速率限制**。
1. 在 **发送给触发速率限制的客户端的纯文本响应** 文本框中，
   添加纯文本响应消息。

<a id="maximum-authenticated-requests-to-projectidjobs-per-minute"></a>

## 每分钟对 `project/:id/jobs` 的最大已认证请求数

为减少超时，`project/:id/jobs` 端点默认具有每个已认证用户 600 次调用的 [速率限制](../../rate_limits/_index.md)。

要修改最大请求数：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **用户和 IP 速率限制**。
1. 更新 **每分钟对 `project/:id/jobs` 的最大已认证请求数** 值。

<a id="response-headers"></a>

## 响应头

响应头包含所有请求的速率限制信息。使用这些响应头主动监控使用情况并调整请求模式，以避免被限流。

<a id="multiple-rate-limiting-systems"></a>

### 多个速率限制系统

速率限制通过两个独立的系统强制执行：

- `Rack::Attack` 中间件速率限制：在 HTTP 层应用。示例包括每个用户的已认证 API 请求，或每个 IP 的未认证 Web 请求。这些限制反映在响应头中。
- 应用程序速率限制：在应用程序级别应用。示例包括每个用户的议题创建，或每个用户的项目导出。这些限制不包含在响应头中。

单个请求可以同时计入两种类型的速率限制。响应头仅显示最严格的 `Rack::Attack` 速率限制状态。

> [!note]
> 应用程序速率限制不包含在响应头中。

<a id="example"></a>

#### 示例

通过 API 创建议题的请求会计入：

- 已认证 API 请求速率限制（`Rack::Attack`）。包含在响应头中。
- 议题创建速率限制（应用程序级别）。不包含在响应头中。

超过议题创建限制会导致 `429` 响应，即使之前的响应头表明仍有足够的已认证 API 请求配额。

<a id="headers-returned-for-all-requests"></a>

### 为所有请求返回的响应头

以下响应头包含在所有响应中，以帮助客户端跟踪其速率限制状态：

| 响应头                | 示例                      | 描述                                                                                                                                                                                                      |
|:----------------------|:-----------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `RateLimit-Limit`     | `60`                         | 客户端每分钟的请求配额。如果 **管理员** 区域中设置的速率限制周期不是 1 分钟，则此响应头的值会调整为最接近的 60 分钟周期。 |
| `RateLimit-Name`      | `throttle_authenticated_api` | 应用于请求的限流器名称。                                                                                                                                                                     |
| `RateLimit-Observed`  | `67`                         | 时间窗口内与客户端关联的请求数。                                                                                                                                                  |
| `RateLimit-Remaining` | `33`                         | 时间窗口内的剩余配额。即 `RateLimit-Limit` - `RateLimit-Observed` 的结果。                                                                                                                     |
| `RateLimit-Reset`     | `1609844400`                 | 请求配额重置的 [Unix 时间](https://en.wikipedia.org/wiki/Unix_time) 格式时间。                                                                                                             |

<a id="additional-headers-for-throttled-requests"></a>

### 限流请求的附加响应头

当客户端超过速率限制（HTTP 状态 `429`）时，会包含以下附加响应头：

| 响应头                | 示例                         | 描述                                                                                                                                                   |
|:----------------------|:--------------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `RateLimit-ResetTime` | `Tue, 05 Jan 2021 11:00:00 GMT` | 请求配额重置的 [RFC2616](https://www.rfc-editor.org/rfc/rfc2616#section-3.3.1) 格式日期和时间。                                     |
| `Retry-After`         | `30`                            | 距离配额重置的剩余秒数。这是一个 [标准 HTTP 响应头](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Retry-After)。 |

<a id="use-an-http-header-to-bypass-rate-limiting"></a>

## 使用 HTTP 请求头绕过速率限制

根据您组织的需求，您可能希望启用速率限制，但让某些请求绕过速率限制器。

您可以通过使用自定义请求头标记应绕过速率限制器的请求来实现此目的。您必须在极狐GitLab 前面的负载均衡器或反向代理中进行此操作。例如：

1. 为您的绕过请求头选择一个名称。例如，`Gitlab-Bypass-Rate-Limiting`。
1. 配置您的负载均衡器，在应绕过极狐GitLab 速率限制的请求上设置 `Gitlab-Bypass-Rate-Limiting: 1`。
1. 配置您的负载均衡器，执行以下任一操作：
   - 删除 `Gitlab-Bypass-Rate-Limiting`。
   - 在所有应受速率限制影响的请求上，将 `Gitlab-Bypass-Rate-Limiting` 设置为 `1` 以外的值。
1. 设置环境变量 `GITLAB_THROTTLE_BYPASS_HEADER`。
   - 对于 [Linux 软件包安装](https://gitlab.cn/docs/omnibus/settings/environment-variables/)，
     在 `gitlab_rails['env']` 中设置 `'GITLAB_THROTTLE_BYPASS_HEADER' => 'Gitlab-Bypass-Rate-Limiting'`。
   - 对于自编译安装，在 `/etc/default/gitlab` 中设置 `export GITLAB_THROTTLE_BYPASS_HEADER=Gitlab-Bypass-Rate-Limiting`。

您的负载均衡器必须删除或覆盖所有传入流量上的绕过请求头，这一点很重要。否则，您必须信任您的用户不会设置该请求头并绕过极狐GitLab 速率限制器。

仅当请求头设置为 `1` 时，绕过才有效。

由于绕过请求头而绕过速率限制器的请求会在
[`production_json.log`](../logs/_index.md#production_jsonlog) 中标记为 `"throttle_safelist":"throttle_bypass_header"`。

要禁用绕过机制，请确保环境变量
`GITLAB_THROTTLE_BYPASS_HEADER` 未设置或为空。

<a id="allow-specific-users-to-bypass-authenticated-request-rate-limiting"></a>

## 允许特定用户绕过已认证请求速率限制

与前面描述的绕过请求头类似，可以允许特定用户集绕过速率限制器。这仅适用于已认证请求：对于未认证请求，根据定义，极狐GitLab 不知道用户是谁。

允许名单在 `GITLAB_THROTTLE_USER_ALLOWLIST` 环境变量中配置为逗号分隔的用户 ID 列表。如果您希望用户 1、53 和 217 绕过已认证请求速率限制器，则允许名单配置为 `1,53,217`。

- 对于 [Linux 软件包安装](https://gitlab.cn/docs/omnibus/settings/environment-variables/)，
  在 `gitlab_rails['env']` 中设置 `'GITLAB_THROTTLE_USER_ALLOWLIST' => '1,53,217'`。
- 对于自编译安装，在 `/etc/default/gitlab` 中设置 `export GITLAB_THROTTLE_USER_ALLOWLIST=1,53,217`。

由于用户允许名单而绕过速率限制器的请求会在
[`production_json.log`](../logs/_index.md#production_jsonlog) 中标记为 `"throttle_safelist":"throttle_user_allowlist"`。

在应用程序启动时，允许名单会记录在 [`auth.log`](../logs/_index.md#authlog) 中。

<a id="try-out-throttling-settings-before-enforcing-them"></a>

## 在强制执行前试用限流设置

您可以通过将 `GITLAB_THROTTLE_DRY_RUN` 环境变量设置为逗号分隔的限流器名称列表来试用限流设置。

可能的名称有：

- `throttle_unauthenticated`
  - 在极狐GitLab 14.3 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/335300)。请改用 `throttle_unauthenticated_api` 或 `throttle_unauthenticated_web`。
    `throttle_unauthenticated` 仍受支持，并会选择这两者。
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

例如，您可以通过设置
`GITLAB_THROTTLE_DRY_RUN='throttle_authenticated_web,throttle_authenticated_api'` 来试用对所有非保护路径的已认证请求的限流。

要为所有限流器启用试运行模式，可以将变量设置为 `*`。

将限流器设置为试运行模式时，当请求即将达到限制时，会在
[`auth.log`](../logs/_index.md#authlog) 中记录一条消息，同时允许该
请求继续。日志消息包含一个设置为 `track` 的 `env` 字段。`matched` 字段包含被触发的限流器的名称。

在设置中启用速率限制之前设置环境变量非常重要。**管理员** 区域中的设置会立即生效，而设置环境变量需要重启所有 Puma 进程。

<a id="troubleshooting"></a>

## 故障排除

<a id="disable-throttling-after-accidentally-locking-administrators-out"></a>

### 意外锁定管理员后禁用限流

如果许多用户通过同一代理或网络网关连接到极狐GitLab，则速率限制过低时，该限制也可能锁定管理员，因为极狐GitLab 看到他们使用的 IP 与触发限流的请求相同。

管理员可以使用 [Rails 控制台](../operations/rails_console.md) 禁用与
[`GITLAB_THROTTLE_DRY_RUN` 变量](#try-out-throttling-settings-before-enforcing-them) 中列出的相同的限制。
例如：

```ruby
Gitlab::CurrentSettings.update!(throttle_authenticated_web_enabled: false)
```

在此示例中，`throttle_authenticated_web` 参数具有 `_enabled` 名称后缀。

要为限制设置数值，请将 `_enabled` 名称后缀替换为 `_period_in_seconds` 和 `_requests_per_period` 后缀。
