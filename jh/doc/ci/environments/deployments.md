---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 部署
description: 部署、回滚、安全性和审批。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当您将某个版本的代码部署到环境时，就创建了一次部署。每个环境通常只有一个活跃的部署。

极狐GitLab：

- 提供每个环境的完整部署历史。
- 跟踪您的部署，因此您始终清楚服务器上部署了什么。

如果您的项目关联了诸如 [Kubernetes](../../user/infrastructure/clusters/_index.md) 之类的部署服务，您可以使用它来协助部署。

部署创建后，您可以将其发布给用户。

<a id="configure-manual-deployments"></a>

## 配置手动部署

您可以创建一个需要有人手动启动部署的作业。例如：

```yaml
deploy_prod:
  stage: deploy
  script:
    - echo "Deploy to production server"
  environment:
    name: production
    url: https://example.com
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      when: manual
```

`when: manual` 操作：

- 在极狐GitLab UI 中为该作业显示**运行**（{{< icon name="play" >}}）按钮，按钮文本为**可手动部署到 `<environment>`**。
- 表示 `deploy_prod` 作业必须手动触发。

您可以在流水线、环境、部署和作业视图中找到**运行**（{{< icon name="play" >}}）。

<a id="track-newly-included-merge-requests-per-deployment"></a>

## 跟踪每次部署中新纳入的合并请求

极狐GitLab 可以跟踪每次部署中新纳入的合并请求。当部署成功时，系统会计算最新部署与上一次部署之间的提交差异。您可以使用[部署 API](../../api/deployments.md#list-all-merge-requests-associated-with-a-deployment) 获取跟踪信息，或在[合并请求页面](../../user/project/merge_requests/_index.md)的合并后流水线中查看。

要启用跟踪，请配置您的环境，使其满足以下任一条件：

- [环境名称](../yaml/_index.md#environmentname)不使用带 `/` 的文件夹（长期存在或顶层环境）。
- [环境层级](_index.md#deployment-tier-of-environments)为 `production` 或 `staging`。

  以下是一些在 `.gitlab-ci.yml`中使用 [`environment` 关键字](../yaml/_index.md#environment)的示例配置：

  ```yaml
  # Trackable
  environment: production
  environment: production/aws
  environment: development

  # Non Trackable
  environment: review/$CI_COMMIT_REF_SLUG
  environment: testing/aws
  ```

配置更改仅适用于新的部署。现有部署记录不会关联或取消关联合并请求。

<a id="check-out-deployments-locally"></a>

## 在本地检出部署

每次部署都会在 Git 代码仓库中保存一个引用，因此只需执行一次 `git fetch` 即可了解当前环境的状态。

在您的 Git 配置中，为 `[remote "<your-remote>"]` 块追加一行额外的 fetch 配置：

```plaintext
fetch = +refs/environments/*:refs/remotes/origin/environments/*
```

<a id="archive-old-deployments"></a>

## 归档旧部署

当您的项目中发生新部署时，极狐GitLab 会[为该部署创建一个特殊的 Git 引用](#check-out-deployments-locally)。由于这些 Git 引用是从远程极狐GitLab 代码仓库填充的，您可能会发现，随着项目中部署数量的增加，某些 Git 操作（例如 `git-fetch` 和 `git-pull`）会变慢。

为保持 Git 操作的效率，极狐GitLab 仅保留最近的部署引用（最多 50,000 个），并删除其余旧部署引用。已归档的部署仍可在 UI 中或通过 API 用于审计目的。此外，即使在部署被归档后，您仍然可以通过指定提交 SHA（例如 `git checkout <deployment-sha>`）从代码仓库中获取已部署的提交。

> [!note]
> 极狐GitLab 会将所有提交保留为 [`keep-around` 引用](../../user/project/repository/repository_size.md#methods-to-reduce-repository-size)，
> 因此已部署的提交不会被垃圾回收，即使它们未被部署引用所引用。

<a id="deployment-rollback"></a>

## 部署回滚

当您回滚到特定提交上的部署时，会创建一个新部署。该部署有其自己唯一的作业 ID。它指向您要回滚到的提交。

要使回滚成功，必须在作业的 `script`中定义部署过程。

仅运行[部署作业](../jobs/_index.md#deployment-jobs)。如果之前的作业生成了必须在部署时重新生成的产物，您必须从流水线页面手动运行必要的作业。例如，如果您使用 Terraform，并且您的 `plan` 和 `apply` 命令被拆分到多个作业中，则必须手动运行这些作业来部署或回滚。

<a id="retry-or-roll-back-a-deployment"></a>

### 重试或回滚部署

如果部署出现问题，您可以重试或回滚它。

要重试或回滚部署：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**运维** > **环境**。
1. 选择该环境。
1. 在部署名称右侧：
   - 要重试部署，请选择**重新部署到环境**。
   - 要回滚到某个部署，请在之前成功的部署旁边选择**回滚环境**。

> [!note]
> 如果您的项目中[阻止了过期的部署作业](deployment_safety.md#prevent-outdated-deployment-jobs)，
> 回滚按钮可能会被隐藏或禁用。
> 在这种情况下，请参阅[回滚部署的作业重试](deployment_safety.md#job-retries-for-rollback-deployments)。

<a id="troubleshooting"></a>

## 故障排除

使用部署时，您可能会遇到以下问题。

<a id="deployment-refs-are-not-found"></a>

### 找不到部署引用

极狐GitLab 会[删除旧的部署引用](#archive-old-deployments)，以保持 Git 代码仓库的性能。

如果您必须在极狐GitLab 私有化部署上恢复已归档的 Git 引用，请让管理员在 Rails 控制台上执行以下命令：

```ruby
Project.find_by_full_path(<your-project-full-path>).deployments.where(archived: true).each(&:create_ref)
```

出于性能方面的考虑，极狐GitLab 将来可能会放弃此支持。您可以在 [GitLab 议题跟踪器](https://gitlab.com/gitlab-org/gitlab/-/work_items/new)中创建议题，讨论此功能的行为。
