---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 依赖项扫描
description: 漏洞、修复、配置、分析器和报告。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

依赖项扫描可识别项目依赖项（包括运行时、开发及传递（嵌套）软件包）中的已知安全漏洞。
极狐GitLab 提供了多种依赖项扫描方法，每种方法适用于不同的工作流。请参考以下摘要，选择适合您项目的方法。

<a id="available-scanning-methods"></a>

## 可用的扫描方法

<a id="dependency-scanning-using-sbom"></a>

### 使用 SBOM 的依赖项扫描

扫描由依赖项扫描分析器在流水线中生成的 CycloneDX SBOM 产物，并与极狐GitLab 安全咨询数据库进行比对。
这是推荐用于新项目的方法，也是极狐GitLab 依赖项扫描的长期发展方向。

详情请参见[使用 SBOM 的依赖项扫描](dependency_scanning_sbom/_index.md)。

<a id="continuous-dependency-scanning"></a>

### 持续依赖项扫描

每当极狐GitLab 安全咨询数据库更新时，持续重新扫描默认分支最新成功流水线中的 SBOM 组件，从而在无需重新运行流水线的情况下暴露新披露的漏洞。

详情请参见[持续依赖项扫描](continuous_dependency_scanning/_index.md)。

<a id="dependency-scanning-with-gemnasium"></a>

### 使用 Gemnasium 的依赖项扫描

原始的基于流水线的分析器，在 CI/CD 作业中检测依赖项，并将其与极狐GitLab 安全咨询数据库进行比对。

> [!warning]
> 基于 Gemnasium 分析器的依赖项扫描在极狐GitLab 17.9 中已弃用，并计划在极狐GitLab 20.0 中移除。有关迁移指导，请参见[迁移指南](migration_guide_to_sbom_based_scans.md)。

详情请参见[旧版依赖项扫描页面](legacy_dependency_scanning/_index.md)。

<a id="analyze-dependencies-for-behaviors-libbehave"></a>

### 分析依赖项行为 (Libbehave)

一项实验性功能，分析依赖项的运行时行为，以发现超出已知 CVE 的可疑或恶意活动。

详情请参见[分析依赖项行为](experiment_libbehave_dependency.md)。

<a id="comparison-of-scanning-methods"></a>

## 扫描方法对比

| 方法                               | 状态               | 触发方式           | 最适合                                                     |
| ---------------------------------- | ------------------ | ------------------ | ---------------------------------------------------------- |
| 使用 SBOM 的依赖项扫描             | 有限可用           | 流水线             | 新项目、以 SBOM 为先的工作流                                |
| 持续依赖项扫描                     | GA                 | 安全咨询数据库更新 | 在不重新运行流水线的情况下捕获新披露的 CVE                  |
| 使用 Gemnasium 的依赖项扫描        | 已弃用 (17.9)      | 流水线             | 等待迁移的现有项目                                          |
| 分析依赖项行为                     | 实验性             | 流水线             | 检测恶意软件包行为                                          |

<a id="contributing-to-the-vulnerability-database"></a>

## 为漏洞数据库做贡献

要查找漏洞，您可以搜索[`极狐GitLab 安全咨询数据库`](https://advisories.gitlab.com/)。
您也可以[提交新漏洞](https://jihulab.com/gitlab-cn/security-products/gemnasium-db/blob/master/CONTRIBUTING.md)。