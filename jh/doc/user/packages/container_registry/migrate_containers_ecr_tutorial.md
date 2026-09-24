---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：将容器镜像从 Amazon ECR 迁移到极狐GitLab'
description: 本教程介绍如何设置 CI/CD 流水线，以自动化地将容器镜像从 Amazon Elastic Container Registry (ECR) 批量迁移到极狐GitLab 容器镜像仓库。
---

在注册表之间手动迁移容器镜像非常耗时。本教程介绍如何设置一条 CI/CD 流水线，以实现将容器镜像从 Amazon Elastic Container Registry (ECR) 批量迁移到极狐GitLab 容器镜像仓库的自动化。

迁移 ECR 容器镜像的步骤如下：

1. [配置 AWS 权限](#configure-aws-permissions)
1. [在 UI 中将 AWS 凭证添加为变量](#add-aws-credentials-as-variables-in-the-ui)
1. [创建迁移流水线](#create-the-migration-pipeline)
1. [运行并验证迁移](#run-and-verify-the-migration)

当您完成所有配置后，您的 `.gitlab-ci.yml` 文件应与本教程末尾提供的 [示例配置](#example-gitlab-ciyml-configuration) 类似。

<a id="before-you-begin"></a>

## 准备工作

您必须具备以下条件：

- 在极狐GitLab 项目中拥有**维护者**或**所有者**角色
- 可访问您的 AWS 账户，并拥有创建 IAM 用户的权限
- 您的 AWS 账户 ID
- 存放 ECR 仓库的 AWS 区域
- 极狐GitLab 容器镜像仓库中有足够的存储空间

<a id="configure-aws-permissions"></a>

## 配置 AWS 权限

在 AWS IAM 中，创建一个具有 ECR 只读访问权限的新策略和用户：

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

1. 创建一个新的 IAM 用户并附加该策略。
1. 为该 IAM 用户生成并保存访问密钥。

<a id="add-aws-credentials-as-variables-in-the-ui"></a>

## 在 UI 中将 AWS 凭证添加为变量

在极狐GitLab 项目中，将所需的 AWS 凭证配置为变量：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量**。
1. 选择 **添加变量** 并添加：
   - `AWS_ACCOUNT_ID`：您的 AWS 账号。
   - `AWS_DEFAULT_REGION`：您的 ECR 区域，例如 `us-east-1`。
   - `AWS_ACCESS_KEY_ID`：来自 IAM 用户的访问密钥 ID。
     - 勾选 **屏蔽变量**。
   - `AWS_SECRET_ACCESS_KEY`：来自 IAM 用户的秘密访问密钥。
     - 勾选 **屏蔽变量**。

<a id="create-the-migration-pipeline"></a>

## 创建迁移流水线

在您的仓库中创建一个新的 `.gitlab-ci.yml` 文件，并包含以下配置：

### 设置镜像和服务

使用 Docker-in-Docker 来处理容器操作：

```yaml
image: docker:20.10
services:
  - docker:20.10-dind
```

### 定义流水线变量

设置流水线需要的变量：

```yaml
variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: ""
  BULK_MIGRATE: "true"
```

### 配置迁移作业

创建用于处理迁移的作业：

```yaml
migration:
  stage: deploy
  script:
    # 安装所需工具
    - apk add --no-cache aws-cli jq

    # 验证 AWS 凭证
    - aws sts get-caller-identity

    # 登录注册表
    - aws ecr get-login-password | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
    - docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}

    # 获取 ECR 仓库列表
    - REPOS=$(aws ecr describe-repositories --query 'repositories[*].repositoryName' --output text)

    # 处理每个仓库
    - |
      for repo in $REPOS; do
        echo "Processing repository: $repo"

        # 获取此仓库的所有标签
        TAGS=$(aws ecr describe-images --repository-name $repo --query 'imageDetails[*].imageTags[]' --output text)

        # 处理每个标签
        for tag in $TAGS; do
          echo "Processing tag: $tag"

          # 从 ECR 拉取镜像
          docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${repo}:${tag}

          # 为极狐GitLab 注册表打标签
          docker tag ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${repo}:${tag} ${CI_REGISTRY_IMAGE}/${repo}:${tag}

          # 推送到极狐GitLab
          docker push ${CI_REGISTRY_IMAGE}/${repo}:${tag}
        done
      done
```

<a id="run-and-verify-the-migration"></a>

## 运行并验证迁移

在设置好流水线之后：

1. 将 `.gitlab-ci.yml` 文件提交并推送到仓库。
1. 前往 **CI/CD** > **流水线** 来监控迁移进度。
1. 完成后，验证迁移结果：
   - 前往 **软件包与镜像仓库** > **容器镜像仓库**。
   - 确认所有仓库和标签均已存在。
   - 测试拉取部分已迁移的镜像。

<a id="example-gitlab-ciyml-configuration"></a>

## `.gitlab-ci.yml` 示例配置

当您按照以上所有步骤操作后，`.gitlab-ci.yml` 文件应该如下所示：

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
    # 安装所需工具
    - apk add --no-cache aws-cli jq

    # 验证 AWS 凭证
    - aws sts get-caller-identity

    # 登录注册表
    - aws ecr get-login-password | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
    - docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}

    # 获取 ECR 仓库列表
    - REPOS=$(aws ecr describe-repositories --query 'repositories[*].repositoryName' --output text)

    # 处理每个仓库
    - |
      for repo in $REPOS; do
        echo "Processing repository: $repo"

        # 获取此仓库的所有标签
        TAGS=$(aws ecr describe-images --repository-name $repo --query 'imageDetails[*].imageTags[]' --output text)

        # 处理每个标签
        for tag in $TAGS; do
          echo "Processing tag: $tag"

          # 从 ECR 拉取镜像
          docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${repo}:${tag}

          # 为极狐GitLab 注册表打标签
          docker tag ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${repo}:${tag} ${CI_REGISTRY_IMAGE}/${repo}:${tag}

          # 推送到极狐GitLab
          docker push ${CI_REGISTRY_IMAGE}/${repo}:${tag}
        done
      done
  rules:
    - if: $BULK_MIGRATE == "true"
```