---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use stacked diffs to create small merge changes that build upon each other to ultimately deliver a feature.
title: 堆叠差异
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- 状态：实验

{{< /details >}}

{{< history >}}

- 在 [极狐GitLab CLI v1.42.0](https://jihulab.com/gitlab-cn/cli/-/releases/v1.42.0) 中作为 [实验性功能](../../../policy/development_stages_support.md#experiment) 引入。

{{< /history >}}

在 [极狐GitLab CLI](https://gitlab.cn/docs/cli/) 中使用堆叠差异，可以创建彼此依赖的小型变更，并最终交付一个完整功能。每个堆叠都是独立的，因此你可以：

- 在审核早期更改的同时，继续构建新功能。
- 针对特定差异回复审核意见，而不影响其他工作。
- 在差异获得批准后，独立合并它们。

堆叠差异的工作流为：

1. 创建更改：运行 `glab stack save` 时，极狐GitLab CLI 会：
   - 暂存你的所有更改。
   - 使用你的消息创建一个新提交。
   - 为该提交创建一个新分支。
   - 自动将你切换到该新分支。

1. 同步到极狐GitLab：运行 `glab stack sync` 时，极狐GitLab CLI 会：
   - 将堆叠中的所有分支推送到极狐GitLab。
   - 为每个尚未创建合并请求的差异创建一个合并请求。
   - 将这些合并请求链式串联起来。除第一个合并请求外，每个合并请求都以上一个差异分支为合并目标。

该功能在 CLI 中的基础命令是 [`stack`](https://gitlab.cn/docs/cli/stack/)，你可以通过 [其他命令](#可用命令) 进一步扩展它。

<!-- Video content removed -->

此功能为 [实验性功能](../../../policy/development_stages_support.md)。

<a id="create-a-stacked-diff"></a>

## 创建堆叠差异

当你需要将一个大型功能拆分为更小、可审核的更改时，可以创建堆叠差异。

先决条件：

- 已安装并认证 [极狐GitLab CLI](https://gitlab.cn/docs/cli/)。

要创建堆叠差异：

1. 在终端中，创建一个新堆叠并为其命名。例如：

   ```shell
   glab stack create add-authentication
   ```

1. 在编辑器中完成你的第一组更改。
1. 将你的更改保存为第一个差异：

   ```shell
   glab stack save
   ```

   当系统提示时，输入描述此更改的提交消息。

1. 完成你的下一组更改，并将其保存为第二个差异：

   ```shell
   glab stack save
   ```

   每次运行 `glab stack save`，你都会创建一个新的差异和分支。
   当系统提示时，输入描述此更改的提交消息。

1. 当你准备好将更改推送到极狐GitLab 并创建合并请求时，请运行：

   ```shell
   glab stack sync
   ```

你的合并请求已可供审核。你可以继续在此堆叠中创建更多差异，或者切换去处理其他工作。

<a id="add-changes-to-a-diff-in-a-stack"></a>

## 为堆叠中的某个差异添加更改

要返回堆叠中的特定位置并为其添加更多更改：

1. 显示堆叠列表：

   ```shell
   glab stack move
   ```

1. 选择你要编辑的堆叠，然后按 <kbd>Enter</kbd>。
1. 完成你的更改。
1. 准备就绪后，保存你的更改并运行：

   ```shell
   glab stack amend
   ```

1. 可选。更改该堆叠的描述。
1. 推送你的更改：

   ```shell
   glab stack sync
   ```

当你同步现有堆叠时，极狐GitLab 会：

- 使用你的新更改更新现有堆叠。
- 变基堆叠中的其他合并请求，以纳入你的最新更改。

<a id="available-commands"></a>

## 可用命令

使用以下命令操作堆叠差异：

| 命令                                                   | 描述                         |
|--------------------------------------------------------|------------------------------|
| [`create`](https://gitlab.cn/docs/cli/stack/create/)   | 创建一个新堆叠。             |
| [`save`](https://gitlab.cn/docs/cli/stack/save/)       | 将你的更改保存为新差异。     |
| [`amend`](https://gitlab.cn/docs/cli/stack/amend/)     | 修改当前差异。               |
| [`prev`](https://gitlab.cn/docs/cli/stack/prev/)       | 移动到上一个差异。           |
| [`next`](https://gitlab.cn/docs/cli/stack/next/)       | 移动到下一个差异。           |
| [`first`](https://gitlab.cn/docs/cli/stack/first/)     | 移动到第一个差异。           |
| [`last`](https://gitlab.cn/docs/cli/stack/last/)       | 移动到最后一个差异。         |
| [`move`](https://gitlab.cn/docs/cli/stack/move/)       | 从列表中选择任意一个差异。   |
| [`sync`](https://gitlab.cn/docs/cli/stack/sync/)       | 推送分支并创建/更新合并请求。|

<a id="choose-between-save-and-amend"></a>

### 在 save 和 amend 之间选择

根据目的选用以下命令：

- `glab stack save`：创建一个新差异（提交和分支）。当你需要向堆叠添加新的逻辑变更时，使用此命令。
- `glab stack amend`：修改当前差异。当你需要回复审核反馈或修正当前变更时，使用此命令。