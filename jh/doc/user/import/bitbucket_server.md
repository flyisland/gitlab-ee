---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 Bitbucket Server 迁移
description: "从 Bitbucket Server 迁移到极狐GitLab。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

将您的项目从 Bitbucket Server 导入到极狐GitLab。

Bitbucket Server 导入器会从 Bitbucket Server 导入一部分条目。

| Bitbucket Server 条目                                                         | 是否导入 |
|:------------------------------------------------------------------------------|:---------|
| 代码仓库描述                                                        | {{< yes >}} |
| Git 代码仓库数据                                                           | {{< yes >}} |
| 拉取请求，包括评论、用户提及、审核人和合并事件 | {{< yes >}} |
| LFS 对象                                                                   | {{< yes >}} |
| 代码评论<sup>1</sup>                                                  | {{< yes >}} |
| 讨论串<sup>2</sup>                                                           | {{< yes >}} |
| 项目筛选<sup>3</sup>                                                   | {{< yes >}} |
| Markdown 中的附件                                                       | {{< no >}} |
| 任务列表                                                                    | {{< no >}} |
| 表情回应                                                               | {{< no >}} |
| 拉取请求审批                                                        | {{< no >}} |
| 拉取请求的审批规则                                              | {{< no >}} |

脚注：

1. 极狐GitLab 不允许对任意代码行发表评论。任何超出范围的 Bitbucket 评论都会作为
   合并请求中的评论插入。
1. 多个层级的讨论串会合并为一个讨论串，引用会作为原始评论的一部分添加。
1. 项目筛选不支持模糊搜索。仅支持前缀匹配或完全匹配字符串。

<a id="known-issues"></a>

## 已知问题

- 拉取请求描述和评论中嵌入的图片和文件附件不会复制到极狐GitLab。
  它们仍作为指向原始 Bitbucket 托管 URL 的外部链接。
  如果源 Bitbucket Server 实例已停用或代码仓库被删除，所有嵌入的图片和附件链接将永久失效。
  在停用源 Bitbucket Server 实例之前，请确认所有嵌入的图片和附件均可访问，或单独保存它们。
  有关导入图片和附件的支持，已在[工作项 623235](https://gitlab.com/gitlab-org/gitlab/-/work_items/623235) 中提出。

<a id="importer-workflow"></a>

## 导入器工作流

Bitbucket Server 导入器支持对 JihuLab.com 和
极狐GitLab 私有化部署的用户贡献进行[迁移后映射](mapping/post_migration_mapping.md)。导入器还支持一种[替代映射方法](#alternative-method-of-mapping)。

导入 Bitbucket Server 条目时：

- 保留代码仓库的公共访问权限。如果代码仓库在 Bitbucket 中是私有的，则在极狐GitLab 中创建为私有。
- 导入的合并请求和评论在极狐GitLab 中带有 **已导入** 徽章。

当导入已关闭或已合并的拉取请求时，会从 Bitbucket Server 获取代码仓库中不存在的提交 SHA，以确保拉取请求关联了提交：

- 源提交 SHA 以 `refs/merge-requests/<iid>/head` 格式的引用保存。
- 目标提交 SHA 以 `refs/keep-around/<SHA>` 格式的引用保存。

如果源提交在代码仓库中不存在，则使用提交消息中包含该 SHA 的提交。

<a id="estimating-import-duration"></a>

## 估算导入时长

每次从 Bitbucket Server 导入的内容都不同，这会影响您执行的导入时长。
但是，为帮助您估算导入时长，包含以下数据的项目可能需要 8 小时才能完成导入：

- 13,000 个拉取请求
- 7,000 个标签
- 500 GiB 代码仓库

<a id="prerequisites"></a>

## 先决条件

- Bitbucket Server 必须可从极狐GitLab 实例访问。Bitbucket Server URL 必须是
  可公开解析的，或者可在运行极狐GitLab 的网络上访问。
- 您必须启用 [Bitbucket Server 导入源](../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources)，
  或请求您的极狐GitLab 管理员启用它。在 JihuLab.com 上默认启用。
- 对要导入到的目标群组具有维护者或所有者角色。
- 具有管理员访问权限的 Bitbucket Server 身份验证令牌。如果没有管理员访问权限，某些数据将
  [无法导入](https://gitlab.com/gitlab-org/gitlab/-/issues/446218)。

<a id="import-your-bitbucket-server-repositories"></a>

## 导入您的 Bitbucket Server 代码仓库

要导入您的 Bitbucket Server 代码仓库：

1. 登录极狐GitLab。
1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建项目/代码仓库**。
1. 选择 **导入项目**。
1. 选择 **Bitbucket Server**。
1. 登录 Bitbucket 并授予极狐GitLab 访问您 Bitbucket 账户的权限。
1. 选择要导入的项目，或导入所有项目。您可以按名称筛选项目，并选择
   要为每个项目导入的命名空间。
1. 要导入项目：
   - 首次导入时，选择 **导入**。
   - 后续导入时，选择 **重新导入**。指定新名称并再次选择 **重新导入**。重新导入会创建
     源项目的新副本。

<a id="alternative-method-of-mapping"></a>

## 替代映射方法

您可以禁用 `bitbucket_server_user_mapping` 功能标志，以使用替代的用户贡献映射方法
进行导入。

对于导入到 JihuLab.com，您必须改用[迁移后方法](mapping/post_migration_mapping.md)。

> [!flag]
> 此功能的可用性由功能标志控制。不建议使用此功能，并且此功能不适用于
> 迁移到 JihuLab.com。在此映射方法中发现的问题不太可能被修复。请改用
> [迁移后方法](mapping/post_migration_mapping.md)，该方法没有这些限制。
>
> 有关更多信息，请参阅[议题 512213](https://gitlab.com/gitlab-org/gitlab/-/work_items/512213)。

使用替代方法时，导入器会尝试将 Bitbucket Server 用户的电子邮件地址与极狐GitLab 用户数据库中的
已确认电子邮件地址进行匹配。如果未找到此类用户：

- 则改用项目创建者。导入器会在评论中附加一条说明，以标记原始创建者。
- 对于拉取请求审核人，不会指派任何审核人。
- 对于拉取请求审批人，不会添加任何审批。

拉取请求描述和评论中的提及会通过使用用户的电子邮件地址与 Bitbucket Server 上的用户配置文件进行匹配。
如果在极狐GitLab 上找不到具有相同电子邮件地址的用户，则该提及将变为静态。
要匹配用户，该用户必须具有至少能提供项目读取访问权限的极狐GitLab 角色。

如果项目是公共的，极狐GitLab 仅匹配已受邀加入该项目的用户。

如果命名空间（群组）不存在，导入器会创建它们。如果命名空间已被占用，则
代码仓库将导入到发起导入过程的用户的命名空间下。

<a id="troubleshooting"></a>

## 故障排除

以下部分包含您可能遇到的问题的解决方案。

<a id="general"></a>

### 常规

如果基于 GUI 的导入工具无法正常工作，您可以尝试：

- 使用 [导入 API](../../api/import.md#import-repository-from-bitbucket-server)
  的 Bitbucket Server 端点。
- 设置[代码仓库镜像](../project/repository/mirror/_index.md)。
  它提供详细的错误输出。

有关 Bitbucket Cloud，请参阅[故障排除部分](bitbucket_cloud.md#troubleshooting)。

<a id="lfs-objects-not-imported"></a>

### LFS 对象未导入

如果项目导入完成，但无法下载或克隆 LFS 对象，则您可能使用了包含特殊字符的
密码或个人访问令牌。有关更多信息，请参阅
[议题 337769](https://gitlab.com/gitlab-org/gitlab/-/issues/337769)。

<a id="import-fails-due-to-invalidunresolved-host-address-or-the-import-url-is-blocked"></a>

### 导入因无效/无法解析的主机地址而失败，或导入 URL 被阻止

如果项目导入失败，并显示类似 `Importing the project failed: Import URL is blocked` 的错误消息，即使与 Bitbucket
服务器的初始连接成功，也可能是因为 Bitbucket 服务器或反向代理配置不正确。

要解决此问题，请使用 [Projects API](../../api/projects.md) 检查新创建的项目，并找到该项目的 `import_url` 值。

此值表示 Bitbucket 服务器提供的用于导入的 URL。如果此 URL 无法公开解析，您可能会遇到无法解析的地址错误。

要解决此问题，请确保 Bitbucket 服务器了解任何代理服务器，因为代理服务器会影响 Bitbucket 构造和使用 URL 的方式。
有关更多信息，请参阅[代理和安全 Bitbucket](https://confluence.atlassian.com/bitbucketserver/proxy-and-secure-bitbucket-776640099.html)。

<a id="import-fails-with-jsonnestingerror"></a>

### 导入失败并显示 JSON::NestingError

如果项目导入失败，并显示包含 `JSON::NestingError` 的错误消息，则 Bitbucket Server 响应包含深度嵌套的对象，这些对象超过了 `max_http_response_json_depth` 设置。

要解决此问题，请增加[出站请求的 JSON HTTP 响应中允许的最大嵌套深度](../../administration/instance_limits.md#maximum-allowed-nesting-depth-in-json-http-responses-from-outbound-requests)。
