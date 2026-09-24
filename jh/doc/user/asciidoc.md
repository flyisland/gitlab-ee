---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use AsciiDoc files in your GitLab project, and understand AsciiDoc syntax.
title: AsciiDoc
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 使用 [Asciidoctor](https://asciidoctor.org) gem 将 AsciiDoc 内容转换为 HTML5。
完整参考，请参见 [Asciidoctor 用户手册](https://asciidoctor.org/docs/user-manual/)。

你可以在以下区域使用 AsciiDoc：

- Wiki 页面
- 仓库中的 AsciiDoc 文档（`.adoc` 或 `.asciidoc`）

<a id="paragraphs"></a>

## 段落

```plaintext
一个普通段落。
换行不会被保留。
```

以 `//` 开头的行注释将被跳过：

```plaintext
// 这是一条注释
```

一个空行分隔段落。

带有 `[%hardbreaks]` 选项的段落会保留换行：

```plaintext
[%hardbreaks]
这一段使用了 `hardbreaks` 选项。
注意现在换行被保留了。
```

缩进的（字面）段落会禁用文本格式，
保留空格和换行，并以等宽字体显示：

```plaintext
 这段字面段落缩进了一个空格。
 因此，*文本格式*、空格和换行都将被保留。
```

警告段落会引起读者的注意：

- `NOTE: 这是一个简短引用，完整文档请参阅 https://asciidoctor.org/docs/.`
- `TIP: 列表可以缩进。前导空格不重要。`

<a id="text-formatting"></a>

## 文本格式

- 约束型（应用于词边界）：

  ```plaintext
  *强调*（即粗体）
  _着重_（即斜体）
  `等宽字体`（即打字机文本）
  "`双引号`" 和 '`单引号`' 排印引号
  +直通文本+（禁用替换）
  `+字面文本+`（等宽且禁用替换）
  ```

- 无约束型（可应用于任何位置）：

  ```plaintext
  **C**reate+**R**ead+**U**pdate+**D**elete
  fan__freakin__tastic
  ``mono``culture
  ```

- 替换：

  ```plaintext
  很久以前，在一个遥远的星系里……
  (C) 1976 Arty Artisan
  我相信我会——不，实际上我不会。
  ```

- 宏：

  ```plaintext
  // 其中 c=特殊字符，q=引号，a=属性，r=替换，m=宏，p=后替换
  欧洲图标 icon:flag[role=blue] 是蓝色的 & 包含 pass:[************] 排列成 icon:circle-o[role=yellow]。
  pass:c[->] 运算符通常被称为 stabby lambda。
  因为 `pass:[++]` 在 AsciiDoc 中有很高的优先级，你可以重写 pass:c,a,r[C++ => C{pp}]。
  // 通过在文档头部添加 `:stem:` 来激活 stem 支持
  stem:[sqrt(4) = 2]
  ```

<a id="links"></a>

## 链接

```plaintext
https://example.org/page[一个网页]
link:../path/to/file.txt[一个本地文件]
xref:document.adoc[一个同级文档]
mailto:hello@example.org[发送邮件打招呼！]
```

<a id="anchors"></a>

## 锚点

```plaintext
[[idname,reference text]]
// 或使用普通块属性 `[#idname,reftext=reference text]` 书写
一个带有锚点（即 ID）和引用文本的段落（或任何块）。

请参见 <<idname>> 或 <<idname,内部链接的可选文本>>。

xref:document.adoc#idname[跳转到另一个文档中的锚点]。

这段有一个脚注。footnote:[这是脚注的文本。]
```

<a id="lists"></a>

## 列表

<a id="unordered"></a>

### 无序列表

```plaintext
* 第一级
** 第二级
*** 第三级
**** 第四级
***** 第五级
* 回到第一级
+
使用列表续行（可将其包含在开放块中）将一个块或段落附加到列表项。

.一些作者
[circle]
- Edgar Allen Poe
- Sheri S. Tepper
- Bill Bryson
```

<a id="ordered"></a>

### 有序列表

```plaintext
. 步骤 1
. 步骤 2
.. 步骤 2a
.. 步骤 2b
. 步骤 3

.还记得你的罗马数字吗？
[upperroman]
. 是一
. 是二
. 是三
```

<a id="checklist"></a>

### 检查清单

```plaintext
* [x] 已勾选
* [ ] 未勾选
```

<a id="callout"></a>

### 标注

```plaintext
// 通过在文档头部添加 `:icons: font` 来启用标注气泡
[,ruby]
----
puts 'Hello, World!' # <1>
----
<1> 向控制台打印 `Hello, World!`。
```

<a id="description"></a>

### 描述列表

```plaintext
第一个术语:: 第一个术语的描述
第二个术语::
第二个术语的描述
```

<a id="headers"></a>

## 文档头部

```plaintext
= 文档标题
作者姓名 <author@example.org>
v1.0, 2019-01-01
```

<a id="sections"></a>

## 章节

```plaintext
= 文档标题 (层级 0)
== 层级 1
=== 层级 2
==== 层级 3
===== 层级 4
====== 层级 5
== 回到层级 1
```

<a id="includes"></a>

## 包含

> [!note]
> 使用 AsciiDoc 格式创建的 [Wiki 页面](project/wiki/_index.md#create-a-new-wiki-page) 会以文件扩展名 `.asciidoc` 保存。在处理 AsciiDoc wiki 页面时，请将文件名从 `.adoc` 改为 `.asciidoc`。

```plaintext
include::basics.adoc[]
```

```plaintext
// 你还可以从你的仓库中包含其他文件
[,language]
----
include::my_code_file.language[]
----
```

为了保证良好的系统性能并防止恶意文档引发问题，极狐GitLab 对任何单个文档中处理的包含指令数量施加了最大限制。默认情况下，一个文档最多可以有 32 个包含指令，这包括传递依赖。要自定义处理的包含指令数量，请使用 [应用程序设置 API](../api/settings.md#available-settings) 修改应用程序设置 `asciidoc_max_includes`。

> [!note]
> `asciidoc_max_includes` 当前允许的最大值是 64。如果该值过高，在某些情况下可能会导致性能问题。

要使用来自单独页面或外部 URL 的包含，请在 [应用程序设置](../administration/wikis/_index.md#allow-uri-includes-for-asciidoc) 中启用 `allow-uri-read`。

```plaintext
// 将应用程序设置 allow-uri-read 定义为 true，以允许从 URI 读取内容
include::https://example.org/installation.adoc[]
```

<a id="attributes"></a>

## 属性

<a id="user-defined"></a>

### 用户自定义

```plaintext
// 在文档头部定义属性
:name: value
```

```plaintext
:url-gem: https://rubygems.org/gems/asciidoctor

你可以从 {url-gem} 下载并安装 Asciidoctor {asciidoctor-version}。
不需要 C{pp}，只需要 Ruby。
在花括号中的单词前加反斜杠即可原样输出，如 \{name}。
```

<a id="environment"></a>

### 环境

极狐GitLab 设置以下环境属性：

| 属性 | 描述 |
| :--- | :--- |
| `docname` | 源文档的根名称（无前导路径或文件扩展名）。 |
| `outfilesuffix` | 与后端输出对应的文件扩展名（默认为 `.adoc` 以确保文档间交叉引用工作）。 |

<a id="blocks"></a>

## 块

```plaintext
--
开放块 - 通用内容包装器；用于封装要附加到列表项的内容
--
```

```plaintext
// 公认的类型包括 CAUTION、IMPORTANT、NOTE、TIP 和 WARNING
// 通过在文档头部设置 `:icons: font` 来启用警告图标
[NOTE]
====
警告块 - 给读者的提示，严重程度从提示到警告不等
====
```

```plaintext
====
示例块 - 正在记录的概念的演示
====
```

```plaintext
.点我展开
[%collapsible]
====
可折叠块 - 点击标题即可显示这些详细信息
====
```

```plaintext
****
侧边栏块 - 可以独立于主要内容阅读的辅助内容
****
```

```plaintext
....
字面块 - 展示程序输出的示例
....
```

```plaintext
----
清单块 - 展示程序输入、源代码或文件内容的示例
----
```

```plaintext
[,language]
----
源代码块 - 一个附有（彩色）语法高亮的清单
----
```

````plaintext
\```language
围栏代码 - 源代码块的简写语法
\```
````

```plaintext
[,attribution,citetitle]
____
引用块 - 一段引文或摘录；来源的署名与标题是可选的
____
```

```plaintext
[verse,attribution,citetitle]
____
诗歌块 - 一段文学摘录，通常是一首诗；来源的署名与标题是可选的
____
```

```plaintext
++++
直通块 - 直接传递给输出文档的内容；通常是原始 HTML
++++
```

```plaintext
// 通过在文档头部添加 `:stem:` 来激活 stem 支持
[stem]
++++
x = y^2
++++
```

```plaintext
////
注释块 - 不包含在输出文档中的内容
////
```

<a id="tables"></a>

## 表格

```plaintext
.表格属性
[cols=>1h;2d,width=50%,frame=topbot]
|===
| 属性名称 | 值

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

可以以 `HEX`、`RGB` 或 `HSL` 格式写入颜色，并使用颜色指示器进行渲染。
支持的格式（不支持命名颜色）：

- `HEX`: `` `#RGB[A]` `` 或 `` `#RRGGBB[AA]` ``
- `RGB`: `` `RGB[A](R, G, B[, A])` ``
- `HSL`: `` `HSL[A](H, S, L[, A])` ``

写在反引号内的颜色后面会跟着一个颜色“色块”：

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

## 方程与公式

如果需要包含科学、技术、工程和数学 (STEM) 表达式，请在文档头部将 `stem` 属性设置为 `latexmath`。
方程和公式将使用 [KaTeX](https://katex.org/) 进行渲染：

```plaintext
:stem: latexmath

latexmath:[C = \alpha + \beta Y^{\gamma} + \epsilon]

[stem]
++++
sqrt(4) = 2
++++

一个矩阵可以写成 stem:[[[a,b\],[c,d\]\]((n),(k))]。
```

<a id="diagrams-and-flowcharts"></a>

## 图表与流程图

可以使用 [Mermaid](https://mermaidjs.github.io/) 或 [PlantUML](https://plantuml.com) 在极狐GitLab 中从文本生成图表和流程图。

<a id="mermaid"></a>

### Mermaid

有关更多详细信息，请访问 [官方页面](https://mermaidjs.github.io/)。
如果你刚开始使用 Mermaid 或需要帮助识别 Mermaid 代码中的问题，
[Mermaid Live Editor](https://mermaid-js.github.io/mermaid-live-editor/) 是一个用于创建和解决 Mermaid 图表问题的有用工具。

要生成图表或流程图，请将你的文本放入 `mermaid` 块中：

```plaintext
[mermaid]
----
graph LR
    A[正方形] -- 链接文本 --> B((圆形))
    A --> C(圆角矩形)
    B --> D{菱形}
    C --> D
----
```

<a id="kroki"></a>

### Kroki

Kroki 支持十多种图表库。
要在极狐GitLab 中使用 Kroki，需要极狐GitLab 管理员首先启用它。
详情请参阅 [Kroki 集成](../administration/integration/kroki.md) 页面。

启用 Kroki 后，你可以在 AsciiDoc 和 Markdown 文档中创建图表。
以下是使用 GraphViz 图表的示例：

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

JihuLab.com 上启用了 PlantUML 集成。要在极狐GitLab 私有化部署中使用 PlantUML，极狐GitLab 管理员 [必须启用它](../administration/integration/plantuml.md)。

启用 PlantUML 后，请将你的文本放入 `plantuml` 块中：

```plaintext
[plantuml]
----
Bob -> Alice : 你好
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
image::screenshot.png[块图像,800,450]

按下 image:reload.svg[重新加载,16,opts=interactive] 重新加载页面。

video::movie.mp4[width=640,start=60,end=140,options=autoplay]
```

极狐GitLab 不支持在 AsciiDoc 内容中嵌入 YouTube 和 Vimeo 视频。
请使用标准 AsciiDoc 链接：

```plaintext
https://www.youtube.com/watch?v=BlaZ65-b7y0[视频的链接文本]
```

<a id="breaks"></a>

## 分隔符

```plaintext
// 主题分隔符（即水平线）
---
```

```plaintext
// 分页符
<<<
```

<a id="table-of-contents"></a>

## 目录

```plaintext
= 文档标题 (层级 0)
:toc:
:toclevels: 3
:toc-title: 内容

== 层级 1
=== 层级 2
==== 层级 3
===== 层级 4
====== 层级 5
== 回到层级 1
```

不支持 `:toc-class:`、`:toc: left` 和 `:toc: right` 属性。
