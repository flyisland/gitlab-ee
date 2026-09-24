---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Wiki 特定的 Markdown
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="links"></a>

## 链接

以下主题展示了 wiki 内部链接的行为。

链接到 wiki 页面时，请使用页面 slug 而非页面名称。
页面 slug 是页面标题的 URL 友好版本，其中空格替换为连字符，特殊字符被删除或转换。
例如，标题为 “How to Use GitLab” 的页面，其 slug 为 `How-to-Use-GitLab`。

<a id="wiki-style-links"></a>

### Wiki 风格的链接

除了标准的 [Markdown 链接](../../markdown.md#links) 外，wiki 还支持特殊的 wiki 风格链接语法，提供了在 wiki 页面之间链接的更便捷方式。

<a id="double-bracket-syntax"></a>

#### 双括号语法

你可以使用双括号链接到 wiki 页面：

```markdown
[[Home]]
```

此语法创建一个指向 slug 为 `Home` 的 wiki 页面的链接。
如果页面不存在，当你选择该链接时，即可创建此页面。

当页面 slug 包含连字符时，链接将按原样显示 slug：

```markdown
[[Home-page-new-slug]]
```

这将显示 `Home-page-new-slug` 作为链接文本。

<a id="double-bracket-syntax-with-custom-text"></a>

#### 带自定义文本的双括号语法

如果页面 slug 与你要显示的标题不同，请使用竖线 (`|`) 字符将显示文本与页面 slug 分开：

```markdown
[[How to use GitLab|how-to-use-gitlab]]
```

这将显示 “How to use GitLab” 作为链接文本，但链接到 slug 为 `how-to-use-gitlab` 的页面。

你还可以使用此语法为带有连字符 slug 的页面提供更易读的标题：

```markdown
[[Home page (renamed)|Home-page-new-slug]]
```

这将显示 “Home page (renamed)” 作为链接文本，但链接到 slug 为 `Home-page-new-slug` 的页面。

<a id="alternative-wiki-page-syntax"></a>

#### 备选 Wiki 页面语法

你还可以使用 `[wiki_page:PAGE_SLUG]` 语法：

```markdown
[wiki_page:Home]
```

对于跨项目引用，指定完整的项目路径：

```markdown
[wiki_page:namespace/project:Home]
[wiki_page:group1/subgroup:Home]
```

<a id="automatic-url-recognition"></a>

#### 自动 URL 识别

当你粘贴一个没有任何 Markdown 格式的 wiki 页面完整 URL 时，极狐GitLab 会自动将其转换为链接，并显示将连字符替换为空格的页面 slug：

```markdown
https://jihulab.com/namespace/project/-/wikis/Home-page-new-slug
```

这将自动渲染为一个链接，文本为 “Home page new slug”（连字符被转换为空格）。

<a id="direct-page-link"></a>

### 直接页面链接

直接页面链接包含指向 wiki 基础级别中该页面的 slug。

此示例链接到你的 wiki 根目录下的 `documentation` 页面：

```markdown
[链接到文档](documentation-top-page)
```

<a id="direct-file-link"></a>

### 直接文件链接

直接文件链接指向相对于当前页面的文件扩展名的文件。

如果以下示例位于 `<your_wiki>/documentation/related` 页面，它将链接到 `<your_wiki>/documentation/file.md`：

```markdown
[链接到文件](file.md)
```

<a id="hierarchical-link"></a>

### 层级链接

可以使用相对路径（如 `./<page>` 或 `../<page>`）相对于当前 wiki 页面构建层级链接。

如果此示例位于 `<your_wiki>/documentation/main` 页面，它将链接到 `<your_wiki>/documentation/related`：

```markdown
[链接到相关页面](related)
```

如果此示例位于 `<your_wiki>/documentation/related/content` 页面，它将链接到 `<your_wiki>/documentation/main`：

```markdown
[链接到相关页面](../main)
```

如果此示例位于 `<your_wiki>/documentation/main` 页面，它将链接到 `<your_wiki>/documentation/related.md`：

```markdown
[链接到相关页面](related.md)
```

如果此示例位于 `<your_wiki>/documentation/related/content` 页面，它将链接到 `<your_wiki>/documentation/main.md`：

```markdown
[链接到相关页面](../main.md)
```

<a id="root-link"></a>

### 根链接

根链接以 `/` 开头，并相对于 wiki 根目录。

此示例链接到 `<wiki_root>/documentation`：

```markdown
[链接到相关页面](/documentation)
```

此示例链接到 `<wiki_root>/documentation.md`：

```markdown
[链接到相关页面](/documentation.md)
```

<a id="diagrams.net-editor"></a>

## diagrams.net 编辑器

在 wiki 中，你可以使用 [diagrams.net](https://app.diagrams.net/) 编辑器创建图表。你还可以编辑使用 diagrams.net 编辑器创建的图表。该图表编辑器在纯文本编辑器和富文本编辑器中均可用。

更多信息，请参见 [Diagrams.net](../../../administration/integration/diagrams_net.md)。

<a id="plain-text-editor"></a>

### 纯文本编辑器

要在纯文本编辑器中创建图表：

1. 在要编辑的 wiki 页面上，选择 **编辑**。
1. 在文本框中，确保你正在使用纯文本编辑器
   （左下角的按钮显示为 **切换到富文本编辑**）。
1. 在编辑器的工具栏中，选择 **插入或编辑图表** ({{< icon name="diagram" >}})。
1. 在 [app.diagrams.net](https://app.diagrams.net/) 编辑器中创建图表。
1. 选择 **保存并退出**。

图表的 Markdown 图片引用将被插入到 wiki 内容中。

要在纯文本编辑器中编辑图表：

1. 在要编辑的 wiki 页面上，选择 **编辑**。
1. 在文本框中，确保你正在使用纯文本编辑器
   （左下角的按钮显示为 **切换到富文本编辑**）。
1. 将光标放在包含图表的 Markdown 图片引用中。
1. 选择 **插入或编辑图表** ({{< icon name="diagram" >}})。
1. 在 [app.diagrams.net](https://app.diagrams.net/) 编辑器中编辑图表。
1. 选择 **保存并退出**。

图表的 Markdown 图片引用将被插入到 wiki 内容中，替换之前的图表。

<a id="rich-text-editor"></a>

### 富文本编辑器

要在富文本编辑器中创建图表：

1. 在要编辑的 wiki 页面上，选择 **编辑**。
1. 在文本框中，确保你正在使用富文本编辑器
   （左下角的按钮显示为 **切换到纯文本编辑**）。
1. 在编辑器的工具栏中，选择 **更多选项** ({{< icon name="plus" >}})。
1. 在下拉列表中，选择 **创建或编辑图表**。
1. 在 [app.diagrams.net](https://app.diagrams.net/) 编辑器中创建图表。
1. 选择 **保存并退出**。

在 diagrams.net 编辑器中可视化的图表将被插入到 wiki 内容中。

要在富文本编辑器中编辑图表：

1. 在要编辑的 wiki 页面上，选择 **编辑**。
1. 在文本框中，确保你正在使用富文本编辑器
   （左下角的按钮显示为 **切换到纯文本编辑**）。
1. 选择你要编辑的图表。
1. 在浮动工具栏中，选择 **编辑图表** ({{< icon name="diagram" >}})。
1. 在 [app.diagrams.net](https://app.diagrams.net/) 编辑器中编辑图表。
1. 选择 **保存并退出**。

选定的图表将被更新版本替换。