---
stage: Tutorials
group: Tutorials
info: For assistance with this tutorials page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
description: 依赖项与合规性扫描。
title: '教程：保护您的应用程序并检查合规性'
---

极狐GitLab 可以检查您的应用程序是否存在安全漏洞，以及是否满足合规要求。

<a id="learn-security-fundamentals"></a>

## 了解安全基础知识

从这里开始了解极狐GitLab 的安全基础知识。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|

<a id="set-up-basic-security-detection"></a>

## 设置基本安全检测

创建基础扫描以识别漏洞。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [设置依赖项扫描](dependency_scanning.md) | 了解如何检测应用程序依赖项中的漏洞。预计用时：15-20 分钟。 | {{< icon name="star" >}} |
| [使用 SBOM 方法设置依赖项扫描](dependency_scanning_by_sbom.md) | 了解如何使用 SBOM 方法检测应用程序依赖项中的漏洞。预计用时：15-20 分钟。 | {{< icon name="star" >}} |
| [扫描 Docker 容器中的漏洞](container_scanning/_index.md) | 了解如何使用容器扫描模板为您的项目添加容器扫描。预计用时：15-20 分钟。 | {{< icon name="star" >}} |
| [极狐GitLab DAST 综合指南](https://about.gitlab.com/blog/comprehensive-guide-to-gitlab-dast/) | 了解如何配置动态应用程序安全测试、执行扫描以及实施安全策略。预计用时：15-20 分钟。 | {{< icon name="star" >}} |

<a id="protect-against-secret-exposure"></a>

## 防止密钥泄露

防止敏感数据被提交到您的代码仓库。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [使用密钥推送保护来保护您的项目](../user/application_security/secret_detection/push_protection_tutorial.md) | 在您的项目中启用密钥推送保护。预计用时：5-10 分钟。 | {{< icon name="star" >}} |
| [检测提交到项目中的密钥](../user/application_security/secret_detection/pipeline/tutorial.md) | 了解如何检测并修复提交到项目代码仓库中的密钥。预计用时：15-20 分钟。 | {{< icon name="star" >}} |
| [从提交中移除密钥](../user/application_security/secret_detection/remove_secrets_tutorial.md) | 了解如何从提交历史中移除密钥。预计用时：15-20 分钟。 | {{< icon name="star" >}} |

<a id="implement-security-policies-and-governance"></a>

## 实施安全策略与治理

在您的项目中强制执行安全要求。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [设置扫描执行策略](scan_execution_policy/_index.md) | 了解如何创建扫描执行策略，以对您的项目强制执行安全扫描。预计用时：30-45 分钟。 | {{< icon name="star" >}} |
| [设置流水线执行策略](pipeline_execution_policy/_index.md) | 了解如何创建流水线执行策略，以作为流水线的一部分，跨项目强制执行安全扫描。预计用时：30-45 分钟。 | {{< icon name="star" >}} |
| [设置合并请求审批策略](scan_result_policy/_index.md) | 了解如何配置根据扫描结果采取行动的合并请求审批策略。预计用时：30-45 分钟。 | {{< icon name="star" >}} |

<a id="establish-compliance-and-reporting"></a>

## 建立合规与报告

满足监管要求并生成合规文档。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [使用极狐GitLab 软件包仓库生成软件物料清单](../user/packages/package_registry/tutorial_generate_sbom.md) | 了解如何为群组中的所有项目生成 SBOM。预计用时：1 小时。 | {{< icon name="star" >}} |
| [以 SBOM 格式导出依赖项列表](export_sbom.md) | 了解如何将应用程序的依赖项导出为 CycloneDX SBOM 格式。预计用时：15-20 分钟。 | {{< icon name="star" >}} |
