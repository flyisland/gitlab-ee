---
stage: Growth
group: Engagement
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 键盘快捷键
description: 全局快捷键、导航及快速访问。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 提供了多个键盘快捷键，你可以使用它们来访问其不同的功能。

要在极狐GitLab 中显示列出其键盘快捷键的窗口，请使用以下方法之一：

- 按下 <kbd>?</kbd>。
- 在应用程序左下角，选择 **Help** 然后选择 **键盘快捷键**。

尽管[全局快捷键](#global-shortcuts)在 极狐GitLab 的任意区域都可以使用，但其他快捷键则必须在特定的页面中才能使用，详情请参考各个部分的说明。

<a id="global-shortcuts"></a>

## 全局快捷键

这些快捷键在 极狐GitLab 的大部分区域都可以使用：

| 键盘快捷键                      | 描述 |
|------------------------------------|-------------|
| <kbd>?</kbd>                       | 显示或隐藏快捷键参考表。 |
| <kbd>Shift</kbd>+<kbd>h</kbd>      | 前往首页。 |
| <kbd>Shift</kbd>+<kbd>p</kbd>      | 前往你的 **项目** 页面。 |
| <kbd>Shift</kbd>+<kbd>g</kbd>      | 前往你的 **群组** 页面。 |
| <kbd>Shift</kbd>+<kbd>a</kbd>      | 前往你的 **动态** 页面。 |
| <kbd>Shift</kbd>+<kbd>l</kbd>      | 前往你的 **里程碑** 页面。 |
| <kbd>Shift</kbd>+<kbd>s</kbd>      | 前往你的 **代码片段** 页面。 |
| <kbd>s</kbd> / <kbd>/</kbd>        | 将光标置于搜索栏。 |
| <kbd>f</kbd>                       | 聚焦过滤栏 |
| <kbd>Shift</kbd>+<kbd>i</kbd>      | 前往你的 **议题** 页面。 |
| <kbd>Shift</kbd>+<kbd>m</kbd>      | 前往你的 **合并请求** 页面。 |
| <kbd>Shift</kbd>+<kbd>r</kbd>      | 前往你的 **评审请求** 页面。 |
| <kbd>Shift</kbd>+<kbd>t</kbd>      | 前往你的 **待办事项** 页面。 |
| <kbd>p</kbd>, 然后 <kbd>b</kbd>    | 显示或隐藏性能栏。 |
| <kbd>Escape</kbd>                  | 隐藏工具提示或弹窗。 |
| <kbd>g</kbd>, 然后 <kbd>x</kbd>    | 切换 [GitLab](https://jihulab.com/) 和 [GitLab Next](https://next.gitlab.com/)。 |
| <kbd>.</kbd>                       | 打开 [Web IDE](project/web_ide/_index.md)。 |
| <kbd>d</kbd>                       | 打开 极狐GitLab Duo Chat |

此外，在文本字段（例如评论、回复、议题描述和合并请求描述）编辑文本时，可以使用以下快捷键：

| macOS 快捷键                                       | Windows 快捷键                                   | 描述 |
|------------------------------------------------------|----------------------------------------------------|-------------|
| <kbd>↑</kbd>                                         | <kbd>↑</kbd>                                       | 编辑你的上一条评论。你必须在一个空白的文本字段中，并且该讨论串中至少有一条你的评论。 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>p</kbd>     | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>p</kbd>   | 在顶部有 **Write** 和 **Preview** 选项卡的文本字段中编辑文本时，切换 Markdown 预览。 |
| <kbd>Command</kbd>+<kbd>b</kbd>                      | <kbd>Control</kbd>+<kbd>b</kbd>                    | 将选中的文本加粗（用 `**` 包围）。 |
| <kbd>Command</kbd>+<kbd>i</kbd>                      | <kbd>Control</kbd>+<kbd>i</kbd>                    | 将选中的文本设为斜体（用 `_` 包围）。 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>x</kbd>     | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>x</kbd>   | 为选中文本添加删除线（用 `~~` 包围）。 |
| <kbd>Command</kbd>+<kbd>k</kbd>                      | <kbd>Control</kbd>+<kbd>k</kbd>                    | 添加链接（用 `[]()` 包围选中文本）。 |
| <kbd>Command</kbd>+<kbd>[</kbd>                      | <kbd>Control</kbd>+<kbd>[</kbd>                    | 减少缩进。 |
| <kbd>Command</kbd>+<kbd>]</kbd>                      | <kbd>Control</kbd>+<kbd>]</kbd>                    | 增加缩进。 |
| <kbd>Command</kbd>+<kbd>Enter</kbd>                  | <kbd>Control</kbd>+<kbd>Enter</kbd>                | 提交或保存更改。 |

文本编辑的键盘快捷键始终处于启用状态，即使其他键盘快捷键被禁用。

<a id="project"></a>

## 项目

这些快捷键在项目内的任意页面均可使用。你需要相对快速地依次键入它们才能生效，它们会将你带到项目中的其他页面。

| 键盘快捷键           | 描述 |
|-----------------------------|-------------|
| <kbd>g</kbd>+<kbd>o</kbd>   | 前往项目概览页面。 |
| <kbd>g</kbd>+<kbd>v</kbd>   | 前往项目 **动态** 页面 (**Manage** > **Activity**)。 |
| <kbd>g</kbd>+<kbd>r</kbd>   | 前往项目 **发布** 页面 (**Deploy** > **Releases**)。 |
| <kbd>g</kbd>+<kbd>f</kbd>   | 前往项目文件 (**Code** > **Repository**)。 |
| <kbd>t</kbd>                | 打开项目文件搜索对话框。(**Code** > **Repository**，然后选择 **Find Files**)。 |
| <kbd>g</kbd>+<kbd>c</kbd>   | 前往项目 **提交** 页面 (**Code** > **Commits**)。 |
| <kbd>g</kbd>+<kbd>n</kbd>   | 前往代码仓图表页面 (**Code** > **Repository graph**)。 |
| <kbd>g</kbd>+<kbd>d</kbd>   | 前往 **仓库分析** 页面中的图表 (**Analyze** > **Repository analytics**)。 |
| <kbd>g</kbd>+<kbd>i</kbd>   | 前往项目 **工作项** 页面 (**Plan** > **Work items**)。 |
| <kbd>i</kbd>                | 前往新建议题页面 (**Plan** > **Work items**，然后选择 **New item**)。 |
| <kbd>g</kbd>+<kbd>b</kbd>   | 前往项目 **议题看板** 页面 (**Plan** > **Issue boards**)。 |
| <kbd>g</kbd>+<kbd>m</kbd>   | 前往项目 **合并请求** 页面 (**Code** > **Merge requests**)。 |
| <kbd>g</kbd>+<kbd>p</kbd>   | 前往 CI/CD **流水线** 页面 (**Build** > **Pipelines**)。 |
| <kbd>g</kbd>+<kbd>j</kbd>   | 前往 CI/CD **作业** 页面 (**Build** > **Jobs**)。 |
| <kbd>g</kbd>+<kbd>e</kbd>   | 前往项目 **环境** 页面 (**Operate** > **Environments**)。 |
| <kbd>g</kbd>+<kbd>k</kbd>   | 前往项目 **Kubernetes clusters** 集成页面 (**Operate** > **Kubernetes clusters**)。你必须至少有[`维护者`权限](permissions.md)才能访问此页面。 |
| <kbd>g</kbd>+<kbd>s</kbd>   | 前往项目 **代码片段** 页面 (**Code** > **Snippets**)。 |
| <kbd>g</kbd>+<kbd>w</kbd>   | 前往项目 Wiki (**Plan** > **Wiki**)。 |
| <kbd>.</kbd>                | 打开 Web IDE。 |

<a id="issues"></a>

### 议题

查看议题时可用的快捷键：

| 键盘快捷键           | 描述 |
|-----------------------------|-------------|
| <kbd>e</kbd>                | 编辑描述。 |
| <kbd>a</kbd>                | 更改指派人。 |
| <kbd>m</kbd>                | 更改里程碑。 |
| <kbd>l</kbd>                | 更改标签。 |
| <kbd>c</kbd>+<kbd>r</kbd>   | 复制议题引用。 |
| <kbd>r</kbd>                | 开始编写评论。预选中的文本会以引用形式出现在评论中。 |
| <kbd>→</kbd>                | 前往下一个设计。 |
| <kbd>←</kbd>                | 前往上一个设计。 |
| <kbd>Escape</kbd>           | 关闭设计。 |

<a id="merge-requests"></a>

### 合并请求

查看[合并请求](project/merge_requests/_index.md)时可用的快捷键：

| macOS 快捷键                    | Windows 快捷键                  | 描述 |
|-----------------------------------|-----------------------------------|-------------|
| <kbd>]</kbd> 或 <kbd>j</kbd>      |                                   | 移动到下一个文件。 |
| <kbd>&#91;</kbd> or <kbd>k</kbd>  |                                   | 移动到上一个文件。 |
| <kbd>Command</kbd>+<kbd>p</kbd>   | <kbd>Control</kbd>+<kbd>p</kbd>   | 搜索并跳转到一个文件进行评审。 |
| <kbd>n</kbd>                      |                                   | 移动到下一个打开的讨论串。 |
| <kbd>p</kbd>                      |                                   | 移动到上一个打开的讨论串。 |
| <kbd>b</kbd>                      |                                   | 复制源分支名称。 |
| <kbd>c</kbd>+<kbd>r</kbd>         |                                   | 复制合并请求引用。 |
| <kbd>r</kbd>                      |                                   | 开始编写评论。预选中的文本会以引用形式出现在评论中。 |
| <kbd>Shift</kbd>+<kbd>Command</kbd>+<kbd>Enter</kbd> | <kbd>Shift</kbd>+<kbd>Control</kbd>+<kbd>Enter</kbd> | 立即发布你的评论。 |
| <kbd>Command</kbd>+<kbd>Enter</kbd> | <kbd>Control</kbd>+<kbd>Enter</kbd> | 将你的评论添加为挂起状态。 |
| <kbd>c</kbd>                      |                                   | 移动到下一个提交。 |
| <kbd>x</kbd>                      |                                   | 移动到上一个提交。 |
| <kbd>Shift</kbd>+<kbd>f</kbd>     |                                   | 切换文件浏览器。 |
| <kbd>v</kbd>                      |                                   | 将文件标记为已查看或未查看。 |
| <kbd>;</kbd>                      |                                   | 展开所有文件。 |
| <kbd>Shift</kbd>+<kbd>;</kbd>     |                                   | 折叠所有文件。 |

<a id="project-files"></a>

### 项目文件

浏览项目中的文件时可用的快捷键（前往 **Code** > **Repository**）：

| 键盘快捷键 | 描述 |
|-------------------|-------------|
| <kbd>↑</kbd>      | 向上移动选择项（仅限搜索文件时，**Code** > **Repository**，然后选择 **Find File**）。 |
| <kbd>↓</kbd>      | 向下移动选择项（仅限搜索文件时，**Code** > **Repository**，然后选择 **Find File**）。 |
| <kbd>Enter</kbd>  | 打开选择项（仅限搜索文件时，**Code** > **Repository**，然后选择 **Find File**）。 |
| <kbd>Escape</kbd> | 返回 **Find File** 屏幕（仅限搜索文件时，**Code** > **Repository**，然后选择 **Find File**）。 |
| <kbd>y</kbd>      | 前往文件永久链接（仅限查看文件时）。 |
| <kbd>.</kbd>      | 打开 Web IDE。 |

<a id="repository-graph"></a>

### 代码仓图表

查看项目[代码仓图表](project/repository/_index.md#repository-history-graph)页面时可用的快捷键（前往 **Code** > **Repository graph**）：

| 键盘快捷键                                                  | 描述 |
|--------------------------------------------------------------------|-------------|
| <kbd>←</kbd> 或 <kbd>h</kbd>                                       | 向左滚动。 |
| <kbd>→</kbd> 或 <kbd>l</kbd>                                       | 向右滚动。 |
| <kbd>↑</kbd> 或 <kbd>k</kbd>                                       | 向上滚动。 |
| <kbd>↓</kbd> 或 <kbd>j</kbd>                                       | 向下滚动。 |
| <kbd>Shift</kbd>+<kbd>↑</kbd> 或 <kbd>Shift</kbd>+<kbd>k</kbd>     | 滚动到顶部。 |
| <kbd>Shift</kbd>+<kbd>↓</kbd> 或 <kbd>Shift</kbd>+<kbd>j</kbd>     | 滚动到底部。 |

<a id="incidents"></a>

### 突发事件

查看突发事件时可用的快捷键：

| 键盘快捷键             | 描述 |
|-------------------------------|-------------|
| <kbd>c</kbd>+<kbd>r</kbd>     | 复制突发事件引用。 |

<a id="wiki-pages"></a>

### Wiki 页面

查看 [Wiki 页面](project/wiki/_index.md)时可用的快捷键：

| 键盘快捷键 | 描述     |
|-------------------|-----------------|
| <kbd>e</kbd>      | 编辑 Wiki 页面。 |

<a id="rich-text-editor"></a>

### 富文本编辑器

使用[富文本编辑器](https://about.gitlab.com/direction/plan/knowledge/content_editor/)编辑文件时可用的快捷键：

| macOS 快捷键 | Windows 快捷键 | 描述 |
|----------------|------------------|-------------|
| <kbd>Command</kbd>+<kbd>c</kbd> | <kbd>Control</kbd>+<kbd>c</kbd> | 复制 |
| <kbd>Command</kbd>+<kbd>x</kbd> | <kbd>Control</kbd>+<kbd>x</kbd> | 剪切 |
| <kbd>Command</kbd>+<kbd>v</kbd> | <kbd>Control</kbd>+<kbd>v</kbd> | 粘贴 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>v</kbd> | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>v</kbd> | 无格式粘贴 |
| <kbd>Command</kbd>+<kbd>z</kbd> | <kbd>Control</kbd>+<kbd>z</kbd> | 撤销 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>z</kbd> | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>z</kbd> | 重做 |
| <kbd>Shift</kbd>+<kbd>Enter</kbd> | <kbd>Shift</kbd>+<kbd>Enter</kbd> | 添加换行符 |

<a id="formatting"></a>

#### 格式化

| macOS 快捷键 | Windows/Linux 快捷键 | 描述 |
|----------------|------------------------|-------------|
| <kbd>Command</kbd>+<kbd>b</kbd> | <kbd>Control</kbd>+<kbd>b</kbd>  | 加粗 |
| <kbd>Command</kbd>+<kbd>i</kbd> | <kbd>Control</kbd>+<kbd>i</kbd>   | 斜体 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>x</kbd>  | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>x</kbd>   | 删除线 |
| <kbd>Command</kbd>+<kbd>k</kbd> | <kbd>Control</kbd>+<kbd>k</kbd>   | 插入链接 |
| <kbd>Command</kbd>+<kbd>Option</kbd>+<kbd>0</kbd> | <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>0</kbd> | 应用普通文本样式 |
| <kbd>Command</kbd>+<kbd>Option</kbd>+<kbd>1</kbd> | <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>1</kbd> | 应用标题样式 1 |
| <kbd>Command</kbd>+<kbd>Option</kbd>+<kbd>2</kbd> | <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>2</kbd> | 应用标题样式 2 |
| <kbd>Command</kbd>+<kbd>Option</kbd>+<kbd>3</kbd> | <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>3</kbd> | 应用标题样式 3 |
| <kbd>Command</kbd>+<kbd>Option</kbd>+<kbd>4</kbd> | <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>4</kbd> | 应用标题样式 4 |
| <kbd>Command</kbd>+<kbd>Option</kbd>+<kbd>5</kbd> | <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>5</kbd> | 应用标题样式 5 |
| <kbd>Command</kbd>+<kbd>Option</kbd>+<kbd>6</kbd> | <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>6</kbd> | 应用标题样式 6 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>7</kbd>  | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>7</kbd> | 有序列表 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>8</kbd>  | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>8</kbd> | 无序列表 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>9</kbd>  | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>9</kbd> | 任务列表 |
| <kbd>Command</kbd>+<kbd>Option</kbd>+<kbd>c</kbd> | <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>c</kbd> | 代码块 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>h</kbd>  | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>h</kbd> | 高亮 |
| <kbd>Command</kbd>+<kbd>,</kbd> | <kbd>Control</kbd>+<kbd>,</kbd> | 下标 |
| <kbd>Command</kbd>+<kbd>.</kbd> | <kbd>Control</kbd>+<kbd>.</kbd> | 上标 |
| <kbd>Tab</kbd> | <kbd>Tab</kbd> | 增加列表缩进 |
| <kbd>Shift</kbd>+<kbd>Tab</kbd> | <kbd>Shift</kbd>+<kbd>Tab</kbd> | 减少列表缩进 |

<a id="text-selection"></a>

#### 文本选择

| macOS 快捷键                    | Windows 快捷键                  | 描述 |
|-----------------------------------|-----------------------------------|-------------|
| <kbd>Command</kbd>+<kbd>a</kbd>   | <kbd>Control</kbd>+<kbd>a</kbd>   | 全选 |
| <kbd>Shift</kbd>+<kbd>←</kbd>     | <kbd>Shift</kbd>+<kbd>←</kbd>     | 向左扩展选中一个字符 |
| <kbd>Shift</kbd>+<kbd>→</kbd>     | <kbd>Shift</kbd>+<kbd>→</kbd>     | 向右扩展选中一个字符 |
| <kbd>Shift</kbd>+<kbd>↑</kbd>     | <kbd>Shift</kbd>+<kbd>↑</kbd>     | 向上扩展选中一行 |
| <kbd>Shift</kbd>+<kbd>↓</kbd>     | <kbd>Shift</kbd>+<kbd>↓</kbd>     | 向下扩展选中一行 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>↑</kbd> | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>↑</kbd> | 扩展到文档开头 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>↓</kbd> | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>↓</kbd> | 扩展到文档末尾 |

<a id="gitlab-duo-chat"></a>

### 极狐GitLab Duo Chat

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: CodeRider Duo Core, Pro, or Enterprise
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- Introduced in 极狐GitLab 18.7。

{{< /history >}}

以下快捷键在使用[极狐GitLab Duo Non-Agentic Chat](gitlab_duo_chat/_index.md) 时可用。

| macOS 快捷键                    | Windows 快捷键                  | 描述 |
|-----------------------------------|-----------------------------------|-------------|
| <kbd>Option</kbd>+<kbd>d</kbd>    | <kbd>Alt</kbd>+<kbd>d</kbd> | 打开或关闭 Chat，或者如果 Chat 已打开，则将焦点切换到 Chat|
| <kbd>Option</kbd>+<kbd>n</kbd>    | <kbd>Alt</kbd>+<kbd>n</kbd> | 在 Chat 中，开始一个新会话。 |
| <kbd>Option</kbd>+<kbd>r</kbd>    | <kbd>Alt</kbd>+<kbd>r</kbd> | [重构代码](gitlab_duo_chat/examples.md#refactor-code-in-the-ide)|
| <kbd>Option</kbd>+<kbd>t</kbd>    | <kbd>Alt</kbd>+<kbd>t</kbd> | [编写测试](gitlab_duo_chat/examples.md#write-tests-in-the-ide)|

你可以在 IDE 中自定义这些快捷键。

<a id="epics"></a>

## 史诗

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

查看[史诗](group/epics/_index.md)时可用的快捷键：

| 键盘快捷键            | 描述       |
|------------------------------|-------------------|
| <kbd>e</kbd>                 | 编辑描述。 |
| <kbd>l</kbd>                 | 更改标签。     |
| <kbd>c</kbd>+<kbd>r</kbd>    | 复制史诗引用。 |

<a id="disable-keyboard-shortcuts"></a>

## 禁用键盘快捷键

{{< history >}}

- [Moved] to user preferences in 极狐GitLab 16.4。

{{< /history >}}

要禁用键盘快捷键：

1. 在右上角，选择你的头像。
1. 选择 **Preferences**。
1. 在 **Behavior** 部分，清除 **Enable keyboard shortcuts** 复选框。
1. 选择 **Save changes**。

<a id="enable-keyboard-shortcuts"></a>

## 启用键盘快捷键

{{< history >}}

- [Moved] to user preferences in 极狐GitLab 16.4。

{{< /history >}}

要启用键盘快捷键：

1. 在右上角，选择你的头像。
1. 选择 **Preferences**。
1. 在 **Behavior** 部分，勾选 **Enable keyboard shortcuts** 复选框。
1. 选择 **Save changes**。

<a id="troubleshooting"></a>

## 故障排除

<a id="linux-shortcuts"></a>

### Linux 快捷键

Linux 用户可能会遇到操作系统或浏览器覆盖 极狐GitLab 键盘快捷键的问题。