---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用直接传输迁移极狐GitLab 数据
description: "Use a direct connection to migrate 极狐GitLab data."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.6 中于 JihuLab.com 启用。
- 新应用程序设置 `bulk_import_enabled` 在极狐GitLab 15.8 中引入。`bulk_import` 功能标志已移除。
- `bulk_import_projects` 功能标志在极狐GitLab 15.10 中移除。

{{< /history >}}

您可以迁移极狐GitLab 群组：

- 从私有化部署迁移到 JihuLab.com
- 从 JihuLab.com 迁移到私有化部署
- 从一个私有化部署实例迁移到另一个
- 在同一极狐GitLab 实例上

直接传输迁移会创建群组的新副本。如果您想移动群组而不是复制群组，且群组位于同一极狐GitLab 实例中，您可以[转移群组](../manage.md#transfer-a-group)。转移群组而非迁移群组是一种更快、更完整的选择。

您可以通过两种方式迁移群组：

- 通过直接传输（推荐）。
- 通过[上传导出文件](../../project/settings/import_export.md)。

如果您从 JihuLab.com 迁移到私有化部署实例，管理员可以在实例上创建用户。

在私有化部署上，默认情况下，[迁移群组项](migrated_items.md#migrated-group-items)不可用。要显示该功能，管理员可以在[应用程序设置中启用它](../../../administration/settings/import_and_export_settings.md#enable-migration-of-groups-and-projects-by-direct-transfer)。

通过直接传输迁移群组会将群组从一个位置复制到另一个位置。您可以：

- 一次复制多个群组。
- 在极狐GitLab UI 中，将顶级群组复制到：
  - 另一个顶级群组。
  - 任何现有顶级群组的子群组。
  - 另一个极狐GitLab 实例，包括 JihuLab.com。
- 使用[直接传输 API 进行群组和项目迁移](../../../api/bulk_imports.md)，将顶级群组和子群组复制到这些位置。
- 复制包含或不包含项目的群组。在 JihuLab.com 上，默认情况下复制包含项目的群组可用。

并非所有群组和项目资源都会被复制。请参阅下面复制的资源列表：

- [已迁移的群组项](migrated_items.md#migrated-group-items)。
- [已迁移的项目项](migrated_items.md#migrated-project-items)。

启动迁移后，您不应该对源实例上已导入的群组或项目进行任何更改，因为这些更改可能不会复制到目标实例。

<a id="migrating-specific-projects"></a>

## 迁移特定的项目

在极狐GitLab UI 中使用直接传输迁移群组会迁移群组中的所有项目。如果您只想使用直接传输迁移群组中的特定项目，则必须使用 [API](../../../api/bulk_imports.md#start-a-group-or-project-migration)。

<a id="known-issues"></a>

## 已知问题

- 文件名超过 255 个字符的文件不会被迁移。
- 在极狐GitLab 16.1 及更早版本中，您不应将直接传输与[计划扫描执行策略](../../application_security/policies/scan_execution_policies.md)一起使用。
- 在极狐GitLab 16.9 及更早版本中，由于已知问题，您可能会看到 `DiffNote::NoteDiffFileCreationError` 错误。当此错误发生时，合并请求差异中某个评论的 diff 会丢失，但评论和合并请求仍会被导入。
- 当从源实例映射时，共享成员会被映射为目标实例上的直接成员，除非这些成员资格已存在于目标实例上。这意味着，将源实例上的顶级群组导入到目标实例上的顶级群组时，即使在源顶级群组包含必要的共享成员层次结构细节的情况下，项目中的成员也会始终映射为直接成员。完整映射共享成员关系的支持正在计划中。
- 在极狐GitLab 17.0、17.1 和 17.2 中，导入的史诗和工作项会映射到导入用户，而非原始作者。
- 直接传输不支持将来自不同源群组的群组或项目合并到单个目标群组中。要合并群组或项目，请在迁移前在源实例上进行重组，或在[完成占位用户重新分配后](../../import/mapping/reassignment.md#completing-the-reassignment)在目标实例上进行重组。

<a id="estimating-migration-duration"></a>

## 预估迁移持续时间

预估直接传输的迁移持续时间很困难。以下因素会影响迁移持续时间：

- 源实例和目标极狐GitLab 实例上可用的硬件和数据库资源。源实例和目标实例上的资源越多，迁移持续时间可能越短，因为：
  - 源实例接收 API 请求，并提取和序列化要导出的实体。
  - 目标实例运行作业并在其数据库中创建实体。
- 要导出数据的复杂性和大小。例如，想象您要迁移两个不同的项目，每个项目有 1000 个合并请求。如果其中一个项目的合并请求包含更多的附件、评论和其他条目，那么这两个项目的迁移时间可能会有很大差异。因此，项目上的合并请求数量并不是预测项目迁移时长的可靠指标。

没有确切的公式可以可靠地估算迁移时间。但是，每个流水线工作器导入项目{{< glossary-tooltip text="relation" >}}的平均持续时间可以帮助您大致了解导入项目可能花费的时间。

在此上下文中，关系是一种可导出项的类型。

| 项目资源类型                 | 导入一条记录的平均时间（秒） |
|:----------------------------|:---------------------------------------------|
| 空项目                       | 2.4                                          |
| 代码仓                       | 20                                           |
| 项目属性                     | 1.5                                          |
| 成员                        | 0.2                                          |
| 标签                        | 0.1                                          |
| 里程碑                      | 0.07                                         |
| 徽章                        | 0.1                                          |
| 议题                        | 0.1                                          |
| 代码片段                    | 0.05                                         |
| 代码片段仓库                | 0.5                                          |
| 展示板                      | 0.1                                          |
| 合并请求                    | 1                                            |
| 外部拉取请求                | 0.5                                          |
| 受保护分支                  | 0.1                                          |
| 项目功能                    | 0.3                                          |
| 容器镜像过期策略            | 0.3                                          |
| 服务台设置                  | 0.3                                          |
| 发布                        | 0.1                                          |
| CI 流水线                   | 0.2                                          |
| 提交评论                    | 0.05                                         |
| Wiki                       | 10                                           |
| 上传文件                    | 0.5                                          |
| LFS 对象                    | 0.5                                          |
| 设计                        | 0.1                                          |
| Auto DevOps                 | 0.1                                          |
| 流水线计划                  | 0.5                                          |
| 引用                        | 5                                            |
| 推送规则                    | 0.1                                          |

尽管预测迁移持续时间很困难，但已观察到以下情况：

- 100 个项目（1.99万 议题，8.3万 合并请求，10万+ 流水线）在 8 小时内完成迁移。
- 1926 个项目（2.2万 议题，16万 合并请求，110万 流水线）在 34 小时内完成迁移。

如果您正在迁移大型项目并遇到超时或迁移持续时间的问题，请尝试[减少迁移持续时间](troubleshooting.md#migrations-are-slow-or-timing-out)。

<a id="limits"></a>

## 限制

有关默认限制，请参阅[直接传输迁移限制](../../../administration/instance_limits.md#direct-transfer-migration)。

您可以使用以下 API 测试最大关系大小限制：

- [群组关系导出 API](../../../api/group_relations_export.md)。
- [项目关系导出 API](../../../api/project_relations_export.md)

如果任一 API 生成的文件大于最大关系大小限制，则直接传输的群组迁移将失败。

<a id="visibility-rules"></a>

## 可见性规则

迁移后：

- 私有群组和项目保持私有。
- 内部群组和项目：
  - 当复制到内部群组时保持内部，除非内部可见性被[限制](../../../administration/settings/visibility_and_access_controls.md#restrict-visibility-levels)。在这种情况下，群组和项目变为私有。
  - 当复制到私有群组时变为私有。
- 公开群组和项目：
  - 当复制到公开群组时保持公开，除非公开可见性被[限制](../../../administration/settings/visibility_and_access_controls.md#restrict-visibility-levels)。在这种情况下，群组和项目变为内部。
  - 当复制到内部群组时变为内部，除非内部可见性被[限制](../../../administration/settings/visibility_and_access_controls.md#restrict-visibility-levels)。在这种情况下，群组和项目变为私有。
  - 当复制到私有群组时变为私有。

如果您在源实例上使用私有网络来向公众隐藏内容，请确保在目标实例上进行类似设置，或者导入到私有群组中。

<a id="migration-by-direct-transfer-process"></a>

## 通过直接传输迁移的过程

请参阅[使用直接传输迁移群组和项目](direct_transfer_migrations.md)。

