---
stage: Foundations
group: Import and Integrate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 从 Bitbucket Server 导入您的项目
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

{{< history >}}

- 重新导入项目的能力引入于极狐GitLab 15.9。
- 导入审核者的能力引入于极狐GitLab 16.3。
- 支持拉取请求审批导入引入于极狐GitLab 16.7。
- 在一些导入的项目上的 **导入的** 徽章引入于极狐GitLab 17.2。

{{< /history >}}

将您的项目从 Bitbucket Server 导入到极狐GitLab。

<a id="estimating-import-duration"></a>

## 估算导入时间

每次从 Bitbucket Server 导入都是不同的，这会影响导入的持续时间。然而，为了帮助估算导入的持续时间，由以下数据组成的项目可能需要 8 小时才能导入：

- 13,000 个拉取请求
- 10,000 个分支
- 7,000 个标签
- 500 GiB 的仓库

<a id="prerequisites"></a>

## 前提条件

{{< history >}}

- Requirement for Maintainer role instead of Developer role introduced in 极狐GitLab 16.0 and backported to 极狐GitLab 15.11.1 and 极狐GitLab 15.10.5.

{{< /history >}}

- 必须启用 [Bitbucket Server 导入源](../../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources)。如果未启用，请询问您的极狐GitLab管理员启用它。Bitbucket Server 导入源在 JihuLab.com 上默认启用。
- 在目标群组上至少要有维护者角色才能导入。
- 具有管理员访问权限的 Bitbucket Server 身份验证令牌。

<a id="import-repositories"></a>

## 导入仓库

要导入您的 Bitbucket 仓库：

1. 登录到极狐GitLab。
1. 在左侧边栏顶部选择 **创建新的** ({{< icon name="plus" >}}) 和 **新项目/仓库**。
1. 选择 **导入项目**。
1. 选择 **Bitbucket Server**。
1. 登录到 Bitbucket 并授予极狐GitLab访问您的 Bitbucket 帐户。
1. 选择要导入的项目或导入所有项目。您可以按名称过滤项目，并选择要导入每个项目的命名空间。
1. 要导入项目：
   - 第一次：选择 **导入**。
   - 再次：选择 **重新导入**。指定新名称并再次选择 **重新导入**。重新导入会创建源项目的新副本。

<a id="items-that-are-imported"></a>

## 导入的项目

- 仓库描述
- Git 仓库数据
- 拉取请求，包括评论、用户提及、审阅者和合并事件
- LFS 对象

导入时：

- 仓库的公开访问权限得以保留。如果 Bitbucket 中的仓库是私有的，则在极狐GitLab中创建时也是私有的。
- 导入的合并请求和评论在极狐GitLab中有一个 **导入的** 徽章。

当关闭或合并的拉取请求被导入时，不存在于仓库中的提交 SHA 从 Bitbucket Server 中获取，以确保拉取请求有与之相关联的提交：

- 源提交 SHA 以 `refs/merge-requests/<iid>/head` 格式保存。
- 目标提交 SHA 以 `refs/keep-around/<SHA>` 格式保存。

如果源提交在仓库中不存在，则使用包含 SHA 的提交消息的提交代替。

<a id="items-that-are-not-imported"></a>

## 未导入的项目

以下项目不会导入：

- Markdown 中的附件
- 任务列表
- 表情符号反应
- 拉取请求审批
- 拉取请求的审批规则

<a id="items-that-are-imported-but-changed"></a>

## 导入但已更改的项目

导入时以下项目会更改：

- 极狐GitLab不允许在任意代码行上发表评论。任何越界的 Bitbucket 评论都会作为合并请求中的评论插入。
- 多个线程级别会折叠成一个线程，并作为原始评论的一部分添加引用。
- 项目过滤不支持模糊搜索。仅支持 **以开头** 或 **完全匹配** 字符串。

<a id="user-contribution-and-membership-mapping"></a>

## 用户贡献和成员映射

{{< history >}}

- 通过邮件地址或用户名进行用户映射引入于极狐GitLab 13.4，使用名为 `bitbucket_server_user_mapping_by_username` 的[功能标志](../../../administration/feature_flags.md)启用。默认情况下禁用。
- 将用户提及和极狐GitLab 用户映射添加于极狐GitLab 16.8。
- 在极狐GitLab 17.1 中更改为仅通过电子邮件地址映射用户。
- 在极狐GitLab 17.8 中，在 JihuLab.com 上更改了[用户贡献和成员映射](_index.md#user-contribution-and-membership-mapping)。
- 在极狐GitLab 17.8 中，为 JihuLab.com 和私有化部署启用。

{{< /history >}}

Bitbucket Server 导入器使用 [改进的方法](_index.md#user-contribution-and-membership-mapping) 来映射 JihuLab.com 和极狐GitLab私有化部署中的用户贡献。

<a id="old-method-of-user-contribution-mapping"></a>

### 用户贡献映射的旧方法

您可以使用旧的用户贡献映射方法来导入到极狐GitLab私有化部署和极狐GitLab Dedicated 实例。要使用此方法，必须禁用 `importer_user_mapping` 和 `bitbucket_server_user_mapping`。对于导入到 JihuLab.com，您必须使用 [改进的方法](_index.md#user-contribution-and-membership-mapping)。

使用旧方法，导入器尝试将 Bitbucket Server 用户的电子邮件地址与极狐GitLab用户数据库中的确认电子邮件地址进行匹配。如果没有找到这样的用户：

- 改用项目创建者。导入器在评论中附加备注以标记原始创建者。
- 对于拉取请求审阅者，没有分配审阅者。
- 对于拉取请求批准者，没有添加批准。

拉取请求描述和备注中的 `@mentions` 通过使用用户的电子邮件地址与 Bitbucket Server 上的用户配置文件进行匹配。如果在极狐GitLab中没有找到具有相同电子邮件地址的用户，则 `@mention` 被静态化。要匹配用户，他们必须具有至少提供项目读取访问权限的极狐GitLab角色。

如果项目是公开的，极狐GitLab仅匹配被邀请到项目的用户。

如果命名空间不存在，导入器会创建任何新的命名空间（群组）。如果命名空间已被占用，仓库会导入到启动导入过程的用户的命名空间下。

<a id="troubleshooting"></a>

## 故障排除

<a id="general"></a>

### 常规

如果基于 GUI 的导入工具不起作用，您可以尝试：

- 使用 [极狐GitLab导入 API](../../../api/import.md#import-repository-from-bitbucket-server) Bitbucket Server 端点。
- 设置 [仓库镜像](../repository/mirror/_index.md)。它提供详细的错误输出。

请参阅 Bitbucket 云的 [故障排除部分](bitbucket.md#troubleshooting)。

<a id="lfs-objects-not-imported"></a>

### LFS 对象未导入

如果项目导入完成但无法下载或克隆 LFS 对象，则您可能正在使用包含特殊字符的密码或个人访问令牌。

<a id="import-fails-due-to-invalid-unresolved-host-address-or-the-import-url-is-blocked"></a>

### 导入因无效/无法解析的主机地址或导入 URL 被阻止而失败

如果项目导入失败并出现错误消息，例如 `导入项目失败：导入 URL 被阻止`，即使最初连接到 Bitbucket Server 成功，Bitbucket Server 或反向代理可能未正确配置。

要解决此问题，请使用 [项目 API](../../../api/projects.md) 检查新创建的项目并定位项目的 `import_url` 值。

此值指示 Bitbucket Server 提供的用于导入的 URL。如果此 URL 无法公开解析，您可能会收到无法解析的地址错误。

要解决此问题，请确保 Bitbucket Server 知道任何代理服务器，因为代理服务器可能会影响 Bitbucket 构建和使用 URL 的方式。
