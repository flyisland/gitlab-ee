---
stage: Growth
group: Engagement
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 键盘快捷键
description: 全局快捷键、导航和快速访问。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 提供了多个键盘快捷键，您可以使用它们访问各项功能。

要在极狐GitLab 中显示列出键盘快捷键的窗口，请使用以下任一方法：

- 按 <kbd>?</kbd>。
- 在应用程序左下角，选择**帮助**，然后选择**键盘快捷键**。

尽管[全局快捷键](#global-shortcuts)在极狐GitLab 的任何区域都可用，但其他快捷键必须在特定页面中才可用，具体说明见各章节。

<a id="global-shortcuts"></a>

## 全局快捷键

这些快捷键在极狐GitLab 的大多数区域都可用：

| 键盘快捷键                  | 描述 |
|------------------------------------|-------------|
| <kbd>?</kbd>                       | 显示或隐藏快捷键参考表。 |
| <kbd>Shift</kbd>+<kbd>h</kbd>      | 转到主页。 |
| <kbd>Shift</kbd>+<kbd>p</kbd>      | 转到您的**项目**页面。 |
| <kbd>Shift</kbd>+<kbd>g</kbd>      | 转到您的**群组**页面。 |
| <kbd>Shift</kbd>+<kbd>a</kbd>      | 转到您的**活动**页面。 |
| <kbd>Shift</kbd>+<kbd>l</kbd>      | 转到您的**里程碑**页面。 |
| <kbd>Shift</kbd>+<kbd>s</kbd>      | 转到您的**代码片段**页面。 |
| <kbd>s</kbd> / <kbd>/</kbd>        | 将光标置于搜索栏中。 |
| <kbd>f</kbd>                       | 聚焦筛选栏 |
| <kbd>Shift</kbd>+<kbd>i</kbd>      | 转到您的**议题**页面。 |
| <kbd>Shift</kbd>+<kbd>m</kbd>      | 转到您的**合并请求**页面。 |
| <kbd>Shift</kbd>+<kbd>r</kbd>      | 转到您的**评审请求**页面。 |
| <kbd>Shift</kbd>+<kbd>t</kbd>      | 转到您的**待办事项列表**页面。 |
| <kbd>p</kbd>，然后 <kbd>b</kbd>    | 显示或隐藏性能栏。 |
| <kbd>Escape</kbd>                  | 隐藏工具提示或弹出框。 |
| <kbd>g</kbd>，然后 <kbd>x</kbd>    | 在 [GitLab](https://gitlab.com/) 和 [GitLab Next](https://next.gitlab.com/) 之间切换（仅限 GitLab.com）。 |
| <kbd>.</kbd>                       | 打开 [Web IDE](project/web_ide/_index.md)。 |
| <kbd>d</kbd>                       | 打开极狐GitLab Duo Chat |

此外，在文本字段中编辑文本时（例如评论、回复、议题描述和合并请求描述），还可以使用以下快捷键：

| macOS 快捷键                                       | Windows 快捷键                                   | 描述 |
|------------------------------------------------------|----------------------------------------------------|-------------|
| <kbd>↑</kbd>                                         | <kbd>↑</kbd>                                       | 编辑您的最后一条评论。您必须位于讨论串下方的空白文本字段中，并且该讨论串中必须已至少有一条评论。 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>p</kbd>     | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>p</kbd>   | 在顶部带有**编写**和**预览**标签页的文本字段中编辑文本时，切换 Markdown 预览。 |
| <kbd>Command</kbd>+<kbd>b</kbd>                      | <kbd>Control</kbd>+<kbd>b</kbd>                    | 将所选文本加粗（在其两侧添加 `**`）。 |
| <kbd>Command</kbd>+<kbd>i</kbd>                      | <kbd>Control</kbd>+<kbd>i</kbd>                    | 将所选文本设为斜体（在其两侧添加 `_`）。 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>x</kbd>     | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>x</kbd>   | 为所选文本添加删除线（在其两侧添加 `~~`）。 |
| <kbd>Command</kbd>+<kbd>k</kbd>                      | <kbd>Control</kbd>+<kbd>k</kbd>                    | 添加链接（在所选文本两侧添加 `[]()`）。 |
| <kbd>Command</kbd>+<kbd>[</kbd>                      | <kbd>Control</kbd>+<kbd>[</kbd>                    | 减少文本缩进。 |
| <kbd>Command</kbd>+<kbd>]</kbd>                      | <kbd>Control</kbd>+<kbd>]</kbd>                    | 增加文本缩进。 |
| <kbd>Command</kbd>+<kbd>Enter</kbd>                  | <kbd>Control</kbd>+<kbd>Enter</kbd>                | 提交或保存更改 |

即使在禁用其他键盘快捷键的情况下，文本字段编辑快捷键也始终处于启用状态。

<a id="project"></a>

## 项目

这些快捷键在项目的任何页面都可用。您必须相对快速地输入它们才能生效，它们会将您带到项目中的另一个页面。

| 键盘快捷键           | 描述 |
|-----------------------------|-------------|
| <kbd>g</kbd>+<kbd>o</kbd>   | 转到**项目概览**页面。 |
| <kbd>g</kbd>+<kbd>v</kbd>   | 转到项目**活动**页面（**管理** > **活动**）。 |
| <kbd>g</kbd>+<kbd>r</kbd>   | 转到项目**发布**页面（**部署** > **发布**）。 |
| <kbd>g</kbd>+<kbd>f</kbd>   | 转到[项目文件](#project-files)（**代码** > **代码仓库**）。 |
| <kbd>t</kbd>                | 打开项目文件搜索对话框。（**代码** > **代码仓库**，选择**查找文件**）。 |
| <kbd>g</kbd>+<kbd>c</kbd>   | 转到项目**提交**页面（**代码** > **提交**）。 |
| <kbd>g</kbd>+<kbd>n</kbd>   | 转到[**代码仓库图谱**](#repository-graph)页面（**代码** > **代码仓库图谱**）。 |
| <kbd>g</kbd>+<kbd>d</kbd>   | 转到**代码仓库分析**页面中的图表（**分析** > **代码仓库分析**）。 |
| <kbd>g</kbd>+<kbd>i</kbd>   | 转到项目**工作项**页面（**计划** > **工作项**）。 |
| <kbd>i</kbd>                | 转到**新建议题**页面（**计划** > **工作项**，选择**新建工作项**）。 |
| <kbd>g</kbd>+<kbd>b</kbd>   | 转到项目**议题看板**页面（**计划** > **议题看板**）。 |
| <kbd>g</kbd>+<kbd>m</kbd>   | 转到项目**合并请求**页面（**代码** > **合并请求**）。 |
| <kbd>g</kbd>+<kbd>p</kbd>   | 转到 CI/CD **流水线**页面（**构建** > **流水线**）。 |
| <kbd>g</kbd>+<kbd>j</kbd>   | 转到 CI/CD **作业**页面（**构建** > **作业**）。 |
| <kbd>g</kbd>+<kbd>e</kbd>   | 转到项目**环境**页面（**运维** > **环境**）。 |
| <kbd>g</kbd>+<kbd>k</kbd>   | 转到项目 **Kubernetes 集群**集成页面（**运维** > **Kubernetes 集群**）。您必须至少拥有 [`maintainer` 权限](permissions.md)才能访问此页面。 |
| <kbd>g</kbd>+<kbd>s</kbd>   | 转到项目**代码片段**页面（**代码** > **代码片段**）。 |
| <kbd>g</kbd>+<kbd>w</kbd>   | 转到项目 Wiki（**计划** > **Wiki**）（如果已启用）。 |
| <kbd>.</kbd>                | 打开 Web IDE。 |

<a id="issues"></a>

### 议题

查看议题时可以使用以下快捷键：

| 键盘快捷键           | 描述 |
|-----------------------------|-------------|
| <kbd>e</kbd>                | 编辑描述。 |
| <kbd>a</kbd>                | 更改指派人。 |
| <kbd>m</kbd>                | 更改里程碑。 |
| <kbd>l</kbd>                | 更改标记。 |
| <kbd>c</kbd>+<kbd>r</kbd>   | 复制议题引用。 |
| <kbd>r</kbd>                | 开始撰写评论。所选文本会在评论中作为引用。 |
| <kbd>→</kbd>                | 转到下一个设计。 |
| <kbd>←</kbd>                | 转到上一个设计。 |
| <kbd>Escape</kbd>           | 关闭设计。 |

<a id="merge-requests"></a>

### 合并请求

查看[合并请求](project/merge_requests/_index.md)时可以使用以下快捷键：

| macOS 快捷键                    | Windows 快捷键                  | 描述 |
|-----------------------------------|-----------------------------------|-------------|
| <kbd>]</kbd> 或 <kbd>j</kbd>      |                                   | 移动到下一个文件。 |
| <kbd>&#91;</kbd> 或 <kbd>k</kbd>  |                                   | 移动到上一个文件。 |
| <kbd>Command</kbd>+<kbd>p</kbd>   | <kbd>Control</kbd>+<kbd>p</kbd>   | 搜索并跳转到要评审的文件。 |
| <kbd>n</kbd>                      |                                   | 移动到下一个未解决的讨论串。 |
| <kbd>p</kbd>                      |                                   | 移动到上一个未解决的讨论串。 |
| <kbd>b</kbd>                      |                                   | 复制源分支名称。 |
| <kbd>c</kbd>+<kbd>r</kbd>         |                                   | 复制合并请求引用。 |
| <kbd>r</kbd>                      |                                   | 开始撰写评论。所选文本会在评论中作为引用。 |
| <kbd>Shift</kbd>+<kbd>Command</kbd>+<kbd>Enter</kbd> | <kbd>Shift</kbd>+<kbd>Control</kbd>+<kbd>Enter</kbd> | 立即发布您的评论。 |
| <kbd>Command</kbd>+<kbd>Enter</kbd> | <kbd>Control</kbd>+<kbd>Enter</kbd> | 将您的评论以待处理状态添加，作为评审的一部分。 |
| <kbd>c</kbd>                      |                                   | 移动到下一个提交。 |
| <kbd>x</kbd>                      |                                   | 移动到上一个提交。 |
| <kbd>Shift</kbd>+<kbd>f</kbd>     |                                   | 切换文件浏览器。 |
| <kbd>v</kbd>                      |                                   | 将文件标记为已查看或未查看。 |
| <kbd>;</kbd>                      |                                   | 展开所有文件。 |
| <kbd>Shift</kbd>+<kbd>;</kbd>     |                                   | 折叠所有文件。 |
| <kbd>Shift</kbd>+<kbd>d</kbd>     |                                   | 在内联和并排差异视图之间切换。 |

<a id="project-files"></a>

### 项目文件

浏览项目中的文件时可以使用以下快捷键（转到**代码** > **代码仓库**）：

| 键盘快捷键 | 描述 |
|-------------------|-------------|
| <kbd>↑</kbd>      | 向上移动选择（仅在搜索文件时可用，**代码** > **代码仓库**，然后选择**查找文件**）。 |
| <kbd>↓</kbd>      | 向下移动选择（仅在搜索文件时可用，**代码** > **代码仓库**，然后选择**查找文件**）。 |
| <kbd>Enter</kbd>  | 打开所选项（仅在搜索文件时可用，**代码** > **代码仓库**，然后选择**查找文件**）。 |
| <kbd>Escape</kbd> | 返回**查找文件**界面（仅在搜索文件时可用，**代码** > **代码仓库**，然后选择**查找文件**）。 |
| <kbd>y</kbd>      | 转到文件永久链接（仅在查看文件时可用）。 |
| <kbd>.</kbd>      | 打开 Web IDE。 |
| <kbd>Shift</kbd>+<kbd>f</kbd> | 显示或隐藏[文件树浏览器](project/repository/files/file_tree_browser.md)。 |
| <kbd>f</kbd>      | 打开搜索面板（仅在文件树浏览器打开时可用）。 |

<a id="repository-graph"></a>

### 代码仓库图谱

查看项目[代码仓库图谱](project/repository/_index.md#repository-history-graph)页面时可以使用以下快捷键（转到**代码** > **代码仓库图谱**）：

| 键盘快捷键                                                  | 描述 |
|--------------------------------------------------------------------|-------------|
| <kbd>←</kbd> 或 <kbd>h</kbd>                                       | 向左滚动。 |
| <kbd>→</kbd> 或 <kbd>l</kbd>                                       | 向右滚动。 |
| <kbd>↑</kbd> 或 <kbd>k</kbd>                                       | 向上滚动。 |
| <kbd>↓</kbd> 或 <kbd>j</kbd>                                       | 向下滚动。 |
| <kbd>Shift</kbd>+<kbd>↑</kbd> 或 <kbd>Shift</kbd>+<kbd>k</kbd>     | 滚动到顶部。 |
| <kbd>Shift</kbd>+<kbd>↓</kbd> 或 <kbd>Shift</kbd>+<kbd>j</kbd>     | 滚动到底部。 |

<a id="incidents"></a>

### 事件

查看事件时可以使用以下快捷键：

| 键盘快捷键             | 描述 |
|-------------------------------|-------------|
| <kbd>c</kbd>+<kbd>r</kbd>     | 复制事件引用。 |

<a id="wiki-pages"></a>

### Wiki 页面

查看 [Wiki 页面](project/wiki/_index.md)时可以使用以下快捷键：

| 键盘快捷键 | 描述     |
|-------------------|-----------------|
| <kbd>e</kbd>      | 编辑 Wiki 页面。 |

<a id="rich-text-editor"></a>

### 富文本编辑器

使用[富文本编辑器](rich_text_editor.md)编辑文件时可以使用以下快捷键：

| macOS 快捷键 | Windows 快捷键 | 描述 |
|----------------|------------------|-------------|
| <kbd>Command</kbd>+<kbd>c</kbd> | <kbd>Control</kbd>+<kbd>c</kbd> | 复制 |
| <kbd>Command</kbd>+<kbd>x</kbd> | <kbd>Control</kbd>+<kbd>x</kbd> | 剪切 |
| <kbd>Command</kbd>+<kbd>v</kbd> | <kbd>Control</kbd>+<kbd>v</kbd> | 粘贴 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>v</kbd> | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>v</kbd> | 粘贴而不带格式 |
| <kbd>Command</kbd>+<kbd>Option</kbd>+<kbd>v</kbd> | <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>v</kbd> | 在表格单元格中，将复制的表格作为嵌套表格粘贴到该单元格内 |
| <kbd>Command</kbd>+<kbd>z</kbd> | <kbd>Control</kbd>+<kbd>z</kbd> | 撤销 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>v</kbd> | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>v</kbd> | 重做 |
| <kbd>Shift</kbd>+<kbd>Enter</kbd> | <kbd>Shift</kbd>+<kbd>Enter</kbd> | 添加换行符 |

<a id="formatting"></a>

#### 格式设置

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
| <kbd>Tab</kbd> | <kbd>Tab</kbd> | 缩进列表 |
| <kbd>Shift</kbd>+<kbd>Tab</kbd> | <kbd>Shift</kbd>+<kbd>Tab</kbd> | 减少列表缩进 |

<a id="text-selection"></a>

#### 文本选择

| macOS 快捷键                    | Windows 快捷键                  | 描述 |
|-----------------------------------|-----------------------------------|-------------|
| <kbd>Command</kbd>+<kbd>a</kbd>   | <kbd>Control</kbd>+<kbd>a</kbd>   | 全选 |
| <kbd>Shift</kbd>+<kbd>←</kbd>     | <kbd>Shift</kbd>+<kbd>←</kbd>     | 将选择范围向左扩展一个字符 |
| <kbd>Shift</kbd>+<kbd>→</kbd>     | <kbd>Shift</kbd>+<kbd>→</kbd>     | 将选择范围向右扩展一个字符 |
| <kbd>Shift</kbd>+<kbd>↑</kbd>     | <kbd>Shift</kbd>+<kbd>↑</kbd>     | 将选择范围向上扩展一行 |
| <kbd>Shift</kbd>+<kbd>↓</kbd>     | <kbd>Shift</kbd>+<kbd>↓</kbd>     | 将选择范围向下扩展一行 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>↑</kbd> | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>↑</kbd> | 将选择范围扩展到文档开头 |
| <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>↓</kbd> | <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>↓</kbd> | 将选择范围扩展到文档末尾 |

<a id="gitlab-duo-chat"></a>

### 极狐GitLab Duo Chat

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise、极狐GitLab Duo with Amazon Q
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在受支持的 IDE 中使用 [GitLab Duo Non-Agentic Chat](gitlab_duo_chat/_index.md) 时，可以使用以下快捷键。

| macOS 快捷键                    | Windows 快捷键                  | 描述 | VS Code | JetBrains IDE | Visual Studio |
|-----------------------------------|-----------------------------------|-------------|---|---|---|
| <kbd>Option</kbd>+<kbd>d</kbd>    | <kbd>Alt</kbd>+<kbd>d</kbd> | 打开或关闭 Chat，如果 Chat 已打开则切换焦点| {{< yes >}} | {{< yes >}} | {{< no >}} |
| <kbd>Option</kbd>+<kbd>n</kbd>    | <kbd>Alt</kbd>+<kbd>n</kbd> | 在 Chat 中开始新对话。 | {{< yes >}} | {{< no >}} | {{< no >}} |
| <kbd>Option</kbd>+<kbd>r</kbd>    | <kbd>Alt</kbd>+<kbd>r</kbd> | [重构代码](gitlab_duo_chat/examples.md#refactor-code-in-the-ide)| {{< yes >}} | {{< no >}} | {{< no >}} |
| <kbd>Option</kbd>+<kbd>t</kbd>    | <kbd>Alt</kbd>+<kbd>t</kbd> | [编写测试](gitlab_duo_chat/examples.md#write-tests-in-the-ide)| {{< yes >}} | {{< no >}} | {{< no >}} |

您可以在 IDE 中自定义这些快捷键。

<a id="customize-in-vs-code"></a>

#### 在 VS Code 中自定义

1. 在 VS Code 中，转到**设置** > **键盘快捷键**。
1. 在搜索文本框中，输入 <kbd>GitLab</kbd> 以查找所有 GitLab 快捷键。
1. 对于要自定义的快捷键，选择**更改键绑定（Enter）** {{< icon name="pencil" >}}。
1. 按下新的快捷键组合，然后按 <kbd>Enter</kbd>。

<a id="customize-in-jetbrains-ides"></a>

#### 在 JetBrains IDE 中自定义

1. 在您的 JetBrains IDE 中，转到**设置** > **按键映射**，或您的 IDE 中对应的键盘
   映射设置。
1. 查找所有 GitLab 快捷键。
1. 自定义相应的快捷键并保存。

<a id="customize-in-visual-studio"></a>

#### 在 Visual Studio 中自定义

1. 在 Visual Studio 中，转到**工具** > **选项**。
1. 转到**环境** > **键盘**。
1. 在**显示以下内容的命令：**文本框中，输入 <kbd>GitLab</kbd> 以查找所有 GitLab 快捷键。
1. 在**按快捷键**下，选择当前的快捷键组合。
1. 按下新的快捷键组合，然后选择**分配**。
1. 选择**确定**。

<a id="epics"></a>

## 史诗

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

查看[史诗](group/epics/_index.md)时可以使用以下快捷键：

| 键盘快捷键            | 描述       |
|------------------------------|-------------------|
| <kbd>e</kbd>                 | 编辑描述。 |
| <kbd>l</kbd>                 | 更改标记。     |
| <kbd>c</kbd>+<kbd>r</kbd>    | 复制史诗引用。 |

<a id="disable-keyboard-shortcuts"></a>

## 禁用键盘快捷键

要禁用键盘快捷键：

1. 在右上角，选择您的头像。
1. 选择**偏好设置**。
1. 在**行为**部分，清除**启用键盘快捷键**复选框。
1. 选择**保存更改**。

<a id="enable-keyboard-shortcuts"></a>

## 启用键盘快捷键

要启用键盘快捷键：

1. 在右上角，选择您的头像。
1. 选择**偏好设置**。
1. 在**行为**部分，选中**启用键盘快捷键**复选框。
1. 选择**保存更改**。

<a id="troubleshooting"></a>

## 故障排除

<a id="linux-shortcuts"></a>

### Linux 快捷键

Linux 用户可能会遇到被操作系统或浏览器覆盖的极狐GitLab 键盘快捷键。
