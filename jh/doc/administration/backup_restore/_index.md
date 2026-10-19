---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 备份与恢复概览
description: 备份和恢复极狐GitLab 实例。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您的极狐GitLab 实例包含软件开发或组织所需的关键数据。制定包含定期备份的灾难恢复计划非常重要，原因如下：

- 数据保护：防止因硬件故障、软件缺陷或意外删除而导致的数据丢失。
- 灾难恢复：在发生不利事件时恢复极狐GitLab 实例和数据。
- 版本控制：提供历史快照，以便回滚到之前的状态。
- 合规性：满足特定行业的监管要求。
- 迁移：便于将极狐GitLab 迁移到新服务器或环境。
- 测试与开发：创建副本以测试升级或新功能，而不会对生产数据造成风险。

> [!note]
> 本文档适用于极狐GitLab 基础版和企业版。
> 虽然 JihuLab.com 可确保数据安全，但您无法使用这些方法从 JihuLab.com 导出或备份数据。

<a id="back-up-gitlab"></a>

## 备份极狐GitLab

备份极狐GitLab 实例的步骤因部署的具体配置和使用模式而异。数据类型、存储位置和数据量等因素会影响备份方法、存储选项和恢复过程。更多信息，请参见[备份极狐GitLab](backup_gitlab.md)。

<a id="restore-gitlab"></a>

## 恢复极狐GitLab

恢复极狐GitLab 实例的步骤因部署的具体配置和使用模式而异。数据类型、存储位置和数据量等因素会影响恢复过程。

更多信息，请参见[恢复极狐GitLab](restore_gitlab.md)。

<a id="migrate-to-a-new-server"></a>

## 迁移到新服务器

使用极狐GitLab 的备份和恢复功能可将实例迁移到新服务器。对于极狐GitLab Geo 部署，请考虑 [Geo 计划内故障转移的灾难恢复](../geo/disaster_recovery/planned_failover.md)。更多信息，请参见[迁移到新服务器](migrate_to_new_server.md)。

<a id="back-up-and-restore-large-gitlab-environments"></a>

## 备份和恢复大型极狐GitLab 环境

大型极狐GitLab 环境可能需要单独的步骤来备份和恢复对象存储数据、PostgreSQL 数据和 Git 代码仓库。更多信息，请参见[备份和恢复大型极狐GitLab 环境](backup_large_reference_architectures.md)。

<a id="backup-archive-process"></a>

## 备份归档流程

为保护数据并确保系统完整性，极狐GitLab 会创建备份归档。有关极狐GitLab 如何创建此归档的详细信息，请参见[备份归档流程](backup_archive_process.md)。
