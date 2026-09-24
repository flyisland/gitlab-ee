---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab for Jira Cloud app
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> 本页面包含面向用户的极狐GitLab for Jira Cloud app 文档。有关管理员文档，请参阅[极狐GitLab for Jira Cloud app 管理](../../administration/settings/jira_cloud_app.md)。

使用 [极狐GitLab for Jira Cloud](https://marketplace.atlassian.com/apps/1221011/gitlab-com-for-jira-cloud?tab=overview&hosting=cloud) 应用，你可以连接极狐GitLab 和 Jira Cloud，实时同步开发信息。你可以在 [Jira 开发面板](development_panel.md) 中查看这些信息。

你可以使用极狐GitLab for Jira Cloud 应用来关联顶级群组或子群组。无法直接关联项目或个人命名空间。

要在 JihuLab.com 上设置极狐GitLab for Jira Cloud 应用，请[安装极狐GitLab for Jira Cloud 应用](#install-the-gitlab-for-jira-cloud-app)。

设置应用后，你可以使用由 Atlassian 开发和维护的 [项目工具链](https://support.atlassian.com/jira-software-cloud/docs/what-is-the-connections-feature/) 来[将极狐GitLab 仓库关联到 Jira 项目](https://support.atlassian.com/jira-software-cloud/docs/link-repositories-to-a-project/#Link-repositories-using-the-toolchain-feature)。项目工具链不会影响开发信息在极狐GitLab 和 Jira Cloud 之间的同步方式。

对于 Jira Data Center 或 Jira Server，请使用由 Atlassian 开发和维护的 [Jira DVCS 连接器](dvcs/_index.md)。

<a id="gitlab-data-synced-to-jira"></a>

## 极狐GitLab 同步到 Jira 的数据

关联群组后，当你[提及 Jira 议题 ID](development_panel.md#information-displayed-in-the-development-panel) 时，该群组中所有项目的以下极狐GitLab 数据将同步到 Jira：

- 现有项目数据（关联群组之前）：
  - 最近 400 个合并请求
  - 最近 400 个分支以及每个分支的最后一次提交（极狐GitLab 15.11 及更高版本）
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

## 安装极狐GitLab for Jira Cloud 应用

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

先决条件：

- 你的网络必须允许极狐GitLab 和 Jira 之间的入站和出站连接。
- 你必须满足某些 [Jira 用户要求](../../administration/settings/jira_cloud_app.md#jira-user-requirements)。

要安装极狐GitLab for Jira Cloud 应用：

1. 在 Jira 中，在顶部栏中，选择 **应用** > **探索更多应用**，然后搜索 `GitLab for Jira Cloud`。
1. 选择 **GitLab for Jira Cloud**，然后选择 **立即获取**。

或者，[直接从 Atlassian Marketplace 获取应用](https://marketplace.atlassian.com/apps/1221011/gitlab-com-for-jira-cloud?tab=overview&hosting=cloud)。

你现在可以[配置极狐GitLab for Jira Cloud 应用](#configure-the-gitlab-for-jira-cloud-app)。

<a id="configure-the-gitlab-for-jira-cloud-app"></a>

## 配置极狐GitLab for Jira Cloud 应用

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- **添加命名空间** 在极狐GitLab 16.1 中更名为 **关联群组**。

{{< /history >}}

先决条件：

- 你必须具有极狐GitLab 群组的维护者或所有者角色。
- 你必须满足某些 [Jira 用户要求](../../administration/settings/jira_cloud_app.md#jira-user-requirements)。

你可以通过将极狐GitLab for Jira Cloud 应用关联到一个或多个极狐GitLab 群组，将数据从极狐GitLab 同步到 Jira。要配置极狐GitLab for Jira Cloud 应用：

<!-- markdownlint-disable MD044 -->

1. 在 Jira 中，选择 **应用** 旁边的水平省略号 ({{< icon name="ellipsis_h" >}})，然后选择 **管理你的应用**。
1. 使用以下方法之一导航到应用：

   - 对于集中式应用管理的实例：

     1. 如果你看到“应用管理已移至管理”，请选择 **带我去那里**。否则，请按照下面的 **对于使用旧版应用管理的实例** 说明操作。
     1. 在 **已安装的应用** 选项卡中，找到 **GitLab for Jira**。根据你安装应用的方式，应用的名称为：
        - 如果你[从 Atlassian Marketplace 安装了应用](https://marketplace.atlassian.com/apps/1221011/gitlab-com-for-jira-cloud?tab=overview&hosting=cloud)，则为 **GitLab for Jira (gitlab.com)**。
        - 如果你[手动安装了应用](../../administration/settings/jira_cloud_app.md#install-the-gitlab-for-jira-cloud-app-manually)，则为 **GitLab for Jira (`<gitlab.example.com>`)**。
     1. 选择水平省略号 ({{< icon name="ellipsis_h" >}})，然后选择 **开始** 以配置集成。

   - 对于使用旧版应用管理的实例：

     1. 展开 **GitLab for Jira**。根据你安装应用的方式，应用的名称为：
        - 如果你[从 Atlassian Marketplace 安装了应用](https://marketplace.atlassian.com/apps/1221011/gitlab-com-for-jira-cloud?tab=overview&hosting=cloud)，则为 **GitLab for Jira (gitlab.com)**。
        - 如果你[手动安装了应用](../../administration/settings/jira_cloud_app.md#install-the-gitlab-for-jira-cloud-app-manually)，则为 **GitLab for Jira (`<gitlab.example.com>`)**。
     1. 选择 **开始** 以配置集成。

1. 可选。要将极狐GitLab 私有化部署与 Jira 关联，请选择 **更改极狐GitLab 版本**。
   1. 选中所有复选框，然后选择 **下一步**。
   1. 输入你的 **极狐GitLab 实例 URL**，然后选择 **保存**。
1. 选择 **登录极狐GitLab**。

   > [!note]
   > [企业用户](../../user/enterprise_user/_index.md) 如果为其群组[禁用了密码认证](../../user/group/saml_sso/_index.md#disable-password-and-passkey-authentication-for-enterprise-users)，则必须先使用其群组的单点登录 URL 登录极狐GitLab。

   极狐GitLab 要求你登录以关联群组，但不会将配置绑定到特定用户。极狐GitLab 实例从 Jira 接收一个令牌，用于更新 Jira 中的信息。更多信息，请参阅[极狐GitLab 对 Jira 的访问](#gitlab-access-to-jira)。
1. 选择 **授权**。现在可以看到群组列表。
1. 选择 **关联群组**。
1. 要关联群组，请选择 **关联**。

<!-- markdownlint-enable MD044 -->

关联极狐GitLab 群组后：

- 该群组中所有项目的数据将同步到 Jira。初始数据同步以每分钟 20 个项目的批次进行。对于具有许多项目的群组，某些项目的数据同步会延迟。
- 极狐GitLab for Jira Cloud 应用集成会自动为该群组以及该群组中的所有子群组或项目启用。该集成允许你[配置 Jira Service Management](#configure-jira-service-management)。

<a id="configure-jira-service-management"></a>

## 配置 Jira Service Management

{{< history >}}

- 在极狐GitLab 17.2 中引入，带有一个功能标志，名为 `enable_jira_connect_configuration`。默认禁用。
- 在极狐GitLab 17.4 中全面可用。功能标志 `enable_jira_connect_configuration` 已移除。

{{< /history >}}

> [!note]
> 此功能作为社区贡献添加，仅由极狐GitLab 社区开发和维护。

先决条件：

- 必须已[安装](#install-the-gitlab-for-jira-cloud-app)极狐GitLab for Jira Cloud 应用。
- 必须在极狐GitLab for Jira Cloud 应用配置中[关联一个极狐GitLab 群组](#configure-the-gitlab-for-jira-cloud-app)。

你可以将极狐GitLab 连接到你的 IT 服务项目以跟踪部署。

配置在极狐GitLab 的极狐GitLab for Jira Cloud 应用集成中进行。在[关联极狐GitLab 群组](#configure-the-gitlab-for-jira-cloud-app)后，该集成会为群组、其子群组和项目启用。

极狐GitLab for Jira Cloud 应用集成的启用和禁用完全通过群组关联自动进行，而不是通过极狐GitLab 集成表单或 API。

在 Jira Service Management 中：

1. 在你的服务项目中，转到 **项目设置** > **变更管理**。
1. 选择 **连接流水线** > **GitLab**，然后在设置流程结束时复制 **服务 ID**。

在极狐GitLab 中：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **极狐GitLab for Jira Cloud 应用**。如果集成已禁用，请先[关联一个极狐GitLab 群组](#configure-the-gitlab-for-jira-cloud-app)，这会为群组、其子群组和项目启用极狐GitLab for Jira Cloud 应用集成。
1. 在 **服务 ID** 字段中，输入你要映射到此项目的服务 ID。要使用多个服务 ID，请在每个服务 ID 之间添加逗号。

最多可以映射 100 个服务。

有关 Jira 中部署跟踪的更多信息，请参阅[设置部署跟踪](https://support.atlassian.com/jira-service-management-cloud/docs/set-up-deployment-tracking/)。

<a id="set-up-deployment-gating-with-gitlab"></a>

### 使用极狐GitLab 设置部署门禁

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.6 中引入。

{{< /history >}}

> [!note]
> 此功能作为社区贡献添加，仅由极狐GitLab 社区开发和维护。

你可以设置部署门禁，将变更请求从极狐GitLab 带到 Jira Service Management 进行审批。通过部署门禁，任何对你所选环境的极狐GitLab 部署都会自动发送到 Jira Service Management，并且仅在获得批准后才部署。

<a id="create-the-service-account-token"></a>

#### 创建服务账户令牌

要在极狐GitLab 中创建服务账户令牌，你必须先创建个人访问令牌。此令牌用于认证在 Jira Service Management 中管理极狐GitLab 部署的服务账户令牌。

要创建服务账户令牌：

1. [创建服务账户用户](../../api/service_accounts.md#create-an-instance-service-account)。
1. 使用你的个人访问令牌[将服务账户添加到群组或项目](../../api/group_members.md#add-a-group-member)。
1. [将服务账户添加到受保护环境](../../ci/environments/protected_environments.md#protecting-environments)。
1. 使用你的个人访问令牌[生成服务账户令牌](../../api/service_accounts.md#create-a-personal-access-token-for-a-group-service-account)。
1. 复制服务账户令牌值。

<a id="enable-deployment-gating"></a>

#### 启用部署门禁

要启用部署门禁：

- 在极狐GitLab 中：

  1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
  1. 选择 **设置** > **集成**。
  1. 选择 **极狐GitLab for Jira Cloud 应用**。
  1. 在 **部署门禁** 下，选中 **启用部署门禁** 复选框。
  1. 在 **环境层级** 文本框中，输入你要为其启用部署门禁的环境名称。你可以输入多个环境名称，用逗号分隔（例如，`production, staging, testing, development`）。仅使用小写字母。
  1. 选择 **保存更改**。
- 在 Jira Service Management 中：

  1. [设置部署门禁](https://support.atlassian.com/jira-service-management-cloud/docs/set-up-deployment-gating/)。
  1. 在 **服务账户令牌** 文本框中，[粘贴你从极狐GitLab 复制的服务账户令牌值](#create-the-service-account-token)。

<a id="add-the-service-account-to-protected-environments"></a>

#### 将服务账户添加到受保护环境

要将服务账户添加到极狐GitLab 中的受保护环境：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **受保护