---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 基于浏览器的 DAST 分析器
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.7 中 GA（极狐GitLab DAST v3.0.50）。

{{< /history >}}

> [!warning]
> 在极狐GitLab 17.0 中，DAST 版本 4 基于浏览器的分析器已被 DAST 版本 5 替代。
> 有关如何迁移到 DAST 版本 5 的说明，请参见[迁移指南](../browser_based_4_to_5_migration_guide.md)。

基于浏览器的 DAST 可帮助您识别 Web 应用程序中的安全弱点（CWEs）。当您部署 Web 应用程序后，它会面临新的攻击类型，其中许多攻击在部署之前是无法检测到的。例如，应用程序服务器的错误配置或对安全控制的不正确假设可能无法从源代码中看到，但可以通过基于浏览器的 DAST 检测到。

动态应用程序安全测试（DAST）检查已部署环境中的应用程序是否存在此类漏洞。

> [!warning]
> 不要对生产服务器运行 DAST 扫描。它不仅会执行用户可以执行的任何功能（例如点击按钮或提交表单），还可能触发错误，导致生产数据被修改或丢失。只应对测试服务器运行 DAST 扫描。

DAST 浏览器化分析器由极狐GitLab 构建，用于扫描现代 Web 应用程序以查找漏洞。扫描在浏览器中运行，以优化对严重依赖 JavaScript 的应用程序（例如单页应用程序）的测试。有关详细信息，请参阅[DAST 如何扫描应用程序](#how-dast-scans-an-application)。

要将分析器添加到 CI/CD 流水线中，请参阅[启用分析器](configuration/enabling_the_analyzer.md)。

## 入门指南

如果您是 DAST 的新手，请按照本指南设置您的第一次扫描。

前提条件：

- 在 Linux/amd64 上使用 [`docker` executor](https://gitlab.cn/docs/runner/executors/docker/) 的[极狐GitLab Runner](../../../../ci/runners/_index.md)。
- 已部署的目标应用程序。请参阅[部署选项](application_deployment_options.md)。
- 极狐GitLab Runner 与目标应用程序之间的网络连通性。

开始使用 DAST：

1. 启用分析器。[在流水线中创建 DAST CI/CD 作业](configuration/enabling_the_analyzer.md)以运行扫描器。
1. 配置身份验证。如果您的应用程序需要登录，请[设置身份验证](configuration/authentication.md)，以便 DAST 可以扫描经过身份验证的页面。
1. 排查配置问题。如果在设置过程中遇到问题，请参阅[故障排查文档](troubleshooting.md#setting-up-dast)。

### 后续步骤

完成第一次扫描后：

- 查看[理解扫描结果](#understanding-the-results)以了解如何解读扫描发现。
- 探索[配置选项](configuration/_index.md)以自定义扫描。
- 了解更多关于[DAST 如何扫描应用程序](#how-dast-scans-an-application)的信息。

## 理解扫描结果

您可以在流水线中查看漏洞：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **构建** > **流水线**。
1. 选择该流水线。
1. 选择 **安全** 标签页。
1. 选择一个漏洞以查看其详细信息，包括：
   - 状态：指示漏洞是否已被分类或已解决。
   - 描述：解释漏洞的成因、潜在影响以及建议的修复步骤。
   - 严重性：根据影响分为六个级别。[了解更多关于严重性级别的信息](../../vulnerabilities/severities.md)。
   - 扫描器：识别检测到漏洞的分析器。
   - 方法：确定易受攻击的服务器交互类型。
   - URL：显示漏洞的位置。
   - 证据：描述证明给定漏洞存在的测试用例。
   - 标识符：用于对漏洞进行分类的引用列表，例如 CWE 标识符。

您也可以下载安全扫描结果：

- 在流水线的 **安全** 标签页中，选择 **下载结果**。

有关更多详细信息，请参阅[流水线安全报告](../../detect/security_scanning_results.md)。

> [!note]
> 发现结果在功能分支上生成。当它们被合并到默认分支后，就会变成漏洞。在评估您的安全态势时，这一区别非常重要。

## 优化

有关针对特定应用程序或环境配置 DAST 的信息，请参阅[配置选项](configuration/_index.md)。

## 推广

为一个项目配置 DAST 后，您可以将该配置扩展到其他项目：

- 如果您的流水线配置为每次运行都部署到同一个 Web 服务器，需格外小心。在服务器更新期间运行 DAST 扫描会导致结果不准确且不确定。
- 配置 Runner 使用[始终拉取策略](https://gitlab.cn/docs/runner/executors/docker/#using-the-always-pull-policy)以运行分析器的最新版本。
- 默认情况下，DAST 会下载流水线中先前作业定义的所有产物。如果您的 DAST 作业不依赖于 `environment_url.txt` 来定义被测 URL，也不依赖于先前作业创建的任何其他文件，则不应下载产物。为避免下载产物，可以扩展分析器 CI/CD 作业以指定无依赖项。例如，对于基于代理的 DAST 分析器，在您的 `.gitlab-ci.yml` 文件中添加以下内容：

  ```yaml
  dast:
    dependencies: []
  ```

## DAST 如何扫描应用程序

一次扫描执行以下步骤：

1. [身份验证](configuration/authentication.md)（如果已配置）。
1. [爬取](#crawling-an-application)目标应用程序，通过执行用户操作（如跟踪链接、点击按钮和填写表单）来发现应用程序的表面积。
1. [被动扫描](#passive-scans)以查找在爬取过程中发现的 HTTP 消息和页面中的漏洞。
1. [主动扫描](#active-scans)通过将攻击负载注入到爬取阶段记录的 HTTP 请求中来查找漏洞。

### 爬取应用程序

“导航”是用户可能在页面上执行的操作，例如点击按钮、点击锚链接、打开菜单项或填写表单。
“导航路径”是一个导航操作序列，表示用户如何遍历应用程序。
DAST 通过爬取页面和内容并识别导航路径来发现应用程序的表面积。

爬取过程通过包含一个导航的导航路径进行初始化，该导航在一个特制的 Chromium 浏览器中加载目标应用程序 URL。
然后，DAST 爬取所有导航路径，直到所有路径都被爬取完。

为了爬取一个导航路径，DAST 会打开一个浏览器窗口，并指示其执行导航路径中的所有导航操作。
当浏览器完成最终操作结果的加载后，DAST 会检查页面上用户可能执行的操作，
为每个找到的操作创建一个新导航，并将其添加到导航路径中以形成新的导航路径。例如：

1. DAST 处理导航路径 `LoadURL[https://example.com]`。
1. DAST 发现两个用户操作，`LeftClick[class=menu]` 和 `LeftClick[id=users]`。
1. DAST 创建两个新的导航路径，`LoadURL[https://example.com] -> LeftClick[class=menu]` 和 `LoadURL[https://example.com] -> LeftClick[id=users]`。
1. 爬取从这两个新的导航路径开始。

一个 HTML 元素存在于应用程序的多个位置是很常见的，例如在每个页面上都可见的菜单。
重复的元素可能导致爬虫反复爬取相同的页面或陷入循环。
DAST 使用基于 HTML 属性的元素唯一性计算，以丢弃先前已爬取过的新导航操作。

### 被动扫描

被动扫描在扫描的爬取阶段发现的页面中检查漏洞。
被动扫描尝试以与普通用户相同的方式与站点交互，包括执行破坏性操作，如删除数据。
但是，被动扫描不模拟对抗性行为。
被动扫描默认启用。

这些检查搜索 HTTP 消息、Cookie、存储事件、控制台事件和 DOM 中的漏洞。
被动检查的示例包括查找暴露的信用卡、暴露的密钥令牌、缺失的内容安全策略以及重定向到不受信任的位置。

有关各个检查的更多信息，请参阅[检查](checks/_index.md)。

### 主动扫描

主动扫描通过将攻击负载注入到扫描爬取阶段记录的 HTTP 请求中来检查漏洞。
主动扫描默认禁用，因为它们模拟对抗性行为。

DAST 分析每个记录的 HTTP 请求以查找注入位置，例如查询值、请求头值、Cookie 值、表单提交和 JSON 字符串值。
攻击负载被注入到注入位置，形成新的请求。
DAST 将请求发送到目标应用程序，并使用 HTTP 响应来确定攻击是否成功。

主动扫描运行两种类型的主动检查：

- 匹配响应攻击分析响应内容以确定攻击是否成功。例如，如果攻击试图读取系统密码文件，当响应正文包含密码文件的证据时，就会创建一个发现结果。
- 时序攻击使用响应时间来确定攻击是否成功。例如，如果攻击试图强制目标应用程序休眠，当应用程序的响应时间超过休眠时间时，就会创建一个发现结果。时序攻击会使用不同的攻击负载重复多次，以最大限度地减少误报。

一个简化的时序攻击工作原理如下：

1. 爬取阶段记录了 HTTP 请求 `https://example.com?search=people`。
1. DAST 分析 URL 并找到一个 URL 参数注入位置 `https://example.com?search=[INJECT]`。
1. 主动检查定义一个负载 `sleep 10`，试图让 Linux 主机休眠。
1. DAST 向目标应用程序发送一个带有注入负载的新 HTTP 请求 `https://example.com?search=sleep%2010`。
1. 如果目标应用程序在未经验证的情况下将查询参数值作为系统命令执行，例如 `system(params[:search])`，则它是易受攻击的。
1. 如果响应时间超过 10 秒，DAST 会创建一个发现结果。