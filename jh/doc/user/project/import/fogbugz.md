---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 FogBugz 迁移
description: "Migrate from FogBugz to 极狐GitLab."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 15.9 中引入了重新导入项目的能力。

{{< /history >}}

使用导入工具，您可以将 FogBugz 项目导入到 JihuLab.com 或私有化部署。

导入工具会导入所有案例和评论，保留原始案例编号和时间戳。您还可以将 FogBugz 用户映射到 极狐GitLab 用户。

<a id="prerequisites"></a>

## 先决条件

{{< history >}}

- 要求维护者角色而非开发者角色，在 极狐GitLab 16.0 中引入，并向后移植到 极狐GitLab 15.11.1 和 极狐GitLab 15.10.5。

{{< /history >}}

- [FogBugz 导入源](../../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources) 必须启用。如果未启用，请让您的 极狐GitLab 管理员启用它。默认情况下，FogBugz 导入源在 JihuLab.com 上已启用。
- 在目标群组上需要具有维护者或所有者角色。

<a id="import-project-from-fogbugz"></a>

## 从 FogBugz 导入项目

要从 FogBugz 导入您的项目：

1. 登录 极狐GitLab。
1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建项目/仓库**。
1. 选择 **导入项目**。
1. 选择 **FogBugz**。
1. 输入您的 FogBugz URL、电子邮件地址和密码。
1. 创建 FogBugz 用户到 极狐GitLab 用户的映射。对于每个 FogBugz 用户：
   - 要将 FogBugz 帐户映射到一个全名，而不映射到 极狐GitLab 帐户，请将 **极狐GitLab 用户** 文本框留空。此映射会将用户的全名添加到所有议题和评论的描述中，但会将议题和评论分配给项目创建者。
   - 要将 FogBugz 帐户映射到 极狐GitLab 帐户，请在 **极狐GitLab 用户** 中选择您想要关联议题和评论的 极狐GitLab 用户。
1. 当所有用户都映射完毕后，选择 **继续下一步**。
1. 对于您想要导入的每个项目，选择 **导入**。
1. 导入完成后，选择链接转到项目仪表板。按照指示推送您现有的仓库。
1. 要导入项目：
   - 首次导入：选择 **导入**。
   - 再次导入：选择 **重新导入**。指定一个新名称，然后再次选择 **重新导入**。重新导入会创建源项目的一个新副本。

<a id="related-topics"></a>

## 相关主题

- [导入和导出设置](../../../administration/settings/import_and_export_settings.md)。
- [导入的 Sidekiq 配置](../../../administration/sidekiq/configuration_for_imports.md)。
- [运行多个 Sidekiq 进程](../../../administration/sidekiq/extra_sidekiq_processes.md)。
- [处理特定作业类](../../../administration/sidekiq/processing_specific_job_classes.md)。