---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 管理的 Terraform/OpenTofu 状态
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.7 中引入了对包含句点的状态名称的支持，带有一个名为 `allow_dots_on_tf_state_names` 的功能标志。默认禁用。
- 在极狐GitLab 16.0 中，对包含句点的状态名称的支持 GA。功能标志 `allow_dots_on_tf_state_names` 已移除。
- 在极狐GitLab 18.3 中引入了对极狐GitLab 管理的 OpenTofu 和 Terraform 状态的支持。需要 GitLab CLI (`glab`) 1.66 或更高版本。

{{< /history >}}

跨团队管理基础设施状态文件需要兼顾安全性和可靠性。极狐GitLab 管理的 OpenTofu 状态消除了状态管理的典型挑战。只需最少的配置，你的 OpenTofu 状态就会成为极狐GitLab 项目的自然延伸。这种集成将你的基础设施定义、代码和状态全部集中在一个安全的位置。

借助极狐GitLab 管理的 OpenTofu 状态，你可以：

- 通过自动静态加密安全地存储状态文件
- 使用内置版本控制跟踪更改，以识别谁在何时更改了什么
- 使用极狐GitLab 权限模型控制访问，而无需创建单独的身份验证系统
- 跨团队协作，避免状态文件冲突或损坏
- 与你现有的极狐GitLab CI/CD 流水线无缝集成
- 从 CI/CD 作业和本地开发环境远程访问状态

<a id="disaster-recovery-considerations"></a>

## 灾难恢复注意事项

OpenTofu 状态文件在磁盘和对象存储中空闲时会使用 Lockbox Ruby gem 进行加密。加密使用从 `db_key_base` 应用设置派生的密钥。由于这种加密方式，实例必须可用才能解密状态文件。

如果实例离线，你将无法访问或解密你的状态文件。如果你的状态文件包含极狐GitLab 运行所依赖的基础设施的配置，这就会成为一个问题。

如果极狐GitLab 托管了引导自身所需的 OpenTofu 模块或其他依赖项，那么当实例离线时，这些依赖项将无法访问。

为避免此问题：

- 单独托管或备份依赖项。
- 使用一个独立的、没有共享故障点的极狐GitLab 实例。
- 考虑对关键的引导依赖项使用替代托管方案。

<a id="prerequisites"></a>

## 前提条件

对于私有化部署的极狐GitLab，在将极狐GitLab 用于你的 OpenTofu 状态文件之前：

- 管理员必须[设置 Terraform/OpenTofu 状态存储](../../../administration/terraform_state.md)。
- 你必须为你的项目开启**基础设施**菜单：
  1. 前往**设置** > **通用**。
  1. 展开**可见性、项目功能、权限**。
  1. 在**基础设施**下，打开开关。

<a id="secure-plan-data"></a>

## 保护计划数据

> [!warning]
> OpenTofu `plan.json` 或 `plan.cache` 文件未加密，可能包含敏感数据，如密码、访问令牌或证书。默认情况下，具有访客角色的用户可以访问你的计划文件。

为保护你的计划数据：

- 在你的[产物配置](../../../ci/yaml/_index.md#artifactsaccess)中设置 `access: 'developer'`。此设置将访问限制为具有开发者角色或更高角色的用户。
- [禁用公开流水线](../../../ci/pipelines/settings.md#change-pipeline-visibility-for-non-project-members-in-public-projects)。
- 加密计划输出。
- 将项目可见性设置为私有。

<a id="initialize-an-opentofu-state-as-a-backend-by-using-gitlab-cicd"></a>

## 使用极狐GitLab CI/CD 将 OpenTofu 状态初始化为后端

前提条件：

- 要通过 `tofu apply` 锁定、解锁和写入状态，你必须具有维护者或所有者角色。
- 要通过 `tofu plan -lock=false` 读取状态，你必须具有开发者、维护者或所有者角色。

要将极狐GitLab CI/CD 配置为后端：

1. 在你的 OpenTofu 项目中，在 `.tf` 文件（如 `backend.tf`）中定义 [HTTP 后端](https://opentofu.org/docs/language/settings/backends/http/)：

   ```hcl
   terraform {
     backend "http" {
     }
   }
   ```

1. 在你的项目仓库根目录中，创建一个 `.gitlab-ci.yml` 文件。使用 [OpenTofu CI/CD 组件](https://jihulab.com/components/opentofu) 来构建你的 `.gitlab-ci.yml` 文件。
1. 将你的项目推送到极狐GitLab。此操作会触发流水线，运行 `gitlab-tofu init`、`gitlab-tofu validate` 和 `gitlab-tofu plan` 命令。
1. 从前一条流水线触发手动 `deploy` 作业。此操作运行 `gitlab-tofu apply` 命令，用以配置定义的基础设施。

前述命令的输出可以在作业日志中查看。

`gitlab-tofu` CLI 是 `tofu` CLI 的封装器。

<a id="customizing-your-opentofu-environment-variables"></a>

### 自定义你的 OpenTofu 环境变量

在定义 CI/CD 作业时，你可以使用 [OpenTofu HTTP 配置变量](https://opentofu.org/docs/language/settings/backends/http/#configuration-variables)。

要自定义你的 `init` 并覆盖 OpenTofu 配置，请使用环境变量，而不是 `init -backend-config=...` 的方式。使用 `-backend-config` 时，配置会：

- 缓存在 `plan` 命令的输出中。
- 通常传递给 `apply` 命令。

此配置可能导致诸如[在 CI 作业中无法为 `terraform apply` 锁定 Terraform 状态文件](troubleshooting.md#cant-lock-terraform-state-files-in-ci-jobs-for-terraform-apply-with-a-previous-jobs-plan)之类的问题。

<a id="customize-the-plan-filename"></a>

#### 自定义计划文件名

默认情况下，`gitlab-tofu plan`（或 `gitlab-terraform plan`）命令始终将计划输出写入名为 `plan.cache` 的文件。

要更改文件名，请在 CI/CD 流水线配置中设置 `TF_PLAN_CACHE` 环境变量。例如，要将文件名设置为 `my-plan.tfplan`：

```yaml
variables:
  TF_PLAN_CACHE: "my-plan.tfplan"
```

> [!note]
> 不要通过传递 `-out=<filename>` 选项来设置输出文件名。极狐GitLab 命令会覆盖此选项。

<a id="access-the-state-from-your-local-machine"></a>

## 从本地机器访问状态

你可以从本地机器访问极狐GitLab 管理的 OpenTofu 状态。

> [!warning]
> 在极狐GitLab 的集群部署中，你不应使用本地存储。
> 状态可能会在节点之间分裂，导致后续 OpenTofu 执行
> 不一致。请改用远程存储资源。

1. 确保 OpenTofu 状态已[通过 CI/CD 初始化](#initialize-an-opentofu-state-as-a-backend-by-using-gitlab-cicd)。
1. 复制一个预填充的 OpenTofu `init` 命令：

   1. 在顶栏中，选择**搜索或跳转到**并找到你的项目。
   1. 选择**运维** > **Terraform 状态**。
   1. 在你想要使用的环境旁边，选择**操作**
      ({{< icon name="ellipsis_v" >}}) 并选择**复制 Terraform 初始化命令**。

1. 打开终端并在本地机器上运行此命令。

<a id="migrate-to-a-gitlab-managed-opentofu-state"></a>

## 迁移到极狐GitLab 管理的 OpenTofu 状态

OpenTofu 支持在后端更改或重新配置时复制状态。使用以下操作从其他后端迁移到极狐GitLab 管理的 OpenTofu 状态。

你应该使用本地终端运行迁移到极狐GitLab 管理的 OpenTofu 状态所需的命令。

以下示例演示了如何更改状态名称。从不同的状态存储后端迁移到极狐GitLab 管理的 OpenTofu 状态也需要相同的工作流程。

你应该[在本地机器上](#access-the-state-from-your-local-machine)运行这些命令。

<a id="set-up-the-initial-backend"></a>

### 设置初始后端

{{< tabs >}}

{{< tab title="使用 GitLab CLI (glab)" >}}

要使用 `glab` 初始化后端，请运行以下命令：

```shell
glab opentofu init <old_state_name>
```

{{< /tab >}}

{{< tab title="手动使用 OpenTofu CLI" >}}

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

如果后端初始化成功，你将收到以下响应：

```plaintext
正在初始化后端...

已成功配置后端 "http"！除非后端配置发生变化，Terraform 将自动
使用此后端。

正在初始化提供商插件...

Terraform 已成功初始化！

你现在可以开始使用 Terraform。尝试运行 "terraform plan" 以查看
你的基础设施所需的任何更改。所有 Terraform 命令
现在应该可以正常工作。

如果你曾设置或更改 Terraform 的模块或后端配置，
请重新运行此命令以重新初始化你的工作目录。如果你忘记，其他
命令将检测到并提醒你这样做。
```

<a id="change-the-backend"></a>

### 更改后端

现在 `tofu init` 已创建了一个 `.terraform/` 目录，其中记录了旧状态的所在，你可以告诉它新位置：

{{< tabs >}}

{{< tab title="使用 GitLab CLI (glab)" >}}

```shell
glab opentofu init <new-state-name> -- -migrate-state
```

{{< /tab >}}

{{< tab title="手动使用 OpenTofu CLI" >}}

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

如果后端初始化成功，你将收到以下响应。如果你输入 `yes`，它会将你的状态从旧位置复制到新位置。然后你就可以回到极狐GitLab CI/CD 中运行它了：

```plaintext
正在初始化后端...
后端配置已更改！

Terraform 检测到为后端指定的配置
已更改。Terraform 现在将检查后端中的现有状态。


正在获取状态锁。这可能需要一些时间...
是否要将现有状态复制到新后端？
  在将之前的 "http" 后端迁移到新配置的 "http" 后端时发现了先前存在的状态。
  在新配置的 "http" 后端中未发现现有状态。是否要将此状态复制到新的 "http"
  后端？输入 "yes" 复制，输入 "no" 以空状态开始。

  输入值：yes


已成功配置后端 "http"！除非后端配置发生变化，Terraform 将自动
使用此后端。

正在初始化提供商插件...

Terraform 已成功初始化！

你现在可以开始使用 Terraform。尝试运行 "terraform plan" 以查看
你的基础设施所需的任何更改。所有 Terraform 命令
现在应该可以正常工作。

如果你曾设置或更改 Terraform 的模块或后端配置，
请重新运行此命令以重新初始化你的工作目录。如果你忘记，其他
命令将检测到并提醒你这样做。
```

<a id="use-your-gitlab-backend-as-a-remote-data-source"></a>

## 将你的极狐GitLab 后端用作远程数据源

你可以将极狐GitLab 管理的 OpenTofu 状态后端用作 [OpenTofu 数据源](https://opentofu.org/docs/language/state/remote-state-data/)。

1. 在你的 `main.tf` 或其他相关文件中，声明这些变量。将值留空。

   ```hcl
   variable "example_remote_state_address" {
     type = string
     description = "极狐GitLab 远程状态文件地址"
   }

   variable "example_username" {
     type = string
     description = "用于查询远程状态的极狐GitLab 用户名"
   }

   variable "example_access_token" {
     type = string
     description = "用于查询远程状态的极狐GitLab 访问令牌"
   }
   ```

1. 要覆盖上一步中的值，创建一个名为 `example.auto.tfvars` 的文件。此文件**不应**被版本控制在你的项目仓库中。

   ```plaintext
   example_remote_state_address = "https://jihulab.com/api/v4/projects/<TARGET-PROJECT-ID>/terraform/state/<TARGET-STATE-NAME>"
   example_username = "<极狐GitLab 用户名>"
   example_access_token = "<极狐GitLab 个人访问令牌>"
   ```

1. 在 `.tf` 文件中，通过使用 [OpenTofu 输入变量](https://opentofu.org/docs/language/values/variables/)来定义数据源：

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

   - **address**：要作为数据源使用的远程状态后端 URL。
     例如 `https://jihulab.com/api/v4/projects/<TARGET-PROJECT-ID>/terraform/state/<TARGET-STATE-NAME>`。
   - **username**：用于对数据源进行身份验证的用户名。如果你使用[个人访问令牌](../../profile/personal_access_tokens.md)
     进行身份验证，则此值为你的极狐GitLab 用户名。如果你使用极狐GitLab CI/CD，则此值为 `'gitlab-ci-token'`。
   - **password**：用于对数据源进行身份验证的密码。如果你使用个人访问令牌进行身份验证，
     则此值为令牌值（令牌必须具有 **API** 范围）。
     如果你使用极狐GitLab CI/CD，则此值为 `${CI_JOB_TOKEN}` CI/CD 变量的内容。

数据源的输出现在可以在你的 Terraform 资源中通过
`data.terraform_remote_state.example.outputs.<OUTPUT-NAME>` 引用。

要读取目标项目中的 OpenTofu 状态，你需要具有开发者、维护者或所有者角色。

<a id="manage-opentofu-state-files"></a>

## 管理 OpenTofu 状态文件

要查看 OpenTofu 状态文件：

1. 在顶栏中，选择**搜索或跳转到**并找到你的项目。
1. 在左侧边栏中，选择**运维** > **Terraform 状态**。

存在一个史诗用于追踪此 UI 的改进。

<a id="manage-individual-opentofu-state-versions"></a>

### 管理单个 OpenTofu 状态版本

使用 GitLab CLI (`glab`) 或 API 管理单个状态版本。

前提条件：

- 要通过序列号获取状态版本，你必须具有开发者、维护者或所有者角色。
- 要通过序列号删除状态版本，你必须具有维护者或所有者角色。

要通过序列号获取状态版本：
{{< tabs >}}

{{< tab title="使用 GitLab CLI (glab)" >}}

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

要通过序列号删除状态版本：

{{< tabs >}}

{{< tab title="使用 GitLab CLI (glab)" >}}

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

### 删除状态文件

前提条件：

- 要删除状态文件，你必须具有维护者或所有者角色。

{{< tabs >}}

{{< tab title="使用 GitLab CLI (glab)" >}}

```shell
glab opentofu state delete <your_state_name>
```

{{< /tab >}}

{{< tab title="手动使用 curl" >}}

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/terraform/state/<your_state_name>"
```

你还可以使用 [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md) 和基本身份验证：

```shell
curl --request DELETE --user "gitlab-ci-token:$CI_JOB_TOKEN" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/terraform/state/<your_state_name>"
```

你还可以使用 [GraphQL API](../../../api/graphql/reference/_index.md#mutationterraformstatedelete)。

{{< /tab >}}

{{< tab title="使用 UI" >}}

要通过 UI 删除状态文件：

1. 在左侧边栏中，选择**运维** > **Terraform 状态**。
1. 在**操作**列中，选择**操作** ({{< icon name="ellipsis_v" >}}) > **删除状态文件和版本**。

{{< /tab >}}

{{< /tabs >}}

<a id="lock-and-unlock-a-state"></a>

### 锁定和解锁状态

前提条件：

- 要锁定状态文件，你必须具有维护者或所有者角色。

{{< tabs >}}

{{< tab title="使用 GitLab CLI (glab)" >}}

```shell
# 锁定状态文件
glab opentofu state lock <your_state_name>

# 解锁状态文件
glab opentofu state unlock <your_state_name>
```

{{< /tab >}}

{{< tab title="手动使用 curl" >}}

```shell
# 锁定状态文件
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/terraform/state/<your_state_name>/lock"

# 解锁状态文件
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/terraform/state/<your_state_name>/lock"
```

{{< /tab >}}

{{< tab title="使用 UI" >}}

要通过 UI 锁定或解锁状态文件：

1. 在左侧边栏中，选择**运维** > **Terraform 状态**。
1. 在**操作**列中，选择**操作** ({{< icon name="ellipsis_v" >}}) > **锁定** 进行锁定，或选择**操作** ({{< icon name="ellipsis_v" >}}) > **解锁**。

{{< /tab >}}

{{< /tabs >}}

<a id="download-a-state-file"></a>

### 下载状态文件

前提条件：

- 要下载状态文件，你必须具有开发者、维护者或所有者角色。

{{< tabs >}}

{{< tab title="使用 GitLab CLI (glab)" >}}

```shell
# 下载最新状态
glab opentofu state download <your_state_name>

# 下载特定版本（序列号）的状态
glab opentofu state download <your_state_name> <your_serial>
```

{{< /tab >}}

{{< tab title="手动使用 curl" >}}

```shell
# 下载最新状态
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/terraform/state/<your_state_name>"

# 下载特定版本（序列号）的状态
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/terraform/state/<your_state_name>/versions/<version_serial_number>"
```

{{< /tab >}}

{{< tab title="使用 UI" >}}

要通过 UI 下载最新状态文件：

1. 在左侧边栏中，选择**运维** > **Terraform 状态**。
1. 在**操作**列中，选择**操作** ({{< icon name="ellipsis_v" >}}) > **下载 JSON**。

无法通过 UI 下载特定版本的状态。

{{< /tab >}}

{{< /tabs >}}

<a id="protect-sensitive-data-in-terraform-state-files"></a>

#### 保护 Terraform 状态文件中的敏感数据

Terraform 状态文件可能包含敏感信息，例如密码、私钥、API 令牌和数据库连接字符串。
在极狐GitLab 中，任何具有开发者或更高角色的用户都可以下载并查看其所属项目的 Terraform 状态文件。

为减少敏感数据暴露：

- 极狐GitLab 旗舰版客户：创建一个自定义角色，复制开发者角色但排除 `admin_terraform_state` 权限。此操作允许团队成员为基础设施即代码 (IaC) 项目做出贡献，而无需访问包含敏感数据的 Terraform 状态文件。

  > [!note]
  > 自定义角色仅在极狐GitLab 旗舰版上可用。专业版或更低层级的客户无法使用此缓解选项，应专注于前述其他策略。

- OpenTofu 用户：开启状态和计划加密以保护静态敏感数据。极狐GitLab 通过 [OpenTofu CI/CD 组件](https://jihulab.com/components/opentofu) 原生支持此功能，该组件提供加密配置。即使未经授权的用户访问状态文件，加密内容仍然受到保护。

- 所有用户：
  - 将项目成员限制为需要访问基础设施状态的用户。
  - 使用单独的项目存储状态，仅将必要的用户添加为成员。
  - 使用 HashiCorp Vault 或 AWS Secrets Manager 等外部密钥管理解决方案来动态引用密钥，而不是将它们存储在 Terraform 配置中。
  - 在变量定义中使用 Terraform [`sensitive`](https://developer.hashicorp.com/terraform/language/values/variables#suppressing-values-in-cli-output) 参数标记敏感值。此操作可防止值出现在 CLI 输出和计划文件中，尽管它们仍保留在状态文件中。
  - 定期审计具有开发者角色的项目成员，并查看状态文件内容中是否有意外暴露的密钥。

<a id="related-topics"></a>

## 相关主题

- [极狐GitLab 管理的 Terraform 状态故障排查](troubleshooting.md)
- [示例项目：在自定义 VPC 中部署 AWS EC2 实例的 Terraform](https://jihulab.com/gitlab-cn/configure/examples/gitlab-terraform-aws)