---
stage: Tutorials
group: Tutorials
info: For assistance with this tutorial, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
title: '教程：自动创建和注册 Runner'
---

本教程介绍如何自动创建和注册 Runner。

要自动创建和注册 Runner：

1. [创建个人访问令牌](#create-a-personal-access-token)。
1. [创建 Runner 配置](#create-a-runner-configuration)。
1. [自动安装和注册极狐GitLab Runner](#automate-runner-installation-and-registration)。
1. [查看使用相同配置的 Runner](#view-runners-with-the-same-configuration)。

> [!note]
> 本教程中的说明介绍使用 Runner 认证令牌创建和注册 Runner，这种方式已取代使用注册令牌的已弃用注册方法。更多信息，请参见
> [新的 Runner 注册工作流](../../ci/runners/new_creation_workflow.md#the-new-runner-registration-workflow)。

<a id="before-you-begin"></a>

## 开始之前

- 您的极狐GitLab 实例上必须已安装极狐GitLab Runner。
- 要创建实例 Runner，您必须是管理员。
- 要创建群组 Runner，您必须是管理员，或者拥有该群组的所有者角色。
- 要创建项目 Runner，您必须是管理员，或者拥有该项目的维护者角色。

<a id="create-an-access-token"></a>

## 创建访问令牌

创建访问令牌，以便使用 REST API 创建 Runner。

您可以创建：

- 用于共享、群组和项目 Runner 的个人访问令牌。
- 用于群组和项目 Runner 的群组或项目访问令牌。

访问令牌在极狐GitLab UI 中仅显示一次。离开该页面后，您将无法再访问该令牌。您应使用密钥管理解决方案（例如 HashiCorp Vault 或 Keeper 密钥管理器 Terraform 插件）来存储令牌。

<a id="create-a-personal-access-token"></a>

### 创建个人访问令牌

> [!flag]
> 延长后的最大允许有效期上限的可用性受功能标志控制。

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **个人访问令牌**。
1. 选择 **添加新令牌**。
1. 输入令牌的名称和到期日期。
   - 令牌将在该日期的 UTC 午夜到期。到期日期为 2024-01-01 的令牌将在 2024-01-01 00:00:00 UTC 到期。
   - 如果您未输入到期日期，到期日期将自动设置为当前日期之后 365 天。
   - 默认情况下，该日期最多可比当前日期晚 365 天。在极狐GitLab 17.6 或更高版本中，您可以[将该上限延长至 400 天](https://gitlab.com/gitlab-org/gitlab/-/issues/461901)。
1. 在 **选择范围** 部分，选中 **create_runner** 复选框。
1. 选择 **创建个人访问令牌**。

<a id="create-a-project-or-group-access-token"></a>

### 创建项目或群组访问令牌

> [!flag]
> 延长后的最大允许有效期上限的可用性受功能标志控制。

项目访问令牌仅可访问一个项目，而群组访问令牌可访问该群组中的所有项目。

> [!warning]
> 项目访问令牌被视为[内部用户](../../administration/internal_users.md)。
> 如果内部用户创建了项目访问令牌，该令牌可以访问所有可见性级别设置为 [内部](../../user/public_access.md)的项目。

要创建项目访问令牌：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目或群组。
1. 在左侧边栏中，选择 **设置** > **访问令牌**。
1. 选择 **添加新令牌**
1. 输入名称。任何有权查看该群组或项目的用户都可以看到该令牌名称。
1. 输入令牌的到期日期。
   - 令牌将在该日期的 UTC 午夜到期。到期日期为 2024-01-01 的令牌将在 2024-01-01 00:00:00 UTC 到期。
   - 如果您未输入到期日期，到期日期将自动设置为当前日期之后 365 天。
   - 默认情况下，该日期最多可比当前日期晚 365 天。
     在极狐GitLab 17.6 或更高版本中，您可以[将该上限延长至 400 天](https://gitlab.com/gitlab-org/gitlab/-/issues/461901)。
   - 实例范围的[最大有效期](../../administration/settings/account_and_limit_settings.md#limit-the-lifetime-of-access-tokens)
     设置可以限制极狐GitLab 私有化部署实例上的最大允许有效期。
1. 从 **选择角色** 下拉列表中：
   - 对于项目访问令牌，选择 **维护者**。
   - 对于群组访问令牌，选择 **所有者**。
1. 在 **选择范围** 部分，选中 **create_runner** 复选框。
1. 选择 **创建项目访问令牌**。

<a id="create-a-runner-configuration"></a>

## 创建 Runner 配置

Runner 配置是您根据自己的需求配置 Runner 的地方。

创建 Runner 配置后，您会收到一个 Runner 认证令牌，用于注册 Runner。当这些 Runner 使用相同的 Runner 认证令牌注册时，一个或多个 Runner 可以关联到同一配置。Runner 配置存储在 `config.toml` 文件中。

要创建 Runner 配置，您可以使用：

- 极狐GitLab REST API。
- `gitlab_user_runner` Terraform 资源。

<a id="with-the-gitlab-rest-api"></a>

### 使用极狐GitLab REST API

开始之前，您需要：

- 极狐GitLab 实例的 URL。例如，如果您的项目托管在
  `gitlab.example.com/yourname/yourproject`，则您的极狐GitLab 实例 URL 为
  `https://gitlab.example.com`。
- 对于群组或项目 Runner，需要群组或项目的 ID 号。该 ID 号
  显示在项目或群组概览页面的项目或群组名称下方。

在 [`POST /user/runners`](../../api/users.md#create-a-runner-linked-to-a-user) REST 端点中使用该访问令牌来创建 Runner：

1. 使用 `curl` 调用该端点来创建 Runner：

   {{< tabs >}}

   {{< tab title="项目" >}}

   ```shell
   curl --silent --request POST --url "https://gitlab.example.com/api/v4/user/runners"
     --data "runner_type=project_type"
     --data "project_id=<project_id>"
     --data "description=<your_runner_description>"
     --data "tag_list=<your_comma_separated_job_tags>"
     --header "PRIVATE-TOKEN: <project_access_token>"
   ```

   {{< /tab >}}

   {{< tab title="群组" >}}

   ```shell
   curl --silent --request POST --url "https://gitlab.example.com/api/v4/user/runners"
     --data "runner_type=group_type"
     --data "group_id=<group_id>"
     --data "description=<your_runner_description>"
     --data "tag_list=<your_comma_separated_job_tags>"
     --header "PRIVATE-TOKEN: <group_access_token>"
   ```

   {{< /tab >}}

   {{< tab title="Shared" >}}

   ```shell
   curl --silent --request POST --url "https://gitlab.example.com/api/v4/user/runners"
     --data "runner_type=instance_type"
     --data "description=<your_runner_description>"
     --data "tag_list=<your_comma_separated_job_tags>"
     --header "PRIVATE-TOKEN: <personal_access_token>"
   ```

   {{< /tab >}}

   {{< /tabs >}}
1. 将返回的 `token` 值保存在安全位置或您的密钥管理
   解决方案中。`token` 值在 API 响应中仅返回一次。

<a id="with-the-gitlab_user_runner-terraform-resource"></a>

### 使用 `gitlab_user_runner` Terraform 资源

要使用 Terraform 创建 Runner 配置，请使用
[GitLab Terraform provider](https://gitlab.com/gitlab-org/terraform-provider-gitlab)
中的
[`gitlab_user_runner` Terraform 资源](https://gitlab.com/gitlab-org/terraform-provider-gitlab/-/blob/main/docs/resources/user_runner.md?ref_type=heads)。

以下是一个示例配置块：

```terraform
resource "gitlab_user_runner" "example_runner" {
  runner_type = "instance_type"
  description = "my-runner"
  tag_list = ["shell", "docker"]
}
```

<a id="automate-runner-installation-and-registration"></a>

## 自动安装和注册 Runner

如果您将 Runner 托管在公有云中的虚拟机实例上，则可以自动完成 Runner 的安装和注册。

创建 Runner 及其配置后，您可以使用相同的 Runner 认证令牌，将多个 Runner 注册到同一配置。例如，您可以将多个具有相同执行器类型和作业标签的实例 Runner 部署到目标计算主机。使用相同 Runner
认证令牌注册的每个 Runner 都有唯一的 `system_id`，该 ID 由极狐GitLab Runner
随机生成并存储在您的本地文件系统中。

以下是一个自动化工作流示例，您可以用它将 Runner 注册并部署到 Google Compute Engine：

1. 使用 [Terraform 基础设施即代码](../../user/infrastructure/iac/_index.md)
   将 Runner 应用程序安装到托管在 Google Cloud
   Platform (GCP) 上的虚拟机。
1. 在 [GCP Terraform provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)中，
   使用 `metadata` 键将 Runner 认证令牌添加到 GCP 虚拟机上的 Runner
   配置文件中。
1. 要将 Runner 注册到目标极狐GitLab 实例，请使用由 GCP Terraform provider
   填充的 `cloud-init` 脚本。示例如下：

   ```shell
   #!/bin/bash
   apt update
   curl --location "https://packages.gitlab.com/install/repositories/runner/
   gitlab-runner/script.deb.sh" | bash
   GL_NAME=$(curl 169.254.169.254/computeMetadata/v1/instance/name
   --header "Metadata-Flavor:Google")
   GL_EXECUTOR=$(curl 169.254.169.254/computeMetadata/v1/instance/attributes/
   gl_executor --header "Metadata-Flavor:Google")
   apt update
   apt install -y gitlab-runner
   gitlab-runner register --non-interactive --name="$GL_NAME" --url="https://gitlab.com"
     --token="$RUNNER_TOKEN" --request-concurrency="12" --executor="$GL_EXECUTOR"
     --docker-image="alpine:latest"
   systemctl restart gitlab-runner
   ```

<a id="view-runners-with-the-same-configuration"></a>

## 查看使用相同配置的 Runner

现在您已自动完成 Runner 的创建和注册，您可以在极狐GitLab UI 中查看使用相同配置的 Runner。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 在搜索框中，输入 Runner 描述或搜索 Runner 列表。
1. 要查看使用相同配置的 Runner，请在 **详情** 选项卡中，
   在 **Runners** 旁边选择 **显示详情**。
