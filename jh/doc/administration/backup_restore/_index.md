---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 备份与恢复概述
description: Back up and restore a 极狐GitLab instance.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您的极狐GitLab 实例包含软件开发或组织的关键数据。
制定包含定期备份的灾难恢复计划至关重要，其目的包括：

- 数据保护：防范因硬件故障、软件错误或意外删除导致的数据丢失。
- 灾难恢复：在发生不利事件时恢复极狐GitLab 实例和数据。
- 版本控制：提供历史快照，支持回滚到先前状态。
- 合规性：满足特定行业的监管要求。
- 迁移：便于将极狐GitLab 迁移到新服务器或环境。
- 测试与开发：创建副本以测试升级或新功能，避免影响生产数据。

> [!note]
> 本文档适用于极狐GitLab 基础版和企业版。
> 虽然 JihuLab.com 的数据安全性得到保证，但您无法使用这些方法从 JihuLab.com 导出或备份数据。

<a id="back-up-gitlab"></a>

## 备份极狐GitLab

备份极狐GitLab 实例的过程因部署的具体配置和使用模式而异。
数据类型、存储位置和数据量等因素会影响备份方法、存储选项和恢复过程。更多信息，请参见[备份极狐GitLab](backup_gitlab.md)。

<a id="restore-gitlab"></a>

## 恢复极狐GitLab

恢复极狐GitLab 实例的过程因部署的具体配置和使用模式而异。
数据类型、存储位置和数据量等因素会影响恢复过程。

更多信息，请参见[恢复极狐GitLab](restore_gitlab.md)。

<a id="migrate-to-a-new-server"></a>

## 迁移到新服务器

使用极狐GitLab 备份和恢复功能将实例迁移到新服务器。对于极狐GitLab Geo 部署，
请考虑[Geo 灾难恢复计划故障转移](../geo/disaster_recovery/planned_failover.md)。
更多信息，请参见[迁移到新服务器](migrate_to_new_server.md)。

<a id="back-up-and-restore-large-reference-architectures"></a>

## 备份和恢复大型参考架构

定期备份和恢复大型参考架构非常重要。
有关如何配置和恢复对象存储数据、PostgreSQL 数据和 Git 仓库备份的信息，请参见[备份和恢复大型参考架构](backup_large_reference_architectures.md)。

<a id="backup-archive-process"></a>

## 备份归档过程

为了数据保存和系统完整性，极狐GitLab 会创建备份归档。有关极狐GitLab 如何创建此归档的详细信息，请参见[备份归档过程](backup_archive_process.md)。

<a id="related-topics"></a>

## 相关主题

- [Geo](../geo/_index.md)
- [灾难恢复 (Geo)](../geo/disaster_recovery/_index.md)
- [迁移极狐GitLab 群组](../../user/group/import/_index.md)
- [导入和迁移至极狐GitLab](../../user/import/_index.md)
- [极狐GitLab Linux 软件包 (Omnibus) - 备份与恢复](https://gitlab.cn/docs/omnibus/settings/backups/)
- [极狐GitLab Helm chart - 备份与恢复](https://gitlab.cn/docs/charts/backup-restore/)
- [极狐GitLab Operator - 备份与恢复](https://gitlab.cn/docs/operator/backup_and_restore/)