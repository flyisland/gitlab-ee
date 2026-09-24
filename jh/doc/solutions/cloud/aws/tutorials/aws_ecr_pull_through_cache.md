---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
description: Integrations Solutions Index for GitLab and AWS.
title: '教程：配置 AWS ECR Pull Through Cache 规则以实现对 JihuLab.com 项目的认证访问'
---

1.  打开 Amazon ECR 控制台，地址为 <https://console.aws.amazon.com/ecr/>。
1.  在导航栏中，选择要配置私有注册表设置的区域。
1.  在导航窗格中，选择私有注册表，然后选择拉取缓存。
1.  在拉取缓存配置页面，选择添加规则。

在步骤 1：指定源页面，对于注册表，选择极狐GitLab 容器镜像仓库，然后选择下一步。

在步骤 2：配置身份验证页面，对于上游凭证，您必须将极狐GitLab 容器镜像仓库的身份验证凭证存储在 AWS Secrets Manager 密钥中。您可以指定现有密钥或使用 Amazon ECR 控制台创建新密钥。

要使用现有密钥，请选择使用现有 AWS 密钥。对于密钥名称，使用下拉菜单选择现有密钥，然后选择下一步。有关使用 Secrets Manager 控制台创建 Secrets Manager 密钥的更多信息，请参阅在 AWS Secrets Manager 密钥中存储上游仓库凭证。

> [!note]
> AWS 管理控制台仅显示名称使用 ecr-pullthroughcache/ 前缀的 Secrets Manager 密钥。该密钥还必须与创建拉取缓存规则的账户和区域相同。

要创建新密钥，请选择创建 AWS 密钥，执行以下操作，然后选择下一步。

对于密钥名称，为密钥指定一个描述性名称。密钥名称必须包含 1-512 个 Unicode 字符。

对于极狐GitLab 容器镜像仓库用户名，指定您的极狐GitLab 容器镜像仓库用户名。

对于极狐GitLab 容器镜像仓库访问令牌，指定您的极狐GitLab 容器镜像仓库访问令牌。为遵循最小权限原则，请创建一个具有访客角色且仅具有 `read_registry` 范围的群组访问令牌。

在步骤 3：指定目标页面，对于 Amazon ECR 仓库前缀，指定在缓存从源公共注册表拉取的镜像时要使用的仓库命名空间，然后选择下一步。

默认情况下，会填充一个命名空间，但也可以指定自定义命名空间。

在步骤 4：审核并创建页面，审核拉取缓存规则配置，然后选择创建。

对要创建的每个拉取缓存重复上一步。拉取缓存规则是按区域单独创建的。

要验证您的 ECR 拉取缓存规则是否已成功创建，可以通过 AWS CLI 运行以下命令来验证该规则：

```shell
aws ecr validate-pull-through-cache-rule \
     --ecr-repository-prefix ecr-public \
     --region us-east-2
```

要验证您的 ECR 拉取缓存规则是否提供对 JihuLab.com 上游注册表的拉取访问，可以通过运行 `docker pull` 命令进行验证：

```shell
docker pull aws_account_id.dkr.ecr.region.amazonaws.com/{目标命名空间，例如 gitlab-ef1b}/{托管镜像的 jihulab.com 项目/群组路径}/image_name:tag
```

示例 `docker pull` 命令：

```shell
docker pull aws_account_id.dkr.ecr.region.amazonaws.com/gitlab-ef1b/guided-explorations/ci-components/working-code-examples/kaniko-component-multiarch-build:latest
```

