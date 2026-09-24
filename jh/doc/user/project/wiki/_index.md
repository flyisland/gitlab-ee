---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Wiki
description: 文档、外部 Wiki、Wiki 事件和历史记录。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Wiki 以熟悉的格式提供项目和群组文档。
Wiki 页面：

- 使用 Markdown、RDoc、AsciiDoc 或 Org 格式生成技术文档、指南和知识库。
- 创建与极狐GitLab 项目和群组直接集成的协作文档。
- 将文档存储在 Git 代码仓库中，以实现版本控制和协作。
- 通过侧边栏自定义支持自定义导航和组织。
- 将内容导出为 PDF 文件，以便离线访问和共享。
- 将您的内容与代码库分开维护，同时将其保存在同一项目中。
- 支持页面上的表情符号回应，以获取反馈和互动。

每个 Wiki 都是一个独立的 Git 代码仓库。
您可以通过极狐GitLab Web 界面或
[在本地使用 Git](#create-or-edit-wiki-pages-locally) 创建和编辑 Wiki 页面。
使用 Markdown 编写的 Wiki 页面支持所有 [Markdown 功能](../../markdown.md)，并为链接提供
[Wiki 特定行为](markdown.md)。

Wiki 页面显示一个 [侧边栏](#sidebar)，您可以自定义该侧边栏。

<a id="view-a-project-wiki"></a>

## 查看项目 Wiki

要访问项目 Wiki：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **Wiki**。

如果项目左侧边栏中未列出 **计划** > **Wiki**，则项目管理员
已 [禁用它](#enable-or-disable-a-project-wiki)。

<a id="configure-a-default-branch-for-your-wiki"></a>

## 为您的 Wiki 配置默认分支

您的 Wiki 代码仓库继承实例或群组的 [默认分支名称](../repository/branches/default.md)。如果未配置自定义分支名称，极狐GitLab 使用 `main`。
要重命名 Wiki 的默认分支，请 [更新代码仓库中的默认分支名称](../repository/branches/default.md#update-the-default-branch-name-in-your-repository)。

<a id="create-the-wiki-home-page"></a>

## 创建 Wiki 首页

创建 Wiki 时，它是空的。在您首次访问时，可以创建用户查看 Wiki 时看到的首页。此页面需要特定路径才能用作 Wiki 的首页。要创建它：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 选择 **创建您的第一个页面**。
1. 可选。更改首页的 **标题**。
1. 极狐GitLab 要求此首页的路径为 `home`。此路径上的页面用作 Wiki 的首页。
1. 可选。选择 **编辑页面选项** ({{< icon name="chevron-down" >}}) 以：
   - 更改页面的 **路径**。默认情况下，路径由标题生成。
     页面路径使用 [特殊字符](#special-characters-in-page-paths) 表示子目录和格式，
     并具有 [长度限制](#length-restrictions-for-file-and-directory-names)。
   - 更改内容 **格式**。
   - 选择 **模板**。有关更多信息，请参阅 [从模板创建](#from-a-template)。
1. 在内容区域为您的首页添加欢迎消息。您可以随时稍后编辑。
1. 选择 **创建页面**。要在保存前添加提交消息，请选择 **创建页面** 旁边的箭头，然后选择 **带消息保存更改**。

<a id="create-a-new-wiki-page"></a>

## 创建新的 Wiki 页面

先决条件：

- 开发者、维护者或所有者角色。

要从项目或群组创建新的 Wiki 页面：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组或项目。
1. 在右上角，选择 **新建** ({{< icon name="plus" >}})，然后选择 **新建 Wiki 页面**。

或者：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 选择 **Wiki 操作** ({{< icon name="ellipsis_v" >}})，然后在此页面或任何其他 Wiki 页面上选择 **新建页面**。

打开新页面表单后，完成以下步骤：

1. 在编辑器头部为您的页面添加 **标题**。
1. 可选。选择 **编辑页面选项** ({{< icon name="chevron-down" >}}) 以：
   - 更改页面的 **路径**。默认情况下，路径由标题生成。
     页面路径使用 [特殊字符](#special-characters-in-page-paths) 表示子目录和格式，
     并具有 [长度限制](#length-restrictions-for-file-and-directory-names)。
   - 更改内容 **格式**。
   - 选择 **模板**。有关更多信息，请参阅 [从模板创建](#from-a-template)。
1. 可选。向您的 Wiki 页面添加内容。
1. 可选。附加文件，极狐GitLab 会将其存储在 Wiki 的 Git 代码仓库中。
1. 选择 **创建页面**。要在保存前添加提交消息，请选择 **创建页面** 旁边的箭头，然后选择 **带消息保存更改**。

<a id="from-a-template"></a>

### 从模板创建

如果您的项目中至少有一个模板，则可以从 [模板](#create-a-template) 创建新的 Wiki 页面。

先决条件：

- 您必须已经 [创建](#create-a-template) 了至少一个模板。

{{< tabs >}}

{{< tab title="From template list" >}}

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 选择 **模板** 以查看所有可用模板。
1. 在要使用的模板旁边，选择 **从模板创建**。
1. 新页面表单将打开，其中：
   - 模板内容已预填在内容区域中。
   - 模板已在模板下拉列表中选择。
1. 为您的页面输入标题。
1. 根据需要修改内容。
1. 选择 **创建页面**。

{{< /tab >}}

{{< tab title="From template page" >}}

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 选择 **模板** 以查看所有可用模板。
1. 选择并点击要使用的模板。
1. 在页面头部，选择 **从模板创建**。
1. 新页面表单将打开，并预先选择当前模板并加载其内容。
1. 为您的页面输入标题。
1. 根据需要修改内容。
1. 选择 **创建页面**。

{{< /tab >}}

{{< tab title="From new page form" >}}

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 选择 **新建页面**。
1. 在 **选择模板** 下拉列表中，选择您想要的模板。
1. 模板内容会自动加载到内容区域中。
1. 为您的页面输入标题。
1. 根据需要修改内容。
1. 选择 **创建页面**。

{{< /tab >}}

{{< /tabs >}}

<a id="create-or-edit-wiki-pages-locally"></a>

### 在本地创建或编辑 Wiki 页面

Wiki 基于 Git 代码仓库，因此您可以在本地克隆它们，并像处理其他任何 Git 代码仓库一样进行编辑。要在本地克隆 Wiki 代码仓库：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 选择 **Wiki 操作** ({{< icon name="ellipsis_v" >}})，然后选择 **克隆代码仓库**。
1. 按照屏幕上的说明操作。

您在本地添加到 Wiki 的文件必须使用以下受支持的扩展名之一，具体取决于您希望使用的标记语言。
具有不受支持扩展名的文件在推送到极狐GitLab 后不会显示：

- Markdown 扩展名：`.mdown`, `.mkd`, `.mkdn`, `.md`, `.markdown`。
- AsciiDoc 扩展名：`.adoc`, `.ad`, `.asciidoc`。
- 其他标记扩展名：`.textile`, `.rdoc`, `.org`, `.creole`, `.wiki`, `.mediawiki`, `.rst`。

<a id="special-characters-in-page-paths"></a>

### 页面路径中的特殊字符

Wiki 页面作为文件存储在 Git 代码仓库中，默认情况下，页面的文件名也是其标题。文件名中的某些字符具有特殊含义：

- 存储页面时，空格会转换为连字符。
- 显示页面时，连字符 (`-`) 会转换回空格。
- 斜杠 (`/`) 用作路径分隔符，不能显示在标题中。如果您
  创建的文件的标题包含 `/` 字符，极狐GitLab 会创建构建该路径所需的所有子目录。例如，标题为 `docs/my-page` 会创建一个路径为 `/wikis/docs/my-page` 的 Wiki 页面。

为规避这些限制，您还可以在页面内容之前的前置数据块中存储 Wiki 页面的标题。例如：

```yaml
---
title: Page title
---
```

<a id="length-restrictions-for-file-and-directory-names"></a>

### 文件和目录名称的长度限制

许多常见的文件系统对文件和目录名称有 [255 字节的限制](https://en.wikipedia.org/wiki/Comparison_of_file_systems#Limits)。Git 和极狐GitLab 都支持超过这些限制的路径。但是，如果您的文件系统强制执行这些限制，则无法在本地检出包含超过此限制的文件名的 Wiki。为防止此问题，极狐GitLab Web 界面和 API 强制执行以下限制：

- 文件名为 245 字节（为文件扩展名保留 10 字节）。
- 目录名为 255 字节。

非 ASCII 字符占用多个字节。

虽然您仍然可以在本地创建超过这些限制的文件，但您的团队成员之后可能无法在本地检出该 Wiki。

<a id="edit-a-wiki-page"></a>

## 编辑 Wiki 页面

先决条件：

- 您必须具有开发者、维护者或所有者角色。

Wiki 编辑器打开时带有一个粘性标题，其中包含：

- 页面标题。您可以内联编辑。
- **编辑页面选项** ({{< icon name="chevron-down" >}}) 以更改页面路径、格式或选择模板。
- 一个侧边栏切换 ({{< icon name="sidebar" >}})，用于显示或隐藏 Wiki 侧边栏。
- **保存更改** 和 **取消** 以保存或放弃您的更改。

要编辑 Wiki 页面：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 转到要编辑的页面，然后选择 **编辑**。
1. 编辑内容。
1. 选择 **保存更改**。要在保存前添加提交消息，请选择 **保存更改** 旁边的箭头，然后选择 **带消息保存更改**。

当您预览页面并滚动时，页面顶部的粘性栏会保持 **编辑** 和其他操作可访问。

Wiki 页面的未保存更改会保留在本地浏览器存储中，以防止意外数据丢失。

<a id="create-a-table-of-contents"></a>

### 创建目录

内容中包含标题的 Wiki 页面会在侧边栏中自动显示目录部分。

您也可以选择在页面本身上显示单独的目录部分。要从 Wiki 页面的子标题生成目录，请使用
`[[_TOC_]]` 标签。有关示例，请参阅 [目录](../../markdown.md#table-of-contents)。

<a id="react-to-a-wiki-page"></a>

## 回应 Wiki 页面

您可以直接在 Wiki 页面上添加表情符号回应。回应显示在页面内容下方、评论部分上方。

要回应 Wiki 页面：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 转到您要回应的页面。
1. 在页面内容下方，选择现有的表情符号以添加您的回应，或选择
   **添加回应** ({{< icon name="slight-smile" >}}) 以选择不同的表情符号。

要移除回应，请再次选择该表情符号。每个用户对每个页面每种类型的回应只能添加一个。

当您首次对页面添加回应时，极狐GitLab 会为您订阅该页面的通知。

<a id="delete-a-wiki-page"></a>

## 删除 Wiki 页面

先决条件：

- 您必须具有开发者、维护者或所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 转到要删除的页面。
1. 选择 **Wiki 操作** ({{< icon name="ellipsis_v" >}})，然后选择 **删除页面**。
1. 确认删除。

<a id="move-or-rename-a-wiki-page"></a>

## 移动或重命名 Wiki 页面

在极狐GitLab 17.1 及更高版本中，当您移动或重命名页面时，会自动设置从旧页面到新页面的重定向。重定向列表存储在 Wiki 代码仓库的 `.gitlab/redirects.yml` 文件中。

先决条件：

- 您必须具有开发者、维护者或所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 转到要移动或重命名的页面。
1. 选择 **编辑**。
1. 在编辑器头部，选择 **编辑页面选项** ({{< icon name="chevron-down" >}})。
1. 要移动页面，请更改 **路径** 字段。例如，
   如果您有一个名为 `About` 的 Wiki 页面位于 `Company` 下，并且您想
   将其移动到 Wiki 的根目录，请将 **路径** 从 `About` 更改为 `/About`。
1. 要重命名页面，请更改 **路径**。
1. 选择 **保存更改**。

<a id="export-a-wiki-page"></a>

## 导出 Wiki 页面

您可以将 Wiki 页面导出为 PDF 文件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 转到要导出的页面。
1. 在右上角，选择 **Wiki 操作** ({{< icon name="ellipsis_v" >}})，然后选择 **打印为 PDF**。

将创建 Wiki 页面的 PDF。

<a id="creating-diagrams-in-the-wiki-using-drawio"></a>

## 使用 Draw.io 在 Wiki 中创建图表

借助 diagrams.net 集成，您可以在 Wiki 页面上创建和嵌入 SVG 图表。图表编辑器在纯文本编辑器和富文本编辑器中均可用。

在 JihuLab.com 上，此集成对所有用户启用，无需任何额外配置。

在极狐GitLab 私有化部署上，您可以集成免费的 diagrams.net 网站，或在离线环境中托管您自己的 diagrams.net 站点。

要设置集成，您必须：

1. 选择集成免费的 diagrams.net 网站或配置您的 diagrams.net 服务器。
1. 启用集成。

完成集成后，diagrams.net 编辑器将使用您提供的 URL 打开。

<a id="wiki-page-templates"></a>

## Wiki 页面模板

您可以创建模板，用于创建新页面或应用于现有页面。模板是存储在 Wiki 代码仓库的 `templates/` 目录中的 Wiki 页面。

<a id="create-a-template"></a>

### 创建模板

先决条件：

- 您必须具有开发者、维护者或所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 选择 **Wiki 操作** ({{< icon name="ellipsis_v" >}})，然后选择 **模板**。
1. 选择 **新建模板**。
1. 输入模板标题、格式和内容。

模板路径由标题生成，无法编辑。要重命名模板，请更改其标题。标题仅作为路径的一部分存储，因此将模板应用于页面不会在页面内容中插入任何标题元数据。要创建嵌套模板，请在标题中使用 `/` 作为路径分隔符。

特定格式的模板只能应用于相同格式的页面。例如，Markdown 模板仅适用于 Markdown 页面。

<a id="apply-a-template"></a>

### 应用模板

当您 [创建](#create-a-new-wiki-page) 或 [编辑](#edit-a-wiki-page) Wiki 页面时，您可以应用模板。

先决条件：

- 您必须已经 [创建](#create-a-template) 了至少一个模板。

1. 在 **内容** 部分，选择 **选择模板** 下拉列表。
1. 从列表中选择一个模板。如果页面已有内容，将显示警告，指示现有内容将被覆盖。
1. 选择 **应用模板**。

<a id="restore-a-page-template-to-a-previous-version"></a>

### 将页面模板恢复到以前的版本

您可以将 Wiki 页面模板从其历史记录中恢复到任何以前的版本。这会创建一个包含已恢复内容的新版本，同时保留完整的版本历史记录。

先决条件：

- 您必须具有开发者、维护者或所有者角色。

要将 Wiki 页面模板恢复到以前的版本：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 选择 **Wiki 操作** ({{< icon name="ellipsis_v" >}})，然后选择 **模板**。
1. 选择一个模板。
1. 选择 **Wiki 操作** ({{< icon name="ellipsis_v" >}})，然后选择 **模板历史记录**。
1. 选择要恢复的版本。
1. 在右上角，选择 **恢复此版本**。
1. 在提交对话框中，添加 **提交消息** 以描述您恢复此版本的原因。
1. 选择 **恢复**。

页面模板将恢复到所选版本。所有以前的版本都保留在页面历史记录中。

您也可以使用相同的过程 [恢复 Wiki 页面](#restore-a-wiki-page-to-a-previous-version)。

<a id="wiki-page-subscriptions"></a>

## Wiki 页面订阅

Wiki 页面订阅功能允许您在您感兴趣的 Wiki 页面发生更改时接收通知。
此功能可以通过让团队成员了解重要文档的更新来增强协作。

您可以订阅特定的 Wiki 页面，以便在有人执行以下操作时接收通知：

- 向页面添加评论
- 回复评论

<a id="subscribe-to-a-wiki-page"></a>

### 订阅 Wiki 页面

1. 打开您要关注的 Wiki 页面。
1. 在右上角，**编辑** 旁边，选择铃铛图标 ({{< icon name="notifications" >}})。
1. 再次选择铃铛图标 ({{< icon name="notifications-off" >}}) 以取消订阅。

当您更改订阅状态时，极狐GitLab 会显示一条确认消息：

- 如果已订阅，`Notifications turned on`
- 如果已取消订阅，`Notifications turned off`

<a id="subscription-permissions"></a>

### 订阅权限

任何有权查看 Wiki 页面的用户都可以订阅它。您的订阅状态是个人的，不会影响其他用户。

<a id="notification-settings"></a>

### 通知设置

通知遵循您的项目通知设置。它们通过您配置的通知渠道进行投递。

<a id="view-history-of-a-wiki-page"></a>

## 查看 Wiki 页面的历史记录

Wiki 页面随时间推移的更改记录在 Wiki 的 Git 代码仓库中。历史记录页面显示：

- 页面的修订版本。
- 页面作者。
- 提交消息。
- 最后更新时间。
- 以前的修订版本，通过选择 **页面版本** 列中的修订版本号查看。

要查看 Wiki 页面的更改：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 转到要查看历史记录的页面。
1. 选择 **Wiki 操作** ({{< icon name="ellipsis_v" >}})，然后选择 **页面历史记录**。

<a id="view-changes-between-page-versions"></a>

### 查看页面版本之间的更改

您可以查看 Wiki 页面某个版本中所做的更改，类似于版本化差异文件视图：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 转到您感兴趣的 Wiki 页面。
1. 选择 **Wiki 操作** ({{< icon name="ellipsis_v" >}})，然后选择 **页面历史记录** 以查看所有页面版本。
1. 在 **差异** 列中，选择您感兴趣的版本的提交消息。

<a id="restore-a-wiki-page-to-a-previous-version"></a>

### 将 Wiki 页面恢复到以前的版本

您可以将 Wiki 页面从其历史记录中恢复到任何以前的版本。这会创建一个包含已恢复内容的新版本，同时保留完整的版本历史记录。

先决条件：

- 您必须具有开发者、维护者或所有者角色。

要将 Wiki 页面恢复到以前的版本：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 转到要恢复的页面。
1. 选择 **Wiki 操作** ({{< icon name="ellipsis_v" >}})，然后选择 **页面历史记录**。
1. 选择要恢复的版本。
1. 在右上角，选择 **恢复此版本**。
1. 在提交对话框中，添加 **提交消息** 以描述您恢复此版本的原因。
1. 选择 **恢复**。

页面将恢复到所选版本。所有以前的版本都保留在页面历史记录中。

您也可以使用相同的过程 [恢复 Wiki 页面模板](#restore-a-page-template-to-a-previous-version)。

<a id="sidebar"></a>

## 侧边栏

Wiki 页面显示一个侧边栏，其中包含 Wiki 中的页面列表，以嵌套树的形式显示，同级页面按字母顺序列出。

您可以使用侧边栏中的搜索框按标题在 Wiki 中查找页面。您可以使用位于页面左上角的侧边栏切换 ({{< icon name="sidebar" >}}) 来打开或关闭侧边栏。

出于性能原因，侧边栏限制为显示 5000 个条目。要查看所有页面的列表，请在侧边栏中选择 **查看所有页面**。

<a id="customize-sidebar"></a>

### 自定义侧边栏

您可以手动编辑侧边栏导航的内容。

先决条件：

- 您必须具有开发者、维护者或所有者角色。

此过程会创建一个名为 `_sidebar` 的 Wiki 页面，该页面完全替换默认的侧边栏导航：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **Wiki**。
1. 在页面的左上角，选择 **添加自定义侧边栏** ({{< icon name="settings" >}})。
1. 完成后，选择 **保存更改**。

一个 `_sidebar` 示例，使用 Markdown 格式化：

```markdown
### Home

- [Hello World](hello)
- [Foo](foo)
- [Bar](bar)

---

- [Sidebar](_sidebar)
```

<a id="enable-or-disable-a-project-wiki"></a>

## 启用或禁用项目 Wiki

Wiki 在极狐GitLab 中默认启用。项目 [管理员](../../permissions.md)
可以按照 [共享和权限](../settings/_index.md#configure-project-features-and-permissions) 中的说明启用或禁用项目 Wiki。

极狐GitLab 私有化部署的管理员可以
[配置其他 Wiki 设置](../../../administration/wikis/_index.md)。

您可以从 [群组设置](group.md#configure-group-wiki-visibility) 禁用群组 Wiki。

<a id="link-an-external-wiki"></a>

## 链接外部 Wiki

要从项目的左侧边栏添加外部 Wiki 的链接：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **外部 Wiki**。
1. 添加您的外部 Wiki 的 URL。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

您现在可以从项目的左侧边栏看到 **外部 Wiki** 选项。

当您启用此集成时，外部 Wiki 的链接不会替换内部 Wiki 的链接。要从侧边栏隐藏内部 Wiki，请 [禁用项目的 Wiki](#disable-the-projects-wiki)。

要隐藏外部 Wiki 的链接：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **外部 Wiki**。
1. 在 **启用集成** 下，清除 **活动** 复选框。
1. 选择 **保存更改**。

<a id="disable-the-projects-wiki"></a>

## 禁用项目的 Wiki

要禁用项目的内部 Wiki：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 向下滚动找到并关闭 **Wiki** 开关（灰色）。
1. 选择 **保存更改**。

内部 Wiki 现已禁用，用户和项目成员：

- 无法从项目侧边栏找到 Wiki 的链接。
- 无法添加、删除或编辑 Wiki 页面。
- 无法查看任何 Wiki 页面。

以前添加的 Wiki 页面会保留，以防您想重新启用 Wiki。要重新启用它，请重复禁用 Wiki 的过程，但将其切换为开启（蓝色）。

<a id="rich-text-editor"></a>

## 富文本编辑器

极狐GitLab 为 Wiki 中的极狐GitLab 风格 Markdown 提供了富文本编辑体验。

支持包括：

- 格式化文本，包括使用粗体、斜体、块引用、标题和内联代码。
- 格式化有序列表、无序列表和复选框列表。
- 创建和编辑表格结构。
- 插入和格式化带语法高亮的代码块。
- 预览 Mermaid、PlantUML 和 Kroki 图表。

<a id="use-the-rich-text-editor"></a>

### 使用富文本编辑器

1. [创建](#create-a-new-wiki-page) 新的 Wiki 页面，或 [编辑](#edit-a-wiki-page) 现有页面。
1. 选择 **Markdown** 作为您的格式。选择 **编辑页面选项**
   ({{< icon name="chevron-down" >}})，以在编辑器头部更改格式。
1. 在编辑器的标题中，选择 **切换到富文本编辑**。
1. 使用富文本编辑器中可用的各种格式选项自定义页面的内容。
1. 对于新页面选择 **创建页面**，对于现有页面选择 **保存更改**。

要切换回纯文本，请选择 **切换到纯文本编辑**。

另请参阅：

- [富文本编辑器](../../rich_text_editor.md)

<a id="gitlab-flavored-markdown-support"></a>

### 极狐GitLab 风格 Markdown 支持

在富文本编辑器中支持所有极狐GitLab 风格 Markdown 内容类型是一项正在进行的工作。有关 CommonMark 和极狐GitLab 风格 Markdown 支持的持续开发状态，请阅读：

- [基本 Markdown 格式扩展](https://gitlab.com/groups/gitlab-org/-/epics/5404) 史诗。
- [极狐GitLab 风格 Markdown 扩展](https://gitlab.com/groups/gitlab-org/-/epics/5438) 史诗。

<a id="track-wiki-events"></a>

## 跟踪 Wiki 事件

极狐GitLab 会跟踪 Wiki 的创建、删除和更新事件。这些事件显示在以下页面上：

- [用户资料](../../profile/_index.md#access-your-user-profile)。
- 活动页面，具体取决于 Wiki 的类型：
  - [群组活动](../../group/manage.md#view-group-activity)。
  - [项目活动](../working_with_projects.md#view-project-activity)。

对 Wiki 的提交不计入 [代码仓库分析](../../analytics/repository_analytics.md)。

<a id="troubleshooting"></a>

## 故障排查

<a id="page-slug-rendering-with-apache-reverse-proxy"></a>

### 使用 Apache 反向代理的页面别名渲染

页面别名使用
[`ERB::Util.url_encode`](https://www.rubydoc.info/stdlib/erb/ERB%2FUtil.url_encode) 方法进行编码。
如果您使用 Apache 反向代理，您可以在 Apache 配置的 `ProxyPass` 行中添加 `nocanon` 参数，以确保您的页面别名正确渲染。

<a id="recreate-a-project-wiki-with-the-rails-console"></a>

### 使用 Rails 控制台重新创建项目 Wiki

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 此操作会删除 Wiki 中的所有数据。
>
> 任何直接更改数据的命令，如果未正确运行，或未在正确的条件下运行，都可能造成损害。强烈建议在测试环境中运行，并准备好实例的备份以便恢复，以防万一。

要清除项目 Wiki 中的所有数据并以空白状态重新创建：

1. 启动 [Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下命令：

   ```ruby
   # Enter your project's path
   p = Project.find_by_full_path('<username-or-group>/<project-name>')

   # This command deletes the wiki project from the filesystem.
   p.wiki.repository.remove

   # Refresh the wiki repository state.
   p.wiki.repository.expire_exists_cache
   ```

Wiki 中的所有数据已被清除，Wiki 已准备好使用。
