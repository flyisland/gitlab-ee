---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 漏洞风险评估数据
---

使用漏洞风险数据帮助评估对环境的潜在影响。

- 严重性：每个漏洞都被赋予一个标准化的极狐GitLab 严重性值。
- 对于 [常见漏洞与暴露 (CVE)](https://www.cve.org/) 目录中的漏洞，可以通过 [漏洞详情](_index.md) 页面或 GraphQL 查询获取以下数据：
  - 利用可能性：[漏洞利用预测评分系统 (EPSS)](https://www.first.org/epss) 分数。
  - 已知利用的存在性：[已知被利用漏洞 (KEV)](https://www.cisa.gov/known-exploited-vulnerabilities-catalog) 状态。

使用这些数据帮助优先处理修复和缓解措施。例如，一个具有中等严重性和高 EPSS 分数的漏洞可能需要比一个高严重性和低 EPSS 分数的漏洞更早缓解。

<a id="epss"></a>

## EPSS

{{< history >}}

- 在极狐GitLab 17.4 中引入，使用功能标志 `epss_querying`（在议题 470835 中）和 `epss_ingestion`（在议题 467672 中），默认禁用。
- 重命名为 `cve_enrichment_querying` 和 `cve_enrichment_ingestion`，并在极狐GitLab 17.6 中于 JihuLab.com 启用。
- 在极狐GitLab 17.7 中 GA。功能标志 `cve_enrichment_querying` 和 `cve_enrichment_ingestion` 已移除。

{{< /history >}}

EPSS 分数提供了对 CVE 目录中漏洞在未来 30 天内被利用的可能性的估计。EPSS 为每个 CVE 分配一个 0 到 1 之间的分数（相当于 0% 到 100%）。

<a id="kev"></a>

## KEV

{{< history >}}

- 在极狐GitLab 17.7 中引入。

{{< /history >}}

KEV 目录列出了已知已被利用的漏洞。您应该优先修复 KEV 目录中的漏洞，而非其他漏洞。使用这些漏洞的攻击已经发生，攻击者很可能已知其利用方法。

<a id="reachability"></a>

## 可到达性

{{< history >}}

- 在极狐GitLab 17.11 中引入。

{{< /history >}}

可到达性显示易受攻击的软件包是否被您的应用程序导入。您的代码直接交互的软件包中的漏洞比未使用的依赖项中的漏洞构成更高的风险。优先修复可到达的漏洞，因为它们代表攻击者可能利用的真实暴露点。

更多详细信息，请参见 [静态可达性](../dependency_scanning/static_reachability.md)。

<a id="query-risk-assessment-data"></a>

## 查询风险评估数据

使用 GraphQL API 查询项目中漏洞的严重性、EPSS 和 KEV 值。

GraphQL API 中的 `Vulnerability` 类型包含一个 `cveEnrichment` 字段，当 `identifiers` 字段包含 CVE 标识符时，该字段会被填充。`cveEnrichment` 字段包含该漏洞的 CVE ID、EPSS 分数和 KEV 状态。EPSS 分数四舍五入到第二位小数。

例如，以下 GraphQL API 查询返回给定项目中的所有漏洞及其 CVE ID、EPSS 分数和 KEV 状态（`isKnownExploit`）。在 [GraphQL 资源管理器](../../../api/graphql/_index.md#interactive-graphql-explorer) 或任何其他 GraphQL 客户端中运行查询。

```graphql
{
  project(fullPath: "<full/path/to/project>") {
    vulnerabilities {
      nodes {
        severity
        identifiers {
          externalId
          externalType
        }
        cveEnrichment {
          epssScore
          isKnownExploit
          cve
        }
        reachability
      }
    }
  }
}
```

示例输出：

```json
{
  "data": {
    "project": {
      "vulnerabilities": {
        "nodes": [
          {
            "severity": "CRITICAL",
            "identifiers": [
              {
                "externalId": "CVE-2019-3859",
                "externalType": "cve"
              }
            ],
            "cveEnrichment": {
              "epssScore": 0.2,
              "isKnownExploit": false,
              "cve": "CVE-2019-3859"
            }
            "reachability": "UNKNOWN"
          },
          {
            "severity": "CRITICAL",
            "identifiers": [
              {
                "externalId": "CVE-2016-8735",
                "externalType": "cve"
              }
            ],
            "cveEnrichment": {
              "epssScore": 0.94,
              "isKnownExploit": true,
              "cve": "CVE-2016-8735"
            }
            "reachability": "IN_USE"
          },
        ]
      }
    }
  },
  "correlationId": "..."
}
```

<a id="vulnerability-prioritizer"></a>

## 漏洞优先级排序器

{{< details >}}

- 状态：实验

{{< /details >}}

使用 [漏洞优先级排序器 CI/CD 组件](https://jihulab.com/explore/catalog/components/vulnerability-prioritizer) 来帮助对项目中的漏洞（即 CVE）进行优先级排序。该组件在 `vulnerability-prioritizer` 作业的输出中输出一份优先级排序报告。

漏洞按以下顺序列出：

1. 已知被利用 (KEV) 的漏洞为最高优先级。
1. 更高的 EPSS 分数（接近 1）优先。
1. 严重性按 `Critical` 到 `Low` 排序。

只有由 [依赖项扫描](../dependency_scanning/_index.md) 和 [容器扫描](../container_scanning/_index.md) 检测到的漏洞才会包含在内，因为漏洞优先级排序器 CI/CD 组件需要仅在常见漏洞和暴露 (CVE) 记录中可用的数据。此外，仅显示 [已检测（**需要分类**）和已确认](_index.md#vulnerability-status-values) 的漏洞。

要将漏洞优先级排序器 CI/CD 组件添加到您项目的 CI/CD 流水线中，请查看 [漏洞优先级排序器文档](https://jihulab.com/components/vulnerability-prioritizer)。