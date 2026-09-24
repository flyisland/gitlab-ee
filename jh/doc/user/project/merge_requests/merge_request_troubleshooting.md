---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Troubleshooting help for merge requests.
title: 排查合并请求
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在使用合并请求时，您可能会遇到以下问题。

<a id="merge-request-cannot-retrieve-the-pipeline-status"></a>

## 合并请求无法获取流水线状态

如果 Sidekiq 未能足够快地处理变更，就会出现这种情况。

<a id="sidekiq"></a>

### Sidekiq

Sidekiq 没有足够快地处理 CI 状态变更。请稍等几秒钟，状态应该会自动更新。

<a id="pipeline-status-cannot-be-retrieved"></a>

### 流水线状态无法获取

在以下情况下，无法获取合并请求的流水线状态：

1. 创建了一个合并请求
1. 该合并请求被关闭
1. 项目中发生了变更
1. 该合并请求被重新打开

要正确获取流水线状态，请再次关闭并重新打开该合并请求。

<a id="rebase-a-merge-request-from-the-rails-console"></a>

## 从 Rails 控制台变基合并请求

{{< details >}}

- Tier: 基础版，专业版，旗舰版

{{< /details >}}

除了 [`/rebase` 快速操作](../quick_actions.md#ready) 外，有权访问 [Rails 控制台](../../../administration/operations/rails_console.md) 的用户还可以从 Rails 控制台变基合并请求。请将 `<username>`、`<namespace/project>` 和 `<iid>` 替换为适当的值：

> [!warning]
> 任何直接更改数据的命令如果未正确运行或在适当的条件下，都可能造成损害。我们强烈建议在测试环境中运行这些命令，并准备好一份实例备份以备恢复，以防万一。

```ruby
u = User.find_by_username('<username>')
p = Project.find_by_full_path('<namespace/project>')
m = p.merge_requests.find_by(iid: <iid>)
MergeRequests::RebaseService.new(project: m.target_project, current_user: u).execute(m)
```

<a id="fix-incorrect-merge-request-status"></a>

## 修复不正确的合并请求状态

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果合并请求在其变更已合并后仍保持 **Open** 状态，有权访问 [Rails 控制台](../../../administration/operations/rails_console.md) 的用户可以纠正合并请求的状态。请将 `<username>`、`<namespace/project>` 和 `<iid>` 替换为适当的值：

> [!warning]
> 任何直接更改数据的命令如果未正确运行或在适当的条件下，都可能造成损害。我们强烈建议在测试环境中运行这些命令，并准备好一份实例备份以备恢复，以防万一。

```ruby
u = User.find_by_username('<username>')
p = Project.find_by_full_path('<namespace/project>')
m = p.merge_requests.find_by(iid: <iid>)
MergeRequests::PostMergeService.new(project: p, current_user: u).execute(m)
```

对包含未合并变更的合并请求运行此命令会导致该合并请求显示一条不正确的消息：`merged into <branch-name>`。

<a id="close-a-merge-request-from-the-rails-console"></a>

## 从 Rails 控制台关闭合并请求

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果通过 UI 或 API 无法关闭合并请求，请尝试在 [Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session) 中关闭：

> [!warning]
> 如果未正确运行或在适当的条件下，更改数据的命令可能会造成损害。请始终先在生产环境中调用之前测试所有更改，并准备好一份实例备份以备恢复。

```ruby
u = User.find_by_username('<username>')
p = Project.find_by_full_path('<namespace/project>')
m = p.merge_requests.find_by(iid: <iid>)
MergeRequests::CloseService.new(project: p, current_user: u).execute(m)
```

<a id="delete-a-merge-request-from-the-rails-console"></a>

## 从 Rails 控制台删除合并请求

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果通过 UI 或 API 无法删除合并请求，请尝试在 [Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session) 中删除：

> [!warning]
> 任何直接更改数据的命令如果未正确运行或在适当的条件下，都可能造成损害。我们强烈建议在测试环境中运行这些命令，并准备好一份实例备份以备恢复，以防万一。

```ruby
u = User.find_by_username('<username>')
p = Project.find_by_full_path('<namespace/project>')
m = p.merge_requests.find_by(iid: <iid>)
Issuable::DestroyService.new(container: m.project, current_user: u).execute(m)
```

<a id="merge-request-pre-receive-hook-failed"></a>

## 合并请求预接收钩子失败

如果合并请求超时，您可能会看到表明 Puma worker 超时问题的消息：

- 在极狐GitLab UI 中：

  ```plaintext
  出了点问题，在合并预接收钩子期间。
  500 Internal Server Error。请重试。
  ```

- 在 `gitlab-rails/api_json.log` 日志文件中：

  ```plaintext
  Rack::Timeout::RequestTimeoutException
  Request ran for longer than 60000ms
  ```

如果您的合并请求出现此错误，可能是因为：

- 包含大量差异。
- 落后目标分支很多个提交。
- 引用了一个已锁定的 Git LFS 文件。

私有化部署实例的用户可以请求管理员审查服务器日志以确定错误原因。JihuLab.com 用户应 [联系支持](https://gitlab.cn/support/#contact-support) 获取帮助。

<a id="cached-merge-request-count"></a>

## 缓存的合并请求计数

在群组中，侧边栏会显示打开状态的合并请求总数。如果此值大于 1000，则会被缓存。缓存值会四舍五入到千位（或百万位），并且每 24 小时更新一次。

<a id="check-out-merge-requests-locally-through-the-head-ref"></a>

## 通过 `head` 引用在本地检出合并请求

{{< history >}}

- 在 GitLab 16.4 中，在私有化部署和 JihuLab.com 上启用了合并请求关闭或合并后 14 天删除 `head` 引用。
- 在 GitLab 16.6 中，合并请求关闭或合并后 14 天删除 `head` 引用已 GA。功能标志 `merge_request_refs_cleanup` 已移除。

{{< /history >}}

合并请求包含仓库的所有历史记录，以及与合并请求关联的分支上添加的额外提交。以下是在本地检出合并请求的几种方法。

即使源项目是目标项目的派生（即使是私有派生），您也可以在本地检出合并请求。

这依赖于每个合并请求可用的合并请求 `head` 引用 (`refs/merge-requests/:iid/head`)。它允许使用合并请求的 ID 而不是其分支来检出合并请求。

在 GitLab 16.6 及更高版本中，合并请求关闭或合并后 14 天，其 `head` 引用会被删除。之后，该合并请求将不再能通过其 `head` 引用在本地检出。合并请求仍然可以重新打开。如果合并请求的分支仍然存在，您仍然可以检出该分支，因为它不受影响。

<a id="check-out-locally-using-glab"></a>

### 使用 `glab` 在本地检出

```plaintext
glab mr checkout <merge_request_iid>
```

更多信息请参考 [极狐GitLab 终端客户端](../../../editor_extensions/gitlab_cli/_index.md)。

<a id="check-out-locally-by-adding-a-git-alias"></a>

### 通过添加 Git 别名在本地检出

将以下别名添加到您的 `~/.gitconfig` 文件中：

```plaintext
[alias]
    mr = !sh -c 'git fetch $1 merge-requests/$2/head:mr-$1-$2 && git checkout mr-$1-$2' -
```

现在，您可以从任意仓库和任意远程检出特定的合并请求。例如，要在极狐GitLab 中从 `origin` 远程检出 ID 为 5 的合并请求，请执行：

```shell
git mr origin 5
```

这会将合并请求拉取到本地的 `mr-origin-5` 分支并将其检出。

<a id="check-out-locally-by-modifying-gitconfig-for-a-given-repository"></a>

### 通过修改给定仓库的 `.git/config` 在本地检出

在 `.git/config` 文件中找到您的极狐GitLab 远程配置部分。它看起来像这样：

```plaintext
[remote "origin"]
  url = https://gitlab.com/gitlab-org/gitlab-foss.git
  fetch = +refs/heads/*:refs/remotes/origin/*
```

您可以使用以下命令打开该文件：

```shell
git config -e
```

现在，将以下行添加到上述部分中：

```plaintext
fetch = +refs/merge-requests/*/head:refs/remotes/origin/merge-requests/*
```

最终，它应该看起来像这样：

```plaintext
[remote "origin"]
  url = https://gitlab.com/gitlab-org/gitlab-foss.git
  fetch = +refs/heads/*:refs/remotes/origin/*
  fetch = +refs/merge-requests/*/head:refs/remotes/origin/merge-requests/*
```

现在，您可以拉取所有的合并请求：

```shell
git fetch origin

...
From https://gitlab.com/gitlab-org/gitlab-foss.git
 * [new ref]         refs/merge-requests/1/head -> origin/merge-requests/1
 * [new ref]         refs/merge-requests/2/head -> origin/merge-requests/2
...
```

要检出特定的合并请求，请执行：

```shell
git checkout origin/merge-requests/1
```

这些命令也可以使用 [`git-mr`](https://gitlab.com/glensc/git-mr) 脚本来完成。

<a id="error-source-branch-branch_name-does-not-exist-when-the-branch-exists"></a>

## 错误：分支存在时显示 `源分支 <branch_name> 不存在。`

如果极狐GitLab 缓存没有反映 Git 仓库的实际状态，就可能会出现此错误。如果 Git 数据文件夹挂载时带有 `noexec` 标志，也可能发生此问题。

前提条件：

- 您必须是管理员。

要强制更新缓存：

1. 使用以下命令打开极狐GitLab Rails 控制台：

   ```shell
   sudo gitlab-rails console
   ```

1. 在 Rails 控制台中，运行以下脚本：

   ```ruby
   # Get the project
   project = Project.find_by_full_path('affected/project/path')

   # Check if the affected branch exists in cache (it may return `false`)
   project.repository.branch_names.include?('affected_branch_name')

   # Expire the branches cache
   project.repository.expire_branches_cache

   # Check again if the affected branch exists in cache (this time it should return `true`)
   project.repository.branch_names.include?('affected_branch_name')
   ```

1. 重新加载合并请求。

<a id="approvals-reset-when-automation-approves-a-merge-request"></a>

## 自动化审批合并请求时审批重置

如果您自动化创建合并请求或对其推送更改，您可能希望为这些合并请求构建自动化审批。在极狐GitLab 专业版和旗舰版中，默认情况下，[当向源分支添加提交时](approvals/settings.md#remove-all-approvals-when-commits-are-added-to-the-source-branch)，所有审批都会被移除。为避免此问题，请在您的自动化中添加逻辑，确保在审批合并请求之前 [先处理提交](../../../api/merge_request_approvals.md#prevent-approval-resets-in-automated-merge-requests)。

<a id="merge-request-unexpectedly-marked-as-merged"></a>

## 合并请求意外标记为已合并

如果已合并的合并请求包含一条 `merged manually` 系统备注，则说明源分支的提交要么是在极狐GitLab UI 外部合并的，要么是作为另一个合并请求的一部分合并的。

<a id="merged-outside-the-gitlab-ui"></a>

### 在极狐GitLab UI 外部合并

当您使用 `git merge` 在 UI 外部将分支直接合并到目标分支时，极狐GitLab 会检测到此操作并将合并请求标记为 `merged manually`。

当允许直接推送到目标分支时，就可能会发生这种情况。为防止这种情况，您可以保护目标分支，并将其配置为不允许直接推送（**Allowed to push and merge** 设置为 **No one**）。

有关更多信息，请参见 [保护分支](../repository/branches/protected.md#protect-a-branch)。

<a id="merged-as-part-of-a-different-merge-request"></a>

### 作为其他合并请求的一部分合并

该合并请求包含的提交已经作为另一个合并请求的一部分合并了。如果这发生在受保护的分支上，则提交在合并之前已经根据受保护分支的设置获得了审批。

有关更多信息，请参见 [多个分支包含相同提交](../repository/branches/_index.md#multiple-branches-containing-the-same-commit)。

> [!note]
> 在某些情况下，极狐GitLab 可能会显示 `merged manually` 而不是 `Merged with !<merge_request_id>`。