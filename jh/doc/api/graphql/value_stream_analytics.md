---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 检索价值流分析数据
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 GraphQL API 从您配置的价值流和价值流阶段请求指标。
如果您想将价值流分析数据导出到外部系统或用于报告，这些数据会很有用。

以下指标可用：

- 阶段中已完成事项的数量。计数上限为 10,000 个事项。
- 阶段中已完成事项的中位时长。
- 阶段中已完成事项的平均时长。

<a id="retrieve-configured-value-streams"></a>

## 检索已配置的价值流

先决条件：

- 您必须具有报告者、开发者、维护者或所有者角色。

首先，您必须确定要在报告中使用的价值流。

要为群组请求已配置的价值流，请运行：

```graphql
group(fullPath: "your-group-path") {
  valueStreams {
    nodes {
      id
      name
    }
  }
}
```

同样，要为项目请求指标，请运行：

```graphql
project(fullPath: "your-project-path") {
  valueStreams {
    nodes {
      id
      name
    }
  }
}
```

<a id="retrieve-metrics-for-a-stage"></a>

## 检索阶段的指标

要为价值流的阶段请求指标，请运行：

```graphql
group(fullPath: "your-group-path") {
  valueStreams(id: "your-value-stream-id") {
    nodes {
      stages {
        id
        name
      }
    }
  }
}
```

根据您希望如何使用数据，您可以请求价值流中某个特定阶段的指标，或请求所有阶段的指标。

> [!note]
> 对于某些安装，请求所有阶段的指标可能太慢。
> 推荐的方法是逐个阶段请求指标。

请求阶段的指标：

```graphql
group(fullPath: "your-group-path") {
  valueStreams(id: "your-value-stream-id") {
    nodes {
      stages(id: "your-stage-id") {
        id
        name
        metrics(timeframe: { start: "2024-03-01", end: "2024-03-31" }) {
          average {
            value
            unit
          }
          median {
            value
            unit
          }
          count {
            value
            unit
          }
        }
      }
    }
  }
}
```

> [!note]
> 您应始终以指定的时间范围请求指标。
> 支持的最长时间范围为 180 天。

`metrics` 节点支持其他筛选选项：

- 指派人用户名
- 作者用户名
- 标记名称
- 里程碑标题

带筛选条件的请求示例：

```graphql
group(fullPath: "your-group-path") {
  valueStreams(id: "your-value-stream-id") {
    nodes {
      stages(id: "your-stage-id") {
        id
        name
        metrics(
          labelNames: ["backend"],
          milestoneTitle: "17.0",
          timeframe: { start: "2024-03-01", end: "2024-03-31" }
        ) {
          average {
            value
            unit
          }
          median {
            value
            unit
          }
          count {
            value
            unit
          }
        }
      }
    }
  }
}
```

<a id="best-practices"></a>

## 最佳实践

- 为准确了解当前状态，请尽可能在接近时间范围结束时请求指标。
- 对于定期报告，您可以创建脚本并使用[计划流水线](../../ci/pipelines/schedules.md)功能及时导出数据。
- 调用 API 时，您会从数据库获取当前数据。随着时间的推移，由于数据库中底层数据的变化，相同的指标可能会发生变化。例如，从群组中移动或移除项目可能会影响群组级别的指标。
- 重新请求之前期间的指标，并将其与之前收集的指标进行比较，可以显示数据中的偏差，这有助于发现和解释变化的趋势。
