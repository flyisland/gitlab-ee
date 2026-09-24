---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
description: Integrations Solutions Index for GitLab and AWS.
title: 与 AWS 集成
---

了解如何将极狐GitLab 与 AWS 集成。

本内容适用于极狐GitLab 团队成员以及广大社区成员。

除非另有说明，本内容适用于 JihuLab.com 和私有化部署实例。

极狐GitLab 通过通用配置、任一平台的内置功能以及专用解决方案与 AWS 集成。

| 文本标签                 | 配置/内置/解决方案                             | 支持/维护状态                                          |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `[AWS Configuration]`    | 通过配置现有 AWS 功能进行集成       | AWS                                                          |
| `[GitLab Configuration]` | 通过配置现有极狐GitLab 功能进行集成    | 极狐GitLab                                                       |
| `[AWS Built]`            | 由 AWS 产品团队为满足 AWS 集成需求而内置于 AWS | AWS                                                          |
| `[GitLab Built]`         | 由极狐GitLab 产品团队为满足 AWS 集成需求而内置于极狐GitLab | 极狐GitLab                                                       |
| `[AWS Solution]`         | 由 AWS 或 AWS 合作伙伴构建的解决方案示例             | 社区/示例                                            |
| `[GitLab Solution]`      | 由极狐GitLab 或极狐GitLab 合作伙伴构建的解决方案示例       | 社区/示例                                            |
| `[CI Solution]`          | 至少部分使用极狐GitLab CI 构建，因此<br />客户可进一步自定义。 | 标记为 `[CI Solution]` 的项目会<br />同时带有指示维护状态的其他标签<br />。 |

<a id="integrations-for-development-activities"></a>

## 开发活动的集成

这些集成与使用极狐GitLab 构建应用程序工作负载并将其部署到 AWS 有关。

<a id="scm-integrations"></a>

### SCM 集成

<a id="aws-codestar-connection-integrations"></a>

#### AWS CodeStar Connection 集成

[8/14/2023 AWS 发布公告，适用于 GitLab.com](https://aws.amazon.com/about-aws/whats-new/2023/08/aws-codepipeline-supports-gitlab/)

[12/28/2023 AWS 发布公告，适用于私有化部署](https://aws.amazon.com/about-aws/whats-new/2023/12/codepipeline-gitlab-self-managed/)

**AWS CodeStar Connections** - 支持与多个 AWS 服务的 SCM 连接。
[配置极狐GitLab](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-create-gitlab.html)。
[支持的提供者](https://docs.aws.amazon.com/dtconsole/latest/userguide/supported-versions-connections.html)。
[支持的 AWS 服务](https://docs.aws.amazon.com/dtconsole/latest/userguide/integrations-connections.html) -
每个服务可能需要更新才能支持极狐GitLab，因此以下列出了支持极狐GitLab 的子集。适用于 JihuLab.com、极狐GitLab 私有化部署。AWS CodeStar 连接并非在所有 AWS 区域都可用，排除列表
[记录在此](https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodestarConnectionSource.html)。
（[12/28/2023](https://aws.amazon.com/about-aws/whats-new/2023/12/codepipeline-gitlab-self-managed/)）`[AWS Built]`

AWS 账户中直接支持 CodeStar Connection 的 AWS 服务：

- **AWS Service Catalog** 直接继承 CodeStar Connections，没有关于极狐GitLab 的具体文档，因为它直接使用账户中创建的任何极狐GitLab CodeStar Connection。([12/28/2023](https://aws.amazon.com/about-aws/whats-new/2023/12/codepipeline-gitlab-self-managed/)) `[AWS Built]`
- **AWS Proton** 直接继承 CodeStar Connections，没有关于极狐GitLab 的具体文档，因为它直接使用账户中创建的任何极狐GitLab CodeStar Connection。([12/28/2023](https://aws.amazon.com/about-aws/whats-new/2023/12/codepipeline-gitlab-self-managed/)) `[AWS Built]`
- **AWS CodeBuild** - [适用于 JihuLab.com、私有化部署 - 点击此处文档标签页](https://docs.aws.amazon.com/codebuild/latest/userguide/create-project-console.html#create-project-console-source)。（[03/26/2024](https://aws.amazon.com/about-aws/whats-new/2024/03/aws-codebuild-gitlab-gitlab-self-managed/)）`[AWS Built]`

文档和参考：

- [创建与 JihuLab.com 项目的极狐GitLab CodeStar Connection](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-gitlab-managed.html)
- [为极狐GitLab 私有化部署创建 AWS CodeStar Connection](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-gitlab-managed.html)（必须允许来自 AWS 的互联网入口或使用 VPC 连接）

<a id="aws-codepipeline-integrations"></a>

#### AWS CodePipeline 集成

[AWS CodePipeline 集成](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-gitlab.html) - 通过将极狐GitLab 用作 CodeStar Connections 的 CodePipeline 源，可使用更多 AWS 服务集成。([12/28/2023](https://aws.amazon.com/about-aws/whats-new/2023/12/codepipeline-gitlab-self-managed/)) `[AWS Built]`

通过 AWS CodePipeline 集成支持的 AWS 服务：

- **Amazon SageMaker MLOps 项目** 通过 CodePipeline 创建（[如这里所述](https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-projects-walkthrough-3rdgit.html#sagemaker-proejcts-walkthrough-connect-3rdgit)），没有关于极狐GitLab 的具体文档，因为它直接使用账户中创建的任何极狐GitLab CodeStar Connection。([12/28/2023](https://aws.amazon.com/about-aws/whats-new/2023/12/codepipeline-gitlab-self-managed/)) `[AWS Built]`

文档和参考：

- [创建与 JihuLab.com 项目的极狐GitLab CodePipeline 集成](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-gitlab-managed.html)
- [为极狐GitLab 私有化部署创建 AWS CodePipeline 集成](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-gitlab-managed.html)（必须允许来自 AWS 的互联网入口或使用 VPC 连接）

<a id="codestar-connections-enabled-aws-services-that-are-not-yet-supported-for-gitlab"></a>

#### CodeStar Connections 已支持但尚未支持极狐GitLab 的 AWS 服务

- **AWS CloudFormation** 公共扩展发布 - 尚未支持。`[AWS Built]`
- **Amazon CodeGuru Reviewer Repositories** - 尚未支持。`[AWS Built]`
- **AWS App Runner** - 尚未支持。`[AWS Built]`

<a id="custom-gitlab-integration-in-aws-services"></a>

#### AWS 服务中的自定义极狐GitLab 集成

- **Amazon SageMaker Notebooks** [允许通过 Git 克隆 URL 指定 Git 仓库](https://docs.aws.amazon.com/sagemaker/latest/dg/nbi-git-resource.html)并配置密钥 - 因此极狐GitLab 是可配置的。([12/28/2023](https://aws.amazon.com/about-aws/whats-new/2023/12/codepipeline-gitlab-self-managed/)) `[AWS Configuration]`
- **AWS Amplify** - [使用由 AWS Amplify 团队设计的 Git 集成机制](https://docs.aws.amazon.com/amplify/latest/userguide/getting-started.html)。`[AWS Built]`
- **AWS Glue Notebook 作业** 在“作业”级别支持通过个人访问令牌（PAT）认证的极狐GitLab 仓库 URL。([10/03/2022](https://aws.amazon.com/about-aws/whats-new/2022/10/aws-glue-git-integration/)) [关于配置极狐GitLab 的 AWS 文档](https://docs.aws.amazon.com/glue/latest/dg/edit-job-add-source-control-integration.html) `[AWS Configuration]`

<a id="other-scm-integration-options"></a>

#### 其他 SCM 集成选项

- [从极狐GitLab 推送到 CodeCommit 的镜像](../../../user/project/repository/mirror/push.md#set-up-a-push-mirror-from-gitlab-to-aws-codecommit) 变通方法使得极狐GitLab 仓库能够利用 CodePipeline SCM 触发器。极狐GitLab 已经可以利用 S3 和容器触发器进行 CodePipeline。自记录以来，此变通方法启用了 CodePipeline 功能。（06/06/2020）`[GitLab Configuration]`

请参阅下方的 [CD 和运维集成](#cd-and-operations-integrations)，了解可用的持续部署（CD）特定集成。

<a id="ci-integrations"></a>

### CI 集成

- **直接 CI 集成，使用密钥、IAM 或 OIDC/JWT 从极狐GitLab Runner 向 AWS 服务进行身份验证**
- **配合使用极狐GitLab CI 的 Amazon CodeGuru Reviewer CI 工作流** - 可以实现，但尚未记录。`[AWS Solution]` `[CI Solution]`
- [配合使用极狐GitLab CI 的 Amazon CodeGuru 安全扫描](https://docs.aws.amazon.com/codeguru/latest/security-ug/get-started-gitlab.html) （[06/13/2022](https://aws.amazon.com/about-aws/whats-new/2023/06/amazon-codeguru-security-available-preview/)）`[AWS Solution]` `[CI Solution]`

<a id="cd-and-operations-integrations"></a>

### CD 和运维集成

- **AWS CodeDeploy 集成** - 通过前面在 SCM 集成中讨论的 CodePipeline 支持。此功能允许极狐GitLab 对接 [AWS 中的高级部署子系统列表](https://docs.aws.amazon.com/codepipeline/latest/userguide/integrations-action-type.html#integrations-deploy)。([12/28/2023](https://aws.amazon.com/about-aws/whats-new/2023/12/codepipeline-gitlab-self-managed/)) `[AWS Built]`
- **AWS SAM Pipelines** - [对极狐GitLab 的流水线支持](https://aws.amazon.com/about-aws/whats-new/2021/07/simplify-ci-cd-configuration-serverless-applications-your-favorite-ci-cd-system-public-preview/)。（7/31/2021）
- [集成 EKS 集群进行应用部署](../../../user/infrastructure/clusters/connect/new_eks_cluster.md)。`[GitLab Built]`
- [极狐GitLab 将构建产物推送到 CodePipeline 监控的 S3 位置](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-about-starting.html#change-detection-methods) `[AWS Built]`
- [极狐GitLab 将容器推送到 CodePipeline 监控的 AWS ECR](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-about-starting.html#change-detection-methods) `[AWS Built]`
- [将 JihuLab.com 的容器镜像仓库通过 Pull-Through 缓存规则用作 AWS ECR 的上游注册表](https://docs.aws.amazon.com/AmazonECR/latest/userguide/pull-through-cache-creating-rule.html) [配置教程](tutorials/aws_ecr_pull_through_cache.md) `[AWS Built]`

<a id="end-to-end-solutions-for-development-and-deployment-of-specific-development-frameworks-or-ecosystems"></a>

## 针对特定开发框架或生态系统的端到端开发与部署解决方案

解决方案通常展示开发框架的端到端能力 - 利用所有相关集成技术，展现同时使用极狐GitLab 和 AWS 的最大价值。

<a id="serverless"></a>

### 无服务器

- [企业 DevOps 蓝图：AWS 上的 Serverless Framework 应用](https://gitlab.com/guided-explorations/aws/serverless/serverless-framework-aws) - 可运行的示例代码和教程。`[GitLab Solution]` `[CI Solution]`
  - [教程：使用极狐GitLab Serverless SAST 扫描将 Serverless Framework 部署到 AWS](https://gitlab.com/guided-explorations/aws/serverless/serverless-framework-aws/-/blob/master/TUTORIAL.md) `[GitLab Solution]` `[CI Solution]`
  - [教程：使用极狐GitLab 安全策略审批规则和托管 DevOps 环境进行安全的 Serverless Framework 开发](https://gitlab.com/guided-explorations/aws/serverless/serverless-framework-aws/-/blob/prod/TUTORIAL2-SecurityAndManagedEnvs.md?ref_type=heads) `[GitLab Solution]` `[CI Solution]`

<a id="terraform"></a>

### Terraform

- [企业 DevOps 蓝图：部署到 AWS 的 Terraform](https://gitlab.com/guided-explorations/aws/terraform/terraform-web-server-cluster)
  - [教程：使用极狐GitLab IaC SAST 扫描将 Terraform 部署到 AWS](https://gitlab.com/guided-explorations/aws/terraform/terraform-web-server-cluster/-/blob/prod/TUTORIAL.md) `[GitLab Solution]` `[CI Solution]`
  - [使用极狐GitLab 安全策略审批规则和托管 DevOps 环境将 Terraform 部署到 AWS](https://gitlab.com/guided-explorations/aws/terraform/terraform-web-server-cluster/-/blob/prod/TUTORIAL2-SecurityAndManagedEnvs.md) `[GitLab Solution]` `[CI Solution]`

<a id="cloudformation"></a>

### CloudFormation

[使用极狐GitLab 生命周期托管 DevOps 环境进行 CloudFormation 开发和部署的可运行代码](https://gitlab.com/guided-explorations/aws/cloudformation-deploy) `[GitLab Solution]` `[CI Solution]`

<a id="cdk"></a>

### CDK

- [在极狐GitLab 流水线中使用 AWS CDK 构建跨账户部署](https://aws.amazon.com/blogs/apn/building-cross-account-deployment-in-gitlab-pipelines-using-aws-cdk/) `[AWS Solution]` `[CI Solution]`

<a id="net-on-aws"></a>

### AWS 上的 .NET

- [在 AWS 上扩展 .NET Framework 4.x Runner 的可运行示例代码](https://gitlab.com/guided-explorations/aws/dotnet-aws-toolkit) `[GitLab Solution]` `[CI Solution]`

<a id="system-to-system-integration-of-gitlab-and-aws"></a>

## 极狐GitLab 和 AWS 的系统到系统集成

AWS 身份提供商（IDP）可配置为向极狐GitLab 进行身份验证，或者极狐GitLab 可作为 IDP 接入 AWS 账户。

JihuLab.com 上的顶级群组也称为“命名空间”，以公司名称命名是你在 JihuLab.com 上为组织设置租户的第一步。命名空间可配置特殊功能，如 SSO，从而将你的 IDP 集成到极狐GitLab。

<a id="user-authentication-and-authorization-between-gitlab-and-aws"></a>

### 极狐GitLab 和 AWS 之间的用户认证和授权

- [JihuLab.com 群组的 SAML SSO](../../../user/group/saml_sso/_index.md) `[GitLab Configuration]` - 仅限 JihuLab.com
- [将 LDAP 与极狐GitLab 集成](../../../administration/auth/ldap/_index.md) `[GitLab Configuration]` - 仅限私有化部署

<a id="runner-workload-authentication-and-authorization-integration"></a>

### Runner 工作负载认证和授权集成

- [使用 Open ID 和 JWT 认证的 Runner 作业认证](../../../ci/cloud_services/aws/_index.md)。`[GitLab Built]`
  - [在极狐GitLab 和 AWS 之间配置 OpenID Connect](https://gitlab.com/guided-explorations/aws/configure-openid-connect-in-aws) `[GitLab Solution]` `[CI Solution]`
  - [使用 OIDC 和 ECS 在极狐GitLab 中进行多账户部署](https://gitlab.com/guided-explorations/aws/oidc-and-multi-account-deployment-with-ecs) `[GitLab Solution]` `[CI Solution]`

<a id="gitlab-infrastructure-workloads-deployed-on-aws"></a>

## 部署在 AWS 上的极狐GitLab 基础架构工作负载

虽然极狐GitLab 可以部署在单台机器上支持最多 500 个用户，但当为 50,000 个用户这样的大规模进行水平扩展时，它将扩展为一个复杂、多层的平台，适合部署到 AWS。极狐GitLab 使用 AWS 服务作为后端时，既受支持又经过定期测试。极狐GitLab 可以部署到 EC2 进行传统扩展，也可以部署到 AWS EKS 实现云原生混合部署。之所以称为混合，是因为某些服务层由于 Git 的常见工作负载形状（以及 Git 进程如何处理这种负载多样性），无法放置在容器集群中。

<a id="gitlab-instance-compute--operations-integration"></a>

### 极狐GitLab 实例计算和运维集成

- 在 AWS 上安装极狐GitLab 私有化部署
  - [部署极狐GitLab 时可使用的 AWS 服务](gitlab_instance_on_aws.md)
  - 极狐GitLab 单 EC2 实例。`[GitLab Built]`
    - [使用 5 席位 AWS Marketplace 订阅](gitlab_single_box_on_aws.md#marketplace-subscription)
    - [使用预置的 AMI](gitlab_single_box_on_aws.md#official-gitlab-releases-as-amis) - 自带许可证的企业版。
  - 在 AWS EKS 和 PaaS 上进行极狐GitLab 云原生混合扩展。`[GitLab Built]`
    - [使用 GitLab Environment Toolkit (GET)](https://gitlab.com/gitlab-org/gitlab-environment-toolkit) - `[GitLab Solution]`
  - 在 AWS EC2 和 PaaS 上扩展极狐GitLab 实例。`[GitLab Built]`
    - [使用 GitLab Environment Toolkit (GET)](https://gitlab.com/gitlab-org/gitlab-environment-toolkit) - `[GitLab Solution]`
- [适用于极狐GitLab 私有化部署 Prometheus 指标的 Amazon Managed Grafana](https://docs.aws.amazon.com/grafana/latest/userguide/gitlab-AMG-datasource.html)。`[AWS Built]`

<a id="gitlab-runner-on-aws-compute"></a>

### AWS 计算上的极狐GitLab Runner

- [极狐GitLab Runner 自动扩缩器](https://docs.gitlab.com/runner/runner_autoscale/) - 由极狐GitLab Runner 团队构建的核心技术。`[GitLab Built]`
- [GitLab Runner Infrastructure Toolkit (GRIT)](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit) - 由极狐GitLab Runner 团队管理的代码化基础架构。部署极狐GitLab Runner 自动扩缩器等所需。`[GitLab Built]`
- [在 AWS EC2 上自动扩缩极狐GitLab Runner](https://docs.gitlab.com/runner/configuration/runner_autoscale_aws/)。`[GitLab Built]`
- [用于 AWS EC2 ASG 的极狐GitLab 高可用扩展 Runner Vending Machine](https://gitlab.com/guided-explorations/aws/gitlab-runner-autoscaling-aws-asg/)。`[GitLab Solution]`
  - Runner vending machine 培训资源。
- [极狐GitLab EKS Fargate Runners](https://gitlab.com/guided-explorations/aws/eks-runner-configs/gitlab-runner-eks-fargate/-/blob/main/README.md)。`[GitLab Solution]`