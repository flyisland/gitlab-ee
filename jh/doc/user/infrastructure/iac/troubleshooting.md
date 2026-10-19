---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 Terraform 与极狐GitLab 的集成
---

在使用 Terraform 与极狐GitLab 的集成时，您可能会遇到需要排查的问题。

<a id="gitlab_group_share_group-resources-not-detected-when-subgroup-state-is-refreshed"></a>

## 刷新子群组状态时未检测到 `gitlab_group_share_group` 资源

由于议题[“拥有权限的用户无法从 API 检索 `share_with_groups`”](https://gitlab.com/gitlab-org/gitlab/-/issues/328428)，GitLab Terraform provider 可能无法检测到现有的 `gitlab_group_share_group` 资源。这会导致运行 `terraform apply` 时出错，因为 Terraform 会尝试重新创建已存在的资源。

例如，考虑以下群组/子群组配置：

```plaintext
parent-group
├── subgroup-A
└── subgroup-B
```

其中：

- 用户 `user-1` 创建了 `parent-group`、`subgroup-A` 和 `subgroup-B`。
- `subgroup-A` 与 `subgroup-B` 共享。
- 用户 `terraform-user` 是 `parent-group`的成员，并继承了对两个子群组的 `owner` 访问权限。

刷新 Terraform 状态时，provider 发出的 API 查询 `GET /groups/:subgroup-A_id` 不会在 `shared_with_groups` 数组中返回
`subgroup-B`的详细信息。这便导致了该错误。

要变通解决此问题，请确保满足以下条件之一：

1. `terraform-user` 创建所有子群组资源。
1. 为 `subgroup-B` 上的 `terraform-user` 用户授予维护者或所有者角色。
1. `terraform-user` 继承了对 `subgroup-B`的访问权限，并且 `subgroup-B` 至少包含一个项目。

<a id="troubleshooting-terraform-state"></a>

## 故障排除 Terraform 状态

<a id="cant-lock-terraform-state-files-in-ci-jobs-for-terraform-apply-with-a-previous-jobs-plan"></a>

### 在 `terraform apply` 的 CI 作业中使用上一个作业的计划时，无法锁定 Terraform 状态文件

将 `-backend-config=` 传递给 `terraform init` 时，Terraform 会将这些值（包括 `password` 值）持久化到计划缓存文件中。

因此，如果要创建一个计划并在另一个 CI 作业中稍后使用同一计划，在使用 `-backend-config=password=$CI_JOB_TOKEN` 时，您可能会遇到 `Error: Error acquiring the state lock` 错误。这是因为 `$CI_JOB_TOKEN`的值仅在当前作业期间有效。

作为变通方法，请在 CI 作业中使用 [http 后端配置变量](https://www.terraform.io/language/settings/backends/http#configuration-variables)，按照[开始使用极狐GitLab CI](terraform_state.md#initialize-an-opentofu-state-as-a-backend-by-using-gitlab-cicd) 说明操作时，后台实际就是这样处理的。

<a id="error-address-required-field-is-not-set"></a>

### 错误：`"address": required field is not set`

默认情况下，极狐GitLab 将 `TF_ADDRESS` 设置为 `${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/${TF_STATE_NAME}`。如果您未在作业中设置 `TF_STATE_NAME` 或 `TF_ADDRESS`，作业将失败并显示错误消息
`Error: "address": required field is not set`。

要解决此问题，请确保在返回错误的作业中可以访问 `TF_ADDRESS` 或 `TF_STATE_NAME`：

1. 为该作业配置 [CI/CD 环境范围](../../../ci/variables/_index.md#for-a-project)。
1. 设置该作业的[环境](../../../ci/yaml/_index.md#environment)，与上一步中的环境范围匹配。

<a id="error-refreshing-state-http-remote-state-endpoint-requires-auth"></a>

### 刷新状态时出错：HTTP 远程状态端点需要身份验证

要解决此问题，请确保：

- 您使用的访问令牌具有 `api` 范围。
- 如果您已设置 `TF_HTTP_PASSWORD` CI/CD 变量，请确保执行以下任一操作：
  - 将其设置为与 `TF_PASSWORD` 相同的值
  - 如果您的 CI/CD 作业未显式使用 `TF_HTTP_PASSWORD` 变量，请将其移除。

<a id="enable-developer-role-access-to-destructive-commands"></a>

### 为开发者角色启用破坏性命令访问权限

要允许具有开发者角色的用户运行破坏性命令，您需要使用变通方法：

1. [创建项目访问令牌](../../project/settings/project_access_tokens.md#create-a-project-access-token)，并具有 `api` 范围。
1. 将 `TF_USERNAME` 和 `TF_PASSWORD` 添加到您的 CI/CD 变量中：
   1. 将 `TF_USERNAME`的值设置为项目访问令牌的用户名。
   1. 将 `TF_PASSWORD`的值设置为项目访问令牌的密码。
   1. 可选。保护这些变量，使其仅在受保护分支或受保护标签上运行的流水线中可用。

<a id="state-not-found-if-the-state-name-contains-a-period"></a>

### 状态名称包含句点时报状态未找到

在极狐GitLab 15.6 及更早版本中，如果状态名称包含句点，并且 Terraform 尝试锁定状态，则会返回 404 错误。

您可以通过在 Terraform 命令中添加 `-lock=false` 来变通解决此限制。极狐GitLab 后端会接受该请求，但会在内部从状态名称中剥离句点及其后的所有字符。例如，名为 `foo.bar`的状态将存储为 `foo`。但是，不建议使用此变通方法，它甚至可能导致状态名称冲突。

在极狐GitLab 15.7 及更高版本中，[支持包含句点的状态名称](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/106861)。如果您使用 `-lock=false` 变通方法并升级到极狐GitLab 15.7 或更高版本，您的作业可能会失败。失败的原因是极狐GitLab 后端使用完整状态名称存储新状态，这与现有状态名称不一致。

要修复失败的作业，请重命名状态名称，排除句点及其后的所有字符。

如果您设置了 `TF_HTTP_ADDRESS`、`TF_HTTP_LOCK_ADDRESS` 和 `TF_HTTP_UNLOCK_ADDRESS`，请务必更新其中的状态名称。

或者，您可以[迁移 OpenTofu 状态](terraform_state.md#migrate-to-a-gitlab-managed-opentofu-state)。

<a id="error-saving-state-http-error-404"></a>

### 保存状态时出错：HTTP 错误：404

如果状态名称包含正斜杠（`/`）字符，则可能会发生此错误。要解决此问题，请确保状态名称不包含任何正斜杠（`/`）字符。
