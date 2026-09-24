---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于检查和评估项目依赖防火墙的 REST API。
title: 依赖防火墙 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

使用此 API 与项目的依赖防火墙进行交互。
依赖防火墙会在获取软件包之前，阻止不符合项目安全策略的软件包。

<a id="retrieve-status-of-dependency-firewall-for-a-project"></a>

## 检索项目的依赖防火墙状态

检索指定项目的依赖防火墙状态。使用此端点可确定是否在整次运行中跳过防火墙。防火墙已关闭的项目会返回成功响应，而不是 `404 Not Found`，因此您可以将其与无法访问的项目区分开来。

此端点接受个人访问令牌、项目访问令牌、群组访问令牌、OAuth 令牌或 [CI/CD 作业令牌](../ci/jobs/ci_job_token.md)。不支持部署令牌。未认证的请求将被拒绝，包括对公共项目的请求。

CI/CD 作业令牌不需要特定的细粒度权限。限制它的是其作业运行所在的项目：作业令牌只能检查该项目。对任何其他项目的请求将被拒绝并返回 `403 Forbidden`，即使目标项目在其[入站作业令牌允许列表](../ci/jobs/ci_job_token.md)中允许了该作业的项目，并且无论该允许列表条目授予了哪些细粒度权限。一个项目的防火墙状态不是另一个项目的流水线所需的信息。

先决条件：

- 您必须具有读取该项目的权限。

```plaintext
GET /projects/:id/dependency_firewall/enablement
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性  | 类型    | 描述 |
| ---------- | ------- | ----------- |
| `enabled`  | 布尔值 | 依赖防火墙是否已为该项目启用。这是一个综合答案：响应不会说明是许可证还是命名空间设置导致了该结果。 |

可能的响应代码：

| 状态码 | 描述 |
| ----------- | ----------- |
| `401`       | 未授权。请求未包含有效的身份验证信息。 |
| `403`       | 禁止。凭据不允许使用此端点：CI/CD 作业令牌用于其作业运行所在项目以外的任何项目，或没有读取项目权限的细粒度令牌。无法读取项目的用户收到的则是 `404`。 |
| `404`       | 未找到。其含义取决于响应体使用的键：`enabled`、`message` 或 `error`。请参阅此表后的指南。 |
| `429`       | 请求过多。您已超出此端点的速率限制，该限制范围限定为调用用户。此限制与其他项目端点的限制是分开的。 |

当功能标志关闭时，端点返回 `404` 而不是 `200`，因为该端点尚未正式发布。因此，`404` 响应意味着以下三种情况之一，客户端通过响应体使用的键来区分它们，而不是通过文本的措辞：

- 带有 `enabled` 键的响应体，例如 `{"enabled": false}`，表示该项目的功能标志已关闭。防火墙未激活，因此客户端可以在本次运行中跳过它。
- 带有 `error` 键的响应体，例如 `{"error":"404 Not Found"}`，表示此端点在实例上不存在。例如，实例可能运行的是极狐GitLab 基础版，或者是此端点添加之前发布的版本。客户端应回退到其之前的行为，而不是报告配置问题。
- 带有 `message` 键的响应体表示端点存在但拒绝了请求。项目要么不存在，要么您无法读取它。客户端应报告配置问题，并且不得将项目视为未受保护。

不要根据消息文本来做此决定。无法读取项目的调用者会收到 `{"message":"404 Project Not Found"}`，但缺少项目访问权限的细粒度令牌会收到 `{"message":"404 Not Found"}`，如果仅比较措辞，这与端点缺失的情况看起来相同。

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/dependency_firewall/enablement"
```

示例响应：

```json
{
  "enabled": true
}
```

要从流水线作业进行身份验证，请使用带有 `JOB-TOKEN` 请求头的 [CI/CD 作业令牌](../ci/jobs/ci_job_token.md)：

```shell
curl --request GET \
  --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
  --url "https://gitlab.example.com/api/v4/projects/1/dependency_firewall/enablement"
```

<a id="evaluate-a-package-against-dependency-firewall-policies-for-a-project"></a>

## 针对项目的依赖防火墙策略评估软件包

针对指定项目的依赖防火墙策略评估单个软件包。

此端点接受个人访问令牌、项目访问令牌、群组访问令牌、OAuth 令牌或 [CI/CD 作业令牌](../ci/jobs/ci_job_token.md)。来自目标项目作业令牌范围之外项目的作业令牌将被拒绝并返回 `403 Forbidden` 状态码。不支持部署令牌。

先决条件：

- 您必须至少具有该项目的报告者角色。
- 您必须具有读取项目中软件包的权限。

```plaintext
POST /projects/:id/dependency_firewall/evaluate
```

支持的属性：

| 属性   | 类型              | 必填 | 描述 |
|-------------|-------------------|----------|-------------|
| `id`        | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `ecosystem` | 字符串            | 是      | 软件包生态系统。可以是 `cargo`、`composer`、`conan`、`gem`、`golang`、`maven`、`npm`、`nuget`、`pub`、`pypi` 或 `swift` 之一。 |
| `name`      | 字符串            | 是      | 软件包名称，最多 255 个字符。对于 `maven`，请使用 `groupId:artifactId` 格式，例如 `com.example:trivial-lib`。对于 `pypi`，名称在评估前会根据 PEP 503 进行规范化，因此 `Flask_Login` 和 `flask-login` 是等价的。 |
| `version`   | 字符串            | 是      | 软件包版本，最多 255 个字符。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性 | 类型   | 描述 |
|-----------|--------|-------------|
| `outcome` | 字符串 | 评估结果。可以是 `allowed`、`warned` 或 `blocked` 之一。 |
| `reason`  | 字符串 | 描述软件包被警告或阻止原因的消息。指明匹配的策略。当 `outcome` 为 `allowed` 时为 `null`。 |

`outcome` 属性具有以下值之一：

- `allowed`：没有策略规则匹配该软件包。启用了依赖防火墙但未关联任何策略的项目始终返回 `allowed`。`allowed` 结果并不表示极狐GitLab 持有该软件包的漏洞或许可证数据。软件包元数据数据库中不存在的软件包也会被允许。
- `warned`：有策略规则匹配该软件包，且匹配的策略处于警告模式。
- `blocked`：有策略规则匹配该软件包，且匹配的策略处于强制执行模式。

此端点还可以返回以下状态码：

| 状态码 | 代码 | 描述 |
|-------------|------|-------------|
| `400` | 无 | `name` 或 `version` 为空，或 `ecosystem` 不是可接受的值之一。 |
| `401` | 无 | 请求未通过身份验证。 |
| `403` | 无 | 已认证用户无法读取项目中的软件包，或请求使用了项目作业令牌范围之外的作业令牌。 |
| `404` | 无 | 项目不存在、已认证用户无权访问该项目，或 `dependency_firewall_phase1` 功能标志已禁用。 |
| `422` | `dependency_firewall_not_enforced` | 依赖防火墙未为该项目启用。 |
| `429` | 无 | 超出此端点的速率限制。该限制范围限定为项目和用户的组合。 |
| `503` | `dependency_firewall_evaluation_failed` | 软件包元数据查找未完成。请阻止获取。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/1/dependency_firewall/evaluate" \
  --data '{"ecosystem": "npm", "name": "lodash", "version": "4.17.15"}'
```

示例响应：

```json
{
  "outcome": "blocked",
  "reason": "Package 'lodash' violates 'deny-mit' policy"
}
```

已启用依赖防火墙但未关联任何策略的项目的示例响应：

```json
{
  "outcome": "allowed",
  "reason": null
}
```

从流水线作业中，使用 [CI/CD 作业令牌](../ci/jobs/ci_job_token.md) 进行身份验证：

```shell
curl --request POST \
  --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/1/dependency_firewall/evaluate" \
  --data '{"ecosystem": "npm", "name": "lodash", "version": "4.17.15"}'
```
