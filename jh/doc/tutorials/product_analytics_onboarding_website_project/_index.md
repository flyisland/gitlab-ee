---
stage: Analytics
group: Platform Insights
info: For assistance with this tutorial, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
title: '教程：在极狐GitLab Pages 网站项目中设置产品分析'
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验性

{{< /details >}}

<!-- vale gitlab_base.FutureTense = NO -->

了解用户如何与您的网站或应用互动，对于做出数据驱动决策非常重要。
通过识别用户最常使用和最少使用的功能，您的团队可以决定如何高效地分配时间。

跟随本教程，您将学习如何创建一个示例网站项目、为项目启用产品分析、对网站进行插桩以开始收集事件，
并使用项目级分析仪表盘来理解用户行为。

以下是我们将要做的事情概览：

1. 从模板创建项目
1. 为项目启用产品分析
1. 使用跟踪代码片段对网站进行插桩
1. 收集使用数据
1. 查看仪表盘

<a id="before-you-begin"></a>

## 准备工作

要跟随本教程，您必须：

- 为您的实例[启用产品分析](../../development/internal_analytics/product_analytics.md#enable-product-analytics)。
- 在创建项目的群组中拥有所有者角色。

<a id="create-a-project-from-a-template"></a>

## 从模板创建项目

首先，您需要在您的群组中创建一个项目。

极狐GitLab 提供了项目模板，可以方便地为各种用例设置包含所有必要文件的项目。
在这里，您将创建一个纯 HTML 网站的项目。

创建项目的步骤：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建项目/代码仓库**。
1. 选择 **从模板创建**。
1. 选择 **Pages/Plain HTML** 模板。
1. 在 **项目名称** 文本框中，输入名称（例如 `My website`）。
1. 从 **项目 URL** 下拉列表中，选择您想要在其中创建项目的群组。
1. 在 **项目路径** 文本框中，输入项目的路径（例如 `my-website`）。
1. 可选。在 **项目描述** 文本框中，输入项目描述。
   例如，`带有产品分析的纯 HTML 网站`。您可以随时添加或编辑此描述。
1. 在 **可见性级别** 下，选择所需的项目级别。
   如果在群组中创建项目，项目的可见性设置必须至少与其父群组的可见性一样受限。
1. 选择 **创建项目**。

现在，您拥有了一个包涵纯 HTML 网站所需所有文件的项目。

<a id="onboard-the-project-with-product-analytics"></a>

## 为项目启用产品分析

要收集事件并查看网站使用情况的仪表盘，项目必须启用产品分析。

为新项目启用产品分析：

1. 在项目中，选择 **分析** > **分析仪表盘**。
1. 找到 **产品分析** 项并选择 **设置**。
1. 选择 **设置产品分析**。
1. 等待您的实例完成创建。
1. 复制 **HTML 脚本设置** 代码片段。您将在后面的步骤中需要它。

您的项目现在已启用，并准备好让应用开始发送事件。

<a id="instrument-your-website"></a>

## 对您的网站进行插桩

要收集使用事件并将其发送到极狐GitLab，您必须在网站中包含一个代码片段。
您可以选择多种平台和技术特定的跟踪 SDK 来集成到您的应用中。
对于此示例网站，我们使用浏览器 SDK。

对新网站进行插桩：

1. 在项目中，选择 **代码** > **代码仓库**。
1. 选择 **代码** > **Web IDE**。
1. 在左侧 Web IDE 工具栏中，选择 **文件浏览器** 并打开 `public/index.html` 文件。
1. 在 `public/index.html` 文件中，在关闭的 `</body>` 标签之前，粘贴您在上一节中复制的代码片段。

   `index.html` 文件中的代码应如下所示（其中 `appId` 和 `host` 具有启用部分提供的值）：

   ```html
   <!DOCTYPE html>
   <html>
     <head>
       <meta charset="utf-8">
       <meta name="generator" content="GitLab Pages">
       <title>使用 GitLab Pages 的纯 HTML 网站</title>
       <link rel="stylesheet" href="style.css">
     </head>
     <body>
       <div class="navbar">
         <a href="https://pages.gitlab.io/plain-html/">纯 HTML 示例</a>
         <a href="https://gitlab.com/pages/plain-html/">代码仓库</a>
         <a href="https://gitlab.com/pages/">其他示例</a>
       </div>

       <h1>Hello World!</h1>

       <p>
         这是一个简单的纯 HTML 网站，使用 GitLab Pages，无需任何花哨的静态站点生成器。
       </p>
       <script src="https://unpkg.com/@gitlab/application-sdk-browser/dist/gl-sdk.min.js"></script>
       <script>
         window.glClient = window.glSDK.glClientSDK({
           appId: 'YOUR_APP_ID',
           host: 'YOUR_HOST',
         });
       </script>
     </body>
   </html>
   ```

1. 在左侧 Web IDE 工具栏中，选择 **源代码控制**。
1. 输入提交信息，例如 `添加 GitLab 产品分析跟踪代码片段`。
1. 选择 **提交**，如果系统提示要创建新分支或继续，选择 **继续**。然后您可以关闭 Web IDE。
1. 在项目中，选择 **构建** > **流水线**。
   您的最近提交会触发一条流水线。等待它完成运行并部署更新后的网站。

<a id="collect-usage-data"></a>

## 收集使用数据

在插桩的网站部署后，事件开始被收集。

1. 在项目中，选择 **部署** > **Pages**。
1. 要打开网站，在 **访问 pages** 中选择您唯一的 URL。
1. 要收集一些页面浏览事件，刷新页面几次。

<a id="view-dashboards"></a>

## 查看仪表盘

极狐GitLab 默认提供两个产品分析仪表盘：**受众** 和 **行为**。
这些仪表盘在项目收到一些事件后变为可用。

查看这些仪表盘：

1. 在项目中，选择 **分析** > **仪表盘**。
1. 从可用仪表盘列表中，选择 **受众** 或 **行为**。

就是这样！现在您拥有一个带有产品分析的网站项目，它可以帮助您收集和可视化数据，以了解用户行为，并使您的团队工作更高效。