---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Deploy applications from GitLab CI/CD to AWS, including ECS and EC2, by using GitLab-provided Docker images and CloudFormation templates.
title: 从极狐GitLab CI/CD 部署到 AWS
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 提供了包含部署到 AWS 所需库和工具的 Docker 镜像。您可以在 CI/CD 流水线中引用这些镜像。

如果您正在使用 JihuLab.com 并部署到 [Amazon 弹性容器服务](https://aws.amazon.com/ecs/) (ECS)，请阅读有关[部署到 ECS](ecs/deploy_to_aws_ecs.md) 的内容。

> [!note]
> 如果您能够自行配置部署，且只需要获取 AWS 凭证，请考虑使用 [ID 令牌和 OpenID Connect](../cloud_services/aws/_index.md)。ID 令牌比将凭证存储在 CI/CD 变量中更安全，但与本页指南不兼容。

<a id="authenticate-gitlab-with-aws"></a>

## 使用 AWS 认证极狐GitLab

要使用极狐GitLab CI/CD 连接到 AWS，您必须进行认证。认证设置完成后，您便可以配置 CI/CD 进行部署。

1. 登录您的 AWS 账户。
1. 创建[一个 IAM 用户](https://console.aws.amazon.com/iam/home#/home)。
1. 选择您的用户以访问其详细信息。进入 **安全凭证** > **创建新的访问密钥**。
1. 记下 **访问密钥 ID** 和 **秘密访问密钥**。
1. 在您的极狐GitLab 项目中，进入 **设置** > **CI/CD**。设置以下 [CI/CD 变量](../variables/_index.md)：

   | 环境变量名称               | 值                 |
   |:--------------------------|:-------------------|
   | `AWS_ACCESS_KEY_ID`       | 您的访问密钥 ID。   |
   | `AWS_SECRET_ACCESS_KEY`   | 您的秘密访问密钥。   |
   | `AWS_DEFAULT_REGION`      | 您的区域代码。您可能需要确认您打算使用的 AWS 服务在[所选区域中是否可用](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/)。 |

1. 变量默认是[受保护的](../variables/_index.md#protect-a-cicd-variable)。要对不受保护的分支或标签使用极狐GitLab CI/CD，请取消选中 **保护变量** 复选框。

<a id="use-an-image-to-run-aws-commands"></a>

## 使用镜像运行 AWS 命令

如果某个镜像包含 [AWS 命令行界面](https://aws.amazon.com/cli/)，您可以在项目的 `.gitlab-ci.yml` 文件中引用该镜像。然后，您便可以在 CI/CD 作业中运行 `aws` 命令。

例如：

```yaml
deploy:
  stage: deploy
  image: registry.gitlab.com/gitlab-org/cloud-deploy/aws-base:latest
  script:
    - aws s3 ...
    - aws create-deployment ...
  environment: production
```

极狐GitLab 提供了一个包含 AWS CLI 的 Docker 镜像：

- 镜像托管在极狐GitLab 容器镜像仓库中。最新镜像是 `registry.gitlab.com/gitlab-org/cloud-deploy/aws-base:latest`。
- [镜像存储在极狐GitLab 仓库中](https://jihulab.com/gitlab-cn/cloud-deploy/-/tree/master/aws)。

或者，您也可以使用 [Amazon 弹性容器镜像仓库 (ECR)](https://aws.amazon.com/ecr/) 中的镜像。[了解如何将镜像推送到您的 ECR 仓库中](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)。

您也可以使用任何第三方镜像仓库中的镜像。

<a id="deploy-your-application-to-ecs"></a>

## 将应用部署到 ECS

您可以自动将应用部署到您的 [Amazon ECS](https://aws.amazon.com/ecs/) 集群中。

前提条件：

- [使用 AWS 认证极狐GitLab](#authenticate-gitlab-with-aws)。
- 在 Amazon ECS 上创建集群。
- 创建相关组件，例如 ECS 服务或 Amazon RDS 上的数据库。
- 创建 ECS 任务定义，其中 `containerDefinitions[].name` 属性的值与目标 ECS 服务中定义的 `Container name` 相同。任务定义可以是：
  - ECS 中已有的任务定义。
  - 极狐GitLab 项目中的 JSON 文件。使用 [AWS 文档中的模板](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-task-definition.html#task-definition-template) 并将文件保存在项目中。例如 `<project-root>/ci/aws/task-definition.json`。

要部署到您的 ECS 集群：

1. 在您的极狐GitLab 项目中，进入 **设置** > **CI/CD**。设置以下 [CI/CD 变量](../variables/_index.md)。您可以在 [Amazon ECS 控制台](https://console.aws.amazon.com/ecs/home)上选择目标集群来找到这些名称。

   | 环境变量名称                        | 值                   |
   |:----------------------------------|:---------------------|
   | `CI_AWS_ECS_CLUSTER`              | 您部署所针对的 AWS ECS 集群的名称。 |
   | `CI_AWS_ECS_SERVICE`              | 与您的 AWS ECS 集群关联的目标服务的名称。确保将此变量限定在适当的环境（`production`、`staging`、`review/*`）内。 |
   | `CI_AWS_ECS_TASK_DEFINITION`      | 如果任务定义在 ECS 中，则为与服务关联的任务定义的名称。 |
   | `CI_AWS_ECS_TASK_DEFINITION_FILE` | 如果任务定义是极狐GitLab 中的 JSON 文件，则为包含路径的文件名。例如 `ci/aws/my_task_definition.json`。如果 JSON 文件中的任务定义名称与 ECS 中已有的任务定义名称相同，则在 CI/CD 运行时将创建一个新修订版本。否则，将创建一个全新的任务定义，从修订版本 1 开始。 |

   > [!warning]
   > 如果您同时定义了 `CI_AWS_ECS_TASK_DEFINITION_FILE` 和 `CI_AWS_ECS_TASK_DEFINITION`，则 `CI_AWS_ECS_TASK_DEFINITION_FILE` 优先。

1. 在 `.gitlab-ci.yml` 中包含此模板：

   ```yaml
   include:
     - template: AWS/Deploy-ECS.gitlab-ci.yml
   ```

   `AWS/Deploy-ECS` 模板随极狐GitLab 提供，并可在 [JihuLab.com](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/AWS/Deploy-ECS.gitlab-ci.yml) 上获取。

1. 提交并推送更新后的 `.gitlab-ci.yml` 到您的项目仓库。

您的应用 Docker 镜像将被重新构建并推送到极狐GitLab 容器镜像仓库中。如果您的镜像位于私有镜像仓库中，请确保您的任务定义已[配置了 `repositoryCredentials` 属性](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html)。

目标任务定义将使用新 Docker 镜像的位置进行更新，并在 ECS 中创建一个新修订版本。

最后，您的 AWS ECS 服务将使用任务定义的新修订版本进行更新，从而使集群拉取您应用的最新版本。

ECS 部署作业会在退出前等待发布完成。要禁用此行为，请将 `CI_AWS_ECS_WAIT_FOR_ROLLOUT_COMPLETE_DISABLED` 设置为非空值。

> [!warning]
> [`AWS/Deploy-ECS.gitlab-ci.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/AWS/Deploy-ECS.gitlab-ci.yml) 模板包含两个模板：[`Jobs/Build.gitlab-ci.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Build.gitlab-ci.yml) 和 [`Jobs/Deploy/ECS.gitlab-ci.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Deploy/ECS.gitlab-ci.yml)。请勿单独包含这些模板。仅包含 `AWS/Deploy-ECS.gitlab-ci.yml` 模板。这些其他模板设计为仅与主模板一起使用。它们可能会意外移动或更改。此外，这些模板中的作业名称可能会更改。请勿在您自己的流水线中覆盖这些作业名称，因为当名称更改时覆盖会失效。

<a id="deploy-your-application-to-ec2"></a>

## 将应用部署到 EC2

极狐GitLab 提供了一个名为 `AWS/CF-Provision-and-Deploy-EC2` 的模板，以帮助您部署到 Amazon EC2。

当您配置相关的 JSON 对象并使用该模板时，流水线会：

1. **创建堆栈**：通过使用 [AWS CloudFormation](https://aws.amazon.com/cloudformation/) API 预置您的基础设施。
1. **推送到 S3 存储桶**：当您的构建运行时，它会创建一个制品。该制品被推送到一个 [AWS S3](https://aws.amazon.com/s3/) 存储桶中。
1. **部署到 EC2**：内容部署到 [AWS EC2](https://aws.amazon.com/ec2/) 实例上，如下图所示：

![展示 CF-Provision-and-Deploy-EC2 流水线，包括预置基础设施、将制品推送到 S3 以及部署到 EC2 的步骤。](img/cf_ec2_diagram_v13_5.png)

<a id="configure-the-template-and-json"></a>

### 配置模板和 JSON

要部署到 EC2，请完成以下步骤。

1. 为您的堆栈创建 JSON。使用 [AWS 模板](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-anatomy.html)。
1. 创建要推送到 S3 的 JSON。包含以下详细信息。

   ```json
   {
     "applicationName": "string",
     "source": "string",
     "s3Location": "s3://your/bucket/project_built_file...]"
   }
   ```

   `source` 是 `build` 作业构建您应用的位置。构建产物会保存到 [`artifacts:paths`](../yaml/_index.md#artifactspaths)。

1. 创建部署到 EC2 的 JSON。使用 [AWS 模板](https://docs.aws.amazon.com/codedeploy/latest/APIReference/API_CreateDeployment.html)。
1. 让您的流水线能够访问这些 JSON 对象：
   - 如果您希望将这些 JSON 对象保存在代码仓库中，请将它们保存为三个单独的文件。

     在您的 `.gitlab-ci.yml` 文件中，添加指向相对于项目根目录的文件路径的 [CI/CD 变量](../variables/_index.md)。例如，如果您的 JSON 文件位于 `<project_root>/aws` 文件夹中：

     ```yaml
     variables:
       CI_AWS_CF_CREATE_STACK_FILE: 'aws/cf_create_stack.json'
       CI_AWS_S3_PUSH_FILE: 'aws/s3_push.json'
       CI_AWS_EC2_DEPLOYMENT_FILE: 'aws/create_deployment.json'
     ```

   - 如果您不希望将这些 JSON 对象保存在代码仓库中，请在项目设置中将每个对象添加为单独的[文件类型 CI/CD 变量](../variables/_index.md#use-file-type-cicd-variables)。使用与之前相同的变量名。

1. 在您的 `.gitlab-ci.yml` 文件中，为堆栈名称创建一个 CI/CD 变量。例如：

   ```yaml
   variables:
     CI_AWS_CF_STACK_NAME: 'YourStackName'
   ```

1. 在您的 `.gitlab-ci.yml` 文件中，添加 CI 模板：

   ```yaml
   include:
     - template: AWS/CF-Provision-and-Deploy-EC2.gitlab-ci.yml
   ```

1. 运行流水线。

   - 您的 AWS CloudFormation 堆栈将根据 `CI_AWS_CF_CREATE_STACK_FILE` 变量的内容创建。如果您的堆栈已存在，则跳过此步骤，但其所属的 `provision` 作业仍会运行。
   - 您构建的应用随后将被推送到 S3 存储桶，然后根据相关 JSON 对象的内容部署到您的 EC2 实例上。当 EC2 的部署完成或失败时，部署作业结束。

<a id="troubleshooting"></a>

## 故障排查

<a id="error-ascii-codec-cant-encode-character-uxxxx"></a>

### 错误 `'ascii' codec can't encode character '\uxxxx'`

当 Cloud Deploy 镜像使用的 `aws-cli` 工具的响应包含 Unicode 字符时，可能会出现此错误。Cloud Deploy 镜像没有定义的区域设置，默认使用 ASCII。要解决此错误，请添加以下 CI/CD 变量：

```yaml
variables:
  LANG: "UTF-8"
```