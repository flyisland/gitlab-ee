---
stage: none
group: Tutorials
info: For assistance with this tutorial, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
title: 教程：自动化 Runner 创建和注册
---

本教程介绍了如何自动化 Runner 的创建和注册。

要自动化 Runner 的创建和注册：

1. [创建个人访问令牌](#create-a-personal-access-token)。
1. [创建 Runner 配置](#create-a-runner-configuration)。
1. [自动化极狐GitLab Runner 安装和注册](#automate-runner-installation-and-registration)。
1. [查看使用相同配置的 Runner](#view-runners-with-the-same-configuration)。

> [!note]
> 本教程中的说明描述了通过 Runner 认证令牌进行 Runner 创建和注册的方式，该方式已取代使用注册令牌的旧有注册方式。更多信息，请参见
> [新的 Runner 注册工作流程](../../ci/runners/new_creation_workflow.md#the-new-runner-registration-workflow)。

<a id="before-you-begin"></a>

## 准备工作

- 必须在你的极狐GitLab 实例上安装极狐GitLab Runner。
- 要创建实例 Runner，你必须是管理员。
- 要创建群组 Runner，你必须是管理员或拥有该群组的 所有者 角色。
- 要创建项目 Runner，你必须是管理员或拥有该项目的 维护者 角色。

<a id="create-an-access-token"></a>

## 创建访问令牌

创建一个访问令牌，以便你可以使用 REST API 来创建 Runner。

你可以创建以下令牌：

- 用于共享、群组和项目 Runner 的个人访问令牌。
- 用于群组和项目 Runner 的群组或项目访问令牌。

访问令牌在极狐GitLab UI 中仅可见一次。离开页面后，你将无法再访问该令牌。你应该使用密钥管理解决方案来存储令牌，例如 HashiCorp Vault 或 Keeper Secrets Manager Terraform 插件。

<a id="create-a-personal-access-token"></a>

### 创建个人访问令牌

{{< history >}}

- 在极狐GitLab 17.6 中，通过名为 `buffered_token_expiration_limit` 的[功能标志](../../administration/feature_flags/_index.md)将最大允许生命周期限制更改为 400 天。默认禁用。

{{< /history >}}

> [!flag]
> 扩展的最大允许生命周期限制的可用性由功能标志控制。
> 更多信息，请查看历史记录。

1. 在右上角，选择你的头像。
1. 选择 **编辑资料**。
1. 在左侧边栏，选择 **访问** > **个人访问令牌**。
1. 选择 **添加新令牌**。
1. 输入令牌的名称和过期日期。
   - 令牌在该日期的 UTC 时间午夜过期。例如，过期日期为 2024-01-01 的令牌将于 2024-01-01 的 UTC 时间 00:00:00 过期。
   - 如果你不输入过期日期，过期日期将自动设置为当前日期后的 365 天。
   - 默认情况下，此日期最多为当前日期后的 365 天。在极狐GitLab 17.6 或更高版本中，你可以[将此限制延长至 400 天](https://gitlab.com/gitlab-org/gitlab/-/issues/461901)。
1. 在 **选择范围** 部分，选中 **创建 Runner** 复选框。
1. 选择 **创建个人访问令牌**。

<a id="create-a-project-or-group-access-token"></a>

### 创建项目或群组访问令牌

{{< history >}}

- 在极狐GitLab 17.6 中，通过名为 `buffered_token_expiration_limit` 的[功能标志](../../administration/feature_flags/_index.md)将最大允许生命周期限制更改为 400 天。默认禁用。

{{< /history >}}

> [!flag]
> 扩展的最大允许生命周期限制的可用性由功能标志控制。
> 更多信息，请查看历史记录。

项目访问令牌仅允许访问一个项目，而群组访问令牌允许访问该群组中的所有项目。

> [!warning]
> 项目访问令牌被视为[内部用户](../../administration/internal_users.md)。
> 如果内部用户创建了项目访问令牌，该令牌能够访问所有可见性级别设置为[内部](../../user/public_access.md)的项目。

要创建项目访问令牌：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏，选择 **设置** > **访问令牌**。
1. 选择 **添加新令牌**
1. 输入名称。令牌名称对拥有查看该群组或项目权限的任何用户都可见。
1. 输入令牌的过期日期。
   - 令牌在该日期的 UTC 时间午夜过期。例如，过期日期为 2024-01-01 的令牌将于 2024-01-01 的 UTC 时间 00:00:00 过期。
   - 如果你不输入过期日期，过期日期将自动设置为当前日期后的 365 天。
   - 默认情况下，此日期最多为当前日期后的 365 天。在极狐GitLab 17.6 或更高版本中，你可以[将此限制延长至 400 天](https://gitlab.com/gitlab-org/gitlab/-/issues/461901)。
   - 实例范围的[最大生命周期](../../administration/settings/account_and_limit_settings.md#limit-the-lifetime-of-access-tokens)设置可能会限制极狐GitLab 私有化部署实例上允许的最大生命周期。
1. 从 **选择一个角色** 下拉列表中：
   - 对于项目访问令牌，选择 **维护者**。
   - 对于群组访问令牌，选择 **所有者**。
1. 在 **选择范围** 部分，选中 **创建 Runner** 复选框。
1. 选择 **创建项目访问令牌**。

<a id="create-a-runner-configuration"></a>

## 创建 Runner 配置

Runner 配置允许你根据需求来配置 Runner。

创建 Runner 配置后，你会收到一个用于注册 Runner 的 Runner 认证令牌。当多个 Runner 使用相同的 Runner 认证令牌进行注册时，它们可以关联到同一个配置。Runner 配置存储在 `config.toml` 文件中。

要创建 Runner 配置，你可以使用：

- 极狐GitLab REST API。
- `gitlab_user_runner` Terraform 资源。

<a id="with-the-gitlab-rest-api"></a>

### 通过 极狐GitLab REST API

在开始之前，你需要：

- 你的极狐GitLab 实例的 URL。例如，如果你的项目位于 `gitlab.example.com/yourname/yourproject`，那么你的极狐GitLab 实例 URL 为 `https://gitlab.example.com`。
- 对于群组或项目 Runner，需要知道群组或项目的 ID 号。该 ID 号显示在项目或群组概览页面中，位于项目或群组名称下方。

使用访问令牌调用 [`POST /user/runners`](../../api/users.md#create-a-runner-linked-to-a-user) REST 端点来创建 Runner：

1. 使用 `curl` 调用端点以创建 Runner：

   {{< tabs >}}

   {{< tab title="Project" >}}

   ```shell
   curl --silent --request POST --url "https://gitlab.example.com/api/v4/user/runners"
     --data "runner_type=project_type"
     --data "project_id=<project_id>"
     --data "description=<your_runner_description>"
     --data "tag_list=<your_comma_separated_job_tags>"
     --header "PRIVATE-TOKEN: <project_access_token>"
   ```

   {{< /tab >}}

   {{< tab title="Group" >}}

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
1. 将返回的 `token` 值保存在安全位置或你的密钥管理解决方案中。`token` 值仅在 API 响应中返回一次。

<a id="with-the-gitlab_user_runner-terraform-resource"></a>

### 通过 `gitlab_user_runner` Terraform 资源

要使用 Terraform 创建 Runner 配置，请使用来自[极狐GitLab Terraform 提供程序](https://gitlab.com/gitlab-org/terraform-provider-gitlab)的 [`gitlab_user_runner` Terraform 资源](https://gitlab.com/gitlab-org/terraform-provider-gitlab/-/blob/main/docs/resources/user_runner.md?ref_type=heads)。

以下是一个配置块示例：

```terraform
resource "gitlab_user_runner" "example_runner" {
  runner_type = "instance_type"
  description = "my-runner"
  tag_list = ["shell", "docker"]
}
```

<a id="automate-runner-installation-and-registration"></a>

## 自动化 Runner 安装和注册

如果你将 Runner 托管在公有云中的虚拟机实例上，则可以自动化 Runner 的安装和注册。

在创建 Runner 及其配置后，你可以使用相同的 Runner 认证令牌来注册具有相同配置的多个 Runner。例如，你可以将具有相同执行器类型和作业标签的多个实例 Runner 部署到目标计算主机上。使用相同 Runner 认证令牌注册的每个 Runner 都有一个唯一的 `system_id`，此 ID 由极狐GitLab Runner 随机生成并存储在你的本地文件系统中。

<a id="view-runners-with-the-same-configuration"></a>

## 查看使用相同配置的 Runner

现在你已经自动化了 Runner 的创建和注册，你可以在极狐GitLab UI 中查看使用相同配置的 Runner。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **CI/CD** > **Runners**。
1. 在搜索框中，输入 Runner 的描述信息或搜索 Runner 列表。
1. 要查看使用相同配置的 Runner，请在 **详情** 选项卡中，**Runner** 旁边，选择 **显示详情**。