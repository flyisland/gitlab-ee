---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: REST API，用于检查和评估项目的依赖防火墙。
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

使用此 API 与项目的依赖防火墙交互。依赖防火墙会在软件包被获取之前，阻止不符合项目安全策略的软件包。

<a id="retrieve-status-of-dependency-firewall-for-a-project"></a>

## 检索项目的依赖防火墙状态

检索指定项目的依赖防火墙状态。使用此端点可确定是否在整个运行过程中跳过防火墙。已关闭防火墙的项目会返回成功响应，而不是 `404 Not Found`，因此您可以将它们与无法访问的项目区分开来。

此端点接受个人访问令牌、项目访问令牌、群组访问令牌、OAuth 令牌或 [CI/CD 作业令牌](../ci/jobs/ci_job_token.md)。不支持部署令牌。未认证的请求会被拒绝，包括对公开项目的请求。

CI/CD 作业令牌不需要任何特定的细粒度权限。约束它的是其作业运行所在的项目：作业令牌只能检查该项目。对任何其他项目的请求都会被拒绝，并返回 `403 Forbidden`，即使目标项目在其[入站作业令牌允许名单](../ci/jobs/ci_job_token.md)中允许该作业所在的项目，也无论该允许名单条目授予了哪些细粒度权限。一个项目的防火墙状态不是另一个项目的流水线所需要的信息。

先决条件：

- 您必须拥有读取该项目的权限。

```plaintext
GET /projects/:id/dependency_firewall/enablement
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性  | 类型    | 描述 |
| ---------- | ------- | ----------- |
| `enabled`  | boolean | 是否为该项目启用依赖防火墙。这是一个合并后的单一答案：响应不会说明该结果是由许可证还是命名空间设置产生的。 |

可能的响应代码：

| 状态码 | 描述 |
| ----------- | ----------- |
| `401`       | 未授权。请求未包含有效的身份验证。 |
| `403`       | 禁止访问。该凭证无权使用此端点：CI/CD 作业令牌用于其作业运行所在项目之外的任何项目，或细粒度令牌没有读取该项目的权限。无法读取该项目的用户会收到 `404`。 |
| `404`       | 未找到。其含义取决于响应正文使用哪个键：`enabled`、`message` 或 `error`。请参阅此表之后的指导。 |
| `429`       | 请求过多。您已超过此端点的速率限制，该限制以调用用户为范围。此限制与其他项目端点的限制是分开的。 |

当功能标志关闭时，该端点返回 `404` 而不是 `200`，因为该端点尚未正式发布。因此，`404` 响应意味着三种情况之一，客户端通过响应正文使用哪个键来区分它们，而不是通过文本的措辞：

- 正文包含 `enabled` 键，例如 `{"enabled": false}`，表示该项目的功能标志已关闭。防火墙未启用，因此客户端可以在本次运行中跳过它。
- 正文包含 `error` 键，例如 `{"error":"404 Not Found"}`，表示该实例上不存在此端点。例如，该实例可能运行的是极狐GitLab 基础版，或者是在添加此端点之前发布的版本。客户端应回退到其先前的行为，而不是报告配置问题。
- 正文包含 `message` 键，表示该端点存在但拒绝了请求。该项目要么不存在，要么您无法读取它。客户端应报告配置问题，且不得将该项目视为未受保护。

不要根据消息文本做出此判断。项目不可读的调用方会收到 `{"message":"404 Project Not Found"}`，但缺少项目访问权限的细粒度令牌会收到 `{"message":"404 Not Found"}`，如果只比较措辞，后者读起来与端点缺失的情况相同。

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

## 根据项目的依赖防火墙策略评估软件包

根据指定项目的依赖防火墙策略评估单个软件包。

此端点接受个人访问令牌、项目访问令牌、群组访问令牌、OAuth 令牌或 [CI/CD 作业令牌](../ci/jobs/ci_job_token.md)。作业令牌只能评估其作业运行所在项目的软件包：用于任何其他项目的作业令牌都会被拒绝，并返回 `403 Forbidden` 状态码，即使目标项目在其[入站作业令牌允许名单](../ci/jobs/ci_job_token.md)中允许该作业所在的项目。不支持部署令牌。

先决条件：

- 您必须至少拥有该项目的报告者角色。软件包仓库不必开启：依赖防火墙评估从上游仓库获取的依赖项，因此评估权限独立于项目的软件包仓库设置。

```plaintext
POST /projects/:id/dependency_firewall/evaluate
```

支持的属性：

| 属性   | 类型              | 必填 | 描述 |
|-------------|-------------------|----------|-------------|
| `id`        | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `ecosystem` | string            | 是      | 软件包生态系统。为 `cargo`、`composer`、`conan`、`gem`、`golang`、`maven`、`npm`、`nuget`、`pub`、`pypi` 或 `swift` 之一。 |
| `name`      | string            | 是      | 软件包名称，最多 255 个字符。对于 `maven`，请使用 `groupId:artifactId` 形式，例如 `com.example:trivial-lib`。对于 `pypi`，名称在评估前会按照 PEP 503 进行规范化，因此 `Flask_Login` 和 `flask-login` 是等价的。 |
| `version`   | string            | 是      | 软件包版本，最多 255 个字符。 |
| `operation` | string            | 否       | 正在评估的软件包操作。为 `download` 或 `upload` 之一。默认为 `download`。 |

请求头：

- `X-Gitlab-Dependency-Firewall-Session-Id`：可选。将来自单次包管理器调用的所有评估归为一组，因此一条为每个软件包触发一次评估的安装命令可以通过此值进行关联。极狐GitLab 会在该评估的审计事件和分析事件中记录该值，并将其视为不透明值而不进行验证。

该值必须为 1 到 255 个字符，且只能包含字母、数字、下划线和连字符。如果该值不满足这些约束，极狐GitLab 会忽略它，评估会像您未发送该请求头一样继续进行。请求不会失败。

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型   | 描述 |
|-----------|--------|-------------|
| `outcome` | string | 评估结果。为 `allowed`、`warned` 或 `blocked` 之一。 |
| `reason`  | string | 描述该软件包为何被警告或阻止的消息。会指明匹配的策略。当 `outcome` 为 `allowed` 时为 `null`。 |

`outcome` 属性具有以下值之一：

- `allowed`：没有策略规则匹配该软件包。启用了依赖防火墙但未关联任何策略的项目始终返回 `allowed`。`allowed` 结果并不表示极狐GitLab 持有该软件包的漏洞或许可证数据。软件包元数据数据库中不存在的软件包也会被允许。
- `warned`：有策略规则匹配该软件包，且匹配的策略处于警告模式。
- `blocked`：有策略规则匹配该软件包，且匹配的策略处于强制执行模式。

此端点还可能返回以下状态码：

| 状态码 | 代码 | 描述 |
|-------------|------|-------------|
| `400` | 无 | `name` 或 `version` 为空，或者 `ecosystem` 或 `operation` 不是可接受的值之一。 |
| `401` | 无 | 请求未通过身份验证。 |
| `403` | 无 | 已认证用户对该项目没有至少报告者角色，或者请求使用了 CI/CD 作业令牌用于其作业运行所在项目之外的任何项目。 |
| `404` | 无 | 项目不存在、已认证用户无权访问该项目，或者 `dependency_firewall_phase1` 功能标志已禁用。 |
| `422` | `dependency_firewall_not_enforced` | 未为该项目启用依赖防火墙。 |
| `429` | 无 | 已超过此端点的速率限制。该限制以项目和用户的组合为范围。 |
| `503` | `dependency_firewall_evaluation_failed` | 软件包元数据查找未完成。阻止获取。 |

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

启用了依赖防火墙但未关联任何策略的项目的示例响应：

```json
{
  "outcome": "allowed",
  "reason": null
}
```

在流水线作业中，使用 [CI/CD 作业令牌](../ci/jobs/ci_job_token.md)进行身份验证：

```shell
curl --request POST \
  --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/1/dependency_firewall/evaluate" \
  --data '{"ecosystem": "npm", "name": "lodash", "version": "4.17.15"}'
```
