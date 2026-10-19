---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 托管的 Terraform/OpenTofu 状态
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

跨团队管理基础设施状态文件既需要安全性，也需要可靠性。极狐GitLab 托管的 OpenTofu 状态消除了状态管理的常见难题。只需极少的配置，您的 OpenTofu 状态就会成为极狐GitLab 项目的自然延伸。这种集成将您的基础设施定义、代码和状态都保存在一个安全的位置。

使用极狐GitLab 托管的 OpenTofu 状态，您可以：

- 通过静态加密安全地存储状态文件
- 通过内置版本控制跟踪变更，识别谁在何时更改了什么
- 使用极狐GitLab 权限模型控制访问，而无需创建单独的身份验证系统
- 跨团队协作，不会出现状态文件冲突或损坏
- 与您现有的极狐GitLab CI/CD 流水线无缝集成
- 从 CI/CD 作业和本地开发环境远程访问状态

<a id="disaster-recovery-considerations"></a>

## 灾难恢复注意事项

OpenTofu 状态文件在磁盘和对象存储中静态存储时，使用 Lockbox Ruby gem 加密。加密使用的密钥派生自 `db_key_base` 应用设置。由于采用这种加密方式，实例必须可用才能解密状态文件。

如果实例离线，您将无法访问或解密状态文件。如果您的状态文件中包含极狐GitLab 运行所依赖的基础设施的配置，这就会成为问题。

如果极狐GitLab 托管了用于引导自身的 OpenTofu 模块或其他依赖项，那么当实例离线时，这些依赖项将无法访问。

为避免此问题：

- 单独托管或备份依赖项。
- 使用没有共享故障点的独立极狐GitLab 实例。
- 考虑为关键引导依赖项使用其他托管方式。

<a id="prerequisites"></a>

## 先决条件

对于极狐GitLab 私有化部署，在您将极狐GitLab 用于 OpenTofu 状态文件之前：

- 管理员必须[设置 Terraform/OpenTofu 状态存储](../../../administration/terraform_state.md)。
- 您必须为项目开启**基础设施**菜单：
  1. 转到**设置** > **通用**。
  1. 展开**可见性、项目功能、权限**。
  1. 在**基础设施**下，开启开关。

<a id="secure-plan-data"></a>

## 保护计划数据

> [!warning]
> OpenTofu `plan.json` 或 `plan.cache` 文件未加密，可能包含密码、访问令牌或证书等敏感数据。
> 默认情况下，具有访客角色的用户可以访问您的计划文件。

要保护您的计划数据：

- 在[产物配置](../../../ci/yaml/_index.md#artifactsaccess)中设置 `access: 'developer'`。此设置将访问权限限制为具有开发者角色或更高角色的用户。
- [禁用公开流水线](../../../ci/pipelines/settings.md#change-pipeline-visibility-for-non-project-members-in-public-projects)。
- 加密计划输出。
- 将项目可见性设置为私有。

<a id="initialize-an-opentofu-state-as-a-backend-by-using-gitlab-cicd"></a>

## 使用极狐GitLab CI/CD 将 OpenTofu 状态初始化为后端

先决条件：

- 要通过 `tofu apply` 锁定、解锁和写入状态，您必须具有维护者或所有者角色。
- 要通过 `tofu plan -lock=false` 读取状态，您必须具有开发者、维护者或所有者角色。

要将极狐GitLab CI/CD 配置为后端：

1. 在您的 OpenTofu 项目中，在诸如 `backend.tf`的 `.tf` 文件里，
   定义 [HTTP 后端](https://opentofu.org/docs/language/settings/backends/http/)：

   ```hcl
   terraform {
     backend "http" {
     }
   }
   ```

1. 在项目代码仓库的根目录中，创建一个 `.gitlab-ci.yml` 文件。使用
   [OpenTofu CI/CD 组件](https://gitlab.com/components/opentofu)来构成您的 `.gitlab-ci.yml` 文件。
1. 将项目推送到极狐GitLab。此操作会触发一条流水线，该流水线
   会运行 `gitlab-tofu init`、`gitlab-tofu validate` 和
   `gitlab-tofu plan` 命令。
1. 从上一条流水线中触发手动的 `deploy` 作业。此操作会运行 `gitlab-tofu apply` 命令，从而预配所定义的基础设施。

上述命令的输出应可在作业日志中查看。

`gitlab-tofu` CLI 是 `tofu` CLI 的封装。

<a id="customizing-your-opentofu-environment-variables"></a>

### 自定义 OpenTofu 环境变量

在定义 CI/CD 作业时，您可以使用 [OpenTofu HTTP 配置变量](https://opentofu.org/docs/language/settings/backends/http/#configuration-variables)。

要自定义 `init` 并覆盖 OpenTofu 配置，请使用环境变量，而不是 `init -backend-config=...` 方式。当您使用 `-backend-config` 时，该配置会：

- 缓存在 `plan` 命令的输出中。
- 通常会传递到 `apply` 命令。

这种配置可能导致诸如[无法在 CI 作业中锁定状态文件](troubleshooting.md#cant-lock-terraform-state-files-in-ci-jobs-for-terraform-apply-with-a-previous-jobs-plan)之类的问题。

<a id="customize-the-plan-filename"></a>

#### 自定义计划文件名

默认情况下，`gitlab-tofu plan`（或 `gitlab-terraform plan`）命令始终将计划输出写入名为 `plan.cache`的文件。

要更改文件名，请在 CI/CD 流水线配置中设置 `TF_PLAN_CACHE` 环境变量。例如，要将文件名设置为 `my-plan.tfplan`：

```yaml
variables:
  TF_PLAN_CACHE: "my-plan.tfplan"
```

> [!note]
> 不要通过传递 `-out=<filename>` 选项来设置输出文件名。极狐GitLab 命令会覆盖此选项。

<a id="access-the-state-from-your-local-machine"></a>

## 从本地机器访问状态

您可以从本地机器访问极狐GitLab 托管的 OpenTofu 状态。

> [!warning]
> 在极狐GitLab 集群部署中，您不应使用本地存储。
> 状态可能会跨节点拆分，导致后续 OpenTofu 执行
> 不一致。请改用远程存储资源。

1. 确保 OpenTofu 状态已
   [为 CI/CD 初始化](#initialize-an-opentofu-state-as-a-backend-by-using-gitlab-cicd)。
1. 复制预先填充的 OpenTofu `init` 命令：

   1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
   1. 选择**运维** > **Terraform 状态**。
   1. 在您要使用的环境旁边，选择**操作**
      ({{< icon name="ellipsis_v" >}})，然后选择**复制 Terraform init 命令**。

1. 打开终端，并在本地机器上运行此命令。

<a id="migrate-to-a-gitlab-managed-opentofu-state"></a>

## 迁移到极狐GitLab 托管的 OpenTofu 状态

OpenTofu 支持在后端更改或重新配置时复制状态。使用这些操作可从其他后端
迁移到极狐GitLab 托管的 OpenTofu 状态。

您应使用本地终端来运行迁移到极狐GitLab 托管的 OpenTofu 状态所需的命令。

以下示例演示如何更改状态名称。从不同的状态存储后端迁移到极狐GitLab 托管的 OpenTofu 状态也需要相同的工作流。

您应[在本地机器上](#access-the-state-from-your-local-machine)运行这些命令。

<a id="set-up-the-initial-backend"></a>

### 设置初始后端

{{< tabs >}}

{{< tab title="使用 GitLab CLI（glab）" >}}

要使用 `glab` 初始化后端，请运行以下命令：

```shell
glab opentofu init <old_state_name>
```

{{< /tab >}}

{{< tab title="Manually with OpenTofu CLI" >}}

要使用 OpenTofu CLI 初始化后端，请运行以下命令：

```shell
PROJECT_ID="<gitlab-project-id>"
TF_USERNAME="<gitlab-username>"
TF_PASSWORD="<gitlab-personal-access-token>"
TF_ADDRESS="https://jihulab.com/api/v4/projects/${PROJECT_ID}/terraform/state/old-state-name"

tofu init \
  -backend-config=address=${TF_ADDRESS} \
  -backend-config=lock_address=${TF_ADDRESS}/lock \
  -backend-config=unlock_address=${TF_ADDRESS}/lock \
  -backend-config=username=${TF_USERNAME} \
  -backend-config=password=${TF_PASSWORD} \
  -backend-config=lock_method=POST \
  -backend-config=unlock_method=DELETE \
  -backend-config=retry_wait_min=5
```

{{< /tab >}}

{{< /tabs >}}

如果后端初始化成功，您会收到以下响应：

```plaintext
Initializing the backend...

Successfully configured the backend "http"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
re-run this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

<a id="change-the-backend"></a>

### 更改后端

现在 `tofu init` 已创建了一个知道旧状态位置的 `.terraform/` 目录，您可以告诉它新位置：

{{< tabs >}}

{{< tab title="使用 GitLab CLI（glab）" >}}

```shell
glab opentofu init <new-state-name> -- -migrate-state
```

{{< /tab >}}

{{< tab title="Manually with OpenTofu CLI" >}}

```shell
TF_ADDRESS="https://jihulab.com/api/v4/projects/${PROJECT_ID}/terraform/state/<new-state-name>"

tofu init \
  -migrate-state \
  -backend-config=address=${TF_ADDRESS} \
  -backend-config=lock_address=${TF_ADDRESS}/lock \
  -backend-config=unlock_address=${TF_ADDRESS}/lock \
  -backend-config=username=${TF_USERNAME} \
  -backend-config=password=${TF_PASSWORD} \
  -backend-config=lock_method=POST \
  -backend-config=unlock_method=DELETE \
  -backend-config=retry_wait_min=5
```

{{< /tab >}}

{{< /tabs >}}

如果后端初始化成功，您会收到以下响应。如果您输入 `yes`，它会将您的状态从旧位置复制到新位置。然后您可以回到极狐GitLab CI/CD 中运行它：

```plaintext
Initializing the backend...
Backend configuration changed!

Terraform has detected that the configuration specified for the backend
has changed. Terraform will now check for existing state in the backends.


Acquiring state lock. This may take a few moments...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "http" backend to the
  newly configured "http" backend. No existing state was found in the newly
  configured "http" backend. Do you want to copy this state to the new "http"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes


Successfully configured the backend "http"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

<a id="use-your-gitlab-backend-as-a-remote-data-source"></a>

## 将极狐GitLab 后端用作远程数据源

您可以将极狐GitLab 托管的 OpenTofu 状态后端用作
[OpenTofu 数据源](https://opentofu.org/docs/language/state/remote-state-data/)。

1. 在您的 `main.tf` 或其他相关文件中，声明这些变量。将值留空。

   ```hcl
   variable "example_remote_state_address" {
     type = string
     description = "Gitlab remote state file address"
   }

   variable "example_username" {
     type = string
     description = "Gitlab username to query remote state"
   }

   variable "example_access_token" {
     type = string
     description = "GitLab access token to query remote state"
   }
   ```

1. 要覆盖上一步中的值，请创建一个名为 `example.auto.tfvars`的文件。此文件不应在您的项目代码仓库中进行版本控制。

   ```plaintext
   example_remote_state_address = "https://jihulab.com/api/v4/projects/<TARGET-PROJECT-ID>/terraform/state/<TARGET-STATE-NAME>"
   example_username = "<GitLab username>"
   example_access_token = "<GitLab personal access token>"
   ```

1. 在 `.tf` 文件中，使用 [OpenTofu 输入变量](https://opentofu.org/docs/language/values/variables/)定义数据源：

   ```hcl
   data "terraform_remote_state" "example" {
     backend = "http"

     config = {
       address = var.example_remote_state_address
       username = var.example_username
       password = var.example_access_token
     }
   }
   ```

   - **address**：您要用作数据源的远程状态后端的 URL。
     例如，`https://jihulab.com/api/v4/projects/<TARGET-PROJECT-ID>/terraform/state/<TARGET-STATE-NAME>`。
   - **username**：用于向数据源进行身份验证的用户名。如果您使用
     [个人访问令牌](../../profile/personal_access_tokens.md)进行
     身份验证，此值为您的极狐GitLab 用户名。如果您使用极狐GitLab CI/CD，此值为 `'gitlab-ci-token'`。
   - **password**：用于向数据源进行身份验证的密码。如果您使用个人访问令牌进行
     身份验证，此值为令牌值（该令牌必须具有 **API** 范围）。
     如果您使用极狐GitLab CI/CD，此值为 `${CI_JOB_TOKEN}` CI/CD 变量的内容。

现在可以在您的 Terraform 资源中使用 `data.terraform_remote_state.example.outputs.<OUTPUT-NAME>` 引用数据源的输出。

要读取目标项目中的 OpenTofu 状态，您需要开发者、维护者或所有者角色。

<a id="manage-opentofu-state-files"></a>

## 管理 OpenTofu 状态文件

要查看 OpenTofu 状态文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**运维** > **Terraform 状态**。

[存在一个史诗](https://gitlab.com/groups/gitlab-org/-/epics/4563)来跟踪此 UI 的改进。

<a id="manage-individual-opentofu-state-versions"></a>

### 管理单个 OpenTofu 状态版本

使用 GitLab CLI（`glab`）或 API 管理单个状态版本。

先决条件：

- 要使用序列号获取状态版本，您必须具有开发者、维护者或所有者角色。
- 要使用序列号移除状态版本，您必须具有维护者或所有者角色。

要使用序列号获取状态版本：
{{< tabs >}}

{{< tab title="使用 GitLab CLI（glab）" >}}

```shell
glab opentofu state download <your_state_name> <version_serial_number>
```

{{< /tab >}}

{{< tab title="手动使用 curl" >}}

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/terraform/state/<your_state_name>/versions/<version_serial_number>"
```

{{< /tab >}}

{{< /tabs >}}

要使用序列号移除状态版本：

{{< tabs >}}

{{< tab title="使用 GitLab CLI（glab）" >}}

```shell
glab opentofu state delete <your_state_name> <version_serial_number>
```

{{< /tab >}}

{{< tab title="手动使用 curl" >}}

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/terraform/state/<your_state_name>/versions/<version_serial_number>"
```

{{< /tab >}}

{{< /tabs >}}

<a id="remove-a-state-file"></a>

### 移除状态文件

先决条件：

- 要移除状态文件，您必须具有维护者或所有者角色。

{{< tabs >}}

{{< tab title="使用 GitLab CLI（glab）" >}}

```shell
glab opentofu state delete <your_state_name>
```

{{< /tab >}}

{{< tab title="手动使用 curl" >}}

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/terraform/state/<your_state_name>"
```

您还可以使用 [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)和基本身份验证：

```shell
curl --request DELETE --user "gitlab-ci-token:$CI_JOB_TOKEN" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/terraform/state/<your_state_name>"
```

您还可以使用 [GraphQL API](../../../api/graphql/reference/_index.md#mutationterraformstatedelete)。

{{< /tab >}}

{{< tab title="使用 UI" >}}

要使用 UI 移除状态文件：

1. 在左侧边栏中，选择**运维** > **Terraform 状态**。
1. 在**操作**列中，选择**操作** ({{< icon name="ellipsis_v" >}}) > **移除状态文件和版本**。

{{< /tab >}}

{{< /tabs >}}

<a id="lock-and-unlock-a-state"></a>

### 锁定和解锁状态

先决条件：

- 要锁定状态文件，您必须具有维护者或所有者角色。

{{< tabs >}}

{{< tab title="使用 GitLab CLI（glab）" >}}

```shell
# Lock a state file
glab opentofu state lock <your_state_name>

# Unlock a state file
glab opentofu state unlock <your_state_name>
```

{{< /tab >}}

{{< tab title="手动使用 curl" >}}

```shell
# Lock a state file
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/terraform/state/<your_state_name>/lock"

# Unlock a state file
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/terraform/state/<your_state_name>/lock"
```

{{< /tab >}}

{{< tab title="使用 UI" >}}

要使用 UI 锁定或解锁状态文件：

1. 在左侧边栏中，选择**运维** > **Terraform 状态**。
1. 在**操作**列中，选择**操作** ({{< icon name="ellipsis_v" >}}) > **锁定**以锁定，或选择**操作** ({{< icon name="ellipsis_v" >}}) > **解锁**。

{{< /tab >}}

{{< /tabs >}}

<a id="download-a-state-file"></a>

### 下载状态文件

先决条件：

- 要下载状态文件，您必须具有开发者、维护者或所有者角色。

{{< tabs >}}

{{< tab title="使用 GitLab CLI（glab）" >}}

```shell
# Download the latest state
glab opentofu state download <your_state_name>

# Download a specific version (serial) of a state
glab opentofu state download <your_state_name> <your_serial>
```

{{< /tab >}}

{{< tab title="手动使用 curl" >}}

```shell
# Download the latest state
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/terraform/state/<your_state_name>"

# Download a specific version (serial) of a state
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/terraform/state/<your_state_name>/versions/<version_serial_number>"
```

{{< /tab >}}

{{< tab title="使用 UI" >}}

要使用 UI 下载最新的状态文件：

1. 在左侧边栏中，选择**运维** > **Terraform 状态**。
1. 在**操作**列中，选择**操作** ({{< icon name="ellipsis_v" >}}) > **下载 JSON**。

无法使用 UI 下载特定版本的状态。

{{< /tab >}}

{{< /tabs >}}

<a id="protect-sensitive-data-in-terraform-state-files"></a>

#### 保护 Terraform 状态文件中的敏感数据

Terraform 状态文件可能包含密码、私钥、API 令牌和数据库连接字符串等敏感信息。在极狐GitLab 中，任何具有开发者角色或更高角色的用户都可以下载并查看其所属项目的 Terraform 状态文件。

要减少敏感数据的暴露：

- 极狐GitLab 旗舰版客户：创建一个复制开发者角色但排除 `admin_terraform_state` 权限的自定义角色。此操作允许团队成员为基础设施即代码（IaC）项目做出贡献，而无需访问包含敏感数据的 Terraform 状态文件。

  > [!note]
  > 自定义角色仅在极狐GitLab 旗舰版上可用。专业版或更低版本的客户无法使用此缓解选项，应重点关注前面介绍的其他策略。

- OpenTofu 用户：开启状态和计划加密，以保护静态存储的敏感数据。极狐GitLab 通过 [OpenTofu CI/CD 组件](https://gitlab.com/components/opentofu)原生支持此功能，该组件提供加密配置。即使未经授权的用户访问了状态文件，加密内容仍受到保护。
- 所有用户：
  - 将项目成员资格限制为需要访问基础设施状态的用户。
  - 使用单独的项目存储状态，仅将必要的用户添加为成员。
  - 使用 HashiCorp Vault 或 AWS Secrets Manager 等外部密钥管理解决方案动态引用密钥，而不是将其存储在 Terraform 配置中。
  - 在变量定义中使用 Terraform [`sensitive`](https://developer.hashicorp.com/terraform/language/values/variables#suppressing-values-in-cli-output) 参数标记敏感值。此操作可防止值出现在 CLI 输出和计划文件中，不过它们仍会保留在状态文件中。
  - 定期审计具有开发者角色的项目成员，并检查状态文件内容是否存在意外暴露的密钥。
