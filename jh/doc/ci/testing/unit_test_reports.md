---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 无需在作业日志中搜索，即可查看和调试单元测试结果。
title: 单元测试报告
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

单元测试报告直接在合并请求和流水线详情中显示测试结果，因此您无需在作业日志中搜索即可识别失败。

在以下场景使用单元测试报告：

- 在合并请求中立即查看测试失败。
- 比较分支之间的测试结果。
- 使用错误详情和截图调试失败的测试。
- 跟踪一段时间内的测试失败模式。

单元测试报告需要 JUnit XML 格式，且不影响作业状态。要使作业在测试失败时失败，您的作业的 [script](../yaml/_index.md#script) 必须以非零状态退出。

极狐GitLab Runner 会将您的 JUnit XML 格式的测试结果作为 [产物](../yaml/artifacts_reports.md#artifactsreportsjunit) 上传。
当您进入合并请求时，您的测试结果会在源分支（head）和目标分支（base）之间进行比较，以显示更改内容。

<a id="file-format-and-size-limits"></a>

## 文件格式和大小限制

单元测试报告必须使用 JUnit XML 格式，并满足特定要求，以确保正确解析和显示。

<a id="file-requirements"></a>

### 文件要求

您的测试报告文件必须：

- 使用 JUnit XML 格式，文件扩展名为 `.xml`。
- 单个文件小于 30 MB。
- 作业中所有 JUnit 文件的总大小小于 100 MB。

如果存在重复的测试名称，则仅使用第一个测试，其他同名测试将被忽略。

有关测试用例限制，请参阅 [每个单元测试报告的最大测试用例数](../../user/jihulab_com/_index.md#gitlab-cicd)。

<a id="junit-xml-format-specification"></a>

### JUnit XML 格式规范

极狐GitLab 解析 JUnit XML 元素和属性的子集，以在 UI 中显示测试结果。

| XML 元素  | XML 属性   | 描述 |
| ------------ | --------------- | ----------- |
| `testsuites` | `time`          | 所有测试套件的总执行时间。用于计算测试执行时间。 |
| `testsuite`  | `name`          | 测试套件名称。解析用于内部分组。 |
| `testsuite`  | `time`          | 单个测试套件的执行时间。用于计算测试执行时间。 |
| `testcase`   | `classname`     | 测试类或类别名称。在 UI 中显示为套件名称。 |
| `testcase`   | `name`          | 单个测试名称。 |
| `testcase`   | `file`          | 定义测试的文件路径。 |
| `testcase`   | `time`          | 测试执行时间（秒）。 |
| `failure`    | 元素内容 | 失败消息和堆栈跟踪。 |
| `error`      | 元素内容 | 错误消息和堆栈跟踪。 |
| `skipped`    | 元素内容 | 跳过测试的原因。 |
| `system-out` | 元素内容 | 系统输出和附件标签。仅从 `testcase` 元素解析。 |
| `system-err` | 元素内容 | 系统错误输出。仅从 `testcase` 元素解析。 |

以下元素和属性不会被解析：

- `testsuite` 属性（tests、failures、errors、timestamp）
- `testcase` 属性（assertions、line、status）
- `properties` 元素
- `system-out` 和 `system-err` 在 `testsuite` 级别

<a id="xml-structure-example"></a>

#### XML 结构示例

```xml
<testsuites>
  <testsuite name="Authentication Tests" tests="1" failures="1">
    <testcase classname="LoginTest" name="test_invalid_password" file="spec/auth_spec.rb" time="0.23">
      <failure>Expected authentication to fail</failure>
      <system-out>[[ATTACHMENT|screenshots/failure.png]]</system-out>
    </testcase>
  </testsuite>
</testsuites>
```

此 XML 在极狐GitLab 中显示为：

- 套件：`LoginTest`（来自 `testcase classname`）
- 名称：`test_invalid_password`（来自 `testcase name`）
- 文件：`spec/auth_spec.rb`（来自 `testcase file`）
- 时间：`0.23s`（来自 `testcase time`）
- 截图：可在测试详情对话框中查看（来自 `testcase system-out`）
- 不显示：“Authentication Tests”（来自 `testsuite name`）

<a id="test-result-types"></a>

## 测试结果类型

测试结果会在合并请求的源分支和目标分支之间进行比较，以显示更改内容：

- 新失败测试：在目标分支上通过但在您的分支上失败的测试。
- 新遇到错误：在目标分支上通过但在您的分支上出现错误的测试。
- 既有失败：在两个分支上都失败的测试。
- 已解决失败：在目标分支上失败但在您的分支上通过的测试。

如果无法比较分支，例如目标分支尚无数据，则仅显示您分支上的失败测试。

对于过去 14 天内在默认分支上失败的测试，您会看到类似 `Failed {n} time(s) in {default_branch} in the last 14 days` 的消息。
此计数包括已完成的流水线中的失败测试，但不包括[已阻止的流水线](../jobs/job_control.md#types-of-manual-jobs)。
对已阻止的流水线的支持已在 [议题 431265](https://gitlab.com/gitlab-org/gitlab/-/issues/431265) 中提出。

<a id="configure-unit-test-reports"></a>

## 配置单元测试报告

配置单元测试报告，以在合并请求和流水线中显示测试结果。

要配置单元测试报告：

1. 将您的测试作业配置为输出 JUnit XML 格式的测试报告。
   有关配置详情，请查阅您的测试框架文档。
1. 在您的 `.gitlab-ci.yml` 文件中，将
   [`artifacts:reports:junit`](../yaml/artifacts_reports.md#artifactsreportsjunit) 添加到您的测试作业中。
1. 指定 XML 测试报告文件的路径。`junit` 属性接受：

   - 单个文件名：`junit: report.xml`
   - 文件名模式：`junit: test-results/**/*.xml`
   - 文件名数组：`junit: [rspec-1.xml, rspec-2.xml, rspec-3.xml]`
   - 两者的组合：`junit: [rspec.xml, test-results/TEST-*.xml]`

   不支持目录（例如，`junit: test-results` 或 `junit: test-results/**`）。

1. 可选。要使报告文件可浏览，请使用 [`artifacts:paths`](../yaml/_index.md#artifactspaths) 包含它们。
1. 可选。要在作业失败时也上传报告，请使用 [`artifacts:when:always`](../yaml/_index.md#artifactswhen)。

Ruby 与 RSpec 的示例配置：

```yaml
ruby:
  stage: test
  script:
    - bundle install
    - bundle exec rspec --format progress --format RspecJunitFormatter --out rspec.xml
  artifacts:
    when: always
    paths:
      - rspec.xml
    reports:
      junit: rspec.xml
```

您可以在以下位置查看测试结果：

- 在测试作业完成后，位于流水线详情的 **测试** 选项卡中。
- 在流水线完成后，位于合并请求的 **测试摘要** 面板中。

<a id="view-test-results-in-merge-requests"></a>

## 在合并请求中查看测试结果

在合并请求中查看测试失败的详细信息。

**测试摘要** 面板显示测试结果的概览，包括失败和通过的测试数量。

![展开的测试摘要面板，显示一个失败的测试及“查看详情”链接](img/test_summary_panel_expanded_v18_1.png)

要查看测试失败详情：

1. 在合并请求中，转到 **测试摘要** 面板。
1. 要展开 **测试摘要** 面板，请选择 **显示详情** ({{< icon name="chevron-lg-down" >}})。
1. 选择失败测试旁边的 **查看详情**。

对话框显示测试名称、文件路径、执行时间、截图附件（如果已配置），以及错误输出。

要查看所有测试结果：

- 在 **测试摘要** 面板中，选择 **完整报告**
  以转到流水线详情中的 **测试** 选项卡。

<a id="copy-failed-test-names"></a>

### 复制失败的测试名称

复制测试名称以在本地重新运行进行调试。

先决条件：

- 您的 JUnit 报告必须包含失败测试的 `<file>` 属性。

要复制所有失败的测试名称：

- 在 **测试摘要** 面板中，选择 **复制失败的测试** ({{< icon name="copy-to-clipboard" >}})。

失败的测试将以空格分隔的字符串形式复制。

要复制单个失败的测试名称：

1. 要展开 **测试摘要** 面板，请选择 **显示详情** ({{< icon name="chevron-lg-down" >}})。
1. 选择要复制的测试旁边的 **查看详情**。
1. 在对话框中，选择 **复制测试名称以在本地重新运行** ({{< icon name="copy-to-clipboard" >}})。

测试名称将复制到您的剪贴板。

<a id="view-test-results-in-pipelines"></a>

## 在流水线中查看测试结果

在流水线详情中查看所有测试套件和用例，包括来自子流水线的结果。

要查看流水线测试结果：

1. 转到您的流水线详情页面。
1. 选择 **测试** 选项卡。
1. 选择任何测试套件以查看单个测试用例。

![测试结果显示 1671 个测试，总执行时间 1 分 11 秒，以及各个作业的执行时间。](img/pipelines_junit_test_report_v18_3.png)

您还可以使用 [流水线 API](../../api/pipelines.md#retrieve-a-test-report-for-a-pipeline) 检索测试报告。

<a id="test-timing-metrics"></a>

### 测试时间指标

测试结果显示不同的时间指标：

流水线时长 : 从流水线开始到完成所经过的时间。

测试执行时间 : 所有作业中运行所有测试所花费的总时间之和。

排队时间 : 作业等待可用 Runner 所花费的时间。

当作业并行运行时，累计测试执行时间可能超过流水线时长。

流水线时长显示您等待结果的时间，而测试执行时间显示使用的计算资源。

例如，一个在 81 分钟内完成的流水线，如果许多测试作业在多个 Runner 上并行运行，则可能显示 9 小时 10 分钟的测试执行时间。

<a id="add-screenshots-to-test-reports"></a>

## 向测试报告添加截图

向测试报告添加截图，以帮助调试测试失败。

要向测试报告添加截图：

1. 在您的 JUnit XML 文件中，添加附件标签，其中截图路径相对于 `$CI_PROJECT_DIR`：

   ```xml
   <testcase time="1.00" name="Test">
     <system-out>[[ATTACHMENT|/path/to/some/file]]</system-out>
   </testcase>
   ```

1. 在您的 `.gitlab-ci.yml` 文件中，将作业配置为上传截图作为产物：

   - 指定截图文件的路径。
   - 可选。使用 [`artifacts:when: always`](../yaml/_index.md#artifactswhen) 在测试失败时上传截图。

   例如：

   ```yaml
   ruby:
     stage: test
     script:
       - bundle install
       - bundle exec rspec --format progress --format RspecJunitFormatter --out rspec.xml
       - # Your test framework should save screenshots to a directory
     artifacts:
       when: always
       paths:
         - rspec.xml
         - screenshots/
       reports:
         junit: rspec.xml
   ```

1. 运行您的流水线。

当您在 **测试摘要** 面板中为失败的测试选择 **查看详情** 时，您可以在测试详情对话框中访问截图链接。

![失败的单元测试报告，包含测试详情和截图附件](img/unit_test_report_screenshot_v18_1.png)

<a id="troubleshooting"></a>

## 故障排除

<a id="test-report-appears-empty"></a>

### 测试报告显示为空

您可能会在合并请求中看到空的 **测试摘要** 面板。

此问题可能由以下原因导致：

- 报告产物已过期。
- JUnit 文件超过大小限制。

要解决此问题，请为报告产物设置更长的 [`expire_in`](../yaml/_index.md#artifactsexpire_in) 值，
或运行新的流水线以生成新报告。

如果 JUnit 文件超过大小限制，请确保：

- 单个 JUnit 文件小于 30 MB。
- 作业的所有 JUnit 文件总大小小于 100 MB。

对自定义限制的支持已在 [史诗 16374](https://gitlab.com/groups/gitlab-org/-/epics/16374) 中提出。

<a id="test-results-are-missing"></a>

### 测试结果缺失

您可能会在报告中看到比预期更少的测试结果。

这可能是由于 JUnit XML 文件中存在重复的测试名称。每个名称仅使用第一个测试，重复项将被忽略。

要解决此问题，请确保所有测试名称和类都是唯一的。

<a id="no-test-reports-appear-in-merge-requests"></a>

### 合并请求中不显示测试报告

您可能完全看不到合并请求中的 **测试摘要** 面板。

此问题可能发生在目标分支没有用于比较的测试数据时。

要解决此问题，请在目标分支上运行流水线以生成基线测试数据。

<a id="junit-xml-parsing-errors"></a>

### JUnit XML 解析错误

您可能会在流水线中看到作业名称旁边出现解析错误指示器。

这可能是由于 JUnit XML 文件包含格式错误或无效元素。

要解决此问题：

- 验证您的 JUnit XML 文件遵循标准格式。
- 检查所有 XML 元素是否正确闭合。
- 确保属性名称和值格式正确。

对于[分组作业](../jobs/_index.md#group-similar-jobs-together-in-pipeline-views)，
仅显示该组中的第一个解析错误。
