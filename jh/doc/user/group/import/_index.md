---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用直接转移迁移极狐GitLab 数据
description: "使用直接连接迁移极狐GitLab 数据。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以迁移极狐GitLab 群组：

- 从极狐GitLab 私有化部署到 JihuLab.com
- 从 JihuLab.com 到极狐GitLab 私有化部署
- 从一个极狐GitLab 私有化部署实例到另一个实例
- 在同一个极狐GitLab 实例内

通过直接转移进行迁移会创建群组的新副本。如果您想移动群组而不是复制群组，并且群组位于同一个极狐GitLab 实例中，您可以[转移群组](../manage.md#transfer-a-group)。转移群组比迁移群组更快，也更完整。

您可以通过以下方式迁移群组：

- 通过直接转移（推荐）。
- 当目标实例与源实例之间没有直接网络连接时，通过对象存储进行[离线转移](../../import/gitlab_instances/offline-transfer-migrations.md)。
- 通过[上传导出文件](../../project/settings/import_export.md)。

如果您从 JihuLab.com 迁移到极狐GitLab 私有化部署实例，管理员可以在该实例上创建用户。

在极狐GitLab 私有化部署上，默认情况下[迁移群组条目](migrated_items.md#migrated-group-items)不可用。要显示该功能，管理员可以[在应用程序设置中启用它](../../../administration/settings/import_and_export_settings.md#enable-migration-of-groups-and-projects-by-direct-transfer)。

通过直接转移迁移群组会将群组从一个位置复制到另一个位置。您可以：

- 一次复制多个群组。
- 在极狐GitLab UI 中，将顶级群组复制到：
  - 另一个顶级群组。
  - 任何现有顶级群组的子群组。
  - 另一个极狐GitLab 实例，包括 JihuLab.com。
- 在[通过直接转移 API 进行群组和项目迁移](../../../api/bulk_imports.md)中，将顶级群组和子群组复制到这些位置。
- 复制包含或不包含项目的群组。
  在 JihuLab.com 上，默认可以复制包含项目的群组。

并非所有群组和项目资源都会被复制。请参阅下面的已复制资源列表：

- [已迁移的群组条目](migrated_items.md#migrated-group-items)。
- [已迁移的项目条目](migrated_items.md#migrated-project-items)。

开始迁移后，您不应在源实例上对已导入的群组或项目进行任何更改，因为这些更改可能不会被复制到目标实例。

我们鼓励您在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/284495)中留下关于通过直接转移进行迁移的反馈。

<a id="migrating-specific-projects"></a>

## 迁移特定项目

在极狐GitLab UI 中使用直接转移迁移群组会迁移群组中的所有项目。如果您只想使用直接转移迁移群组中的特定项目，则必须使用 [API](../../../api/bulk_imports.md#start-a-group-or-project-migration)。

<a id="known-issues"></a>

## 已知问题

- 由于[议题 406685](https://gitlab.com/gitlab-org/gitlab/-/issues/406685)，文件名超过 255 个字符的文件不会被迁移。
- 从源实例映射时，共享成员会映射为目标实例上的直接成员，除非这些成员关系已存在于目标实例上。这意味着，将源实例上的顶级群组导入到目标实例上的顶级群组时，项目中的成员始终会映射为直接成员，即使源顶级群组包含必要的共享成员层级详细信息。对共享成员关系的完整映射支持已在[议题 458345](https://gitlab.com/gitlab-org/gitlab/-/issues/458345)中提出。
- 在极狐GitLab 17.0、17.1 和 17.2 中，导入的史诗和工作项会映射到执行导入的用户，而不是原始作者。
- 直接转移不支持将来自不同源群组的群组或项目合并到单个目标群组中。要合并群组或项目，请在迁移前在源实例上进行重组，或者在[占位用户重新分配完成后](../../import/mapping/reassignment.md#completing-the-reassignment)在目标实例上进行重组。请参阅[议题 589460](https://gitlab.com/gitlab-org/gitlab/-/work_items/589460)。
- 如果目标命名空间与源命名空间属于不同的组织，并且任一组织被标记为隔离，则通过直接转移进行的迁移会失败。有关更多信息，请参阅[议题 595674](https://gitlab.com/gitlab-org/gitlab/-/issues/595674)。
- 由于直接转移迁移会将贡献映射到目标实例上未被封禁的用户，因此在源实例上被隐藏的已封禁用户贡献会再次出现在目标实例上。要隐藏这些贡献，请在目标实例上执行以下任一操作：
  - 封禁这些用户。
  - 删除这些贡献。
  有关更多信息，请参阅[议题 508111](https://gitlab.com/gitlab-org/gitlab/-/work_items/508111)。
- 在迁移期间，评论、议题描述和合并请求描述中的 URL 引用只会针对属于正在迁移的群组或项目的链接（`source_full_path`）进行重写。指向源实例上其他群组或项目的 URL 不会被重写，即使这些群组或项目也被迁移。
  迁移后，您可以手动更新任何仍指向源实例的外部链接。

<a id="estimating-migration-duration"></a>

## 估算迁移时长

估算通过直接转移进行迁移的时长比较困难。以下因素会影响迁移时长：

- 源极狐GitLab 实例和目标极狐GitLab 实例上可用的硬件和数据库资源。源实例和目标实例上的资源越多，迁移时长可能越短，因为：
  - 源实例接收 API 请求，并提取和序列化要导出的实体。
  - 目标实例运行作业并在其数据库中创建实体。
- 要导出的数据的复杂性和大小。例如，假设您想迁移两个不同的项目，每个项目都有 1000 个合并请求。如果其中一个项目的合并请求上有更多的附件、评论和其他条目，那么这两个项目的迁移时间可能会有很大差异。因此，项目上合并请求的数量并不能很好地预测项目迁移所需的时间。

没有确切的公式可以可靠地估算迁移时间。但是，每个流水线工作进程导入一个项目的平均时长 {{< glossary-tooltip text="relation" >}} 可以帮助您大致了解导入项目可能需要多长时间。

在此上下文中，关系是一种可导出的条目类型。

| 项目资源类型       | 导入一条记录的平均时间（秒） |
|:----------------------------|:---------------------------------------------|
| 空项目               | 2.4                                          |
| 代码仓库                  | 20                                           |
| 项目属性          | 1.5                                          |
| 成员                     | 0.2                                          |
| 标记                      | 0.1                                          |
| 里程碑                  | 0.07                                         |
| 徽章                      | 0.1                                          |
| 议题                      | 0.1                                          |
| 代码片段                    | 0.05                                         |
| 代码片段仓库        | 0.5                                          |
| 看板                      | 0.1                                          |
| 合并请求              | 1                                            |
| 外部拉取请求      | 0.5                                          |
| 受保护分支          | 0.1                                          |
| 项目功能             | 0.3                                          |
| 容器镜像过期策略 | 0.3                                          |
| 服务台设置        | 0.3                                          |
| 发布                    | 0.1                                          |
| CI 流水线                | 0.2                                          |
| 提交评论                | 0.05                                         |
| Wiki                        | 10                                           |
| 上传                     | 0.5                                          |
| LFS 对象                 | 0.5                                          |
| 设计                      | 0.1                                          |
| Auto DevOps                 | 0.1                                          |
| 流水线计划          | 0.5                                          |
| 引用                  | 5                                            |
| 推送规则                   | 0.1                                          |

尽管很难预测迁移时长，但已观察到以下情况：

- 100 个项目（1.99 万个议题、8.3 万个合并请求、10 万多个流水线）在 8 小时内完成迁移。
- 1926 个项目（2.2 万个议题、16 万个合并请求、110 万个流水线）在 34 小时内完成迁移。

如果您正在迁移大型项目并遇到超时或迁移时长问题，请尝试[缩短迁移时长](troubleshooting.md#migrations-are-slow-or-timing-out)。

<a id="limits"></a>

## 限制

有关默认限制，请参阅[直接转移迁移限制](../../../administration/instance_limits.md#direct-transfer-migration)。

您可以使用以下 API 测试最大关系大小限制：

- [群组关系导出 API](../../../api/group_relations_export.md)。
- [项目关系导出 API](../../../api/project_relations_export.md)

如果任一 API 生成的文件大于最大关系大小限制，则通过直接转移进行的群组迁移会失败。

<a id="visibility-rules"></a>

## 可见性规则

迁移后：

- 私有群组和项目保持私有。
- 内部群组和项目：
  - 复制到内部群组时保持内部，除非内部可见性被[限制](../../../administration/settings/visibility_and_access_controls.md#restrict-visibility-levels)。在这种情况下，群组和项目会变为私有。
  - 复制到私有群组时变为私有。
- 公开群组和项目：
  - 复制到公开群组时保持公开，除非公开可见性被[限制](../../../administration/settings/visibility_and_access_controls.md#restrict-visibility-levels)。在这种情况下，群组和项目会变为内部。
  - 复制到内部群组时变为内部，除非内部可见性被[限制](../../../administration/settings/visibility_and_access_controls.md#restrict-visibility-levels)。在这种情况下，群组和项目会变为私有。
  - 复制到私有群组时变为私有。

如果您在源实例上使用了专用网络来向公众隐藏内容，请确保在目标实例上进行类似设置，或者导入到私有群组中。

<a id="migration-by-direct-transfer-process"></a>

## 直接转移迁移过程

请参阅[使用直接转移迁移群组和项目](direct_transfer_migrations.md)。
