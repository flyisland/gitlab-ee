---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 创建推送镜像，以被动接收来自上游代码仓库的变更。
title: 推送镜像
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

*推送镜像*是一个下游代码仓库，用于[镜像](_index.md)对上游代码仓库所做的提交。推送镜像被动接收对上游代码仓库所做提交的副本。为防止镜像与上游代码仓库产生分歧，请勿将提交直接推送到下游镜像。而应将提交推送到上游代码仓库。

[拉取镜像](pull.md)会定期从上游代码仓库获取更新，而推送镜像仅在以下情况下接收变更：

- 提交被推送到上游极狐GitLab 代码仓库时。
- 管理员[强制更新镜像](_index.md#force-an-update)时。

当您将变更推送到上游代码仓库时，推送镜像会在五分钟内收到该变更；如果开启了 **仅镜像受保护分支** 设置，则在一分钟内收到。

当某个分支被合并到默认分支并在源项目中删除后，它会在下一次推送时从远程镜像中删除。包含未合并变更的分支会被保留。如果分支产生分歧，**镜像仓库** 部分会显示错误。

[极狐GitLab 静默模式](../../../../administration/silent_mode/_index.md)会禁止向远程镜像推送以及从远程镜像拉取。

<a id="push-mirror-limits"></a>

## 推送镜像限制

每个项目最多可以有 10 个已启用的推送镜像。更多信息，请参阅[项目推送镜像的最大数量](../../../../administration/instance_limits.md#maximum-number-of-project-push-mirrors)。

<a id="configure-push-mirroring"></a>

## 配置推送镜像

先决条件：

- 您的极狐GitLab 代码仓库和远程代码仓库使用相同的对象格式。
  您无法在 SHA-1 和 SHA-256 代码仓库之间进行镜像。

要为现有项目设置推送镜像：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开 **镜像仓库**。
1. 输入代码仓库 URL。
1. 在 **镜像方向** 下拉列表中，选择 **推送**。
1. 选择一种 **验证方式**。更多信息，请参阅
   [镜像的身份验证方法](_index.md#authentication-methods-for-mirrors)。
1. 如有必要，选择 **仅镜像受保护分支**。
1. 如需要，选择 **保留分歧引用**。
1. 要保存配置，请选择 **镜像仓库**。

<a id="configure-push-mirrors-through-the-api"></a>

### 通过 API 配置推送镜像

您也可以通过[远程镜像 API](../../../../api/remote_mirrors.md) 创建和修改项目推送镜像。

<a id="keep-divergent-refs"></a>

## 保留分歧的引用

默认情况下，如果远程（下游）镜像上的任何引用（分支或标签）与本地代码仓库产生分歧，上游代码仓库会覆盖远程上的任何变更：

1. 一个代码仓库将 `main` 和 `develop` 分支镜像到远程。
1. 在远程镜像的 `develop` 上添加了一个新提交。
1. 下一次推送会更新远程镜像，使其与上游代码仓库匹配。
1. 添加到远程镜像 `develop` 上的新提交会丢失。

如果选择了 **保留分歧引用**，变更的处理方式会有所不同：

1. 对远程镜像上 `develop` 分支的更新会被跳过。
1. 远程镜像上的 `develop` 分支会保留上游代码仓库中不存在的提交。远程镜像中存在但上游不存在的任何引用都会保持原样。
1. 该更新会被标记为失败。

创建镜像后，您只能通过[远程镜像 API](../../../../api/remote_mirrors.md) 修改 **保留分歧引用**的值。

<a id="set-up-a-push-mirror-from-gitlab-to-github"></a>

## 设置从极狐GitLab 到 GitHub 的推送镜像

当您将提交从极狐GitLab 推送到 GitHub 时，GitHub 会根据电子邮件地址确定提交归属。如果提交的电子邮件地址与 GitHub 用户账号上已验证的电子邮件地址匹配，GitHub 会将该提交归属于该用户。否则，该提交会显示为未归属，仅包含提交元数据中的姓名和电子邮件地址。

先决条件：

- 一个 GitHub [细粒度个人访问令牌](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#fine-grained-personal-access-tokens)，
  具有对
  [代码仓库内容](https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens?apiVersion=2022-11-28#repository-permissions-for-contents)的读写权限。
  如果您的代码仓库包含 `.github/workflows` 目录，您还必须授予对
  [Workflows](https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens?apiVersion=2022-11-28#repository-permissions-for-workflows)的读写权限。
  如需更细粒度的访问权限，请将您的令牌配置为仅适用于特定代码仓库。

要设置镜像：

1. 对于 **Git 代码仓库 URL**，请输入以下格式的 URL：

   ```plaintext
   https://github.com/GROUP/PROJECT.git
   ```

   - `GROUP`：GitHub 上的群组。
   - `PROJECT`：GitHub 上的项目。

1. 对于 **用户名**，请输入个人访问令牌所有者的用户名。
1. 对于 **密码**，请输入您的 GitHub 个人访问令牌。
1. 选择 **镜像仓库**。

镜像的代码仓库会列出。例如：

```plaintext
https://*****:*****@github.com/<your_github_group>/<your_github_project>.git
```

代码仓库随后会很快推送。要强制推送，请选择 **立即更新**（{{< icon name="retry" >}}）。

<a id="set-up-a-push-mirror-from-gitlab-to-aws-codecommit"></a>

## 设置从极狐GitLab 到 AWS CodeCommit 的推送镜像

AWS CodeCommit 推送镜像是将极狐GitLab 代码仓库连接到 AWS CodePipeline 的最佳方式。AWS CodePipeline 尚不支持将极狐GitLab 作为其源代码管理（SCM）提供商之一。每个新的 AWS CodePipeline 都需要大量的 AWS 基础设施设置。它还需要为每个分支配置单独的流水线。

如果 AWS CodeDeploy 是 CodePipeline 的最后一步，您可以改为组合使用这些工具来创建部署：

- 极狐GitLab CI/CD 流水线。
- 在 `.gitlab-ci.yml`的最后一个作业中使用 AWS CLI 部署到 CodeDeploy。

要设置从极狐GitLab 到 AWS CodeCommit 的镜像：

1. 在 AWS IAM 控制台中，创建一个 IAM 用户。
1. 将以下用于代码仓库镜像的最小权限作为 **内联策略** 添加。

   Amazon 资源名称（ARN）必须明确包含区域和账号。此 IAM 策略授予对两个示例代码仓库的镜像访问权限。这些权限已经过测试，是镜像所需的最低（最小）权限：

   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Sid": "MinimumGitLabPushMirroringPermissions",
               "Effect": "Allow",
               "Action": [
                   "codecommit:GitPull",
                   "codecommit:GitPush"
               ],
               "Resource": [
                 "arn:aws:codecommit:us-east-1:111111111111:MyDestinationRepo",
                 "arn:aws:codecommit:us-east-1:111111111111:MyDemo*"
               ]
           }
       ]
   }
   ```

1. 创建用户后，选择该 AWS IAM 用户名。
1. 选择 **安全凭证** 标签页。
1. 在 **AWS CodeCommit 的 HTTPS Git 凭证** 下，选择 **生成凭证**。

   > [!note]
   > 此 Git 用户 ID 和密码专门用于与 CodeCommit 通信。请勿将其与该用户的 IAM 用户 ID 或 AWS 密钥混淆。

1. 复制或下载特殊的 Git HTTPS 用户 ID 和密码。
1. 在 AWS CodeCommit 控制台中，创建一个新代码仓库，以便从您的极狐GitLab 代码仓库进行镜像。
1. 打开您的新代码仓库，在右上角选择 **代码** > **克隆 HTTPS**（不是 **克隆 HTTPS（GRC）**）。
1. 在极狐GitLab 中，打开要进行推送镜像的代码仓库。
1. 选择**设置** > **代码仓库**，然后展开 **镜像仓库**。
1. 使用以下格式填写 **Git 代码仓库 URL** 字段，将
   `<aws-region>` 替换为您的 AWS 区域，将
   `<your_codecommit_repo>` 替换为您在 CodeCommit 中的代码仓库名称：

   ```plaintext
   https://git-codecommit.<aws-region>.amazonaws.com/v1/repos/<your_codecommit_repo>
   ```

1. 对于 **验证方式**，选择 **用户名和密码**。
1. 对于 **用户名**，输入 AWS **专用 HTTPS Git 用户 ID**。
1. 对于 **密码**，输入之前在 AWS 中创建的特殊 IAM Git 克隆用户 ID 密码。
1. 为 CodeCommit 保留 **仅镜像受保护分支** 选项。它会更频繁地推送（从每五分钟一次到每一分钟一次）。

   CodePipeline 需要为您想要设置 AWS CI 的具名分支单独设置流水线。由于不支持具有动态名称的功能分支，配置 **仅镜像受保护分支** 不会给 CodePipeline 集成带来灵活性方面的问题。您还必须保护您想要为其构建 CodePipeline 的所有具名分支。

1. 选择 **镜像仓库**。您应该会看到镜像的代码仓库出现：

   ```plaintext
   https://*****:*****@git-codecommit.<aws-region>.amazonaws.com/v1/repos/<your_codecommit_repo>
   ```

要通过强制推送来测试镜像，请选择 **立即更新**（半圆箭头）。
如果 **最近成功的更新** 显示日期，则说明您已正确配置镜像。
如果它无法正常工作，会出现一个红色的 `error` 标签，并在悬停文本中显示错误消息。

<a id="set-up-a-push-mirror-to-another-gitlab-instance-with-2fa-activated"></a>

## 设置到另一个启用了 2FA 的极狐GitLab 实例的推送镜像

1. 在目标极狐GitLab 实例上，创建一个具有 `write_repository` 范围的
   [个人访问令牌](../../../profile/personal_access_tokens.md)。
1. 在源极狐GitLab 实例上：
   1. 使用以下格式输入 **Git 代码仓库 URL**：
      `https://<destination host>/<your_gitlab_group_or_name>/<your_gitlab_project>.git`。
   1. 输入 **用户名** `oauth2`。
   1. 输入 **密码**。使用在目标极狐GitLab 实例上创建的极狐GitLab 个人访问令牌。
   1. 选择 **镜像仓库**。
