```markdown
---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Deploy a 极狐GitLab project to Amazon ECS. Containerize the application and set up continuous deployment, review apps, and security testing.
title: 部署到 Amazon Elastic Container Service
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

这份分步指南帮助你将托管在 JihuLab.com 上的项目部署到 Amazon [Elastic Container Service (ECS)](https://aws.amazon.com/ecs/)。

在本指南中，你首先使用 AWS 控制台手动创建一个 ECS 集群。你创建并部署一个从极狐GitLab 模板创建的简单应用程序。

这些说明适用于 JihuLab.com 和极狐GitLab 私有化部署实例。确保你的 [runners 已配置](../../runners/_index.md)。

<a id="prerequisites"></a>

## 先决条件

- 一个 [AWS 账户](https://repost.aws/knowledge-center/create-and-activate-aws-account)。使用现有 AWS 账户登录或创建一个新账户。
- 在本指南中，你在 [`us-east-2` 区域](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) 中创建基础设施。你可以使用任何区域，但开始后不要更改。

<a id="create-an-infrastructure-and-initial-deployment-on-aws"></a>

## 在 AWS 上创建基础设施和初始部署

要从极狐GitLab 部署应用程序，你必须首先在 AWS 上创建基础设施和初始部署。这包括一个 [ECS 集群](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/clusters.html) 和相关组件，例如 [ECS 任务定义](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html)、[ECS 服务](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) 和容器化应用程序镜像。

作为第一步，你从项目模板创建一个演示应用程序。

<a id="create-a-new-project-from-a-template"></a>

### 从模板创建新项目

使用极狐GitLab 项目模板开始。顾名思义，这些项目提供基于一些知名框架的极简应用程序。

1. 在右上角，选择 **创建新项目** ({{< icon name="plus" >}}) 和 **新建项目/仓库**。
1. 选择 **从模板创建**，你可以选择 Ruby on Rails、Spring 或 NodeJS Express 项目。在本指南中，使用 Ruby on Rails 模板。
1. 为你的项目命名。在此示例中，命名为 `ecs-demo`。将其设为公开，以便你可以利用 [极狐GitLab 旗舰版计划](https://gitlab.cn/pricing/) 中提供的功能。
1. 选择 **创建项目**。

现在你创建了一个演示项目，你必须将应用程序容器化并将其推送到容器镜像仓库。

<a id="push-a-containerized-application-image-to-gitlab-container-registry"></a>

### 将容器化应用程序镜像推送到极狐GitLab 容器镜像仓库

[ECS](https://aws.amazon.com/ecs/) 是一种容器编排服务，这意味着你必须在基础设施构建期间提供容器化应用程序镜像。为此，你可以使用极狐GitLab [Auto Build](../../../topics/autodevops/stages.md#auto-build) 和 [容器镜像仓库](../../../user/packages/container_registry/_index.md)。

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的 `ecs-demo` 项目。
1. 选择 **设置 CI/CD**。它会将你带到一个 `.gitlab-ci.yml` 创建表单。
1. 将以下内容复制并粘贴到空的 `.gitlab-ci.yml` 中。这定义了用于持续部署到 ECS 的流水线。

   ```yaml
   include:
     - template: AWS/Deploy-ECS.gitlab-ci.yml
   ```

1. 选择 **提交更改**。它会自动触发一个新的流水线。在此流水线中，`build` 作业将应用程序容器化并将镜像推送到 [极狐GitLab 容器镜像仓库](../../../user/packages/container_registry/_index.md)。

1. 访问 **部署** > **容器镜像仓库**。确保应用程序镜像已推送。

   ![极狐GitLab 容器镜像仓库中的容器化应用程序镜像。](img/registry_v13_10.png)

现在你有了一个可以从 AWS 拉取的容器化应用程序镜像。接下来，你定义如何在 AWS 中使用此应用程序镜像的规范。

`production_ecs` 作业失败，因为 ECS 集群尚未连接。你可以稍后修复此问题。

<a id="create-an-ecs-task-definition"></a>

### 创建 ECS 任务定义

[ECS 任务定义](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html) 是关于应用程序镜像如何由 [ECS 服务](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) 启动的规范。

1. 在 [AWS 控制台](https://aws.amazon.com/) 上，转到 **ECS** > **任务定义**。
1. 选择 **创建新的任务定义**。

   ![带有“创建新的任务定义”按钮的任务定义页面。](img/ecs-task-definitions_v13_10.png)

1. 选择 **EC2** 作为启动类型。选择 **下一步**。
1. 将 `ecs_demo` 设置为 **任务定义名称**。
1. 将 `512` 设置为 **任务大小** > **任务内存** 和 **任务 CPU**。
1. 选择 **容器定义** > **添加容器**。这将打开一个容器镜像仓库单。
1. 将 `web` 设置为 **容器名称**。
1. 将 `registry.jihulab.com/<your-namespace>/ecs-demo/master:latest` 设置为 **镜像**。或者，你可以从 [极狐GitLab 容器镜像仓库页面](#push-a-containerized-application-image-to-gitlab-container-registry) 复制并粘贴镜像路径。

   ![容器名称和镜像字段已完成。](img/container-name_v13_10.png)

1. 添加端口映射。将 `80` 设置为 **主机端口**，将 `5000` 设置为 **容器端口**。

   ![端口映射字段已完成。](img/container-port-mapping_v13_10.png)

1. 选择 **创建**。

现在你有了初始任务定义。接下来，你创建实际的基础设施来运行应用程序镜像。

<a id="create-an-ecs-cluster"></a>

### 创建 ECS 集群

[ECS 集群](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/clusters.html) 是 [ECS 服务](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) 的虚拟组。它还与 EC2 或 Fargate 作为计算资源相关联。

1. 在 [AWS 控制台](https://aws.amazon.com/) 上，转到 **ECS** > **集群**。
1. 选择 **创建集群**。
1. 选择 **EC2 Linux + Networking** 作为集群模板。选择 **下一步**。
1. 将 `ecs-demo` 设置为 **集群名称**。
1. 在 **网络** 中选择默认 [VPC](https://aws.amazon.com/vpc/?vpc-blogs.sort-by=item.additionalFields.createdDate&vpc-blogs.sort-order=desc)。如果没有现有的 VPC，你可以保持原样以创建新的。
1. 将 VPC 的所有可用子网设置为 **子网**。
1. 选择 **创建**。
1. 确保 ECS 集群已成功创建。

   ![ECS 集群已成功创建，所有实例正在运行。](img/ecs-launch-status_v13_10.png)

现在你可以在下一步中将 ECS 服务注册到 ECS 集群。

请注意以下几点：

- 你可以选择在创建表单中设置 SSH 密钥对。这允许你通过 SSH 连接到 EC2 实例进行调试。
- 如果你不选择现有的 VPC，它会默认创建一个新的 VPC。如果达到你账户上允许的最大互联网网关数量，这可能会导致错误。
- 集群需要 EC2 实例，这意味着它会 [根据实例类型](https://aws.amazon.com/ec2/pricing/on-demand/) 产生费用。

<a id="create-an-ecs-service"></a>

### 创建 ECS 服务

[ECS 服务](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) 是一个守护进程，用于基于 [ECS 任务定义](#create-an-ecs-task-definition) 创建应用程序容器。

1. 在 [AWS 控制台](https://aws.amazon.com/) 上，转到 **ECS** > **集群** > **ecs-demo** > **服务**。
1. 选择 **部署**。这将打开一个服务创建表单。
1. 在 **启动类型** 中选择 `EC2`。
1. 将 `ecs_demo` 设置为 **任务定义**。这对应于 [你之前创建的任务定义](#create-an-ecs-task-definition)。
1. 将 `ecs_demo` 设置为 **服务名称**。
1. 将 `1` 设置为 **所需任务数**。

   ![所有输入已完成的服务页面。](img/service-parameter_v13_10.png)

1. 选择 **部署**。
1. 确保创建的服务处于活动状态。

   ![一个正在运行任务的活动服务。](img/service-running_v13_10.png)

AWS 控制台 UI 会不时更改。如果你在说明中找不到相关组件，请选择最接近的一个。

<a id="view-the-demo-application"></a>

### 查看演示应用程序

现在，演示应用程序可以从互联网访问。

1. 在 [AWS 控制台](https://aws.amazon.com/) 上，转到 **EC2** > **实例**。
1. 搜索 `ECS Instance` 以找到 [ECS 集群创建的](#create-an-ecs-cluster) 相应 EC2 实例。
1. 选择 EC2 实例的 ID。这将带你进入实例详细信息页面。
1. 复制 **公有 IPv4 地址** 并将其粘贴到浏览器中。现在你可以看到演示应用程序正在运行。

   ![在浏览器中运行的演示应用程序。](img/view-running-app_v13_10.png)

在本指南中，**未** 配置 HTTPS/SSL。你只能通过 HTTP 访问应用程序（例如，`http://<ec2-ipv4-address>`）。

<a id="set-up-continuous-deployment-from-gitlab"></a>

## 从极狐GitLab 设置持续部署

现在你在 ECS 上运行了一个应用程序，你可以从极狐GitLab 设置持续部署。

<a id="create-a-new-iam-user-as-a-deployer"></a>

### 创建新的 IAM 用户作为部署者

为了让极狐GitLab 访问你之前创建的 ECS 集群、服务和任务定义，你必须在 AWS 上创建一个部署者用户：

1. 在 [AWS 控制台](https://aws.amazon.com/) 上，转到 **IAM** > **用户**。
1. 选择 **添加用户**。
1. 将 `ecs_demo` 设置为 **用户名**。
1. 启用 **编程访问** 复选框。选择 **下一步：权限**。
1. 在 **设置权限** 中选择 `直接附加现有策略`。
1. 从策略列表中选择 `AmazonECS_FullAccess`。选择 **下一步：标签** 和 **下一步：审核**。

   ![已选择的 `AmazonECS_FullAccess` 策略。](img/ecs-policy_v13_10.png)

1. 选择 **创建用户**。
1. 记下创建的用户的 **访问密钥 ID** 和 **秘密访问密钥**。

> [!note]
> 不要在公共场所共享秘密访问密钥。你必须将其保存在安全的地方。

<a id="setup-credentials-in-gitlab-to-let-pipeline-jobs-access-to-ecs"></a>

### 在极狐GitLab 中设置凭据以允许流水线作业访问 ECS

你可以在 [极狐GitLab CI/CD 变量](../../variables/_index.md) 中注册访问信息。这些变量会被注入到流水线作业中，并可以访问 ECS API。

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的 `ecs-demo` 项目。
1. 转到 **设置** > **CI/CD** > **变量**。
1. 选择 **添加变量** 并设置以下键值对。

   | 键                           | 值                                    | 备注 |
   |------------------------------|---------------------------------------|------|
   | `AWS_ACCESS_KEY_ID`          | `<部署者的访问密钥 ID>`                | 用于验证 `aws` CLI。 |
   | `AWS_SECRET_ACCESS_KEY`      | `<部署者的秘密访问密钥>`                | 用于验证 `aws` CLI。 |
   | `AWS_DEFAULT_REGION`         | `us-east-2`                           | 用于验证 `aws` CLI。 |
   | `CI_AWS_ECS_CLUSTER`         | `ecs-demo`                            | ECS 集群由 `production_ecs` 作业访问。 |
   | `CI_AWS_ECS_SERVICE`         | `ecs_demo`                            | 集群的 ECS 服务由 `production_ecs` 作业更新。确保此变量作用域为适当的环境（`production`、`staging`、`review/*`）。 |
   | `CI_AWS_ECS_TASK_DEFINITION` | `ecs_demo`                            | ECS 任务定义由 `production_ecs` 作业更新。 |

<a id="make-a-change-to-the-demo-application"></a>

### 对演示应用程序进行更改

更改项目中的文件，并查看它是否反映在 ECS 上的演示应用程序中：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的 `ecs-demo` 项目。
1. 打开 `app/views/welcome/index.html.erb` 文件。
1. 选择 **编辑**。
1. 将文本更改为 `You're on ECS!`。
1. 选择 **提交更改**。这会自动触发一个新的流水线。等待它完成。
1. [访问 ECS 集群上运行的应用程序](#view-the-demo-application)。你应该会看到：

   ![在 ECS 上运行的应用程序，带有确认消息。](img/view-running-app-2_v13_10.png)

恭喜！你成功设置了持续部署到 ECS。

> [!note]
> ECS 部署作业在退出前等待部署完成。要禁用此行为，请将 `CI_AWS_ECS_WAIT_FOR_ROLLOUT_COMPLETE_DISABLED` 设置为非空值。

<a id="set-up-review-apps"></a>

## 设置审查应用

要在 ECS 中使用审查应用：

1. 设置一个新的 [服务](#create-an-ecs-service)。
1. 使用 `CI_AWS_ECS_SERVICE` 变量设置名称。
1. 将环境作用域设置为 `review/*`。

一次只能部署一个审查应用，因为此服务由所有审查应用共享。

<a id="set-up-security-testing"></a>

## 设置安全测试

<a id="configure-sast"></a>

### 配置 SAST

要在 ECS 中使用 [SAST](../../../user/application_security/sast/_index.md)，请将以下内容添加到你的 `.gitlab-ci.yml` 文件中：

```yaml
include:
   - template: Jobs/SAST.gitlab-ci.yml
```

有关更多详细信息和配置选项，请参阅 [SAST 文档](../../../user/application_security/sast/_index.md#configuration)。

<a id="configure-dast"></a>

### 配置 DAST

要在非默认分支上使用 [DAST](../../../user/application_security/dast/_index.md)，请 [设置审查应用](#set-up-review-apps) 并将以下内容添加到你的 `.gitlab-ci.yml` 文件中：

```yaml
include:
  - template: Security/DAST.gitlab-ci.yml
```

要在默认分支上使用 DAST：

1. 设置一个新的 [服务](#create-an-ecs-service)。此服务将用于部署临时 DAST 环境。
1. 使用 `CI_AWS_ECS_SERVICE` 变量设置名称。
1. 将作用域设置为 `dast-default` 环境。
1. 将以下内容添加到你的 `.gitlab-ci.yml` 文件中：

```yaml
include:
  - template: Security/DAST.gitlab-ci.yml
  - template: Jobs/DAST-Default-Branch-Deploy.gitlab-ci.yml
```

有关更多详细信息和配置选项，请参阅 [DAST 文档](../../../user/application_security/dast/_index.md)。

<a id="further-reading"></a>

## 延伸阅读

- 如果你对更多云的持续部署感兴趣，请参阅 [云部署](../_index.md)。
- 如果你想在项目中快速设置 DevSecOps，请参阅 [Auto DevOps](../../../topics/autodevops/_index.md)。
- 如果你想快速设置生产级环境，请参阅 [5 Minute Production App](https://jihulab.com/gitlab-org/5-minute-production-app/deploy-template/-/blob/master/README.md)。
```