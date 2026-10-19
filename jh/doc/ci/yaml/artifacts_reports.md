---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于测试结果、安全扫描、代码质量检查和性能指标的产物报告类型。
title: CI/CD 产物报告类型
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 [`artifacts:reports`](_index.md#artifactsreports) 可以：

- 收集作业中包含的模板所生成的测试报告、代码质量报告、安全报告和其他产物。
- 其中一些报告用于在以下位置显示信息：
  - 合并请求。
  - 流水线视图。
  - [安全仪表板](../../user/application_security/security_dashboard/_index.md)。

为 `artifacts: reports` 创建的产物始终会上传，无论作业结果如何（成功或失败）。

> [!note]
> 对于安全报告类型（`sarif`、`sast`、`dast`、`container_scanning`、
> `dependency_scanning`、`secret_detection`、`api_fuzzing` 和 `coverage_fuzzing`），
> 产物始终会上传，但只有在生成该产物的作业成功时才会采集发现项。失败的作业（包括
> 设置了 `allow_failure: true`的作业）不会产生被采集的发现项。更多信息，请参阅
> [扫描器退出码](../../user/application_security/detect/sarif.md#scanner-exit-codes)。

您可以使用 [`artifacts:expire_in`](_index.md#artifactsexpire_in) 为产物设置过期时间，该设置会覆盖实例的[默认设置](../../administration/settings/continuous_integration.md#set-default-artifacts-expiration)。JihuLab.com 可能有[不同的默认产物过期值](../../user/jihulab_com/_index.md#gitlab-cicd)。

某些 `artifacts:reports` 类型可以由同一流水线中的多个作业生成，并供每个作业的合并请求或流水线功能使用。

要浏览报告输出文件，请确保在作业定义中包含 [`artifacts:paths`](_index.md#artifactspaths) 关键字。

> [!note]
> 不支持在父流水线中使用[子流水线的产物](_index.md#needspipelinejob)来合并报告。
> 此功能的支持已在[史诗 8205](https://gitlab.com/groups/gitlab-org/-/epics/8205)中提出。

<a id="artifactsreportsaccessibility"></a>

## `artifacts:reports:accessibility`

`accessibility` 报告使用 [pa11y](https://pa11y.org/) 报告合并请求中引入的变更对无障碍性的影响。

极狐GitLab 可以在合并请求的[无障碍性小组件](../testing/accessibility_testing.md#accessibility-merge-request-widget)中显示一个或多个报告的结果。

更多信息，请参阅[无障碍性测试](../testing/accessibility_testing.md)。

<a id="artifactsreportsannotations"></a>

## `artifacts:reports:annotations`

`annotations` 报告用于将辅助数据附加到作业。

注解报告是一个包含注解部分的 JSON 文件。每个注解部分可以具有任意所需的名称，并且可以包含任意数量的相同或不同类型的注解。

如果报告路径匹配多个文件，则每个部分名称在所有匹配文件中必须唯一。如果两个文件包含同名的部分，则产物上传会失败。

每个注解都是一个单独的键（注解类型），其中包含该注解数据的子键。

<a id="annotation-types"></a>

### 注解类型

<a id="external_link"></a>

#### `external_link`

可以将 `external_link` 注解附加到作业，以在作业输出页面添加链接。`external_link` 注解的值是一个对象，包含以下键：

| 键     | 描述 |
|---------|-------------|
| `label` | 与该链接关联的、人类可读的标签。 |
| `url`   | 该链接指向的 URL。 |

<a id="example-report"></a>

### 示例报告

以下是作业注解报告可能的样子示例：

```json
{
  "my_annotation_section_1": [
    {
      "external_link": {
        "label": "URL 1",
        "url": "https://url1.example.com/"
      }
    },
    {
      "external_link": {
        "label": "URL 2",
        "url": "https://url2.example.com/"
      }
    }
  ]
}
```

<a id="artifactsreportsapi_fuzzing"></a>

## `artifacts:reports:api_fuzzing`

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

`api_fuzzing` 报告将 [API 模糊测试缺陷](../../user/application_security/api_fuzzing/_index.md)收集为产物。

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的[安全扫描报告](../../user/project/merge_requests/reports.md#security-scan-report)。
- [项目漏洞报告](../../user/application_security/vulnerability_report/_index.md)。
- 流水线的[**安全**标签页](../../user/application_security/detect/security_scanning_results.md)。
- [安全仪表板](../../user/application_security/api_fuzzing/configuration/enabling_the_analyzer.md#security-dashboard)。

<a id="artifactsreportsbrowser_performance"></a>

## `artifacts:reports:browser_performance`

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

`browser_performance` 报告将浏览器性能测试指标收集为产物。该产物是由
[GitLab sitespeed.io 插件](https://gitlab.com/gitlab-org/gl-performance)生成的 JSON 文件。

极狐GitLab 会在合并请求中显示结果。更多信息，请参阅[浏览器性能测试](../testing/browser_performance_testing.md)。

极狐GitLab 无法显示多个 `browser_performance` 报告的合并结果。

<a id="artifactsreportscoverage_report"></a>

## `artifacts:reports:coverage_report`

使用 `coverage_report` 收集 Cobertura 或 JaCoCo 格式的覆盖率报告。
流水线完成后，极狐GitLab 会解析该报告，并在合并请求差异中显示逐行覆盖率注解。

> [!note]
> 此关键字仅生成差异注解。它不会在合并请求小组件中显示覆盖率百分比，
> 也不会填充覆盖率历史图表。要显示覆盖率百分比，
> 请单独配置 [`coverage`](_index.md#coverage) 关键字。

更多信息，请参阅：

- [Cobertura 覆盖率可视化](../testing/code_coverage/cobertura.md)
- [JaCoCo 覆盖率可视化](../testing/code_coverage/jacoco.md)

```yaml
artifacts:
  reports:
    coverage_report:
      coverage_format: cobertura
      path: coverage/cobertura-coverage.xml
```

您可以生成多个报告，并使用[通配符](../jobs/job_artifacts.md#with-wildcards)收集它们。极狐GitLab 会将结果合并为单个报告。

来自子流水线的覆盖率报告会显示在合并请求差异注解中，但不会与父流水线共享。

<a id="artifactsreportscodequality"></a>

## `artifacts:reports:codequality`

`codequality` 报告收集[代码质量问题](../testing/code_quality.md)。收集到的代码质量报告会作为产物上传到极狐GitLab。

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的[代码质量报告](../../user/project/merge_requests/reports.md#code-quality-report)。
- 合并请求的[差异注解](../testing/code_quality.md#merge-request-changes-view)。
- [完整报告](../testing/metrics_reports.md)。

[`artifacts:expire_in`](_index.md#artifactsexpire_in)的值设置为 `1 week`。

<a id="artifactsreportscontainer_scanning"></a>

## `artifacts:reports:container_scanning`

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

`container_scanning` 报告收集[容器扫描漏洞](../../user/application_security/container_scanning/_index.md)。收集到的容器扫描报告会作为产物上传到极狐GitLab。

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的[容器扫描小组件](../../user/application_security/container_scanning/_index.md)。
- 流水线的[**安全**标签页](../../user/application_security/detect/security_scanning_results.md)。
- [安全仪表板](../../user/application_security/security_dashboard/_index.md)。
- [项目漏洞报告](../../user/application_security/vulnerability_report/_index.md)。

<a id="artifactsreportscoverage_fuzzing"></a>

## `artifacts:reports:coverage_fuzzing`

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

`coverage_fuzzing` 报告收集[覆盖率模糊测试缺陷](../../user/application_security/coverage_fuzzing/_index.md)。收集到的覆盖率模糊测试报告会作为产物上传到极狐GitLab。极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的[安全扫描报告](../../user/project/merge_requests/reports.md#security-scan-report)。
- 流水线的[**安全**标签页](../../user/application_security/detect/security_scanning_results.md)。
- [项目漏洞报告](../../user/application_security/vulnerability_report/_index.md)。
- [安全仪表板](../../user/application_security/security_dashboard/_index.md)。

<a id="artifactsreportscyclonedx"></a>

## `artifacts:reports:cyclonedx`

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

此报告是一份软件物料清单，按照 [CycloneDX](https://cyclonedx.org/docs/1.4/json/) 协议格式描述项目的组件。

您可以为每个作业指定多个 CycloneDX 报告。这些报告可以以文件名列表、文件名模式或两者兼有的形式提供：

- 文件名模式（`cyclonedx: gl-sbom-*.json`、`junit: test-results/**/*.json`）。
- 文件名数组（`cyclonedx: [gl-sbom-npm-npm.cdx.json, gl-sbom-bundler-gem.cdx.json]`）。
- 两者的组合（`cyclonedx: [gl-sbom-*.json, my-cyclonedx.json]`）。
- 不支持目录（`cyclonedx: test-results`、`cyclonedx: test-results/**`）。

以下示例展示了一个公开 CycloneDX 产物的作业：

```yaml
artifacts:
  reports:
    cyclonedx:
      - gl-sbom-npm-npm.cdx.json
      - gl-sbom-bundler-gem.cdx.json
```

<a id="artifactsreportsdast"></a>

## `artifacts:reports:dast`

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

`dast` 报告收集 [DAST 漏洞](../../user/application_security/dast/_index.md)。收集到的 DAST 报告会作为产物上传到极狐GitLab。

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的[安全扫描报告](../../user/project/merge_requests/reports.md#security-scan-report)。
- 流水线的[**安全**标签页](../../user/application_security/detect/security_scanning_results.md)。
- [项目漏洞报告](../../user/application_security/vulnerability_report/_index.md)。
- [安全仪表板](../../user/application_security/security_dashboard/_index.md)。

<a id="artifactsreportsdependency_scanning"></a>

## `artifacts:reports:dependency_scanning`

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

`dependency_scanning` 报告收集[依赖项扫描漏洞](../../user/application_security/dependency_scanning/_index.md)。收集到的依赖项扫描报告会作为产物上传到极狐GitLab。

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的[依赖项扫描小组件](../../user/application_security/dependency_scanning/_index.md)。
- 流水线的[**安全**标签页](../../user/application_security/detect/security_scanning_results.md)。
- [安全仪表板](../../user/application_security/security_dashboard/_index.md)。
- [项目漏洞报告](../../user/application_security/vulnerability_report/_index.md)。
- [依赖项列表](../../user/application_security/dependency_list/_index.md)。

<a id="artifactsreportsdotenv"></a>

## `artifacts:reports:dotenv`

`dotenv` 报告从文件中收集环境变量，并将它们作为 CI/CD 变量提供给流水线中的后续作业使用。

更多信息，请参阅 [dotenv 变量](../variables/dotenv_variables.md)。

<a id="artifactsreportsjunit"></a>

## `artifacts:reports:junit`

`junit` 报告收集 [JUnit 报告格式 XML 文件](https://www.ibm.com/docs/en/developer-for-zos/16.0.x?topic=formats-junit-xml-format)。收集到的单元测试报告会作为产物上传到极狐GitLab。尽管 JUnit 最初是用 Java 开发的，但它有许多针对其他语言（如 JavaScript、Python 和 Ruby）的第三方移植版本。

更多详细信息和示例，请参阅[单元测试报告](../testing/unit_test_reports.md)。以下示例展示了如何从 Ruby RSpec 测试中收集 JUnit XML 报告：

```yaml
rspec:
  stage: test
  script:
    - bundle install
    - rspec --format RspecJunitFormatter --out rspec.xml
  artifacts:
    reports:
      junit: rspec.xml
```

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的[**测试摘要**面板](../testing/unit_test_reports.md#view-test-results-in-merge-requests)。
- [流水线的**测试**标签页](../testing/unit_test_reports.md#view-test-results-in-pipelines)。

某些 JUnit 工具会导出到多个 XML 文件。您可以在单个作业中指定多个测试报告路径，以将它们连接成单个文件。请使用以下任一方式：

- 文件名模式（`junit: rspec-*.xml`、`junit: test-results/**/*.xml`）。
- 文件名数组（`junit: [rspec-1.xml, rspec-2.xml, rspec-3.xml]`）。
- 两者的组合（`junit: [rspec.xml, test-results/TEST-*.xml]`）。
- 不支持目录（`junit: test-results`、`junit: test-results/**`）。

<a id="artifactsreportsload_performance"></a>

## `artifacts:reports:load_performance`

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

`load_performance` 报告收集[负载性能测试指标](../testing/load_performance_testing.md)并作为产物上传。

结果显示在合并请求的[负载测试小组件](../testing/load_performance_testing.md#load-performance-results-in-merge-requests)中。不支持合并多个 `load_performance` 报告的结果。

<a id="artifactsreportsmetrics"></a>

## `artifacts:reports:metrics`

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

`metrics` 报告收集[指标](../testing/metrics_reports.md)。收集到的指标报告会作为产物上传到极狐GitLab。

极狐GitLab 可以在合并请求的[指标报告小组件](../testing/metrics_reports.md)中显示一个或多个报告的结果。

<a id="artifactsreportsrequirements"></a>

## `artifacts:reports:requirements`

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

`requirements` 报告收集 `requirements.json` 文件。收集到的需求报告会作为产物上传到极狐GitLab，现有的[需求](../../user/project/requirements/_index.md)会标记为“已满足”。

极狐GitLab 可以在
[项目需求](../../user/project/requirements/_index.md#view-a-requirement)中显示一个或多个报告的结果。

<a id="artifactsreportssarif"></a>

## `artifacts:reports:sarif`

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

`sarif` 报告收集来自输出 [SARIF 2.1.0](https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html) 格式的工具的安全发现项。收集到的 SARIF 报告会作为产物上传到极狐GitLab。

使用此报告类型可以从任何兼容 SARIF 的扫描器（例如 Semgrep、ESLint 安全插件或 GitHub Advanced Security 工具）
采集发现项。

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 流水线的[**安全**标签页](../../user/application_security/detect/security_scanning_results.md)。
- [安全仪表板](../../user/application_security/security_dashboard/_index.md)。
- [项目漏洞报告](../../user/application_security/vulnerability_report/_index.md)。

> [!note]
> 无论作业状态如何，产物始终会上传，但只有在作业成功时
> 才会采集发现项。

**示例**：

```yaml
semgrep:
  image: returntocorp/semgrep
  script:
    - semgrep ci --sarif --output gl-sarif-report.sarif
  artifacts:
    reports:
      sarif: gl-sarif-report.sarif
```

有关行为、限制、字段映射和推断报告类型的详细信息，请参阅 [SARIF 报告](../../user/application_security/detect/sarif.md)。

<a id="artifactsreportssast"></a>

## `artifacts:reports:sast`

`sast` 报告收集 [SAST 漏洞](../../user/application_security/sast/_index.md)。收集到的 SAST 报告会作为产物上传到极狐GitLab。

更多信息，请参阅：

- [查看 SAST 结果](../../user/application_security/sast/_index.md#understanding-the-results)
- [SAST 输出](../../user/application_security/sast/_index.md#download-a-sast-report)

<a id="artifactsreportssecret_detection"></a>

## `artifacts:reports:secret_detection`

`secret-detection` 报告收集[检测到的密钥](../../user/application_security/secret_detection/pipeline/_index.md)。收集到的密钥检测报告会上传到极狐GitLab。

极狐GitLab 可以在以下位置显示一个或多个报告的结果：

- 合并请求的[安全扫描报告](../../user/project/merge_requests/reports.md#security-scan-report)。
- [流水线安全标签页](../../user/application_security/detect/security_scanning_results.md)。
- [安全仪表板](../../user/application_security/security_dashboard/_index.md)。

<a id="artifactsreportsterraform"></a>

## `artifacts:reports:terraform`

`terraform` 报告获取 OpenTofu `tfplan.json` 文件。[需要使用 JQ 处理以移除凭据](../../user/infrastructure/iac/mr_integration.md#configure-opentofu-report-artifacts)。收集到的 OpenTofu 计划报告会作为产物上传到极狐GitLab。

极狐GitLab 可以在合并请求的 [OpenTofu 小组件](../../user/infrastructure/iac/mr_integration.md#output-opentofu-plan-information-into-a-merge-request)中显示一个或多个报告的结果。

更多信息，请参阅[将 `tofu plan` 信息输出到合并请求](../../user/infrastructure/iac/mr_integration.md)。
