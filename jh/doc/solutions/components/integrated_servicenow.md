---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
title: 集成变更管理 - ServiceNow
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- ServiceNow Version: 最新版，Xanadu 及向前兼容旧版本

{{< /details >}}

本文档提供了极狐GitLab 使用 ServiceNow DevOps Change Velocity 编排与 ServiceNow 集成的变更管理的说明和功能细节。

通过 ServiceNow DevOps Change Velocity 集成，可以在 ServiceNow 中跟踪极狐GitLab 仓库和 CI/CD 流水线中的活动信息。

当与极狐GitLab CI/CD 流水线集成时，它会自动创建变更请求，并根据策略条件自动批准变更请求。

本文档将展示如何：

1. 使用 Change Velocity 将 ServiceNow 与极狐GitLab 集成以进行变更管理，
1. 在极狐GitLab CI/CD 流水线中自动在 ServiceNow 中创建变更请求，
1. 如果变更请求需要 CAB 审核和批准，则在 ServiceNow 中批准它，
1. 根据变更请求的批准开始生产部署。

<a id="getting-started"></a>

## 入门

<a id="download-the-solution-component"></a>

### 下载解决方案组件

1. 从您的客户团队获取邀请码。
1. 使用邀请码从[解决方案组件商城](https://cloud.gitlab-accelerator-marketplace.com)下载解决方案组件。

<a id="integration-options-for-change-management"></a>

## 变更管理的集成选项

有多种方式可以将极狐GitLab 与 ServiceNow 集成。本解决方案组件提供了以下选项：

1. 用于内置变更请求流程的 ServiceNow DevOps Change Velocity
1. 使用 Velocity 容器镜像的自定义变更请求的 ServiceNow DevOps Change Velocity
1. 用于自定义变更请求流程的 ServiceNow Rest API

<a id="servicenow-devops-change-velocity"></a>

## ServiceNow DevOps Change Velocity

从 ServiceNow 商店安装并配置 DevOps Change Velocity 后，可以直接在 DevOps Change Workspace 中通过自动创建变更来启用变更控制。

<a id="built-in-change-request-process"></a>

### 内置变更请求流程

ServiceNow DevOps Change Velocity 为正常变更流程提供了内置的变更请求模型，并且自动创建的变更请求具有默认的命名约定。

正常变更流程要求变更请求在部署到生产环境的流水线作业之前获得批准。

<a id="setup-the-pipeline-and-change-request-jobs"></a>

#### 设置流水线和变更请求作业

使用解决方案仓库中的 `gitlab-ci-workflow1.yml` 示例流水线作为起点。
请查看以下步骤以启用自动变更创建并通过流水线传递变更属性。

> [!note]
> 有关更详细的说明，请参见[自动执行 DevOps 变更请求创建](https://www.servicenow.com/docs/bundle/yokohama-it-service-management/page/product/enterprise-dev-ops/task/automate-devops-change-request.html)。

以下是高层次步骤：

1. 在 DevOps Change Workspace 中，导航到 Change 选项卡，然后选择 Automate change。

   ![选择了 Automate change 选项的 DevOps Change Workspace。](img/snow_automate_cr_creation_v17_9.png)
1. 在 Application 字段中，选择要与要自动创建变更请求的流水线关联的应用程序，然后选择 Next。
1. 选择包含要从中触发自动创建变更请求的步骤（阶段）的流水线。例如，变更请求创建步骤。
1. 在流水线中选择要从中触发自动创建变更请求的步骤。
1. 在变更字段中指定变更属性，并通过选择 Change receipt 选项来启用变更回执。
1. 修改您的流水线，并使用相应的代码片段来启用变更控制并指定变更属性。例如，在启用了变更控制的作业中添加以下两个配置：

   ```yaml
      when: manual
      allow_failure: false
   ```

    ![更新以支持变更控制的极狐GitLab CI/CD 流水线作业。](img/snow_automated_cr_pipeline_update_v17_9.png)

<a id="run-pipeline-with-change-management"></a>

#### 使用变更管理运行流水线

完成上述步骤后，项目 CD 流水线就可以包含 `gitlab-ci-workflow1.yml` 示例流水线中所示的作业。

要使用变更管理运行流水线：

1. 在 ServiceNow 中，为流水线中的某个阶段启用了变更控制。

   ![流水线中启用了变更控制的 ServiceNow 阶段。](img/snow_change_control_enabled_v17_9.png)
1. 在极狐GitLab 中，带有变更控制功能的流水线作业正在运行。

   ![等待变更批准的极狐GitLab 流水线。](img/snow_pipeline_pause_for_approval_v17_9.png)
1. 在 ServiceNow 中，会自动创建一个变更请求。

   ![等待批准的 ServiceNow 变更请求。](img/snow_cr_waiting_for_approval_v17_9.png)
1. 在 ServiceNow 中，批准变更请求。

   ![标记为已批准的 ServiceNow 变更请求。](img/snow_cr_approved_v17_9.png)
1. 变更请求获得批准后，流水线恢复并开始下一个作业，即部署到生产环境。

   ![变更批准后极狐GitLab 流水线恢复。](img/snow_pipeline_resumes_v17_9.png)

<a id="custom-actions-with-velocity-container-image"></a>

### 使用 Velocity 容器镜像的自定义操作

通过 DevOps Change Velocity Docker 镜像使用 ServiceNow 自定义操作，可以设置变更请求标题、描述、变更计划、回滚计划以及要部署的产物数据和软件包注册。这允许您自定义变更请求描述，而不是将流水线元数据作为变更请求描述传递。

<a id="setup-the-pipeline-and-change-request-jobs-1"></a>

#### 设置流水线和变更请求作业

这是 ServiceNow DevOps Change Velocity 的附加功能，因此前面的设置步骤是相同的。您只需要在流水线定义中包含 Docker 镜像。

使用此仓库中的 `gitlab-ci-workflow2.yml` 示例流水线作为示例。

1. 指定要在作业中使用的镜像。根据需要更新镜像版本。

   ```yaml
      image: servicenowdocker/sndevops:5.0.0
   ```

1. 使用 CLI 执行特定操作。例如，使用 sndevops CLI 创建变更请求：

   ```yaml
   sndevopscli create change -p {
        "changeStepDetails": {
          "timeout": 3600,
          "interval": 100
        },
        "autoCloseChange": true,
        "attributes": {
          "short_description": "'"${CHANGE_REQUEST_SHORT_DESCRIPTION}"'",
          "description": "'"${CHANGE_REQUEST_DESCRIPTION}"'",
          "assignment_group": "'"${ASSIGNMENT_GROUP_ID}"'",
          "implementation_plan": "'"${CR_IMPLEMENTATION_PLAN}"'",
          "backout_plan": "'"${CR_BACKOUT_PLAN}"'",
          "test_plan": "'"${CR_TEST_PLAN}"'"
        }
      }

   ```

<a id="run-pipeline-with-custom-change-management"></a>

#### 使用自定义变更管理运行流水线

使用 `gitlab-ci-workflow2.yml` 示例流水线作为起点。
完成上述步骤后，项目 CD 流水线就可以包含 `gitlab-ci-workflow2.yml` 示例流水线中所示的作业。

要使用自定义变更管理运行流水线：

1. 在 ServiceNow 中，为流水线中的某个阶段启用了变更控制。

   ![使用 custom change flow 启用了变更控制的 ServiceNow 阶段。](img/snow_change_control_enabled_v17_9.png)
1. 在极狐GitLab 中，带有变更控制功能的流水线作业正在运行。

   ![change request creation workflow2](img/snow_cr_creation_workflow2_v17_9.png)
1. 在 ServiceNow 中，使用 `servicenowdocker/sndevops` 镜像，根据流水线变量值提供的自定义标题、描述和任何其他字段创建变更请求。

   ![使用流水线自定义值创建的 ServiceNow 变更请求。](img/snow_pipeline_workflow2_v17_9.png)
1. 在极狐GitLab 中，可以在流水线详细信息中找到变更请求编号和其他信息。流水线作业将保持运行状态，直到变更请求获得批准，然后才会继续执行下一个作业。

   ![审批后 workflow2 的流水线变更详细信息](img/snow_pipeline_details_workflow2_v17_9.png)
1. 在 ServiceNow 中，批准变更请求。

   ![pipeline details workflow2](img/snow_pipeline_cr_details_workflow2_v17_9.png)
1. 在极狐GitLab 中，变更请求获得批准后，流水线作业恢复并开始下一个作业，即部署到生产环境。

   ![pipeline resumes workflow2](img/snow_pipeline_resumes_workflow2_v17_9.png)