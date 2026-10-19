---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 创建拉取镜像，将更改从远程代码仓库拉取到极狐GitLab，并保持您的副本最新。
title: 从远程代码仓库拉取
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用极狐GitLab 界面浏览代码仓库的内容和活动，即使它并非托管在极狐GitLab 上。创建拉取[镜像](_index.md)，将上游代码仓库的分支、标签和提交复制到您的代码仓库。

与[推送镜像](push.md)不同，拉取镜像会按计划从上游（远程）代码仓库检索更改。为防止镜像与上游代码仓库产生分歧，请勿直接向下游镜像推送提交。请将提交推送到上游代码仓库。远程代码仓库中的更改会按以下方式拉取到极狐GitLab 代码仓库：

- 自动拉取，在上次拉取 30 分钟后进行。此操作无法禁用。
- 当管理员[强制更新镜像](_index.md#force-an-update)时。
- 当[API 调用触发更新](#trigger-an-update-by-using-the-api)时。

UI 和 API 更新受默认的 5 分钟[拉取镜像间隔](../../../../administration/instance_limits.md#pull-mirroring-interval)限制。此间隔可在极狐GitLab 私有化部署实例上配置。

默认情况下，如果下游拉取镜像上的任何分支或标签与本地代码仓库产生分歧，极狐GitLab 将停止更新该分支。这可以防止数据丢失。上游代码仓库中已删除的分支和标签不会反映在下游代码仓库中。

> [!note]
> 从下游拉取镜像代码仓库中删除但仍存在于上游代码仓库中的条目，将在下次拉取时恢复。例如：仅在镜像代码仓库中删除的分支会在下次拉取后重新出现。

<a id="how-pull-mirroring-works"></a>

## 拉取镜像的工作原理

将极狐GitLab 代码仓库配置为拉取镜像后：

1. 极狐GitLab 将该代码仓库添加到队列中。
1. 每分钟一次，Sidekiq 定时作业会根据以下条件调度代码仓库镜像进行更新：
   - 可用容量，由 Sidekiq 设置决定。对于 JihuLab.com，请阅读 JihuLab.com Sidekiq 设置。
   - 队列中已存在且到期需要更新的镜像数量。是否到期取决于代码仓库镜像上次更新的时间，以及更新已重试的次数。
1. 当 Sidekiq 可用于处理更新时，镜像即被更新。如果更新过程：
   - 成功：更新会再次入队，并至少等待 30 分钟。
   - 失败：稍后会再次尝试更新。连续失败 14 次后，镜像将被标记为[硬失败](#fix-hard-failures-when-mirroring)，并且不再入队更新。分支与其上游对应分支产生分歧可能导致失败。为防止分支产生分歧，请在创建镜像时配置[覆盖已分歧的分支](#overwrite-diverged-branches)。

<a id="configure-pull-mirroring"></a>

## 配置拉取镜像

先决条件：

- 如果您的远程代码仓库位于 GitHub 且已配置[双因素认证 (2FA)](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa)，请创建具有 `repo` 范围的 [GitHub 个人访问令牌](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)。如果启用了 2FA，此个人访问令牌将用作您的 GitHub 密码。
- 未启用[极狐GitLab 静默模式](../../../../administration/silent_mode/_index.md)。
- 上游代码仓库和您的极狐GitLab 代码仓库使用相同的对象格式。您无法在 SHA-1 和 SHA-256 代码仓库之间进行镜像。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **代码仓库**。
1. 展开 **镜像代码仓库**。
1. 输入 **Git 代码仓库 URL**。

   > [!note]
   > 要镜像 `gitlab` 代码仓库，请使用 `jihulab.com:gitlab-cn/gitlab.git` 或 `https://jihulab.com/gitlab-cn/gitlab.git`。

1. 在 **镜像方向** 中，选择 **拉取**。
1. 在 **认证方法** 中，选择您的认证方法。更多信息，请参阅[镜像的认证方法](_index.md#authentication-methods-for-mirrors)。
1. 选择您需要的任何选项：
   - [**覆盖已分歧的分支**](#overwrite-diverged-branches)
   - [**为镜像更新触发流水线**](#trigger-pipelines-for-mirror-updates)
   - **仅镜像受保护的分支**
1. 要保存配置，请选择 **镜像代码仓库**。

<a id="overwrite-diverged-branches"></a>

### 覆盖已分歧的分支

要始终使用远程版本更新您的本地分支，即使它们已与远程产生分歧，请在创建镜像时选择 **覆盖已分歧的分支**。

> [!warning]
> 对于已镜像的分支，启用此选项将导致本地更改丢失。

<a id="trigger-pipelines-for-mirror-updates"></a>

### 为镜像更新触发流水线

您可以配置镜像，在远程代码仓库更新分支或标签时自动触发流水线。在启用此功能之前：

- 确保您的 CI Runner 能够处理远程代码仓库活动带来的额外负载。
- 考虑安全风险，因为流水线使用设置拉取镜像的用户的凭据。例如，恶意维护者可能：
  - 对远程代码仓库进行更新，尝试在流水线运行时获取存储的 CI/CD 变量值。
  - 如果启用了[**允许向项目代码仓库发起 Git 推送请求**](../../../../ci/jobs/ci_job_token.md#allow-git-push-requests-to-your-project-repository)设置，则向您的镜像项目推送提交。

> [!warning]
> 仅为您自己的项目或具有可信维护者的项目启用此功能。

<a id="pull-mirroring-with-sso-enforcement"></a>

## 使用 SSO 强制进行拉取镜像

当您的群组启用了 [SSO 强制](../../../group/saml_sso/_index.md#sso-enforcement)时，创建镜像的用户必须保持有效的 SSO 会话，否则镜像将失败。

要配置不依赖 SSO 会话的镜像，您可以使用[拉取镜像 API](../../../../api/project_pull_mirroring.md) 配合[项目访问令牌](../../settings/project_access_tokens.md)、[群组访问令牌](../../../group/settings/group_access_tokens.md)或[个人访问令牌](../../../profile/personal_access_tokens.md)用于服务账号。

<a id="trigger-an-update-by-using-the-api"></a>

## 使用 API 触发更新

拉取镜像使用轮询来检测上游新增的分支和提交，通常会在几分钟后检测到。您可以使用 [API 调用](../../../../api/project_pull_mirroring.md#start-the-pull-mirroring-process-for-a-project)通知极狐GitLab，但仍会强制执行[拉取镜像的最小间隔限制](_index.md#force-an-update)。

更多信息，请参阅[为项目启动拉取镜像过程](../../../../api/project_pull_mirroring.md#start-the-pull-mirroring-process-for-a-project)。

<a id="fix-hard-failures-when-mirroring"></a>

## 修复镜像时的硬失败

连续 14 次重试失败后，镜像过程将被标记为硬失败，并停止镜像尝试。此失败可在以下任一位置看到：

- 项目的主仪表板。
- 拉取镜像设置页面。

要恢复项目镜像，请[强制更新](_index.md#force-an-update)。

如果多个项目受此问题影响（例如在长时间网络或服务器中断后），您可以使用 [Rails 控制台](../../../../administration/operations/rails_console.md) 使用以下命令识别并更新所有受影响的项目：

```ruby
Project.find_each do |p|
  if p.import_state && p.import_state.retry_count >= 14
    puts "Resetting mirroring operation for #{p.full_path}"
    p.import_state.reset_retry_count
    p.import_state.set_next_execution_to_now(prioritized: true)
    p.import_state.save!
  end
end
```
