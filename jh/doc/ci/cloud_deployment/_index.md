---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用极狐GitLab 提供的 Docker 镜像和 CloudFormation 模板，将应用从极狐GitLab CI/CD 部署到 AWS，包括 ECS 和 EC2。
title: 从极狐GitLab CI/CD 部署到 AWS
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 提供包含部署到 AWS 所需库和工具的 Docker 镜像。您可以在 CI/CD 流水线中引用这些镜像。

如果您使用 JihuLab.com 并部署到 [Amazon Elastic Container Service](https://aws.amazon.com/ecs/) (ECS)，请阅读[部署到 ECS](ecs/deploy_to_aws_ecs.md)。

> [!note]
> 如果您能够自行配置部署，并且只需要获取 AWS 凭证，请考虑使用 [ID 令牌和 OpenID Connect](../cloud_services/aws/_index.md)。
> ID 令牌比将凭证存储在 CI/CD 变量中更安全，但不适用于本页面的指导内容。

<a id="authenticate-gitlab-with-aws"></a>

## 使用 AWS 对极狐GitLab 进行身份验证

要使用极狐GitLab CI/CD 连接到 AWS，您必须进行身份验证。设置身份验证后，您可以配置 CI/CD 进行部署。

1. 登录您的 AWS 账户。
1. 创建[一个 IAM 用户](https://console.aws.amazon.com/iam/home#/home)。
1. 选择您的用户以访问其详细信息。转到 **安全凭证** > **创建新的访问密钥**。
1. 记下 **访问密钥 ID** 和**秘密访问密钥**。
1. 在您的极狐GitLab 项目中，转到**设置** > **CI/CD**。设置以下
   [CI/CD 变量](../variables/_index.md)：

   | 环境变量名称 | 值 |
   |:--------------------------|:------|
   | `AWS_ACCESS_KEY_ID`       | 您的访问密钥 ID。 |
   | `AWS_SECRET_ACCESS_KEY`   | 您的秘密访问密钥。 |
   | `AWS_DEFAULT_REGION`      | 您的区域代码。您可能需要确认您打算使用的 AWS 服务[在所选区域中可用](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/)。 |

1. 变量[默认受保护](../variables/_index.md#protect-a-cicd-variable)。
   要在未受保护的分支或标签上使用极狐GitLab CI/CD，
   请清除 **保护变量** 复选框。

<a id="use-an-image-to-run-aws-commands"></a>

## 使用镜像运行 AWS 命令

如果某个镜像包含 [AWS Command Line Interface](https://aws.amazon.com/cli/)，
您可以在项目的 `.gitlab-ci.yml` 文件中引用该镜像。然后您就可以在 CI/CD 作业中运行 `aws` 命令。

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

- 镜像托管在极狐GitLab 容器镜像仓库中。最新镜像为
  `registry.gitlab.com/gitlab-org/cloud-deploy/aws-base:latest`。
- [镜像存储在 GitLab 代码仓库中](https://gitlab.com/gitlab-org/cloud-deploy/-/tree/master/aws)。

或者，您可以使用 [Amazon Elastic Container Registry (ECR)](https://aws.amazon.com/ecr/) 镜像。
[了解如何将镜像推送到您的 ECR 容器仓库](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)。

您也可以使用来自任何第三方镜像仓库的镜像。

<a id="deploy-your-application-to-ecs"></a>

## 将应用部署到 ECS

您可以自动将应用部署到您的 [Amazon ECS](https://aws.amazon.com/ecs/) 集群。

先决条件：

- [使用 AWS 对极狐GitLab 进行身份验证](#authenticate-gitlab-with-aws)。
- 在 Amazon ECS 上创建集群。
- 创建相关组件，例如 ECS 服务或 Amazon RDS 上的数据库。
- 创建 ECS 任务定义，其中 `containerDefinitions[].name` 属性的值
  与目标 ECS 服务中定义的 `Container name` 相同。任务定义可以是：
  - ECS 中的现有任务定义。
  - 极狐GitLab 项目中的 JSON 文件。使用
    [AWS 文档中的模板](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-task-definition.html#task-definition-template)
    并将该文件保存在您的项目中。例如 `<project-root>/ci/aws/task-definition.json`。

要部署到您的 ECS 集群：

1. 在您的极狐GitLab 项目中，转到**设置** > **CI/CD**。设置以下
   [CI/CD 变量](../variables/_index.md)。您可以在 [Amazon ECS 仪表板](https://console.aws.amazon.com/ecs/home)上选择目标集群来找到这些名称。

   | 环境变量名称         | 值 |
   |:----------------------------------|:------|
   | `CI_AWS_ECS_CLUSTER`              | 您要部署到的目标 AWS ECS 集群的名称。 |
   | `CI_AWS_ECS_SERVICE`              | 与您的 AWS ECS 集群关联的目标服务的名称。确保此变量限定到适当的环境（`production`、`staging`、`review/*`）。 |
   | `CI_AWS_ECS_TASK_DEFINITION`      | 如果任务定义位于 ECS 中，则为与该服务关联的任务定义的名称。 |
   | `CI_AWS_ECS_TASK_DEFINITION_FILE` | 如果任务定义是极狐GitLab 中的 JSON 文件，则为文件名（包括路径）。例如，`ci/aws/my_task_definition.json`。如果 JSON 文件中的任务定义名称与 ECS 中现有任务定义的名称相同，则 CI/CD 运行时会创建新修订版本。否则，将创建一个全新的任务定义，从修订版本 1 开始。 |

   > [!warning]
   > 如果您同时定义了 `CI_AWS_ECS_TASK_DEFINITION_FILE` 和 `CI_AWS_ECS_TASK_DEFINITION`，
   > 则 `CI_AWS_ECS_TASK_DEFINITION_FILE` 优先。

1. 在 `.gitlab-ci.yml` 中包含此模板：

   ```yaml
   include:
     - template: AWS/Deploy-ECS.gitlab-ci.yml
   ```

   `AWS/Deploy-ECS` 模板随极狐GitLab 一起提供，可在
   [GitLab.com 上获取](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/AWS/Deploy-ECS.gitlab-ci.yml)。

1. 提交并推送更新后的 `.gitlab-ci.yml` 到您项目的代码仓库。

您的应用 Docker 镜像会被重新构建并推送到极狐GitLab 容器镜像仓库。如果您的镜像位于私有镜像仓库中，请确保您的任务定义[配置了 `repositoryCredentials` 属性](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html)。

目标任务定义会更新为新 Docker 镜像的位置，并因此在 ECS 中创建新修订版本。

最后，您的 AWS ECS 服务会更新为任务定义的新修订版本，使集群拉取您应用的最新版本。

ECS 部署作业会等待发布完成后再退出。要禁用此行为，请将 `CI_AWS_ECS_WAIT_FOR_ROLLOUT_COMPLETE_DISABLED` 设置为非空值。

> [!warning]
> [`AWS/Deploy-ECS.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/AWS/Deploy-ECS.gitlab-ci.yml)
> 模板包含两个模板：[`Jobs/Build.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Build.gitlab-ci.yml)
> 和 [`Jobs/Deploy/ECS.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Deploy/ECS.gitlab-ci.yml)。请勿单独包含这些模板。只包含
> `AWS/Deploy-ECS.gitlab-ci.yml` 模板。这些其他模板设计为
> 仅与主模板一起使用。它们可能会意外移动或更改。此外，这些模板中的作业名称
> 可能会更改。请勿在您自己的流水线中覆盖这些作业名称，
> 因为名称更改后覆盖将不再生效。

<a id="deploy-your-application-to-ec2"></a>

## 将应用部署到 EC2

极狐GitLab 提供了一个名为 `AWS/CF-Provision-and-Deploy-EC2` 的模板，
以协助您部署到 Amazon EC2。

当您配置相关 JSON 对象并使用该模板时，流水线会：

1. **创建堆栈**：您的基础设施通过
   [AWS CloudFormation](https://aws.amazon.com/cloudformation/) API 进行预配。
1. **推送到 S3 存储桶**：当您的构建运行时，它会创建一个产物。
   该产物会被推送到 [AWS S3](https://aws.amazon.com/s3/) 存储桶。
1. **部署到 EC2**：内容会部署到 [AWS EC2](https://aws.amazon.com/ec2/) 实例上，
   如下图所示：

![展示 CF-Provision-and-Deploy-EC2 流水线，包括预配基础设施、将产物推送到 S3 以及部署到 EC2 的步骤。](img/cf_ec2_diagram_v13_5.png)

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

   `source` 是 `build` 作业构建您的应用的位置。
   构建会保存到 [`artifacts:paths`](../yaml/_index.md#artifactspaths)。

1. 创建要部署到 EC2 的 JSON。使用 [AWS 模板](https://docs.aws.amazon.com/codedeploy/latest/APIReference/API_CreateDeployment.html)。
1. 使 JSON 对象可供您的流水线访问：
   - 如果您希望将这些 JSON 对象保存在代码仓库中，请将这些对象保存为三个
     单独的文件。

     在您的 `.gitlab-ci.yml` 文件中，添加指向相对于项目根目录的文件路径的 [CI/CD 变量](../variables/_index.md)。
     例如，如果您的 JSON 文件位于 `<project_root>/aws` 文件夹中：

     ```yaml
     variables:
       CI_AWS_CF_CREATE_STACK_FILE: 'aws/cf_create_stack.json'
       CI_AWS_S3_PUSH_FILE: 'aws/s3_push.json'
       CI_AWS_EC2_DEPLOYMENT_FILE: 'aws/create_deployment.json'
     ```

   - 如果您不希望将这些 JSON 对象保存在代码仓库中，请在项目设置中将每个对象
     添加为单独的[文件类型 CI/CD 变量](../variables/_index.md#use-file-type-cicd-variables)。
     使用与前面相同的变量名称。

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

   - 您的 AWS CloudFormation 堆栈会根据
     `CI_AWS_CF_CREATE_STACK_FILE` 变量的内容创建。
     如果您的堆栈已存在，则跳过此步骤，但它所属的 `provision`
     作业仍会运行。
   - 您构建的应用会被推送到 S3 存储桶，然后根据相关 JSON 对象的内容部署到 EC2 实例。
     当部署到 EC2 完成或失败时，部署作业结束。

<a id="troubleshooting"></a>

## 故障排除

<a id="error-ascii-codec-cant-encode-character-uxxxx"></a>

### 错误 `'ascii' codec can't encode character '\uxxxx'`

当 Cloud Deploy 镜像使用的 `aws-cli` 工具返回的响应包含 Unicode 字符时，可能会出现此错误。Cloud Deploy 镜像没有定义区域设置，默认使用 ASCII。要解决此错误，请添加以下 CI/CD 变量：

```yaml
variables:
  LANG: "UTF-8"
```
