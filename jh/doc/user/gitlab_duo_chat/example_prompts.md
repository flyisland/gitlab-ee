---
stage: AI-powered
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Duo Chat 提示词示例
---

极狐GitLab Duo Agentic Chat 可以帮助您回答需要多个文件或极狐GitLab 资源信息的问题。
它可以回答关于代码库的问题，无需指定确切文件路径。
它还可以了解议题或合并请求的状态，并创建和编辑文件。

<a id="learn-more-about-your-projects"></a>

## 深入了解您的项目

极狐GitLab Duo Chat 最适合自然语言问题。
向它询问项目的任何方面，从整体到具体。

- `阅读项目结构并向我解释`，或`解释项目`。
- `找到此代码库中处理用户认证的 API 端点`。
- `请解释 <application name> 的授权流程`。
- `如何在此仓库中添加 GraphQL mutation？`
- `展示如何在整个应用程序中实现错误处理`。
- `组件 <component name> 具有 <x> 和 <y> 的方法。能否将其拆分为两个组件？`
- `合并请求 <MR URL> 和合并请求 <MR URL> 是否完全解决了议题 <issue URL>？`

<a id="have-chat-do-the-work-for-you"></a>

## 让 Chat 为您完成工作

如果您已经知道自己想做什么，Chat 可以为您完成工作。

- `添加一个允许用户查询我的应用程序的 GraphQL mutation。`
- `为我的应用程序实现错误处理`。
- `组件 <component name> 具有 <x> 和 <y> 的方法。将其拆分为两个组件。`
- `为 <directory> 中的所有 Java 文件添加内联文档。`
- `创建一个合并请求来解决此议题：<issue URL>。`

<a id="use-chat-to-address-security-vulnerabilities"></a>

## 使用 Chat 应对安全漏洞

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com

{{< /details >}}

使用 Chat 通过自然语言命令对漏洞进行分类、管理和修复。

漏洞信息与分析：

- `按严重程度和报告类型筛选，列出项目中的所有漏洞。`
- `获取详细的漏洞信息，包括 CVE 数据、EPSS 评分和可达性分析。`
- `显示我项目中的所有严重漏洞。`
- `列出 EPSS 评分高于 0.7 且可达的漏洞。`

漏洞管理：

- `将此漏洞标记为真正的安全问题。`
- `将漏洞状态恢复为已检测，以便重新评估。`
- `解除所有因不可达代码而被标记为误报的依赖扫描漏洞。`
- `显示过去一周中被解除的漏洞及其理由。`
- `确认所有存在已知利用漏洞的容器扫描漏洞。`
- `将漏洞 123 链接到议题 456 以跟踪修复。`

议题管理集成：

- `为所有已确认的高严重性 SAST 漏洞创建议题，并将其分配给最近的提交者。`
- `将所有跨越信任边界的漏洞的严重性更新为 HIGH。`

有关安全功能的更多信息，请参见 [epic 19639](https://jihulab.com/gitlab-cn/-/epics/19639)。