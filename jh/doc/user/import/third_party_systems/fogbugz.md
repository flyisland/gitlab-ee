---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 FogBugz 迁移
description: "从 FogBugz 迁移到极狐GitLab。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

将您的 FogBugz 项目导入到极狐GitLab。

FogBugz 导入器会导入您的所有案例和评论，并保留原始案例编号和时间戳。
您可以将 FogBugz 用户映射到极狐GitLab 用户。

<a id="prerequisites"></a>

## 先决条件

- 已启用 [FogBugz 导入源](../../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources)。如果未启用，请联系您的极狐GitLab 管理员启用。FogBugz 导入源在 JihuLab.com 上默认启用。
- 对要导入到的目标群组具有维护者或所有者角色。

<a id="import-project-from-fogbugz"></a>

## 从 FogBugz 导入项目

要从 FogBugz 导入您的项目：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建项目/代码仓库**。
1. 选择 **导入项目**。
1. 选择 **FogBugz**。
1. 输入您的 FogBugz URL、电子邮件地址和密码。
1. 创建从 FogBugz 用户到极狐GitLab 用户的映射。对于每个 FogBugz 用户：
   - 要将 FogBugz 账号映射到全名，而不映射到极狐GitLab 账号，请将 **极狐GitLab 用户** 文本框留空。此映射会将用户的全名添加到所有议题和评论的描述中，但会将议题和评论分配给项目创建者。
   - 要将 FogBugz 账号映射到极狐GitLab 账号，请在 **极狐GitLab 用户** 中，选择您想要关联议题和评论的极狐GitLab 用户。
1. 当所有用户都映射完成后，选择 **继续下一步**。
1. 要导入项目：
   - 首次导入：选择 **导入**。
   - 再次导入：选择 **重新导入**。指定新名称并再次选择 **重新导入**。重新导入会创建源项目的新副本。
1. 导入完成后，选择链接转到项目仪表板。按照说明推送您现有的代码仓库。
