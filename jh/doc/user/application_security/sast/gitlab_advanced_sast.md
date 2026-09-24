---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: GitLab Advanced SAST uses cross-file, cross-function taint analysis to detect complex vulnerabilities with high accuracy.
title: 极狐GitLab Advanced SAST
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 GitLab 17.1 中作为 [实验功能](../../../policy/development_stages_support.md) 为 Python 引入。
- 在 17.2 中为 Go 和 Java 添加了支持。
- [变更] 在 GitLab 17.2 中从实验功能变为 beta。
- 在 17.3 中为 JavaScript、TypeScript 和 C# 添加了支持。
- [GA] 在 GitLab 17.3 中。
- 在 GitLab 17.4 中为 Java Server Pages (JSP) 添加了支持。
- 在 GitLab 18.1 中为 PHP [添加] 了支持。
- 在 GitLab 18.6 中为 C/C++ [添加] 了支持。

{{< /history >}}

极狐GitLab Advanced SAST 是一个静态应用程序安全测试 (SAST) 分析器，它使用跨函数、跨文件的污点分析来检测复杂漏洞，相比传统 SAST，误报更少。

极狐GitLab Advanced SAST 比标准的基于 Semgrep 的 SAST 分析器执行更深入的分析。这种全面的方法可以提高准确性并减少误报，但需要更多的计算资源和更长的扫描时间。

## 功能

<a id="features"></a>

| 功能 | SAST | Advanced SAST |
|------|------|---------------|
| 分析深度 | 检测复杂漏洞的能力有限；分析仅限于单个文件，并且（有少数例外）仅限单个函数。 | 使用跨文件、跨函数的污点分析检测复杂漏洞。 |
| 准确性 | 由于上下文有限，更可能产生误报。 | 通过跨文件、跨函数的污点分析专注于真正可被利用的漏洞，从而减少误报。 |
| 修复指导 | 漏洞发现按行号标识。 | 详细的[代码流视图](#code-flow)展示了漏洞如何通过程序流动，有助于更快的修复。 |
| 与极狐GitLab Duo 漏洞解释和漏洞解决方案配合使用 | 是。 | 是。 |
| 语言覆盖范围 | [更广泛](_index.md#supported-languages-and-frameworks)。 | [更有限](#supported-languages)。 |

## 开启极狐GitLab Advanced SAST

<a id="turn-on-gitlab-advanced-sast"></a>

按照以下步骤在您的项目中开启极狐GitLab Advanced SAST。

前提条件：

- 项目拥有维护者或所有者角色。
- 开启标准 SAST 分析器。详情请参阅 [SAST 前提条件](_index.md#getting-started)。
- 对于私有化部署，使用受支持的极狐GitLab 版本：
  - 最低版本：极狐GitLab 17.1 或更高版本
  - 推荐版本：极狐GitLab 17.4 或更高版本（包含代码流视图、漏洞去重和更新的模板）
  - 模板兼容性：
    - 稳定模板：极狐GitLab 17.3 或更高版本
    - 最新模板：极狐GitLab 17.2 或更高版本
    - 不要在同一项目中混合使用[稳定模板和最新模板](../detect/security_configuration.md#template-editions)

开启极狐GitLab Advanced SAST：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 转到 **构建** > **流水线** 编辑器。
1. 创建或编辑您的 `.gitlab-ci.yml` 文件。
1. 添加适当的变量以启用 Advanced SAST：

   - 对于除 C/C++ 外的所有受支持语言：
     `GITLAB_ADVANCED_SAST_ENABLED: 'true'`

   - 对于 C/C++：
     `GITLAB_ADVANCED_SAST_CPP_ENABLED: 'true'`

1. 选择 **校验** 标签页，然后选择 **校验流水线**。

   消息 **模拟成功完成** 确认文件有效。
1. 选择 **编辑** 标签页。
1. 填写字段。
1. 选中 **以此更改开始新的合并请求** 复选框，然后选择 **提交变更**。
1. 按照您的标准工作流程填写字段，然后选择 **创建合并请求**。
1. 按照您的标准工作流程审查和编辑合并请求，然后选择 **合并**。

此时，极狐GitLab Advanced SAST 已在您的流水线中启用。当流水线运行时，将扫描受支持的源代码以查找漏洞。相应的作业将显示在流水线的 `test` 阶段中。

完成这些步骤后，您可以：

- 了解更多关于如何评估[漏洞结果](#vulnerability-results)的信息。
- 查看[优化建议](#optimization)。
- 计划[向更多项目推广](#roll-out)。

## 漏洞结果

<a id="vulnerability-results"></a>

极狐GitLab Advanced SAST 漏洞包含详细信息，可帮助您评估和修复安全问题。
每个漏洞均展示：

- 描述：解释漏洞的成因、潜在影响以及推荐的修复步骤。
- 状态：指示漏洞是否已经过分类或已解决。
- 严重性：根据影响分为六个级别。[了解更多关于严重性级别的信息](../vulnerabilities/severities.md)。
- 位置：显示问题所在的文件名和行号。选择文件路径将在代码视图中打开相应的行。
- 代码流：数据从用户输入（源）到存在漏洞的代码行所经过的路径。
- 扫描器：标识检测到该漏洞的分析器。
- 标识符：用于对漏洞进行分类的参考列表，例如 CWE 标识符，以及检测到它的规则 ID。

SAST 漏洞根据所发现漏洞的主要通用弱点枚举 (CWE) 标识符进行命名。
有关 SAST 覆盖范围的更多信息，请参阅 [SAST 规则](rules.md)。

### 查看结果

<a id="view-results"></a>

前提条件：

- 项目拥有安全经理、开发者、维护者或所有者角色。

查看流水线中的漏洞：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **构建** > **流水线**。
1. 选择流水线。
1. 选择 **安全** 标签页。
1. 可以下载结果，或选择一个漏洞以查看其详细信息（仅在旗舰版中可用）。

#### 代码流

<a id="code-flow"></a>

{{< history >}}

- 在极狐GitLab 17.3 中引入，[带有多个功能标志](../../../administration/feature_flags/_index.md)。默认启用。
- 在极狐GitLab 17.7 中在私有化部署上启用。
- 极狐GitLab 17.7 中 GA。所有功能标志均已移除。

{{< /history >}}

对于特定类型的漏洞，极狐GitLab Advanced SAST 提供代码流信息。
漏洞的代码流是数据从用户输入（源）到存在漏洞的代码行（接收点）所经过的路径，涵盖了所有赋值、操作和净化处理。
此信息可帮助您理解和评估漏洞的上下文、影响和风险。
代码流信息适用于通过追踪输入从源到接收点而检测到的漏洞，包括：

- SQL 注入
- 命令注入
- 跨站脚本 (XSS)
- 路径遍历

代码流信息显示在 **代码流** 标签页中，包括：

- 从源到接收点的步骤。
- 相关文件，包括代码片段。

![跨两个文件的 Python 应用程序代码流](img/code_flow_view_v17_7.png)

## 支持的语言

<a id="supported-languages"></a>

{{< history >}}

- C# 版本支持[在极狐GitLab 18.6 中从 10.0 提升到 13.0](https://gitlab.com/gitlab-org/gitlab/-/issues/570499)。

{{< /history >}}

极狐GitLab Advanced SAST 支持以下语言：

- C#（最高至 13.0，含 13.0）
- C/C++
- Go
- Java，包括 Java Server Pages (JSP)
- JavaScript、TypeScript
- PHP
- Python
- Ruby

极狐GitLab Advanced SAST CPP 需要额外配置，包括编译数据库。详情请参阅 [C/C++ 配置](advanced_sast_cpp.md)。对于 C/C++ 项目，极狐GitLab Advanced SAST CPP 和 Semgrep 会同时运行，各自使用不同的规则集。

### PHP 已知问题

<a id="php-known-issues"></a>

在分析 PHP 代码时，极狐GitLab Advanced SAST 存在以下已知问题：

- 动态文件包含：使用变量作为文件路径的动态文件包含语句（`include`、`include_once`、`require`、`require_once`）此版本不支持。仅支持静态文件包含路径进行跨文件分析。参见
  [议题 527341](https://gitlab.com/gitlab-org/gitlab/-/issues/527341)。
- 大小写敏感性：PHP 函数名、类名和方法名的大小写不敏感性在跨文件分析中未完全支持。参见
  [议题 526528](https://gitlab.com/gitlab-org/gitlab/-/issues/526528)。

## 优化

<a id="optimization"></a>

极狐GitLab Advanced SAST 的扫描持续时间由多种因素决定，但主要是代码覆盖率和 Runner 资源。为优化极狐GitLab Advanced SAST 的扫描持续时间，您可以调整代码覆盖率和 Runner 资源。

您可以选择[报告未验证的漏洞](#report-unverified-vulnerabilities)，即未识别从源到接收点的完整路径的情况。

### 调整代码覆盖率

<a id="tune-code-coverage"></a>

代码覆盖率指代码库中被分析的代码有多少。极狐GitLab Advanced SAST 使用其预定义的规则集扫描所有受支持的语言文件。基于 Semgrep 的 SAST 分析器不扫描这些文件。当两个分析器检测到同一漏洞时，一个自动的[过渡流程](#transitioning-from-semgrep-to-gitlab-advanced-sast)会移除重复的发现。

默认情况下，极狐GitLab Advanced SAST 扫描整个仓库。您可以使用以下方法调整代码覆盖率：

- 排除仓库路径以减少分析的代码量。
- 开启基于差异的扫描，仅分析合并请求中修改的文件（及其依赖文件）。
- 开启增量扫描，该扫描会缓存先前扫描的结果，从而降低计算负载。

#### 排除路径

<a id="exclude-paths"></a>

为了减少扫描持续时间，请将不太可能包含漏洞的路径从极狐GitLab Advanced SAST 扫描中排除。

排除路径时需谨慎，避免隐藏漏洞。逐步进行更改，并在每次排除后测试其对扫描持续时间的影响。

考虑排除包含以下内容的路径：

- 数据库迁移
- 单元测试
- 依赖项，例如 `node_modules/`
- 构建文件
- 配置信息
- 静态资源
- 测试数据
- 基础设施即代码

前提条件：

- 项目拥有维护者或所有者角色。

排除路径：

- 在 [`SAST_EXCLUDED_PATHS`](_index.md#vulnerability-filters) CI/CD 变量中列出排除的路径。

#### 基于差异的扫描

<a id="diff-based-scanning"></a>

{{< history >}}

- 在极狐GitLab 18.5 中引入，[带有一个功能标志](../../../administration/feature_flags/_index.md) 命名为 `vulnerability_partial_scans`。默认禁用。
- 在极狐GitLab 18.5 中[在 JihuLab.com、私有化部署上启用](https://gitlab.com/gitlab-org/gitlab/-/issues/552051)。
- 极狐GitLab 18.6 中[GA](https://gitlab.com/gitlab-org/gitlab/-/issues/552051)。功能标志 `vulnerability_partial_scans` 已移除。

{{< /history >}}

基于差异的扫描仅分析合并请求中修改的文件及其依赖文件。这种有针对性的方法减少了扫描持续时间，在开发过程中提供更快的反馈。

为确保全面覆盖，在合并请求合并后，会在默认分支上运行一次完整扫描。

在以下条件下，基于差异的扫描在合并请求流水线和分支流水线中均受支持：

- 合并请求流水线：当极狐GitLab Advanced SAST 配置为在
  [合并请求流水线](../detect/security_configuration.md#use-security-scanning-tools-with-merge-request-pipelines)上运行时，将进行基于差异的扫描。
- 分支流水线：当分支上恰好有一个打开的合并请求时，将进行基于差异的扫描。如果没有合并请求或超过一个，则扫描会回退为完整扫描，因为它无法确定分支应与哪个提交进行对比。

当基于差异的扫描处于活动状态时：

- 仅扫描在合并请求中修改或添加的文件及其依赖文件。
- 作业日志会包含输出：`Running differential scan`。（如果非活动，则输出：`Running full scan`。）
- 在合并请求的安全小组件中，一个专门的 **基于差异** 标签页会显示相关的扫描发现。
- 在流水线安全标签页中，一个标记为 **部分 SAST 报告** 的警报表示仅包含部分发现。

基于差异的扫描存在以下已知问题：

- 漏报和误报：基于差异的扫描可能无法捕获所扫描文件中的完整调用图，这可能导致漏掉漏洞（漏报）或已解决的漏洞再次出现（误报）。这种取舍可缩短扫描时间并提供更快的开发反馈。为实现全面覆盖，默认分支上始终会运行一次完整扫描。
- C/C++ 头文件覆盖：基于差异的扫描不完全支持 C/C++ 头文件。跨越头文件和源文件的漏洞可以被检测到，但完全位于头文件中的漏洞可能无法检测到。
- 已修复的漏洞未报告：为避免误导性结果，已修复的漏洞在基于差异的扫描中被排除。由于仅分析文件子集，无法获得完整的调用图，因此无法确认漏洞是否已被修复。在合并后，默认分支上会始终运行一次完整扫描，届时将报告已修复的漏洞。因此，基于差异的扫描可能存在的任何差距，都通过合并到默认分支时自动运行的全面扫描得到了弥补，确保了全面覆盖。这种分层方法在开发过程中的快速反馈循环与代码进入生产前的彻底安全分析之间取得了平衡。

##### 开启基于差异的扫描

<a id="turn-on-diff-based-scanning"></a>

前提条件：

- 项目拥有维护者或所有者角色。

在合并请求流水线中开启基于差异的扫描：

- 在项目的 `.gitlab-ci.yml` 文件中将 `ADVANCED_SAST_PARTIAL_SCAN` CI/CD 变量设置为 `differential`。

##### 依赖文件

<a id="dependent-files"></a>

为避免遗漏修改文件之外的跨文件漏洞，基于差异的扫描会包含它们的直接依赖项。这减少了漏报，同时保持快速扫描，但在更深层的依赖链中可能会产生不精确的结果。

以下文件包含在扫描中：

- 修改的文件（合并请求中更改或添加的文件）
- 依赖文件（导入修改文件的文件）

这种设计有助于检测跨文件数据流，例如受污染的数据从修改的函数移动到导入了它的调用者。

被修改文件导入的文件不会被扫描，因为它们通常不会影响所修改代码的行为或数据流。

例如，考虑一个修改了文件 B 的合并请求：

- 如果文件 A 导入了文件 B，则扫描文件 A 和 B。
- 如果文件 B 导入了文件 C，则仅扫描文件 B。

#### 增量扫描

<a id="incremental-scanning"></a>

{{< history >}}

- 在极狐GitLab 18.11 中引入。

{{< /history >}}

增量扫描在流水线运行之间缓存污点签名分析结果。在后续扫描中，未更改的代码会重用缓存签名，而不是重新分析，而更改或新增的代码则进行全面分析。这减少了在大多数文件在提交之间不发生更改的大型代码库上的扫描时间。

增量扫描的工作方式如下：

1. 首次扫描（冷启动）：分析器执行全面分析，并创建污点签名缓存。缓存存储为 CI 产物 (`ts-cache.sqlite.gz`)。
1. 后续扫描（热启动）：分析器在之前的提交中搜索包含缓存产物的成功流水线。如果找到，则获取缓存并重用未更改的结果。扫描完成后，更新后的缓存存储为新的产物。

##### 缓存失效

<a id="cache-invalidation"></a>

为确保准确性同时最大化重用，缓存会失效：

部分失效：仅重新计算受影响的条目，缓存的其余部分重用：

- 新增或更改的文件：当文件被添加、修改、删除或重命名时，其缓存签名会失效，并在下一次扫描时重新计算。
- 新增或更改的规则：当检测规则被添加或修改时，仅那些特定规则会针对代码库重新计算。

完全失效：整个缓存被重建：

- 引擎变更：当引擎级别的变更使现有缓存不兼容时，将通过完整扫描自动生成新缓存。

##### 开启增量扫描

<a id="turn-on-incremental-scanning"></a>

开启增量扫描：

- 在项目的 `.gitlab-ci.yml` 文件中将 `GITLAB_ADV_SAST_INCR_SCAN` CI/CD 变量设置为 `true`：

  ```yaml
  gitlab-advanced-sast:
    variables:
      GITLAB_ADV_SAST_INCR_SCAN: "true"
  ```

##### 配置缓存保留

<a id="configure-cache-retention"></a>

SAST CI/CD 模板将缓存产物的默认过期时间存储为 3 天。`GITLAB_ADV_SAST_INCR_SCAN_SEARCH_PERIOD` 变量控制分析器向后搜索缓存产物的时间范围（默认：`3 days`）。

这两个值应对齐。搜索周期不应超过产物的到期时间，否则分析器可能会搜索已经过期的产物。

要自定义这两个值，请覆盖 `artifacts:expire_in` 并设置搜索周期变量：

```yaml
gitlab-advanced-sast:
  variables:
    GITLAB_ADV_SAST_INCR_SCAN: "true"
    GITLAB_ADV_SAST_INCR_SCAN_SEARCH_PERIOD: "7 days"
  artifacts:
    paths:
      - gl-sast-report.json
      - ts-cache.sqlite.gz
    expire_in: 7 days
```

搜索周期支持一个数字后跟 `d`、`day` 或 `days`（例如，`7 days`、`14d`）。

##### 配置自定义作业名称

<a id="configure-custom-job-name"></a>

分析器使用 CI/CD 作业名称来识别哪个作业的产物包含缓存。如果您重命名了 `gitlab-advanced-sast` 作业，设置 `GITLAB_ADV_SAST_INCR_SCAN_CUSTOM_JOB_NAME` 为自定义名称，以便缓存查找找到正确的作业：

```yaml
my-custom-sast-job:
  variables:
    GITLAB_ADV_SAST_INCR_SCAN: "true"
    GITLAB_ADV_SAST_INCR_SCAN_CUSTOM_JOB_NAME: "my-custom-sast-job"
```

##### 缓存大小限制

<a id="cache-size-limits"></a>

缓存存储为压缩的 CI/CD 产物。产物大小限制适用：

- JihuLab.com：产物最大大小为 1 GB。
- 私有化部署：默认产物最大大小为 100 MB。管理员可以在 [CI/CD 设置](../../../administration/settings/continuous_integration.md#set-maximum-artifacts-size)中调整此限制。

### 报告未验证的漏洞

<a id="report-unverified-vulnerabilities"></a>

{{< details >}}

- 状态：Beta

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.11 中作为 [Beta](../../../policy/development_stages_support.md#beta) 引入。

{{< /history >}}

极狐GitLab Advanced SAST 使用污点分析追踪数据从不受信任的来源到易受攻击的接收点。默认情况下，分析器仅在能够追踪到完整路径时才报告漏洞，这优先考虑准确性而非覆盖率。为了检测更多的潜在数据流，您可以启用未验证漏洞。此功能即使无法建立完整的数据流路径也会报告发现，这增加了覆盖率，但同时也可能增加误报数量。

当您启用未验证漏洞报告时，分析器还会报告检测到部分污点流但无法从源到接收点完全验证的发现。这些接近命中的发现可帮助您识别并主动修复风险代码，防止其变得可被利用。未验证发现仅针对安全严重性为中等或更高的规则进行报告。

未验证发现通过以下方式与完全验证的漏洞明显区分开来：

- 在流水线 **安全** 标签页中，漏洞描述以 **(未验证)** 前缀开头。
- 在 **漏洞报告** 中，未验证发现同样带有此前缀。
- 在 **代码流** 视图中，未验证漏洞没有源节点。流中的第一个节点是 **追踪入口点**，指示部分追踪开始的位置。

#### 开启未验证漏洞报告

<a id="turn-on-unverified-vulnerability-reporting"></a>

要在扫描结果中包含未验证发现，请在 `.gitlab-ci.yml` 文件中将 `REPORT_UNVERIFIED_VULNS` CI/CD 变量设置为一个真值：

```yaml
gitlab-advanced-sast:
  variables:
    REPORT_UNVERIFIED_VULNS: "true"
```

> [!warning]
> 启用未验证漏洞报告可能会显著增加分析器生成的发现数量。
> 这些发现存储在漏洞数据库中，并可能影响漏洞管理工作流，
> 包括分类工作量和报告。

### 调整 Runner 资源

<a id="tune-runner-resources"></a>

Runner 资源直接影响扫描持续时间。极狐GitLab Advanced SAST 默认并行运行检查，这需要多个 CPU 核心以及每个核心至少 4 GB 内存。Runner 资源会自动检测，但您可以根据需要调整某些设置。

分析器按照以下优先级确定可用的 CPU 和内存：

1. 极狐GitLab SaaS Runner 标签 (`CI_RUNNER_TAGS`)：
   - 在极狐GitLab 托管的 Runner 上，分析器读取 Runner 标签（例如，
     `saas-linux-large-amd64`），并查找该 Runner 类型的已知 CPU 和内存值。
1. 容器资源限制 (`/sys/fs/cgroup/cpu.max`、`/sys/fs/cgroup/memory.max`)：
   - 在私有化部署 Runner 上，分析器从 Linux cgroups 读取容器资源限制。只有
     资源限制会反映在 cgroups 中。请求不在容器级别强制执行，因此无效。
1. CI/CD 变量覆盖 (`ADVANCED_SAST_AVAILABLE_CPUS`、`ADVANCED_SAST_AVAILABLE_MEMORY`)：
   - 如果设置，这些值将覆盖在步骤 1 或 2 中检测到的任何值。

如果检测在步骤 1 和 2 都失败，分析器默认使用 1 个核心和 4 GB 内存。

要确认 CPU 和内存分配，请查看 `gitlab-advanced-sast` 作业日志，并查找
极狐GitLab Advanced SAST 条目。例如：

```plaintext
[INFO] [GitLab Advanced SAST] [2026-03-30T02:38:09Z] ▶ 检测到 2 个 CPU 核心
[INFO] [GitLab Advanced SAST] [2026-03-30T02:38:09Z] ▶ 未检测到内存限制
```

#### 配置 Runner 资源设置

<a id="configure-runner-resource-settings"></a>

在以下情况下，您可以使用 CI/CD 变量手动调整分析器的 CPU 和内存设置：

- 您的 Runner 上未设置 cgroup 限制（例如，在裸金属或无约束的虚拟机中）。
- 检测到的值与您 Runner 的实际容量不匹配。
- 您希望将分析器使用的资源限制在可用资源以下。

使用以下 CI/CD 设置来调整极狐GitLab Advanced SAST Runner 资源：

- `ADVANCED_SAST_AVAILABLE_CPUS` - 指定分析器可用的 CPU 核心数
- `ADVANCED_SAST_AVAILABLE_MEMORY` - 指定分析器可用的总内存量
- `MAX_UNVERIFIED_CORES` - 设置自动核心检测的上限
- `DISABLE_MULTI_CORE` - 完全禁用多核心扫描
对于私有化部署 runner，你可以在
[安全扫描器配置](_index.md#security-scanner-configuration) 中使用 `--multi-core` 标志来指定
`requested` 核心的数量。

更多详情，请参见[配置](#configuration)。

要找到适合你项目的最优配置，一次只更改一个设置并
监控扫描持续时间。

在以下示例中，极狐GitLab Advanced SAST 分析器可使用 4 个 CPU 核心和 16 GB 内存。4 个 worker 中的每一个都有 4 GB 可用内存。

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  GITLAB_ADVANCED_SAST_ENABLED: 'true'
  ADVANCED_SAST_AVAILABLE_CPUS: '4'
  ADVANCED_SAST_AVAILABLE_MEMORY: '16384'  # 4 核 16 GB 内存
```

## 配置

你可以使用以下变量调整 GitLab Advanced SAST 的行为：

| CI/CD 变量                                | 默认值                | 描述                                                                                                                                                                   |
|------------------------------------------|---------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `GITLAB_ADVANCED_SAST_ENABLED`           | `false`             | 为除 C 和 C++ 之外的所有支持语言启用 GitLab Advanced SAST 扫描。                                                                                                               |
| `GITLAB_ADVANCED_SAST_CPP_ENABLED`       | `false`             | 专门为 C 和 C++ 项目启用 GitLab Advanced SAST 扫描。                                                                                                                        |
| `ADVANCED_SAST_PARTIAL_SCAN`             | `false`             | 通过设置为 `differential`，启用 GitLab Advanced SAST 差分扫描模式。                                                                                                            |
| `GITLAB_ADVANCED_SAST_RULE_TIMEOUT`      | `30`                | 每个文件每条规则的超时时间（秒）。超时后，将跳过该分析。                                                                                                                               |
| `REPORT_UNVERIFIED_VULNS`                | `false`             | 在扫描结果中包含未经证实的发现。设置为 `true`、`1` 或 `True` 以启用。                                                                                                                    |
| `GITLAB_ADV_SAST_INCR_SCAN`              | `false`             | 启用[增量扫描](#incremental-scanning)以在流水线运行之间缓存污点签名。                                                                                                                |
| `GITLAB_ADV_SAST_INCR_SCAN_SEARCH_PERIOD` | `3 days`            | 向后搜索缓存的污点签名产物的时间范围。支持的格式：数字后跟 `d`、`day` 或 `days`（例如，`7 days`）。不应超过产物过期期限。                                                                                |
| `GITLAB_ADV_SAST_INCR_SCAN_CUSTOM_JOB_NAME` | `gitlab-advanced-sast` | 用于缓存产物查找的自定义作业名称。如果你重命名了 `gitlab-advanced-sast` 作业，请设置此项。                                                                                                    |

默认情况下，GitLab Advanced SAST 扫描是禁用的。要在较高级别（例如，对于群组）启用时显式禁用它，请将 `GITLAB_ADVANCED_SAST_ENABLED`（或用于 C/C++ 项目的 `GITLAB_ADVANCED_SAST_CPP_ENABLED`）设置为 `false`。

## 推广

在你对一个项目的 GitLab Advanced SAST 结果有信心之后，可以将其扩展到其他
项目和群组。你应该创建一个包含 GitLab Advanced SAST 的共享 CI/CD 配置，并在所需的群组和项目中强制执行。

更多详情，请参见[安全配置](../detect/security_configuration.md)。

## 漏洞检测标准

GitLab Advanced SAST 使用跨文件、跨函数扫描和污点分析
来追踪用户输入在程序中的流动。这确保了即使注入漏洞（如 SQL 注入和跨站脚本 (XSS)）跨越多个函数和文件，
也能被检测到。

分析器仅当存在可验证的、将不受信任的用户输入从源点引入到可能造成安全漏洞的不受信任数据点时，
才会报告基于污点的漏洞。
相较于其他可能以较少验证来报告漏洞的产品，此方法可以最大限度地降低误报。

检测强调跨越信任边界的输入，例如源自 HTTP 请求的值，
但排除了命令行参数、环境变量或通常由操作程序的用户提供的其他输入。

有关 GitLab Advanced SAST 检测的漏洞类型的详细信息，
请参见[GitLab Advanced SAST CWE 覆盖范围](advanced_sast_coverage.md)。

## 从 Semgrep 迁移到 GitLab Advanced SAST

当你从 Semgrep 迁移到 GitLab Advanced SAST 时，一个自动化的过渡过程会进行漏洞去重。此过程将先前检测到的 Semgrep 漏洞与相应的 GitLab Advanced SAST 发现关联起来，当找到匹配项时，将其替换。

在默认分支中启用 Advanced SAST 扫描后，当扫描运行并检测到
漏洞时，它会根据以下条件检查是否应该将任何漏洞替换掉现有的 Semgrep 漏洞。

### 去重条件

1.  **匹配标识符**：
    -   GitLab Advanced SAST 漏洞的标识符中（不包括 CWE 和 OWASP）至少有一个必须与现有 Semgrep 漏洞的**主标识符**匹配。
    -   主标识符是 [SAST 报告](_index.md#download-a-sast-report) 中漏洞标识符数组里的第一个标识符。
    -   例如，如果一个 GitLab Advanced SAST 漏洞包含 `bandit.B506` 等标识符，而一个 Semgrep 漏洞的主标识符也是 `bandit.B506`，则满足此条件。

1.  **匹配位置**：
    -   漏洞必须关联到代码中的**相同位置**。这是通过 [SAST 报告](_index.md#download-a-sast-report) 中漏洞的以下字段之一来确定的：
        -   跟踪字段（如果存在）
        -   位置字段（如果跟踪字段不存在）

### 漏洞变更

当条件满足时，现有的 Semgrep 漏洞将转换为 GitLab Advanced SAST 漏洞。此更新后的漏洞将出现在[漏洞报告](../vulnerability_report/_index.md)中，并有以下变更：

-   扫描器类型从 Semgrep 更新为 GitLab Advanced SAST。
-   GitLab Advanced SAST 漏洞中存在的任何其他标识符都会被添加到现有漏洞中。
-   漏洞的所有其他细节保持不变。

### 解决重复漏洞

在某些情况下，如果不满足[去重条件](#conditions-for-deduplication)，Semgrep 漏洞可能仍会显示为重复项。要在[漏洞报告](../vulnerability_report/_index.md)中解决此问题：

1.  按 Advanced SAST 扫描器[筛选漏洞](../vulnerability_report/_index.md#filtering-vulnerabilities)并[以 CSV 格式导出结果](../vulnerability_report/_index.md#export-details)。
1.  按 Semgrep 扫描器[筛选漏洞](../vulnerability_report/_index.md#filtering-vulnerabilities)。这些可能就是未去重的漏洞。
1.  对于每个 Semgrep 漏洞，检查它是否在导出的 Advanced SAST 结果中有对应的匹配项。
1.  如果存在重复项，请适当地解决该 Semgrep 漏洞。

## 请求 GitLab Advanced SAST 中 LGPL 许可组件的源代码

要请求有关 GitLab Advanced SAST 中 LGPL 许可组件源代码的信息，
请[联系极狐GitLab 支持团队](https://about.gitlab.com/support/)。

为确保快速响应，请在你的请求中附上 GitLab Advanced SAST 分析器版本。

由于此功能仅在旗舰版提供，你必须与拥有该级别支持权益的组织相关联。