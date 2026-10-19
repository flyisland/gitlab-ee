---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义流水线配置
description: 为流水线配置可见性、超时、Git 策略、自动取消行为和自动清理等设置。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以自定义项目中流水线的运行方式。

<a id="change-which-users-can-view-your-pipelines"></a>

## 更改可以查看流水线的用户

对于公开和内部项目，您可以更改谁可以查看：

- 流水线
- 作业输出日志
- 作业产物

**基于项目的流水线可见性**设置不会更改谁可以查看[流水线安全报告](../../user/application_security/detect/security_scanning_results.md#view-pipeline-security-report)。

要更改流水线及相关功能的可见性：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**通用流水线**。
1. 选中或清除**基于项目的流水线可见性**复选框。
   选中时，流水线及相关功能对以下对象可见：

   - 对于[**公开**](../../user/public_access.md)项目，对所有人可见。
   - 对于**内部**项目，对所有已认证用户可见，但[外部用户](../../administration/external_users.md)除外。
   - 对于**私有**项目，对所有项目成员（访客或更高角色）可见。

   清除时：

   - 对于**公开**项目，作业日志、作业产物
     和 **CI/CD** 菜单项仅对项目成员（报告者或更高角色）可见。
     其他用户（包括访客用户）只能查看流水线和作业的状态，并且仅在
     查看合并请求或提交时可见。
   - 对于**内部**项目，流水线对所有已认证用户可见，但[外部用户](../../administration/external_users.md)除外。
     相关功能仅对项目成员（报告者或更高角色）可见。
   - 对于**私有**项目，流水线及相关功能仅对项目成员（报告者或更高角色）可见。

<a id="change-pipeline-visibility-for-non-project-members-in-public-projects"></a>

### 更改公开项目中非项目成员的流水线可见性

您可以控制[公开项目](../../user/public_access.md)中非项目成员的流水线可见性。

在以下情况下，此设置无效：

- 项目可见性设置为[**内部**或**私有**](../../user/public_access.md)，
  因为非项目成员无法访问内部或私有项目。
- [**基于项目的流水线可见性**](#change-which-users-can-view-your-pipelines)设置已禁用。

要更改非项目成员的流水线可见性：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**。
1. 对于 **CI/CD**，选择：
   - **仅项目成员**：只有项目成员可以查看流水线。
   - **所有有访问权限的人**：非项目成员也可以查看流水线。
1. 选择**保存更改**。

[CI/CD 权限表](../../user/permissions.md#project-cicd)
列出了当选择**所有有访问权限的人**时，非项目成员可以访问的流水线功能。

<a id="auto-cancel-redundant-pipelines"></a>

## 自动取消冗余流水线

您可以设置当同一分支上运行针对新更改的流水线时，自动取消待处理或正在运行的流水线。您可以在项目设置中启用此功能：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**通用流水线**。
1. 选中**自动取消冗余流水线**复选框。
1. 选择**保存更改**。

使用 [`interruptible`](../yaml/_index.md#interruptible) 关键字来指示正在运行的作业是否可以在完成前被取消。在带有 `interruptible: false`的作业启动后，整个流水线不再被视为可中断。

<a id="skip-branch-pipelines-for-merge-requests"></a>

## 为合并请求跳过分支流水线

{{< details >}}

- Status: 测试版

{{< /details >}}

此功能处于[测试版](../../policy/development_stages_support.md#beta)。

当您推送到带有打开的合并请求的分支时，极狐GitLab 默认会尝试同时创建分支流水线和合并请求流水线。这可能会浪费 CI/CD 资源，并导致对哪个流水线决定合并就绪状态产生混淆。有关此问题的更多信息，请参阅[避免重复流水线](../jobs/job_rules.md#avoid-duplicate-pipelines)。

要在推送到带有打开的合并请求的分支时仅创建合并请求流水线：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**通用流水线**。
1. 选中**为合并请求跳过分支流水线**复选框。
1. 选择**保存更改**。

启用此设置后：

- 当您 `git push` 到作为合并请求源分支的分支时，
  极狐GitLab 不会尝试创建分支流水线。极狐GitLab 只会尝试创建合并请求流水线。
- 如果该分支不是打开或之前已关闭的合并请求的源分支，
  则极狐GitLab 会尝试创建分支流水线。
- 在创建合并请求的首次推送中，仍会创建分支流水线，
  因为流水线在合并请求创建之前就已启动。
  从下一次推送开始，将跳过分支流水线。
- 可合并性检查（例如[**流水线必须成功**](../../user/project/merge_requests/auto_merge.md#require-a-successful-pipeline-for-merge)）
  仅考虑合并请求流水线。分支流水线
  不影响合并就绪状态。
- 没有显式 `rules`、`only` 或 `except` 部分的作业会自动
  包含在合并请求流水线中。对于这些作业，隐式的 `only: [branches, tags]` 默认值会被移除。
- 仅影响由推送触发的流水线。所有其他流水线类型（包括
  手动、API、计划和触发的流水线）不受影响。
- 如果您将流水线或作业配置为仅运行分支流水线，
  启用此设置可能会导致您的合并请求没有流水线运行。

<a id="prevent-outdated-deployment-jobs"></a>

## 防止过时的部署作业

您的项目可能有多个并发的部署作业，计划在同一时间段内运行。

这可能导致较旧的部署作业在较新的部署作业之后运行，这可能不是您想要的结果。

要避免这种情况：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**通用流水线**。
1. 选中**防止过时的部署作业**复选框。
1. 可选。清除**允许回滚部署的作业重试**复选框。
1. 选择**保存更改**。

有关更多信息，请参阅[部署安全](../environments/deployment_safety.md#prevent-outdated-deployment-jobs)。

<a id="restrict-roles-that-can-cancel-pipelines-or-jobs"></a>

## 限制可以取消流水线或作业的角色

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以自定义哪些角色有权取消流水线或作业。

默认情况下，具有开发者、维护者或所有者角色的用户可以取消流水线或作业。您可以将取消权限限制为仅具有维护者或所有者角色的用户，或完全阻止取消任何流水线或作业。

要更改取消流水线或作业的权限：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**通用流水线**。
1. 从**取消流水线或作业所需的最低角色**中选择一个选项。
1. 选择**保存更改**。

<a id="specify-a-custom-cicd-configuration-file"></a>

## 指定自定义 CI/CD 配置文件

极狐GitLab 期望在项目的根目录中找到 CI/CD 配置文件（`.gitlab-ci.yml`）。但是，您可以指定替代的文件名路径，包括项目之外的位置。

要自定义路径：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**通用流水线**。
1. 在 **CI/CD 配置文件**字段中，输入文件名。如果该文件：
   - 不在根目录中，请包含路径。
   - 在其他项目中，请包含群组和项目名称。
   - 在外部站点上，请输入完整 URL。
1. 选择**保存更改**。

> [!note]
> 您不能使用项目的[流水线编辑器](../pipeline_editor/_index.md)来
> 编辑其他项目或外部站点上的 CI/CD 配置文件。

<a id="custom-cicd-configuration-file-examples"></a>

### 自定义 CI/CD 配置文件示例

如果 CI/CD 配置文件不在根目录中，则路径必须相对于根目录。例如：

- `my/path/.gitlab-ci.yml`
- `my/path/.my-custom-file.yml`

如果 CI/CD 配置文件在外部站点上，则 URL 必须以 `.yml` 结尾：

- `http://example.com/generate/ci/config.yml`

如果 CI/CD 配置文件在其他项目中：

- 该文件必须存在于其默认分支上，或将分支指定为 refname。
- 路径必须相对于其他项目中的根目录。
- 路径后面必须跟一个 `@` 符号以及完整的群组和项目路径。

例如：

- `.gitlab-ci.yml@namespace/another-project`
- `my/path/.my-custom-file.yml@namespace/subgroup/another-project`
- `my/path/.my-custom-file.yml@namespace/subgroup1/subgroup2/another-project:refname`

如果配置文件在单独的项目中，您可以设置更细粒度的权限。例如：

- 创建一个公开项目来托管配置文件。
- 仅向允许编辑该文件的用户授予该项目的写入权限。

然后其他用户和项目可以访问该配置文件，但不能编辑它。

<a id="choose-the-default-git-strategy"></a>

## 选择默认 Git 策略

您可以选择作业运行时如何从极狐GitLab 获取代码仓库。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**通用流水线**。
1. 在 **Git 策略**下，选择一个选项：
   - `git clone` 较慢，因为它会为每个作业
     从头克隆代码仓库。但是，本地工作副本始终是干净的。
   - `git fetch` 较快，因为它会重用本地工作副本（如果不存在，
     则回退到克隆）。请使用此命令，尤其是对于
     [大型代码仓库](../../user/project/repository/monorepos/_index.md#use-git-fetch-in-cicd-operations)。

配置的 Git 策略可以被 `.gitlab-ci.yml` 文件中的 [`GIT_STRATEGY` 变量](../runners/configure_runners.md#git-strategy)覆盖。

<a id="limit-the-number-of-changes-fetched-during-clone"></a>

## 限制克隆期间获取的更改数量

您可以限制极狐GitLab CI/CD 在克隆代码仓库时获取的更改数量。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**通用流水线**。
1. 在 **Git 策略**下，在 **Git 浅克隆**下，输入一个值。
   最大值为 `1000`。要禁用浅克隆并让极狐GitLab CI/CD
   每次获取所有分支和标签，请将该值留空或设置为 `0`。

新建项目的默认 `git depth` 值为 `20`。

此值可以被 `.gitlab-ci.yml` 文件中的 [`GIT_DEPTH` 变量](../../user/project/repository/monorepos/_index.md#use-shallow-clones-and-filters-in-cicd-processes)覆盖。

<a id="set-a-limit-for-how-long-jobs-can-run"></a>

## 设置作业可以运行的最长时间

您可以定义作业在超时前可以运行多长时间。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**通用流水线**。
1. 在**超时**字段中，输入分钟数，或像 `2 hours` 这样的可读值。
   必须为 10 分钟或更长，且少于一个月。默认值为 60 分钟。
   待处理的作业在 24 小时无活动后会被丢弃。

超过超时时间的作业会被标记为失败。

当同时设置了项目超时和 [runner 超时](../runners/configure_runners.md#set-the-maximum-job-timeout)时，较低的值优先。

无论超时设置如何，一小时没有输出的作业都会被丢弃。要防止这种情况发生，请添加一个脚本以持续输出进度。有关更多信息，请参阅[议题 25359](https://gitlab.com/gitlab-org/gitlab/-/issues/25359#workaround)。

<a id="pipeline-badges"></a>

## 流水线徽章

您可以使用[流水线徽章](../../user/project/badges.md)来指示项目的流水线状态和测试覆盖率。这些徽章由最近一次成功的流水线决定。

<a id="disable-gitlab-cicd-pipelines"></a>

## 禁用极狐GitLab CI/CD 流水线

极狐GitLab CI/CD 流水线在所有新项目中默认启用。如果您使用像
Jenkins 或 Drone CI 这样的外部 CI/CD 服务器，您可以禁用极狐GitLab CI/CD 以避免与提交状态 API 冲突。

您可以按项目禁用极狐GitLab CI/CD，或[为实例上的所有新项目禁用](../../administration/cicd/_index.md)。

当您禁用极狐GitLab CI/CD 时：

- 左侧边栏中的 **CI/CD** 项会被移除。
- `/pipelines` 和 `/jobs` 页面不再可用。
- 现有的作业和流水线会被隐藏，而不是移除。

要在项目中禁用极狐GitLab CI/CD：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**。
1. 在**代码仓库**部分，关闭 **CI/CD**。
1. 选择**保存更改**。

这些更改不适用于[外部集成](../../user/project/integrations/_index.md#available-integrations)中的项目。

<a id="automatic-pipeline-cleanup"></a>

## 自动清理流水线

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

设置保留期以帮助管理流水线存储并提高系统性能。超过配置时长的流水线会由后台作业自动删除。清理会定期在后台运行，而不是在流水线符合条件时立即运行。积压了大量旧流水线的项目会在多次运行中逐步清理。

当流水线被删除时，其作业、作业日志和产物也会被永久删除。所有超过配置保留期的流水线都有资格被删除，无论其状态或它们是否是给定分支或标签的最新流水线。

先决条件：

- 项目的所有者角色。

要配置自动清理流水线：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**通用流水线**。
1. 在**自动清理流水线**字段中，输入时长，例如 `2 weeks` 或 `30 days`。
   该值必须至少为一天，且不超过实例最大值（默认 1 年）。留空则永不自动删除流水线。
1. 选择**保存更改**。

对于极狐GitLab 私有化部署，管理员可以提高[自动清理流水线](../../administration/cicd/limits.md#maximum-retention-period-for-automatic-pipeline-cleanup)的上限。
