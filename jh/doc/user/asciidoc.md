---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在极狐GitLab 项目中使用 AsciiDoc 文件，并了解 AsciiDoc 语法。
title: AsciiDoc
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 使用 [Asciidoctor](https://asciidoctor.org) gem 将 AsciiDoc 内容转换为 HTML5。
完整参考请参见 [Asciidoctor 用户手册](https://asciidoctor.org/docs/user-manual/)。

您可以在以下区域使用 AsciiDoc：

- Wiki 页面
- 代码仓库中的 AsciiDoc 文档（`.adoc` 或 `.asciidoc`）

<a id="paragraphs"></a>

## 段落

```plaintext
A normal paragraph.
Line breaks are not preserved.
```

以 `//` 开头的行注释会被跳过：

```plaintext
// this is a comment
```

空行用于分隔段落。

带有 `[%hardbreaks]` 选项的段落会保留换行：

```plaintext
[%hardbreaks]
This paragraph carries the `hardbreaks` option.
Notice how line breaks are now preserved.
```

缩进（字面）段落会禁用文本格式，保留空格和换行，并以等宽字体显示：

```plaintext
 This literal paragraph is indented with one space.
 As a consequence, *text formatting*, spaces,
 and lines breaks will be preserved.
```

警告段落用于吸引读者的注意：

- `NOTE: This is a brief reference, read the full documentation at https://asciidoctor.org/docs/.`
- `TIP: Lists can be indented. Leading whitespace is not significant.`

<a id="text-formatting"></a>

## 文本格式

- 受约束（应用于词边界）：

  ```plaintext
  *strong importance* (aka bold)
  _stress emphasis_ (aka italic)
  `monospaced` (aka typewriter text)
  "`double`" and '`single`' typographic quotes
  +passthrough text+ (substitutions disabled)
  `+literal text+` (monospaced with substitutions disabled)
  ```

- 不受约束（可应用于任意位置）：

  ```plaintext
  **C**reate+**R**ead+**U**pdate+**D**elete
  fan__freakin__tastic
  ``mono``culture
  ```

- 替换：

  ```plaintext
  A long time ago in a galaxy far, far away...
  (C) 1976 Arty Artisan
  I believe I shall--no, actually I won't.
  ```

- 宏：

  ```plaintext
  // where c=specialchars, q=quotes, a=attributes, r=replacements, m=macros, p=post_replacements
  The European icon:flag[role=blue] is blue & contains pass:[************] arranged in a icon:circle-o[role=yellow].
  The pass:c[->] operator is often referred to as the stabby lambda.
  Since `pass:[++]` has strong priority in AsciiDoc, you can rewrite pass:c,a,r[C++ => C{pp}].
  // activate stem support by adding `:stem:` to the document header
  stem:[sqrt(4) = 2]
  ```

<a id="links"></a>

## 链接

```plaintext
https://example.org/page[A webpage]
link:../path/to/file.txt[A local file]
xref:document.adoc[A sibling document]
mailto:hello@example.org[Email to say hello!]
```

<a id="anchors"></a>

## 锚点

```plaintext
[[idname,reference text]]
// or written using normal block attributes as `[#idname,reftext=reference text]`
A paragraph (or any block) with an anchor (aka ID) and reftext.

See <<idname>> or <<idname,optional text of internal link>>.

xref:document.adoc#idname[Jumps to anchor in another document].

This paragraph has a footnote.footnote:[This is the text of the footnote.]
```

<a id="lists"></a>

## 列表

<a id="unordered"></a>

### 无序列表

```plaintext
* level 1
** level 2
*** level 3
**** level 4
***** level 5
* back at level 1
+
Attach a block or paragraph to a list item using a list continuation (which you can enclose in an open block).

.Some Authors
[circle]
- Edgar Allen Poe
- Sheri S. Tepper
- Bill Bryson
```

<a id="ordered"></a>

### 有序列表

```plaintext
. Step 1
. Step 2
.. Step 2a
.. Step 2b
. Step 3

.Remember your Roman numerals?
[upperroman]
. is one
. is two
. is three
```

<a id="checklist"></a>

### 检查清单

```plaintext
* [x] checked
* [ ] not checked
```

<a id="callout"></a>

### 标注

```plaintext
// enable callout bubbles by adding `:icons: font` to the document header
[,ruby]
----
puts 'Hello, World!' # <1>
----
<1> Prints `Hello, World!` to the console.
```

<a id="description"></a>

### 描述

```plaintext
first term:: description of first term
second term::
description of second term
```

<a id="headers"></a>

## 文档头部

```plaintext
= Document Title
Author Name <author@example.org>
v1.0, 2019-01-01
```

<a id="sections"></a>

## 章节

```plaintext
= Document Title (Level 0)
== Level 1
=== Level 2
==== Level 3
===== Level 4
====== Level 5
== Back at Level 1
```

<a id="includes"></a>

## 包含

> [!note]
> 使用 AsciiDoc 格式创建的 [Wiki 页面](project/wiki/_index.md#create-a-new-wiki-page)
> 会以 `.asciidoc` 文件扩展名保存。处理 AsciiDoc Wiki
> 页面时，请将文件名从 `.adoc` 改为 `.asciidoc`。

```plaintext
include::basics.adoc[]
```

```plaintext
// you can also include other files from you repository
[,language]
----
include::my_code_file.language[]
----
```

为保证良好的系统性能并防止恶意文档引发问题，极狐GitLab 对单个文档中处理的 include 指令数量实施最大限制。默认情况下，一个文档最多可包含 32 个 include 指令，其中包含传递依赖。要自定义处理的 include 指令数量，请通过[应用设置 API](../api/settings.md#available-settings) 更改应用设置 `asciidoc_max_includes`。

> [!note]
> `asciidoc_max_includes` 当前允许的最大值为 64。如果该值
> 过高，在某些情况下可能会导致性能问题。

要使用来自单独页面或外部 URL 的 include，请在[应用设置](../administration/wikis/_index.md#allow-uri-includes-for-asciidoc)中启用 `allow-uri-read`。

```plaintext
// define application setting allow-uri-read to true to allow content to be read from URI
include::https://example.org/installation.adoc[]
```

<a id="attributes"></a>

## 属性

<a id="user-defined"></a>

### 用户定义

```plaintext
// define attributes in the document header
:name: value
```

```plaintext
:url-gem: https://rubygems.org/gems/asciidoctor

You can download and install Asciidoctor {asciidoctor-version} from {url-gem}.
C{pp} is not required, only Ruby.
Use a leading backslash to output a word enclosed in curly braces, like \{name}.
```

<a id="environment"></a>

### 环境

极狐GitLab 会设置以下环境属性：

| 属性       | 描述                                                                                                            |
| :-------------- | :--------------------------------------------------------------------------------------------------------------------- |
| `docname`       | 源文档的根名称（不含前导路径或文件扩展名）。                                                  |
| `outfilesuffix` | 与后端输出对应的文件扩展名（默认为 `.adoc`，以便文档间的交叉引用正常工作）。 |

<a id="blocks"></a>

## 块

```plaintext
--
open - a general-purpose content wrapper; useful for enclosing content to attach to a list item
--
```

```plaintext
// recognized types include CAUTION, IMPORTANT, NOTE, TIP, and WARNING
// enable admonition icons by setting `:icons: font` in the document header
[NOTE]
====
admonition - a notice for the reader, ranging in severity from a tip to an alert
====
```

```plaintext
====
example - a demonstration of the concept being documented
====
```

```plaintext
.Toggle Me
[%collapsible]
====
collapsible - these details are revealed by clicking the title
====
```

```plaintext
****
sidebar - auxiliary content that can be read independently of the main content
****
```

```plaintext
....
literal - an exhibit that features program output
....
```

```plaintext
----
listing - an exhibit that features program input, source code, or the contents of a file
----
```

```plaintext
[,language]
----
source - a listing that is embellished with (colorized) syntax highlighting
----
```

````plaintext
\```language
fenced code - a shorthand syntax for the source block
\```
````

```plaintext
[,attribution,citetitle]
____
quote - a quotation or excerpt; attribution with title of source are optional
____
```

```plaintext
[verse,attribution,citetitle]
____
verse - a literary excerpt, often a poem; attribution with title of source are optional
____
```

```plaintext
++++
pass - content passed directly to the output document; often raw HTML
++++
```

```plaintext
// activate stem support by adding `:stem:` to the document header
[stem]
++++
x = y^2
++++
```

```plaintext
////
comment - content which is not included in the output document
////
```

<a id="tables"></a>

## 表格

```plaintext
.Table Attributes
[cols=>1h;2d,width=50%,frame=topbot]
|===
| Attribute Name | Values

| options
| header,footer,autowidth

| cols
| colspec[;colspec;...]

| grid
| all \| cols \| rows \| none

| frame
| all \| sides \| topbot \| none

| stripes
| all \| even \| odd \| none

| width
| (0%..100%)

| format
| psv {vbar} csv {vbar} dsv
|===
```

<a id="colors"></a>

## 颜色

可以以 `HEX`、`RGB` 或 `HSL` 格式书写颜色，并渲染出颜色指示符。支持的格式（不支持命名颜色）：

- `HEX`：`` `#RGB[A]` `` 或 `` `#RRGGBB[AA]` ``
- `RGB`：`` `RGB[A](R, G, B[, A])` ``
- `HSL`：`` `HSL[A](H, S, L[, A])` ``

写在反引号内的颜色后面会跟一个颜色“色块”：

```plaintext
- `#F00`
- `#F00A`
- `#FF0000`
- `#FF0000AA`
- `RGB(0,255,0)`
- `RGB(0%,100%,0%)`
- `RGBA(0,255,0,0.3)`
- `HSL(540,70%,50%)`
- `HSLA(540,70%,50%,0.3)`
```

<a id="equations-and-formulas"></a>

## 方程和公式

如果您需要包含科学、技术、工程和数学（STEM）表达式，请在文档头部将 `stem` 属性设置为 `latexmath`。方程和公式使用 [KaTeX](https://katex.org/) 渲染：

```plaintext
:stem: latexmath

latexmath:[C = \alpha + \beta Y^{\gamma} + \epsilon]

[stem]
++++
sqrt(4) = 2
++++

A matrix can be written as stem:[[[a,b\],[c,d\]\]((n),(k))].
```

<a id="diagrams-and-flowcharts"></a>

## 图表和流程图

在极狐GitLab 中，可以使用
[Mermaid](https://mermaidjs.github.io/) 或 [PlantUML](https://plantuml.com) 从文本生成图表和流程图。

<a id="mermaid"></a>

### Mermaid

更多详情请访问[官方页面](https://mermaidjs.github.io/)。如果您是初次使用 Mermaid，或需要帮助识别 Mermaid 代码中的问题，
[Mermaid Live Editor](https://mermaid-js.github.io/mermaid-live-editor/) 是一个有用的工具，
可用于创建 Mermaid 图表并解决其中的问题。

要生成图表或流程图，请在 `mermaid` 块中输入文本：

```plaintext
[mermaid]
----
graph LR
    A[Square Rect] -- Link text --> B((Circle))
    A --> C(Round Rect)
    B --> D{Rhombus}
    C --> D
----
```

<a id="kroki"></a>

### Kroki

Kroki 支持十多种图表库。要在极狐GitLab 中使用 Kroki，极狐GitLab 管理员需要先启用它。更多信息请阅读 [Kroki 集成](../administration/integration/kroki.md)页面。

启用 Kroki 后，您可以在 AsciiDoc 和 Markdown 文档中创建图表。
以下是一个使用 GraphViz 图表的示例：

- AsciiDoc：

  ```plaintext
  [graphviz]
  ....
  digraph G {
    Hello->World
  }
  ....
  ```

- Markdown：

  ````markdown
  ```graphviz
  digraph G {
    Hello->World
  }
  ```
  ````

<a id="plantuml"></a>

### PlantUML

PlantUML 集成已在 JihuLab.com 上启用。要在极狐GitLab 私有化部署实例中使用 PlantUML，极狐GitLab 管理员[必须启用它](../administration/integration/plantuml.md)。

启用 PlantUML 后，请在 `plantuml` 块中输入文本：

```plaintext
[plantuml]
----
Bob -> Alice : hello
----
```

要包含存储在单独文件中的 PlantUML 图表：

```plaintext
[plantuml, format="png", id="myDiagram", width="200px"]
----
include::diagram.puml[]
----
```

<a id="multimedia"></a>

## 多媒体

```plaintext
image::screenshot.png[block image,800,450]

Press image:reload.svg[reload,16,opts=interactive] to reload the page.

video::movie.mp4[width=640,start=60,end=140,options=autoplay]
```

如需链接视频等资源，请使用标准 AsciiDoc 链接：

```plaintext
https://www.youtube.com/watch?v=BlaZ65-b7y0[Link text for the video]
```

<a id="breaks"></a>

## 分隔符

```plaintext
// thematic break (aka horizontal rule)
---
```

```plaintext
// page break
<<<
```

<a id="table-of-contents"></a>

## 目录

```plaintext
= Document Title (Level 0)
:toc:
:toclevels: 3
:toc-title: Contents

== Level 1
=== Level 2
==== Level 3
===== Level 4
====== Level 5
== Back at Level 1
```

不支持 `:toc-class:`、`:toc: left` 和 `:toc: right` 属性。
