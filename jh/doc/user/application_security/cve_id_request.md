---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: CVE ID 请求
description: 漏洞跟踪与安全披露。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

[通用漏洞与暴露 ID](https://cve.mitre.org/index.html)（CVE ID）是分配给公开披露的软件漏洞的唯一标识符。极狐GitLab 是 [CVE 编号机构](<https://cve.mitre.org/cve/cna.html>)（CNA），这意味着我们可以为托管在 JihuLab.com 上的项目中的漏洞分配 CVE 标识符。

对于公开项目，您可以请求 CVE 标识符，以便让用户了解安全问题。例如，极狐GitLab [依赖扫描工具](dependency_scanning/_index.md)可以检测您的项目何时使用了存在漏洞的依赖项版本。

常见的漏洞处理流程是：

1. 为漏洞请求 CVE。
1. 在发布说明中引用已分配的 CVE 标识符。
1. 在修复发布后公布该漏洞的详细信息。

<a id="submit-a-cve-id-request"></a>

## 提交 CVE ID 请求

先决条件：

- 拥有项目的维护者或所有者角色。
- 项目托管在 JihuLab.com 上。
- 项目是公开的。
- 该漏洞的议题是[机密](../project/issues/confidential_issues.md)的。

要提交 CVE ID 请求：

1. 转到该漏洞的议题，然后选择 **创建CVE ID请求**。此时会打开
   [GitLab CVE 项目](https://gitlab.com/gitlab-org/cves)的新建议题页面。
1. 在 **标题** 框中，输入该漏洞的简要描述。
1. 在 **描述** 框中，输入以下详细信息：

   - 该漏洞的详细描述
   - 项目的供应商和名称
   - 受影响的版本
   - 已修复的版本
   - 漏洞类别（[CWE](https://cwe.mitre.org/data/index.html) 标识符）
   - [CVSS v3 向量](https://nvd.nist.gov/vuln-metrics/cvss/v3-calculator)

极狐GitLab 会在以下情况下更新您的 CVE ID 请求议题：

- 您提交的内容被分配了 CVE。
- 您的 CVE 已发布。
- MITRE 已收到您的 CVE 已发布的通知。
- MITRE 已将您的 CVE 添加到 NVD 源中。

<a id="cve-assignment"></a>

## CVE 分配

分配 CVE 标识符后，您可以根据需要引用它。CVE ID 请求中提交的漏洞详细信息将按照您的时间安排发布。
