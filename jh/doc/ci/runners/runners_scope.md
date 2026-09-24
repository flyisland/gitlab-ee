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

极狐GitLab Runner 有以下类型的 Runner，其可用性取决于你希望谁有权访问：

- [实例 Runner](#instance-runners) 可用于极狐GitLab 实例中的所有群组和项目。
- [群组 Runner](#group-runners) 可用于群组中的所有项目和子群组。
- [项目 Runner](#project-runners) 与特定项目关联。
  通常，项目 Runner 一次由一个项目使用。

<a id="instance-runners"></a>

## 实例 Runner

*实例 Runner* 可用于极狐GitLab 实例中的每个项目。

当你有多个具有相似需求的作业时，使用实例 Runner。不必为许多项目保留多个空闲的 Runner，你可以让少数 Runner 处理多个项目。

如果你使用私有化部署的极狐GitLab，管理员可以：

- [安装极狐GitLab Runner](https://gitlab.cn/docs/runner/install/) 并注册一个实例 Runner。
- 为每个群组配置最大实例 Runner [计算分钟数](../../administration/cicd/compute_minutes.md#set-the-compute-quota-for-a-group)。

如果你使用 JihuLab.com：

- 你可以从[极狐GitLab 维护的实例 Runner](_index.md) 列表中选择。
- 实例 Runner 会消耗你账户中包含的[计算分钟](../pipelines/compute_minutes.md)。

<a id="create-an-instance-runner-with-a-runner-authentication-token"></a>

### 使用 Runner 认证令牌创建实例 Runner

{{< history >}}

- 引入于极狐GitLab 15.10。部署在 `create_runner_workflow_for_admin` 功能标志后。
- 于极狐GitLab 16.0 默认启用。
- 于极狐GitLab 16.2 GA。功能标志 `create_runner_workflow_for_admin` 已移除。

{{< /history >}}

先决条件：

- 你必须是管理员。

当你创建 Runner 时，会为其分配一个 Runner 认证令牌，用于注册。Runner 使用该令牌在从作业队列中获取作业时向极狐GitLab 进行身份验证。

要创建实例 Runner：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 选择 **创建实例 Runner**。
1. 选择安装极狐GitLab Runner 的操作系统。
1. 在 **标签** 部分的 **标签** 字段中，输入作业标签以指定 Runner 可以运行的作业。
   如果此 Runner 没有作业标签，请选择 **运行未标记**。
1. 可选。在 **Runner 描述** 字段中，输入要在极狐GitLab 中显示的 Runner 描述。
1. 可选。在 **配置** 部分，添加其他配置。
1. 选择 **创建 Runner**。
1. 按照屏幕上的说明从命令行注册 Runner。当命令行提示时：
   - 对于 `极狐GitLab 实例 URL`，使用你的极狐GitLab 实例的 URL。例如，如果你的项目托管在 `gitlab.example.com/yourname/yourproject`，则你的极狐GitLab 实例 URL 是 `https://gitlab.example.com`。
   - 对于 `executor`，输入 [executor](https://gitlab.cn/docs/runner/executors/) 的类型。executor 是 Runner 执行作业的环境。

你还可以[使用 API](../../api/users.md#create-a-runner-linked-to-a-user) 创建 Runner。

> [!note]
> Runner 认证令牌在注册期间仅在 UI 中显示有限的时间。注册 Runner 后，认证令牌存储在 `config.toml` 中。

<a id="create-an-instance-runner-with-a-registration-token-deprecated"></a>

### 使用注册令牌创建实例 Runner（已弃用）

> [!warning]
> 传递 Runner 注册令牌的选项以及对某些配置参数的支持被视为旧版，不建议使用。
> 请使用 [Runner 创建工作流程](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 生成认证令牌来注册 Runner。此过程提供了 Runner 所有权的完全可追溯性，并增强了 Runner 队列的安全性。
> 有关更多信息，请参阅
> [迁移到新的 Runner 注册工作流程](new_creation_workflow.md)。

先决条件：

- 必须在 **管理员** 区域[启用](../../administration/settings/continuous_integration.md#control-runner-registration) Runner 注册令牌。
- 你必须是管理员。

要创建实例 Runner：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 选择 **注册实例 Runner**。
1. 复制注册令牌。
1. [注册 Runner](https://gitlab.cn/docs/runner/register/#register-with-a-runner-registration-token-legacy)。

<a id="pause-or-resume-an-instance-runner"></a>

### 暂停或恢复实例 Runner

先决条件：

- 你必须是管理员。

你可以暂停 Runner，使其不接受来自极狐GitLab 实例中群组和项目的作业。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 在搜索框中，输入 Runner 描述或过滤 Runner 列表。
1. 在 Runner 列表中，在 Runner 右侧：
   - 要暂停 Runner，选择 **暂停** ({{< icon name="pause" >}})。
   - 要恢复 Runner，选择 **恢复** ({{< icon name="play" >}})。

<a id="delete-instance-runners"></a>

### 删除实例 Runner

先决条件：

- 你必须是管理员。

当你删除实例 Runner 时，它将从极狐GitLab 实例中永久删除，并且群组和项目不能再使用它。如果你想暂时停止 Runner 接受作业，可以改为[暂停](#pause-or-resume-an-instance-runner) Runner。

要删除单个或多个实例 Runner：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 在搜索框中，输入 Runner 描述或过滤 Runner 列表。
1. 删除实例 Runner：
   - 要删除单个 Runner，在 Runner 旁边，选择 **删除 Runner** ({{< icon name="remove" >}})。
   - 要删除多个实例 Runner，选中每个 Runner 的复选框，然后选择 **删除选中项**。
   - 要删除所有 Runner，选中 Runner 列表顶部的复选框，然后选择 **删除选中项**。
1. 选择 **永久删除 Runner**。

<a id="enable-instance-runners-for-a-project"></a>

### 为项目启用实例 Runner

在 JihuLab.com 上，默认情况下所有项目都启用了[实例 Runner](_index.md)。

在私有化部署的极狐GitLab 上，管理员可以
[为所有新项目启用它们](../../administration/settings/continuous_integration.md#enable-instance-runners-for-new-projects)。

对于现有项目，管理员必须
[安装](https://gitlab.cn/docs/runner/install/) 和
[注册](https://gitlab.cn/docs/runner/register/) 它们。

要为项目启用实例 Runner：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners**。
1. 启用 **为此项目启用实例 Runner** 切换开关。

<a id="enable-instance-runners-for-a-group"></a>

### 为群组启用实例 Runner

要为群组启用实例 Runner：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners**。
1. 启用 **为此群组启用实例 Runner** 切换开关。

<a id="disable-instance-runners-for-a-project"></a>

### 为项目禁用实例 Runner

你可以为单个项目或群组禁用实例 Runner。
你必须拥有项目或群组的 所有者 角色。

要为项目禁用实例 Runner：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners**。
1. 在 **实例 Runner** 区域，关闭 **为此项目启用 Runner** 切换开关。

在以下情况下，实例 Runner 会自动为项目禁用：

- 如果父群组的实例 Runner 设置被禁用，并且
- 如果不允许项目覆盖此设置。

<a id="disable-instance-runners-for-a-group"></a>

### 为群组禁用实例 Runner

要为群组禁用实例 Runner：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners**。
1. 关闭 **为此群组启用实例 Runner** 切换开关。
1. 可选。要允许为单个项目或子群组启用实例 Runner，
   选择 **允许项目和子群组覆盖群组设置**。

<a id="how-instance-runners-pick-jobs"></a>

### 实例 Runner 如何选择作业

实例 Runner 使用公平使用队列处理作业。此队列可防止
项目创建数百个作业并占用所有可用的
实例 Runner 资源。

公平使用队列算法根据已在实例 Runner 上运行的作业数量最少的项目来分配作业。

例如，如果队列中有以下作业：

- 项目 1 的作业 1
- 项目 1 的作业 2
- 项目 1 的作业 3
- 项目 2 的作业 4
- 项目 2 的作业 5
- 项目 3 的作业 6

当多个 CI/CD 作业同时运行时，公平使用算法按以下顺序分配作业：

1. 作业 1 是第一个，因为它来自没有运行作业的项目（即所有项目）中编号最小的作业。
1. 接下来是作业 4，因为 4 现在是来自没有运行作业的项目（项目 1 有作业正在运行）中编号最小的作业。
1. 接下来是作业 6，因为 6 现在是来自没有运行作业的项目（项目 1 和 2 有作业正在运行）中编号最小的作业。
1. 接下来是作业 2，因为在运行作业数量最少的项目（每个都有 1 个）中，它是编号最小的作业。
1. 接下来是作业 5，因为项目 1 现在有 2 个作业正在运行，而作业 5 是项目 2 和 3 之间剩余编号最小的作业。
1. 最后是作业 3，因为它是唯一剩下的作业。

当一次只运行一个作业时，公平使用算法按以下顺序分配作业：

1. 首先选择作业 1，因为它来自没有运行作业的项目（即所有项目）中编号最小的作业。
1. 作业 1 完成。
1. 接下来是作业 2，因为在完成作业 1 后，所有项目又都有 0 个作业正在运行，而 2 是可用的最小作业编号。
1. 接下来是作业 4，因为项目 1 正在运行一个作业，4 是来自没有运行作业的项目（项目 2 和 3）中编号最小的作业。
1. 作业 4 完成。
1. 接下来是作业 5，因为在完成作业 4 后，项目 2 又没有作业正在运行了。
1. 接下来是作业 6，因为项目 3 是唯一没有运行作业的项目。
1. 最后是作业 3，因为它是唯一剩下的作业。

<a id="group-runners"></a>

## 群组 Runner

当你希望群组中的所有项目都可以访问一组 Runner 时，使用群组 Runner。

群组 Runner 使用先进先出队列处理作业。

<a id="create-a-group-runner-with-a-runner-authentication-token"></a>

### 使用 Runner 认证令牌创建群组 Runner

{{< history >}}

- 引入于极狐GitLab 15.10。部署在 `create_runner_workflow_for_namespace` 功能标志后。默认禁用。
- 于极狐GitLab 16.0 默认启用。
- 于极狐GitLab 16.2 GA。功能标志 `create_runner_workflow_for_admin` 已移除。

{{< /history >}}

先决条件：

- 你必须拥有群组的 所有者 角色。

你可以为私有化部署的极狐GitLab 或 JihuLab.com 创建群组 Runner。
当你创建 Runner 时，会为其分配一个 Runner 认证令牌，用于注册。
Runner 使用该令牌在从作业队列中获取作业时向极狐GitLab 进行身份验证。

要创建群组 Runner：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **构建** > **Runners**。
1. 选择 **创建群组 Runner**。
1. 在 **标签** 部分的 **标签** 字段中，输入作业标签以指定 Runner 可以运行的作业。
   如果此 Runner 没有作业标签，请选择 **运行未标记**。
1. 可选。在 **Runner 描述** 字段中，添加要在极狐GitLab 中显示的 Runner 描述。
1. 可选。在 **配置** 部分，添加其他配置。
1. 选择 **创建 Runner**。
1. 选择安装极狐GitLab Runner 的平台。
1. 完成屏幕上的说明：
   - 对于 Linux、macOS 和 Windows，当命令行提示时：
     - 对于 `极狐GitLab 实例 URL`，使用你的极狐GitLab 实例的 URL。例如，如果你的项目托管在 `gitlab.example.com/yourname/yourproject`，则你的极狐GitLab 实例 URL 是 `https://gitlab.example.com`。
     - 对于 `executor`，输入 [executor](https://gitlab.cn/docs/runner/executors/) 的类型。
       executor 是 Runner 执行作业的环境。
   - 对于 Google Cloud，请参阅[在 Google Cloud 中配置 Runner](provision_runners_google_cloud.md)。

你还可以[使用 API](../../api/users.md#create-a-runner-linked-to-a-user) 创建 Runner。

> [!note]
> Runner 认证令牌在注册期间仅在 UI 中显示很短的时间。

<a id="create-a-group-runner-with-a-registration-token-deprecated"></a>

### 使用注册令牌创建群组 Runner（已弃用）

{{< history >}}

- 路径从 **设置** > **CI/CD** > **Runners** 更改。

{{< /history >}}

> [!warning]
> 传递 Runner 注册令牌的选项以及对某些配置参数的支持被视为旧版，不建议使用。
> 请使用 [Runner 创建工作流程](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 生成认证令牌来注册 Runner。此过程提供了 Runner 所有权的完全可追溯性，并增强了 Runner 队列的安全性。
> 有关更多信息，请参阅
> [迁移到新的 Runner 注册工作流程](new_creation_workflow.md)。

先决条件：

- 必须在顶级群组中[启用](#enable-use-of-runner-registration-tokens-in-projects-and-groups) Runner 注册令牌。
- 你必须拥有群组的 所有者 角色。

要创建群组 Runner：

1. [安装极狐GitLab Runner](https://gitlab.cn/docs/runner/install/)。
1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **构建** > **Runners**。
1. 在右上角，选择 **注册群组 Runner**。
1. 选择 **显示 Runner 安装和注册说明**。
   这些说明包括令牌、URL 和注册 Runner 的命令。

或者，你可以复制注册令牌并按照文档说明
[注册 Runner](https://gitlab.cn/docs/runner/register/#register-with-a-runner-registration-token-legacy)。

<a id="view-group-runners"></a>

### 查看群组 Runner

{{< history >}}

- 具有 维护者 角色的用户查看群组 Runner 的能力引入于极狐GitLab 16.4。

{{< /history >}}

先决条件：

- 你必须拥有群组的 维护者 或 所有者 角色。

你可以查看群组及其子群组和项目的所有 Runner。
你可以对私有化部署的极狐GitLab 或 JihuLab.com 执行此操作。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **构建** > **Runners**。

<a id="filter-group-runners-to-show-only-inherited"></a>

#### 过滤群组 Runner 以仅显示继承的

{{< history >}}

- 引入于极狐GitLab 15.5。
- 于极狐GitLab 15.5 GA。功能标志 `runners_finder_all_available` 已移除。

{{< /history >}}

你可以选择显示列表中的所有 Runner，或仅显示
从实例或其他群组继承的 Runner。

默认情况下，仅显示继承的 Runner。

要显示实例中所有可用的 Runner，包括实例 Runner 和
其他群组中的 Runner：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **构建** > **Runners**。
1. 在列表上方，关闭 **仅显示继承的** 切换开关。

<a id="pause-or-resume-a-group-runner"></a>

### 暂停或恢复群组 Runner

先决条件：

- 你必须是管理员或拥有群组的 所有者 角色。

你可以暂停 Runner，使其不接受来自极狐GitLab 实例中子群组和项目的作业。如果你暂停了多个项目使用的群组 Runner，则该 Runner 将对所有项目暂停。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **构建** > **Runners**。
1. 在搜索框中，输入 Runner 描述或过滤 Runner 列表。
1. 在 Runner 列表中，在 Runner 右侧：
   - 要暂停 Runner，选择 **暂停** ({{< icon name="pause" >}})。
   - 要恢复 Runner，选择 **恢复** ({{< icon name="play" >}})。

<a id="delete-a-group-runner"></a>

### 删除群组 Runner

{{< history >}}

- 多 Runner 删除引入于极狐GitLab 15.6。

{{< /history >}}

先决条件：

- 你必须是管理员或拥有群组的 所有者 角色。

当你删除群组 Runner 时，它将从极狐GitLab 实例中永久删除，并且子群组和项目不能再使用它。如果你想暂时停止 Runner 接受作业，可以改为[暂停](#pause-or-resume-a-group-runner) Runner。

要删除单个或多个群组 Runner：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **构建** > **Runners**。
1. 在搜索框中，输入 Runner 描述或过滤 Runner 列表。
1. 删除群组 Runner：
   - 要删除单个 Runner，在 Runner 旁边，选择 **删除 Runner** ({{< icon name="remove" >}})。
   - 要删除多个实例 Runner，选中每个 Runner 的复选框，然后选择 **删除选中项**。
   - 要删除所有 Runner，选中 Runner 列表顶部的复选框，然后选择 **删除选中项**。
1. 选择 **永久删除 Runner**。

<a id="clean-up-stale-group-runners"></a>

### 清理过期的群组 Runner

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 15.1。

{{< /history >}}

先决条件：

- 你必须拥有群组的 所有者 角色。

你可以清理超过三个月不活动的群组 Runner。

群组 Runner 是在特定群组中创建的 Runner。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners**。
1. 启用 **启用过期 Runner 清理** 切换开关。

<a id="view-stale-runner-cleanup-logs"></a>

#### 查看过期 Runner 清理日志

你可以查看 [Sidekiq 日志](../../administration/logs/_index.md#sidekiq-logs) 来查看清理结果。在 Kibana 中，你可以使用以下查询：

```json
{
  "query": {
    "match_phrase": {
      "json.class.keyword": "Ci::Runners::StaleGroupRunnersPruneCronWorker"
    }
  }
}
```

过滤已删除过期 Runner 的条目：

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

当你希望为特定项目使用 Runner 时，使用项目 Runner。例如，
当你有：

- 具有特定要求的作业，例如需要凭据的部署作业。
- CI 活动频繁的项目，可以从与其他 Runner 分离中受益。

你可以设置一个项目 Runner 供多个项目使用。项目 Runner
必须为每个项目显式启用。

项目 Runner 使用先进先出（[FIFO](https://en.wikipedia.org/wiki/FIFO_(computing_and_electronics))）队列处理作业。

> [!note]
> 项目 Runner 不会自动为派生的项目获取实例。
> 派生会复制克隆仓库的 CI/CD 设置。

<a id="project-runner-ownership"></a>

### 项目 Runner 所有权

当 Runner 首次连接到项目时，该项目将成为 Runner 的所有者。

如果你删除所有者项目：

1. 极狐GitLab 会找到共享该 Runner 的所有其他项目。
1. 极狐GitLab 将所有权分配给关联最早的项目。
1. 如果没有其他项目共享该 Runner，极狐GitLab 会自动删除该 Runner。

你不能从所有者项目中取消分配 Runner。请改为删除 Runner。

<a id="create-a-project-runner-with-a-runner-authentication-token"></a>

### 使用 Runner 认证令牌创建项目 Runner

{{< history >}}

- 引入于极狐GitLab 15.10。部署在 `create_runner_workflow_for_namespace` 功能标志后。默认禁用。
- 于极狐GitLab 16.0 默认启用。
- 于极狐GitLab 16.2 GA。功能标志 `create_runner_workflow_for_admin` 已移除。

{{< /history >}}

先决条件：

- 你必须拥有项目的 维护者 角色。

你可以为私有化部署的极狐GitLab 或 JihuLab.com 创建项目 Runner。当你创建 Runner 时，
会为其分配一个 Runner 认证令牌，用于注册 Runner。Runner 使用该令牌在从作业队列中获取作业时向极狐GitLab 进行身份验证。

要创建项目 Runner：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners** 部分。
1. 选择 **创建项目 Runner**。
1. 选择安装极狐GitLab Runner 的操作系统。
1. 在 **标签** 部分的 **标签** 字段中，输入作业标签以指定 Runner 可以运行的作业。
   如果此 Runner 没有作业标签，请选择 **运行未标记**。
1. 可选。在 **Runner 描述** 字段中，添加要在极狐GitLab 中显示的 Runner 描述。
1. 可选。在 **配置** 部分，添加其他配置。
1. 选择 **创建 Runner**。
1. 选择安装极狐GitLab Runner 的平台。
1. 完成屏幕上的说明：
   - 对于 Linux、macOS 和 Windows，当命令行提示时：
     - 对于 `极狐GitLab 实例 URL`，使用你的极狐GitLab 实例的 URL。例如，如果你的项目托管在 `gitlab.example.com/yourname/yourproject`，则你的极狐GitLab 实例 URL 是 `https://gitlab.example.com`。
     - 对于 `executor`，输入 [executor](https://gitlab.cn/docs/runner/executors/) 的类型。
       executor 是 Runner 执行作业的环境。
   - 对于 Google Cloud，请参阅[在 Google Cloud 中配置 Runner](provision_runners_google_cloud.md)。

你还可以[使用 API](../../api/users.md#create-a-runner-linked-to-a-user) 创建 Runner。

> [!note]
> Runner 认证令牌在注册期间仅在 UI 中显示很短的时间。

<a id="create-a-project-runner-with-a-registration-token-deprecated"></a>

### 使用注册令牌创建项目 Runner（已弃用）

> [!warning]
> 传递 Runner 注册令牌的选项以及对某些配置参数的支持被视为旧版，不建议使用。
> 请使用 [Runner 创建工作流程](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 生成认证令牌来注册 Runner。此过程提供了 Runner 所有权的完全可追溯性，并增强了 Runner 队列的安全性。
> 有关更多信息，请参阅
> [迁移到新的 Runner 注册工作流程](new_creation_workflow.md)。

先决条件：

- 必须在顶级群组中[启用](#enable-use-of-runner-registration-tokens-in-projects-and-groups) Runner 注册令牌。
- 你必须拥有项目的 维护者 或 所有者 角色。

要创建项目 Runner：

1. [安装极狐GitLab Runner](https://gitlab.cn/docs/runner/install/)。
1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners**。
1. 在 **项目 Runner** 部分，记下 URL 和令牌。
1. [注册 Runner](https://gitlab.cn/docs/runner/register/#register-with-a-runner-registration-token-legacy)。

Runner 现已为项目启用。

<a id="pause-or-resume-a-project-runner"></a>

### 暂停或恢复项目 Runner

先决条件：

- 你必须是管理员，或拥有项目的 维护者 角色。

你可以暂停项目 Runner，使其不接受来自极狐GitLab 实例中已分配给它的项目的作业。
<a id="pause-or-resume-a-project-runner"></a>

### 暂停或恢复项目 Runner

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners**。
1. 在 **已分配的项目 Runner** 部分，找到该 Runner。
1. 在 Runner 的右侧：
   - 要暂停此 Runner，请选择 **暂停** ({{< icon name="pause" >}})，然后选择 **暂停**。
   - 要恢复此 Runner，请选择 **恢复** ({{< icon name="play" >}})。

<a id="delete-a-project-runner"></a>

### 删除项目 Runner

前提条件：

- 您必须是管理员，或者对项目具有维护者角色。
- 您不能删除已分配给多个项目的项目 Runner。在您可以删除该 Runner 之前，必须将其在所有已启用的项目中[禁用](#enable-a-project-runner-for-a-different-project)。

当您删除项目 Runner 时，它将从极狐GitLab 实例中永久删除，并且项目无法再使用它。如果您想临时停止 Runner 接受作业，可以改为[暂停](#pause-or-resume-a-project-runner)该 Runner。

当您删除 Runner 时，其配置仍然存在于 Runner 主机的 `config.toml` 文件中。如果被删除的 Runner 配置仍然存在于该文件中，则 Runner 主机会继续联系极狐GitLab。为防止不必要的 API 流量，您还必须[注销已删除的 Runner](https://gitlab.cn/docs/runner/commands/#gitlab-runner-unregister)。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到项目。
1. 选择 **设置** > **CI/CD**。
1. 展开 **Runners**。
1. 在 **已分配的项目 Runner** 部分，找到该 Runner。
1. 在 Runner 右侧，选择 **移除 Runner**。
1. 要删除该 Runner，请选择 **移除**。

<a id="enable-a-project-runner-for-a-different-project"></a>

### 为其他项目启用项目 Runner

创建项目 Runner 后，您可以为其启用到其他项目。

前提条件：
您必须对以下对象具有维护者或所有者角色：

- 已启用该 Runner 的项目。
- 您想启用该 Runner 的项目。
- 项目 Runner 不得被[锁定](#prevent-a-project-runner-from-being-enabled-for-other-projects)。

要为项目启用项目 Runner：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners**。
1. 在 **项目 Runner** 区域，在您想要的 Runner 旁边，选择 **为此项目启用**。

您可以在已启用该 Runner 的任何项目中编辑项目 Runner。所做的修改（包括解锁和编辑标签以及描述）会影响所有使用此 Runner 的项目。

管理员可以为多个项目[启用 Runner](../../administration/settings/continuous_integration.md#share-project-runners-with-multiple-projects)。

<a id="prevent-a-project-runner-from-being-enabled-for-other-projects"></a>

### 防止项目 Runner 被其他项目启用

您可以配置项目 Runner 使其“锁定”，无法为其他项目启用。在首次[注册 Runner](https://gitlab.cn/docs/runner/register/) 时即可启用此设置，但也可在后期更改。

要锁定或解锁项目 Runner：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners**。
1. 找到您要锁定或解锁的项目 Runner。确保其已启用。您无法锁定实例 Runner 或群组 Runner。
1. 选择 **编辑** ({{< icon name="pencil" >}})。
1. 选中 **锁定到当前项目** 复选框。
1. 选择 **保存更改**。

<a id="runner-statuses"></a>

### Runner 状态

Runner 可以具有以下状态之一。

| 状态  | 描述 |
|---------|-------------|
| `online`  | Runner 在过去 2 小时内已联系极狐GitLab，并且可用于运行作业。 |
| `offline` | Runner 超过 2 小时未联系极狐GitLab，并且无法运行作业。请检查该 Runner，看能否使其上线。 |
| `stale`   | Runner 超过 7 天未联系极狐GitLab。如果 Runner 创建于 7 天前，但从未联系实例，它也会被视为 **stale**。 |
| `never_contacted` | Runner 从未联系过极狐GitLab。要使 Runner 联系极狐GitLab，请运行 `gitlab-runner run`。 |

<a id="stale-runner-manager-cleanup"></a>

### 过期 Runner 管理器清理

极狐GitLab 会定期删除过期 Runner 管理器，以保持数据库精简。如果 Runner 联系极狐GitLab 实例，则会重新创建连接。

<a id="view-statistics-for-runner-performance"></a>

### 查看 Runner 性能统计信息

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 GitLab 15.8 中引入。

{{< /history >}}

作为管理员，您可以查看 Runner 统计信息以了解您的 Runner 机群的性能。

**作业排队时间中位数** 值是通过对实例 Runner 运行的最新 100 个作业的排队持续时间进行采样计算得出的。仅考虑最近 5000 个 Runner 的作业。

中位数是处于第 50 百分位数的值。一半的作业排队时间比中位数长，另一半排队时间比中位数短。

要查看 Runner 统计信息：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 选择 **查看指标**。

<a id="determine-which-runners-need-to-be-upgraded"></a>

### 确定哪些 Runner 需要升级

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 GitLab 15.3 中引入。

{{< /history >}}

前提条件：

- 管理员权限以查看实例 Runner。
- 对群组 Runner 需要维护者或所有者角色。

您的 Runner 所使用的 GitLab Runner 版本应[保持最新](https://gitlab.cn/docs/runner/#gitlab-runner-versions)。

要确定哪些 Runner 需要升级：

1. 查看 Runner 列表：
   - 对于群组：
     1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
     1. 选择 **构建** > **Runners**。
   - 对于实例：
     1. 在右上角，选择 **管理员**。
     1. 选择 **CI/CD** > **Runners**。

1. 在 Runner 列表上方查看状态：
   - **过期 - 推荐升级**：该 Runner 没有最新的 `PATCH` 版本，这可能导致其易受安全或严重错误的影响。或者，该 Runner 比您的极狐GitLab 实例落后一个或多个 `MAJOR` 版本，因此某些功能可能不可用或工作不正常。
   - **过期 - 有可用版本**：有新版本可用，但升级并非关键。

1. 按状态筛选列表，查看哪些个别 Runner 需要升级。

<a id="determine-the-ip-address-of-a-runner"></a>

### 确定 Runner 的 IP 地址

要对 Runner 问题进行故障排除，您可能需要知道 Runner 的 IP 地址。极狐GitLab 通过查看 Runner 轮询作业时 HTTP 请求的来源来存储和显示 IP 地址。每当 IP 地址更新时，极狐GitLab 会自动更新 Runner 的 IP 地址。

实例 Runner 和项目 Runner 的 IP 地址可以在不同位置找到。

<a id="determine-the-ip-address-of-an-instance-runner"></a>

#### 确定实例 Runner 的 IP 地址

前提条件：

- 您必须具有实例的管理员权限。

要确定实例 Runner 的 IP 地址：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runners**。
1. 在表格中查找该 Runner，并查看 **IP 地址** 列。

![显示实例 Runner 的 IP 地址列的管理员区域](img/shared_runner_ip_address_v14_5.png)

<a id="determine-the-ip-address-of-a-project-runner"></a>

#### 确定项目 Runner 的 IP 地址

要查找项目的 Runner 的 IP 地址，您必须具有该项目的所有者角色。

1. 转到项目的 **设置** > **CI/CD** 并展开 **Runner** 部分。
1. 选择 Runner 名称，找到 **IP 地址** 行。

![显示项目 Runner 的 IP 地址字段的 Runner 详情页面](img/project_runner_ip_address_v17_6.png)

<a id="add-maintenance-notes-to-runner-configuration"></a>

### 向 Runner 配置添加维护备注

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 GitLab 15.1 中为管理员引入。
- 在 GitLab 18.2 中为群组和项目开放。

{{< /history >}}

您可以添加维护备注以记录该 Runner。可以编辑 Runner 的用户在查看 Runner 详情时会看到备注。

使用此功能向其他人告知与更改 Runner 配置相关的后果或问题。

<a id="enable-use-of-runner-registration-tokens-in-projects-and-groups"></a>

### 在项目和群组中启用 Runner 注册令牌的使用

{{< history >}}

- 在 GitLab 16.11 中引入

{{< /history >}}

> [!warning]
> 传递 Runner 注册令牌的选项以及对某些配置参数的支持被视为旧版，不建议使用。
> 请使用 [Runner 创建工作流程](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token) 生成身份验证令牌来注册 Runner。此流程提供了 Runner 所有权的完全可追溯性，并增强了 Runner 机群的安全性。
> 有关更多信息，请参阅[迁移到新的 Runner 注册工作流程](new_creation_workflow.md)。

在 GitLab 17.0 中，所有极狐GitLab 实例都禁用了 Runner 注册令牌的使用。

前提条件：

- 必须在 **管理员** 区域[启用](../../administration/settings/continuous_integration.md#control-runner-registration) Runner 注册令牌。

要在项目和群组中启用 Runner 注册令牌的使用：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners**。
1. 打开 **允许项目成员和群组成员使用 Runner 注册令牌创建 Runner** 开关。

