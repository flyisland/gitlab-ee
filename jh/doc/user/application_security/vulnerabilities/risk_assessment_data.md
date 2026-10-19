---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 漏洞风险评估数据
---

使用漏洞风险数据帮助评估对您的环境可能造成的影响。

- 严重性：每个漏洞都会分配一个标准化的极狐GitLab 严重性值。
- 对于 [常见漏洞与暴露 (CVE)](https://www.cve.org/) 目录中的漏洞，
  可以通过[漏洞详情](_index.md)页面或使用 GraphQL 查询获取以下数据：
  - 被利用的可能性：[漏洞利用预测评分系统 (EPSS)](https://www.first.org/epss/) 分数。
  - 是否存在已知利用：[已知被利用漏洞 (KEV)](https://www.cisa.gov/known-exploited-vulnerabilities-catalog) 状态。

使用这些数据帮助确定修复和缓解措施的优先级。例如，一个中等严重性但 EPSS 分数较高的漏洞，可能比一个高严重性但 EPSS 分数较低的漏洞需要更早采取缓解措施。

<a id="epss"></a>

## EPSS

EPSS 分数用于估计 CVE 目录中的某个漏洞在未来 30 天内被利用的可能性。EPSS 为每个 CVE 分配一个介于 0 到 1 之间的分数（相当于 0% 到 100%）。

<a id="kev"></a>

## KEV

KEV 目录列出了已知曾被利用的漏洞。您应优先修复 KEV 目录中的漏洞，而不是其他漏洞。使用这些漏洞的攻击已经发生，攻击者很可能已经掌握其利用方法。

<a id="reachability"></a>

## 可达性

可达性显示您的应用程序是否导入了存在漏洞的软件包。您的代码直接交互的软件包中的漏洞，比未使用的依赖项中的漏洞风险更高。请优先修复可达的漏洞，因为它们代表攻击者可能利用的真实暴露点。

更多详情，请参见[静态可达性](../dependency_scanning/static_reachability.md)。

<a id="query-risk-assessment-data"></a>

## 查询风险评估数据

使用 GraphQL API 查询项目中漏洞的严重性、EPSS 和 KEV 值。

GraphQL API 中的 `Vulnerability` 类型有一个 `cveEnrichment` 字段，当 `identifiers` 字段包含 CVE 标识符时，该字段会被填充。`cveEnrichment` 字段包含该漏洞的 CVE ID、EPSS 分数和 KEV 状态。EPSS 分数会四舍五入到小数点后第二位。

例如，以下 GraphQL API 查询会返回给定项目中的所有漏洞及其 CVE ID、EPSS 分数和 KEV 状态（`isKnownExploit`）。请在 [GraphQL 浏览器](../../../api/graphql/_index.md#interactive-graphql-explorer)或任何其他 GraphQL 客户端中运行该查询。

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

- Status: 实验

{{< /details >}}

使用[漏洞优先级排序器 CI/CD 组件](https://gitlab.com/explore/catalog/components/vulnerability-prioritizer)帮助确定项目漏洞（即 CVE）的优先级。该组件会在 `vulnerability-prioritizer` 作业的输出中生成优先级排序报告。

漏洞按以下顺序列出：

1. 存在已知利用（KEV）的漏洞优先级最高。
1. EPSS 分数较高（更接近 1）的漏洞优先。
1. 严重性从 `Critical` 到 `Low` 排序。

仅包含由[依赖扫描](../dependency_scanning/_index.md)和[容器扫描](../container_scanning/_index.md)检测到的漏洞，因为漏洞优先级排序器 CI/CD 组件需要仅在常见漏洞与暴露 (CVE) 记录中提供的数据。此外，仅显示[已检测（**需要分类**）和已确认](_index.md#vulnerability-status-values)的漏洞。

要将漏洞优先级排序器 CI/CD 组件添加到项目的 CI/CD 流水线，请参见[漏洞优先级排序器文档](https://gitlab.com/components/vulnerability-prioritizer)。
