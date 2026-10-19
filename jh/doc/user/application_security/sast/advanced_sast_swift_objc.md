---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Advanced SAST Swift 和 Objective-C 配置
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

极狐GitLab Advanced SAST 通过跨文件、跨函数的污点分析来分析 Swift 和 Objective-C 代码，将 [极狐GitLab Advanced SAST](gitlab_advanced_sast.md) 的覆盖范围扩展到 iOS 应用程序。

Swift 和 Objective-C 分析作为独立的 CI/CD 作业 `gitlab-advanced-sast-ext` 运行，并以独立的容器镜像形式发布。无需额外配置。启用极狐GitLab Advanced SAST 后，如果代码仓库中包含 Swift（`.swift`）、Objective-C（`.m`）或 Objective-C++（`.mm`）文件，该作业就会运行。

<a id="turn-on-gitlab-advanced-sast-swift-and-objective-c-analysis"></a>

## 启用极狐GitLab Advanced SAST Swift 和 Objective-C 分析

先决条件：

- [启用极狐GitLab Advanced SAST](gitlab_advanced_sast.md#turn-on-gitlab-advanced-sast)。

Swift 和 Objective-C 分析使用与其他受支持语言相同的启用变量：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  GITLAB_ADVANCED_SAST_ENABLED: "true"
```

设置此变量且代码仓库中包含 Swift 或 Objective-C 文件时，极狐GitLab 会将 `gitlab-advanced-sast-ext` 作业添加到流水线的 `test` 阶段。

<a id="turn-off-gitlab-advanced-sast-swift-and-objective-c-analysis"></a>

## 关闭极狐GitLab Advanced SAST Swift 和 Objective-C 分析

要在保持其他语言的极狐GitLab Advanced SAST 开启的同时关闭 Swift 和 Objective-C 分析，请将 `gitlab-advanced-sast-ext` 添加到 `SAST_EXCLUDED_ANALYZERS` 变量：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  GITLAB_ADVANCED_SAST_ENABLED: "true"
  SAST_EXCLUDED_ANALYZERS: "gitlab-advanced-sast-ext"
```

要完全关闭极狐GitLab Advanced SAST（包括 Swift 和 Objective-C 分析），请将 `GITLAB_ADVANCED_SAST_ENABLED` 设置为 `"false"`。

如果 `GITLAB_ADVANCED_SAST_ENABLED` 被设置为群组 CI/CD 变量，项目 `.gitlab-ci.yml` 文件中的值不会覆盖它。要覆盖群组变量，请定义同名项目 CI/CD 变量。更多信息，请参见 [CI/CD 变量优先级](../../../ci/variables/_index.md#cicd-variable-precedence)。

<a id="incremental-scanning"></a>

## 增量扫描

增量扫描默认开启。分析器在流水线运行之间缓存其污点分析存储，然后仅重新分析代码或依赖项发生变化的文件，并对未更改的代码复用缓存结果。
这可以缩短大型代码库的扫描时间，因为大多数代码在提交之间不会发生变化。

对于其他极狐GitLab Advanced SAST 语言，等效功能是 [增量扫描](gitlab_advanced_sast.md#incremental-scanning)，该功能默认关闭，并使用不同的 CI/CD 变量进行配置。

`gitlab-advanced-sast-ext` 作业通过作业的 `cache:` 在流水线之间传递存储，以分支为键，并回退到默认分支。

缓存复用要求 Runner 能够访问先前的缓存。
如果您的实例使用多个 Runner 且未配置 [分布式缓存](https://gitlab.cn/docs/runner/configuration/autoscale/#distributed-runners-caching)，存储可能不可用，分析器将执行完整扫描。

<a id="turn-off-incremental-scanning"></a>

### 关闭增量扫描

要关闭增量扫描并在每次运行时扫描所有代码，请将 `GITLAB_ADVANCED_SAST_EXT_INCREMENTAL_ENABLED` 变量设置为 `"false"`：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  GITLAB_ADVANCED_SAST_ENABLED: "true"
  GITLAB_ADVANCED_SAST_EXT_INCREMENTAL_ENABLED: "false"
```

<a id="disable-the-cache"></a>

### 禁用缓存

关闭增量扫描会保持 `cache:` 处于活动状态，因此每次流水线仍会上传和下载存储。
存储会保持预热状态，因此您可以重新启用增量扫描并立即复用它。

要同时消除每次流水线的缓存成本，请使用空的 `cache:` 覆盖该作业：

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  GITLAB_ADVANCED_SAST_ENABLED: "true"

gitlab-advanced-sast-ext:
  cache: []
```

禁用缓存后，每次流水线都会运行完整扫描，且不产生缓存成本。
重新启用增量扫描则需要一次完整扫描来重新预热存储。

<a id="vulnerability-coverage"></a>

## 漏洞覆盖范围

分析器跨文件和函数追踪从来源到易受攻击汇聚点的不可信输入。
除了 SQL 注入和敏感信息明文传输等一般弱点类型外，它还建模了 iOS 特定的 API 和数据流，包括：

- 将深层链接和自定义 URL scheme 作为不可信输入来源。
- 钥匙串条目的可访问性类别。
- 在 `UserDefaults`、粘贴板和本地文件中存储敏感数据。
- WebKit 和 UIWebView 内容加载。

有关分析器检测到的弱点类型的完整列表，请参见 [Swift 和 Objective-C CWE 覆盖范围](advanced_sast_coverage.md#swift-and-objective-c-cwe-coverage)。

<a id="fips-pipelines"></a>

## FIPS 流水线

测试版期间，Swift 和 Objective-C 分析不提供启用 FIPS 的镜像。与其他分析器一样，只有极狐GitLab Advanced SAST 和基于 Semgrep 的分析器提供符合 FIPS 的镜像。

在使用 [启用 FIPS 的镜像](_index.md#fips-enabled-images) 的流水线中，`gitlab-advanced-sast-ext` 作业仍会运行，并因无法拉取启用 FIPS 的镜像而失败。
要以符合 FIPS 的方式使用 SAST，请 [关闭 Swift 和 Objective-C 分析](#turn-off-gitlab-advanced-sast-swift-and-objective-c-analysis)。

<a id="known-issues"></a>

## 已知问题

测试版期间，Swift 和 Objective-C 分析存在以下已知问题：

- 不支持 [离线环境](../offline_deployments/_index.md)。
- 发现结果不会与基于 Semgrep 的 SAST 分析器的发现结果进行去重。当两个分析器在 Swift 或 Objective-C 文件中检测到同一漏洞时，会报告两个发现结果。
- 不支持 [自定义规则集](customize_rulesets.md)。
- 不支持 [基于差异的扫描](gitlab_advanced_sast.md#diff-based-scanning)。
