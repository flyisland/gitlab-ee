---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在 JihuLab.com 上安装 GitLab for Jira Cloud 应用，以实时将群组和项目与 Jira Cloud 同步。
title: GitLab for Jira Cloud 应用
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> 管理员文档请参见 [GitLab for Jira Cloud 应用管理](../../administration/settings/jira_cloud_app.md)。

借助 [GitLab for Jira Cloud](https://marketplace.atlassian.com/apps/1221011/gitlab-com-for-jira-cloud?tab=overview&hosting=cloud) 应用，您可以连接极狐GitLab 和 Jira Cloud，以实时同步开发信息。您可以在 [Jira 开发面板](development_panel.md)中查看这些信息。

您可以使用 GitLab for Jira Cloud 应用来关联顶级群组或子群组。无法直接关联项目或个人命名空间。

要在 JihuLab.com 上设置 GitLab for Jira Cloud 应用，请[安装 GitLab for Jira Cloud 应用](#install-the-gitlab-for-jira-cloud-app)。

设置应用后，您可以使用由 Atlassian 开发和维护的[项目工具链](https://support.atlassian.com/jira-software-cloud/docs/what-is-the-connections-feature/)来[将极狐GitLab 代码仓库关联到 Jira 项目](https://support.atlassian.com/jira-software-cloud/docs/link-repositories-to-a-project/#Link-repositories-using-the-toolchain-feature)。项目工具链不会影响极狐GitLab 与 Jira Cloud 之间同步开发信息的方式。

对于 Jira Data Center 或 Jira Server，请使用由 Atlassian 开发和维护的 [Jira DVCS 连接器](dvcs/_index.md)。

<a id="gitlab-data-synced-to-jira"></a>

## 同步到 Jira 的极狐GitLab 数据

关联群组后，当您[提及 Jira 议题 ID](development_panel.md#information-displayed-in-the-development-panel) 时，该群组中所有项目的以下极狐GitLab 数据会同步到 Jira：

- 现有项目数据（关联群组之前）：
  - 最近 400 个合并请求
  - 最近 400 个分支以及每个分支上的最后一次提交
- 新项目数据（关联群组之后）：
  - 合并请求
    - 合并请求作者
  - 分支
  - 提交
    - 提交作者
  - 流水线
  - 部署
  - 功能标志

<a id="install-the-gitlab-for-jira-cloud-app"></a>

## 安装 GitLab for Jira Cloud 应用

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

先决条件：

- 您的网络必须允许极狐GitLab 与 Jira 之间的入站和出站连接。
- 您必须满足特定的 [Jira 用户要求](../../administration/settings/jira_cloud_app.md#jira-user-requirements)。

要安装 GitLab for Jira Cloud 应用：

1. 在 Jira 中，在顶部栏中选择**应用** > **探索更多应用**，然后搜索 `GitLab for Jira Cloud`。
1. 选择 **GitLab for Jira Cloud**，然后选择**立即获取**。

或者，[直接从 Atlassian Marketplace 获取该应用](https://marketplace.atlassian.com/apps/1221011/gitlab-com-for-jira-cloud?tab=overview&hosting=cloud)。

现在您可以[配置 GitLab for Jira Cloud 应用](#configure-the-gitlab-for-jira-cloud-app)。

较旧的 [Universal Plugin Manager 界面](https://community.atlassian.com/forums/Community-Announcements-articles/Cloud-admins-we-re-making-app-management-easier/ba-p/2806285)，在较新的 Jira Cloud 实例上可能不可用。
以下说明涵盖新旧两种应用管理界面。

<a id="configure-the-gitlab-for-jira-cloud-app"></a>

## 配置 GitLab for Jira Cloud 应用

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

先决条件：

- 您必须拥有极狐GitLab 群组的维护者或所有者角色。
- 您必须满足特定的 [Jira 用户要求](../../administration/settings/jira_cloud_app.md#jira-user-requirements)。

您可以通过将 GitLab for Jira Cloud 应用关联到一个或多个极狐GitLab 群组，将数据从极狐GitLab 同步到 Jira。
要配置 GitLab for Jira Cloud 应用：

<!-- markdownlint-disable MD044 -->

1. 在 Jira 中，选择**应用**旁边的水平省略号（{{< icon name="ellipsis_h" >}}），然后选择**管理您的应用**。
1. 使用以下方法之一转到该应用：

   - 对于使用集中式应用管理的实例：

     1. 如果您看到“应用管理已移至“管理””，请选择**带我去那里**。否则，请按照下面的**对于使用旧版应用管理的实例**说明操作。
     1. 在**已安装的应用**选项卡中，找到 **GitLab for Jira**。根据您安装应用的方式，应用名称为：
        - 如果您[从 Atlassian Marketplace 安装了该应用](https://marketplace.atlassian.com/apps/1221011/gitlab-com-for-jira-cloud?tab=overview&hosting=cloud)，则为 **GitLab for Jira (gitlab.com)**。
        - 如果您[手动安装了该应用](../../administration/settings/jira_cloud_app.md#install-the-gitlab-for-jira-cloud-app-manually)，则为 **GitLab for Jira (`<gitlab.example.com>`)**。
     1. 选择水平省略号（{{< icon name="ellipsis_h" >}}），然后选择**开始使用**以配置该集成。

   - 对于使用旧版应用管理的实例：

     1. 展开 **GitLab for Jira**。根据您安装应用的方式，应用名称为：
        - 如果您[从 Atlassian Marketplace 安装了该应用](https://marketplace.atlassian.com/apps/1221011/gitlab-com-for-jira-cloud?tab=overview&hosting=cloud)，则为 **GitLab for Jira (gitlab.com)**。
        - 如果您[手动安装了该应用](../../administration/settings/jira_cloud_app.md#install-the-gitlab-for-jira-cloud-app-manually)，则为 **GitLab for Jira (`<gitlab.example.com>`)**。
     1. 选择**开始使用**以配置该集成。

1. 可选。要将极狐GitLab 私有化部署与 Jira 关联，请选择**更改极狐GitLab 版本**。
   1. 选中所有复选框，然后选择**下一步**。
   1. 输入您的**极狐GitLab 实例 URL**，然后选择**保存**。
1. 选择**登录到极狐GitLab**。

   > [!note]
   > [企业用户](../../user/enterprise_user/_index.md)如果[为其群组禁用了密码认证](../../user/group/saml_sso/_index.md#disable-password-and-passkey-authentication-for-enterprise-users)，
   > 必须先使用其群组的单点登录 URL 登录极狐GitLab。

   极狐GitLab 要求您登录才能关联群组，但不会将配置绑定到
   特定用户。极狐GitLab 实例会从 Jira 接收一个令牌，用于更新 Jira 中的信息。
   有关更多信息，请参见[极狐GitLab 对 Jira 的访问](#gitlab-access-to-jira)。
1. 选择**授权**。现在会显示群组列表。
1. 选择**关联群组**。
1. 要关联到某个群组，请选择**关联**。

<!-- markdownlint-enable MD044 -->

关联到极狐GitLab 群组后：

- 数据会同步到 Jira，适用于该群组中的所有项目。初始数据同步以每分钟 20 个项目的批次进行。
  对于项目较多的群组，部分项目的数据同步会延迟。
- 该群组及其所有子群组或项目会自动开启 GitLab for Jira Cloud 应用集成。
  借助该集成，您可以[配置 Jira Service Management](#configure-jira-service-management)。

<a id="configure-jira-service-management"></a>

## 配置 Jira Service Management

> [!note]
> 此功能是作为社区贡献添加的，仅由 GitLab 社区开发和维护。

先决条件：

- 必须已[安装](#install-the-gitlab-for-jira-cloud-app) GitLab for Jira Cloud 应用。
- 在 GitLab for Jira Cloud 应用配置中有一个[要关联的极狐GitLab 群组](#configure-the-gitlab-for-jira-cloud-app)。

您可以将极狐GitLab 连接到您的 IT 服务项目，以跟踪您的部署。

配置在极狐GitLab 中的 GitLab for Jira Cloud 应用集成内进行。在[关联极狐GitLab 群组](#configure-the-gitlab-for-jira-cloud-app)后，会为极狐GitLab 中的群组、其子群组和项目开启该集成。

GitLab for Jira Cloud 应用集成通过群组关联自动开启和关闭，
而不是通过极狐GitLab 集成表单或 API。

在 Jira Service Management 中：

1. 在您的服务项目中，转到**项目设置** > **变更管理**。
1. 选择**连接流水线** > **GitLab**，然后在设置流程末尾复制**服务 ID**。

在极狐GitLab 中：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **GitLab for Jira Cloud 应用**。如果该集成已关闭，请先[关联一个极狐GitLab 群组](#configure-the-gitlab-for-jira-cloud-app)，
   这会为该群组、其子群组和项目开启 GitLab for Jira Cloud 应用集成。
1. 在**服务 ID** 文本框中，输入您要映射到此项目的服务 ID。要使用多个服务 ID，
   请在每个服务 ID 之间添加逗号。

您最多可以映射 100 个服务。

有关 Jira 中部署跟踪的更多信息，请参见[设置部署跟踪](https://support.atlassian.com/jira-service-management-cloud/docs/set-up-deployment-tracking/)。

<a id="set-up-deployment-gating-with-gitlab"></a>

### 使用极狐GitLab 设置部署门禁

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

> [!note]
> 此功能是作为社区贡献添加的，仅由 GitLab 社区开发和维护。

您可以设置部署门禁，将变更请求从极狐GitLab 发送到 Jira Service Management 进行审批。
借助部署门禁，任何对您所选环境的极狐GitLab 部署都会自动发送
到 Jira Service Management，并且只有在获得批准后才会部署。

<a id="create-the-service-account-token"></a>

#### 创建服务账号令牌

要在极狐GitLab 中创建服务账号令牌，您必须先创建个人访问令牌。此令牌用于对服务账号令牌进行认证，该服务账号令牌用于在 Jira Service Management 中管理极狐GitLab 部署。

要创建服务账号令牌：

1. [创建服务账号用户](../../api/service_accounts.md#create-an-instance-service-account)。
1. 使用您的个人访问令牌[将服务账号添加到群组或项目](../../api/group_members.md#add-a-group-member)。
1. [将服务账号添加到受保护环境](../../ci/environments/protected_environments.md#protecting-environments)。
1. 使用您的个人访问令牌[生成服务账号令牌](../../api/service_accounts.md#create-a-personal-access-token-for-a-group-service-account)。
1. 复制服务账号令牌值。

<a id="enable-deployment-gating"></a>

#### 启用部署门禁

要开启部署门禁：

- 在极狐GitLab 中：

  1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
  1. 选择**设置** > **集成**。
  1. 选择 **GitLab for Jira Cloud 应用**。
  1. 在**部署门禁**下，选中**启用部署门禁**复选框。
  1. 在**环境层级**文本框中，输入您要为其开启部署门禁的环境名称。
     您可以输入多个环境名称，以逗号分隔（例如 `production, staging, testing, development`）。
     仅使用小写字母。
  1. 选择**保存更改**。
- 在 Jira Service Management 中：

  1. [设置部署门禁](https://support.atlassian.com/jira-service-management-cloud/docs/set-up-deployment-gating/)。
  1. 在**服务账号令牌**文本框中，[粘贴您从极狐GitLab 复制的服务账号令牌值](#create-the-service-account-token)。

<a id="add-the-service-account-to-protected-environments"></a>

#### 将服务账号添加到受保护环境

要将服务账号添加到极狐GitLab 中的受保护环境：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**受保护环境**并选择**保护环境**。
1. 从**选择环境**下拉列表中，选择要保护的环境（例如 **staging**）。
1. 从**允许部署**下拉列表中，选择可以部署到此环境的对象（例如**开发者 + 维护者**）。
1. 从**审批人**下拉列表中，选择[您创建的服务账号](#create-the-service-account-token)。
1. 选择**保护**。

<a id="example-api-requests"></a>

#### API 请求示例

- 创建服务账号用户：

  ```shell
  curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" --data "name=<name_of_your_choice>&username=<username_of_your_choice>"  "<https://jihulab.com/api/v4/groups/<group_id>/service_accounts"
  ```

- 使用您的个人访问令牌将服务账号添加到群组或项目：

  ```shell
  curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
       --data "user_id=<service_account_id>&access_level=30" "https://jihulab.com/api/v4/groups/<group_id>/members"
  curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
       --data "user_id=<service_account_id>&access_level=30" "https://jihulab.com/api/v4/projects/<project_id>/members"
  ```

- 使用您的个人访问令牌生成服务账号令牌：

  ```shell
  curl --request POST --header "PRIVATE-TOKEN: <your_access_token>"
  "https://jihulab.com/api/v4/groups/<group_id>/service_accounts/<service_account_id>/personal_access_tokens" --data "scopes[]=api,read_user,read_repository" --data "name=service_accounts_token"
  ```

<a id="update-the-gitlab-for-jira-cloud-app"></a>

## 更新 GitLab for Jira Cloud 应用

该应用的大多数更新都是自动的。有关更多信息，请参见
[Atlassian 文档](https://developer.atlassian.com/platform/marketplace/upgrading-and-versioning-cloud-apps/)。

如果该应用需要额外权限，[您必须在 Jira 中手动批准更新](https://developer.atlassian.com/platform/marketplace/upgrading-and-versioning-cloud-apps/#changes-that-require-manual-customer-approval)。

<a id="migration-from-atlassian-connect-to-forge"></a>

## 从 Atlassian Connect 迁移到 Forge

GitLab for Jira Cloud 应用已从
[Atlassian Connect](https://developer.atlassian.com/cloud/jira/platform/getting-started-with-connect/)
迁移到 [Atlassian Forge](https://developer.atlassian.com/platform/forge/)。
此变更遵循 Atlassian 的
[Connect 应用终止支持公告](https://www.atlassian.com/blog/developer/announcing-connect-end-of-support-timeline-and-next-steps)。

所有现有功能继续正常工作，包括：

- 将分支、提交、合并请求、流水线、部署和
  功能标志同步到 Jira 开发面板。
- 从 Jira 议题创建极狐GitLab 分支。
- 使用智能提交进行时间跟踪和议题状态转换。
- 同时支持 JihuLab.com 和极狐GitLab 私有化部署实例。

如果您是从
[Atlassian Marketplace](https://marketplace.atlassian.com/apps/1221011/gitlab-com-for-jira-cloud) 安装的 GitLab for Jira Cloud 应用：

- Forge 版本会作为现有应用的
  [重大升级](https://developer.atlassian.com/platform/marketplace/upgrading-and-versioning-cloud-apps/#changes-that-require-manual-customer-approval)出现。
- Jira 管理员必须批准该升级。
- 所有之前同步的开发数据都会自动保留。
  Forge 应用使用相同的应用标识符，因此您无需迁移任何数据。
- 您无需更改极狐GitLab 配置。

如果您之前使用基于 Connect 的**应用描述符 URL** 工作流手动安装了 GitLab for Jira Cloud 应用，则必须迁移到基于 Forge 的方法。
Atlassian [已于 2026-03-31 禁用基于 Connect 的私有安装](https://www.atlassian.com/blog/developer/announcing-connect-end-of-support-timeline-and-next-steps)，
因此之前的工作流不再可用。

要迁移并保留现有数据：

1. [将您的 Connect 应用描述符转换为 Forge 清单](https://developer.atlassian.com/platform/adopting-forge-from-connect/how-to-adopt/#part-2--convert-your-descriptor-to-a-manifest)。
1. 使用转换后的清单[注册新的 Forge 应用](https://developer.atlassian.com/platform/adopting-forge-from-connect/how-to-adopt/#part-3--register-and-deploy-your-app-to-your-forge-development-site)。

这些步骤可确保新的 Forge 应用保留原有的 `connect.app.key`。Jira 使用此键以及新的 Forge 应用 ID 来识别这两个安装是关联的，因此您之前同步的开发数据会保持完整。

转换后，请按照[基于 Forge 的手动安装说明](../../administration/settings/jira_cloud_app.md#install-the-gitlab-for-jira-cloud-app-manually)在您自己的 Atlassian 开发者账号下发布
[GitLab for Jira Cloud Forge 应用](https://gitlab.com/gitlab-org/gitlab-jira-forge)的私有副本。

有关从 Connect 过渡到 Forge 的更多信息，请参见
[Atlassian 关于如何采用 Forge 的指南](https://developer.atlassian.com/platform/adopting-forge-from-connect/how-to-adopt/)。

<a id="security-considerations"></a>

## 安全注意事项

GitLab for Jira Cloud 应用连接极狐GitLab 和 Jira。两个应用之间必须共享数据，并且必须在两个方向上授予访问权限。

<a id="gitlab-access-to-jira"></a>

### 极狐GitLab 对 Jira 的访问

当您[配置 GitLab for Jira Cloud 应用](#configure-the-gitlab-for-jira-cloud-app)时，极狐GitLab 会从 Jira 接收一个共享密钥令牌。
该令牌授予极狐GitLab 对 Jira 项目的 `READ`、`WRITE` 和 `DELETE` [应用作用域](https://developer.atlassian.com/cloud/jira/software/scopes-for-connect-apps/#scopes-for-atlassian-connect-apps)。这些作用域是更新 Jira 项目开发面板中信息所必需的。该令牌不会授予极狐GitLab 访问除安装该应用所在的 Jira 项目之外的任何其他 Atlassian 产品的权限。

该令牌使用 `AES256-GCM` 加密并存储在极狐GitLab 上。
当从您的 Jira 项目卸载 GitLab for Jira Cloud 应用时，极狐GitLab 会删除该令牌。

<a id="jira-access-to-gitlab"></a>

### Jira 对极狐GitLab 的访问

Jira 不会获得对极狐GitLab 的任何访问权限。

<a id="data-sent-from-gitlab-to-jira"></a>

### 从极狐GitLab 发送到 Jira 的数据

有关发送到 Jira 的所有数据，请参见[同步到 Jira 的极狐GitLab 数据](#gitlab-data-synced-to-jira)。

有关发送到 Jira 的特定数据属性的更多信息，请参见数据同步中涉及的[序列化器类](https://gitlab.com/gitlab-org/gitlab/-/tree/master/lib/atlassian/jira_connect/serializers)。

<a id="data-sent-from-jira-to-gitlab"></a>

### 从 Jira 发送到极狐GitLab 的数据

当安装或卸载 GitLab for Jira Cloud 应用时，极狐GitLab 会从 Jira 接收一个[生命周期事件](https://developer.atlassian.com/cloud/jira/platform/connect-app-descriptor/#lifecycle)。
该事件包含一个[令牌](#gitlab-access-to-jira)，用于验证后续生命周期事件，并在[向 Jira 发送数据](#data-sent-from-gitlab-to-jira)时进行认证。来自 Jira 的生命周期事件请求会经过[验证](https://developer.atlassian.com/cloud/jira/platform/security-for-connect-apps/#validating-installation-lifecycle-requests)。

对于使用 Atlassian Marketplace 中 GitLab for Jira Cloud 应用的极狐GitLab 私有化部署实例，JihuLab.com 会处理生命周期事件并将其转发到极狐GitLab 私有化部署实例。有关更多信息，请参见 [JihuLab.com 对应用生命周期事件的处理](../../administration/settings/jira_cloud_app.md#gitlabcom-handling-of-app-lifecycle-events)。

<a id="data-stored-by-jira"></a>

### Jira 存储的数据

[发送到 Jira 的数据](#data-sent-from-gitlab-to-jira)由 Jira 存储，并显示在 [Jira 开发面板](development_panel.md)中。

当卸载 GitLab for Jira Cloud 应用时，Jira 会永久删除此数据。
此过程是异步进行的，可能需要长达数小时。

<a id="privacy-and-security-details-in-the-atlassian-marketplace"></a>

### Atlassian Marketplace 中的隐私和安全详情

有关更多信息，请参见 [Atlassian Marketplace 列表的隐私和安全详情](https://marketplace.atlassian.com/apps/1221011/gitlab-for-jira-cloud?tab=privacy-and-security&hosting=cloud)。

<a id="troubleshooting"></a>

## 故障排除

使用 GitLab for Jira Cloud 应用时，您可能会遇到以下问题。

有关管理员故障排除，请参见 [GitLab for Jira Cloud 应用管理](../../administration/settings/jira_cloud_app_troubleshooting.md)。

<a id="error-failed-to-link-group"></a>

### 错误：`Failed to link group`

当您连接 GitLab for Jira Cloud 应用时，可能会遇到此错误：

```plaintext
Failed to link group. Please try again.
```

如果由于权限不足而无法从 Jira 获取用户信息，则会返回 `403 Forbidden`。

要解决此问题，请确保您满足特定的 [Jira 用户要求](../../administration/settings/jira_cloud_app.md#jira-user-requirements)。

如果 Jira 用户具有管理员权限但并非明确属于 `site-admins` 或 `org-admins` 群组的成员，请参见[错误：Jira 用户不是站点或组织管理员](../../administration/settings/jira_cloud_app_troubleshooting.md#error-the-jira-user-is-not-a-site-or-organization-administrator)。

<a id="jira-code-does-not-work-after-linking-to-a-gitlab-group"></a>

### 关联到极狐GitLab 群组后 Jira Code 无法正常工作

在您[将 GitLab for Jira Cloud 应用关联到极狐GitLab 群组](#configure-the-gitlab-for-jira-cloud-app)后，
[Jira Code](https://support.atlassian.com/jira-software-cloud/docs/enable-code/) 可能无法正常工作。要解决此问题，您必须同时配置 Bitbucket 和 Jira。

在 Bitbucket 中：

1. 登录您的 Atlassian 账号。
1. 创建并输入您的工作区名称。

在 Jira 中：

1. 在**项目**中，选择您的项目。
1. 选择**开发** > **代码**。
1. 选择**连接 Bitbucket** > **关联 Bitbucket Cloud 工作区**。
1. 选择您在 Bitbucket 中创建的工作区。
1. 选择**授予访问权限**。

您的代码仓库现在应显示在 Jira Code 中。

有关更多信息，请参见[议题 JRACLOUD-95847](https://jira.atlassian.com/browse/JRACLOUD-95847)。
