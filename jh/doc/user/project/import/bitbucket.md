---
stage: Foundations
group: Import and Integrate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 从 Bitbucket Cloud 导入您的项目
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 从 Bitbucket Cloud 并行导入引入于极狐GitLab 16.6，使用名为 `bitbucket_parallel_importer` 的[功能标志](../../../administration/feature_flags.md)。默认禁用。
- 在极狐GitLab 16.6 中，为 JihuLab.com 启用。
- 在极狐GitLab 16.7 中 GA。功能标志 `bitbucket_parallel_importer` 被移除。
- 在有些导入项上的 **导入的** 徽章引入于极狐GitLab 17.2。

{{< /history >}}

从 Bitbucket Cloud 导入项目到极狐GitLab。

Bitbucket 导入工具可以导入：

1. 仓库描述
1. Git 仓库数据
1. 议题，包括评论
1. 拉取请求，包括评论
1. 里程碑
1. Wiki
1. 标签
1. LFS 对象

Bitbucket 导入工具无法导入：

1. 拉取请求审批
1. 审批规则

导入时：

1. 对拉取请求和议题的引用会被保留。
1. 仓库公共访问权限会被保留。如果仓库在 Bitbucket 上是私有的，它在极狐GitLab中也会被创建为私有。
1. 导入的议题、合并请求和评论在极狐GitLab中会有一个**导入的**徽章。

{{< alert type="note" >}}

Bitbucket Cloud 导入工具仅适用于 [Bitbucket.org](https://bitbucket.org/)，不适用于 Bitbucket Server （又称为 Stash）。如果您尝试从 Bitbucket Server 导入项目，请使用 [Bitbucket Server 导入工具](bitbucket_server.md)。

{{< /alert >}}

当议题、拉取请求和评论被导入时，Bitbucket 导入工具会使用作者/受托人的 Bitbucket 昵称，并尝试在极狐GitLab中找到相同的 Bitbucket 身份。如果它们不匹配或者用户在极狐GitLab数据库中没有找到，该项目的创建者（通常是启动导入过程的当前用户）将被设置为作者，但在议题上会保留原始 Bitbucket 作者的引用。

对于拉取请求：

1. 如果源 SHA 在仓库中不存在，导入工具会尝试将源提交设置为合并提交 SHA。
1. 合并请求受托人被设置为作者。审阅者则根据匹配的 Bitbucket 身份在极狐GitLab中设置用户名。
1. 极狐GitLab中的合并请求可以是 `opened`，`closed` 或 `merged`。

对于议题：

1. 会添加一个标签，对应于 Bitbucket 上议题的类型。可能是 `bug`，`enhancement`，`proposal` 或 `task`。
1. 如果 Bitbucket 上的议题是 `resolved`，`invalid`，`duplicate`，`wontfix` 或 `closed`，议题在极狐GitLab中也会被关闭。

导入工具会创建任何新的命名空间（群组）如果它们不存在，或者如果命名空间被占用，仓库会被导入到启动导入过程的用户的命名空间下。

<a id="prerequisites"></a>

## 先决条件

{{< history >}}

- - 所需维护者角色而不是开发者角色的要求引入于极狐GitLab 16.0 并回溯到极狐GitLab 15.11.1 和极狐GitLab 15.10.5。

{{< /history >}}

1. 必须启用 [Bitbucket Cloud 集成](../../../integration/bitbucket.md)。如果该集成未启用，请向您的极狐GitLab管理员请求启用。Bitbucket Cloud 集成在 JihuLab.com 上默认启用。
1. 必须启用 [Bitbucket Cloud 导入源](../../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources)。如果未启用，请向您的极狐GitLab管理员请求启用。Bitbucket Cloud 导入源在 JihuLab.com 上默认启用。
1. 在目标群组上至少需要有维护者角色以进行导入。
1. Bitbucket 中的拉取请求必须具有相同的源项目和目标项目，不能来自项目的分叉。否则，拉取请求会被导入为空的合并请求。

<a id="requirements-for-user-mapped-contributions"></a>

### 用户映射贡献的要求

为了映射用户贡献，每个用户在项目导入之前必须完成以下操作：

1. 验证 Bitbucket 账户设置中的用户名是否与 Atlassian 账户设置中的公开名称匹配。如果它们不匹配，请修改 Atlassian 账户设置中的公开名称以匹配 Bitbucket 账户设置中的用户名。

1. 在 [极狐GitLab 个人资料服务登录](https://jihulab.com/-/profile/account) 中连接您的 Bitbucket 账户。

<a id="import-your-bitbucket-repositories"></a>

## 导入您的 Bitbucket 仓库

{{< history >}}

- 重新导入项目的能力引入于极狐GitLab 15.9。

{{< /history >}}

1. 登录到极狐GitLab。
1. 在左侧边栏顶部，选择 **创建新的** （{{< icon name="plus" >}}）和 **新项目/仓库**。
1. 选择 **导入项目**。
1. 选择 **Bitbucket Cloud**。
1. 登录到 Bitbucket，然后选择 **授予访问权限** 以让极狐GitLab访问您的 Bitbucket 账户。
1. 选择要导入的项目，或者导入所有项目。您可以通过名称过滤项目并选择导入的命名空间。

1. 要导入项目：
   - 首次导入：选择 **导入**。
   - 再次导入：选择 **重新导入**。指定新名称并再次选择 **重新导入**。重新导入会创建源项目的新副本。

<a id="generate-a-bitbucket-cloud-app-password"></a>

### 生成 Bitbucket Cloud 应用密码

如果您想使用 [极狐GitLab REST API](../../../api/import.md#import-repository-from-bitbucket-cloud) 来导入 Bitbucket Cloud 仓库，您必须创建一个 Bitbucket Cloud 应用密码。

生成 Bitbucket Cloud 应用密码的方法：

1. 前往 <https://bitbucket.org/account/settings/>.
1. 在 **访问管理** 部分，选择 **应用密码**。
1. 选择 **创建应用密码**。
1. 输入密码名称。
1. 至少选择以下权限：

   ```plaintext
   Account: Email, Read
   Projects: Read
   Repositories: Read
   Pull Requests: Read
   Issues: Read
   Wiki: Read and Write
   ```

1. 选择 **创建**。

<a id="troubleshooting"></a>

## 故障排除

<a id="if-you-have-more-than-one-bitbucket-account"></a>

### 如果您有多个 Bitbucket 账户

请确保登录到正确的账户。

如果您不小心使用错误的账户开始导入过程，请按照以下步骤进行：

1. 撤销极狐GitLab对您的 Bitbucket 账户的访问，基本上是逆转以下过程中的步骤：[导入您的 Bitbucket 仓库](#import-your-bitbucket-repositories)。

1. 登出 Bitbucket 账户。按照上一步链接的过程进行。

<a id="user-mapping-fails-despite-matching-names"></a>

### 用户映射失败即使名称匹配

[为了让用户映射正常工作](#requirements-for-user-mapped-contributions)，Bitbucket 账户设置中的用户名必须与 Atlassian 账户设置中的公开名称匹配。如果这些名称匹配但用户映射仍然失败，可能是用户在连接他们的 Bitbucket 账户到 [极狐GitLab 个人资料服务登录](https://gitlab.com/-/profile/account) 后修改了 Bitbucket 用户名。

要解决此问题，用户必须验证他们在极狐GitLab数据库中的 Bitbucket 外部 UID 是否与他们当前的 Bitbucket 公开名称匹配，如果不匹配则重新连接：

1. [使用 API 获取当前认证用户](../../../api/users.md#as-a-regular-user-2)。

1. 在 API 响应中，`identities` 属性包含在极狐GitLab数据库中存在的 Bitbucket 账户。如果 `extern_uid` 与当前 Bitbucket 公开名称不匹配，用户应该在 [极狐GitLab 个人资料服务登录](https://gitlab.com/-/profile/account) 中重新连接他们的 Bitbucket 账户。

1. 重新连接后，用户应该再次使用 API 验证他们在极狐GitLab数据库中的 `extern_uid` 是否现在与他们当前的 Bitbucket 公开名称匹配。

然后导入工具必须 [删除导入的项目](../working_with_projects.md#delete-a-project) 并重新导入。
