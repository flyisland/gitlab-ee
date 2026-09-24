---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 性能调优与测试速度
---

执行动态分析测试的安全工具，例如 API 安全测试，通过向您正在运行的应用程序实例发送请求来执行测试。这些请求旨在测试您应用程序中可能存在的特定漏洞。动态分析测试的速度取决于以下因素：

- 极狐GitLab 工具每秒可以向您的应用程序发送多少请求
- 您的应用程序响应请求的速度有多快
- 必须发送多少请求才能测试应用程序
  - 您的 API 包含多少操作
  - 每个操作中有多少字段（考虑 JSON 体、标头、查询字符串、Cookie 等）

如果在遵循本性能指南的建议后 API 安全测试作业仍然耗时超过预期，请联系支持以获取进一步帮助。

<a id="diagnosing-performance-issues"></a>

## 诊断性能问题

解决性能问题的第一步是了解导致测试时间比预期慢的因素。一些常见的问题包括：

- API 安全测试运行在低 vCPU 的 Runner 上
- 应用程序部署在慢速/单 CPU 实例上，无法跟上测试负载
- 应用程序包含一个慢操作，影响整体测试速度（> 0.5 秒）
- 应用程序包含一个返回大量数据的操作（> 500K+）
- 应用程序包含大量操作（> 40）

<a id="the-application-contains-a-slow-operation-that-impacts-the-overall-test-speed-(>-1/2-second)"></a>

### 应用程序包含一个影响整体测试速度的慢操作（> 0.5 秒）

API 安全测试作业输出包含关于测试速度、操作响应时间和摘要信息的有用信息。以下示例输出展示了如何利用摘要输出来定位性能问题：

```shell
API 安全测试：从 assets/har-large-response/large_responses.har 加载了 10 个操作
API 安全测试：
API 安全测试：正在测试操作 [1/10]：'GET http://target:7777/api/large_response_json'。
API 安全测试： - 参数：（标头：4，查询：0，正文：0）
API 安全测试： - 请求正文大小：0 字节（0 字节）
API 安全测试：
API 安全测试：已完成对操作 'GET http://target:7777/api/large_response_json' 的测试。
API 安全测试： - 排除的参数：（标头：0，查询：0，正文：0）
API 安全测试： - 执行了 767 个请求
API 安全测试： - 平均响应正文大小：130 MB
API 安全测试： - 平均调用时间：2 秒 82.69 毫秒（2.082693 秒）
API 安全测试： - 完成时间：14 分钟 8 秒 788.36 毫秒（848.788358 秒）
```

作业控制台输出片段首先显示找到了多少个操作（10）。接下来，它通知测试已针对特定操作开始，并显示该操作的摘要。摘要显示 API 安全测试花费了 767 个请求才完全测试完这个操作及其相关字段。摘要还显示该操作的平均响应时间为 2 秒，总共耗时 14 分钟完成。

平均响应时间 2 秒是一个很好的初步指标，表明这个特定操作需要很长时间来测试。摘要还显示响应正文大小很大，这导致了较长的响应时间。每次请求的大部分响应时间都花在了传输响应正文数据上。

针对此问题，团队可能决定：

- 使用具有更多 vCPU 的 Runner，因为这允许 API 安全测试并行化执行的工作。这有助于缩短测试时间，但由于操作测试本身耗时较长，即使迁移到高 CPU 机器，将测试时间缩短到 10 分钟以下可能仍有困难。尽管较大的 Runner 成本更高，但如果作业执行速度更快，您也会为更少的计费分钟数付费。
- 从 API 安全测试中[排除此操作](#排除慢操作)。虽然这是最简单的方法，但其缺点是安全测试覆盖范围会出现缺口。
- 在功能分支 API 安全测试中排除此操作，但将其保留在默认分支测试中。[](#排除功能分支中的操作但不排除默认分支)
- [将 API 安全测试拆分为多个作业](#将测试拆分为多个作业)。

可能的解决方案是结合使用这些解决方案，以达到可接受的测试时间，假设您团队的要求是在 5-7 分钟范围内。

<a id="addressing-performance-issues"></a>

## 解决性能问题

以下各节记录了解决 API 安全测试性能问题的各种选项：

- [使用更大的 Runner](#使用更大的-runner)
- [排除慢操作](#排除慢操作)
- [将测试拆分为多个作业](#将测试拆分为多个作业)
- [排除功能分支中的操作，但不排除默认分支](#排除功能分支中的操作但不排除默认分支)

<a id="using-a-larger-runner"></a>

### 使用更大的 Runner

使用[更大的 Runner](../../../ci/runners/hosted_runners/linux.md#machine-types-available-for-linux---x86-64) 与 API 安全测试相结合，可以最容易地提高性能之一。下表显示了在基准测试 Java Spring Boot REST API 期间收集的统计数据。在此基准测试中，目标和 API 安全测试共享一个 Runner 实例。

| Linux 上的托管 Runner 标签           | 每秒请求数 |
|------------------------------------|-----------|
| `saas-linux-small-amd64`（默认） | 255 |
| `saas-linux-medium-amd64`          | 400 |

此表显示了如何通过增加 Runner 大小和 vCPU 数量来对测试速度/性能产生巨大影响。

以下是 API 安全测试的示例作业定义，它添加了一个 `tags` 部分，以使用 Linux 上的中型极狐GitLab 托管 Runner。该作业扩展了通过 API 安全测试模板包含的作业定义。

```yaml
api_security:
  tags:
  - saas-linux-medium-amd64
```

在 `gl-api-security-scanner.log` 文件中，您可以搜索字符串 `Starting work item processor` 来检查报告的最大 DOP（并行度）。最大 DOP 应大于或等于分配给 Runner 的 vCPU 数量。如果无法确定问题，请开票给支持以获取帮助。

示例日志条目：

`17:00:01.084 [INF] <Peach.Web.Core.Services.WebRunnerMachine> Starting work item processor with 4 max DOP`

<a id="excluding-slow-operations"></a>

### 排除慢操作

如果存在一两个慢操作，团队可能会决定跳过测试这些操作。排除操作通过使用 `APISEC_EXCLUDE_PATHS` 配置变量完成，[如本节所述。](configuration/customizing_analyzer_settings.md#exclude-paths)

此示例显示了一个返回大量数据的操作。该操作为 `GET http://target:7777/api/large_response_json`。要排除它，请提供 `APISEC_EXCLUDE_PATHS` 配置变量，其中包含操作 URL 的路径部分 `/api/large_response_json`。

要验证操作是否已排除，运行 API 安全测试作业并查看作业控制台输出。它会在测试结束时列出已包含和已排除的操作。

```yaml
api_security:
  variables:
    APISEC_EXCLUDE_PATHS: /api/large_response_json
```

> [!warning]
> 从测试中排除操作可能会让某些漏洞无法被检测到。

<a id="splitting-a-test-into-multiple-jobs"></a>

### 将测试拆分为多个作业

通过使用 [`APISEC_EXCLUDE_PATHS`](configuration/customizing_analyzer_settings.md#exclude-paths) 和 [`APISEC_EXCLUDE_URLS`](configuration/customizing_analyzer_settings.md#exclude-urls)，API 安全测试支持将测试拆分为多个作业。拆分测试时，一个好模式是禁用 `dast_api` 作业，并用两个具有标识名称的作业来替换它。此示例展示了两个作业。每个作业测试一个 API 版本，正如它们的名称所反映的那样。然而，此技术可以应用于任何情况，而不仅仅是 API 版本。

在 `APISEC_v1` 和 `APISEC_v2` 作业中使用的规则是从 [API 安全测试模板](https://jihulab.com/gitlab-cn/gitlab/blob/master/lib/gitlab/ci/templates/Security/API-Security.gitlab-ci.yml) 复制的。

```yaml
# 禁用主 dast_api 作业
api_security:
  rules:
  - if: $CI_COMMIT_BRANCH
    when: never

APISEC_v1:
  extends: dast_api
  variables:
    APISEC_EXCLUDE_PATHS: /api/v1/**
  rules:
  - if: $APISEC_DISABLED == 'true' || $APISEC_DISABLED == '1'
    when: never
  - if: $APISEC_DISABLED_FOR_DEFAULT_BRANCH == 'true' &&
        $CI_DEFAULT_BRANCH == $CI_COMMIT_REF_NAME
    when: never
  - if: $APISEC_DISABLED_FOR_DEFAULT_BRANCH == '1' &&
        $CI_DEFAULT_BRANCH == $CI_COMMIT_REF_NAME
    when: never
  - if: $CI_COMMIT_BRANCH &&
        $CI_GITLAB_FIPS_MODE == "true"
    variables:
      APISEC_IMAGE_SUFFIX: "-fips"
  - if: $CI_COMMIT_BRANCH

APISEC_v2:
  variables:
    APISEC_EXCLUDE_PATHS: /api/v2/**
  rules:
  - if: $APISEC_DISABLED == 'true' || $APISEC_DISABLED == '1'
    when: never
  - if: $APISEC_DISABLED_FOR_DEFAULT_BRANCH == 'true' &&
        $CI_DEFAULT_BRANCH == $CI_COMMIT_REF_NAME
    when: never
  - if: $APISEC_DISABLED_FOR_DEFAULT_BRANCH == '1' &&
        $CI_DEFAULT_BRANCH == $CI_COMMIT_REF_NAME
    when: never
  - if: $CI_COMMIT_BRANCH &&
        $CI_GITLAB_FIPS_MODE == "true"
    variables:
      APISEC_IMAGE_SUFFIX: "-fips"
  - if: $CI_COMMIT_BRANCH
```

<a id="excluding-operations-in-feature-branches-but-not-default-branch"></a>

### 排除功能分支中的操作，但不排除默认分支

如果存在一两个慢操作，团队可能会决定跳过测试这些操作，或在功能分支测试中排除它们，但将其包含在默认分支测试中。排除操作通过使用 `APISEC_EXCLUDE_PATHS` 配置变量完成，[如本节所述。](configuration/customizing_analyzer_settings.md#exclude-paths)

此示例显示了一个返回大量数据的操作。该操作为 `GET http://target:7777/api/large_response_json`。要排除它，请提供 `APISEC_EXCLUDE_PATHS` 配置变量，其中包含操作 URL 的路径部分 `/api/large_response_json`。该配置禁用了主 `dast_api` 作业，并创建了两个新作业 `APISEC_main` 和 `APISEC_branch`。`APISEC_branch` 设置用于排除这个耗时较长的操作，并仅在非默认分支（例如，功能分支）上运行。`APISEC_main` 分支设置为仅在默认分支（例如，`main`）上执行。`APISEC_branch` 作业运行速度更快，可实现快速开发周期，而仅在默认分支构建时运行的 `APISEC_main` 作业则需要更长的时间来运行。

要验证操作是否已排除，运行 API 安全测试作业并查看作业控制台输出。它会在测试结束时列出已包含和已排除的操作。

```yaml
# 禁用主作业，以便创建两个具有不同名称的作业
api_security:
  rules:
  - if: $CI_COMMIT_BRANCH
    when: never

# 功能分支工作的 API 安全测试，排除 /api/large_response_json
APISEC_branch:
  extends: dast_api
  variables:
    APISEC_EXCLUDE_PATHS: /api/large_response_json
  rules:
  - if: $APISEC_DISABLED == 'true' || $APISEC_DISABLED == '1'
    when: never
  - if: $APISEC_DISABLED_FOR_DEFAULT_BRANCH == 'true' &&
        $CI_DEFAULT_BRANCH == $CI_COMMIT_REF_NAME
    when: never
  - if: $APISEC_DISABLED_FOR_DEFAULT_BRANCH == '1' &&
        $CI_DEFAULT_BRANCH == $CI_COMMIT_REF_NAME
    when: never
  - if: $CI_COMMIT_BRANCH &&
        $CI_GITLAB_FIPS_MODE == "true"
    variables:
      APISEC_IMAGE_SUFFIX: "-fips"
  - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    when: never
  - if: $CI_COMMIT_BRANCH

# 默认分支的 API 安全测试（此处为 main）
# 包含耗时较长的操作
APISEC_main:
  extends: dast_api
  rules:
  - if: $APISEC_DISABLED == 'true' || $APISEC_DISABLED == '1'
    when: never
  - if: $APISEC_DISABLED_FOR_DEFAULT_BRANCH == 'true' &&
        $CI_DEFAULT_BRANCH == $CI_COMMIT_REF_NAME
    when: never
  - if: $APISEC_DISABLED_FOR_DEFAULT_BRANCH == '1' &&
        $CI_DEFAULT_BRANCH == $CI_COMMIT_REF_NAME
    when: never
  - if: $CI_COMMIT_BRANCH &&
        $CI_GITLAB_FIPS_MODE == "true"
    variables:
      APISEC_IMAGE_SUFFIX: "-fips"
  - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```