---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在合并请求中跟踪覆盖率百分比并可视化逐行测试覆盖率。
title: 代码覆盖率
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用覆盖率报告和覆盖率可视化来跟踪代码覆盖率。这两种机制读取不同的输入、产生不同的输出，并且不共享配置。配置其中一种并不会启用另一种。

覆盖率报告会在合并请求小部件、流水线列表和分析图表中显示百分比。覆盖率可视化会在合并请求差异中显示逐行注释。要同时获得两者，请同时配置这两个关键字（[`coverage`](../../yaml/_index.md#coverage) 和 [`artifacts:reports:coverage_report`](../../yaml/artifacts_reports.md#artifactsreportscoverage_report)）。

<a id="where-coverage-appears"></a>

## 覆盖率显示位置

使用此表可找到您所需覆盖率输出对应的关键字。除差异注释外，所有输出都由 `coverage` 关键字提供支持。

| 界面                                                 | 查找位置                             | 关键字                             | Tier |
| ------------------------------------------------------- | -------------------------------------------- | ----------------------------------- | ---- |
| 覆盖率百分比以及与目标分支的差值 | 合并请求小部件                                    | `coverage`                          | 基础版 |
| 逐行注释                                | 合并请求差异，仅限变更的文件                  | `artifacts:reports:coverage_report` | 基础版 |
| 每个作业的覆盖率百分比                             | 流水线和作业列表                       | `coverage`                          | 基础版 |
| 覆盖率徽章                                          | 您嵌入徽章 URL 的任何位置             | `coverage`                          | 基础版 |
| 覆盖率历史和 CSV 导出                         | **分析 > 仓库分析**（项目） | `coverage`                          | 基础版 |
| 群组覆盖率历史和 CSV 导出                   | **分析 > 仓库分析**（群组）   | `coverage`                          | 专业版和旗舰版 |
| `Coverage-Check` 审批规则                          | **设置 > 合并请求**                | `coverage`                          | 专业版和旗舰版 |

<a id="choose-an-approach"></a>

## 选择一种方式

这两种机制读取不同的输入，行为也不同。

|                 | 覆盖率报告                               | 覆盖率可视化                    |
|-----------------|--------------------------------------------------|-------------------------------------------|
| 关键字         | `coverage`                                       | `artifacts:reports:coverage_report`       |
| 输入           | 与作业日志匹配的正则表达式 | Cobertura 或 JaCoCo XML 产物        |
| 产生        | 每个作业一个数字                          | 对变更文件的逐行注释     |
| 可用时间       | 作业完成时                           | 整个流水线完成后        |
| 子流水线 | 不记录                                     | 记录                                  |
| 失败方式        | 不显示百分比                            | 静默跳过注释             |

由于这两种机制读取不同的输入，它们可能不一致。合并请求小部件中的百分比是您的正则表达式在日志中匹配到的内容。注释来自 XML 报告。如果您的测试命令基于不同的基准计算这些内容，小部件和差异所描述的就是不同的东西。请从同一次测试运行中生成两者。

<a id="coverage-reporting"></a>

## 覆盖率报告

覆盖率报告会从测试工具的作业日志输出中提取百分比。您在 `coverage` 关键字中定义正则表达式。极狐GitLab 会扫描作业日志，提取第一个匹配的数字并存储它。

极狐GitLab 会在以下位置显示此值：

- 合并请求小部件，包括与目标分支相比的差值。
- 流水线作业列表。
- **分析** > **仓库分析**中的按项目和按群组覆盖率历史图表。
- 覆盖率徽章。
- `Coverage-Check` 审批规则（专业版和旗舰版），可在覆盖率下降时要求审批。

有关设置说明，请参阅[配置覆盖率报告](coverage_reporting.md)。

<a id="coverage-visualization"></a>

## 覆盖率可视化

覆盖率可视化会解析测试作业作为 CI/CD 产物上传的 Cobertura 或 JaCoCo XML 报告。流水线完成后，极狐GitLab 会在后台处理该报告，并在合并请求差异中为行添加注释。

注释仅出现在合并请求差异中发生变更的文件上。未在合并请求中变更的文件不会添加注释，即使报告包含这些文件的覆盖率数据也是如此。

有关设置说明，请参阅[配置覆盖率可视化](coverage_visualization.md)。
