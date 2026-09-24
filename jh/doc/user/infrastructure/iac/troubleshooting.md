---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 Terraform 与极狐GitLab 集成的问题
---

在使用 Terraform 与极狐GitLab 集成时，可能会遇到需要排查的问题。

## `gitlab_group_share_group` 资源在子群组状态刷新时未被检测到

由于议题["具有权限的用户无法从 API 检索 `share_with_groups`"](https://gitlab.com/gitlab-org/gitlab/-/issues/328428)，极狐GitLab Terraform provider 可能无法检测到现有的 `gitlab_group_share_group` 资源。
这会导致运行 `terraform apply` 时出错，因为 Terraform 尝试重新创建已存在的资源。

例如，考虑以下群组/子群组配置：

```plaintext
parent-group
├── subgroup-A
└── subgroup-B
```

其中：

- 用户 `user-1` 创建了 `parent-group`、`subgroup-A` 和 `subgroup-B`。
- `subgroup-A` 已与 `subgroup-B` 共享。
- 用户 `terraform-user` 是 `parent-group` 的成员，拥有继承至两个子群组的 `owner` 权限。

当 Terraform 状态刷新时，provider 发出的 `GET /groups/:subgroup-A_id` API 查询无法在 `shared_with_groups` 数组中返回 `subgroup-B` 的详细信息。这导致了错误。

要解决此问题，请确保满足以下条件之一：

1. `terraform-user` 创建了所有子群组资源。
1. 向 `terraform-user` 用户授予对 `subgroup-B` 的维护者或所有者角色。
1. `terraform-user` 继承了对 `subgroup-B` 的访问权限，并且 `subgroup-B` 至少包含一个项目。

## 排查 Terraform 状态

### 在 `terraform apply` 的 CI 作业中无法使用前一个作业的计划锁定 Terraform 状态文件

当将 `-backend-config=` 传递给 `terraform init` 时，Terraform 会将这些值（包括 `password` 值）持久化保存在计划缓存文件中。

因此，要创建一个计划并在另一个 CI 作业中稍后使用同一计划，当使用 `-backend-config=password=$CI_JOB_TOKEN` 时，您可能会遇到 `Error: Error acquiring the state lock` 错误。
这是因为 `$CI_JOB_TOKEN` 的值仅在当前作业的持续时间内有效。

作为解决方法，请在 CI 作业中使用 [http backend configuration variables](https://www.terraform.io/language/settings/backends/http#configuration-variables)，这是在遵循[开始使用极狐GitLab CI](terraform_state.md#initialize-an-opentofu-state-as-a-backend-by-using-gitlab-cicd) 说明时的实际执行方式。

### 错误：`"address": required field is not set`

默认情况下，极狐GitLab 将 `TF_ADDRESS` 设置为 `${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/${TF_STATE_NAME}`。
如果您未在作业中设置 `TF_STATE_NAME` 或 `TF_ADDRESS`，作业将失败并显示错误消息 `Error: "address": required field is not set`。

要解决此问题，请确保在返回错误的作业中能够访问 `TF_ADDRESS` 或 `TF_STATE_NAME`：

1. 为该作业配置 [CI/CD 环境作用域](../../../ci/variables/_index.md#for-a-project)。
1. 设置作业的 [environment](../../../ci/yaml/_index.md#environment)，使其与上一步中的环境作用域匹配。

### Error refreshing state: HTTP remote state endpoint requires auth

要解决此问题，请确保：

- 您使用的访问令牌具有 `api` 作用域。
- 如果您已设置 `TF_HTTP_PASSWORD` CI/CD 变量，请确保您：
  - 设置了与 `TF_PASSWORD` 相同的值
  - 或者，如果您的 CI/CD 作业未显式使用 `TF_HTTP_PASSWORD` 变量，则将其移除。

### 启用开发者角色对破坏性命令的访问权限

要允许具有开发者角色的用户运行破坏性命令，您需要一种解决方法：

1. [创建一个项目访问令牌](../../project/settings/project_access_tokens.md#create-a-project-access-token)，其作用域为 `api`。
1. 将 `TF_USERNAME` 和 `TF_PASSWORD` 添加到您的 CI/CD 变量中：
   1. 将 `TF_USERNAME` 的值设置为您的项目访问令牌的用户名。
   1. 将 `TF_PASSWORD` 的值设置为您的项目访问令牌的密码。
   1. 可选。保护这些变量，使其仅在运行于受保护分支或受保护标签的流水线中可用。

### 如果状态名称包含句点，则找不到状态

极狐GitLab 15.6 及更早版本中，如果状态名称包含句点并且 Terraform 尝试进行状态锁定时，会返回 404 错误。

您可以通过在 Terraform 命令中添加 `-lock=false` 来解决此限制。极狐GitLab 后端会接受请求，但会在内部将句点及其后的所有字符从状态名称中剥离。
例如，名为 `foo.bar` 的状态将存储为 `foo`。但是，不推荐这种解决方法，甚至可能导致状态名称冲突。

在极狐GitLab 15.7 及更高版本中，[支持包含句点的状态名称](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/106861)。如果您使用了 `-lock=false` 的解决方法并升级到极狐GitLab 15.7 或更高版本，您的作业可能会失败。失败的原因是极狐GitLab 后端存储了一个使用完整状态名称的新状态，这与现有状态名称产生了分歧。

要修复失败的作业，请重命名您的状态名称，排除句点及其后的所有字符。

如果设置了 `TF_HTTP_ADDRESS`、`TF_HTTP_LOCK_ADDRESS` 和 `TF_HTTP_UNLOCK_ADDRESS`，请务必也更新其中的状态名称。

或者，您可以[迁移您的 OpenTofu 状态](terraform_state.md#migrate-to-a-gitlab-managed-opentofu-state)。

### Error saving state: HTTP error: 404

如果状态名称包含正斜杠（`/`）字符，可能会发生此错误。
要解决此问题，请确保状态名称不包含任何正斜杠（`/`）字符。