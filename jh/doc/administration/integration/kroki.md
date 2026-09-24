---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 开启 Kroki 集成，即可在 AsciiDoc、Markdown、reStructuredText 和 Textile 文件中将图表作为代码渲染。
title: Kroki
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

通过 [Kroki](https://kroki.io) 集成，
您可以在 AsciiDoc、Markdown、reStructuredText 和 Textile 中创建图表即代码。

<a id="enable-kroki-in-gitlab"></a>

## 在极狐GitLab 中启用 Kroki

先决条件：

- 管理员访问权限。

要开启 Kroki 集成：

1. 在右上角，选择 **管理员**。
1. 转到 **设置** > **通用**。
1. 展开 **Kroki**。
1. 选中 **启用 Kroki** 复选框。
1. 输入 **Kroki URL**，例如 `https://kroki.io`。

为防止浏览器将图表内容发送到外部 Kroki 服务，
请使用[图表代理](diagram_proxy.md)。

<a id="kroki-server"></a>

## Kroki 服务器

当您开启 Kroki 时，极狐GitLab 会将图表发送到 Kroki 实例以将其显示为图像。
您可以使用免费的公共云实例 `https://kroki.io`，也可以在您自己的基础设施上
[安装 Kroki](https://docs.kroki.io/kroki/setup/install/)。
安装 Kroki 后，请务必更新设置中的 **Kroki URL**，使其指向您的实例。

> [!note]
> Kroki 图表不存储在极狐GitLab 上，因此极狐GitLab 的标准访问控制和其他用户权限限制不适用。

<a id="docker"></a>

### Docker

使用 Docker，运行如下容器：

```shell
docker run -d --name kroki -p 8080:8000 yuzutech/kroki
```

**Kroki URL** 是运行容器的服务器的主机名。

[`yuzutech/kroki`](https://hub.docker.com/r/yuzutech/kroki) Docker 镜像开箱即用地支持大多数图表
类型。有关完整列表，请参阅 [Kroki 安装文档](https://docs.kroki.io/kroki/setup/install/#_the_kroki_container)。

支持的图表类型包括：

<!-- vale gitlab_base.Spelling = NO -->

- [Bytefield](https://bytefield-svg.deepsymmetry.org/bytefield-svg/intro.html)
- [D2](https://d2lang.com/tour/intro/)
- [DBML](https://dbml.dbdiagram.io/home/)
- [Ditaa](https://ditaa.sourceforge.net)
- [Erd](https://github.com/BurntSushi/erd)
- [GraphViz](https://www.graphviz.org/)
- [Nomnoml](https://github.com/skanaar/nomnoml)
- [PlantUML](https://github.com/plantuml/plantuml)
  - [C4 model](https://github.com/plantuml-stdlib/C4-PlantUML)（与 PlantUML 一起使用）
- [Structurizr](https://structurizr.com/)（非常适合 C4 Model 图表）
- [Svgbob](https://github.com/ivanceras/svgbob)
- [UMlet](https://github.com/umlet/umlet)
- [Vega](https://github.com/vega/vega)
- [Vega-Lite](https://github.com/vega/vega-lite)
- [WaveDrom](https://wavedrom.com/)

<!-- vale gitlab_base.Spelling = YES -->

如果您想使用其他图表库，
请阅读 [Kroki 安装](https://docs.kroki.io/kroki/setup/install/#_images) 了解如何启动 Kroki 配套容器。

<a id="create-diagrams"></a>

## 创建图表

开启并配置 Kroki 集成后，您可以使用分隔块开始向
您的 AsciiDoc 或 Markdown 文档添加图表：

- **Markdown**

  ````markdown
  ```plantuml
  Bob -> Alice : hello
  Alice -> Bob : hi
  ```
  ````

- **AsciiDoc**

  ```plaintext
  [plantuml]
  ....
  Bob->Alice : hello
  Alice -> Bob : hi
  ....
  ```

- **reStructuredText**

  ```plaintext
  .. code-block:: plantuml

    Bob->Alice : hello
    Alice -> Bob : hi
  ```

- **Textile**

  ```plaintext
  bc[plantuml]. Bob->Alice : hello
  Alice -> Bob : hi
  ```

分隔块会转换为 HTML 图像标签，其源指向
Kroki 实例。如果 Kroki 服务器配置正确，这应该
会渲染出漂亮的图表，而不是显示代码块：

![从示例代码渲染的 PlantUML 图表。](img/kroki_plantuml_diagram_v13_7.png)

Kroki 支持十多种图表库。以下是 AsciiDoc 的一些示例：

**GraphViz**

```plaintext
[graphviz]
....
digraph finite_state_machine {
  rankdir=LR;
  node [shape = doublecircle]; LR_0 LR_3 LR_4 LR_8;
  node [shape = circle];
  LR_0 -> LR_2 [ label = "SS(B)" ];
  LR_0 -> LR_1 [ label = "SS(S)" ];
  LR_1 -> LR_3 [ label = "S($end)" ];
  LR_2 -> LR_6 [ label = "SS(b)" ];
  LR_2 -> LR_5 [ label = "SS(a)" ];
  LR_2 -> LR_4 [ label = "S(A)" ];
  LR_5 -> LR_7 [ label = "S(b)" ];
  LR_5 -> LR_5 [ label = "S(a)" ];
  LR_6 -> LR_6 [ label = "S(b)" ];
  LR_6 -> LR_5 [ label = "S(a)" ];
  LR_7 -> LR_8 [ label = "S(b)" ];
  LR_7 -> LR_5 [ label = "S(a)" ];
  LR_8 -> LR_6 [ label = "S(b)" ];
  LR_8 -> LR_5 [ label = "S(a)" ];
}
....
```

![从示例代码生成的 GraphViz 图表。](img/kroki_graphviz_diagram_v13_7.png)

**C4（基于 PlantUML）**

```plaintext
[c4plantuml]
....
@startuml
!include C4_Context.puml

title System Context diagram for Internet Banking System

Person(customer, "Banking Customer", "A customer of the bank, with personal bank accounts.")
System(banking_system, "Internet Banking System", "Allows customers to check their accounts.")

System_Ext(mail_system, "E-mail system", "The internal Microsoft Exchange e-mail system.")
System_Ext(mainframe, "Mainframe Banking System", "Stores all of the core banking information.")

Rel(customer, banking_system, "Uses")
Rel_Back(customer, mail_system, "Sends e-mails to")
Rel_Neighbor(banking_system, mail_system, "Sends e-mails", "SMTP")
Rel(banking_system, mainframe, "Uses")
@enduml
....
```

![从示例代码生成的 C4 PlantUML 图表。](img/kroki_c4_diagram_v13_7.png)

<!-- vale gitlab_base.Spelling = NO -->

**Nomnoml**

<!-- vale gitlab_base.Spelling = YES -->

```plaintext
[nomnoml]
....
[Pirate|eyeCount: Int|raid();pillage()|
  [beard]--[parrot]
  [beard]-:>[foul mouth]
]

[<abstract>Marauder]<:--[Pirate]
[Pirate]- 0..7[mischief]
[jollyness]->[Pirate]
[jollyness]->[rum]
[jollyness]->[singing]
[Pirate]-> *[rum|tastiness: Int|swig()]
[Pirate]->[singing]
[singing]<->[rum]
....
```

![从示例代码生成的 Nomnoml 图表。](img/kroki_nomnoml_diagram_v13_7.png)
