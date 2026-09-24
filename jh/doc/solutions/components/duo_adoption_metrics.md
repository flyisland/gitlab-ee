---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
description: Measure and visualize GitLab Duo adoption and usage with a CI-based data collection pipeline, GraphQL API client, and Duo Analytics dashboard.
title: 极狐GitLab Duo 采用指标与分析
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="gitlab-duo-adoption-metrics-&-analytics"></a>

## 极狐GitLab Duo 采用指标与分析

本项目提供端到端的极狐GitLab Duo 用量分析，结合以下组件：

- **Duo GraphQL 数据采集** – 一个通用 Python 编排器，调用由极狐GitLab GraphQL API 客户端支持的 Duo 采集器脚本。
- **Duo 用量指标流水线** – 定期采集和聚合您极狐GitLab 群组的 Duo 用量数据的 CI 作业。
- **Duo 分析仪表板** – 一个托管在极狐GitLab Pages 上的仪表板，展示 Duo 采用率、使用强度和参与趋势。

<a id="getting-started"></a>

## 开始使用

您可以通过设置以下 **项目 CI/CD 变量** 来控制哪些分析流水线运行：

| 变量 | Duo 设置 | 描述 |
|----------|-----------|-------------|
| `ENABLE_DUO_METRICS` | `"true"` | 启用/禁用 Duo AI 指标流水线。 |
| `ENABLE_PROJECT_METRICS` | `"false"` | 当您只关心 Duo 采用率时，禁用传统的以项目为中心的指标。 |
| `DUO_TOKEN` | `TOKEN VALUE` | 用于 Duo 用量采集的个人访问令牌，需具备 `read_api` 和 `ai_features` 权限。 |
| `GROUP_PATH` | `example_group` | 要采集 Duo 指标的一级群组或子群组路径。 |

**快速入门步骤**

1. Fork 此仓库。
1. 前往 **项目设置 → CI/CD → 变量**。
1. 添加上述变量，并设置为适合您环境的值。
1. 配置按您偏好的时间间隔运行的 **调度流水线**。Duo 用量采集可能较重，因此建议 **每天运行一次**。
1. 手动运行调度流水线，或等待其调度时间。
1. 流水线完成后，在 **部署 → Pages** 下打开 **Pages** 应用，即可访问 Duo 分析仪表板。

<a id="gitlab-pages-deployment-(duo-metrics)"></a>

## 极狐GitLab Pages 部署（Duo 指标）

当启用 Duo 指标时，Pages 部署将在 Duo 流水线完成后自动进行：

- **Duo 指标流水线** → 部署到类似 `https://your-username.gitlab.io/project-name/duo-metrics/` 的 URL。
- **主导航页** → 位于 `https://your-username.gitlab.io/project-name/`，并提供指向可用仪表板的链接。

登录页面会自动检测存在的仪表板，并在 `ENABLE_DUO_METRICS="true"` 时显示 Duo 相关链接。

<a id="local-development-&-testing"></a>

## 本地开发与测试

要本地测试 Duo 分析（不通过 CI）：

1. 确保已安装 Python 和依赖项（例如，在仓库根目录下通过 `poetry install`）。
1. 在本地 `.env` 或 shell 会话中设置所需的环境变量：
   - `DUO_TOKEN`
   - `GROUP_PATH`
1. 运行通用编排器脚本来采集原始 Duo 用量数据：

```shell
python ai_raw_data_collection.py
```

1. 在本地 `public/` 或 `docs/` 文件夹下打开生成的指标文件（取决于您的设置），或按照解决方案组件项目文档中的描述，在本地运行仪表板。

<a id="duo-dashboard-features"></a>

## Duo 仪表板功能

Duo 分析仪表板重点关注极狐GitLab Duo 采用率和 AI 使用模式，包括：

- **许可证和采用率分析** – 跟踪有多少用户拥有 Duo 访问权限以及有多少用户实际使用。
- **代码建议分析** – 监控接受率、建议量以及 AI 辅助编码的编程语言分布。
- **Duo Chat 分析** – 查看聊天交互、用户群体和对话量。
- **用户参与度分析** – 按使用水平（不活跃、探索中、常规、重度）对用户进行细分。
- **语言和工作流性能** – 按编程语言或工作流分析 Duo 效能（例如，接受率、建议使用率）。

这些指标完全源自 Duo 相关信号；使用本仪表板不需要传统的项目指标。

<a id="duo-usage-data-collection-pipeline"></a>

## Duo 用量数据采集流水线

Duo 采用指标由 CI 驱动的数据采集流水线创建，该流水线依赖：

- **通用 Python 编排器**：`ai_raw_data_collection.py`
- 可复用的 **极狐GitLab GraphQL API 客户端**：`gitlab_graphql_api`

<a id="orchestrator-ai_raw_data_collection.py"></a>

### 编排器：`ai_raw_data_collection.py`

脚本 `ai_raw_data_collection.py` 负责：

- 读取环境/CI 变量（如 `GROUP_PATH`、`DUO_TOKEN` 及流水线配置）。
- 调用一个或多个 **采集器脚本**，这些脚本实现具体的 Duo 用量查询。
- 协调：
  - 跨群组和项目的分页。
  - Duo 用量事件的日期/时间窗口或采样策略。
  - 将结果归一化为一致的、便于分析的格式（例如，CSV/JSON）。
- 将采集到的数据写入 Duo 仪表板和下游聚合步骤所使用的位置。

它作为采集原始 Duo 用量数据的 **通用入口点**，因此您可以：

- 添加新的 Duo 相关采集器而无需更改 CI 配置。
- 通过环境变量或 CI 作业控制运行哪些采集器。

<a id="gitlab-graphql-api-client-&-collections"></a>

### 极狐GitLab GraphQL API 客户端与集合

所有 Duo 相关的 GraphQL 逻辑都封装在 `gitlab_graphql_api` Python 包中，特别是以下路径下：

- `gitlab_graphql_api > collections`

关键思想：

- **GraphQL 客户端抽象** – 一个中心客户端，处理针对极狐GitLab GraphQL 端点的认证、分页和错误处理。
- **集合类** – `collections` 模块提供更高级别的抽象（如“项目集合”或“用户集合”），这些抽象暴露了检索结构化数据的方法。Duo 采集器使用这些类来：
  - 获取给定 `GROUP_PATH` 的群组和项目。
  - 查询 Duo 用量字段和 AI 相关活动。
- **版本化 API 使用** – 随着极狐GitLab 改善或扩展 Duo 相关的 GraphQL 字段，相同的集合 API 可以扩展，而无需更改编排器。

Duo 采集器导入这些集合类，并定义它们需要的特定查询（例如，获取 AI 代码建议的数量、聊天使用事件或用户级采用统计信息）。

> **注意：** Duo 用量的 GraphQL 模式和字段名与集合类一起在 `gitlab_graphql_api > collections` 中记录。在扩展或自定义 Duo 指标所采集的数据时，请使用这些文档。

<a id="configuring-duo-data-collection"></a>

## 配置 Duo 数据采集

虽然流水线可以自定义，但典型的纯 Duo 设置需要：

- **最小化 CI 配置**：
  - 通过设置 `ENABLE_DUO_METRICS="true"` 启用 Duo 流水线。
  - 可选地，通过设置 `ENABLE_PROJECT_METRICS="false"` 禁用任何非 Duo 流水线。
- `ai_raw_data_collection.py` 使用的 **环境变量**：

| 变量 | 描述 | 示例 |
|----------|-------------|---------|
| `DUO_TOKEN` | 具有 `read_api` + `ai_features` 的令牌，用于 Duo GraphQL 查询。 | `glpat-xxxx` |
| `GROUP_PATH` | 应测量其 Duo 用量的群组或子群组。 | `"gitlab-org/your-group"` |
| `DUO_METRICS_OUTPUT_DIR` | 可选输出目录，用于存放原始 Duo 用量数据。 | `"duo-metrics/raw"` |

设置这些后，运行 `ai_raw_data_collection.py` 的 CI 作业将：

1. 使用 `gitlab_graphql_api` 集合查询指定群组的 Duo 用量数据。
1. 写入原始 Duo 用量制品，这些制品可用于：
   - 聚合为报告。
   - 直接由 Duo 仪表板加载。

<a id="extending-duo-metrics"></a>

## 扩展 Duo 指标

要添加或完善 Duo 采用指标：

1. **确定** 与新 Duo 信号相关的极狐GitLab GraphQL 字段（例如，额外的用量计数器或新的 AI 功能）。
1. **更新或添加** 一个采集器脚本，该脚本：
   - 使用 `gitlab_graphql_api > collections` 抽象。
   - 以与现有 Duo 采集器一致的格式写入数据。
1. **将采集器接入** `ai_raw_data_collection.py`（或通过环境变量控制）。
1. **更新仪表板** 以消费和可视化新字段，如果需要的话。

由于 GraphQL 访问和分页逻辑被封装在 `gitlab_graphql_api` 内部，扩展 Duo 指标通常意味着：

- 编排器的更改最小。
- 专注于建模新指标和更新仪表板。

<a id="resources"></a>

## 资源

- [极狐GitLab Duo 采用指标解决方案组件项目](https://gitlab.com/gitlab-com/product-accelerator/work-streams/packaging/gitlab-graphql-api)
- `gitlab_graphql_api` 包和 `collections` 模块（用于 Duo GraphQL 用量模式）