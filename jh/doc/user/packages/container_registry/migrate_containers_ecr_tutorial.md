---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：将容器镜像从 Amazon ECR 迁移到极狐GitLab'
description: 本教程介绍如何自动将容器镜像从 Amazon Elastic Container Registry 批量迁移到极狐GitLab。
---

手动在镜像仓库之间迁移容器镜像可能非常耗时。本教程介绍如何设置 CI/CD 流水线，以自动将容器镜像从 Amazon Elastic Container Registry (ECR) 批量迁移到极狐GitLab 容器镜像仓库。

要从 ECR 迁移容器镜像：

1. [配置 AWS 权限](#configure-aws-permissions)
1. [在 UI 中将 AWS 凭证添加为变量](#add-aws-credentials-as-variables-in-the-ui)
1. [创建迁移流水线](#create-the-migration-pipeline)
1. [运行并验证迁移](#run-and-verify-the-migration)

完成所有步骤后，您的 `.gitlab-ci.yml` 应与本教程末尾提供的[示例配置](#example-gitlab-ciyml-configuration)类似。

<a id="before-you-begin"></a>

## 开始之前

您必须具备：

- 极狐GitLab 项目中的维护者或所有者角色
- 对 AWS 账户的访问权限，并具有创建 IAM 用户的权限
- 您的 AWS 账户 ID
- ECR 容器仓库所在的 AWS 区域
- 极狐GitLab 容器镜像仓库中有足够的存储空间

<a id="configure-aws-permissions"></a>

## 配置 AWS 权限

在 AWS IAM 中，创建一个对 ECR 具有只读访问权限的新策略和用户：

1. 在 AWS 管理控制台中，转到 IAM。
1. 创建新策略：

   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": [
                   "ecr:GetAuthorizationToken",
                   "ecr:BatchCheckLayerAvailability",
                   "ecr:GetDownloadUrlForLayer",
                   "ecr:DescribeRepositories",
                   "ecr:ListImages",
                   "ecr:DescribeImages",
                   "ecr:BatchGetImage"
               ],
               "Resource": "*"
           }
       ]
   }
   ```

1. 创建新的 IAM 用户并附加该策略。
1. 为该 IAM 用户生成并保存访问密钥。

<a id="add-aws-credentials-as-variables-in-the-ui"></a>

## 在 UI 中将 AWS 凭证添加为变量

在极狐GitLab 项目中，将所需的 AWS 凭证配置为变量：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**。
1. 选择**添加变量**并添加：
   - `AWS_ACCOUNT_ID`：您的 AWS 账号。
   - `AWS_DEFAULT_REGION`：您的 ECR 区域。例如，`us-east-1`。
   - `AWS_ACCESS_KEY_ID`：您的 IAM 用户的访问密钥 ID。
     - 选择**屏蔽变量**。
   - `AWS_SECRET_ACCESS_KEY`：您的 IAM 用户的秘密访问密钥。
     - 选择**屏蔽变量**。

<a id="create-the-migration-pipeline"></a>

## 创建迁移流水线

在您的代码仓库中创建一个新的 `.gitlab-ci.yml` 文件，包含以下配置：

<a id="set-image-and-service"></a>

### 设置镜像和服务

使用 Docker-in-Docker 处理容器操作：

```yaml
image: docker:20.10
services:
  - docker:20.10-dind
```

<a id="define-pipeline-variables"></a>

### 定义流水线变量

为流水线设置所需的变量：

```yaml
variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: ""
  BULK_MIGRATE: "true"
```

<a id="configure-the-migration-job"></a>

### 配置迁移作业

创建负责迁移镜像的作业：

```yaml
migration:
  stage: deploy
  script:
    # Install required tools
    - apk add --no-cache aws-cli jq

    # Verify AWS credentials
    - aws sts get-caller-identity

    # Log in to registries
    - aws ecr get-login-password | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
    - docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}

    # Get list of ECR repositories
    - REPOS=$(aws ecr describe-repositories --query 'repositories[*].repositoryName' --output text)

    # Process each repository
    - |
      for repo in $REPOS; do
        echo "Processing repository: $repo"

        # Get all tags for this repository
        TAGS=$(aws ecr describe-images --repository-name $repo --query 'imageDetails[*].imageTags[]' --output text)

        # Process each tag
        for tag in $TAGS; do
          echo "Processing tag: $tag"

          # Pull image from ECR
          docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${repo}:${tag}

          # Tag for GitLab registry
          docker tag ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${repo}:${tag} ${CI_REGISTRY_IMAGE}/${repo}:${tag}

          # Push to GitLab
          docker push ${CI_REGISTRY_IMAGE}/${repo}:${tag}
        done
      done
```

<a id="run-and-verify-the-migration"></a>

## 运行并验证迁移

设置流水线后：

1. 将 `.gitlab-ci.yml` 文件提交并推送到您的代码仓库。
1. 转到 **CI/CD** > **流水线**以监控迁移进度。
1. 完成后，验证迁移：
   - 转到**软件包和镜像仓库** > **容器镜像仓库**。
   - 验证所有容器仓库和标签均已存在。
   - 测试拉取一些已迁移的镜像。

<a id="example-gitlab-ciyml-configuration"></a>

## 示例 `.gitlab-ci.yml` 配置

按照前面所有步骤操作后，`.gitlab-ci.yml` 文件应如下所示：

```yaml
image: docker:20.10
services:
  - docker:20.10-dind

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: ""
  BULK_MIGRATE: "true"

migration:
  stage: deploy
  script:
    # Install required tools
    - apk add --no-cache aws-cli jq

    # Verify AWS credentials
    - aws sts get-caller-identity

    # Log in to registries
    - aws ecr get-login-password | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
    - docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}

    # Get list of ECR repositories
    - REPOS=$(aws ecr describe-repositories --query 'repositories[*].repositoryName' --output text)

    # Process each repository
    - |
      for repo in $REPOS; do
        echo "Processing repository: $repo"

        # Get all tags for this repository
        TAGS=$(aws ecr describe-images --repository-name $repo --query 'imageDetails[*].imageTags[]' --output text)

        # Process each tag
        for tag in $TAGS; do
          echo "Processing tag: $tag"

          # Pull image from ECR
          docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${repo}:${tag}

          # Tag for GitLab registry
          docker tag ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${repo}:${tag} ${CI_REGISTRY_IMAGE}/${repo}:${tag}

          # Push to GitLab
          docker push ${CI_REGISTRY_IMAGE}/${repo}:${tag}
        done
      done
  rules:
    - if: $BULK_MIGRATE == "true"
```
