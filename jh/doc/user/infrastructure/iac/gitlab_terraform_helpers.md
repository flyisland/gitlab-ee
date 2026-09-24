---
stage: Deploy
group: Environments
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 极狐GitLab Terraform 帮助器
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< alert type="warning" >}}

Terraform CI/CD 模板已被启用并计划在 18.0 中被移除。

{{< /alert >}}

极狐GitLab 提供两个助手来简化与 [极狐GitLab 托管 Terraform 状态](terraform_state.md) 的集成。

- `gitlab-terraform` 脚本，这是 `terraform` 命令的轻量包装。
- `terraform-images` 容器镜像，包含 `gitlab-terraform` 脚本和 `terraform` 本身。

<a id="`gitlab-terraform`"></a>

## `gitlab-terraform`

`gitlab-terraform` 脚本是 `terraform` 命令的轻量包装。

在 CI/CD 流水线中运行 `gitlab-terraform` 以设置连接到 [极狐GitLab 托管 Terraform 状态](terraform_state.md) 后端所需的环境变量。

<a id="source-but-do-not-run-the-helper-script"></a>

### 源（但不运行）助手脚本

当 `gitlab-terraform` 脚本被源化时，它会为 `terraform` 调用配置环境，但不会实际运行 `terraform`。当您需要执行额外步骤来准备环境或使用替代工具（如 `terragrunt`）时，可以源化该脚本。

要源化脚本，执行：

```shell
source $(which gitlab-terraform)
```

一些 shell，如 BusyBox，不支持其他脚本源化您的脚本的情况。为了解决此问题，您应该使用 `bash`，`zsh` 或 `ksh`，或者直接从 shell 源化 `gitlab-terraform`。

<a id="commands"></a>

### 命令

您可以使用以下命令运行 `gitlab-terraform`。

| Command                      | Forwards command line? | Implicit init?        | Description                                                                                           |
|------------------------------|------------------------|-----------------------|-------------------------------------------------------------------------------------------------------|
| `gitlab-terraform apply`     | Yes                    | Yes                   | Runs `terraform apply`.                                                                               |
| `gitlab-terraform destroy`   | Yes                    | Yes                   | Runs `terraform destroy`.                                                                             |
| `gitlab-terraform fmt`       | Yes                    | No                    | Runs `terraform fmt` in check mode.                                                                   |
| `gitlab-terraform init`      | Yes                    | Not applicable        | Runs `terraform init`.                                                                                |
| `gitlab-terraform plan`      | Yes                    | Yes                   | Runs `terraform plan` and produces a `plan.cache` file.                                               |
| `gitlab-terraform plan-json` | No                     | No                    | Converts a `plan.cache` file into a 极狐GitLab Terraform report for a [MR integration](mr_integration.md). |
| `gitlab-terraform validate`  | Yes                    | Yes (without backend) | Runs `terraform validate`.                                                                            |
| `gitlab-terraform -- <cmd>`  | Yes                    | No                    | Runs `terraform <cmd>`, even if it is wrapped.                                                        |
| `gitlab-terraform <cmd>`     | Yes                    | No                    | Runs `terraform <cmd>`, if the command is not wrapped.                                                |

<a id="generic-variables"></a>

### 通用变量

当您运行 `gitlab-terraform` 时，会配置这些变量。

| Variable             | Default                                    | Description                                                                                                                                                                |
|----------------------|--------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `TF_ROOT`            | Not set                                    | 根的 Terraform 配置。如果设置，它将用作 Terraform `-chdir` 参数值。所有读取和写入的文件都是相对于给定配置根的。                                                         |
| `TF_CLI_CONFIG_FILE` | `$HOME/.terraformrc`                       | Terraform 配置文件的位置。                                                                            |
| `TF_IN_AUTOMATION`   | `true`                                     | 设置为 `true` 表示 Terraform 命令是自动化的。                                                                                                                               |
| `TF_GITLAB_SOURCED`  | `false`                                    | 如果 `gitlab-terraform` [被源化](#source-but-do-not-run-the-helper-script)，则设置为 `true`。                                                                              |
| `TF_PLAN_CACHE`      | `$TF_ROOT/plan.cache` or `$PWD/plan.cache` | 计划缓存文件的位置。如果 `TF_ROOT` 未设置，则其路径是相对于当前工作目录 (`$PWD`) 的。                                                                                    |
| `TF_PLAN_JSON`       | `$TF_ROOT/plan.json` or `$PWD/plan.json`   | [MR 集成](mr_integration.md) 的计划 JSON 文件的位置。如果 `TF_ROOT` 未设置，则其路径是相对于当前工作目录 (`$PWD`) 的。                                                   |
| `DEBUG_OUTPUT`       | `"false"`                                  | 如果设置为 `"true"`，则每个语句都使用 `set -x` 记录。                                                                                                                      |

<a id="gitlab-managed-terraform-state-variables"></a>

### 极狐GitLab 托管 Terraform 状态变量

当您运行 `gitlab-terraform` 时，会配置这些变量。

| Variable                 | Default                                                                                                                 | Description                                                                                                                                                                                                               |
|--------------------------|-------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `TF_STATE_NAME`          | Not set                                                                                                                 | 如果 `TF_ADDRESS` 未设置，并且提供了 `TF_STATE_NAME`，则 `TF_STATE_NAME` 的值将用作 [极狐GitLab 托管 Terraform 状态](terraform_state.md) 名称。                                      |
| `TF_ADDRESS`             | Terraform State API URL for `$TF_STATE_NAME`                                                                            | 作为 `TF_HTTP_ADDRESS` 的默认值。默认情况下使用 `TF_STATE_NAME` 作为 [极狐GitLab 托管 Terraform 状态](terraform_state.md) 名称。   |
| `TF_USERNAME`            | [`$GITLAB_USER_LOGIN`](../../../ci/variables/predefined_variables.md) 或 `gitlab-ci-token` 如果 `$TF_PASSWORD` 未设置 | 用作 `TF_HTTP_USERNAME` 的默认值。                                                                                                    |
| `TF_PASSWORD`            | [`$CI_JOB_TOKEN`](../../../ci/variables/predefined_variables.md)                                                        | 用作 `TF_HTTP_PASSWORD` 的默认值。                                                                                                    |
| `TF_HTTP_ADDRESS`        | `$TF_ADDRESS`                                                                                                           | Terraform 后端的地址。                                                                                                                |
| `TF_HTTP_LOCK_ADDRESS`   | `$TF_ADDRESS/lock`                                                                                                      | Terraform 后端锁定端点的地址。                                                                                                   |
| `TF_HTTP_LOCK_METHOD`    | `POST`                                                                                                                  | 用于 Terraform 后端锁定端点的方法。                                                                                               |
| `TF_HTTP_UNLOCK_ADDRESS` | `$TF_ADDRESS/lock`                                                                                                      | Terraform 后端解锁端点的地址。                                                                                                  |
| `TF_HTTP_UNLOCK_METHOD`  | `DELETE`                                                                                                                | 用于 Terraform 后端解锁端点的方法。                                                                                             |
| `TF_HTTP_USERNAME`       | `$TF_USERNAME`                                                                                                          | 用于与 Terraform 后端进行身份验证的用户名。                                                                                         |
| `TF_HTTP_PASSWORD`       | `$TF_PASSWORD`                                                                                                          | 用于与 Terraform 后端进行身份验证的密码。                                                                                           |
| `TF_HTTP_RETRY_WAIT_MIN` | `5`                                                                                                                     | 在 HTTP 请求尝试之间等待的最短时间（以秒为单位）到 Terraform 后端。                                                           |

<a id="command-variables"></a>

### 命令变量

当您运行 `gitlab-terraform` 时，会配置这些变量。

| Variable                 | Default  | Description                                                                               |
|--------------------------|----------|-------------------------------------------------------------------------------------------|
| `TF_IMPLICIT_INIT`       | `true`   | 如果为 `true`，则在需要的封装命令之前运行隐式 `terraform init`。                          |
| `TF_INIT_NO_RECONFIGURE` | `false`  | 如果为 `true`，则隐式 `terraform init` 在没有 `-reconfigure` 的情况下运行。                |
| `TF_INIT_FLAGS`          | Not set  | 额外的 `terraform init` 标志。                                                            |

<a id="terraform-input-variables"></a>

### Terraform 输入变量

当您运行 `gitlab-terraform` 时，这些 Terraform 输入变量会自动设置。有关默认值的更多信息，请参阅 [预定义变量](../../../ci/variables/predefined_variables.md)。

| Variable                      | Default                 |
|-------------------------------|-------------------------|
| `TF_VAR_CI_JOB_ID`            | `$CI_JOB_ID`            |
| `TF_VAR_CI_COMMIT_SHA`        | `$CI_COMMIT_SHA`        |
| `TF_VAR_CI_JOB_STAGE`         | `$CI_JOB_STAGE`         |
| `TF_VAR_CI_PROJECT_ID`        | `$CI_PROJECT_ID`        |
| `TF_VAR_CI_PROJECT_NAME`      | `$CI_PROJECT_NAME`      |
| `TF_VAR_CI_PROJECT_NAMESPACE` | `$CI_PROJECT_NAMESPACE` |
| `TF_VAR_CI_PROJECT_PATH`      | `$CI_PROJECT_PATH`      |
| `TF_VAR_CI_PROJECT_URL`       | `$CI_PROJECT_URL`       |

<a id="terraform-images"></a>

## Terraform 镜像

`gitlab-terraform` 辅助脚本和 `terraform` 本身在 `registry.gitlab.com/gitlab-org/terraform-images/` 下的容器镜像中提供。您可以使用这些镜像来配置和管理您的集成。

提供以下镜像：

| Image name                    | Tag                         | Description                                                                    |
|-------------------------------|-----------------------------|--------------------------------------------------------------------------------|
| `stable`                      | `latest`                    | 最新的 `terraform-images` 发布版本，捆绑了最新的 Terraform 发布。               |
| `releases/$TERRAFORM_VERSION` | `latest`                    | 最新的 `terraform-images` 发布版本，捆绑了特定的 Terraform 发布。               |
| `releases/$TERRAFORM_VERSION` | `$TERRAFORM_IMAGES_VERSION` | 特定的 `terraform-images` 发布版本，捆绑了特定的 Terraform 发布。               |

<a id="related-topics"></a>

## 相关主题

- [Terraform CI/CD 模板](_index.md)

