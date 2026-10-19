---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在极狐GitLab CI/CD 中控制作业并发
title: 资源组
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

默认情况下，极狐GitLab CI/CD 中的流水线会并发运行。并发是改善合并请求反馈循环的重要因素。不过，在某些情况下，您可能希望限制部署作业的并发，让它们逐个运行。使用资源组可以策略性地控制作业的并发，从而在保障安全的前提下优化您的持续部署工作流。

<a id="add-a-resource-group"></a>

## 添加资源组

一个资源组中只能添加一个资源。

假设您有以下流水线配置（代码仓库中的`.gitlab-ci.yml` 文件）：

```yaml
build:
  stage: build
  script: echo "Your build script"

deploy:
  stage: deploy
  script: echo "Your deployment script"
  environment: production
```

每次向分支推送新提交时，都会运行一条新的流水线，其中包含两个作业：`build` 和 `deploy`。但如果您在短时间内推送多个提交，多条流水线会同时开始运行，例如：

- 第一条流水线运行作业 `build` -> `deploy`
- 第二条流水线运行作业 `build` -> `deploy`

在这种情况下，不同流水线中的 `deploy` 作业可能会并发运行到 `production` 环境。向同一基础设施运行多个部署脚本可能会损害或干扰该实例，最坏情况下会使其处于损坏状态。

为确保 `deploy` 作业一次只运行一个，您可以为对并发敏感的作业指定 [`resource_group` 关键字](../yaml/_index.md#resource_group)：

```yaml
deploy:
  # ...
  resource_group: production
```

使用此配置，可以确保部署的安全性，同时您仍可以并发运行 `build` 作业，以最大化流水线效率。

<a id="prerequisites"></a>

## 先决条件

- 熟悉[极狐GitLab CI/CD 流水线](../pipelines/_index.md)
- 熟悉[极狐GitLab 环境和部署](../environments/_index.md)
- 拥有项目的开发者、维护者或所有者角色，以配置 CI/CD 流水线。

<a id="process-modes"></a>

## 处理模式

您可以选择一种处理模式，根据您的部署偏好来控制作业并发。支持以下模式：

| 处理模式 | 描述 | 使用场景  |
|---------------|-------------|-------------|
| `unordered` | 默认处理模式。只要作业准备好运行就处理该作业。 | 作业的执行顺序不重要。这是最简单的选项。 |
| `oldest_first` | 当资源空闲时，从按流水线 ID 升序排列的待运行作业列表中选取第一个作业。 | 您希望先执行来自最早流水线的作业。效率低于 `unordered` 模式，但对持续部署更安全。 |
| `newest_first` | 当资源空闲时，从按流水线 ID 降序排列的待运行作业列表中选取第一个作业。 | 您希望执行来自最新流水线的作业，并[防止过时的部署作业](../environments/deployment_safety.md#prevent-outdated-deployment-jobs)。每个作业必须是幂等的。 |
| `newest_ready_first` | 当资源空闲时，从等待该资源的待运行作业列表中选取第一个作业。作业按流水线 ID 降序排列。 | 您希望防止 `newest_first` 在部署当前流水线之前优先处理新的流水线。比 `newest_first` 更快。每个作业必须是幂等的。 |

<a id="change-the-process-mode"></a>

### 更改处理模式

要更改资源组的处理模式，您必须使用 API，并通过指定 `process_mode` 向[编辑现有资源组](../../api/resource_groups.md#update-a-resource-group)发送请求：

- `unordered`
- `oldest_first`
- `newest_first`
- `newest_ready_first`

<a id="an-example-of-the-difference-between-the-process-modes"></a>

### 处理模式差异示例

考虑以下 `.gitlab-ci.yml`，其中包含一个 `build` 作业和一个 `deploy` 作业。每个作业在各自的阶段中运行，且 `deploy` 作业的资源组设置为
`production`：

```yaml
build:
  stage: build
  script: echo "Your build script"

deploy:
  stage: deploy
  script: echo "Your deployment script"
  environment: production
  resource_group: production
```

如果在短时间内向项目推送了三个提交，这意味着三条流水线几乎同时运行：

- 第一条流水线运行作业 `build` -> `deploy`。我们称此部署作业为 `deploy-1`。
- 第二条流水线运行作业 `build` -> `deploy`。我们称此部署作业为 `deploy-2`。
- 第三条流水线运行作业 `build` -> `deploy`。我们称此部署作业为 `deploy-3`。

根据资源组的处理模式：

- 如果处理模式设置为 `unordered`：
  - `deploy-1`、`deploy-2` 和 `deploy-3` 不会并发运行。
  - 作业执行顺序没有保证，例如 `deploy-1` 可能在 `deploy-3` 运行之前或之后运行。
- 如果处理模式为 `oldest_first`：
  - `deploy-1`、`deploy-2` 和 `deploy-3` 不会并发运行。
  - `deploy-1` 最先运行，`deploy-2` 第二个运行，`deploy-3` 最后运行。
- 如果处理模式为 `newest_first`：
  - `deploy-1`、`deploy-2` 和 `deploy-3` 不会并发运行。
  - `deploy-3` 最先运行，`deploy-2` 第二个运行，`deploy-1` 最后运行。

<a id="pipeline-level-concurrency-control-with-cross-projectparent-child-pipelines"></a>

## 使用跨项目/父子流水线进行流水线级并发控制

您可以为对并发执行敏感的下游流水线定义 `resource_group`。[`trigger` 关键字](../yaml/_index.md#trigger)可以触发下游流水线，并且 [`resource_group` 关键字](../yaml/_index.md#resource_group)可以与之共存。`resource_group` 可以高效地控制部署流水线的并发，同时其他作业可以继续并发运行。

以下示例在一个项目中有两个流水线配置。当一条流水线开始运行时，非敏感作业会先执行，且不受其他流水线中并发执行的影响。不过，极狐GitLab 会确保在触发部署（子）流水线之前没有其他部署流水线正在运行。如果其他部署流水线正在运行，极狐GitLab 会等到这些流水线完成后再运行另一条。

```yaml
# .gitlab-ci.yml (parent pipeline)

build:
  stage: build
  script: echo "Building..."

test:
  stage: test
  script: echo "Testing..."

deploy:
  stage: deploy
  trigger:
    include: deploy.gitlab-ci.yml
    strategy: mirror
  resource_group: AWS-production
```

```yaml
# deploy.gitlab-ci.yml (child pipeline)

stages:
  - provision
  - deploy

provision:
  stage: provision
  script: echo "Provisioning..."

deployment:
  stage: deploy
  script: echo "Deploying..."
  environment: production
```

您必须定义 [`trigger:strategy`](../yaml/_index.md#triggerstrategy)，以确保在下游流水线完成之前不会释放锁。

<a id="troubleshooting"></a>

## 故障排除

<a id="avoid-dead-locks-in-pipeline-configurations"></a>

### 避免流水线配置中的死锁

由于 [`oldest_first` 处理模式](#process-modes)强制作业按流水线顺序执行，因此存在一种情况：它无法与其他 CI 功能很好地配合。

例如，当您运行[子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)且该子流水线需要与父流水线相同的资源组时，可能会发生死锁。以下是一个错误配置的示例：

```yaml
# BAD
test:
  stage: test
  trigger:
    include: child-pipeline-requires-production-resource-group.yml
    strategy: mirror

deploy:
  stage: deploy
  script: echo
  resource_group: production
  environment: production
```

在父流水线中，它运行 `test` 作业，该作业随后运行一条子流水线，而 [`strategy: mirror` 选项](../yaml/_index.md#triggerstrategy)会使 `test` 作业等待子流水线完成。父流水线在下一阶段运行 `deploy` 作业，该作业需要 `production` 资源组中的一个资源。如果处理模式为 `oldest_first`，它会从最早的流水线开始执行作业，这意味着接下来执行 `deploy` 作业。

然而，子流水线也需要 `production` 资源组中的一个资源。由于子流水线比父流水线更新，子流水线会等待 `deploy` 作业完成，而这是永远不会发生的。

在这种情况下，您应该在父流水线配置中改为指定 `resource_group` 关键字：

```yaml
# GOOD
test:
  stage: test
  trigger:
    include: child-pipeline.yml
    strategy: mirror
  resource_group: production # Specify the resource group in the parent pipeline

deploy:
  stage: deploy
  script: echo
  resource_group: production
  environment: production
```

<a id="jobs-get-stuck-in-waiting-for-resource"></a>

### 作业卡在 `Waiting for resource`

有时，作业会挂起并显示消息 `Waiting for resource: <resource_group>`。要解决此问题，请先检查资源组是否正常工作：

1. 转到作业详情页面。
1. 如果资源已分配给某个作业，请选择**查看当前使用资源的作业**并检查作业状态。

   - 如果状态为 `running` 或 `pending`，则功能正常。请等待作业完成并释放资源。
   - 如果状态为 `created` 且[处理模式](#process-modes)为 **最早在前** 或 **最新在前**，则功能正常。
     访问该作业的流水线页面，检查是哪个上游阶段或作业阻塞了执行。
   - 如果以上条件均不满足，则功能可能未正常工作。[向 GitLab 报告该问题](#report-an-issue)。

1. 如果**查看当前使用资源的作业**不可用，则资源未分配给任何作业。此时请检查该资源的待运行作业。

   1. 使用 [REST API](../../api/resource_groups.md#list-upcoming-jobs-for-a-specific-resource-group) 获取该资源的待运行作业。
   1. 确认该资源组的[处理模式](#process-modes)为 **最早在前**。
   1. 在待运行作业列表中找到第一个作业，并[使用 GraphQL](#get-job-details-through-graphql) 获取作业详情。
   1. 如果第一个作业的流水线是较旧的流水线，请尝试取消该流水线或该作业本身。
   1. 可选。如果下一个待运行作业仍处于不应再运行的较旧流水线中，请重复此过程。
   1. 如果问题仍然存在，请[向 GitLab 报告该问题](#report-an-issue)。

<a id="race-conditions-in-complex-or-busy-pipelines"></a>

#### 复杂或繁忙流水线中的竞态条件

如果上述解决方案无法解决您的问题，您可能遇到了已知的竞态条件问题。竞态条件会发生在复杂或繁忙的流水线中。例如，如果您有以下情况，可能会遇到竞态条件：

- 一条流水线包含多个子流水线。
- 单个项目同时运行多条流水线。

如果您认为自己遇到了此问题，请[向 GitLab 报告该问题](#report-an-issue)，并在[议题 436988](https://gitlab.com/gitlab-org/gitlab/-/issues/436988)中留言，附上您新议题的链接。为确认该问题，GitLab 可能会要求提供更多详细信息，例如您完整的流水线配置。

作为临时变通方法，您可以：

- 启动一条新的流水线。
- 重新运行一个已完成且与卡住的作业具有相同资源组的作业。

  例如，如果您有一个 `setup_job` 和一个具有相同资源组的 `deploy_job`，
  `setup_job` 可能已完成，而 `deploy_job` 卡在 `waiting for resource`。
  重新运行 `setup_job` 以重启整个流程，并让 `deploy_job`得以完成。

<a id="get-job-details-through-graphql"></a>

#### 通过 GraphQL 获取作业详情

您可以从 GraphQL API 获取作业信息。如果您使用[跨项目/父子流水线进行流水线级并发控制](#pipeline-level-concurrency-control-with-cross-projectparent-child-pipelines)，则应使用 GraphQL API，因为触发作业无法从 UI 访问。

要通过 GraphQL API 获取作业信息：

1. 转到流水线详情页面。
1. 选择**作业**标签页，找到卡住的作业的 ID。
1. 转到[交互式 GraphQL 浏览器](../../api/graphql/_index.md#interactive-graphql-explorer)。
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

   `job.detailedStatus.action.path` 字段包含使用该资源的作业 ID。

1. 运行以下查询，并根据上述标准检查 `job.status` 字段。您还可以从 `pipeline.path` 字段访问流水线页面。

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

<a id="report-an-issue"></a>

### 报告问题

[创建新议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/new)，并提供以下信息：

- 受影响作业的 ID。
- 作业状态。
- 问题发生的频率。
- 重现问题的步骤。

  您也可以[联系支持](https://gitlab.cn/support)以获取进一步帮助，或与开发团队取得联系。
