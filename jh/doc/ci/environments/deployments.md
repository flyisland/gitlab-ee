---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 部署
description: Deployments, rollbacks, safety, and approvals.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当您将代码的一个版本部署到某个环境时，您就创建了一个部署。每个环境通常只有一个活跃部署。

极狐GitLab：

- 提供每个环境的完整部署历史。
- 跟踪您的部署，因此您始终知道服务器上部署了什么。

如果您的项目关联了像 [Kubernetes](../../user/infrastructure/clusters/_index.md) 这样的部署服务，您可以使用它来辅助您的部署。

部署创建后，您可以将其推送给用户。

<a id="configure-manual-deployments"></a>

## 配置手动部署

您可以创建一个需要有人手动启动部署的作业。例如：

```yaml
deploy_prod:
  stage: deploy
  script:
    - echo "部署到生产服务器"
  environment:
    name: production
    url: https://example.com
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      when: manual
```

`when: manual` 操作：

- 在极狐GitLab UI 中为该作业显示 **运行** ({{< icon name="play" >}}) 按钮，并带有文本 **可手动部署到 `<environment>`**。
- 表示 `deploy_prod` 作业必须手动触发。

您可以在流水线、环境、部署和作业视图中找到 **运行** ({{< icon name="play" >}})。

<a id="track-newly-included-merge-requests-per-deployment"></a>

## 跟踪每个部署中新包含的合并请求

极狐GitLab 可以跟踪每个部署中新包含的合并请求。当部署成功时，系统会计算最新部署与上一次部署之间的提交差异。您可以使用 [部署 API](../../api/deployments.md#list-all-merge-requests-associated-with-a-deployment) 获取跟踪信息，或在 [合并请求页面](../../user/project/merge_requests/_index.md) 的合并后流水线中查看。

要启用跟踪，请配置您的环境，满足以下任一条件：

- [环境名称](../yaml/_index.md#environmentname) 不使用带 `/` 的文件夹（长期存在或顶级环境）。
- [环境层级](_index.md#deployment-tier-of-environments) 是 `production` 或 `staging`。

以下是在 `.gitlab-ci.yml` 中使用 [`environment` 关键词](../yaml/_index.md#environment) 的一些示例配置：

```yaml
# 可跟踪
environment: production
environment: production/aws
environment: development

# 不可跟踪
environment: review/$CI_COMMIT_REF_SLUG
environment: testing/aws
```

配置更改仅适用于新的部署。现有的部署记录不会因此关联或取消关联合并请求。

<a id="check-out-deployments-locally"></a>

## 在本地检出部署

每次部署都会在 Git 仓库中保存一个引用，因此只需执行 `git fetch` 即可了解当前环境的状态。

在您的 Git 配置中，在 `[remote "<your-remote>"]` 块中追加一个额外的 fetch 行：

```plaintext
fetch = +refs/environments/*:refs/remotes/origin/environments/*
```

<a id="archive-old-deployments"></a>

## 归档旧部署

当您的项目中发生新部署时，极狐GitLab 会为部署创建 [一个特殊的 Git 引用](#check-out-deployments-locally)。由于这些 Git 引用是从远程极狐GitLab 仓库填充的，您可能会发现随着项目中部署数量的增加，某些 Git 操作（如 `git-fetch` 和 `git-pull`）会变慢。

为了保持 Git 操作的效率，极狐GitLab 仅保留最近的部署引用（最多 50,000 个），并删除其余的旧部署引用。已归档的部署仍然可通过 UI 或 API 获取，用于审计目的。此外，即使归档后，您仍然可以通过指定提交 SHA（例如 `git checkout <deployment-sha>`）从仓库中获取已部署的提交。

> [!note]
> 极狐GitLab 将所有提交保留为 [`keep-around` 引用](../../user/project/repository/repository_size.md#methods-to-reduce-repository-size)，这样即使部署引用不再引用它们，已部署的提交也不会被垃圾回收。

<a id="deployment-rollback"></a>

## 部署回滚

当您回滚到特定提交上的部署时，会创建一个新的部署。该部署具有自己唯一的作业 ID。它指向您要回滚到的提交。

要使回滚成功，必须在作业的 `script` 中定义部署过程。

只有 [部署作业](../jobs/_index.md#deployment-jobs) 会运行。如果之前的作业生成了在部署时必须重新生成的产物，您必须从流水线页面手动运行必要的作业。例如，如果您使用 Terraform 并且您的 `plan` 和 `apply` 命令被分到多个作业中，您必须手动运行这些作业来进行部署或回滚。

<a id="retry-or-roll-back-a-deployment"></a>

### 重试或回滚部署

如果部署出现问题，您可以重试或回滚它。

要重试或回滚部署：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **运维** > **环境**。
1. 选择环境。
1. 在部署名称的右侧：
   - 要重试部署，请选择 **重新部署到环境**。
   - 要回滚到某个部署，请在之前成功的部署旁边选择 **回滚环境**。

> [!note]
> 如果您的项目中 [阻止了过时的部署作业](deployment_safety.md#prevent-outdated-deployment-jobs)，回滚按钮可能会被隐藏或禁用。在这种情况下，请参阅 [回滚部署的作业重试](deployment_safety.md#job-retries-for-rollback-deployments)。

<a id="troubleshooting"></a>

## 故障排除

在使用部署时，您可能会遇到以下问题。

<a id="deployment-refs-are-not-found"></a>

### 找不到部署引用

极狐GitLab [会删除旧的部署引用](#archive-old-deployments) 以保持 Git 仓库的性能。

如果您必须在私有化部署的极狐GitLab 上恢复已归档的 Git 引用，请让管理员在 Rails 控制台中执行以下命令：

```ruby
Project.find_by_full_path(<your-project-full-path>).deployments.where(archived: true).each(&:create_ref)
```

出于性能考虑，极狐GitLab 未来可能会放弃此支持。您可以在 [极狐GitLab 议题跟踪器](https://jihulab.com/gitlab-cn/gitlab/-/issues/new) 中打开一个议题来讨论此功能的行为。