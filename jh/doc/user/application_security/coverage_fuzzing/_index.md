---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 覆盖率引导的模糊测试（已弃用）
description: 覆盖率引导的模糊测试、随机输入和意外行为。
---

<!--- start_remove The following content will be removed on remove_date: '2026-08-15' -->

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能已在极狐GitLab 18.0 中[弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/517841)，
> 并计划在 19.0 中移除。这是一项破坏性变更。

<a id="getting-started"></a>

## 入门

覆盖率引导的模糊测试会向您的应用程序的插桩版本发送随机输入，以尝试引发意外行为。此类行为表明存在您应解决的错误。极狐GitLab 允许您将覆盖率引导的模糊测试添加到您的流水线中。这有助于您发现其他 QA 流程可能遗漏的错误和潜在安全问题。

您应该将模糊测试与 [极狐GitLab Secure](../_index.md) 中的其他安全扫描器以及您自己的测试流程结合使用。如果您使用 [极狐GitLab CI/CD](../../../ci/_index.md)，则可以将覆盖率引导的模糊测试作为 CI/CD 工作流的一部分运行。


<a id="confirm-status-of-coverage-guided-fuzz-testing"></a>

### 确认覆盖率引导的模糊测试的状态

要确认覆盖率引导的模糊测试的状态：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **覆盖率模糊测试** 部分，状态为：
   - **未配置**
   - **已启用**
   - 升级到极狐GitLab 旗舰版的提示。

<a id="enable-coverage-guided-fuzz-testing"></a>

### 启用覆盖率引导的模糊测试

要启用覆盖率引导的模糊测试，请编辑 `.gitlab-ci.yml`：

1. 将 `fuzz` 阶段添加到阶段列表中。
1. 如果您的应用程序不是用 Go 编写的，请使用匹配的模糊测试引擎[提供 Docker 镜像](../../../ci/yaml/_index.md#image)。例如：

   ```yaml
   image: python:latest
   ```

1. [包含](../../../ci/yaml/_index.md#includetemplate)极狐GitLab 安装中提供的
   [`Coverage-Fuzzing.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/Coverage-Fuzzing.gitlab-ci.yml)。

1. 自定义 `my_fuzz_target` 作业以满足您的要求。

<a id="example-extract-of-coverage-guided-fuzzing-configuration"></a>

### 覆盖率引导的模糊测试配置示例片段

```yaml
stages:
  - fuzz

include:
  - template: Coverage-Fuzzing.gitlab-ci.yml

my_fuzz_target:
  extends: .fuzz_base
  script:
    # Build your fuzz target binary in these steps, then run it with gitlab-cov-fuzz
    # See our example repos for how you could do this with any of our supported languages
    - ./gitlab-cov-fuzz run --regression=$REGRESSION -- <your fuzz target>
```

`Coverage-Fuzzing` 模板包含[隐藏作业](../../../ci/jobs/_index.md#hide-a-job)
`.fuzz_base`，您必须为每个模糊测试目标[扩展](../../../ci/yaml/_index.md#extends)它。每个模糊测试目标必须有一个单独的作业。例如，[go-fuzzing-example 项目](https://gitlab.com/gitlab-org/security-products/demos/coverage-fuzzing/go-fuzzing-example)包含一个为其单个模糊测试目标扩展 `.fuzz_base` 的作业。

隐藏作业 `.fuzz_base` 使用了几个您不得在自己的作业中覆盖的 YAML 键。如果您在自己的作业中包含这些键，则必须复制其原始内容：

- `before_script`
- `artifacts`
- `rules`

<a id="understanding-the-results"></a>

## 了解结果

<a id="output"></a>

### 输出

每个模糊测试步骤都会输出以下产物：

- `gl-coverage-fuzzing-report.json`：包含覆盖率引导的模糊测试及其结果详细信息的报告。
- `artifacts.zip`：此文件包含两个目录：
  - `corpus`：包含当前及所有先前作业生成的所有测试用例。
  - `crashes`：包含当前作业发现的所有崩溃事件以及先前作业中未修复的事件。

您可以从 CI/CD 流水线页面下载 JSON 报告文件。有关更多信息，请参阅[下载产物](../../../ci/jobs/job_artifacts.md#download-job-artifacts)。

<a id="corpus-registry"></a>

### 语料库注册表

语料库注册表是语料库的集合。项目注册表中的语料库可供该项目中的所有作业使用。项目级注册表是管理语料库的更有效方式，优于每个作业一个语料库的默认选项。

语料库注册表使用软件包仓库来存储项目的语料库。存储在注册表中的语料库是隐藏的，以确保数据完整性。

当您下载语料库时，文件名为 `artifacts.zip`，无论语料库最初上传时使用的文件名是什么。此文件仅包含语料库，这与您可以从 CI/CD 流水线下载的产物文件不同。此外，具有报告者或更高权限的项目成员可以使用直接下载链接下载语料库。

<a id="view-details-of-the-corpus-registry"></a>

#### 查看语料库注册表的详细信息

要查看语料库注册表的详细信息：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **覆盖率模糊测试** 部分，选择 **管理语料库**。

<a id="create-a-corpus-in-the-corpus-registry"></a>

#### 在语料库注册表中创建语料库

要在语料库注册表中创建语料库，请执行以下任一操作：

- 在流水线中创建语料库
- 上传现有的语料库文件

<a id="create-a-corpus-in-a-pipeline"></a>

##### 在流水线中创建语料库

要在流水线中创建语料库：

1. 在 `.gitlab-ci.yml` 文件中，编辑 `my_fuzz_target` 作业。
1. 设置以下变量：
   - 将 `COVFUZZ_USE_REGISTRY` 设置为 `true`。
   - 设置 `COVFUZZ_CORPUS_NAME` 以命名语料库。
   - 将 `COVFUZZ_GITLAB_TOKEN` 设置为个人访问令牌的值。

在 `my_fuzz_target` 作业运行后，语料库将存储在语料库注册表中，名称为 `COVFUZZ_CORPUS_NAME` 变量提供的名称。该语料库在每次流水线运行时更新。

<a id="upload-a-corpus-file"></a>

##### 上传语料库文件

要上传现有的语料库文件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **覆盖率模糊测试** 部分，选择 **管理语料库**。
1. 选择 **新建语料库**。
1. 填写字段。
1. 选择 **上传文件**。
1. 选择 **添加**。

您现在可以在 `.gitlab-ci.yml` 文件中引用该语料库。确保 `COVFUZZ_CORPUS_NAME` 变量中使用的值与上传的语料库文件的名称完全匹配。

<a id="use-a-corpus-stored-in-the-corpus-registry"></a>

### 使用存储在语料库注册表中的语料库

要使用存储在语料库注册表中的语料库，您必须通过其名称引用它。要确认相关语料库的名称，请查看语料库注册表的详细信息。

先决条件：

- 在项目中[启用覆盖率引导的模糊测试](#enable-coverage-guided-fuzz-testing)。

1. 在 `.gitlab-ci.yml` 文件中设置以下变量：
   - 将 `COVFUZZ_USE_REGISTRY` 设置为 `true`。
   - 将 `COVFUZZ_CORPUS_NAME` 设置为语料库的名称。
   - 将 `COVFUZZ_GITLAB_TOKEN` 设置为个人访问令牌的值。

<a id="coverage-guided-fuzz-testing-report"></a>

### 覆盖率引导的模糊测试报告

有关 `gl-coverage-fuzzing-report.json` 文件格式的详细信息，请阅读
[schema](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/blob/master/dist/coverage-fuzzing-report-format.json)。

覆盖率引导的模糊测试报告示例：

```json
{
  "version": "v1.0.8",
  "regression": false,
  "exit_code": -1,
  "vulnerabilities": [
    {
      "category": "coverage_fuzzing",
      "message": "Heap-buffer-overflow\nREAD 1",
      "description": "Heap-buffer-overflow\nREAD 1",
      "severity": "Critical",
      "stacktrace_snippet": "INFO: Seed: 3415817494\nINFO: Loaded 1 modules   (7 inline 8-bit counters): 7 [0x10eee2470, 0x10eee2477), \nINFO: Loaded 1 PC tables (7 PCs): 7 [0x10eee2478,0x10eee24e8), \nINFO:        5 files found in corpus\nINFO: -max_len is not provided; libFuzzer will not generate inputs larger than 4096 bytes\nINFO: seed corpus: files: 5 min: 1b max: 4b total: 14b rss: 26Mb\n#6\tINITED cov: 7 ft: 7 corp: 5/14b exec/s: 0 rss: 26Mb\n=================================================================\n==43405==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x602000001573 at pc 0x00010eea205a bp 0x7ffee0d5e090 sp 0x7ffee0d5e088\nREAD of size 1 at 0x602000001573 thread T0\n    #0 0x10eea2059 in FuzzMe(unsigned char const*, unsigned long) fuzz_me.cc:9\n    #1 0x10eea20ba in LLVMFuzzerTestOneInput fuzz_me.cc:13\n    #2 0x10eebe020 in fuzzer::Fuzzer::ExecuteCallback(unsigned char const*, unsigned long) FuzzerLoop.cpp:556\n    #3 0x10eebd765 in fuzzer::Fuzzer::RunOne(unsigned char const*, unsigned long, bool, fuzzer::InputInfo*, bool*) FuzzerLoop.cpp:470\n    #4 0x10eebf966 in fuzzer::Fuzzer::MutateAndTestOne() FuzzerLoop.cpp:698\n    #5 0x10eec0665 in fuzzer::Fuzzer::Loop(std::__1::vector\u003cfuzzer::SizedFile, fuzzer::fuzzer_allocator\u003cfuzzer::SizedFile\u003e \u003e\u0026) FuzzerLoop.cpp:830\n    #6 0x10eead0cd in fuzzer::FuzzerDriver(int*, char***, int (*)(unsigned char const*, unsigned long)) FuzzerDriver.cpp:829\n    #7 0x10eedaf82 in main FuzzerMain.cpp:19\n    #8 0x7fff684fecc8 in start+0x0 (libdyld.dylib:x86_64+0x1acc8)\n\n0x602000001573 is located 0 bytes to the right of 3-byte region [0x602000001570,0x602000001573)\nallocated by thread T0 here:\n    #0 0x10ef92cfd in wrap__Znam+0x7d (libclang_rt.asan_osx_dynamic.dylib:x86_64+0x50cfd)\n    #1 0x10eebdf31 in fuzzer::Fuzzer::ExecuteCallback(unsigned char const*, unsigned long) FuzzerLoop.cpp:541\n    #2 0x10eebd765 in fuzzer::Fuzzer::RunOne(unsigned char const*, unsigned long, bool, fuzzer::InputInfo*, bool*) FuzzerLoop.cpp:470\n    #3 0x10eebf966 in fuzzer::Fuzzer::MutateAndTestOne() FuzzerLoop.cpp:698\n    #4 0x10eec0665 in fuzzer::Fuzzer::Loop(std::__1::vector\u003cfuzzer::SizedFile, fuzzer::fuzzer_allocator\u003cfuzzer::SizedFile\u003e \u003e\u0026) FuzzerLoop.cpp:830\n    #5 0x10eead0cd in fuzzer::FuzzerDriver(int*, char***, int (*)(unsigned char const*, unsigned long)) FuzzerDriver.cpp:829\n    #6 0x10eedaf82 in main FuzzerMain.cpp:19\n    #7 0x7fff684fecc8 in start+0x0 (libdyld.dylib:x86_64+0x1acc8)\n\nSUMMARY: AddressSanitizer: heap-buffer-overflow fuzz_me.cc:9 in FuzzMe(unsigned char const*, unsigned long)\nShadow bytes around the buggy address:\n  0x1c0400000250: fa fa fd fa fa fa fd fa fa fa fd fa fa fa fd fa\n  0x1c0400000260: fa fa fd fa fa fa fd fa fa fa fd fa fa fa fd fa\n  0x1c0400000270: fa fa fd fa fa fa fd fa fa fa fd fa fa fa fd fa\n  0x1c0400000280: fa fa fd fa fa fa fd fa fa fa fd fa fa fa fd fa\n  0x1c0400000290: fa fa fd fa fa fa fd fa fa fa fd fa fa fa fd fa\n=\u003e0x1c04000002a0: fa fa fd fa fa fa fd fa fa fa fd fa fa fa[03]fa\n  0x1c04000002b0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa\n  0x1c04000002c0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa\n  0x1c04000002d0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa\n  0x1c04000002e0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa\n  0x1c04000002f0: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa\nShadow byte legend (one shadow byte represents 8 application bytes):\n  Addressable:           00\n  Partially addressable: 01 02 03 04 05 06 07 \n  Heap left redzone:       fa\n  Freed heap region:       fd\n  Stack left redzone:      f1\n  Stack mid redzone:       f2\n  Stack right redzone:     f3\n  Stack after return:      f5\n  Stack use after scope:   f8\n  Global redzone:          f9\n  Global init order:       f6\n  Poisoned by user:        f7\n  Container overflow:      fc\n  Array cookie:            ac\n  Intra object redzone:    bb\n  ASan internal:           fe\n  Left alloca redzone:     ca\n  Right alloca redzone:    cb\n  Shadow gap:              cc\n==43405==ABORTING\nMS: 1 EraseBytes-; base unit: de3a753d4f1def197604865d76dba888d6aefc71\n0x46,0x55,0x5a,\nFUZ\nartifact_prefix='./crashes/'; Test unit written to ./crashes/crash-0eb8e4ed029b774d80f2b66408203801cb982a60\nBase64: RlVa\nstat::number_of_executed_units: 122\nstat::average_exec_per_sec:     0\nstat::new_units_added:          0\nstat::slowest_unit_time_sec:    0\nstat::peak_rss_mb:              28",
      "scanner": {
        "id": "libFuzzer",
        "name": "libFuzzer"
      },
      "location": {
        "crash_address": "0x602000001573",
        "crash_state": "FuzzMe\nstart\nstart+0x0\n\n",
        "crash_type": "Heap-buffer-overflow\nREAD 1"
      },
      "tool": "libFuzzer"
    }
  ]
}
```

<a id="interacting-with-the-vulnerabilities"></a>

### 与漏洞交互

发现漏洞后，您可以[解决它](../vulnerabilities/_index.md)。
合并请求的 **报告** 选项卡列出了该漏洞，并包含一个用于下载模糊测试产物的按钮。通过选择检测到的漏洞之一，您可以查看其详细信息。

您还可以从[安全仪表板](../security_dashboard/_index.md)查看漏洞，
该仪表板显示了您的群组、项目和流水线中所有安全漏洞的概览。

选择漏洞会打开一个模态框，提供有关该漏洞的附加信息：

- 状态：漏洞的状态。与任何类型的漏洞一样，覆盖率模糊测试漏洞可以是已检测、已确认、已忽略或已解决。
- 项目：漏洞所在的项目。
- 崩溃类型：代码中崩溃或弱点的类型。这通常映射到 [CWE](https://cwe.mitre.org/)。
- 崩溃状态：堆栈跟踪的规范化版本，包含崩溃的最后三个函数（不含随机地址）。
- 堆栈跟踪片段：堆栈跟踪的最后几行，显示有关崩溃的详细信息。
- 标识符：漏洞的标识符。这映射到 [CVE](https://cve.mitre.org/) 或 [CWE](https://cwe.mitre.org/)。
- 严重性：漏洞的严重性。可以是严重、高、中、低、信息或未知。
- 扫描器：检测到漏洞的扫描器（例如，覆盖率模糊测试）。
- 扫描器提供程序：执行扫描的引擎。对于覆盖率模糊测试，可以是[支持的模糊测试引擎和语言](#supported-fuzzing-engines-and-languages)中列出的任何引擎。

<a id="optimization"></a>

## 优化

使用以下自定义选项来优化适合您项目的覆盖率引导的模糊测试。

<a id="available-cicd-variables"></a>

### 可用的 CI/CD 变量

使用以下变量在您的 CI/CD 流水线中配置覆盖率引导的模糊测试。

> [!warning]
> 对极狐GitLab 安全扫描工具的所有自定义都应在合并请求中进行测试，然后再将这些更改合并到默认分支。否则可能会产生意外结果，包括大量误报。

| CI/CD 变量            | 描述                                                                     |
|---------------------------|---------------------------------------------------------------------------------|
| `COVFUZZ_ADDITIONAL_ARGS` | 传递给 `gitlab-cov-fuzz` 的参数。用于自定义底层模糊测试引擎的行为。请阅读模糊测试引擎的文档以获取完整的参数列表。 |
| `COVFUZZ_BRANCH`          | 要运行长时间运行的模糊测试作业的分支。在所有其他分支上，仅运行模糊测试回归测试。默认值：代码仓库的默认分支。 |
| `COVFUZZ_SEED_CORPUS`     | 种子语料库目录的路径。默认值：空。 |
| `COVFUZZ_URL_PREFIX`      | 为离线环境克隆的 `gitlab-cov-fuzz` 代码仓库的路径。仅在使用离线环境时才应更改此值。默认值：`https://gitlab.com/gitlab-org/security-products/analyzers/gitlab-cov-fuzz/-/raw`。 |
| `COVFUZZ_USE_REGISTRY`    | 设置为 `true` 以将语料库存储在极狐GitLab 语料库注册表中。如果此变量设置为 `true`，则需要变量 `COVFUZZ_CORPUS_NAME` 和 `COVFUZZ_GITLAB_TOKEN`。默认值：`false`。 |
| `COVFUZZ_CORPUS_NAME`     | 要在作业中使用的语料库的名称。 |
| `COVFUZZ_GITLAB_TOKEN`    | 配置了具有 API 读写访问权限的[个人访问令牌](../../profile/personal_access_tokens.md#create-a-personal-access-token)或[项目访问令牌](../../project/settings/project_access_tokens.md#create-a-project-access-token)的环境变量。 |

<a id="seed-corpus"></a>

#### 种子语料库

[种子语料库](../terminology/_index.md#seed-corpus)中的文件必须手动更新。它们不会被覆盖率引导的模糊测试作业更新或覆盖。

<a id="coverage-guided-fuzz-testing-process"></a>

### 覆盖率引导的模糊测试流程

模糊测试流程：

1. 编译目标应用程序。
1. 使用 `gitlab-cov-fuzz` 工具运行插桩后的应用程序。
1. 解析并分析模糊器输出的异常信息。
1. 从以下位置下载[语料库](../terminology/_index.md#corpus)：
   - 之前的流水线。
   - 如果 `COVFUZZ_USE_REGISTRY` 设置为 `true`，则从[语料库注册表](#corpus-registry)下载。
1. 从之前的流水线下载崩溃事件。
1. 将解析后的崩溃事件和数据输出到 `gl-coverage-fuzzing-report.json` 文件。
1. 更新语料库，方式如下：
   - 在作业的流水线中。
   - 如果 `COVFUZZ_USE_REGISTRY` 设置为 `true`，则在语料库注册表中更新。

覆盖率引导的模糊测试的结果可在 CI/CD 流水线中获取。

<a id="roll-out"></a>

## 推广

当您对在单个项目中使用覆盖率引导的模糊测试感到满意后，您可以利用以下高级功能，包括在离线环境中启用测试。

<a id="supported-fuzzing-engines-and-languages"></a>

### 支持的模糊测试引擎和语言

您可以使用以下模糊测试引擎来测试指定的语言。

| 语言                                    | 模糊测试引擎                                                                                       | 示例                                                                                                                         |
|---------------------------------------------|------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|
| C/C++                                       | [libFuzzer](https://llvm.org/docs/LibFuzzer.html)                                                    | [c-cpp-example](https://gitlab.com/gitlab-org/security-products/demos/coverage-fuzzing/c-cpp-fuzzing-example)                   |
| Go                                          | [go-fuzz（支持 libFuzzer）](https://github.com/dvyukov/go-fuzz)                                    | [go-fuzzing-example](https://gitlab.com/gitlab-org/security-products/demos/coverage-fuzzing/go-fuzzing-example)                 |
| Swift                                       | [libFuzzer](https://github.com/swiftlang/swift/blob/main/docs/libFuzzerIntegration.md)                 | [swift-fuzzing-example](https://gitlab.com/gitlab-org/security-products/demos/coverage-fuzzing/swift-fuzzing-example)           |
| Rust                                        | [cargo-fuzz（支持 libFuzzer）](https://github.com/rust-fuzz/cargo-fuzz)                            | [rust-fuzzing-example](https://gitlab.com/gitlab-org/security-products/demos/coverage-fuzzing/rust-fuzzing-example)             |
| Java（仅限 Maven）<sup>1</sup>               | [Javafuzz](https://gitlab.com/gitlab-org/security-products/analyzers/fuzzers/javafuzz)（推荐） | [javafuzz-fuzzing-example](https://gitlab.com/gitlab-org/security-products/demos/coverage-fuzzing/javafuzz-fuzzing-example)     |
| Java                                        | [JQF](https://github.com/rohanpadhye/JQF)（不推荐）                                            | [jqf-fuzzing-example](https://gitlab.com/gitlab-org/security-products/demos/coverage-fuzzing/java-fuzzing-example)              |
| JavaScript                                  | [`jsfuzz`](https://gitlab.com/gitlab-org/security-products/analyzers/fuzzers/jsfuzz)                 | [jsfuzz-fuzzing-example](https://gitlab.com/gitlab-org/security-products/demos/coverage-fuzzing/jsfuzz-fuzzing-example)         |
| Python                                      | [`pythonfuzz`](https://gitlab.com/gitlab-org/security-products/analyzers/fuzzers/pythonfuzz)         | [pythonfuzz-fuzzing-example](https://gitlab.com/gitlab-org/security-products/demos/coverage-fuzzing/pythonfuzz-fuzzing-example) |
| AFL（任何可在 AFL 之上运行的语言） | [AFL](https://lcamtuf.coredump.cx/afl/)                                                              | [afl-fuzzing-example](https://gitlab.com/gitlab-org/security-products/demos/coverage-fuzzing/afl-fuzzing-example)               |

1. 对 Gradle 的支持计划在[议题 409764](https://gitlab.com/gitlab-org/gitlab/-/issues/409764)中实现。

<a id="duration-of-coverage-guided-fuzz-testing"></a>

### 覆盖率引导的模糊测试的持续时间

覆盖率引导的模糊测试可用的持续时间有：

- 10 分钟持续时间（默认）：推荐用于默认分支。
- 60 分钟持续时间：推荐用于开发分支和合并请求。更长的持续时间提供更大的覆盖率。
  在 `COVFUZZ_ADDITIONAL_ARGS` 变量中设置值 `--regression=true`。

有关完整示例，请阅读 [Go 覆盖率引导的模糊测试示例](https://gitlab.com/gitlab-org/security-products/demos/coverage-fuzzing/go-fuzzing-example/-/blob/master/.gitlab-ci.yml)。

<a id="continuous-coverage-guided-fuzz-testing"></a>

#### 持续覆盖率引导的模糊测试

也可以在不阻塞您的主流水线的情况下，更长时间地运行覆盖率引导的模糊测试作业。此配置使用极狐GitLab
[父子流水线](../../../ci/pipelines/downstream_pipelines.md#parent-child-pipelines)。

此场景中建议的工作流是在主分支或开发分支上运行长时间运行的异步模糊测试作业，并在所有其他分支和合并请求上运行短时间的同步模糊测试作业。这平衡了快速完成每次提交的流水线的需求，同时也为模糊器提供了大量时间来充分探索和测试应用程序。长时间运行的模糊测试作业通常是覆盖率引导的模糊器在您的代码库中发现更深层错误所必需的。

以下是此工作流的 `.gitlab-ci.yml` 文件片段。有关完整示例，请参阅 [Go 模糊测试示例的代码仓库](https://gitlab.com/gitlab-org/security-products/demos/coverage-fuzzing/go-fuzzing-example/-/tree/continuous_fuzzing)：

```yaml

sync_fuzzing:
  variables:
    COVFUZZ_ADDITIONAL_ARGS: '-max_total_time=300'
  trigger:
    include: .covfuzz-ci.yml
    strategy: depend
  rules:
    - if: $CI_COMMIT_BRANCH != 'continuous_fuzzing' && $CI_PIPELINE_SOURCE != 'merge_request_event'

async_fuzzing:
  variables:
    COVFUZZ_ADDITIONAL_ARGS: '-max_total_time=3600'
  trigger:
    include: .covfuzz-ci.yml
  rules:
    - if: $CI_COMMIT_BRANCH == 'continuous_fuzzing' && $CI_PIPELINE_SOURCE != 'merge_request_event'
```

这将创建两个作业：

1. `sync_fuzzing`：以阻塞配置在短时间内运行您的所有模糊测试目标。这可以找到简单的错误，并让您确信您的合并请求不会引入新错误或导致旧错误再次出现。
1. `async_fuzzing`：在您的分支上运行，在不阻塞您的开发周期和合并请求的情况下发现代码中的深层错误。

`covfuzz-ci.yml` 与[原始同步示例](https://gitlab.com/gitlab-org/security-products/demos/coverage-fuzzing/go-fuzzing-example#running-go-fuzz-from-ci)中的相同。

<a id="fips-enabled-binary"></a>

### 启用 FIPS 的二进制文件

覆盖率模糊测试二进制文件在 Linux x86 上使用 `golang-fips` 编译，并使用 OpenSSL 作为加密后端。有关更多详细信息，请参阅极狐GitLab 中 Go 的 FIPS 合规性。

<a id="offline-environment"></a>

### 离线环境

要在离线环境中使用覆盖率模糊测试：

1. 将 [`gitlab-cov-fuzz`](https://gitlab.com/gitlab-org/security-products/analyzers/gitlab-cov-fuzz)
   克隆到您的离线极狐GitLab 实例可以访问的私有代码仓库中。

1. 对于每个模糊测试步骤，将 `COVFUZZ_URL_PREFIX` 设置为 `${NEW_URL_GITLAB_COV_FUZ}/-/raw`，其中
   `NEW_URL_GITLAB_COV_FUZ` 是您在第一步中设置的私有 `gitlab-cov-fuzz` 克隆的 URL。

<a id="troubleshooting"></a>

## 故障排除

<a id="error-unable-to-extract-corpus-folder-from-artifacts-zip-file"></a>

### 错误 `Unable to extract corpus folder from artifacts zip file`

如果您看到此错误消息，并且 `COVFUZZ_USE_REGISTRY` 设置为 `true`，请确保上传的语料库文件解压到一个名为 `corpus` 的文件夹中。

<a id="error-400-bad-request---duplicate-package-is-not-allowed"></a>

### 错误 `400 Bad request - Duplicate package is not allowed`

如果您在将 `COVFUZZ_USE_REGISTRY` 设置为 `true` 运行模糊测试作业时看到此错误消息，请确保允许重复。有关更多详细信息，请参阅
[重复的通用软件包](../../packages/generic_packages/_index.md#disable-publishing-duplicate-package-names)。

<!--- end_remove -->
