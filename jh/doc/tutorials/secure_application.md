---
stage: none
group: Tutorials
info: For assistance with this tutorials page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
description: 依赖项与合规性扫描。
title: '教程：保护应用并检查合规性'
---

极狐GitLab 可以检查你的应用是否存在安全漏洞，并检查其是否满足合规性要求。

## 学习安全基础知识

从这里开始了解极狐GitLab 的安全基础知识。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [极狐GitLab 安全要点](https://university.gitlab.com/learning-paths/gitlab-security-essentials-v100) | 通过此自学课程学习极狐GitLab 的基本安全能力。 | {{< icon name="star" >}}  |
| [极狐GitLab 应用安全入门](../user/application_security/get-started-security.md) | 按照推荐的步骤设置安全工具。 | |

## 设置基础安全检测

创建基础扫描以识别漏洞。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [设置依赖项扫描](dependency_scanning.md) | 学习如何检测应用依赖项中的漏洞。 | {{< icon name="star" >}} |
| [使用 SBOM 方法设置依赖项扫描](dependency_scanning_by_sbom.md) | 学习如何使用 SBOM 方法检测应用依赖项中的漏洞。 | {{< icon name="star" >}} |
| [扫描 Docker 容器中的漏洞](container_scanning/_index.md) | 学习如何使用容器扫描模板将容器扫描添加到你的项目中。 | {{< icon name="star" >}} |
| [极狐GitLab DAST 综合指南](https://about.gitlab.com/blog/comprehensive-guide-to-gitlab-dast/) | 学习如何配置动态应用安全测试、执行扫描以及实施安全策略。 | {{< icon name="star" >}} |

## 防止密钥泄露

防止敏感数据被提交到你的代码仓库中。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [使用密钥推送保护保护你的项目](../user/application_security/secret_detection/push_protection_tutorial.md) | 在你的项目中启用密钥推送保护。 | {{< icon name="star" >}} |
| [检测提交到项目中的密钥](../user/application_security/secret_detection/pipeline/tutorial.md) | 学习如何检测并修复提交到项目代码仓库中的密钥。 | {{< icon name="star" >}} |
| [从你的提交中删除密钥](../user/application_security/secret_detection/remove_secrets_tutorial.md) | 学习如何从你的提交历史中删除某个密钥。 | {{< icon name="star" >}} |

## 实施安全策略与治理

在你的项目中强制执行安全要求。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [设置扫描执行策略](scan_execution_policy/_index.md) | 学习如何创建扫描执行策略以强制对你的项目进行安全扫描。 | {{< icon name="star" >}} |
| [设置流水线执行策略](pipeline_execution_policy/_index.md) | 学习如何创建流水线执行策略，以便在流水线中跨项目强制执行安全扫描。 | {{< icon name="star" >}} |
| [设置合并请求批准策略](scan_result_policy/_index.md) | 学习如何配置一个根据扫描结果采取行动的合并请求批准策略。 | {{< icon name="star" >}} |

## 建立合规性与报告机制

满足监管要求并生成合规性文档。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [使用极狐GitLab 软件包仓库生成软件物料清单](../user/packages/package_registry/tutorial_generate_sbom.md) | 学习如何在群组内的所有项目中生成 SBOM。 | {{< icon name="star" >}} |
| [以 SBOM 格式导出依赖项列表](export_sbom.md) | 学习如何将应用的依赖项导出为 CycloneDX SBOM 格式。 | {{< icon name="star" >}} |