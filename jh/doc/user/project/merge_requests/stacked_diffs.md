---
stage: AI Coding
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用堆叠差异创建小型合并变更，这些变更相互叠加，最终交付一项功能。
title: 堆叠差异
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

在 [GitLab CLI](https://gitlab.cn/docs/cli/)中使用堆叠差异来创建小型变更，这些变更相互叠加，最终交付一项功能。每个堆叠都是独立的，因此您可以：

- 在较早的变更接受评审的同时继续构建新功能。
- 针对特定差异回应评审反馈，而不影响其他工作。
- 在差异获得批准后独立合并它们。

堆叠差异的工作流程如下：

1. 创建变更：当您运行 `glab stack save` 时，GitLab CLI 会：

   - 暂存您的所有变更。
   - 使用您的提交信息创建一个新提交。
   - 为此提交创建一个新分支。
   - 自动将您切换到新分支。

1. 同步到极狐GitLab：当您运行 `glab stack sync` 时，GitLab CLI 会：

   - 将堆叠中的所有分支推送到极狐GitLab。
   - 为每个尚无合并请求的差异创建一个合并请求。
   - 将这些合并请求串联起来。除第一个外，每个合并请求
     都以上一个差异分支为目标。

此功能在 CLI 中的基础命令是 [`stack`](https://gitlab.cn/docs/cli/stack/)，您可以再使用[其他命令](#available-commands)对其进行扩展。

此功能是一项[实验](../../../policy/development_stages_support.md)。GitLab CLI 项目欢迎您在[议题 7473](https://gitlab.com/gitlab-org/cli/-/issues/7473)中提供反馈。

<a id="create-a-stacked-diff"></a>

## 创建堆叠差异

当您想将一项大型功能拆分为更小、更易于评审的变更时，可以创建堆叠差异。

先决条件：

- 您必须已安装并完成 [GitLab CLI](https://gitlab.cn/docs/cli/)的身份验证。

创建堆叠差异：

1. 在终端中，创建一个新堆叠并为其命名。例如：

   ```shell
   glab stack create add-authentication
   ```

1. 在编辑器中完成第一组变更。
1. 将您的变更保存为第一个差异：

   ```shell
   glab stack save
   ```

   出现提示时，输入描述此变更的提交信息。

1. 完成下一组变更，并将其保存为第二个差异：

   ```shell
   glab stack save
   ```

   每次运行 `glab stack save` 时，您都会创建一个新差异和分支。
   出现提示时，输入描述此变更的提交信息。

1. 当您准备好将变更推送到极狐GitLab 并创建合并请求时，请运行：

   ```shell
   glab stack sync
   ```

您的合并请求已可供评审。您可以继续在此堆叠中创建更多差异，也可以切换到其他工作。

<a id="add-changes-to-a-diff-in-a-stack"></a>

## 向堆叠中的差异添加变更

要返回到堆叠中的特定位置以向其添加更多变更：

1. 显示堆叠列表：

   ```shell
   glab stack move
   ```

1. 选择要编辑的堆叠，然后按 <kbd>Enter</kbd>。
1. 进行您的变更。
1. 准备好后，保存您的变更，并运行：

   ```shell
   glab stack amend
   ```

1. 可选。更改堆叠的描述。
1. 推送您的变更：

   ```shell
   glab stack sync
   ```

当您同步现有堆叠时，极狐GitLab 会：

- 使用您的新变更更新现有堆叠。
- 对堆叠中的其他合并请求执行变基，以引入您的最新变更。

<a id="available-commands"></a>

## 可用命令

使用以下命令处理堆叠差异：

| 命令                                               | 描述 |
|-------------------------------------------------------|-------------|
| [`create`](https://gitlab.cn/docs/cli/stack/create/) | 创建新堆叠。 |
| [`save`](https://gitlab.cn/docs/cli/stack/save/)     | 将您的变更保存为新差异。 |
| [`amend`](https://gitlab.cn/docs/cli/stack/amend/)   | 修改当前差异。 |
| [`prev`](https://gitlab.cn/docs/cli/stack/prev/)     | 移动到上一个差异。 |
| [`next`](https://gitlab.cn/docs/cli/stack/next/)     | 移动到下一个差异。 |
| [`first`](https://gitlab.cn/docs/cli/stack/first/)   | 移动到第一个差异。 |
| [`last`](https://gitlab.cn/docs/cli/stack/last/)     | 移动到最后一个差异。 |
| [`move`](https://gitlab.cn/docs/cli/stack/move/)     | 从列表中选择任意差异。 |
| [`sync`](https://gitlab.cn/docs/cli/stack/sync/)     | 推送分支并创建/更新合并请求。 |

<a id="choose-between-save-and-amend"></a>

### 在 save 和 amend 之间选择

根据不同的用途使用以下命令：

- `glab stack save`：创建一个新差异（提交和分支）。当您要向堆叠中添加
  新的逻辑变更时使用此命令。
- `glab stack amend`：修改当前差异。当您要回应评审反馈
  或修复当前变更时使用此命令。
