---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Wiki 专用 Markdown
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="links"></a>

## 链接

以下主题介绍 Wiki 内链接的行为。

链接到 Wiki 页面时，请使用页面 slug，而不是页面名称。页面 slug 是页面标题的 URL 友好版本，其中空格替换为连字符，特殊字符被移除或转换。
例如，标题为“How to Use GitLab”的页面，其 slug 为 `How-to-Use-GitLab`。

<a id="wiki-style-links"></a>

### Wiki 式链接

除了标准 [Markdown 链接](../../markdown.md#links)之外，Wiki 还支持特殊的 Wiki 式
链接语法，可简化 Wiki 页面之间的链接。

<a id="double-bracket-syntax"></a>

#### 双方括号语法

您可以使用双方括号链接到 Wiki 页面：

```markdown
[[Home]]
```

此语法会创建一个指向 slug 为 `Home`的 Wiki 页面的链接。如果该页面不存在，当您选择该链接时，可以创建此页面。

当页面 slug 包含连字符时，链接会按原样显示该 slug：

```markdown
[[Home-page-new-slug]]
```

这会显示 `Home-page-new-slug` 作为链接文本。

<a id="double-bracket-syntax-with-custom-text"></a>

#### 带自定义文本的双方括号语法

如果页面 slug 与您想要显示的标题不同，请使用竖线（`|`）字符将显示文本与页面 slug 分隔开：

```markdown
[[How to use GitLab|how-to-use-gitlab]]
```

这会显示“How to use GitLab”作为链接文本，但链接到 slug 为 `how-to-use-gitlab`的页面。

您也可以使用此语法为带连字符 slug 的页面提供更易读的标题：

```markdown
[[Home page (renamed)|Home-page-new-slug]]
```

这会显示“Home page (renamed)”作为链接文本，但链接到 slug 为 `Home-page-new-slug`的页面。

<a id="alternative-wiki-page-syntax"></a>

#### 替代 Wiki 页面语法

您也可以使用 `[wiki_page:PAGE_SLUG]` 语法：

```markdown
[wiki_page:Home]
```

对于跨项目引用，请指定完整的项目路径：

```markdown
[wiki_page:namespace/project:Home]
[wiki_page:group1/subgroup:Home]
```

<a id="automatic-url-recognition"></a>

#### 自动识别 URL

当您粘贴 Wiki 页面的完整 URL 且未使用任何 Markdown 格式时，极狐GitLab 会自动将其转换为链接，并显示页面 slug，其中连字符替换为空格：

```markdown
https://gitlab.com/namespace/project/-/wikis/Home-page-new-slug
```

这会自动渲染为文本为“Home page new slug”的链接（连字符转换为空格）。

<a id="direct-page-link"></a>

### 直接页面链接

直接页面链接包含指向该页面的页面 slug，位于 Wiki 的基础层级。

此示例链接到 Wiki 根目录下的 `documentation` 页面：

```markdown
[Link to Documentation](documentation-top-page)
```

<a id="direct-file-link"></a>

### 直接文件链接

直接文件链接指向某个文件的文件扩展名，相对于当前页面。

如果以下示例位于 `<your_wiki>/documentation/related` 页面，它会链接到 `<your_wiki>/documentation/file.md`：

```markdown
[Link to File](file.md)
```

<a id="hierarchical-link"></a>

### 层级链接

层级链接可以通过使用 `./<page>` 或 `../<page>` 等相对路径，相对于当前 Wiki 页面构建。

如果此示例位于 `<your_wiki>/documentation/main` 页面，它会链接到 `<your_wiki>/documentation/related`：

```markdown
[Link to Related Page](related)
```

如果此示例位于 `<your_wiki>/documentation/related/content` 页面，它会链接到 `<your_wiki>/documentation/main`：

```markdown
[Link to Related Page](../main)
```

如果此示例位于 `<your_wiki>/documentation/main` 页面，它会链接到 `<your_wiki>/documentation/related.md`：

```markdown
[Link to Related Page](related.md)
```

如果此示例位于 `<your_wiki>/documentation/related/content` 页面，它会链接到 `<your_wiki>/documentation/main.md`：

```markdown
[Link to Related Page](../main.md)
```

<a id="root-link"></a>

### 根链接

根链接以 `/` 开头，相对于 Wiki 根目录。

此示例链接到 `<wiki_root>/documentation`：

```markdown
[Link to Related Page](/documentation)
```

此示例链接到 `<wiki_root>/documentation.md`：

```markdown
[Link to Related Page](/documentation.md)
```

<a id="diagramsnet-editor"></a>

## diagrams.net 编辑器

在 Wiki 中，您可以使用 [diagrams.net](https://app.diagrams.net/) 编辑器创建图表。您也可以编辑使用 diagrams.net 编辑器创建的图表。该图表编辑器在纯文本编辑器和富文本编辑器中均可用。

更多信息，请参见 [Diagrams.net](../../../administration/integration/diagrams_net.md)。

<a id="plain-text-editor"></a>

### 纯文本编辑器

要在纯文本编辑器中创建图表：

1. 在您想要编辑的 Wiki 页面上，选择**编辑**。
1. 在文本框中，确保您使用的是纯文本编辑器
   （左下角的按钮显示为**切换到富文本编辑**）。
1. 在编辑器的工具栏中，选择**插入或编辑图表**（{{< icon name="diagram" >}}）。
1. 在 [app.diagrams.net](https://app.diagrams.net/) 编辑器中创建图表。
1. 选择**保存并退出**。

图表对应的 Markdown 图片引用会插入到 Wiki 内容中。

要在纯文本编辑器中编辑图表：

1. 在您想要编辑的 Wiki 页面上，选择**编辑**。
1. 在文本框中，确保您使用的是纯文本编辑器
   （左下角的按钮显示为**切换到富文本编辑**）。
1. 将光标定位在包含该图表的 Markdown 图片引用中。
1. 选择**插入或编辑图表**（{{< icon name="diagram" >}}）。
1. 在 [app.diagrams.net](https://app.diagrams.net/) 编辑器中编辑图表。
1. 选择**保存并退出**。

图表对应的 Markdown 图片引用会插入到 Wiki 内容中，替换之前的图表。

<a id="rich-text-editor"></a>

### 富文本编辑器

要在富文本编辑器中创建图表：

1. 在您想要编辑的 Wiki 页面上，选择**编辑**。
1. 在文本框中，确保您使用的是富文本编辑器
   （左下角的按钮显示为**切换到纯文本编辑**）。
1. 在编辑器的工具栏中，选择**更多选项**（{{< icon name="plus" >}}）。
1. 在下拉列表中，选择**创建或编辑图表**。
1. 在 [app.diagrams.net](https://app.diagrams.net/) 编辑器中创建图表。
1. 选择**保存并退出**。

图表在 diagrams.net 编辑器中呈现的效果会插入到 Wiki 内容中。

要在富文本编辑器中编辑图表：

1. 在您想要编辑的 Wiki 页面上，选择**编辑**。
1. 在文本框中，确保您使用的是富文本编辑器
   （左下角的按钮显示为**切换到纯文本编辑**）。
1. 选择您想要编辑的图表。
1. 在浮动工具栏中，选择**编辑图表**（{{< icon name="diagram" >}}）。
1. 在 [app.diagrams.net](https://app.diagrams.net/) 编辑器中编辑图表。
1. 选择**保存并退出**。

所选图表会被更新后的版本替换。
