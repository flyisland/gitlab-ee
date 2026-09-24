---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
description: Guide for deploying GitLab Security Metrics and KPIs Solution, including vulnerability data export to Splunk, CI/CD pipeline setup, dashboard configuration, and best practices.
title: 安全指标与 KPI
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本文档描述了极狐GitLab 安全指标与 KPI 解决方案组件的安装、配置和用户指南。该安全解决方案组件提供可按业务单元、时间范围、漏洞严重性和安全类型查看的指标和 KPI。它可以通过 PDF 文档提供每月或每季度的安全态势快照。数据使用 Splunk 中的仪表板进行可视化。

![安全指标与 KPI](img/security_metrics_kpi_v17_9.png)

该解决方案使用 GraphQL API 从极狐GitLab 项目或群组导出漏洞数据，通过 HTTP 事件收集器 (HEC) 将其发送到 Splunk，并包含一个开箱即用的仪表板用于安全指标可视化。导出过程设计为按计划作为极狐GitLab CI/CD 流水线运行。

<a id="getting-started"></a>

## 入门

<a id="download-the-solution-component"></a>

### 下载解决方案组件

1. 从您的客户团队获取邀请码。
1. 使用邀请码从 [解决方案组件商店](https://cloud.gitlab-accelerator-marketplace.com) 下载解决方案组件。

<a id="set-up-the-solution-component-project"></a>

### 设置解决方案组件项目

1. 创建一个新的极狐GitLab 项目来托管此导出器。
1. 将提供的文件复制到您的项目中：
   - `export_vulns.py`
   - `send_to_splunk.py`
   - `requirements.txt`
   - `.gitlab-ci.yml`
1. 在项目设置中配置所需的 CI/CD 变量。
1. 设置流水线计划（例如，每天或每周）。

<a id="how-it-works"></a>

## 工作原理

该解决方案由两个主要组件组成：

1. 一个漏洞导出器，从极狐GitLab 安全仪表板获取数据
1. 一个 Splunk 采集器，处理导出的数据并将其发送到 Splunk HEC

流水线分两个阶段运行：

1. `extract`：获取漏洞并保存为 CSV
1. `ingest`：将漏洞数据发送到 Splunk

<a id="configuration"></a>

## 配置

<a id="required-cicd-variables"></a>

### 必需的 CI/CD 变量

| 变量 | 描述 | 示例值 |
|----------|-------------|---------------|
| `SCOPE` | 漏洞扫描的目标范围 | `group:security/appsec` 或 `security/my-project` |
| `GRAPHQL_API_TOKEN` | 具有 API 访问权限的极狐GitLab 个人访问令牌 | `glpat-XXXXXXXXXXXXXXXX` |
| `GRAPHQL_API_URL` | 极狐GitLab GraphQL API URL | `https://jihulab.com/api/graphql` |
| `SPLUNK_HEC_TOKEN` | Splunk HTTP 事件收集器令牌 | `11111111-2222-3333-4444-555555555555` |
| `SPLUNK_HEC_URL` | Splunk HEC 端点 URL | `https://splunk.company.com:8088/services/collector` |

<a id="optional-cicd-variables"></a>

### 可选的 CI/CD 变量

| 变量 | 描述 | 示例值 | 默认值 |
|----------|-------------|---------------|---------|
| `SEVERITY_FILTER` | 以逗号分隔的严重性级别列表 | `CRITICAL,HIGH,MEDIUM` | 所有严重性 |
| `VULN_TIME_WINDOW` | 漏洞收集的时间窗口 | `24h`、`7d` 或 `all` | `24h` |

<a id="scope-configuration"></a>

### 范围配置

`SCOPE` 变量确定要扫描的项目或群组：

- 对于项目：`mygroup/myproject`
- 对于群组：`group:mygroup/subgroup`
- 对于整个实例：`instance`

<a id="severity-filter-examples"></a>

### 严重性过滤示例

有效的严重性级别：

- `CRITICAL`
- `HIGH`
- `MEDIUM`
- `LOW`
- `UNKNOWN`

示例组合：

- `CRITICAL,HIGH`
- `CRITICAL,HIGH,MEDIUM`
- 留空以包含所有严重性

<a id="time-window-configuration"></a>

### 时间窗口配置

`VULN_TIME_WINDOW` 变量控制回溯查找漏洞的时间范围：

- 格式：`<数字><单位>`，其中：
  - `数字`：任意正整数
  - `单位`：`h` 表示小时，`d` 表示天
- 示例：
  - `24h`：最近 24 小时
  - `7h`：最近 7 小时
  - `15d`：最近 15 天
  - `30d`：最近 30 天
  - `all`：所有漏洞（首次运行时有用）

默认值：`24h`

流水线配置示例：

```yaml
# 12 小时窗口
variables:
  VULN_TIME_WINDOW: "12h"

# 3 天窗口
variables:
  VULN_TIME_WINDOW: "3d"

# 所有漏洞
variables:
  VULN_TIME_WINDOW: "all"
```

根据所选窗口安排流水线。例如：

- 对于 12h：每天安排两次
- 对于 3d：每 3 天安排一次
- 在安排时添加一些重叠，以确保不会遗漏漏洞

<a id="pipeline-setup"></a>

## 流水线设置

1. **首次运行**：

   - 设置 `VULN_TIME_WINDOW: "all"` 以收集所有历史漏洞
   - 运行一次流水线

1. **持续收集**：

   - 将 `VULN_TIME_WINDOW` 设置为所需窗口（`24h` 或 `7d`）
   - 设置流水线计划：
     - 对于 `24h`：每天安排
     - 对于 `7d`：每周安排

<a id="splunk-integration"></a>

## Splunk 集成

脚本将漏洞作为事件发送到 Splunk。

<a id="index-configuration"></a>

### 索引配置

1. 在 Splunk 中创建一个名为 `gitlab_vulns` 的新索引
1. 创建 HEC 令牌时：
   - 将默认 **索引** 设置为 `gitlab_vulns`（提供的 Splunk 仪表板的基础搜索中引用了此索引）
   - 确保令牌具有写入此索引的权限
   - 确保令牌具有允许将事件数据正确解析为 JSON 的 **sourcetype**

每个事件包括：

- 检测时间
- 漏洞标题和描述
- 严重性级别
- 扫描器信息
- 项目详情
- 项目和漏洞的 URL

<a id="dashboard-setup"></a>

## 仪表板设置

提供的仪表板通过以下可视化全面展示您的极狐GitLab 漏洞数据：

- 严重和高危漏洞的 P95 年龄指标（径向仪表）
- 老化分析显示严重和高危漏洞在不同时间段（0-30 天、31-90 天、91-180 天、180 天以上）的分布
- 前 10 个最常见的 CVE 及其出现次数
- 按项目路径和严重性划分的漏洞分布
- 所有指标都可以按业务单元和时间范围过滤

设置仪表板：

1. **业务单元映射**：
   1. 创建一个包含两列的 CSV 文件：

      ```shell
      project_url,business_unit
      ```

   1. 将每个极狐GitLab 项目 URL 映射到其对应的业务单元。
   1. 将文件作为查找表上传到 Splunk：
      1. 转到 **设置** > **查找** > **查找表文件**。
      1. 选择 **新建查找表文件**。
      1. 上传您的 CSV 文件。
      1. 将 **目标文件名** 设置为 `business_unit_mapping.csv`。
      1. 配置权限：
         1. 找到标记为 `<splunk_dir>/etc/apps/search/lookups/business_unit_mapping.csv` 的行。
         1. 选择 **权限**。
         1. 将权限设置为以下之一：
            - 设置为 **全局** 以实现实例范围访问。
            - 根据需要与特定应用或角色共享。
         1. 选择 **保存**。

1. **仪表板安装**：
   1. 保存提供的 `vuln_metrics_dashboard.xml` 文件。
   1. 在 Splunk 中：
      1. 转到搜索应用。
      1. 点击 **仪表板** > **创建新仪表板**。
      1. 在编辑视图中选择 **源代码**。
      1. 用 `vuln_metrics_dashboard.xml` 的内容替换默认 XML。
      1. 保存仪表板。

<a id="output-format"></a>

## 输出格式

中间 CSV 文件包含：

- `detectedAt`：检测时间戳
- `title`：漏洞标题
- `severity`：严重性级别
- `primaryIdentifier`：漏洞标识符
- `exporter`：扫描器名称
- `projectPath`：极狐GitLab 项目路径
- `projectUrl`：项目 URL
- `description`：漏洞描述
- `webUrl`：漏洞详情 URL

<a id="error-handling"></a>

## 错误处理

该解决方案包括：

- 带指数退避的速率限制处理
- Splunk 采集的批处理
- 适当的错误报告
- 超时处理
- UTF-8 编码支持

<a id="best-practices"></a>

## 最佳实践

1. **令牌权限**：

   - `GRAPHQL_API_TOKEN` 需要：
     - 对目标群组/项目的读取权限
     - 安全仪表板访问权限
   - `SPLUNK_HEC_TOKEN` 需要：
     - 向目标索引提交事件的权限

1. **计划频率**：

   - 使计划与 `VULN_TIME_WINDOW` 匹配
   - 包含重叠以防止遗漏漏洞
   - 考虑您组织的 SLA

1. **监控**：

   - 监控流水线成功/失败
   - 跟踪导出的漏洞数量
   - 监控 Splunk 采集成功

<a id="troubleshooting"></a>

## 故障排除

常见问题及解决方案：

1. **未导出漏洞**：

   - 验证 `SCOPE` 设置
   - 检查令牌权限
   - 验证安全仪表板访问权限

1. **Splunk 采集失败**：

   - 验证 HEC URL 和令牌
   - 检查网络连接
   - 验证索引权限

