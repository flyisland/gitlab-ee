---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 性能调优与测试速度
---

执行 API 模糊测试的安全工具，例如 API 模糊测试，通过向您正在运行的应用程序实例发送请求来进行测试。请求会被模糊测试引擎变异，以触发应用程序中可能存在的意外行为。API 模糊测试的速度取决于以下因素：

- 极狐GitLab 工具可以向您的应用程序发送多少请求数/秒
- 您的应用程序对请求的响应速度有多快
- 必须发送多少请求来测试应用程序
  - 您的 API 包含多少个操作
  - 每个操作中有多少个字段（例如 JSON 主体、标头、查询字符串、Cookie 等）

如果在遵循本性能指南中的建议后，API 模糊测试作业仍然比预期花费更多的时间，请联系支持人员以获得进一步的帮助。

<a id="diagnosing-performance-issues"></a>

## 诊断性能问题

解决性能问题的第一步是了解导致测试时间比预期慢的原因。一些常见报告的问题有：

- API 模糊测试在一个低 vCPU 的 Runner 上运行
- 应用程序部署在速度慢/单 CPU 的实例上，无法跟上测试负载
- 应用程序包含一个影响整体测试速度的慢操作（> 0.5 秒）
- 应用程序包含一个返回大量数据的操作（> 500K+）
- 应用程序包含大量操作（> 40）

<a id="the-application-contains-a-slow-operation-that-impacts-the-overall-test-speed--12-second"></a>

### 应用程序包含一个影响整体测试速度的慢操作（> 0.5 秒）

API 模糊测试作业输出包含有关测试速度、操作响应时间和摘要信息的有用信息。使用以下示例输出来跟踪性能问题：

```shell
API 模糊测试：从以下位置加载了 10 个操作：assets/har-large-response/large_responses.har
API 模糊测试：
API 模糊测试：正在测试操作 [1/10]：'GET http://target:7777/api/large_response_json'。
API 模糊测试： - 参数：（标头：4，查询：0，主体：0）
API 模糊测试： - 请求主体大小：0 字节（0 字节）
API 模糊测试：
API 模糊测试：已完成测试操作 'GET http://target:7777/api/large_response_json'。
API 模糊测试： - 已排除参数：（标头：0，查询：0，主体：0）
API 模糊测试： - 已执行 767 个请求
API 模糊测试： - 平均响应主体大小：130 MB
API 模糊测试： - 平均调用时间：2 秒 82.69 毫秒（2.082693 秒）
API 模糊测试： - 完成时间：14 分 8 秒 788.36 毫秒（848.788358 秒）
```

作业控制台输出片段开头显示找到了多少个操作（10）。接下来是一条通知，表明测试已开始对特定操作进行，并且已完成操作摘要。摘要显示，API 模糊测试完全测试此操作及其相关字段需要 767 个请求。摘要还显示，此操作耗时 14 分钟才完成，平均响应时间为 2 秒。

平均响应时间为 2 秒，这是一个初步指标，表明这个特定操作需要很长时间来测试。您还可以看到响应主体大小较大，这是导致响应时间长的主要原因。每个请求的响应时间大部分都花在了传输响应主体数据上。

针对此问题，团队可能决定：

- 使用具有更多 vCPU 的 Runner，因为这允许 API 模糊测试并行化正在执行的工作。这有助于降低测试时间，但由于操作测试所需的时间，要在不迁移到高 CPU 机器的情况下将测试时间降至 10 分钟以下可能仍然有难度。虽然更大的 Runner 成本更高，但如果作业执行更快，您支付的分钟数也会更少。
- [从 API 模糊测试中排除此操作](#excluding-slow-operations)。虽然这是最简单的方法，但代价是安全测试覆盖出现盲区。
- [从功能分支的 API 模糊测试中排除该操作，但将其包含在默认分支测试中](#excluding-operations-in-feature-branches-but-not-default-branch)。
- [将 API 模糊测试拆分为多个作业](#splitting-a-test-into-multiple-jobs)。

假设您的团队对测试时间的要求在 5-7 分钟范围内，那么可能的解决方案是将这些方案组合使用，以达到可接受的测试时间。

<a id="addressing-performance-issues"></a>

## 解决性能问题

以下部分记录了解决 API 模糊测试性能问题的各种选项：

- [使用更大的 Runner](#using-a-larger-runner)
- [排除慢操作](#excluding-slow-operations)
- [将测试拆分为多个作业](#splitting-a-test-into-multiple-jobs)
- [在功能分支中排除操作，但不在默认分支中排除](#excluding-operations-in-feature-branches-but-not-default-branch)

<a id="using-a-larger-runner"></a>

### 使用更大的 Runner

通过为 API 模糊测试使用[更大的 Runner](../../../ci/runners/hosted_runners/linux.md#machine-types-available-for-linux---x86-64)，可以实现最简单的性能提升之一。下表显示了在对 Java Spring Boot REST API 进行基准测试期间收集的统计数据。在此基准测试中，目标和 API 模糊测试共享单个 Runner 实例。

| Linux 上的托管 Runner 标签             | 每秒请求数 |
|------------------------------------|-----------|
| `saas-linux-small-amd64`（默认）   | 255       |
| `saas-linux-medium-amd64`          | 400       |

此表显示了增加 Runner 的大小和 vCPU 数如何对测试速度/性能产生巨大影响。

以下是 API 模糊测试的一个作业定义示例，它添加了一个 `tags` 部分，以在 Linux 上使用中型极狐GitLab 托管的 Runner。该作业扩展了通过 API 模糊测试模板包含的作业定义。

```yaml
apifuzzer_fuzz:
  tags:
  - saas-linux-medium-amd64
```

在 `gl-api-security-scanner.log` 文件中，您可以搜索字符串 `Starting work item processor` 以检查报告的最大 DOP（并行度）。最大 DOP 应大于或等于分配给 Runner 的 vCPU 数。如果无法识别问题，请联系支持人员以获取帮助。

日志条目示例：

`17:00:01.084 [INF] <Peach.Web.Core.Services.WebRunnerMachine> 启动工作项处理器，最大 DOP 为 4`

<a id="excluding-slow-operations"></a>

### 排除慢操作

如果有一两个操作很慢，团队可能决定跳过测试这些操作。排除操作是通过 `FUZZAPI_EXCLUDE_PATHS` 配置[变量，如本节所述](configuration/customizing_analyzer_settings.md#exclude-paths)来完成的。

此示例显示了一个返回大量数据的操作。该操作是 `GET http://target:7777/api/large_response_json`。要排除它，请提供 `FUZZAPI_EXCLUDE_PATHS` 配置变量，并将操作 URL 的路径部分设为 `/api/large_response_json`。

要验证操作是否被排除，请运行 API 模糊测试作业并查看作业控制台输出。它会在测试结束时包含一个已包含和已排除操作的列表。

```yaml
apifuzzer_fuzz:
  variables:
    FUZZAPI_EXCLUDE_PATHS: /api/large_response_json
```

> [!warning] 从测试中排除操作可能会使某些漏洞未被发现。

<a id="splitting-a-test-into-multiple-jobs"></a>

### 将测试拆分为多个作业

API 模糊测试通过使用 [`FUZZAPI_EXCLUDE_PATHS`](configuration/customizing_analyzer_settings.md#exclude-paths) 和 [`FUZZAPI_EXCLUDE_URLS`](configuration/customizing_analyzer_settings.md#exclude-urls) 支持将测试拆分为多个作业。拆分测试时，一个好的模式是禁用 `apifuzzer_fuzz` 作业，并将其替换为两个具有标识名称的作业。此示例显示了两个作业。每个作业测试 API 的一个版本，正如其名称所反映的那样。但是，此技术可以应用于任何情况，而不仅仅是 API 的版本。

在 `apifuzzer_v1` 和 `apifuzzer_v2` 作业中使用的规则是从 [API 模糊测试模板](https://jihulab.com/gitlab-cn/gitlab/blob/master/lib/gitlab/ci/templates/Security/DAST-API.gitlab-ci.yml)复制而来。

```yaml
# 禁用主 apifuzzer_fuzz 作业
apifuzzer_fuzz:
  rules:
    - if: $CI_COMMIT_BRANCH
      when: never

apifuzzer_v1:
  extends: apifuzzer_fuzz
  variables:
    FUZZAPI_EXCLUDE_PATHS: /api/v1/**
  rules:
    - if: $API_FUZZING_DISABLED == 'true' || $API_FUZZING_DISABLED == '1'
      when: never
    - if: $API_FUZZING_DISABLED_FOR_DEFAULT_BRANCH == 'true' &&
            $CI_DEFAULT_BRANCH == $CI_COMMIT_REF_NAME
      when: never
    - if: $API_FUZZING_DISABLED_FOR_DEFAULT_BRANCH == '1' &&
            $CI_DEFAULT_BRANCH == $CI_COMMIT_REF_NAME
      when: never
    - if: $CI_COMMIT_BRANCH &&
          $CI_GITLAB_FIPS_MODE == "true"
      variables:
          FUZZAPI_IMAGE_SUFFIX: "-fips"
    - if: $CI_COMMIT_BRANCH

apifuzzer_v2:
  variables:
    FUZZAPI_EXCLUDE_PATHS: /api/v2/**
  rules:
    - if: $API_FUZZING_DISABLED == 'true' || $API_FUZZING_DISABLED == '1'
      when: never
    - if: $API_FUZZING_DISABLED_FOR_DEFAULT_BRANCH &&
            $CI_DEFAULT_BRANCH == $CI_COMMIT_REF_NAME
      when: never
    - if: $CI_COMMIT_BRANCH &&
          $CI_GITLAB_FIPS_MODE == "true"
      variables:
          FUZZAPI_IMAGE_SUFFIX: "-fips"
    - if: $CI_COMMIT_BRANCH
```

<a id="excluding-operations-in-feature-branches-but-not-default-branch"></a>

### 在功能分支中排除操作，但不在默认分支中排除

如果有一两个操作很慢，团队可能决定跳过测试这些操作，或者从功能分支测试中排除它们，但将其包含在默认分支测试中。排除操作是通过 `FUZZAPI_EXCLUDE_PATHS` 配置[变量，如本节所述](configuration/customizing_analyzer_settings.md#exclude-paths)来完成的。

此示例显示了一个返回大量数据的操作。该操作是 `GET http://target:7777/api/large_response_json`。要排除它，请提供 `FUZZAPI_EXCLUDE_PATHS` 配置变量，并将操作 URL 的路径部分设为 `/api/large_response_json`。该配置禁用了主 `apifuzzer_fuzz` 作业，并创建了两个新作业：`apifuzzer_main` 和 `apifuzzer_branch`。`apifuzzer_branch` 被设置为排除长时间运行的操作，并且仅在非默认分支（例如，功能分支）上运行。`apifuzzer_main` 分支被设置为仅在默认分支（本例中为 `main`）上执行。`apifuzzer_branch` 作业运行得更快，允许快速的开发周期，而仅在默认分支构建上运行的 `apifuzzer_main` 作业则需要更长的时间来运行。

要验证操作是否被排除，请运行 API 模糊测试作业并查看作业控制台输出。它会在测试结束时包含一个已包含和已排除操作的列表。

```yaml
# 禁用主作业，以便您可以创建两个具有不同名称的作业
apifuzzer_fuzz:
  rules:
    - if: $CI_COMMIT_BRANCH
      when: never

# 用于功能分支工作的 API 模糊测试，排除 /api/large_response_json
apifuzzer_branch:
  extends: apifuzzer_fuzz
  variables:
    FUZZAPI_EXCLUDE_PATHS: /api/large_response_json
  rules:
    - if: $API_FUZZING_DISABLED == 'true' || $API_FUZZING_DISABLED == '1'
      when: never
    - if: $API_FUZZING_DISABLED_FOR_DEFAULT_BRANCH &&
            $CI_DEFAULT_BRANCH == $CI_COMMIT_REF_NAME
      when: never
    - if: $CI_COMMIT_BRANCH &&
          $CI_GITLAB_FIPS_MODE == "true"
      variables:
          FUZZAPI_IMAGE_SUFFIX: "-fips"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      when: never
    - if: $CI_COMMIT_BRANCH

# 用于默认分支（本例中为 main）的 API 模糊测试
# 包括长时间运行的操作
apifuzzer_main:
  extends: apifuzzer_fuzz
  rules:
    - if: $API_FUZZING_DISABLED == 'true' || $API_FUZZING_DISABLED == '1'
      when: never
    - if: $API_FUZZING_DISABLED_FOR_DEFAULT_BRANCH &&
            $CI_DEFAULT_BRANCH == $CI_COMMIT_REF_NAME
      when: never
    - if: $CI_COMMIT_BRANCH &&
          $CI_GITLAB_FIPS_MODE == "true"
      variables:
          FUZZAPI_IMAGE_SUFFIX: "-fips"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```