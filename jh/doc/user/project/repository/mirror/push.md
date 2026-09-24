---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Create a push mirror to passively receive changes from an upstream repository.
title: 推送镜像
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

_推送镜像_是一个下游仓库，它[镜像](_index.md)了向上游仓库所做的提交。推送镜像被动接收上游仓库提交的副本。为防止镜像与上游仓库分叉，请勿直接向下游镜像推送提交。而应向上游仓库推送提交。

与[拉取镜像](pull.md)定期从上游仓库获取更新不同，推送镜像仅在以下情况下接收变更：

- 提交被推送到上游极狐GitLab 仓库。
- 管理员[强制更新镜像](_index.md#force-an-update)。

当你向上游仓库推送变更时，推送镜像会在五分钟内接收到，如果开启了 **仅镜像受保护分支** 设置，则为一分钟。

当分支被合并到默认分支并在源项目中删除时，该分支会在下一次推送时从远程镜像中删除。未合并变更的分支会被保留。如果分支出现分叉，**镜像仓库** 部分会显示错误。

[极狐GitLab 静默模式](../../../../administration/silent_mode/_index.md)会禁用向远程镜像的推送和从远程镜像的拉取。

<a id="push-mirror-limits"></a>

## 推送镜像限制

每个项目最多可以启用 10 个推送镜像。
更多信息，请参见[项目推送镜像的最大数量](../../../../administration/instance_limits.md#maximum-number-of-project-push-mirrors)。

<a id="configure-push-mirroring"></a>

## 配置推送镜像

为已有项目配置推送镜像：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **镜像仓库**。
1. 输入仓库 URL。
1. 在 **镜像方向** 下拉列表中，选择 **推送**。
1. 选择 **认证方法**。更多信息，请参见[镜像的认证方法](_index.md#authentication-methods-for-mirrors)。
1. 如有必要，选择 **仅镜像受保护分支**。
1. 如有需要，选择 **保留分歧引用**。
1. 要保存配置，选择 **镜像仓库**。

<a id="configure-push-mirrors-through-the-api"></a>

### 通过 API 配置推送镜像

你还可以通过[远程镜像 API](../../../../api/remote_mirrors.md) 创建和修改项目推送镜像。

<a id="keep-divergent-refs"></a>

## 保留分歧引用

默认情况下，如果远程（下游）镜像上的任何引用（分支或标签）与本地仓库产生分叉，上游仓库会覆盖远程上的任何变更：

1. 一个仓库将 `main` 和 `develop` 分支镜像到远程。
1. 一个新提交被添加到远程镜像的 `develop` 分支。
1. 下一次推送会更新远程镜像以匹配上游仓库。
1. 远程镜像的 `develop` 分支上新增的提交丢失。

如果选择了 **保留分歧引用**，变更的处理方式会不同：

1. 跳过对远程镜像 `develop` 分支的更新。
1. 远程镜像上的 `develop` 分支保留上游仓库中不存在的那次提交。任何存在于远程镜像但不存在于上游的引用均保持不变。
1. 此次更新被标记为失败。

创建镜像后，你只能通过[远程镜像 API](../../../../api/remote_mirrors.md) 修改 **保留分歧引用** 的值。

<a id="set-up-a-push-mirror-from-gitlab-to-github"></a>

## 设置从极狐GitLab 到 GitHub 的推送镜像

当你从极狐GitLab 向 GitHub 推送提交时，GitHub 根据电子邮件地址确定提交归属。如果提交的电子邮件地址与 GitHub 用户帐户上已验证的电子邮件匹配，GitHub 会将提交归属于该用户。否则，提交会以无归属方式显示，仅带有提交元数据中的姓名和电子邮件。

前提条件：

- 一个 GitHub [细粒度个人访问令牌](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#fine-grained-personal-access-tokens)，具有[仓库内容](https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens?apiVersion=2022-11-28#repository-permissions-for-contents)的读写权限。如果仓库中包含 `.github/workflows` 目录，你还必须授予对 [Workflows](https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens?apiVersion=2022-11-28#repository-permissions-for-workflows) 的读写权限。要实现更精细的访问控制，请将令牌配置为仅应用于特定仓库。

设置镜像：

1. 对于 **Git 仓库 URL**，按以下格式输入 URL：

   ```plaintext
   https://github.com/GROUP/PROJECT.git
   ```

   - `GROUP`：GitHub 上的群组。
   - `PROJECT`：GitHub 上的项目。

1. 对于 **用户名**，输入个人访问令牌所有者的用户名。
1. 对于 **密码**，输入你的 GitHub 个人访问令牌。
1. 选择 **镜像仓库**。

镜像仓库会列出。例如：

```plaintext
https://*****:*****@github.com/<your_github_group>/<your_github_project>.git
```

仓库随后不久便开始推送。要强制推送，选择 **立即更新** ({{< icon name="retry" >}})。

<a id="set-up-a-push-mirror-to-another-gitlab-instance-with-2fa-activated"></a>

## 设置到另一个已激活双因素认证的极狐GitLab 实例的推送镜像

1. 在目标极狐GitLab 实例上，创建一个具有 `write_repository` 作用域的[个人访问令牌](../../../profile/personal_access_tokens.md)。
1. 在源极狐GitLab 实例上：
   1. 按以下格式输入 **Git 仓库 URL**：
      `https://<destination host>/<your_gitlab_group_or_name>/<your_gitlab_project>.git`。
   1. 输入 **用户名** `oauth2`。
   1. 输入 **密码**。使用在目标极狐GitLab 实例上创建的极狐GitLab 个人访问令牌。
   1. 选择 **镜像仓库**。