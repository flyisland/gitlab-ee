---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用直接传输迁移的条目
description: "使用直接传输时包含或排除的项目和群组条目。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用直接传输方法时，许多条目会被迁移，有些则会被排除。

> [!note]
> 使用自定义表情的 Emoji 反应只有在目标实例上存在同名自定义表情时才会被迁移。引用目标实例上缺失的自定义表情的反应会被跳过。

<a id="migrated-group-items"></a>

## 已迁移的群组条目

已迁移的群组条目取决于您在目标实例上使用的极狐GitLab 版本。要确定某个特定群组条目是否被迁移：

1. 检查所有版本的 [`groups/stage.rb`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/bulk_imports/groups/stage.rb) 文件，以及目标实例上您所用版本的企业版 [`groups/stage.rb`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/ee/bulk_imports/groups/stage.rb) 文件。例如，对于 15.9 版本：
   - <https://gitlab.com/gitlab-org/gitlab/-/blob/15-9-stable-ee/lib/bulk_imports/groups/stage.rb>（所有版本）。
   - <https://gitlab.com/gitlab-org/gitlab/-/blob/15-9-stable-ee/ee/lib/ee/bulk_imports/groups/stage.rb>（企业版）。
1. 检查目标实例上您所用版本的群组 [`group/import_export.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/import_export/group/import_export.yml) 文件。例如，对于 15.9 版本：
   <https://gitlab.com/gitlab-org/gitlab/-/blob/15-9-stable-ee/lib/gitlab/import_export/group/import_export.yml>。

任何其他群组条目都不会被迁移。

迁移到目标极狐GitLab 实例的群组条目包括：

- 徽章
- 看板
- 看板列表
- 史诗
- 史诗看板
- 史诗看板列表
- 群组标记

  > [!note]
  > 导入期间，群组标记无法保留任何关联的标记优先级。
  > 将相关项目迁移到目标实例后，您必须手动重新设置这些标记的优先级。

- 群组里程碑
- 迭代
- 迭代节奏
- [成员](direct_transfer_migrations.md#user-membership-mapping)
- 命名空间设置
- 发布里程碑
- 子群组
- 上传
- Wiki

<a id="excluded-items"></a>

### 排除的条目

某些群组条目因以下原因被排除在迁移之外：

- 可能包含敏感信息：
  - CI/CD 变量
  - 部署令牌
  - Webhook
- 不受支持：
  - 自定义字段
  - 迭代节奏设置
  - 待处理的成员邀请
  - 推送规则

此外，用户及其创建的任何[个人访问令牌](../../profile/personal_access_tokens.md)均被排除在迁移之外。

<a id="migrated-project-items"></a>

## 已迁移的项目条目

如果您在[选择要迁移的群组](direct_transfer_migrations.md#select-the-groups-and-projects-to-import)时选择迁移项目，则项目条目会随项目一起迁移。

已迁移的项目条目取决于您在目标实例上使用的极狐GitLab 版本。要确定某个特定项目条目是否被迁移：

1. 检查所有版本的 [`projects/stage.rb`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/bulk_imports/projects/stage.rb) 文件，以及目标实例上您所用版本的企业版 [`projects/stage.rb`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/ee/bulk_imports/projects/stage.rb) 文件。例如，对于 15.9 版本：
   - <https://gitlab.com/gitlab-org/gitlab/-/blob/15-9-stable-ee/lib/bulk_imports/projects/stage.rb>（所有版本）。
   - <https://gitlab.com/gitlab-org/gitlab/-/blob/15-9-stable-ee/ee/lib/ee/bulk_imports/projects/stage.rb>（企业版）。
1. 检查目标实例上您所用版本的项目 [`project/import_export.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/import_export/project/import_export.yml) 文件。例如，对于 15.9 版本：
   <https://gitlab.com/gitlab-org/gitlab/-/blob/15-9-stable-ee/lib/gitlab/import_export/project/import_export.yml>。

任何其他项目条目都不会被迁移。

如果您选择不随群组一起迁移项目，或者想要重试项目迁移，您可以使用 [API](../../../api/bulk_imports.md) 发起仅项目的迁移。

迁移到目标极狐GitLab 实例的项目条目包括：

- Auto DevOps
- 徽章
- 分支（包括受保护分支）

  > [!note]
  > 导入的分支遵循目标群组的[默认分支保护设置](../../project/repository/branches/protected.md)。
  > 这些设置可能会导致未受保护的分支被导入为受保护分支。

- CI 流水线

  > [!note]
  > 流水线和作业记录（如状态、阶段和时间戳）会被迁移。
  > 作业日志和作业产物不会被迁移。有关更多信息，请参阅[排除的条目](#excluded-items-1)。

- 提交评论
- 设计
- 外部合并请求
- 议题
- 议题看板
- 标记
- LFS 对象
- [成员](direct_transfer_migrations.md#user-membership-mapping)
- 合并请求
- 里程碑
- 流水线历史
- 流水线计划
- 项目
- 项目功能
- 推送规则。导入期间，[群组推送规则](../../project/repository/push_rules.md#group-push-rules)优先于项目推送规则。
  如果源实例有任何群组推送规则，则不会导入任何项目推送规则。
- 发布
- 发布证据
- 代码仓库
- 设置
- 代码片段
- 上传
- 漏洞报告

  > [!note]
  > 在极狐GitLab 17.7 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/501466)。
  > 漏洞报告在迁移时不包含其状态。
  > 有关更多信息，请参阅[议题 512859](https://gitlab.com/gitlab-org/gitlab/-/issues/512859)。
  > 有关迁移漏洞报告时出现 `ActiveRecord::RecordNotUnique` 错误的信息，
  > 请参阅[议题 509904](https://gitlab.com/gitlab-org/gitlab/-/issues/509904)。

- Wiki

<a id="issue-related-items"></a>

### 与议题相关的条目

迁移到目标极狐GitLab 实例的与议题相关的项目条目包括：

- 议题评论
- 议题迭代
- 议题资源迭代事件
- 议题资源里程碑事件
- 议题资源状态事件
- 合并请求 URL 引用
- 时间跟踪

<a id="merge-request-related-items"></a>

### 与合并请求相关的条目

迁移到目标极狐GitLab 实例的与合并请求相关的项目条目包括：

- 议题 URL 引用
- 合并请求批准人
- 合并请求评论
- 合并请求资源里程碑事件
- 合并请求资源状态事件
- 合并请求审核人
- 多个合并请求指派人
- 时间跟踪

<a id="setting-related-items"></a>

### 与设置相关的条目

迁移到目标极狐GitLab 实例的与设置相关的项目条目包括：

- 头像
- 容器过期策略
- 项目属性
- 服务台

<a id="excluded-items-1"></a>

### 排除的条目

某些项目条目因以下原因被排除在迁移之外：

- 可能包含敏感信息：
  - CI/CD 作业日志
  - CI/CD 变量
  - 容器镜像仓库中的镜像
  - 部署密钥
  - 部署令牌
  - 加密令牌
  - 作业产物
  - 流水线计划变量
  - 流水线触发器
  - Webhook
- 不受支持：
  - Agent
  - [子 CI/CD 流水线](https://gitlab.com/gitlab-org/gitlab/-/issues/571159)
  - 容器镜像仓库
  - 自定义字段
  - 环境
  - 功能标志
  - 基础设施仓库
  - 从极狐GitLab 私有化部署迁移到 JihuLab.com 时，分支保护规则中的实例管理员
  - 关联议题
  - 合并请求批准规则
  - 合并请求依赖
  - 软件包仓库
  - Pages 域名
  - 待处理的成员邀请
  - 远程镜像
  - Wiki 评论

    > [!note]
    > 与项目设置相关的批准规则会被导入。

- 不包含可恢复数据：
  - 没有差异或源信息的合并请求
    （有关更多信息，请参阅[议题 537943](https://gitlab.com/gitlab-org/gitlab/-/issues/537943)）

此外，用户及其创建的任何[个人访问令牌](../../profile/personal_access_tokens.md)均被排除在迁移之外。
