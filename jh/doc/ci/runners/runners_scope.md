---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解 Runner 的类型、可用性以及如何管理它们。
title: 管理 Runner
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab Runner 具有以下类型的 Runner，具体可用类型取决于您希望哪些对象拥有访问权限：

- [实例 Runner](#instance-runners) 可供极狐GitLab 实例中的所有群组和项目使用。
- [群组 Runner](#group-runners) 可供群组中的所有项目和子群组使用。
- [项目 Runner](#project-runners) 与特定项目关联。
  通常，项目 Runner 一次只供一个项目使用。

<a id="instance-runners"></a>

## 实例 Runner

实例 Runner 可供极狐GitLab 实例中的每个项目使用。

当您有多个需求相似的作业时，请使用实例 Runner。与其让多个 Runner 为许多项目闲置，不如让少量 Runner 处理多个项目。

如果您使用的是极狐GitLab 私有化部署，管理员可以：

- [安装极狐GitLab Runner](https://gitlab.cn/docs/runner/install/) 并注册一个实例 Runner。
- 配置每个群组的实例 Runner [最大计算分钟数](../../administration/cicd/compute_minutes.md#set-the-compute-quota-for-a-group)。

如果您使用的是 JihuLab.com：

- 您可以从[极狐GitLab 维护的实例 Runner](_index.md) 列表中进行选择。
- 实例 Runner 会消耗您账户中包含的[计算分钟数](../pipelines/compute_minutes.md)。

<a id="create-an-instance-runner-with-a-runner-authentication-token"></a>

### 使用 Runner 身份验证令牌创建实例 Runner

先决条件：

- 您必须是管理员。

创建 Runner 时，系统会为其分配一个 Runner 身份验证令牌，您可以使用该令牌注册它。Runner 在从作业队列中获取作业时，会使用该令牌向极狐GitLab 进行身份验证。

要创建实例 Runner：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 选择**创建实例 Runner**。
1. 选择安装极狐GitLab Runner 的操作系统。
1. 在**标签**部分的**标签**字段中，输入作业标签以指定该 Runner 可以运行的作业。
   如果该 Runner 没有作业标签，请选择**运行未标记的作业**。
1. 可选。在 **Runner 描述**字段中，输入一个会在极狐GitLab 中显示的 Runner 描述。
1. 可选。在**配置**部分中，添加其他配置。
1. 选择**创建 Runner**。
1. 按照屏幕上的说明从命令行注册该 Runner。当命令行提示时：
   - 对于 `GitLab instance URL`，使用您的极狐GitLab 实例的 URL。例如，如果您的项目
     托管在 `gitlab.example.com/yourname/yourproject` 上，则您的极狐GitLab 实例 URL 为 `https://gitlab.example.com`。
   - 对于 `executor`，输入[执行器](https://gitlab.cn/docs/runner/executors/)的类型。执行器是
     Runner 执行作业的环境。

您也可以[使用 API](../../api/users.md#create-a-runner-linked-to-a-user) 创建 Runner。

> [!note]
> Runner 身份验证令牌在注册期间会在 UI 中显示有限的一段时间。注册 Runner 后，
> 该身份验证令牌会存储在 `config.toml`中。

<a id="create-an-instance-runner-with-a-registration-token-deprecated"></a>

### 使用注册令牌创建实例 Runner（已弃用）

> [!warning]
> 传递 Runner 注册令牌的选项以及对某些配置参数的支持被视为旧版功能，
> 不建议使用。
> 请使用 [Runner 创建工作流](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 生成身份验证令牌来注册 Runner。此流程可提供 Runner 所有权的完整
> 可追溯性，并增强您 Runner 集群的安全性。
> 有关更多信息，请参阅
> [迁移到新的 Runner 注册工作流](new_creation_workflow.md)。

先决条件：

- 必须在**管理员**区域中[启用](../../administration/settings/continuous_integration.md#control-runner-registration) Runner 注册令牌。
- 您必须是管理员。

要创建实例 Runner：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 选择**注册实例 Runner**。
1. 复制注册令牌。
1. [注册该 Runner](https://gitlab.cn/docs/runner/register/#register-with-a-runner-registration-token-legacy)。

<a id="pause-or-resume-an-instance-runner"></a>

### 暂停或恢复实例 Runner

先决条件：

- 您必须是管理员。

您可以暂停 Runner，使其不再接受极狐GitLab 实例中群组和项目的作业。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 在搜索框中，输入 Runner 描述或筛选 Runner 列表。
1. 在 Runner 列表中，在 Runner 右侧：
   - 要暂停该 Runner，请选择**暂停**（{{< icon name="pause" >}}）。
   - 要恢复该 Runner，请选择**恢复**（{{< icon name="play" >}}）。

<a id="delete-instance-runners"></a>

### 删除实例 Runner

先决条件：

- 您必须是管理员。

删除实例 Runner 时，它会从极狐GitLab 实例中永久删除，并且群组和项目将无法再使用它。如果您想暂时阻止该 Runner 接受
作业，可以改为[暂停](#pause-or-resume-an-instance-runner)该 Runner。

要删除单个或多个实例 Runner：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 在搜索框中，输入 Runner 描述或筛选 Runner 列表。
1. 删除实例 Runner：
   - 要删除单个 Runner，请在该 Runner 旁边选择**删除 Runner**（{{< icon name="remove" >}}）。
   - 要删除多个实例 Runner，请选中每个 Runner 的复选框，然后选择**删除所选**。
   - 要删除所有 Runner，请选中 Runner 列表顶部的复选框，然后选择**删除所选**。
1. 选择**永久删除 Runner**。

<a id="enable-instance-runners-for-a-project"></a>

### 为项目启用实例 Runner

在 JihuLab.com 上，[实例 Runner](_index.md) 默认在所有项目中
启用。

在极狐GitLab 私有化部署上，管理员可以
[为所有新项目启用它们](../../administration/settings/continuous_integration.md#enable-instance-runners-for-new-projects)。

对于现有项目，管理员必须
[安装](https://gitlab.cn/docs/runner/install/)并
[注册](https://gitlab.cn/docs/runner/register/)它们。

要为项目启用实例 Runner：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runners**。
1. 启用**为此项目开启实例 Runner** 开关。

<a id="enable-instance-runners-for-a-group"></a>

### 为群组启用实例 Runner

要为群组启用实例 Runner：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runners**。
1. 启用**为此群组开启实例 Runner** 开关。

<a id="disable-instance-runners-for-a-project"></a>

### 为项目禁用实例 Runner

您可以为单个项目或群组禁用实例 Runner。您必须拥有该项目的所有者角色或群组的所有者角色。

要为项目禁用实例 Runner：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runners**。
1. 在**实例 Runner** 区域中，关闭**为此项目开启 Runner** 开关。

在以下情况下，实例 Runner 会自动为项目禁用：

- 如果父群组的实例 Runner 设置已禁用，并且
- 如果不允许项目覆盖此设置。

<a id="disable-instance-runners-for-a-group"></a>

### 为群组禁用实例 Runner

要为群组禁用实例 Runner：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runners**。
1. 关闭**为此群组启用实例 Runner** 开关。
1. 可选。要允许为单个项目或子群组启用实例 Runner，
   请选择**允许项目和子群组覆盖群组设置**。

<a id="how-instance-runners-pick-jobs"></a>

### 实例 Runner 如何获取作业

实例 Runner 使用公平使用队列来处理作业。此队列可防止项目创建数百个作业并占用所有可用的
实例 Runner 资源。

公平使用队列算法会根据已在实例 Runner 上运行的作业数量最少的项目来分配作业。

例如，如果队列中有以下作业：

- 项目 1 的作业 1
- 项目 1 的作业 2
- 项目 1 的作业 3
- 项目 2 的作业 4
- 项目 2 的作业 5
- 项目 3 的作业 6

当多个 CI/CD 作业并发运行时，公平使用算法会按以下顺序分配作业：

1. 作业 1 最先，因为它是没有正在运行作业的项目（即所有项目）中编号最低的作业。
1. 接下来是作业 4，因为 4 现在是没有正在运行作业的项目中编号最低的作业（项目 1 有一个作业正在运行）。
1. 接下来是作业 6，因为 6 现在是没有正在运行作业的项目中编号最低的作业（项目 1 和 2 都有作业正在运行）。
1. 接下来是作业 2，因为在正在运行作业数量最少的项目（每个都有 1 个）中，它的作业编号最低。
1. 接下来是作业 5，因为项目 1 现在有 2 个作业正在运行，而作业 5 是项目 2 和 3 之间剩余编号最低的作业。
1. 最后是作业 3，因为它是唯一剩下的作业。

当一次只运行一个作业时，公平使用算法会按以下顺序分配作业：

1. 首先选择作业 1，因为它是没有正在运行作业的项目（即所有项目）中编号最低的作业。
1. 作业 1 完成。
1. 接下来是作业 2，因为作业 1 完成后，所有项目又都有 0 个正在运行的作业，而 2 是可用编号最低的作业。
1. 接下来是作业 4，因为项目 1 有一个作业正在运行，4 是没有正在运行作业的项目（项目 2 和 3）中编号最低的作业。
1. 作业 4 完成。
1. 接下来是作业 5，因为作业 4 完成后，项目 2 又没有正在运行的作业了。
1. 接下来是作业 6，因为项目 3 是唯一剩下没有正在运行作业的项目。
1. 最后是作业 3，因为它是唯一剩下的作业。

<a id="group-runners"></a>

## 群组 Runner

当您希望群组中的所有项目都能访问一组 Runner 时，请使用群组 Runner。

群组 Runner 使用先进先出队列来处理作业。

<a id="create-a-group-runner-with-a-runner-authentication-token"></a>

### 使用 Runner 身份验证令牌创建群组 Runner

先决条件：

- 您必须拥有该群组的所有者角色。

您可以为极狐GitLab 私有化部署或 JihuLab.com 创建群组 Runner。
创建 Runner 时，系统会为其分配一个 Runner 身份验证令牌，您可以使用该令牌注册它。Runner 在从作业队列中获取作业时，会使用该令牌向极狐GitLab 进行身份验证。

要创建群组 Runner：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**构建** > **Runners**。
1. 选择**创建群组 Runner**。
1. 在**标签**部分的**标签**字段中，输入作业标签以指定该 Runner 可以运行的作业。
   如果该 Runner 没有作业标签，请选择**运行未标记的作业**。
1. 可选。在 **Runner 描述**字段中，添加一个会在极狐GitLab 中显示的
   Runner 描述。
1. 可选。在**配置**部分中，添加其他配置。
1. 选择**创建 Runner**。
1. 选择安装极狐GitLab Runner 的平台。
1. 完成屏幕上的说明：
   - 对于 Linux、macOS 和 Windows，当命令行提示时：
     - 对于 `GitLab instance URL`，使用您的极狐GitLab 实例的 URL。例如，如果您的项目
       托管在 `gitlab.example.com/yourname/yourproject` 上，则您的极狐GitLab 实例 URL 为 `https://gitlab.example.com`。
     - 对于 `executor`，输入[执行器](https://gitlab.cn/docs/runner/executors/)的类型。
       执行器是 Runner 执行作业的环境。
   - 对于 Google Cloud，请参阅[在 Google Cloud 中预配 Runner](provision_runners_google_cloud.md)。

您也可以[使用 API](../../api/users.md#create-a-runner-linked-to-a-user) 创建 Runner。

> [!note]
> Runner 身份验证令牌在注册期间只会在 UI 中显示很短的一段时间。

<a id="create-a-group-runner-with-a-registration-token-deprecated"></a>

### 使用注册令牌创建群组 Runner（已弃用）

> [!warning]
> 传递 Runner 注册令牌的选项以及对某些配置参数的支持被视为旧版功能，
> 不建议使用。
> 请使用 [Runner 创建工作流](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 生成身份验证令牌来注册 Runner。此流程可提供 Runner 所有权的完整
> 可追溯性，并增强您 Runner 集群的安全性。
> 有关更多信息，请参阅
> [迁移到新的 Runner 注册工作流](new_creation_workflow.md)。

先决条件：

- 必须在顶层群组中[启用](#enable-use-of-runner-registration-tokens-in-projects-and-groups) Runner 注册令牌。
- 您必须拥有该群组的所有者角色。

要创建群组 Runner：

1. [安装极狐GitLab Runner](https://gitlab.cn/docs/runner/install/)。
1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**构建** > **Runners**。
1. 在右上角，选择**注册群组 Runner**。
1. 选择**显示 Runner 安装和注册说明**。
   这些说明包括令牌、URL 以及用于注册 Runner 的命令。

或者，您可以复制注册令牌，并按照文档
[注册 Runner](https://gitlab.cn/docs/runner/register/#register-with-a-runner-registration-token-legacy)。

<a id="view-group-runners"></a>

### 查看群组 Runner

先决条件：

- 您必须拥有该群组的维护者或所有者角色。

您可以查看群组及其子群组和项目的所有 Runner。您可以对极狐GitLab 私有化部署或 JihuLab.com 执行此操作。

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**构建** > **Runners**。

<a id="filter-group-runners-to-show-only-inherited"></a>

#### 筛选群组 Runner 以仅显示继承的 Runner

您可以选择显示列表中的所有 Runner，或仅显示从实例或其他群组继承的 Runner。

默认情况下，仅显示继承的 Runner。

要显示实例中所有可用的 Runner，包括实例 Runner 和其他群组中的 Runner：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**构建** > **Runners**。
1. 在列表上方，关闭**仅显示继承的 Runner** 开关。

<a id="pause-or-resume-a-group-runner"></a>

### 暂停或恢复群组 Runner

先决条件：

- 您必须是管理员，或拥有该群组的所有者角色。

您可以暂停 Runner，使其不再接受极狐GitLab 实例中子群组和项目的作业。如果您暂停一个被多个项目使用的群组 Runner，该 Runner 会为所有项目暂停。

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**构建** > **Runners**。
1. 在搜索框中，输入 Runner 描述或筛选 Runner 列表。
1. 在 Runner 列表中，在 Runner 右侧：
   - 要暂停该 Runner，请选择**暂停**（{{< icon name="pause" >}}）。
   - 要恢复该 Runner，请选择**恢复**（{{< icon name="play" >}}）。

<a id="delete-a-group-runner"></a>

### 删除群组 Runner

先决条件：

- 您必须是管理员，或拥有该群组的所有者角色。

删除群组 Runner 时，它会从极狐GitLab 实例中永久删除，并且子群组和项目将无法再使用它。如果您想暂时阻止该 Runner 接受
作业，可以改为[暂停](#pause-or-resume-a-group-runner)该 Runner。

要删除单个或多个群组 Runner：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**构建** > **Runners**。
1. 在搜索框中，输入 Runner 描述或筛选 Runner 列表。
1. 删除群组 Runner：
   - 要删除单个 Runner，请在该 Runner 旁边选择**删除 Runner**（{{< icon name="remove" >}}）。
   - 要删除多个实例 Runner，请选中每个 Runner 的复选框，然后选择**删除所选**。
   - 要删除所有 Runner，请选中 Runner 列表顶部的复选框，然后选择**删除所选**。
1. 选择**永久删除 Runner**。

<a id="clean-up-stale-group-runners"></a>

### 清理过期的群组 Runner

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

先决条件：

- 您必须拥有该群组的所有者角色。

您可以清理已超过七天未活动的群组 Runner。

群组 Runner 是指在特定群组中创建的 Runner。

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runners**。
1. 开启**启用过期 Runner 清理**开关。

<a id="view-stale-runner-cleanup-logs"></a>

#### 查看过期 Runner 清理日志

您可以查看 [Sidekiq 日志](../../administration/logs/_index.md#sidekiq-logs)以了解清理结果。在 Kibana 中，您可以使用以下查询：

```json
{
  "query": {
    "match_phrase": {
      "json.class.keyword": "Ci::Runners::StaleGroupRunnersPruneCronWorker"
    }
  }
}
```

筛选已移除过期 Runner 的条目：

```json
{
  "query": {
    "range": {
      "json.extra.ci_runners_stale_group_runners_prune_cron_worker.total_pruned": {
        "gte": 1,
        "lt": null
      }
    }
  }
}
```

<a id="project-runners"></a>

## 项目 Runner

当您想为特定项目使用 Runner 时，请使用项目 Runner。例如，当您有以下情况时：

- 具有特定需求的作业，例如需要凭据的部署作业。
- 具有大量 CI 活动、可以从与其他 Runner 分离中受益的项目。

您可以将一个项目 Runner 设置为供多个项目使用。项目 Runner 必须为每个项目显式启用。

项目 Runner 使用先进先出（[FIFO](https://en.wikipedia.org/wiki/FIFO_(computing_and_electronics))）队列来处理作业。

> [!note]
> 项目 Runner 不会自动为 forked 的项目启用。
> fork 会复制被克隆代码仓库的 CI/CD 设置。

<a id="project-runner-ownership"></a>

### 项目 Runner 的所有权

当 Runner 首次连接到某个项目时，该项目将成为该 Runner 的所有者。

如果您删除所有者项目：

1. 极狐GitLab 会查找共享该 Runner 的所有其他项目。
1. 极狐GitLab 会将所有权分配给关联时间最早的项目。
1. 如果没有其他项目共享该 Runner，极狐GitLab 会自动删除该 Runner。

您无法取消将 Runner 分配给所有者项目。请改为删除该 Runner。

<a id="create-a-project-runner-with-a-runner-authentication-token"></a>

### 使用 Runner 身份验证令牌创建项目 Runner

先决条件：

- 您必须拥有该项目的维护者角色。

您可以为极狐GitLab 私有化部署或 JihuLab.com 创建项目 Runner。创建 Runner 时，
系统会为其分配一个 Runner 身份验证令牌，您可以使用该令牌注册它。Runner 在从作业队列中获取作业时，会使用该令牌向极狐GitLab 进行身份验证。

要创建项目 Runner：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runners** 部分。
1. 选择**创建项目 Runner**。
1. 选择安装极狐GitLab Runner 的操作系统。
1. 在**标签**部分的**标签**字段中，输入作业标签以指定该 Runner 可以运行的作业。
   如果该 Runner 没有作业标签，请选择**运行未标记的作业**。
1. 可选。在 **Runner 描述**字段中，添加一个会在极狐GitLab 中显示的
   Runner 描述。
1. 可选。在**配置**部分中，添加其他配置。
1. 选择**创建 Runner**。
1. 选择安装极狐GitLab Runner 的平台。
1. 完成屏幕上的说明：
   - 对于 Linux、macOS 和 Windows，当命令行提示时：
     - 对于 `GitLab instance URL`，使用您的极狐GitLab 实例的 URL。例如，如果您的项目
       托管在 `gitlab.example.com/yourname/yourproject` 上，则您的极狐GitLab 实例 URL 为 `https://gitlab.example.com`。
     - 对于 `executor`，输入[执行器](https://gitlab.cn/docs/runner/executors/)的类型。
       执行器是 Runner 执行作业的环境。
   - 对于 Google Cloud，请参阅[在 Google Cloud 中预配 Runner](provision_runners_google_cloud.md)。

您也可以[使用 API](../../api/users.md#create-a-runner-linked-to-a-user) 创建 Runner。

> [!note]
> Runner 身份验证令牌在注册期间只会在 UI 中显示很短的一段时间。

<a id="create-a-project-runner-with-a-registration-token-deprecated"></a>

### 使用注册令牌创建项目 Runner（已弃用）

> [!warning]
> 传递 Runner 注册令牌的选项以及对某些配置参数的支持被视为旧版功能，
> 不建议使用。
> 请使用 [Runner 创建工作流](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 生成身份验证令牌来注册 Runner。此流程可提供 Runner 所有权的完整
> 可追溯性，并增强您 Runner 集群的安全性。
> 有关更多信息，请参阅
> [迁移到新的 Runner 注册工作流](new_creation_workflow.md)。

先决条件：

- 必须在顶层群组中[启用](#enable-use-of-runner-registration-tokens-in-projects-and-groups) Runner 注册令牌。
- 您必须拥有该项目的维护者或所有者角色。

要创建项目 Runner：

1. [安装极狐GitLab Runner](https://gitlab.cn/docs/runner/install/)。
1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runners**。
1. 在**项目 Runner** 部分中，记下 URL 和令牌。
1. [注册该 Runner](https://gitlab.cn/docs/runner/register/#register-with-a-runner-registration-token-legacy)。

该 Runner 现在已为该项目启用。

<a id="pause-or-resume-a-project-runner"></a>

### 暂停或恢复项目 Runner

先决条件：

- 您必须是管理员，或拥有该项目的维护者角色。

您可以暂停项目 Runner，使其不再接受极狐GitLab 实例中分配给它的项目的作业。

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runners**。
1. 在**已分配的项目 Runner** 部分中，找到该 Runner。
1. 在该 Runner 右侧：
   - 要暂停该 Runner，请选择**暂停**（{{< icon name="pause" >}}），然后选择**暂停**。
   - 要恢复该 Runner，请选择**恢复**（{{< icon name="play" >}}）。

<a id="delete-a-project-runner"></a>

### 删除项目 Runner

先决条件：

- 您必须是管理员，或拥有该项目的维护者角色。
- 您无法删除分配给多个项目的项目 Runner。在删除该 Runner 之前，您必须在所有已启用它的项目中[禁用它](#enable-a-project-runner-for-a-different-project)。

删除项目 Runner 时，它会从极狐GitLab 实例中永久删除，并且项目将无法再使用它。如果您想暂时阻止该 Runner 接受
作业，可以改为[暂停](#pause-or-resume-a-project-runner)该 Runner。

删除 Runner 时，其配置仍存在于 Runner 主机的 `config.toml` 文件中。如果已删除 Runner 的配置仍存在于该文件中，Runner 主机会继续联系极狐GitLab。为防止不必要的 API 流量，您还必须
[注销已删除的 Runner](https://gitlab.cn/docs/runner/commands/#gitlab-runner-unregister)。

1. 在顶部栏中，选择**搜索或跳转到**并找到该项目。
1. 选择**设置** > **CI/CD**。
1. 展开 **Runners**。
1. 在**已分配的项目 Runner** 部分中，找到该 Runner。
1. 在该 Runner 右侧，选择**移除 Runner**。
1. 要删除该 Runner，请选择**移除**。

<a id="enable-a-project-runner-for-a-different-project"></a>

### 为其他项目启用项目 Runner

创建项目 Runner 后，您可以为其他项目启用它。

先决条件：您必须拥有以下项目的维护者或所有者角色：

- 已启用该 Runner 的项目。
- 您想要启用该 Runner 的项目。
- 该项目的 Runner 必须未[锁定](#prevent-a-project-runner-from-being-enabled-for-other-projects)。

要为项目启用项目 Runner：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runners**。
1. 在**项目 Runner** 区域中，在您想要的 Runner 旁边，选择**为此项目启用**。

您可以从已启用该 Runner 的任一项目编辑项目 Runner。这些修改（包括解锁以及编辑标签和描述）会影响使用该 Runner 的所有项目。

管理员可以[为多个项目启用该 Runner](../../administration/settings/continuous_integration.md#share-project-runners-with-multiple-projects)。

<a id="prevent-a-project-runner-from-being-enabled-for-other-projects"></a>

### 阻止为其他项目启用项目 Runner

您可以将项目 Runner 配置为“锁定”，使其无法为其他项目启用。
此设置可以在您首次[注册 Runner](https://gitlab.cn/docs/runner/register/) 时启用，
但也可以稍后更改。

要锁定或解锁项目 Runner：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runners**。
1. 找到您想要锁定或解锁的项目 Runner。确保它已启用。您无法锁定实例 Runner 或群组 Runner。
1. 选择**编辑**（{{< icon name="pencil" >}}）。
1. 选中**锁定到当前项目**复选框。
1. 选择**保存更改**。

<a id="runner-statuses"></a>

## Runner 状态

Runner 可以具有以下状态之一。

| 状态  | 描述 |
|---------|-------------|
| `online`  | 该 Runner 在过去 2 小时内联系过极狐GitLab，可用于运行作业。 |
| `offline` | 该 Runner 已超过 2 小时未联系极狐GitLab，无法用于运行作业。请检查该 Runner，看是否可以让它上线。 |
| `stale`   | 该 Runner 已超过 7 天未联系极狐GitLab。如果该 Runner 创建于 7 天前以上，但从未联系过实例，也会被视为**过期**。 |
| `never_contacted` | 该 Runner 从未联系过极狐GitLab。要让该 Runner 联系极狐GitLab，请运行 `gitlab-runner run`。 |

<a id="stale-runner-manager-cleanup"></a>

## 过期 Runner 管理器清理

极狐GitLab 会定期删除过期的 Runner 管理器，以保持数据库精简。如果某个 Runner 联系极狐GitLab 实例，该连接会被重新创建。

<a id="view-statistics-for-runner-performance"></a>

## 查看 Runner 性能统计信息

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

作为管理员，您可以查看 Runner 统计信息，以了解您 Runner 集群的性能。

**作业排队时间中位数**值是通过对实例 Runner 最近运行的 100 个作业的排队时长进行采样计算得出的。仅考虑最新 5000 个
Runner 的作业。

中位数是落在第 50 百分位的值。一半作业的排队时间长于中位值，一半作业的排队时间短于中位值。

要查看 Runner 统计信息：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 选择**查看指标**。

<a id="determine-which-runners-need-to-be-upgraded"></a>

## 确定哪些 Runner 需要升级

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

先决条件：

- 具有管理员访问权限才能查看实例 Runner。
- 具有维护者或所有者角色才能查看群组 Runner。

您的 Runner 所使用的极狐GitLab Runner 版本应
[保持最新](https://gitlab.cn/docs/runner/#gitlab-runner-versions)。

要确定哪些 Runner 需要升级：

1. 查看 Runner 列表：
   - 对于群组：
     1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
     1. 选择**构建** > **Runners**。
   - 对于实例：
     1. 在右上角，选择**管理员**。
     1. 选择 **CI/CD** > **Runners**。

1. 在 Runner 列表上方，查看状态：
   - **已过时 - 建议升级**：该 Runner 没有最新的 `PATCH` 版本，这可能使其容易
     受到安全漏洞或高严重性缺陷的影响。或者，该 Runner 比您的极狐GitLab 实例落后一个或多个 `MAJOR` 版本，因此某些功能可能不可用或无法正常工作。
   - **已过时 - 可升级**：有更新的版本可用，但升级并不紧急。

1. 按状态筛选列表，以查看哪些单个 Runner 需要升级。

<a id="determine-the-ip-address-of-a-runner"></a>

## 确定 Runner 的 IP 地址

要对 Runner 问题进行故障排除，您可能需要知道该 Runner 的 IP 地址。极狐GitLab 会在 Runner 轮询作业时通过查看 HTTP 请求的来源来存储并显示 IP 地址。每当 Runner 的 IP 地址更新时，极狐GitLab 都会自动更新它。

实例 Runner 和项目 Runner 的 IP 地址可以在
不同位置找到。

<a id="determine-the-ip-address-of-an-instance-runner"></a>

### 确定实例 Runner 的 IP 地址

先决条件：

- 您必须具有该实例的管理员访问权限。

要确定实例 Runner 的 IP 地址：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 在表格中找到该 Runner，并查看 **IP 地址**列。

![管理区域显示实例 Runner 的 IP 地址列](img/shared_runner_ip_address_v14_5.png)

<a id="determine-the-ip-address-of-a-project-runner"></a>

### 确定项目 Runner 的 IP 地址

要查找项目 Runner 的 IP 地址，您必须拥有该项目的所有者角色。

1. 转到该项目的**设置** > **CI/CD**，并展开 **Runners** 部分。
1. 选择该 Runner 名称，并找到 **IP 地址**行。

![Runner 详情页显示项目 Runner 的 IP 地址字段](img/project_runner_ip_address_v17_6.png)

<a id="add-maintenance-notes-to-runner-configuration"></a>

## 为 Runner 配置添加维护备注

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以添加维护备注来记录该 Runner。可以编辑该 Runner 的用户在查看 Runner 详情时会看到该备注。

使用此功能可告知他人与更改 Runner 配置相关的后果或问题。

<a id="enable-use-of-runner-registration-tokens-in-projects-and-groups"></a>

## 在项目和群组中启用 Runner 注册令牌

> [!warning]
> 传递 Runner 注册令牌的选项以及对某些配置参数的支持被视为旧版功能，
> 不建议使用。
> 请使用 [Runner 创建工作流](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 生成身份验证令牌来注册 Runner。此流程可提供 Runner 所有权的完整
> 可追溯性，并增强您 Runner 集群的安全性。
> 有关更多信息，请参阅
> [迁移到新的 Runner 注册工作流](new_creation_workflow.md)。

在极狐GitLab 17.0 中，所有极狐GitLab 实例中都禁用了 Runner 注册令牌的使用。

先决条件：

- 必须在**管理员**区域中[启用](../../administration/settings/continuous_integration.md#control-runner-registration) Runner 注册令牌。

要在项目和群组中启用 Runner 注册令牌：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runners**。
1. 开启**允许项目和群组成员使用 Runner 注册令牌创建 Runner** 开关。
