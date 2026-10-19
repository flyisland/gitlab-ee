---
stage: Developer Experience
group: API Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: REST API 弃用
description: "极狐GitLab REST API 中已弃用字段和计划进行的重大变更的列表。"
---

您应定期查看以下弃用信息，并进行建议的更改。这些弃用通常意味着 API 功能的改进，并推荐使用新的字段或端点来实现功能。

尽管某些弃用提及了 v5 REST API，但目前并未进行 v5 REST API 的开发。
极狐GitLab 不会在 REST API v4 中进行这些变更，并且 [REST API 遵循语义化版本控制](_index.md#versioning-and-deprecations)。

<a id="geo_nodes-api-endpoints"></a>

## `geo_nodes` API 端点

重大变更。[相关议题](https://jihulab.com/gitlab-cn/-/issues/369140)。

[`geo_nodes` API 端点](../geo_nodes.md) 已弃用，并被 [`geo_sites`](../geo_sites.md) 取代。
这是针对 [如何引用 Geo 部署](../../administration/geo/glossary.md) 进行的全局变更的一部分。
在整个应用程序中，“节点”已重命名为“站点”。这两个端点的功能保持不变。

<a id="merged_by-api-field"></a>

## `merged_by` API 字段

重大变更。[相关议题](https://jihulab.com/gitlab-cn/-/issues/350534)。

[合并请求 API](../merge_requests.md#list-merge-requests) 中的 `merged_by` 字段已弃用，取而代之的是 `merge_user` 字段，后者能更准确地标识在执行操作（如设置为自动合并、添加到合并火车）时，是谁合并了合并请求，而不仅仅是简单的合并操作。

我们鼓励 API 用户改用新的 `merge_user` 字段。`merged_by` 字段将在极狐GitLab REST API v5 中移除。

<a id="merge_status-api-field"></a>

## `merge_status` API 字段

重大变更。[相关议题](https://jihulab.com/gitlab-cn/-/issues/382032)。

[合并请求 API](../merge_requests.md#merge-status) 中的 `merge_status` 字段已弃用，取而代之的是 `detailed_merge_status` 字段，后者能更准确地标识合并请求可能处于的所有状态。我们鼓励 API 用户改用新的 `detailed_merge_status` 字段。`merge_status` 字段将在极狐GitLab REST API v5 中移除。

<a id="null-value-for-private_profile-attribute-in-user-api"></a>

### 用户 API 中 `private_profile` 属性的空值

重大变更。[相关议题](https://jihulab.com/gitlab-cn/-/issues/387005)。

当通过 API 创建和更新用户时，`null` 曾是 `private_profile` 属性的有效值，它会在内部被转换为默认值。在极狐GitLab REST API v5 中，`null` 将不再是该参数的有效值，如果使用，响应将为 400。此变更后，唯一有效的值将是 `true` 和 `false`。

<a id="single-merge-request-changes-api-endpoint"></a>

## 单个合并请求变更 API 端点

重大变更。[相关议题](https://jihulab.com/gitlab-cn/-/issues/322117)。

用于获取 [单个合并请求的变更](../merge_requests.md#retrieve-merge-request-changes) 的端点已弃用，取而代之的是 [列出合并请求差异](../merge_requests.md#list-merge-request-diffs) 端点。
我们鼓励 API 用户改用新的差异端点。

`单个合并请求的变更` 端点将在极狐GitLab REST API v5 中移除。

<a id="managed-licenses-api-endpoint"></a>

## 托管许可证 API 端点

重大变更。[相关议题](https://jihulab.com/gitlab-cn/-/issues/397067)。

用于获取给定项目所有托管许可证的端点已弃用，取而代之的是 [许可证审批策略](../../user/compliance/license_approval_policies.md) 功能。

希望继续基于检测到的许可证强制执行审批的用户，建议改为创建一个新的 [许可证审批策略](../../user/compliance/license_approval_policies.md)。

`托管许可证` 端点将在极狐GitLab REST API v5 中移除。

<a id="approvers-and-approver-group-fields-in-merge-request-approval-api"></a>

## 合并请求审批 API 中的审批人和审批人组字段

重大变更。[相关议题](https://jihulab.com/gitlab-cn/-/issues/353097)。

用于获取项目审批配置的端点，对于 `approvers` 和 `approval_groups` 字段返回空数组。
这些字段已弃用，取而代之的是用于 [列出合并请求的所有审批规则](../merge_request_approvals.md#list-all-approval-rules-for-a-merge-request) 的端点。我们鼓励 API 用户改用此端点。

这些字段将在极狐GitLab REST API v5 中从 `获取配置` 端点中移除。

<a id="runner-usage-of-active-replaced-by-paused"></a>

## Runner 对 `active` 的使用被 `paused` 取代

重大变更。[相关议题](https://jihulab.com/gitlab-cn/-/issues/351109)。

极狐GitLab Runner GraphQL API 端点中出现的 `active` 标识符，将在极狐GitLab 16.0 中重命名为 `paused`。

- 在 REST API v4 中，您可以使用 `paused` 属性代替 `active`
- 在 REST API v5 中，此变更将影响接收或返回 `active` 属性的端点，例如：
  - `GET /runners`
  - `GET /runners/all`
  - `GET /runners/:id` / `PUT /runners/:id`
  - `PUT --form "active=false" /runners/:runner_id`
  - `GET /projects/:id/runners` / `POST /projects/:id/runners`
  - `GET /groups/:id/runners`

极狐GitLab Runner 16.0 版本将在注册 Runner 时开始使用 `paused` 属性。

<a id="runner-status-will-not-return-paused"></a>

## Runner 状态将不会返回 `paused`

重大变更。[相关议题](https://jihulab.com/gitlab-cn/-/issues/344648)。

在未来的 REST API v5 中，极狐GitLab Runner 的端点将不会返回 `paused` 或 `active`。

Runner 的状态将仅与 Runner 的联系状态相关，例如：
`online`、`offline` 或 `not_connected`。状态 `paused` 或 `active` 将不再出现。

在检查 Runner 是否 `paused` 时，建议 API 用户检查布尔属性 `paused` 是否为 `true`。在检查 Runner 是否为 `active` 时，则检查 `paused` 是否为 `false`。

<a id="runner-will-not-return-ip_address"></a>

## Runner 将不会返回 `ip_address`

重大变更。[相关议题](https://jihulab.com/gitlab-cn/-/issues/415159)。

在极狐GitLab 17.0 中，[Runners API](../runners.md) 将返回 `""` 而不是 Runner 的 `ip_address`。
在 REST API v5 中，该字段将被移除。

<a id="default_branch_protection-api-field"></a>

## `default_branch_protection` API 字段

重大变更。[相关议题](https://jihulab.com/gitlab-cn/-/issues/408315)。

在极狐GitLab 17.0 中，`default_branch_protection` 字段对于以下 API 已弃用：

- [新建群组 API](../groups.md#create-a-group)
- [更新群组 API](../groups.md#update-group-attributes)
- [应用程序设置 API](../settings.md#update-application-settings)

您应改用 `default_branch_protection_defaults` 字段，该字段提供了对默认分支保护更细粒度的控制。

`default_branch_protection` 字段将在极狐GitLab REST API v5 中移除。

<a id="require_password_to_approve-api-field"></a>

## `require_password_to_approve` API 字段

`require_password_to_approve` 在极狐GitLab 16.9 中弃用。请改用 `require_reauthentication_to_approve` 字段。
如果您同时为两个字段提供值，则 `require_reauthentication_to_approve` 字段优先。

`require_password_to_approve` 字段将在极狐GitLab REST API v5 中移除。

<a id="pull-mirroring-configuration-with-the-projects-api-endpoint"></a>

## 使用项目 API 端点配置拉取镜像

重大变更。[相关议题](https://jihulab.com/gitlab-cn/-/issues/494294)。

在极狐GitLab 17.6 中，[使用项目 API 配置拉取镜像](../project_pull_mirroring.md#update-pull-mirroring-for-a-project-deprecated) 已弃用。
它被新的配置和端点 [`projects/:id/mirror/pull`](../project_pull_mirroring.md#update-project-pull-mirroring-settings) 所取代。

使用项目 API 的旧配置将在极狐GitLab REST API v5 中移除。

<a id="restrict_user_defined_variables-parameter-with-the-projects-api-endpoint"></a>

## 项目 API 端点中的 `restrict_user_defined_variables` 参数

在极狐GitLab 17.7 中，[项目 API 中的 `restrict_user_defined_variables` 参数](../projects.md#update-a-project) 已弃用，推荐仅使用 `ci_pipeline_variables_minimum_override_role`。

要达到与 `restrict_user_defined_variables: false` 相同的行为，请将 `ci_pipeline_variables_minimum_override_role` 设置为 `developer`。

<a id="namespace-parameter-in-project-import-api-endpoints"></a>

## 项目导入 API 端点中的 `namespace` 参数

重大变更。[相关议题](https://jihulab.com/gitlab-cn/-/issues/511053)。

在极狐GitLab 18.7 中，[项目导入导出 API](../project_import_export.md) 中的 `namespace` 参数已弃用，推荐使用 `namespace_id` 和 `namespace_path` 参数。`namespace` 参数同时接受 ID 或路径，当命名空间路径仅包含数字时，这会导致歧义。

您应改用：

- `namespace_id`，当通过数字 ID 指定命名空间时。
- `namespace_path`，当通过路径指定命名空间时。

`namespace` 参数将在极狐GitLab REST API v5 中移除。

