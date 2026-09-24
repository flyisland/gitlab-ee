---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Control the job concurrency in GitLab CI/CD
title: 资源组
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

默认情况下，极狐GitLab CI/CD 中的流水线会并发运行。并发是改善合并请求反馈循环的重要因素，但在某些情况下，你可能希望限制部署作业的并发性，使其逐一执行。使用资源组可以有策略地控制作业的并发性，从而在保障安全性的前提下优化持续部署工作流。

<a id="add-a-resource-group"></a>

## 添加资源组

你只能为资源组添加一个资源。

假设你有以下流水线配置（仓库中的 `.gitlab-ci.yml` 文件）：

```yaml
构建:
  stage: build
  script: echo "你的构建脚本"

部署:
  stage: deploy
  script: echo "你的部署脚本"
  environment: production
```

每次向分支推送新提交时，都会运行一个新流水线，其中包含两个作业：`构建` 和 `部署`。但是，如果你在短时间内推送多个提交，多个流水线将同时运行，例如：

- 第一个流水线运行作业 `构建` -> `部署`
- 第二个流水线运行作业 `构建` -> `部署`

在这种情况下，不同流水线中的 `部署` 作业可能会并发运行到 `production` 环境。在同一基础设施上运行多个部署脚本可能会损坏或混淆实例，最坏的情况下会使其处于损坏状态。

为了确保 `部署` 作业每次只运行一次，你可以为并发敏感作业指定 [`resource_group` 关键字](../yaml/_index.md#resource_group)：

```yaml
部署:
  # ...
  resource_group: production
```

通过此配置，在保证部署安全性的同时，你仍然可以并发运行 `构建` 作业，最大限度地提高流水线效率。

<a id="prerequisites"></a>

## 先决条件

- 熟悉 [极狐GitLab CI/CD 流水线](../pipelines/_index.md)
- 熟悉 [极狐GitLab 环境和部署](../environments/_index.md)
- 拥有项目的开发者、维护者或所有者角色以配置 CI/CD 流水线。

<a id="process-modes"></a>

## 处理模式

你可以选择处理模式来控制作业并发性，以满足你的部署偏好。支持以下模式：

| 处理模式 | 描述 | 使用场景  |
|---------------|-------------|-------------|
| `unordered` | 默认处理模式。每当作业准备就绪时就处理作业。 | 作业的执行顺序不重要。最简单的选项。 |
| `oldest_first` | 当资源空闲时，从按流水线 ID 升序排列的待处理作业列表中选择第一个作业。 | 你希望首先执行最旧流水线中的作业。效率低于 `无序` 模式，但对持续部署更安全。 |
| `newest_first` | 当资源空闲时，从按流水线 ID 降序排列的待处理作业列表中选择第一个作业。 | 你希望执行最新流水线中的作业，并[防止过时的部署作业](../environments/deployment_safety.md#prevent-outdated-deployment-jobs)。每个作业必须是幂等的。 |
| `newest_ready_first` | 当资源空闲时，从等待此资源的待处理作业列表中选择第一个作业。作业按流水线 ID 降序排列。 | 你希望在新流水线等待的同时仍能优先部署当前流水线。比 `最新优先` 更快。每个作业必须是幂等的。 |

<a id="change-the-process-mode"></a>

### 更改处理模式

要更改资源组的处理模式，你必须使用 API，并发送请求以[编辑现有资源组](../../api/resource_groups.md#update-a-resource-group)，同时指定 `process_mode`：

- `unordered`
- `oldest_first`
- `newest_first`
- `newest_ready_first`

<a id="an-example-of-difference-between-the-process-modes"></a>

### 处理模式差异示例

考虑以下 `.gitlab-ci.yml`，它包含一个 `构建` 作业和一个 `部署` 作业。每个作业运行在自己的阶段中，并且 `部署` 作业的资源组被设置为 `production`：

```yaml
构建:
  stage: build
  script: echo "你的构建脚本"

部署:
  stage: deploy
  script: echo "你的部署脚本"
  environment: production
  resource_group: production
```

如果在短时间内向项目推送了三个提交，这意味着三个流水线几乎同时运行：

- 第一个流水线运行作业 `构建` -> `部署`。我们称此部署作业为 `deploy-1`。
- 第二个流水线运行作业 `构建` -> `部署`。我们称此部署作业为 `deploy-2`。
- 第三个流水线运行作业 `构建` -> `部署`。我们称此部署作业为 `deploy-3`。

根据资源组的处理模式：

- 如果处理模式设置为 `无序`：
  - `deploy-1`、`deploy-2` 和 `deploy-3` 不会并发运行。
  - 不保证作业的执行顺序，例如 `deploy-1` 可能在 `deploy-3` 之前或之后运行。
- 如果处理模式是 `最早优先`：
  - `deploy-1`、`deploy-2` 和 `deploy-3` 不会并发运行。
  - `deploy-1` 最先运行，`deploy-2` 第二，`deploy-3` 最后运行。
- 如果处理模式是 `最新优先`：
  - `deploy-1`、`deploy-2` 和 `deploy-3` 不会并发运行。
  - `deploy-3` 最先运行，`deploy-2` 第二，`deploy-1` 最后运行。

<a id="pipeline-level-concurrency-control-with-cross-projectparent-child-pipelines"></a>

## 使用跨项目/父子流水线进行流水线级别的并发控制

你可以为对并发执行敏感的下游流水线定义 `resource_group`。[`trigger` 关键字](../yaml/_index.md#trigger) 可以触发下游流水线，而 [`resource_group` 关键字](../yaml/_index.md#resource_group) 可以与其共存。`resource_group` 能有效控制部署流水线的并发性，而其他作业可以继续并发运行。

以下示例展示了一个项目中的两个流水线配置。当流水线开始运行时，非敏感作业会先执行，并且不会受到其他流水线并发执行的影响。然而，极狐GitLab 会确保在触发部署（子）流水线之前没有其他部署流水线正在运行。如果其他部署流水线正在运行，极狐GitLab 会等待那些流水线完成后再运行下一个。

```yaml
# .gitlab-ci.yml（父流水线）

构建:
  stage: build
  script: echo "构建中..."

测试:
  stage: test
  script: echo "测试中..."

部署:
  stage: deploy
  trigger:
    include: deploy.gitlab-ci.yml
    strategy: mirror
  resource_group: AWS-production
```

```yaml
# deploy.gitlab-ci.yml（子流水线）

stages:
  - 资源准备
  - 部署

资源准备:
  stage: 资源准备
  script: echo "资源准备中..."

部署作业:
  stage: 部署
  script: echo "部署中..."
  environment: production
```

你必须定义 [`trigger:strategy`](../yaml/_index.md#triggerstrategy) 以确保直到下游流水线完成后才释放锁。

<a id="related-topics"></a>

## 相关主题

- [API 文档](../../api/resource_groups.md)
- [日志文档](../../administration/logs/_index.md#ci_resource_groups_jsonlog)
- [用于安全部署的极狐GitLab](../environments/deployment_safety.md)

<a id="troubleshooting"></a>

## 故障排除

<a id="avoid-dead-locks-in-pipeline-configurations"></a>

### 避免流水线配置中的死锁

由于 [`最早优先` 处理模式](#process-modes) 强制按照流水线顺序执行作业，存在与其他 CI 功能不协调的情况。

例如，当你运行一个[子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines) 且该子流水线需要与父流水线相同的资源组时，可能会发生死锁。以下是一个糟糕的配置示例：

```yaml
# 错误的做法
测试:
  stage: test
  trigger:
    include: child-pipeline-requires-production-resource-group.yml
    strategy: mirror

部署:
  stage: deploy
  script: echo
  resource_group: production
  environment: production
```

在父流水线中，它运行 `测试` 作业，进而运行一个子流水线。而 [`strategy: mirror` 选项](../yaml/_index.md#triggerstrategy) 会使 `测试` 作业等待子流水线完成。父流水线在下一阶段运行需要 `production` 资源组资源的 `部署` 作业。如果处理模式是 `最早优先`，它会从最旧流水线的作业开始执行，这意味着 `部署` 作业将紧接着执行。

然而，子流水线也需要来自 `production` 资源组的资源。由于子流水线比父流水线更新，它将等待 `部署` 作业完成，而这永远不会发生。

在这种情况下，你应该在父流水线配置中指定 `resource_group` 关键字：

```yaml
# 正确的做法
测试:
  stage: test
  trigger:
    include: child-pipeline.yml
    strategy: mirror
  resource_group: production # 在父流水线中指定资源组

部署:
  stage: deploy
  script: echo
  resource_group: production
  environment: production
```

<a id="jobs-get-stuck-in-waiting-for-resource"></a>

### 作业卡在“等待资源”状态

有时，作业会挂起并显示消息 `等待资源：<resource_group>`。要解决此问题，请先检查资源组是否正常工作：

1. 进入作业详情页面。
1. 如果资源已分配给某个作业，请选择 **查看当前使用资源的作业** 并检查作业状态。

   - 如果状态为 `running` 或 `pending`，表示该功能正常工作。请等待作业完成并释放资源。
   - 如果状态为 `created` 且[处理模式](#process-modes) 是 **最早优先** 或 **最新优先**，表示该功能正常工作。访问该作业的流水线页面，检查是哪个上游阶段或作业阻塞了执行。
   - 如果以上条件都不满足，则该功能可能未正常工作。请向极狐GitLab 报告问题。

1. 如果 **查看当前使用资源的作业** 不可用，表示资源未分配给任何作业。请改为检查资源的待处理作业。

   1. 使用 [REST API](../../api/resource_groups.md#list-upcoming-jobs-for-a-specific-resource-group) 获取资源的待处理作业。
   1. 确认资源组的[处理模式](#process-modes) 是 **最早优先**。
   1. 在待处理作业列表中找到第一个作业，并[通过 GraphQL 获取作业详情](#get-job-details-through-graphql)。
   1. 如果第一个作业所在的流水线是较旧的流水线，请尝试取消该流水线或该作业本身。
   1. 可选。如果下一个待处理作业仍然位于一个不应再运行的较旧流水线中，请重复此过程。
   1. 如果问题持续，请向极狐GitLab 报告问题。

<a id="race-conditions-in-complex-or-busy-pipelines"></a>

#### 复杂或繁忙流水线中的竞态条件

如果你无法用上述方法解决问题，则可能遇到了已知的竞态条件问题。该竞态条件出现在复杂或繁忙的流水线中。例如，如果你有以下情况，则可能遇到该问题：

- 具有多个子流水线的流水线。
- 单个项目中同时运行多个流水线。

如果你认为自己遇到了此问题，请向极狐GitLab 报告问题。

作为临时解决方法，你可以：

- 启动新的流水线。
- 重新运行一个已完成的、与卡住作业具有相同资源组的作业。

  例如，如果你有一个 `setup_job` 和一个 `deploy_job`，它们使用相同的资源组，`setup_job` 可能已完成，而 `deploy_job` 卡在 `等待资源` 状态。重新运行 `setup_job` 将重启整个过程，从而允许 `deploy_job` 完成。

<a id="get-job-details-through-graphql"></a>

#### 通过 GraphQL 获取作业详情

你可以从 GraphQL API 获取作业信息。如果你使用了[跨项目/父子流水线的流水线级别并发控制](#pipeline-level-concurrency-control-with-cross-projectparent-child-pipelines)，由于触发器作业无法在 UI 中访问，因此应使用 GraphQL API。

要通过 GraphQL API 获取作业信息：

1. 进入流水线详情页面。
1. 选择 **作业** 选项卡，找到卡住作业的 ID。
1. 进入[交互式 GraphQL 浏览器](../../api/graphql/_index.md#interactive-graphql-explorer)。
1. 运行以下查询：

   ```graphql
   {
     project(fullPath: "<fullpath-to-your-project>") {
       name
       job(id: "gid://gitlab/Ci::Build/<job-id>") {
         name
         status
         detailedStatus {
           action {
             path
             buttonTitle
           }
         }
       }
     }
   }
   ```

    `job.detailedStatus.action.path` 字段包含正在使用该资源的作业 ID。

1. 运行以下查询，并根据上述标准检查 `job.status` 字段。你也可以通过 `pipeline.path` 字段访问流水线页面。

   ```graphql
   {
     project(fullPath: "<fullpath-to-your-project>") {
       name
       job(id: "gid://gitlab/Ci::Build/<job-id-currently-using-the-resource>") {
         name
         status
         pipeline {
           path
         }
       }
     }
   }
   ```