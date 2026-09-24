---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: CI/CD YAML 语法参考
description: Pipeline configuration keywords, syntax, examples, and inputs.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本文档列出了极狐GitLab `.gitlab-ci.yml` 文件的配置选项。
此文件用于定义构成流水线的 CI/CD 作业。

- 如果你已经熟悉[基础 CI/CD 概念](../_index.md)，可以按照教程创建一个简单的 `.gitlab-ci.yml` 文件，该教程演示了[简单](../quick_start/_index.md)或[复杂](../quick_start/tutorial.md)流水线。
- 有关示例集合，请参见[极狐GitLab CI/CD 示例](../examples/_index.md)。
- 要查看企业中使用的较大 `.gitlab-ci.yml` 文件，请参见[极狐GitLab 的 `.gitlab-ci.yml` 文件](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/.gitlab-ci.yml)。

在编辑 `.gitlab-ci.yml` 文件时，可以使用 [CI Lint](lint.md) 工具对其进行验证。

极狐GitLab CI/CD 配置使用 YAML 格式，因此除非另有说明，关键字的顺序并不重要。

使用 [CI/CD 表达式](expressions.md) 获取更动态的流水线配置选项。

<!--
If you are editing content on this page, follow the instructions for documenting keywords:
<https://docs.gitlab.com/development/cicd/cicd_reference_documentation_guide/>
-->

<a id="keywords"></a>

## 关键字

极狐GitLab CI/CD 流水线配置包括：

- [全局关键字](#全局关键字)（global keywords），用于配置流水线行为：

  | 关键字 | 描述 |
  |-----------------------------------|:------------|
  | [`default`](#default) | 自定义作业关键字的默认值。 |
  | [`include`](#include) | 从其他 YAML 文件导入配置。 |
  | [`stages`](#stages) | 流水线阶段的名称和顺序。 |
  | [`variables`](#default-variables) | 为流水线中的所有作业定义默认的 CI/CD 变量。 |
  | [`workflow`](#workflow) | 控制运行的流水线类型。 |

- [头部关键字](#header-keywords)（header keywords）

  | 关键字 | 描述 |
  |-----------------|:------------|
  | [`spec`](#spec) | 定义外部配置文件的规范。 |

- 使用[作业关键字](#job-keywords)配置的[作业](../jobs/_index.md)：

  | 关键字 | 描述 |
  |:----------------------------------------------|:------------|
  | [`after_script`](#after_script) | 覆盖作业后执行的一组命令。 |
  | [`allow_failure`](#allow_failure) | 允许作业失败。失败的作业不会导致流水线失败。 |
  | [`artifacts`](#artifacts) | 作业成功时要附加的文件和目录列表。 |
  | [`before_script`](#before_script) | 覆盖作业前执行的一组命令。 |
  | [`cache`](#cache) | 应在后续运行之间缓存的文件列表。 |
  | [`coverage`](#coverage) | 给定作业的代码覆盖率设置。 |
  | [`dast_configuration`](#dast_configuration) | 在作业级别使用 DAST 配置文件的配置。 |
  | [`dependencies`](#dependencies) | 通过提供要从中获取产物的作业列表，限制传递给特定作业的产物。 |
  | [`environment`](#environment) | 作业部署到的环境名称。 |
  | [`extends`](#extends) | 此作业继承的配置条目。 |
  | [`identity`](#identity) | 使用身份联合对第三方服务进行身份验证。 |
  | [`image`](#image) | 使用 Docker 镜像。 |
  | [`inherit`](#inherit) | 选择所有作业继承的全局默认值。 |
  | [`interruptible`](#interruptible) | 定义当作业因较新运行而冗余时，是否可以取消该作业。 |
  | [`manual_confirmation`](#manual_confirmation) | 为手动作业定义自定义确认消息。 |
  | [`needs`](#needs) | 早于阶段顺序执行作业。 |
  | [`pages`](#pages) | 上传作业结果以用于极狐GitLab Pages。 |
  | [`parallel`](#parallel) | 应并行运行的作业实例数。 |
  | [`release`](#release) | 指示 runner 生成一个[发布](../../user/project/releases/_index.md)对象。 |
  | [`resource_group`](#resource_group) | 限制作业并发。 |
  | [`retry`](#retry) | 在失败的情况下，可以自动重试作业的时间和次数。 |
  | [`rules`](#rules) | 评估并确定作业的选定属性以及是否创建该作业的条件列表。 |
  | [`script`](#script) | 由 runner 执行的 Shell 脚本。 |
  | [`run`](#run) | 由 runner 执行的运行配置。 |
  | [`secrets`](#secrets) | 作业所需的 CI/CD 密钥。 |
  | [`services`](#services) | 使用 Docker 服务镜像。 |
  | [`stage`](#stage) | 定义作业阶段。 |
  | [`start_in`](#start_in) | 将作业的执行延迟指定的持续时间。需要 `when: delayed`。 |
  | [`tags`](#tags) | 用于选择 runner 的标签列表。 |
  | [`timeout`](#timeout) | 定义自定义的作业级别超时时间，它优先于项目范围的设置。 |
  | [`trigger`](#trigger) | 定义下游流水线触发器。 |
  | [`variables`](#job-variables) | 为单个作业定义 CI/CD 变量。 |
  | [`when`](#when) | 何时运行作业。 |

- [弃用的关键字](deprecated_keywords.md)，不再推荐使用。

---

<a id="global-keywords"></a>

## 全局关键字

有些关键字不在作业中定义。这些关键字控制流水线行为或导入额外的流水线配置。

---

<a id="default"></a>

### default

{{< history >}}

- 在极狐GitLab 16.4 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/419750)了对 `id_tokens` 的支持。

{{< /history >}}

你可以为某些关键字设置全局默认值。每个默认关键字都会被复制到所有未显式定义该关键字的作业中。

默认配置不会与作业配置合并。如果作业已定义了某个关键字，则作业关键字优先，该关键字的默认配置不会被使用。

**关键字类型**：全局关键字。

**支持的值**：以下关键字可以设置自定义默认值：

- [`after_script`](#after_script)
- [`artifacts`](#artifacts)
- [`before_script`](#before_script)
- [`cache`](#cache)
- [`hooks`](#hooks)
- [`id_tokens`](#id_tokens)
- [`image`](#image)
- [`interruptible`](#interruptible)
- [`retry`](#retry)
- [`services`](#services)
- [`tags`](#tags)

**`default` 示例**：

```yaml
default:
  image: ruby:3.0
  retry: 2

rspec:
  script: bundle exec rspec

rspec 2.7:
  image: ruby:2.7
  script: bundle exec rspec
```

在此示例中：

- `image: ruby:3.0` 和 `retry: 2` 是流水线中所有作业的默认关键字。
- `rspec` 作业没有定义 `image` 或 `retry`，因此它使用默认值 `image: ruby:3.0` 和 `retry: 2`。
- `rspec 2.7` 作业没有定义 `retry`，但它显式定义了 `image`。它使用默认的 `retry: 2`，但忽略默认的 `image`，而是使用作业中定义的 `image: ruby:2.7`。

**其他详细信息**：

- 使用 [`inherit:default`](#inheritdefault) 控制作业中默认关键字的继承。
- 全局默认值不会传递给[下游流水线](../pipelines/downstream_pipelines.md)，下游流水线独立于触发它的上游流水线运行。

---

<a id="include"></a>

### include

使用 `include` 在 CI/CD 配置中包含外部 YAML 文件。
你可以将一个较长的 `.gitlab-ci.yml` 文件拆分为多个文件，以提高可读性，或减少在多个位置重复相同的配置。

你还可以将模板文件存储在中央仓库中，并将其包含到项目中。

`include` 文件：

- 与 `.gitlab-ci.yml` 文件中的配置合并。
- 始终首先求值，然后与 `.gitlab-ci.yml` 文件的内容合并，无论 `include` 关键字的位置如何。

解析所有文件的时间限制为 30 秒。

**关键字类型**：全局关键字。

**支持的值**：`include` 子键：

- [`include:component`](#include-component)
- [`include:local`](#include-local)
- [`include:project`](#include-project)
- [`include:remote`](#include-remote)
- [`include:template`](#include-template)

以及可选：

- [`include:inputs`](#include-inputs)
- [`include:rules`](#include-rules)
- [`include:integrity`](#include-integrity)
- [`include:cache`](#include-cache)

**其他详细信息**：

- 只有[特定的 CI/CD 变量](includes.md#use-variables-with-include)可以与 `include` 关键字一起使用。
- 使用合并可以自定义和覆盖包含的 CI/CD 配置。
- 你可以通过在 `.gitlab-ci.yml` 文件中使用相同的作业名称或全局关键字来覆盖包含的配置。两种配置会合并，`.gitlab-ci.yml` 文件中的配置优先于包含的配置。
- 如果重新运行：
  - 作业，`include` 文件不会再次获取。流水线中的所有作业都使用创建流水线时获取的配置。源 `include` 文件的任何更改都不会影响作业重运行。
  - 流水线，`include` 文件会再次获取。如果它们在最后一次流水线运行后发生了更改，则新流水线会使用更改后的配置。
- 默认情况下，每个流水线最多可以有 150 个包含项，包括[嵌套包含](includes.md#use-nested-includes)。此外：
  - 在极狐GitLab 16.0 及更高版本中，私有化部署实例的用户可以更改[最大包含项数量](../../administration/settings/continuous_integration.md#set-maximum-includes)的值。
  - 在极狐GitLab 15.10 及更高版本中，你可以有最多 150 个包含项。在嵌套包含中，同一个文件可以多次包含，但重复的包含会计入限制。
  - 从极狐GitLab 14.9 到 15.9，你可以有最多 100 个包含项。同一个文件可以在嵌套包含中多次包含，但重复项会被忽略。

---

<a id="include-component"></a>

#### 包含组件

使用 `include:component` 将 [CI/CD 组件](../components/_index.md) 添加到流水线配置中。

**关键字类型**：全局关键字。

**支持的值**：CI/CD 组件的完整地址，格式为 `<fully-qualified-domain-name>/<project-path>/<component-name>@<specific-version>`。

**`include:component` 示例**：

```yaml
include:
  - component: $CI_SERVER_FQDN/my-org/security-components/secret-detection@1.0
```

**相关主题**：

- [使用 CI/CD 组件](../components/_index.md#use-a-component)。

---

<a id="include-local"></a>

#### 包含本地文件

使用 `include:local` 包含同一仓库和分支中与包含 `include` 关键字的配置文件所在位置相同的文件。
使用 `include:local` 代替符号链接。

**关键字类型**：全局关键字。

**支持的值**：

相对于根目录 (`/`) 的完整路径：

- YAML 文件必须具有 `.yml` 或 `.yaml` 扩展名。
- 你可以在文件路径中[使用 `*` 和 `**` 通配符](includes.md#use-includelocal-with-wildcard-file-paths)。
- 你可以使用[特定的 CI/CD 变量](includes.md#use-variables-with-include)。

**`include:local` 示例**：

```yaml
include:
  - local: '/templates/.gitlab-ci-template.yml'
```

你也可以使用更短的语法来定义路径：

```yaml
include: '.gitlab-ci-production.yml'
```

**其他详细信息**：

- `.gitlab-ci.yml` 文件和本地文件必须在同一分支上。
- 你不能通过 Git 子模块路径包含本地文件。
- `include` 配置始终基于包含 `include` 关键字的文件的位置进行求值，而不是基于运行流水线的项目。如果[嵌套 `include`](includes.md#use-nested-includes) 在另一个项目的配置文件中，则 `include:local` 会在该项目中查找文件。

---

<a id="include-project"></a>

#### 包含项目

要包含同一极狐GitLab 实例上另一个私有项目的文件，请使用 `include:project` 和 `include:file`。

**关键字类型**：全局关键字。

**支持的值**：

- `include:project`：完整的极狐GitLab 项目路径。
- `include:file`：相对于根目录 (`/`) 的完整文件路径或文件路径数组。YAML 文件必须具有 `.yml` 或 `.yaml` 扩展名。
- `include:ref`：可选。要从中获取文件的 ref。如果未指定，则默认为项目的 `HEAD`。
- 你可以使用[特定的 CI/CD 变量](includes.md#use-variables-with-include)。

**`include:project` 示例**：

```yaml
include:
  - project: 'my-group/my-project'
    file: '/templates/.gitlab-ci-template.yml'
  - project: 'my-group/my-subgroup/my-project-2'
    file:
      - '/templates/.builds.yml'
      - '/templates/.tests.yml'
```

你也可以指定一个 `ref`：

```yaml
include:
  - project: 'my-group/my-project'
    ref: main                                      # Git 分支
    file: '/templates/.gitlab-ci-template.yml'
  - project: 'my-group/my-project'
    ref: v1.0.0                                    # Git 标签
    file: '/templates/.gitlab-ci-template.yml'
  - project: 'my-group/my-project'
    ref: 787123b47f14b552955ca2786bc9542ae66fee5b  # Git SHA
    file: '/templates/.gitlab-ci-template.yml'
```

**其他详细信息**：

- `include` 配置始终基于包含 `include` 关键字的文件的位置进行求值，而不是基于运行流水线的项目。如果[嵌套 `include`](includes.md#use-nested-includes) 在另一个项目的配置文件中，则 `include:local` 会在该项目中查找文件。
- 当流水线启动时，通过所有方法包含的 `.gitlab-ci.yml` 文件配置都会被求值。该配置是时间点的快照，并持久保存在数据库中。在下次流水线启动之前，极狐GitLab 不会反映所引用的 `.gitlab-ci.yml` 文件配置的任何更改。
- 当你包含来自另一个私有项目的 YAML 文件时，运行流水线的用户必须是两个项目的成员，并且具有运行流水线的适当权限。如果用户无权访问任何包含的文件，可能会显示 `找不到或拒绝访问` 错误。
- 在包含其他项目的 CI/CD 配置文件时要小心。当 CI/CD 配置文件更改时，不会触发流水线或通知。从安全角度来看，这类似于拉取第三方依赖项。对于 `ref`，请考虑：
  - 使用特定的 SHA 哈希值，这应该是最稳定的选择。使用完整的 40 个字符的 SHA 哈希值以确保引用所期望的提交，因为使用短 SHA 哈希值作为 `ref` 可能会产生歧义。
  - 将[受保护分支](../../user/project/repository/branches/protected.md)和[受保护标签](../../user/project/protected_tags.md#prevent-tag-creation-with-branch-names)规则同时应用于另一个项目中的 `ref`。受保护的标签和分支更有可能在更改之前通过变更管理。

---

<a id="include-remote"></a>

#### 包含远程文件

使用 `include:remote` 加上完整 URL 来包含来自外部位置的文件。

**关键字类型**：全局关键字。

**支持的值**：

可通过 HTTP/HTTPS `GET` 请求访问的公共 URL：

- 不支持对远程 URL 进行身份验证。
- YAML 文件必须具有 `.yml` 或 `.yaml` 扩展名。
- 你可以使用[特定的 CI/CD 变量](includes.md#use-variables-with-include)。

**`include:remote` 示例**：

```yaml
include:
  - remote: 'https://gitlab.com/example-project/-/raw/main/.gitlab-ci.yml'
```

**其他详细信息**：

- 所有[嵌套包含](includes.md#use-nested-includes)均以公共用户身份执行，没有上下文，因此你只能包含公共项目或模板。在嵌套包含的 `include` 部分中没有可用变量。
- 在包含其他项目的 CI/CD 配置文件时要小心。当其他项目的文件更改时，不会触发流水线或通知。从安全角度来看，这类似于拉取第三方依赖项。要验证所包含文件的完整性，请考虑使用 [`integrity`](#include-integrity) 关键字。如果你链接到自己拥有的另一个极狐GitLab 项目，请考虑同时使用[受保护分支](../../user/project/repository/branches/protected.md)和[受保护标签](../../user/project/protected_tags.md#prevent-tag-creation-with-branch-names)来强制执行变更管理规则。

---

<a id="include-template"></a>

#### 包含模板

使用 `include:template` 包含 [`.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/tree/master/lib/gitlab/ci/templates)。

**关键字类型**：全局关键字。

**支持的值**：

- CI/CD 模板的文件名，例如 `Auto-DevOps.gitlab-ci.yml`。
- 你可以使用[特定的 CI/CD 变量](includes.md#use-variables-with-include)。

**`include:template` 示例**：

```yaml
# 文件来自极狐GitLab 模板集合
include:
  - template: Auto-DevOps.gitlab-ci.yml
```

多个 `include:template` 文件：

```yaml
include:
  - template: Android-Fastlane.gitlab-ci.yml
  - template: Auto-DevOps.gitlab-ci.yml
```

**其他详细信息**：

- 所有模板可以在 [`lib/gitlab/ci/templates`](https://gitlab.com/gitlab-org/gitlab/-/tree/master/lib/gitlab/ci/templates) 中查看。并非所有模板都设计为与 `include:template` 一起使用，因此在使用之前请检查模板注释。
- 所有[嵌套包含](includes.md#use-nested-includes)均以公共用户身份执行，没有上下文，因此你只能包含公共项目或模板。在嵌套包含的 `include` 部分中没有可用变量。

---

<a id="include-inputs"></a>

#### include:inputs

{{< history >}}

- 在极狐GitLab 15.11 中作为测试版功能[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/391331)。
- 在极狐GitLab 17.0 中[正式发布 (GA)](https://gitlab.com/gitlab-com/www-gitlab-com/-/merge_requests/134062)。

{{< /history >}}

当包含的配置使用 [`spec:inputs`](#specinputs) 并被添加到流水线中时，使用 `include:inputs` 设置输入参数的值。

**关键字类型**：全局关键字。

**支持的值**：字符串、数字值或布尔值。

**`include:inputs` 示例**：

```yaml
include:
  - local: 'custom_configuration.yml'
    inputs:
      website: "My website"
```

在此示例中：

- `custom_configuration.yml` 中包含的配置被添加到流水线中，并且对于包含的配置，`website` 输入被设置为值 `My website`。

**其他详细信息**：

- 如果包含的配置文件使用了 [`spec:inputs:type`](#specinputstype)，则输入值必须匹配定义的类型。
- 如果包含的配置文件使用了 [`spec:inputs:options`](#specinputsoptions)，则输入值必须匹配所列出的选项之一。

**相关主题**：

- [使用 `include` 时设置输入值](../inputs/_index.md#for-configuration-added-with-include)。

---

<a id="include-rules"></a>

#### include:rules

你可以将 [`rules`](#rules) 与 `include` 一起使用，以有条件地包含其他配置文件。

**关键字类型**：全局关键字。

**支持的值**：这些 `rules` 子键：

- [`rules:if`](#rulesif)。
- [`rules:exists`](#rulesexists)。
- [`rules:changes`](#ruleschanges)。

支持某些[CI/CD 变量](includes.md#use-variables-with-include)。

**`include:rules` 示例**：

```yaml
include:
  - local: build_jobs.yml
    rules:
      - if: $INCLUDE_BUILDS == "true"

test-job:
  stage: test
  script: echo "This is a test job"
```

在此示例中，如果 `INCLUDE_BUILDS` 变量为：

- `true`，则 `build_jobs.yml` 配置被包含在流水线中。
- 不是 `true` 或不存在，则 `build_jobs.yml` 配置不会被包含在流水线中。

**相关主题**：

- 结合使用 `include` 与：
  - [`rules:if`](includes.md#include-with-rulesif)。
  - [`rules:changes`](includes.md#include-with-ruleschanges)。
  - [`rules:exists`](includes.md#include-with-rulesexists)。

---

<a id="include-integrity"></a>

#### include:integrity

{{< history >}}

- 在极狐GitLab 17.9 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/178593)。

{{< /history >}}

将 `integrity` 与 `include:remote` 一起使用，以指定包含的远程文件的 SHA256 哈希值。
如果 `integrity` 与实际内容不匹配，则不会处理远程文件，并且流水线会失败。

**关键字类型**：全局关键字。

**支持的值**：包含内容的 Base64 编码的 SHA256 哈希值。

**`include:integrity` 示例**：

```yaml
include:
  - remote: 'https://gitlab.com/example-project/-/raw/main/.gitlab-ci.yml'
    integrity: 'sha256-L3/GAoKaw0Arw6hDCKeKQlV1QPEgHYxGBHsH4zG1IY8='
```

---

<a id="include-cache"></a>

#### include:cache

{{< details >}}

- 状态：实验

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.9 中作为[实验](../../policy/development_stages_support.md#experiment)引入，带有一个名为 `ci_cache_remote_includes` 的[功能标志](../../administration/feature_flags/_index.md)。默认禁用。

{{< /history >}}

{{< alert type="flag" >}}

此功能的可用性由功能标志控制。有关更多信息，请参阅历史记录。此功能可用作测试，但尚未准备好用于生产环境。

{{< /alert >}}

将 `cache` 与 `include:remote` 一起使用，以缓存获取的远程文件内容并减少 HTTP 请求。
启用后，远程文件将被缓存一段指定的生存时间 (TTL)，从而提高重复使用相同远程包含项的配置的流水线性能。

在设置缓存持续时间时，请考虑性能和新鲜度之间的权衡。较长的缓存持续时间可以提高性能，但如果远程文件频繁更改，可能会使用陈旧的内容。

如果未定义 `cache`，则每次都会获取远程文件。

**关键字类型**：全局关键字。

**支持的值**：

- `true`：启用缓存，默认生存时间 (TTL) 为 1 小时。
- 一个持续时间（字符串）：有效的 TTL 持续时间字符串使用时间单位，如 `minutes`、`hours` 或 `days`（最少 `1 minute`）。

**`include:cache` 示例**：

```yaml
include:
  - remote: 'https://gitlab.com/example-project/-/raw/main/sample1.gitlab-ci.yml'
    cache: true
  - remote: 'https://gitlab.com/example-project/-/raw/main/sample2.gitlab-ci.yml'
    cache: '1 day'
```

**其他详细信息**：

- 缓存仅适用于 `include:remote`。
- 远程文件被缓存后，将继续使用缓存的版本，直到 TTL 过期，即使远程文件的内容发生了更改也是如此。
- 如果你将 [`integrity`](#include-integrity) 与 `cache` 一起使用，则完整性检查会在每次流水线运行时执行，即使使用缓存的内容也是如此。

---

<a id="stages"></a>

### stages

{{< history >}}

- 在极狐GitLab 16.9 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/439451)了对嵌套字符串数组的支持。

{{< /history >}}

使用 `stages` 定义包含作业组的阶段。在作业中使用 [`stage`](#stage) 将作业配置为在特定阶段运行。

如果未在 `.gitlab-ci.yml` 文件中定义 `stages`，则默认的流水线阶段为：

- [`.pre`](#stage-pre)
- `build`
- `test`
- `deploy`
- [`.post`](#stage-post)

`stages` 中的项目顺序定义了作业的执行顺序：

- 同一阶段中的作业并行运行。
- 下一阶段的作业在上一阶段的作业成功完成后运行。

如果流水线仅包含 `.pre` 或 `.post` 阶段中的作业，则不会运行。必须至少有一个其他阶段的其他作业。

**关键字类型**：全局关键字。

**`stages` 示例**：

```yaml
stages:
  - build
  - test
  - deploy
```

在此示例中：

1. `build` 中的所有作业并行执行。
1. 如果 `build` 中的所有作业都成功，则 `test` 作业并行执行。
1. 如果 `test` 中的所有作业都成功，则 `deploy` 作业并行执行。
1. 如果 `deploy` 中的所有作业都成功，则将流水线标记为 `通过`。
如果任何作业失败，流水线会被标记为 `failed`，并且后续阶段的作业不会启动。当前阶段的作业不会停止，而是继续运行。

**额外细节**：

- 如果作业未指定 [`stage`](#stage)，则该作业被分配到 `test` 阶段。
- 如果定义了某个阶段但没有作业使用它，该阶段在流水线中不可见，这有助于[合规流水线配置](../../user/compliance/compliance_pipelines.md)：
  - 阶段可以在合规配置中定义，但如果未被使用则保持隐藏。
  - 当开发者在作业定义中使用这些阶段时，它们才会变为可见。

**相关主题**：

- 要让作业更早启动并忽略阶段顺序，请使用 [`needs`](#needs) 关键字。

---

<a id="workflow"></a>

### `workflow`

使用 [`workflow`](workflow.md) 来控制流水线行为。

你可以在 `workflow` 配置中使用一些[预定义的 CI/CD 变量](../variables/predefined_variables.md)，但不能使用仅在作业启动时才定义的变量。

**相关主题**：

- [`workflow: rules` 示例](workflow.md#workflow-rules-examples)
- [在分支流水线与合并请求流水线之间切换](workflow.md#switch-between-branch-pipelines-and-merge-request-pipelines)

---

<a id="workflow:auto_cancel:on_new_commit"></a>

#### `workflow:auto_cancel:on_new_commit`

{{< history >}}

- 于极狐GitLab 16.8 引入，并[使用功能标志](../../administration/feature_flags/_index.md)命名为 `ci_workflow_auto_cancel_on_new_commit`。默认禁用。
- 于极狐GitLab 16.9 在 JihuLab.com 和私有化部署上启用。
- 于极狐GitLab 16.10 GA。功能标志 `ci_workflow_auto_cancel_on_new_commit` 被移除。

{{< /history >}}

使用 `workflow:auto_cancel:on_new_commit` 来配置[自动取消冗余流水线](../pipelines/settings.md#auto-cancel-redundant-pipelines)功能的行为。

**支持的值**：

- `conservative`：取消流水线，但仅当尚未启动具有 `interruptible: false` 的任何作业时才取消。未定义时的默认值。
- `interruptible`：仅取消 `interruptible: true` 的作业。
- `none`：不自动取消任何作业。

**`workflow:auto_cancel:on_new_commit` 示例**：

```yaml
workflow:
  auto_cancel:
    on_new_commit: interruptible

job1:
  interruptible: true
  script: sleep 60

job2:
  interruptible: false  # 未定义时的默认值。
  script: sleep 60
```

在此示例中：

- 当新提交推送到分支时，极狐GitLab 创建新流水线并启动 `job1` 和 `job2`。
- 如果在作业完成之前又推送了一个新提交到该分支，则仅取消 `job1`。

---

<a id="workflow:auto_cancel:on_job_failure"></a>

#### `workflow:auto_cancel:on_job_failure`

{{< history >}}

- 于极狐GitLab 16.10 引入，并[使用功能标志](../../administration/feature_flags/_index.md)命名为 `auto_cancel_pipeline_on_job_failure`。默认禁用。
- 于极狐GitLab 16.11 GA。功能标志 `auto_cancel_pipeline_on_job_failure` 被移除。

{{< /history >}}

使用 `workflow:auto_cancel:on_job_failure` 来配置当某个作业失败时应立即取消哪些作业。

**支持的值**：

- `all`：一旦有作业失败，立即取消流水线和所有正在运行的作业。
- `none`：不自动取消任何作业。

**`workflow:auto_cancel:on_job_failure` 示例**：

```yaml
stages: [stage_a, stage_b]

workflow:
  auto_cancel:
    on_job_failure: all

job1:
  stage: stage_a
  script: sleep 60

job2:
  stage: stage_a
  script:
    - sleep 30
    - exit 1

job3:
  stage: stage_b
  script:
    - sleep 30
```

在此示例中，如果 `job2` 失败，若 `job1` 仍在运行，则它会被取消，且 `job3` 不会启动。

**相关主题**：

- [从下游流水线自动取消父流水线](../pipelines/downstream_pipelines.md#auto-cancel-the-parent-pipeline-from-a-downstream-pipeline)

---

<a id="workflow:name"></a>

#### `workflow:name`

{{< history >}}

- 于极狐GitLab 15.5 引入，并[使用功能标志](../../administration/feature_flags/_index.md)命名为 `pipeline_name`。默认禁用。
- 于极狐GitLab 15.7 在 JihuLab.com 和私有化部署上启用。
- 于极狐GitLab 15.8 GA。功能标志 `pipeline_name` 被移除。

{{< /history >}}

你可以使用 `workflow:` 中的 `name` 为流水线定义名称。

所有流水线都会被赋予所定义的名称。名称中任何前导或尾随空格都会被移除。

**支持的值**：

- 一个字符串。
- [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。
- 两者的组合。

**`workflow:name` 示例**：

一个带有预定义变量的简单流水线名称：

```yaml
workflow:
  name: '分支流水线: $CI_COMMIT_BRANCH'
```

根据流水线条件使用不同流水线名称的配置：

```yaml
variables:
  PROJECT1_PIPELINE_NAME: '默认流水线名称'  # 非必需的默认值

workflow:
  name: '$PROJECT1_PIPELINE_NAME'
  rules:
    - if: '$CI_MERGE_REQUEST_LABELS =~ /pipeline:run-in-ruby3/'
      variables:
        PROJECT1_PIPELINE_NAME: 'Ruby 3 流水线'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      variables:
        PROJECT1_PIPELINE_NAME: 'MR 流水线: $CI_MERGE_REQUEST_SOURCE_BRANCH_NAME'
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH  # 对于默认分支流水线，使用默认名称
```

**额外细节**：

- 如果名称为空字符串，则流水线不会被分配名称。仅由 CI/CD 变量组成的名称，如果所有变量都为空，也可能评估为空字符串。
- `workflow:rules:variables` 会成为所有作业中可用的[默认变量](#default-variables)，包括 [`trigger`](#trigger) 作业，这些作业默认会将变量转发到下游流水线。如果下游流水线使用了相同的变量，则[变量会被上游变量值覆盖](../variables/_index.md#cicd-variable-precedence)。请务必：
  - 在每个项目的流水线配置中使用唯一的变量名，例如 `PROJECT1_PIPELINE_NAME`。
  - 在 trigger 作业中使用 [`inherit:variables`](#inheritvariables)，并列出你想要转发到下游流水线的确切变量。

---

<a id="workflow:rules"></a>

#### `workflow:rules`

`workflow` 中的 `rules` 关键字类似于[作业中定义的 `rules`](#rules)，但用于控制是否创建整个流水线。

如果没有规则评估为 true，则流水线不运行。

**支持的值**：你可以使用与作业级别 [`rules`](#rules) 相同的一些关键字：

- [`rules: if`](#rulesif)。
- [`rules: changes`](#ruleschanges)。
- [`rules: exists`](#rulesexists)。
- [`when`](#when)，当与 `workflow` 一起使用时只能为 `always` 或 `never`。
- [`variables`](#workflowrulesvariables)。

**`workflow:rules` 示例**：

```yaml
workflow:
  rules:
    - if: $CI_COMMIT_TITLE =~ /-draft$/
      when: never
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

在此示例中，如果提交标题（提交信息的第一行）不以 `-draft` 结尾，并且流水线是针对以下之一，则流水线会运行：

- 合并请求
- 默认分支。

**额外细节**：

- 如果你的规则同时匹配分支流水线（除默认分支外）和合并请求流水线，可能会导致[重复流水线](../jobs/job_rules.md#avoid-duplicate-pipelines)。
- `workflow:rules` 中不支持 `start_in`、`allow_failure` 和 `needs`，但它们不会导致语法违规。尽管它们没有效果，但不建议在 `workflow:rules` 中使用，因为未来可能引发语法错误。详情参见[issue 436473](https://gitlab.com/gitlab-org/gitlab/-/issues/436473)。

**相关主题**：

- [常见的 `workflow:rules` 中的 `if` 子句](workflow.md#common-if-clauses-for-workflowrules)。
- [使用 `rules` 运行合并请求流水线](../pipelines/merge_request_pipelines.md#configure-merge-request-pipelines)。

---

<a id="workflow:rules:variables"></a>

#### `workflow:rules:variables`

你可以在 `workflow:rules` 中使用 [`variables`](#variables) 为特定的流水线条件定义变量。

当条件匹配时，变量被创建，并且可供流水线中的所有作业使用。如果该变量已在顶层定义为默认变量，则 `workflow` 变量会优先并覆盖默认变量。

**关键字类型**：全局关键字。

**支持的值**：变量名和值对：

- 名称只能使用数字、字母和下划线（`_`）。
- 值必须是一个字符串。

**`workflow:rules:variables` 示例**：

```yaml
variables:
  DEPLOY_VARIABLE: "default-deploy"

workflow:
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      variables:
        DEPLOY_VARIABLE: "deploy-production"  # 覆盖全局定义的 DEPLOY_VARIABLE
    - if: $CI_COMMIT_BRANCH =~ /feature/
      variables:
        IS_A_FEATURE: "true"                  # 定义一个新变量。
    - if: $CI_COMMIT_BRANCH                   # 在其他情况下运行流水线

job1:
  variables:
    DEPLOY_VARIABLE: "job1-default-deploy"
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      variables:                                   # 覆盖在作业级别定义的
        DEPLOY_VARIABLE: "job1-deploy-production"  # DEPLOY_VARIABLE。
    - when: on_success                             # 在其他情况下运行作业
  script:
    - echo "使用 $DEPLOY_VARIABLE 作为参数运行脚本"
    - echo "如果 $IS_A_FEATURE 存在，运行另一个脚本"

job2:
  script:
    - echo "使用 $DEPLOY_VARIABLE 作为参数运行脚本"
    - echo "如果 $IS_A_FEATURE 存在，运行另一个脚本"
```

当分支是默认分支时：

- job1 的 `DEPLOY_VARIABLE` 是 `job1-deploy-production`。
- job2 的 `DEPLOY_VARIABLE` 是 `deploy-production`。

当分支是 `feature` 时：

- job1 的 `DEPLOY_VARIABLE` 是 `job1-default-deploy`，且 `IS_A_FEATURE` 是 `true`。
- job2 的 `DEPLOY_VARIABLE` 是 `default-deploy`，且 `IS_A_FEATURE` 是 `true`。

当分支是其他情况时：

- job1 的 `DEPLOY_VARIABLE` 是 `job1-default-deploy`。
- job2 的 `DEPLOY_VARIABLE` 是 `default-deploy`。

**额外细节**：

- `workflow:rules:variables` 会成为所有作业中可用的[默认变量](#variables)，包括 [`trigger`](#trigger) 作业，这些作业默认会将变量转发到下游流水线。如果下游流水线使用了相同的变量，则[变量会被上游变量值覆盖](../variables/_index.md#cicd-variable-precedence)。请务必：
  - 在每个项目的流水线配置中使用唯一的变量名，例如 `PROJECT1_VARIABLE_NAME`。
  - 在 trigger 作业中使用 [`inherit:variables`](#inheritvariables)，并列出你想要转发到下游流水线的确切变量。

---

<a id="workflow:rules:auto_cancel"></a>

#### `workflow:rules:auto_cancel`

{{< history >}}

- 于极狐GitLab 16.8 引入，并[使用功能标志](../../administration/feature_flags/_index.md)命名为 `ci_workflow_auto_cancel_on_new_commit`。默认禁用。
- 于极狐GitLab 16.9 在 JihuLab.com 和私有化部署上启用。
- 于极狐GitLab 16.10 GA。功能标志 `ci_workflow_auto_cancel_on_new_commit` 被移除。
- `workflow:rules` 的 `on_job_failure` 选项于极狐GitLab 16.10 引入，并[使用功能标志](../../administration/feature_flags/_index.md)命名为 `auto_cancel_pipeline_on_job_failure`。默认禁用。
- `workflow:rules` 的 `on_job_failure` 选项于极狐GitLab 16.11 GA。功能标志 `auto_cancel_pipeline_on_job_failure` 被移除。

{{< /history >}}

使用 `workflow:rules:auto_cancel` 来配置
[`workflow:auto_cancel:on_new_commit`](#workflowauto_cancelon_new_commit) 或
[`workflow:auto_cancel:on_job_failure`](#workflowauto_cancelon_job_failure) 功能的行为。

**支持的值**：

- `on_new_commit`：[`workflow:auto_cancel:on_new_commit`](#workflowauto_cancelon_new_commit)
- `on_job_failure`：[`workflow:auto_cancel:on_job_failure`](#workflowauto_cancelon_job_failure)

**`workflow:rules:auto_cancel` 示例**：

```yaml
workflow:
  auto_cancel:
    on_new_commit: interruptible
    on_job_failure: all
  rules:
    - if: $CI_COMMIT_REF_PROTECTED == 'true'
      auto_cancel:
        on_new_commit: none
        on_job_failure: none
    - when: always                  # 在其他情况下运行流水线

test-job1:
  script: sleep 10
  interruptible: false

test-job2:
  script: sleep 10
  interruptible: true
```

在此示例中，默认情况下，所有作业的 [`workflow:auto_cancel:on_new_commit`](#workflowauto_cancelon_new_commit) 设置为 `interruptible`，
[`workflow:auto_cancel:on_job_failure`](#workflowauto_cancelon_job_failure) 设置为 `all`。但是，如果流水线针对受保护分支运行，
该规则会以 `on_new_commit: none` 和 `on_job_failure: none` 覆盖默认值。例如，如果流水线正在运行：

- 针对非受保护分支，并且推送了新提交，则 `test-job1` 继续运行，`test-job2` 被取消。
- 针对受保护分支，并且推送了新提交，则 `test-job1` 和 `test-job2` 都继续运行。

---

<a id="header-keywords"></a>

## Header 关键字

某些关键字必须在 YAML 配置文件的头部区域中定义。
头部必须位于文件顶部，并使用 `---` 与其余配置分开。

---

<a id="spec"></a>

### `spec`

{{< history >}}

- 于极狐GitLab 15.11 作为 Beta 功能引入。

{{< /history >}}

在 YAML 文件的头部添加一个 `spec` 部分，以配置当通过 `include` 关键字将配置添加到流水线时的行为。

Spec 必须在配置文件顶部声明，位于通过 `---` 与其余配置分隔的头部区域中。

---

<a id="spec:inputs"></a>

#### `spec:inputs`

你可以使用 `spec:inputs` 为 CI/CD 配置定义[输入](../inputs/_index.md)。

使用插值格式 `$[[ inputs.input-id ]]` 在头部区域之外引用这些值。
输入在流水线创建期间获取配置时被评估和插值。
使用 `inputs` 时，插值会在配置与 `.gitlab-ci.yml` 文件内容合并之前完成。

**关键字类型**：Header 关键字。`spec` 必须在配置文件顶部、头部区域中声明。

**支持的值**：表示预期输入的字符串哈希。

**`spec:inputs` 示例**：

```yaml
spec:
  inputs:
    environment:
    job-stage:
---

scan-website:
  stage: $[[ inputs.job-stage ]]
  script: ./scan-website $[[ inputs.environment ]]
```

**额外细节**：

- 除非你使用 [`spec:inputs:default`](#specinputsdefault) 设置默认值，否则输入是强制性的。除非你仅将输入与 [`include:inputs`](#includeinputs) 一起使用，否则请避免使用必填输入。
- 除非你使用 [`spec:inputs:type`](#specinputstype) 设置不同的输入类型，否则输入期望为字符串。
- 包含插值块的字符串不得超过 1 MB。
- 插值块内的字符串不得超过 1 KB。
- 你可以在[运行新流水线时](../inputs/_index.md#for-a-pipeline)定义输入值。

**相关主题**：

- [使用 `spec:inputs` 定义输入参数](../inputs/_index.md#define-input-parameters-with-specinputs)。

---

<a id="spec:inputs:default"></a>

##### `spec:inputs:default`

{{< history >}}

- 于极狐GitLab 15.11 作为 Beta 功能引入。

{{< /history >}}

当被包含时，输入是必填的，除非你使用 `spec:inputs:default` 设置了默认值。

使用 `default: ''` 表示没有默认值。

**关键字类型**：Header 关键字。`spec` 必须在配置文件顶部、头部区域中声明。

**支持的值**：表示默认值的字符串，或 `''`。

**`spec:inputs:default` 示例**：

```yaml
spec:
  inputs:
    website:
    user:
      default: 'test-user'
    flags:
      default: ''
---
# 后续是流水线配置...
```

在此示例中：

- `website` 是强制性的，必须定义。
- `user` 是可选的。如果未定义，则值为 `test-user`。
- `flags` 是可选的。如果未定义，则没有值。

**额外细节**：

- 当输入出现以下情况时，流水线会失败并显示验证错误：
  - 同时使用了 `default` 和 [`options`](#specinputsoptions)，但默认值不在所列的选项中。
  - 同时使用了 `default` 和 `regex`，但默认值不匹配正则表达式。
  - 值不匹配 [`type`](#specinputstype)。

---

<a id="spec:inputs:description"></a>

##### `spec:inputs:description`

{{< history >}}

- 于极狐GitLab 16.5 引入。

{{< /history >}}

使用 `description` 为特定输入提供描述。该描述不影响输入的行为，仅用于帮助文件使用者理解该输入。

**关键字类型**：Header 关键字。`spec` 必须在配置文件顶部、头部区域中声明。

**支持的值**：表示描述的字符串。

**`spec:inputs:description` 示例**：

```yaml
spec:
  inputs:
    flags:
      description: '`flags` 输入细节的示例描述。'
---
# 后续是流水线配置...
```

---

<a id="spec:inputs:options"></a>

##### `spec:inputs:options`

{{< history >}}

- 于极狐GitLab 16.6 引入。
- 对数组类型输入的支持于极狐GitLab 19.0 引入。

{{< /history >}}

输入可以使用 `options` 来指定允许值列表。
每个输入的限制为 50 个选项。

**关键字类型**：Header 关键字。`spec` 必须在配置文件顶部、头部区域中声明。

**支持的值**：输入选项数组。

**`spec:inputs:options` 示例**：

```yaml
spec:
  inputs:
    environment:
      options:
        - development
        - staging
        - production
---
# 后续是流水线配置...
```

在此示例中：

- `environment` 是强制性的，并且必须使用列表中的某个值进行定义。

**额外细节**：

- 当出现以下情况时，流水线会失败并显示验证错误：
  - 输入同时使用了 `options` 和 [`default`](#specinputsdefault)，但默认值不在所列的选项中。
  - 任何输入选项不匹配 [`type`](#specinputstype)，当使用 `options` 时，类型可以是 `string` 或 `number`，但不能是 `boolean`。

---

<a id="spec:inputs:regex"></a>

##### `spec:inputs:regex`

{{< history >}}

- 于极狐GitLab 16.5 引入。

{{< /history >}}

使用 `spec:inputs:regex` 指定输入必须匹配的正则表达式。

**关键字类型**：Header 关键字。`spec` 必须在配置文件顶部、头部区域中声明。

**支持的值**：必须是一个正则表达式。

**`spec:inputs:regex` 示例**：

```yaml
spec:
  inputs:
    version:
      regex: ^v\d\.\d+(\.\d+)?$
---
# 后续是流水线配置...
```

在此示例中，`v1.0` 或 `v1.2.3` 等输入与正则表达式匹配并通过验证。
而 `v1.A.B` 等输入不匹配正则表达式，会导致验证失败。

**额外细节**：

- `inputs:regex` 只能与 [`type`](#specinputstype) 为 `string` 一起使用，不能与 `number` 或 `boolean` 一起使用。
- 不要用 `/` 字符将正则表达式括起来。例如，使用 `regex.*`，而不是 `/regex.*/`。
- `inputs:regex` 使用 [RE2](https://github.com/google/re2/wiki/Syntax) 解析正则表达式。
- 对正则表达式的输入验证发生在变量展开之前。如果输入文本包含变量名，则验证的是输入的原始值（变量名），而不是变量值。

---

<a id="spec:inputs:rules"></a>

##### `spec:inputs:rules`

{{< history >}}

- 于极狐GitLab 18.7 引入。

{{< /history >}}

使用 `spec:inputs:rules` 基于其他输入的值，为某个输入定义条件性的 `options` 和 `default` 值。

**关键字类型**：Header 关键字。`spec` 必须在配置文件顶部、头部区域中声明。

**支持的值**：规则对象数组。每个规则都可以包含：

- `if`：检查输入值的条件表达式，使用 [`$[[ inputs.input-id ]]` 语法](../inputs/_index.md#define-input-parameters-with-specinputs)。
- `options`：该输入允许的值数组。
- `default`：当此规则匹配时该输入的默认值。使用 [`default: null`](../inputs/_index.md#allow-user-entered-values-with-default-null) 允许用户为该输入输入自己的值。

**`spec:inputs:rules` 示例**：

```yaml
spec:
  inputs:
    environment:
      options: ['development', 'production']
      default: 'development'

    instance_type:
      description: '虚拟机实例大小'
      rules:
        - if: $[[ inputs.environment ]] == 'development'
          options: ['small', 'medium']
          default: 'small'
        - if: $[[ inputs.environment ]] == 'production'
          options: ['large', 'xlarge']
          default: 'large'
---

deploy:
  script: echo "部署 $[[ inputs.instance_type ]] 实例"
```

在此示例中，当 `environment` 为 `development` 时，用户只能选择 `small` 或 `medium` 实例。当 `environment` 为 `production` 时，仅提供 `large` 或 `xlarge` 实例。

**额外细节**：

- 规则按顺序评估。第一个具有匹配 `if` 条件的规则会被使用。
- 没有 `if` 条件的规则充当其他规则都不匹配时的回退。
- 回退规则必须定义至少包含一个值的 `options`。
- 所有带有 `options` 的规则，也必须定义一个存在于 `options` 列表中的 `default` 值。
- 对于同一个输入，不能同时使用 `rules` 和顶层的 `options` 或 `default`。

**相关主题**：

- [使用 `spec:inputs:rules` 定义条件性输入选项](../inputs/_index.md#define-conditional-input-options-with-specinputsrules)。

---

<a id="spec:inputs:type"></a>

##### `spec:inputs:type`

默认情况下，输入期望为字符串。使用 `spec:inputs:type` 为输入设置不同的必需类型。

**关键字类型**：Header 关键字。`spec` 必须在配置文件顶部、头部区域中声明。

**支持的值**：可以是以下之一：

- `array`，接受[数组](../inputs/_index.md#array-type)输入。
- `string`，接受字符串输入（未定义时的默认值）。
- `number`，仅接受数值输入。
- `boolean`，仅接受 `true` 或 `false` 输入。

**`spec:inputs:type` 示例**：

```yaml
spec:
  inputs:
    job_name:
    website:
      type: string
    port:
      type: number
    available:
      type: boolean
    array_input:
      type: array
---
# 后续是流水线配置...
```

---

<a id="spec:include"></a>

#### `spec:include`

{{< history >}}

- 于极狐GitLab 18.6 引入，并[使用功能标志](../../administration/feature_flags/_index.md)命名为 `ci_file_inputs`。默认禁用。
- 于极狐GitLab 18.9 GA。功能标志 `ci_file_inputs` 被移除。

{{< /history >}}

使用 `spec:include` 从其他文件中包含外部输入定义。
你可以在多个流水线配置之间共享和重用输入定义。

**关键字类型**：Header 关键字。`spec` 必须在配置文件顶部、头部区域中声明。

**支持的值**：include 位置的数组。仅支持 `local`、`remote` 和 `project` 包含类型。

**`spec:include` 示例**：

```yaml
spec:
  include:
    - local: /shared-inputs.yml
  inputs:
    environment:
      default: production
---

deploy:
  script: echo "部署到 $[[ inputs.environment ]]"
```

从不同来源进行多个包含的示例：

```yaml
spec:
  include:
    - local: /base-inputs.yml
    - remote: 'https://example.com/ci/common-inputs.yml'
    - project: 'my-group/shared-configs'
      ref: main
      file: '/ci/team-inputs.yml'
  inputs:
    environment:
      default: production
---

deploy:
  script: echo "部署到 $[[ inputs.environment ]]"
```

**额外细节**：
- 你不能在 [CI/CD 组件](../components/_index.md#component-spec-section) 中使用 `spec:include`。
- 外部输入文件必须只包含 `inputs` 键。其他键会导致验证错误。
- 外部输入优先合并，然后应用内联输入。
- 内联输入不能与包含的输入名称相同。
- 当包含多个输入文件时，它们将按照指定的顺序合并。
- 支持 [`local`](#includelocal)、[`remote`](#includeremote) 和 [`project`](#includeproject) 包含类型。
  不支持 `template`、`component` 或 `artifact` 包含。

**相关主题**：

- [使用来自外部文件的输入](../inputs/_index.md#define-pipeline-inputs-in-external-files)。

---

<a id="spec-component"></a>

#### 组件规范

{{< history >}}

- 在 极狐GitLab 18.6 中作为 [测试版](../../policy/development_stages_support.md#beta) [带有一个功能标志](../../administration/feature_flags/_index.md) 引入，名为 `ci_component_context_interpolation`。默认启用。
- 在 极狐GitLab 18.7 中 GA。功能标志 `ci_component_context_interpolation` 已移除。

{{< /history >}}

使用 `spec:component` 定义哪些组件上下文数据可用于 [CI/CD 组件](../components/_index.md) 中的插值。

组件上下文提供有关组件本身的元数据，例如其名称、版本和提交 SHA。这允许组件模板动态引用其自己的元数据。

使用插值格式 `$[[ component.field-name ]]` 在组件模板中引用组件上下文值。

**关键字类型**：Header 关键字。`spec` 必须声明在配置文件的顶部，位于头部区域。

**支持的值**：一个字符串数组。每个字符串必须是以下之一：

- `name`：组件路径中指定的组件名称。
- `sha`：组件的提交 SHA。
- `version`：从目录资源解析出的语义版本。如果出现以下情况，则返回 `null`：
  - 组件不是目录资源。
  - 引用是分支名称或提交 SHA（非发布版本）。
- `reference`：在组件路径中 `@` 之后指定的原始引用。
  例如 `1.0`、`~latest`、分支名称或提交 SHA。

**`spec:component` 示例**：

```yaml
spec:
  component: [name, version, reference]
  inputs:
    stage:
      default: build
---

build-image:
  stage: $[[ inputs.stage ]]
  image: registry.example.com/$[[ component.name ]]:$[[ component.version ]]
  script:
    - echo "Building with component version $[[ component.version ]]"
    - echo "Component reference: $[[ component.reference ]]"
```

**附加详情**：

- 当使用以下方式时，`version` 字段解析为实际的语义版本：
  - 完整版本，如 `@1.0.0`（返回 `1.0.0`）
  - 部分版本，如 `@1.0`（返回最新匹配版本，例如 `1.0.2`）
  - `@~latest`（返回最新版本）
- `reference` 字段始终返回 `@` 后指定的确切值：
  - `@1.0` 返回 `1.0`（而 `version` 可能返回 `1.0.2`）
  - `@~latest` 返回 `~latest`（而 `version` 返回实际版本号）
  - `@abc123` 返回 `abc123`（而 `version` 返回 `null`）

**相关主题**：

- [在组件中使用组件上下文](../components/_index.md#use-component-context-in-components)。

---

<a id="spec-description"></a>

#### 描述规范

{{< history >}}

- 在 极狐GitLab 18.10 中引入。

{{< /history >}}

使用 `spec:description` 提供组件的简短描述。该描述会显示在 CI/CD 目录的组件详情页面上，位于输入表上方。

**关键字类型**：Header 关键字。`spec` 必须声明在配置文件的顶部，位于头部区域。

**支持的值**：描述组件的字符串。

**`spec:description` 示例**：

```yaml
spec:
  description: "A description of the component visible to users in the CI/CD Catalog."
  inputs:
    stage:
      default: test
---
scan-job:
  stage: $[[ inputs.stage ]]
  script: ./run-scan.sh
```

---

## 作业关键字

以下主题说明如何使用关键字配置 CI/CD 流水线。

---

<a id="after_script"></a>

### 后脚本

{{< history >}}

- 在 极狐GitLab 17.0 中引入了对已取消作业运行 `after_script` 命令的支持。

{{< /history >}}

使用 `after_script` 定义一个命令数组，这些命令会在作业的 `before_script` 和 `script` 部分完成后最后运行。当以下情况发生时，`after_script` 命令也会运行：

- 作业在运行 `before_script` 或 `script` 部分时被取消。
- 作业失败，失败类型为 `script_failure`，但不是 [其他失败类型](#retrywhen)。

作业配置与默认配置不会合并在一起。
如果流水线定义了 [`default:after_script`](#default)，并且作业也定义了 `after_script`，则作业配置优先，默认配置不会被使用。

**关键字类型**：作业关键字。你只能将其用作作业的一部分，或在 [`default` 部分](#default) 中使用。

**支持的值**：一个数组，包括：

- 单行命令。
- [跨多行拆分的长命令](script.md#split-long-commands)。
- [YAML 锚点](yaml_optimization.md#yaml-anchors-for-scripts)。

[CI/CD 变量受支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。

**`after_script` 示例**：

```yaml
job:
  script:
    - echo "An example script section."
  after_script:
    - echo "Execute this command after the `script` section completes."
```

**附加详情**：

你在 `after_script` 中指定的脚本在新的 shell 中执行，与任何 `before_script` 或 `script` 命令分开。因此，它们：

- 当前工作目录被重置为默认值（根据 [定义 Runner 处理 Git 请求方式的变量](../runners/configure_runners.md#configure-runner-behavior-with-variables)）。
- 无法访问由 `before_script` 或 `script` 中的命令所做的更改，包括：
  - 在 `script` 脚本中导出的命令别名和变量。
  - 工作树之外的变化（取决于 runner 执行器），比如由 `before_script` 或 `script` 脚本安装的软件。
- 有独立的超时时间。对于 极狐GitLab Runner 16.4 及更高版本，默认超时为 5 分钟，可以通过 [`RUNNER_AFTER_SCRIPT_TIMEOUT`](../runners/configure_runners.md#set-script-and-after_script-timeouts) 变量进行配置。
  在 极狐GitLab 16.3 及更早版本中，超时时间硬编码为 5 分钟。
- 不影响作业的退出代码。如果 `script` 部分成功，而 `after_script` 超时或失败，作业将以代码 `0`（`作业成功`）退出。
- 对于超时的作业：
  - 默认情况下不执行 `after_script` 命令。
  - 你可以 [配置超时值](../runners/configure_runners.md#ensuring-after_script-execution) 以确保 `after_script` 运行，方法是设置适当的 `RUNNER_SCRIPT_TIMEOUT` 和 `RUNNER_AFTER_SCRIPT_TIMEOUT` 值，这些值不超过作业的超时时间。
- 在顶层使用 `after_script`，但不在 `default` 部分中使用，是 [已弃用的](deprecated_keywords.md#globally-defined-image-services-cache-before_script-after_script)。

**执行时机和文件包含**：

`after_script` 命令在产物上传操作之前执行。

- 如果你配置了产物收集：
  - 在 `after_script` 中创建或修改的文件会包含在产物中。
  - 在 `after_script` 中所做的更改会包含在缓存上传中。
- 任何由 `after_script` 在指定的缓存或产物路径中创建或修改的文件都会被捕获并上传。你可以利用这个时机实现以下场景：
  - 在主脚本之后生成测试报告或覆盖率数据。
  - 创建摘要文件或日志。
  - 对构建输出进行后处理。

在以下示例中，唯一未包含的文件是在产物或缓存上传阶段之后创建或修改的文件：

```yaml
job:
  script:
    - echo "main" > output.txt
    - build_something

  after_script:
    - echo "modified in after_script" >> output.txt  # 这将包含在产物中
    - generate_test_report > report.html            # 这将包含在产物中

  artifacts:
    paths:
      - output.txt
      - report.html

  cache:
    paths:
      - output.txt  # 将包含 "modified in after_script" 行
```

有关更多信息，请参阅 [作业执行流程](../jobs/job_execution.md)。

**相关主题**：

- 使用 [`after_script` 与 `default`](script.md#set-a-default-before_script-or-after_script-for-all-jobs) 为所有作业定义一个应在之后运行的默认命令数组。
- 你可以配置作业以 [在作业被取消时跳过 `after_script` 命令](script.md#skip-after_script-commands-if-a-job-is-canceled)。
- 你可以 [忽略非零退出代码](script.md#ignore-non-zero-exit-codes)。
- [为 `after_script` 的输出添加颜色代码](script.md#add-color-codes-to-script-output) 以使作业日志更易于审查。
- [创建自定义可折叠部分](../jobs/job_logs.md#create-custom-collapsible-sections) 以简化作业日志输出。
- 你可以 [忽略 `after_script` 中的错误](../runners/configure_runners.md#ignore-errors-in-after_script)。

---

<a id="allow_failure"></a>

### 允许失败

使用 `allow_failure` 来确定当作业失败时流水线是否应继续运行。

- 要允许流水线继续运行后续作业，请使用 `allow_failure: true`。
- 要停止流水线运行后续作业，请使用 `allow_failure: false`。

当作业被允许失败时（`allow_failure: true`），会显示一个橙色警告（{{< icon name="status_warning" >}}）指示作业失败。但是，流水线是成功的，并且关联的提交被标记为通过，没有任何警告。

当以下情况时，也会显示相同的警告：

- 该阶段中的所有其他作业都成功。
- 流水线中的所有其他作业都成功。

`allow_failure` 的默认值是：

- 对于 [手动作业](../jobs/job_control.md#create-a-job-that-must-be-run-manually)，为 `true`。
- 对于在 [`rules`](#rules) 中使用 `when: manual` 的作业，为 `false`。
- 在所有其他情况下，为 `false`。

**关键字类型**：作业关键字。你只能将其用作作业的一部分。

**支持的值**：

- `true` 或 `false`。

**`allow_failure` 示例**：

```yaml
job1:
  stage: test
  script:
    - execute_script_1

job2:
  stage: test
  script:
    - execute_script_2
  allow_failure: true

job3:
  stage: deploy
  script:
    - deploy_to_staging
  environment: staging
```

在此示例中，`job1` 和 `job2` 并行运行：

- 如果 `job1` 失败，`deploy` 阶段的作业不会启动。
- 如果 `job2` 失败，`deploy` 阶段的作业仍然可以启动。

**附加详情**：

- 你可以将 `allow_failure` 用作 [`rules`](#rulesallow_failure) 的子键。
- 如果设置了 `allow_failure: true`，则作业始终被视为成功，并且如果此作业失败，具有 [`when: on_failure`](#when) 的后续作业不会启动。
- 你可以对手动作业使用 `allow_failure: false` 来创建 [阻塞性手动作业](../jobs/job_control.md#types-of-manual-jobs)。阻塞的流水线不会运行后续阶段的任何作业，直到该手动作业启动并成功完成。

---

<a id="allow_failure-exit_codes"></a>

#### 允许失败：退出代码

使用 `allow_failure:exit_codes` 控制何时应允许作业失败。对于列出的任何退出代码，作业视为 `allow_failure: true`，对于任何其他退出代码，则 `allow_failure` 为 false。

**关键字类型**：作业关键字。你只能将其用作作业的一部分。

**支持的值**：

- 单个退出代码。
- 退出代码数组。

**`allow_failure` 示例**：

```yaml
test_job_1:
  script:
    - echo "Run a script that results in exit code 1. This job fails."
    - exit 1
  allow_failure:
    exit_codes: 137

test_job_2:
  script:
    - echo "Run a script that results in exit code 137. This job is allowed to fail."
    - exit 137
  allow_failure:
    exit_codes:
      - 137
      - 255
```

---

<a id="artifacts"></a>

### 产物

{{< history >}}

- 在 极狐GitLab Runner 18.1 中 [更新](https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/5543)。在缓存过程中，不再跟随 `symlinks`，这在此前的 极狐GitLab Runner 版本中某些边缘情况下会发生。

{{< /history >}}

使用 `artifacts` 指定要保存为 [作业产物](../jobs/job_artifacts.md) 的文件。作业产物是附加到作业的文件和目录列表，当作业 [成功、失败或始终](#artifactswhen) 时会附加。

产物会在作业完成后发送给 极狐GitLab。如果大小小于 [最大产物大小](../../user/jihulab_com/_index.md#gitlab-cicd)，则可以在 极狐GitLab UI 中下载。

默认情况下，后续阶段的作业会自动下载较早阶段作业创建的所有产物。你可以使用 [`dependencies`](#dependencies) 控制作业中的产物下载行为。

当使用 [`needs`](#needs) 关键字时，作业只能从 `needs` 配置中定义的作业下载产物。

作业产物默认仅针对成功的作业进行收集，并且产物会在 [缓存](#cache) 之后恢复。

作业配置与默认配置不会合并在一起。
如果流水线定义了 [`default:artifacts`](#default)，并且作业也定义了 `artifacts`，则作业配置优先，默认配置不会被使用。

[阅读有关产物的更多信息](../jobs/job_artifacts.md)。

---

<a id="artifacts-paths"></a>

#### 产物路径

路径相对于项目目录（`$CI_PROJECT_DIR`），不能直接链接到其外部。

**关键字类型**：作业关键字。你只能将其用作作业的一部分，或在 [`default` 部分](#default) 中使用。

**支持的值**：

- 一个文件路径数组，相对于项目目录。
- 你可以使用使用 [glob](https://en.wikipedia.org/wiki/Glob_(programming)) 模式和 [`doublestar.Glob`](https://pkg.go.dev/github.com/bmatcuk/doublestar@v1.2.2?tab=doc#Match) 模式的通配符。
- 对于 [极狐GitLab Pages 作业](#pages)：
  - 在 [极狐GitLab 17.10 及更高版本](https://gitlab.com/gitlab-org/gitlab/-/issues/428018) 中，[`pages.publish`](#pagespublish) 路径会自动附加到 `artifacts:paths`，因此你无需再次指定。
  - 在 [极狐GitLab 17.10 及更高版本](https://gitlab.com/gitlab-org/gitlab/-/issues/428018) 中，如果未指定 [`pages.publish`](#pagespublish) 路径，则 `public` 目录会自动附加到 `artifacts:paths`。

支持 [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。

**`artifacts:paths` 示例**：

```yaml
job:
  artifacts:
    paths:
      - binaries/
      - .config
```

此示例创建一个包含 `.config` 和 `binaries` 目录中所有文件的产物。

**附加详情**：

- 如果未与 [`artifacts:name`](#artifactsname) 一起使用，产生的文件将命名为 `artifacts`，下载时变为 `artifacts.zip`。

**相关主题**：

- 要限制特定作业从哪些作业获取产物，请参见 [`dependencies`](#dependencies)。
- [创建作业产物](../jobs/job_artifacts.md#create-job-artifacts)。

---

<a id="artifacts-exclude"></a>

#### 产物排除

使用 `artifacts:exclude` 防止文件被添加到产物存档中。

**关键字类型**：作业关键字。你只能将其用作作业的一部分，或在 [`default` 部分](#default) 中使用。

**支持的值**：

- 一个文件路径数组，相对于项目目录。
- 你可以使用使用 [glob](https://en.wikipedia.org/wiki/Glob_(programming)) 或 [`doublestar.PathMatch`](https://pkg.go.dev/github.com/bmatcuk/doublestar@v1.2.2?tab=doc#PathMatch) 模式的通配符。

**`artifacts:exclude` 示例**：

```yaml
artifacts:
  paths:
    - binaries/
  exclude:
    - binaries/**/*.o
```

此示例存储 `binaries/` 中的所有文件，但不存储位于 `binaries/` 子目录中的 `*.o` 文件。

**附加详情**：

- `artifacts:exclude` 路径不会被递归搜索。
- 也可以使用 `artifacts:exclude` 排除由 [`artifacts:untracked`](#artifactsuntracked) 匹配的文件。

**相关主题**：

- [从作业产物中排除文件](../jobs/job_artifacts.md#without-excluded-files)。

---

<a id="artifacts-expire_in"></a>

#### 产物过期时间

使用 `expire_in` 指定 [作业产物](../jobs/job_artifacts.md) 在被删除之前存储多长时间。`expire_in` 设置不影响：

- 来自最新作业的产物，除非在 [项目级别](../jobs/job_artifacts.md#keep-artifacts-from-most-recent-successful-jobs) 或 [实例范围](../../administration/settings/continuous_integration.md#keep-artifacts-from-latest-successful-pipelines) 中禁用了保留最新作业产物。

超时后，产物会每小时（使用 cron 作业）默认删除，并且不再可访问。

**关键字类型**：作业关键字。你只能将其用作作业的一部分，或在 [`default` 部分](#default) 中使用。

**支持的值**：过期时间。如果未提供单位，则时间以秒为单位。有效值包括：

- `'42'`
- `42 seconds`
- `3 mins 4 sec`
- `2 hrs 20 min`
- `2h20min`
- `6 mos 1 day`
- `47 yrs 6 mos and 4d`
- `3 weeks and 2 days`
- `never`

**`artifacts:expire_in` 示例**：

```yaml
job:
  artifacts:
    expire_in: 1 week
```

**附加详情**：

- 过期时间周期从产物上传并存储在 极狐GitLab 上时开始计算。如果未定义过期时间，则默认为 [实例范围的设置](../../administration/settings/continuous_integration.md#set-default-artifacts-expiration)。
- 要覆盖过期日期并保护产物不被自动删除：
  - 在作业页面上选择 **保留**。
  - 将 `expire_in` 的值设置为 `never`。
- 如果过期时间太短，在长时间流水线的后续阶段中的作业可能会尝试从较早作业中获取已过期的产物。如果产物已过期，尝试获取它们的作业将失败，并显示 [`无法检索所需产物` 错误](../jobs/job_artifacts_troubleshooting.md#error-message-this-job-could-not-start-because-it-could-not-retrieve-the-needed-artifacts)。请将过期时间设置得长一些，或者在后续作业中使用 [`dependencies`](#dependencies) 以确保它们不会尝试获取已过期的产物。
- `artifacts:expire_in` 不影响 极狐GitLab Pages 部署。要配置 Pages 部署的过期时间，请使用 [`pages.expire_in`](#pagesexpire_in)。

---

<a id="artifacts-expose_as"></a>

#### 产物公开为

使用 `artifacts:expose_as` 关键字 [在合并请求 UI 中公开产物](../jobs/job_artifacts.md#link-to-job-artifacts-in-the-merge-request-ui)。

**关键字类型**：作业关键字。你只能将其用作作业的一部分，或在 [`default` 部分](#default) 中使用。

**支持的值**：

- 在合并请求 UI 中为产物下载链接显示的名称。必须与 [`artifacts:paths`](#artifactspaths) 结合使用。

**`artifacts:expose_as` 示例**：

```yaml
test:
  script: ["echo 'test' > file.txt"]
  artifacts:
    expose_as: 'artifact 1'
    paths: ['file.txt']
```

**附加详情**：

- 每个作业只能使用 `expose_as` 一次，每个合并请求最多 10 个作业。
- 不支持 Glob 模式。
- 产物始终会发送到 极狐GitLab。除非 `artifacts:paths` 的值：
  - 使用 [CI/CD 变量](../variables/_index.md)。
  - 定义目录但不以 `/` 结尾，则会在 UI 中显示。例如，`directory/` 与 `artifacts:expose_as` 一起使用是有效的，但 `directory` 则无效。
- 如果 `artifacts:paths` 仅包含一个文件，链接会直接打开该文件。在所有其他情况下，链接会打开 [产物浏览器](../jobs/job_artifacts.md#download-job-artifacts)。
- 链接文件默认被下载。如果启用了 [极狐GitLab Pages](../../administration/pages/_index.md)，你可以在浏览器中直接预览某些产物文件扩展名。有关详细信息，请参阅 [浏览产物存档内容](../jobs/job_artifacts.md#browse-the-contents-of-the-artifacts-archive)。

**相关主题**：

- [在合并请求 UI 中公开作业产物](../jobs/job_artifacts.md#link-to-job-artifacts-in-the-merge-request-ui)。

---

<a id="artifacts-name"></a>

#### 产物名称

使用 `artifacts:name` 关键字定义创建的产物存档的名称。你可以为每个存档指定一个唯一名称。

如果未定义，默认名称是 `artifacts`，下载时变为 `artifacts.zip`。

**关键字类型**：作业关键字。你只能将其用作作业的一部分，或在 [`default` 部分](#default) 中使用。

**支持的值**：

- 产物存档的名称。支持 [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。必须与 [`artifacts:paths`](#artifactspaths) 结合使用。

**`artifacts:name` 示例**：

要创建一个以当前作业名称命名的存档：

```yaml
job:
  artifacts:
    name: "job1-artifacts-file"
    paths:
      - binaries/
```

**相关主题**：

- [使用 CI/CD 变量定义产物配置](../jobs/job_artifacts.md#with-variable-expansion)

---

<a id="artifacts-public"></a>

#### 产物公开

{{< history >}}

- 在 极狐GitLab 15.10 中 [更新](https://gitlab.com/gitlab-org/gitlab/-/issues/322454)。在此更新之前使用 `artifacts:public` 创建的产物在更新后不一定能保证保持私有。
- 在 极狐GitLab 16.7 中 [GA](https://gitlab.com/gitlab-org/gitlab/-/issues/294503)。功能标志 `non_public_artifacts` 已移除。

{{< /history >}}

> [!note]
> `artifacts:public` 现在已被 [`artifacts:access`](#artifactsaccess) 取代，后者具有更多选项。

使用 `artifacts:public` 控制公开流水线中的作业产物是否可供匿名用户或 访客 和 报告者 角色通过 极狐GitLab UI 和 API 下载。

> [!warning]
> 此选项仅影响 极狐GitLab UI 和 API 访问。使用作业令牌的 CI/CD 作业仍然可以通过 runner API 访问产物，此设置不影响。要限制作业令牌访问，请将项目的 [CI/CD 可见性设置](../../user/project/settings/_index.md#configure-project-features-and-permissions) 配置为 **仅项目成员**。

**关键字类型**：作业关键字。你只能将其用作作业的一部分，或在 [`default` 部分](#default) 中使用。

**支持的值**：

- `true`（默认）：公开流水线中的作业的产物可供任何人下载，包括匿名用户或 访客 和 报告者 角色。
- `false`：作业中的产物仅可供 开发者、维护者 或 所有者 角色下载。

**`artifacts:public` 示例**：

```yaml
job:
  artifacts:
    public: false
```

---

<a id="artifacts-access"></a>

#### 产物访问

{{< history >}}

- 在 极狐GitLab 16.11 中 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/145206)。
- `maintainer` 选项在 极狐GitLab 18.4 中 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/454398)。

{{< /history >}}

使用 `artifacts:access` 确定谁可以从 极狐GitLab UI 或 API 访问作业产物。此选项不会阻止你将产物转发到下游流水线。

你不能在同一作业中同时使用 [`artifacts:public`](#artifactspublic) 和 `artifacts:access`。

> [!warning]
> 此选项仅影响 极狐GitLab UI 和 API 访问。使用作业令牌的 CI/CD 作业仍然可以通过 runner API 访问产物，此设置不影响。要限制作业令牌访问，请将项目的 [CI/CD 可见性设置](../../user/project/settings/_index.md#configure-project-features-and-permissions) 配置为 **仅项目成员**。

**关键字类型**：作业关键字。你只能将其用作作业的一部分。

**支持的值**：

- `all`（默认）：公开流水线中的作业的产物可供任何人下载，包括匿名、访客和报告者用户。
- `developer`：作业中的产物仅可供 开发者、维护者 或 所有者 角色下载。
- `maintainer`：作业中的产物仅可供 维护者 或 所有者 角色下载。
- `none`：作业中的产物不可供任何人下载。

**`artifacts:access` 示例**：

```yaml
job:
  artifacts:
    access: 'developer'
```

**附加详情**：

- `artifacts:access` 也影响所有 [`artifacts:reports`](#artifactsreports)，因此你也可以限制对 [用于报告的产物](artifacts_reports.md) 的访问。

---

<a id="artifacts-reports"></a>

#### 产物报告

使用 [`artifacts:reports`](artifacts_reports.md) 收集由作业中包含的模板生成的产物。

**关键字类型**：作业关键字。你只能将其用作作业的一部分，或在 [`default` 部分](#default) 中使用。

**支持的值**：

- 请参见可用的 [产物报告类型](artifacts_reports.md) 列表。

**`artifacts:reports` 示例**：

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
**附加详情**：

- 不支持在父流水线中使用[子流水线的产物](#needspipelinejob)合并报告。更多信息，请参见史诗 8205。
- 要能够浏览和下载报告输出文件，请包含 [`artifacts:paths`](#artifactspaths) 关键字。这会上传并存储产物两次。
- 为 `artifacts: reports` 创建的产物始终会被上传，无论作业结果如何（成功或失败）。你可以使用 [`artifacts:expire_in`](#artifactsexpire_in) 为产物设置过期日期。

---

<a id="artifacts-untracked"></a>

#### 产物：未跟踪文件 (`artifacts:untracked`)

使用 `artifacts:untracked` 将所有 Git 未跟踪文件添加为产物（也包括 `artifacts:paths` 中定义的路径）。`artifacts:untracked` 会忽略仓库 `.gitignore` 中的配置，因此被 `.gitignore` 匹配的产物也会包含在内。

**关键字类型**：作业关键字。只能作为作业的一部分或在 [`default` 部分](#default) 中使用。

**支持的值**：

- `true` 或 `false`（未定义时默认为 false）。

**`artifacts:untracked` 示例**：

保存所有 Git 未跟踪文件：

```yaml
job:
  artifacts:
    untracked: true
```

**相关主题**：

- [将未跟踪文件添加到产物](../jobs/job_artifacts.md#with-untracked-files)。

---

<a id="artifacts-when"></a>

#### 产物：上传时机 (`artifacts:when`)

使用 `artifacts:when` 在作业失败时或无论失败与否上传产物。

**关键字类型**：作业关键字。只能作为作业的一部分或在 [`default` 部分](#default) 中使用。

**支持的值**：

- `on_success`（默认）：只在作业成功时上传产物。
- `on_failure`：只在作业失败时上传产物。
- `always`：始终上传产物（作业超时除外）。例如，[上传产物](../testing/unit_test_reports.md#add-screenshots-to-test-reports) 用于排查测试失败。

**`artifacts:when` 示例**：

```yaml
job:
  artifacts:
    when: on_failure
```

**附加详情**：

- 为 [`artifacts:reports`](#artifactsreports) 创建的产物始终会被上传，无论作业结果如何（成功或失败）。`artifacts:when` 不会改变此行为。

---

<a id="before-script"></a>

### 前置脚本 (`before_script`)

使用 `before_script` 定义一系列命令，这些命令应在每个作业的 `script` 命令之前、在[产物](#artifacts)被还原之后运行。

**关键字类型**：作业关键字。只能作为作业的一部分或在 [`default` 部分](#default) 中使用。

**支持的值**：一个数组，包括：

- 单行命令。
- [拆分为多行的长命令](script.md#split-long-commands)。
- [YAML 锚点](yaml_optimization.md#yaml-anchors-for-scripts)。

CI/CD 变量[受支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。

**`before_script` 示例**：

```yaml
job:
  before_script:
    - echo "Execute this command before any 'script:' commands."
  script:
    - echo "This command executes after the job's 'before_script' commands."
```

**附加详情**：

- 在 `before_script` 中指定的脚本会与主 [`script`](#script) 中指定的任何脚本连接在一起。合并后的脚本会在一个 shell 中一起执行。
- 在顶层而不在 `default` 部分中使用 `before_script` [已被弃用](deprecated_keywords.md#globally-defined-image-services-cache-before_script-after_script)。

**相关主题**：

- [结合 `default` 使用 `before_script`](script.md#set-a-default-before_script-or-after_script-for-all-jobs) 为所有作业定义在 `script` 命令之前运行的默认命令数组。
  - 作业配置和默认配置不会合并。如果流水线定义了 [`default:before_script`](#default)，且作业也定义了 `before_script`，则作业配置优先，默认配置不被使用。
- 你可以[忽略非零退出码](script.md#ignore-non-zero-exit-codes)。
- [在 `before_script` 中使用颜色代码](script.md#add-color-codes-to-script-output) 使作业日志更易于审查。
- [创建自定义可折叠区域](../jobs/job_logs.md#create-custom-collapsible-sections) 简化作业日志输出。

---

<a id="cache"></a>

### 缓存 (`cache`)

{{< history >}}

- 在 极狐GitLab 15.0 中引入，缓存不再在受保护分支和未受保护分支之间共享。
- 在 极狐GitLab Runner 18.1 中更新。在缓存过程中，不再跟踪 `symlinks`，这在之前版本的 极狐GitLab Runner 中某些边缘情况下会发生。

{{< /history >}}

使用 `cache` 指定作业之间要缓存的文件和目录列表。只能使用本地工作副本中的路径。

缓存的特点：

- 在流水线和作业之间共享。
- 默认情况下，不在[受保护分支](../../user/project/repository/branches/protected.md)和未受保护分支之间共享。
- 在[产物](#artifacts)之前还原。
- 最多可设置四个[不同的缓存](../caching/_index.md#use-multiple-caches)。

你可以[为特定作业禁用缓存](../caching/_index.md#disable-cache-for-specific-jobs)，例如覆盖：

- 通过 [`default`](#default) 定义的默认缓存。
- 通过 [`include`](#include) 添加的作业的配置。

作业配置和默认配置不会合并。如果流水线定义了 [`default:cache`](#default)，且作业也定义了 `cache`，则作业配置优先，默认配置不被使用。

有关缓存的更多信息，请参见[极狐GitLab CI/CD 中的缓存](../caching/_index.md)。

在顶层而不在 `default` 部分中使用 `cache` [已被弃用](deprecated_keywords.md#globally-defined-image-services-cache-before_script-after_script)。

---

<a id="cache-paths"></a>

#### 缓存：路径 (`cache:paths`)

使用 `cache:paths` 关键字选择要缓存的文件或目录。

**关键字类型**：作业关键字。只能作为作业的一部分或在 [`default` 部分](#default) 中使用。

**支持的值**：

- 相对项目目录 (`$CI_PROJECT_DIR`) 的路径数组。可使用 [glob](https://en.wikipedia.org/wiki/Glob_(programming)) 和 [`doublestar.Glob`](https://pkg.go.dev/github.com/bmatcuk/doublestar@v1.2.2?tab=doc#Match) 模式通配符。

[CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file) 受支持。

**`cache:paths` 示例**：

缓存 `binaries` 目录中所有以 `.apk` 结尾的文件以及 `.config` 文件：

```yaml
rspec:
  script:
    - echo "This job uses a cache."
  cache:
    key: binaries-cache
    paths:
      - binaries/*.apk
      - .config
```

**附加详情**：

- `cache:paths` 关键字会包括文件，即使它们是未跟踪的或在 `.gitignore` 文件中也是如此。

**相关主题**：

- 请参见 [CI/CD 缓存示例](../caching/examples.md) 了解更多 `cache:paths` 示例。

---

<a id="cache-key"></a>

#### 缓存：键 (`cache:key`)

使用 `cache:key` 关键字为每个缓存提供一个唯一标识键。所有使用相同缓存键的作业（包括在不同流水线中）共享相同的缓存。

如果未设置，则默认键为 `default`。所有带有 `cache` 关键字但没有 `cache:key` 的作业共享默认缓存。

必须与 `cache: paths` 一起使用，否则不会缓存任何内容。

**关键字类型**：作业关键字。只能作为作业的一部分或在 [`default` 部分](#default) 中使用。

**支持的值**：

- 字符串。
- 预定义的 [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。
- 两者的组合。

**`cache:key` 示例**：

```yaml
cache-job:
  script:
    - echo "This job uses a cache."
  cache:
    key: binaries-cache-$CI_COMMIT_REF_SLUG
    paths:
      - binaries/
```

**附加详情**：

- 如果使用 **Windows Batch** 运行 shell 脚本，必须将 `$` 替换为 `%`。例如：`key: %CI_COMMIT_REF_SLUG%`
- `cache:key` 值不能包含：
  - `/` 字符，或等效的 URI 编码 `%2F`。
  - 仅 `.` 字符（任意数量），或等效的 URI 编码 `%2E`。
- 缓存在作业之间共享，因此如果为不同作业使用不同的路径，还应设置不同的 `cache:key`。否则缓存内容可能会被覆盖。

**相关主题**：

- 你可以指定[回退缓存键](../caching/_index.md#use-a-fallback-cache-key)，以便在找不到指定的 `cache:key` 时使用。
- 你可以在单个作业中[使用多个缓存键](../caching/_index.md#use-multiple-caches)。
- 请参见 [CI/CD 缓存示例](../caching/examples.md) 了解更多 `cache:key` 示例。

---

<a id="cache-key-files"></a>

##### 缓存：键文件 (`cache:key:files`)

使用 `cache:key:files` 在指定文件内容变更时生成新的缓存键。如果内容保持不变，缓存键在分支和流水线之间保持一致。你可以复用缓存并减少重建频率，从而加快后续流水线运行。

**关键字类型**：作业关键字。只能作为作业的一部分或在 [`default` 部分](#default) 中使用。

**支持的值**：

- 最多两个文件路径或模式的数组。

CI/CD 变量不受支持。

**`cache:key:files` 示例**：

```yaml
cache-job:
  script:
    - echo "This job uses a cache."
  cache:
    key:
      files:
        - Gemfile.lock
        - package.json
    paths:
      - vendor/ruby
      - node_modules
```

此示例为 Ruby 和 Node.js 依赖创建缓存。缓存与 `Gemfile.lock` 和 `package.json` 文件的当前版本绑定。当其中一个文件变更时，会计算新的缓存键并创建新缓存。后续使用相同 `Gemfile.lock` 和 `package.json` 以及 `cache:key:files` 的作业运行会使用新缓存，而不是重建依赖。

**附加详情**：

- 缓存 `key` 是根据所列文件内容计算出的 SHA。如果某个文件不存在，则在键计算中忽略它。如果所有指定文件都不存在，回退键为 `default`。
- 可使用如 `**/package.json` 的通配符模式。
- 最多可指定两个文件。有关增加允许路径或模式数量的更新，请参见议题 301161。

---

<a id="cache-key-files-commits"></a>

##### 缓存：键提交文件 (`cache:key:files_commits`)

使用 `cache:key:files_commits` 在指定文件的最新提交变更时生成新的缓存键。`cache:key:files_commits` 缓存键会在指定文件有新提交时变更，即使文件内容完全相同。

**关键字类型**：作业关键字。只能作为作业的一部分或在 [`default` 部分](#default) 中使用。

**支持的值**：

- 最多两个文件路径或模式的数组。

**`cache:key:files_commits` 示例**：

```yaml
cache-job:
  script:
    - echo "This job uses a commit-based cache."
  cache:
    key:
      files_commits:
        - package.json
        - yarn.lock
    paths:
      - node_modules
```

此示例基于 `package.json` 和 `yarn.lock` 的提交历史创建缓存。如果这些文件的提交历史变更，会计算新的缓存键并创建新缓存。

**附加详情**：

- 缓存 `key` 是根据每个指定文件的最近提交计算出的 SHA。
- 如果某个文件不存在，则在键计算中忽略它。
- 如果所有指定文件都不存在，回退键为 `default`。
- 不能与 [`cache:key:files`](#cache-key-files) 在同一缓存配置中一起使用。

---

<a id="cache-key-prefix"></a>

##### 缓存：键前缀 (`cache:key:prefix`)

使用 `cache:key:prefix` 将前缀与为 [`cache:key:files`](#cache-key-files) 计算出的 SHA 组合在一起。

**关键字类型**：作业关键字。只能作为作业的一部分或在 [`default` 部分](#default) 中使用。

**支持的值**：

- 字符串。
- 预定义的 [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。
- 两者的组合。

**`cache:key:prefix` 示例**：

```yaml
rspec:
  script:
    - echo "This rspec job uses a cache."
  cache:
    key:
      files:
        - Gemfile.lock
      prefix: $CI_JOB_NAME
    paths:
      - vendor/ruby
```

例如，添加 `$CI_JOB_NAME` 前缀会使键类似于 `rspec-feef9576d21ee9b6a32e30c5c79d0a0ceb68d1e5`。如果某个分支更改了 `Gemfile.lock`，该分支会得到一个新的 `cache:key:files` SHA 校验和。会生成新缓存键并为该键创建新缓存。如果未找到 `Gemfile.lock`，前缀会添加到 `default`，因此示例中的键会是 `rspec-default`。

**附加详情**：

- 如果 `cache:key:files` 中没有文件在任何提交中变更，前缀会添加到 `default` 键。

---

<a id="cache-untracked"></a>

#### 缓存：未跟踪文件 (`cache:untracked`)

使用 `untracked: true` 缓存 Git 仓库中所有未跟踪的文件。未跟踪文件包括：

- 因 [`.gitignore` 配置](https://git-scm.com/docs/gitignore)而被忽略的文件。
- 已创建但未通过 [`git add`](https://git-scm.com/docs/git-add) 添加到检出的文件。

如果作业下载了以下内容，缓存未跟踪文件可能会导致缓存异常大：

- 依赖项，比如 gems 或 node modules，它们通常未被跟踪。
- 来自其他作业的[产物](#artifacts)。从产物中提取的文件默认是未跟踪的。

**关键字类型**：作业关键字。只能作为作业的一部分或在 [`default` 部分](#default) 中使用。

**支持的值**：

- `true` 或 `false`（默认）。

**`cache:untracked` 示例**：

```yaml
rspec:
  script: test
  cache:
    untracked: true
```

**附加详情**：

- 你可以将 `cache:untracked` 与 `cache:paths` 结合使用，以缓存所有未跟踪文件以及配置路径中的文件。使用 `cache:paths` 缓存任何特定文件，包括已跟踪文件或工作目录之外的文件，并使用 `cache: untracked` 同时缓存所有未跟踪文件。例如：

  ```yaml
  rspec:
    script: test
    cache:
      untracked: true
      paths:
        - binaries/
  ```

  在此示例中，作业缓存仓库中所有未跟踪文件以及 `binaries/` 中的所有文件。如果 `binaries/` 中有未跟踪文件，它们会被两个关键字同时覆盖。

---

<a id="cache-unprotect"></a>

#### 缓存：取消保护 (`cache:unprotect`)

{{< history >}}

- 在 极狐GitLab 15.8 中引入。

{{< /history >}}

使用 `cache:unprotect` 设置缓存在[受保护分支](../../user/project/repository/branches/protected.md)和未受保护分支之间共享。

> [!warning]
> 当设置为 `true` 时，没有受保护分支访问权限的用户可以读取和写入受保护分支使用的缓存键。

**关键字类型**：作业关键字。只能作为作业的一部分或在 [`default` 部分](#default) 中使用。

**支持的值**：

- `true` 或 `false`（默认）。

**`cache:unprotect` 示例**：

```yaml
rspec:
  script: test
  cache:
    unprotect: true
```

---

<a id="cache-when"></a>

#### 缓存：保存时机 (`cache:when`)

使用 `cache:when` 根据作业状态定义何时保存缓存。

必须与 `cache: paths` 一起使用，否则不会缓存任何内容。

**关键字类型**：作业关键字。只能作为作业的一部分或在 [`default` 部分](#default) 中使用。

**支持的值**：

- `on_success`（默认）：只在作业成功时保存缓存。
- `on_failure`：只在作业失败时保存缓存。
- `always`：始终保存缓存。

**`cache:when` 示例**：

```yaml
rspec:
  script: rspec
  cache:
    paths:
      - rspec/
    when: 'always'
```

无论作业失败还是成功，此示例都会存储缓存。

---

<a id="cache-policy"></a>

#### 缓存：策略 (`cache:policy`)

要更改缓存的下载和上传行为，请使用 `cache:policy` 关键字。默认情况下，作业在启动时下载缓存，并在作业结束时上传对缓存的更改。此缓存方式是 `pull-push` 策略（默认）。

要设置作业仅在启动时下载缓存，但从不在此作业结束时上传更改，请使用 `cache:policy:pull`。

要设置作业仅在结束时上传缓存，但从不在启动时下载缓存，请使用 `cache:policy:push`。

当你有许多并行执行且使用相同缓存的作业时，请使用 `pull` 策略。此策略可加快作业执行速度并减少缓存服务器负载。你可以使用具有 `push` 策略的作业来构建缓存。

必须与 `cache: paths` 一起使用，否则不会缓存任何内容。

**关键字类型**：作业关键字。只能作为作业的一部分或在 [`default` 部分](#default) 中使用。

**支持的值**：

- `pull`
- `push`
- `pull-push`（默认）
- [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。

**`cache:policy` 示例**：

```yaml
prepare-dependencies-job:
  stage: build
  cache:
    key: gems
    paths:
      - vendor/bundle
    policy: push
  script:
    - echo "This job only downloads dependencies and builds the cache."
    - echo "Downloading dependencies..."

faster-test-job:
  stage: test
  cache:
    key: gems
    paths:
      - vendor/bundle
    policy: pull
  script:
    - echo "This job script uses the cache, but does not update it."
    - echo "Running tests..."
```

**相关主题**：

- 你可以[使用变量控制作业的缓存策略](../caching/examples.md#use-a-variable-to-control-a-jobs-cache-policy)。

---

<a id="cache-fallback-keys"></a>

#### 缓存：回退键 (`cache:fallback_keys`)

使用 `cache:fallback_keys` 指定一个键列表，以便在找不到 `cache:key` 对应的缓存时尝试从这些键恢复缓存。缓存会按照 `fallback_keys` 部分指定的顺序依次被检索。

**关键字类型**：作业关键字。只能作为作业的一部分或在 [`default` 部分](#default) 中使用。

**支持的值**：

- 缓存键的数组。

**`cache:fallback_keys` 示例**：

```yaml
rspec:
  script: rspec
  cache:
    key: gems-$CI_COMMIT_REF_SLUG
    paths:
      - rspec/
    fallback_keys:
      - gems
    when: 'always'
```

---

<a id="coverage"></a>

### 覆盖率 (`coverage`)

使用 `coverage` 和自定义正则表达式来配置如何从作业输出中提取代码覆盖率。如果作业输出中至少有一行与正则表达式匹配，覆盖率就会显示在 UI 中。

为了从匹配项中提取代码覆盖率的值，极狐GitLab 使用这个更小的正则表达式：`\d+(?:\.\d+)?`。

**支持的值**：

- RE2 正则表达式。必须以 `/` 开头和结尾。必须匹配覆盖率数字。也可以匹配周围文本，所以你无需使用正则表达式字符组来捕获精确数字。由于使用 RE2 语法，所有组都必须是非捕获组。

**`coverage` 示例**：

```yaml
job1:
  script: rspec
  coverage: '/Code coverage: \d+(?:\.\d+)?/'
```

在此示例中：

1. 极狐GitLab 检查作业日志中与正则表达式匹配的行。像 `Code coverage: 67.89% of lines covered` 这样的行会匹配。
1. 然后极狐GitLab 检查匹配的片段，寻找与正则表达式：`\d+(?:\.\d+)?` 匹配的内容。示例正则可以匹配代码覆盖率 `67.89`。

**附加详情**：

- 你可以在[代码覆盖率](../testing/code_coverage/_index.md#coverage-regex-patterns)中找到正则表达式示例。
- 如果作业输出中有多行匹配，则使用最后一行（反向搜索的第一个结果）。
- 如果单行中有多个匹配项，则搜索最后一个匹配项以获取覆盖率数字。
- 如果在匹配的片段中发现多个覆盖率数字，则使用第一个数字。
- 前导零会被去除。
- [子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)的覆盖率输出不会被记录或显示。更多详情请参见议题 280818。

---

<a id="dast-configuration"></a>

### DAST 配置 (`dast_configuration`)

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 `dast_configuration` 关键字指定要在 CI/CD 配置中使用的站点配置文件和扫描器配置文件。这两个配置文件必须首先在项目中创建。作业的阶段必须是 `dast`。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：各一个 `site_profile` 和 `scanner_profile`。

- 使用 `site_profile` 指定要在作业中使用的站点配置文件。
- 使用 `scanner_profile` 指定要在作业中使用的扫描器配置文件。

**`dast_configuration` 示例**：

```yaml
stages:
  - build
  - dast

include:
  - template: DAST.gitlab-ci.yml

dast:
  dast_configuration:
    site_profile: "Example Co"
    scanner_profile: "Quick Passive Test"
```

在此示例中，`dast` 作业扩展了通过 `include` 关键字添加的 `dast` 配置，用以选择特定的站点配置文件和扫描器配置文件。

**附加详情**：

- 站点配置文件或扫描器配置文件中包含的设置优先于 DAST 模板中的设置。

**相关主题**：

- [站点配置文件](../../user/application_security/dast/profiles.md#site-profile)。
- [扫描器配置文件](../../user/application_security/dast/profiles.md#scanner-profile)。

---

<a id="dependencies"></a>

### 依赖 (`dependencies`)

使用 `dependencies` 关键字定义要从哪些特定作业获取[产物](#artifacts)的列表。指定的作业必须都位于更早的阶段。你也可以设置作业完全不下载任何产物。

当作业中未定义 `dependencies` 时，所有更早阶段的作业都被视为依赖项，作业会从这些作业获取所有产物。

要从同一阶段的作业获取产物，必须使用 [`needs:artifacts`](#needsartifacts)。不应在同一作业中同时使用 `dependencies` 和 `needs`。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- 要获取产物的作业名称。
- 空数组 (`[]`)，将作业配置为不下载任何产物。

**`dependencies` 示例**：

```yaml
build osx:
  stage: build
  script: make build:osx
  artifacts:
    paths:
      - binaries/

build linux:
  stage: build
  script: make build:linux
  artifacts:
    paths:
      - binaries/

test osx:
  stage: test
  script: make test:osx
  dependencies:
    - build osx

test linux:
  stage: test
  script: make test:linux
  dependencies:
    - build linux

deploy:
  stage: deploy
  script: make deploy
  environment: production
```

在此示例中，有两个作业有产物：`build osx` 和 `build linux`。当执行 `test osx` 时，`build osx` 的产物会在构建上下文中被下载并解压。`test linux` 和来自 `build linux` 的产物同理。

由于[阶段](#stages)优先级，`deploy` 作业会从所有更早的作业下载产物。

**附加详情**：

- 作业状态无关紧要。如果作业失败或者是未触发的手动作业，也不会出错。
- 如果依赖作业的产物[过期](#artifactsexpire_in) 或[被删除](../jobs/job_artifacts.md#delete-job-log-and-artifacts)，则作业失败。

---

<a id="environment"></a>

### 环境 (`environment`)

使用 `environment` 定义作业部署到的[环境](../environments/_index.md)。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：作业部署到的环境名称，格式如下：

- 纯文本，包括字母、数字、空格以及以下字符：`-`、`_`、`/`、`$`、`{`、`}`。
- CI/CD 变量，包括预定义、项目、群组、实例或在 `.gitlab-ci.yml` 文件中定义的变量。不能使用 `script` 部分中定义的变量。

**`environment` 示例**：

```yaml
deploy to production:
  stage: deploy
  script: git push production HEAD:main
  environment: production
```

**附加详情**：

- 如果指定了 `environment` 且不存在该名称的环境，则会创建一个环境。

---

<a id="environment-name"></a>

#### 环境：名称 (`environment:name`)

为[环境](../environments/_index.md)设置名称。常见的环境名称有 `qa`、`staging` 和 `production`，但你可以使用任何名称。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：作业部署到的环境名称，格式如下：

- 纯文本，包括字母、数字、空格以及以下字符：`-`、`_`、`/`、`$`、`{`、`}`。
- [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)，包括预定义、项目、群组、实例或在 `.gitlab-ci.yml` 文件中定义的变量。不能使用 `script` 部分中定义的变量。

**`environment:name` 示例**：

```yaml
deploy to production:
  stage: deploy
  script: git push production HEAD:main
  environment:
    name: production
```

---

<a id="environment-url"></a>

#### 环境：URL (`environment:url`)

为[环境](../environments/_index.md)设置一个 URL。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：单个 URL，格式如下：
- 纯文本，例如 `https://prod.example.com`。
- [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)，包括预定义、项目、群组、实例变量，或在 `.gitlab-ci.yml` 文件中定义的变量。你不能使用在 `script` 部分定义的变量。

**`environment:url` 示例**：

```yaml
deploy to production:
  stage: deploy
  script: git push production HEAD:main
  environment:
    name: production
    url: https://prod.example.com
```

**额外细节**：

- 作业完成后，你可以通过在合并请求、环境或部署页面中选择按钮来访问该 URL。

---

<a id="environmenton_stop"></a>

#### `environment:on_stop`

关闭（停止）环境可以通过在 `environment` 下定义的 `on_stop` 关键字来实现。它声明一个不同的作业来运行以关闭环境。

**关键字类型**：作业关键字。你只能将其作为作业的一部分使用。

**额外细节**：

- 有关更多详细信息及示例，请参阅 [`environment:action`](#environmentaction)。

---

<a id="environmentaction"></a>

#### `environment:action`

使用 `action` 关键字来指定作业如何与环境交互。

**关键字类型**：作业关键字。你只能将其作为作业的一部分使用。

**支持的值**：以下关键字之一：

| **值** | **描述** |
|:----------|:----------------|
| `start`   | 默认值。表示作业启动环境。部署在作业启动后创建。 |
| `prepare` | 表示作业仅准备环境。它不会触发部署。[了解更多关于准备环境的信息](../environments/_index.md#access-an-environment-for-preparation-or-verification-purposes)。 |
| `stop`    | 表示作业停止环境。[了解更多关于停止环境的信息](../environments/_index.md#stopping-an-environment)。 |
| `verify`  | 表示作业仅验证环境。它不会触发部署。[了解更多关于验证环境的信息](../environments/_index.md#access-an-environment-for-preparation-or-verification-purposes)。 |
| `access`  | 表示作业仅访问环境。它不会触发部署。[了解更多关于访问环境的信息](../environments/_index.md#access-an-environment-for-preparation-or-verification-purposes)。 |

**`environment:action` 示例**：

```yaml
stop_review_app:
  stage: deploy
  variables:
    GIT_STRATEGY: none
  script: make delete-app
  when: manual
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    action: stop
```

---

<a id="environmentauto_stop_in"></a>

#### `environment:auto_stop_in`

{{< history >}}

- 在极狐GitLab 15.4 引入 CI/CD 变量支持。
- 在极狐GitLab 17.7 更新以支持 `prepare`、`access` 和 `verify` 环境操作。

{{< /history >}}

`auto_stop_in` 关键字指定环境的生命周期。当环境过期时，极狐GitLab 会自动停止它。

**关键字类型**：作业关键字。你只能将其作为作业的一部分使用。

**支持的值**：以自然语言编写的时间段。例如，以下所有都是等效的：

- `168 小时`
- `7 天`
- `一周`
- `从不`

CI/CD 变量 [受支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。

**`environment:auto_stop_in` 示例**：

```yaml
review_app:
  script: deploy-review-app
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    auto_stop_in: 1 day
```

当为 `review_app` 创建环境时，环境的生命周期设置为 `1 day`。每次部署审查应用时，该生命周期也会重置为 `1 day`。

`auto_stop_in` 关键字可用于除 `stop` 之外的所有 [环境操作](#environmentaction)。某些操作可用于重置环境的计划停止时间。有关更多信息，请参阅 [为准备或验证目的访问环境](../environments/_index.md#access-an-environment-for-preparation-or-verification-purposes)。

**相关主题**：

- [环境自动停止文档](../environments/_index.md#stop-an-environment-after-a-certain-time-period)。

---

<a id="environmentkubernetes"></a>

#### `environment:kubernetes`

{{< history >}}

- 在极狐GitLab 17.6，`agent` 关键字引入。
- 在极狐GitLab 17.7，`namespace` 和 `flux_resource_path` 关键字引入。
- 在极狐GitLab 18.4，`namespace` 和 `flux_resource_path` 关键字 [弃用](deprecated_keywords.md)。
- 在极狐GitLab 18.4，`dashboard:namespace` 和 `dashboard:flux_resource_path` 关键字引入。

{{< /history >}}

使用 `kubernetes` 关键字为环境配置 [Kubernetes 仪表盘](../environments/kubernetes_dashboard.md) 和 [极狐GitLab 管理的 Kubernetes 资源](../../user/clusters/agent/managed_kubernetes_resources.md)。

**关键字类型**：作业关键字。你只能将其作为作业的一部分使用。

**支持的值**：

- `agent`：一个字符串，指定 [极狐GitLab Kubernetes 代理](../../user/clusters/agent/_index.md)。格式为 `path/to/agent/project:agent-name`。如果代理连接到运行流水线的项目，则使用 `$CI_PROJECT_PATH:agent-name`。
- `dashboard:namespace`：一个字符串，表示部署环境的 Kubernetes 命名空间。命名空间必须与 `agent` 关键字一起设置。`namespace` 已 [弃用](deprecated_keywords.md#environmentkubernetesnamespace-and-environmentkubernetesflux_resource_path)。
- `dashboard:flux_resource_path`：一个字符串，表示 Flux 资源的完整路径，例如 `HelmRelease`。Flux 资源必须与 `agent` 和 `dashboard:namespace` 关键字一起设置。`flux_resource_path` 已 [弃用](deprecated_keywords.md#environmentkubernetesnamespace-and-environmentkubernetesflux_resource_path)。
- `managed_resources`：一个哈希，包含 `enabled` 关键字，用于为环境配置 [极狐GitLab 管理的 Kubernetes 资源](../../user/clusters/agent/managed_kubernetes_resources.md)。
  - `managed_resources:enabled`：一个布尔值，指示是否为环境启用极狐GitLab 管理的 Kubernetes 资源。
- `dashboard`：一个哈希，包含 `dashboard:namespace` 和 `dashboard:flux_resource_path` 关键字，用于为环境配置 [Kubernetes 仪表盘](../environments/kubernetes_dashboard.md)。

**`environment:kubernetes` 示例**：

```yaml
deploy:
  stage: deploy
  script: make deploy-app
  environment:
    name: production
    kubernetes:
      agent: path/to/agent/project:agent-name
      dashboard:
        namespace: my-namespace
        flux_resource_path: helm.toolkit.fluxcd.io/v2/namespaces/flux-system/helmreleases/helm-release-resource
```

**禁用托管资源时的 `environment:kubernetes` 示例**：

```yaml
deploy:
  stage: deploy
  script: make deploy-app
  environment:
    name: production
    kubernetes:
      agent: path/to/agent/project:agent-name
      managed_resources:
        enabled: false
      dashboard:
        namespace: my-namespace
        flux_resource_path: helm.toolkit.fluxcd.io/v2/namespaces/flux-system/helmreleases/helm-release-resource
```

此配置：

- 设置 `deploy` 作业以部署到 `production` 环境。
- 将名为 `agent-name` 的 [代理](../../user/clusters/agent/_index.md) 与环境关联。
- 为环境配置 [Kubernetes 仪表盘](../environments/kubernetes_dashboard.md)，命名空间为 `my-namespace`，`flux_resource_path` 设置为 `helm.toolkit.fluxcd.io/v2/namespaces/flux-system/helmreleases/helm-release-resource`。

**额外细节**：

- 要使用仪表盘，你必须 [安装极狐GitLab
- 如果 Runner 不支持定义的拉取策略，作业将报错，类似：
  `ERROR: 作业失败（系统故障）：配置的拉取策略（[always]）不被允许使用的拉取策略（[never]）所允许`。

**相关主题**：

- [在 Docker 容器中运行你的 CI/CD 作业](../docker/using_docker_images.md)。
- [配置 Runner 如何拉取镜像](https://gitlab.cn/docs/runner/executors/docker/#configure-how-runners-pull-images)。
- [设置多个拉取策略](https://gitlab.cn/docs/runner/executors/docker/#set-multiple-pull-policies)。

---

<a id="inputs"></a>

### `输入`

{{< history >}}

- 在极狐GitLab 18.10 引入。

{{< /history >}}

使用 `输入` 为作业定义类型化且经过验证的输入。[作业输入](../jobs/job_inputs.md) 可以在手动运行或重试作业时被覆盖。

作业输入是提供类型安全和验证的参数。与 [CI/CD 变量](../variables/_index.md) 不同，只有在作业中明确定义的输入才能在运行或重试作业时指定。所有作业输入名称必须预定义。

使用 `${{ job.inputs.INPUT_NAME }}` [Moa 表达式](../functions/moa.md) 语法引用作业输入值。

**关键字类型**：作业关键字。你只能在作业中使用它。

**支持的值**：

一个输入名称的哈希，每个输入使用一个或多个子键进行配置：

- [`默认`](#inputsdefault)（必需）
- [`类型`](#inputstype)
- [`选项`](#inputsoptions)
- [`描述`](#inputsdescription)
- [`正则表达式`](#inputsregex)

**`输入` 示例**：

```yaml
test_job:
  inputs:
    test_suite:
      default: unit
      description: 要运行的测试套件
      options: [unit, integration, e2e]
    parallel_count:
      type: number
      default: 5
      description: 并行测试 Runner 数量
    verbose:
      type: boolean
      default: false
      description: 启用详细测试输出
  script:
    - 'echo "正在运行 ${{ job.inputs.test_suite }} 测试"'
    - 'if [ "${{ job.inputs.verbose }}" == "true" ]; then export TEST_VERBOSE=1; fi'
    - ./run_tests.sh --suite ${{ job.inputs.test_suite }} --parallel ${{ job.inputs.parallel_count }}
```

**更多细节**：

- 作业输入在创建作业时以及你尝试使用新的输入值重试作业时进行验证。
  如果验证失败，作业不会启动。
- 作业输入的作用域仅限于定义它们的作业，无法被其他作业访问。
- 有关支持作业输入的关键字的完整列表，请参阅[可以在哪里使用作业输入](../jobs/job_inputs.md#where-you-can-use-job-inputs)。

---

<a id="inputsdefault"></a>

#### `输入:默认`

所有作业输入都必须使用 `默认` 定义一个默认值。

**关键字类型**：作业关键字。你只能在作业中使用它。

**支持的值**：任何匹配输入 [`类型`](#inputstype) 的值。

**`输入:默认` 示例**：

```yaml
test_job:
  inputs:
    environment:
      default: staging
    timeout:
      type: number
      default: 30
```

---

<a id="inputstype"></a>

#### `输入:类型`

使用 `类型` 定义输入值的数据类型。

**关键字类型**：作业关键字。你只能在作业中使用它。

**支持的值**：

- `字符串`（默认）
- `数字`
- `布尔值`
- `数组`。

**`输入:类型` 示例**：

```yaml
test_job:
  inputs:
    count:
      type: number
      default: 5
    enabled:
      type: boolean
      default: true
```

---

<a id="inputsdescription"></a>

#### `输入:描述`

使用 `描述` 提供关于输入用途的信息。
描述不会影响输入的行为。

**关键字类型**：作业关键字。你只能在作业中使用它。

**支持的值**：一个字符串。

**`输入:描述` 示例**：

```yaml
deploy_job:
  inputs:
    environment:
      default: staging
      description: 目标部署环境
```

---

<a id="inputsoptions"></a>

#### `输入:选项`

使用 `选项` 指定输入的允许值列表。

输入值必须与列出的选项之一完全匹配（区分大小写）。
如果值与任何选项不匹配，则验证失败。

**关键字类型**：作业关键字。你只能在作业中使用它。

**支持的值**：允许值的数组。

**`输入:选项` 示例**：

```yaml
deploy_job:
  inputs:
    environment:
      default: staging
      options: [development, staging, production]
```

---

<a id="inputsregex"></a>

#### `输入:正则表达式`

使用 `正则表达式` 指定输入值必须匹配的正则表达式模式。

如果值与正则表达式不匹配，则验证失败。

**关键字类型**：作业关键字。你只能在作业中使用它。

**支持的值**：一个正则表达式字符串。

**`输入:正则表达式` 示例**：

```yaml
deploy_job:
  inputs:
    version:
      default: v1.0.0
      regex: ^v\d+\.\d+\.\d+$
```

在这个示例中，输入值 `v1.1.1` 通过了正则验证，但输入 `v1.1.1-beta` 则没有。

---

<a id="inherit"></a>

### `继承`

使用 `继承` 来[控制默认关键字和变量的继承](../jobs/_index.md#control-the-inheritance-of-default-keywords-and-variables)。

---

<a id="inheritdefault"></a>

#### `继承:默认`

使用 `继承:默认` 控制[默认关键字](#default)的继承。

**关键字类型**：作业关键字。你只能在作业中使用它。

**支持的值**：

- `true`（默认）或 `false` 以启用或禁用所有默认关键字的继承。
- 要继承的特定默认关键字列表。

**`继承:默认` 示例**：

```yaml
default:
  retry: 2
  image: ruby:3.0
  interruptible: true

job1:
  script: echo "此作业不继承任何默认关键字。"
  inherit:
    default: false

job2:
  script: echo "此作业仅继承列出的两个默认关键字。它不继承 'interruptible'。"
  inherit:
    default:
      - retry
      - image
```

**更多细节**：

- 你也可以将默认关键字单行列出以继承：`default: [keyword1, keyword2]`

---

<a id="inheritvariables"></a>

#### `继承:变量`

使用 `继承:变量` 控制[默认变量](#default-variables)关键字的继承。

**关键字类型**：作业关键字。你只能在作业中使用它。

**支持的值**：

- `true`（默认）或 `false` 以启用或禁用所有默认变量的继承。
- 要继承的特定变量列表。

**`继承:变量` 示例**：

```yaml
variables:
  VARIABLE1: "这是默认变量 1"
  VARIABLE2: "这是默认变量 2"
  VARIABLE3: "这是默认变量 3"

job1:
  script: echo "此作业不继承任何默认变量。"
  inherit:
    variables: false

job2:
  script: echo "此作业仅继承列出的两个默认变量。它不继承 'VARIABLE3'。"
  inherit:
    variables:
      - VARIABLE1
      - VARIABLE2
```

**更多细节**：

- 你也可以将默认变量单行列出以继承：`variables: [VARIABLE1, VARIABLE2]`

---

<a id="interruptible"></a>

### `可中断`

{{< history >}}

- 对 `trigger` 作业的支持在极狐GitLab 16.8 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/138508)。

{{< /history >}}

使用 `可中断` 来配置[自动取消冗余流水线](../pipelines/settings.md#auto-cancel-redundant-pipelines)功能，以便在同一 ref 上启动新流水线以用于更新的提交时，在作业完成前取消作业。如果该功能被禁用，则关键字无效。新流水线必须针对具有新变更的提交。例如，如果你在 UI 中选择 **新流水线** 为同一提交运行流水线，则 **自动取消冗余流水线** 功能无效。

**自动取消冗余流水线** 功能的行为可以通过 [`workflow:auto_cancel:on_new_commit`](#workflowauto_cancelon_new_commit) 设置来控制。

**关键字类型**：作业关键字。你只能在作业中使用它，或者在 [`默认` 部分](#default)中使用。

**支持的值**：

- `true` 或 `false`（默认）。

**使用默认行为的 `可中断` 示例**：

```yaml
workflow:
  auto_cancel:
    on_new_commit: conservative # 默认行为

stages:
  - stage1
  - stage2
  - stage3

step-1:
  stage: stage1
  script:
    - echo "可被取消。"
  interruptible: true

step-2:
  stage: stage2
  script:
    - echo "不可被取消。"

step-3:
  stage: stage3
  script:
    - echo "因为 step-2 不可被取消，此步骤永远无法被取消，即便它被设置为可中断。"
  interruptible: true
```

在这个示例中，新流水线导致正在运行的流水线被：

- 取消，如果只有 `step-1` 正在运行或等待。
- 不取消，如果 `step-2` 已经开始。

**使用 `auto_cancel:on_new_commit:interruptible` 设置的 `可中断` 示例**：

```yaml
workflow:
  auto_cancel:
    on_new_commit: interruptible

stages:
  - stage1
  - stage2
  - stage3

step-1:
  stage: stage1
  script:
    - echo "可被取消。"
  interruptible: true

step-2:
  stage: stage2
  script:
    - echo "不可被取消。"

step-3:
  stage: stage3
  script:
    - echo "可被取消。"
  interruptible: true
```

在这个示例中，新流水线导致正在运行的流水线取消 `step-1` 和 `step-3`，如果它们正在运行或等待。

**更多细节**：

- 只有当作业开始后可以安全取消时，才设置 `可中断: true`，比如构建作业。部署作业通常不应该取消，以防止部分部署。
- 当使用默认行为或 `workflow:auto_cancel:on_new_commit: conservative` 时：
  - 尚未启动的作业始终被视为 `可中断: true`，无论作业的配置如何。`可中断` 配置只在作业启动后才考虑。
  - **正在运行** 的流水线只有在所有正在运行的作业都配置了 `可中断: true`，或者在任何时候都没有配置了 `可中断: false` 的作业启动过时，才会被取消。
    一旦具有 `可中断: false` 的作业启动，整个流水线就不再被视为可中断。
  - 如果流水线触发了下游流水线，但下游流水线中尚无具有 `可中断: false` 的作业启动，则下游流水线也会被取消。
- 你可以在流水线的第一阶段添加一个可选的、具有 `可中断: false` 的手动作业，以允许用户手动阻止流水线被自动取消。用户启动该作业后，流水线就无法被 **自动取消冗余流水线** 功能取消。
- 当将 `可中断` 与 [trigger 作业](#trigger) 一起使用时：
  - 触发的下游流水线永远不会受到 trigger 作业的 `可中断` 配置的影响。
  - 如果 [`workflow:auto_cancel`](#workflowauto_cancelon_new_commit) 设置为 `保守`，trigger 作业的 `可中断` 配置无效。
  - 如果 [`workflow:auto_cancel`](#workflowauto_cancelon_new_commit) 设置为 `可中断`，具有 `可中断: true` 的 trigger 作业可以被自动取消。

---

<a id="needs"></a>

### `依赖`

使用 `依赖` 可以使作业无序执行。使用 `依赖` 的作业之间的关系可以用[有向无环图](needs.md)来可视化。

你可以忽略阶段顺序，不必等待其他作业完成就可以运行某些作业。多个阶段的作业可以并发运行。

**关键字类型**：作业关键字。你只能在作业中使用它。

**支持的值**：

- 一个作业数组（最多 50 个作业）。
- 一个空数组 (`[]`)，将作业设置为在流水线创建后立即启动。

**`依赖` 示例**：

```yaml
linux:build:
  stage: build
  script: echo "正在构建 linux..."

mac:build:
  stage: build
  script: echo "正在构建 mac..."

lint:
  stage: test
  needs: []
  script: echo "正在 Lint 检查..."

linux:rspec:
  stage: test
  needs: ["linux:build"]
  script: echo "在 linux 上运行 rspec..."

mac:rspec:
  stage: test
  needs: ["mac:build"]
  script: echo "在 mac 上运行 rspec..."

production:
  stage: deploy
  script: echo "正在运行 production..."
  environment: production
```

此示例创建了四条执行路径：

- Linter：`lint` 作业立即运行，无需等待 `build` 阶段完成，因为它没有依赖 (`依赖: []`)。
- Linux 路径：`linux:rspec` 作业在 `linux:build` 作业完成后立即运行，无需等待 `mac:build` 完成。
- macOS 路径：`mac:rspec` 作业在 `mac:build` 作业完成后立即运行，无需等待 `linux:build` 完成。
- `production` 作业在所有之前的作业（`lint`、`linux:build`、`linux:rspec`、`mac:build`、`mac:rspec`）完成后运行。

**更多细节**：

- 单个作业在 `依赖` 数组中可以拥有的最大作业数受限制：
  - 对于 JihuLab.com，限制为 50。
  - 对于极狐GitLab 私有化部署，默认限制为 50。可以通过[在管理区域更新 CI/CD 限制](../../administration/settings/continuous_integration.md#set-cicd-limits)来更改此限制。
- 如果 `依赖` 引用了使用 [`并行`](#parallel) 关键字的作业，则它依赖于所有并行创建的作业，而不仅仅是一个作业。它还会默认从所有并行作业下载产物。如果产物具有相同的名称，它们会相互覆盖，只有最后下载的产物被保存。
  - 要让 `依赖` 引用并行化作业的子集（而不是所有并行化作业），请使用 [`依赖:并行:矩阵`](#needsparallelmatrix) 关键字。
- 你可以引用与所配置作业位于同一阶段的作业。
- 如果 `依赖` 引用了一个可能因为 `only`、`except` 或 `rules` 而无法添加到流水线的作业，流水线可能无法创建。使用 [`依赖:可选`](#needsoptional) 关键字解决流水线创建失败的问题。
- 如果流水线包含具有 `依赖: []` 的作业和位于 [`.pre`](#stage-pre) 阶段的作业，它们都将在流水线创建后立即启动。具有 `依赖: []` 的作业会立即启动，位于 `.pre` 阶段的作业也会立即启动。

---

<a id="needsartifacts"></a>

#### `依赖:产物`

当作业使用 `依赖` 时，它默认不再从之前的所有阶段下载产物，因为带有 `依赖` 的作业可以在早期阶段完成之前开始。使用 `依赖` 时，你只能从 `依赖` 配置中列出的作业下载产物。

使用 `产物: true`（默认）或 `产物: false` 来控制使用 `依赖` 的作业何时下载产物。

**关键字类型**：作业关键字。你只能在作业中使用它。必须与 `依赖:job` 一起使用。

**支持的值**：

- `true`（默认）或 `false`。

**`依赖:产物` 示例**：

```yaml
test-job1:
  stage: test
  needs:
    - job: build_job1
      artifacts: true

test-job2:
  stage: test
  needs:
    - job: build_job2
      artifacts: false

test-job3:
  needs:
    - job: build_job1
      artifacts: true
    - job: build_job2
    - build_job3
```

在此示例中：

- `test-job1` 作业下载 `build_job1` 的产物
- `test-job2` 作业不下载 `build_job2` 的产物。
- `test-job3` 作业下载所有三个构建作业的产物，因为对于所有三个被依赖的作业，`产物` 是 `true` 或者默认是 `true`。

**更多细节**：

- 你不应在同一作业中同时使用 `依赖` 和 [`依赖关系`](#dependencies)。

---

<a id="needsproject"></a>

#### `依赖:项目`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 `依赖:项目` 从其他流水线的最多五个作业下载产物。产物是从指定 ref 的最新成功指定作业下载的。要指定多个作业，请在 `依赖` 关键字下将每个作业添加为单独的数组项。

如果指定的 ref 有流水线正在运行，则带有 `依赖:项目` 的作业不会等待该流水线完成。相反，产物是从该作业最新成功的运行中下载的。

`依赖:项目` 必须与 `job`、`ref` 和 `artifacts` 一起使用。

**关键字类型**：作业关键字。你只能在作业中使用它。

**支持的值**：

- `依赖:项目`：完整的项目路径，包括命名空间和群组。
- `job`：要从中下载产物的作业。
- `ref`：要从中下载产物的 ref。
- `artifacts`：必须为 `true` 才能下载产物。

**`依赖:项目` 示例**：

```yaml
build_job:
  stage: build
  script:
    - ls -lhR
  needs:
    - project: namespace/group/project-name
      job: build-1
      ref: main
      artifacts: true
    - project: namespace/group/project-name-2
      job: build-2
      ref: main
      artifacts: true
```

在此示例中，`build_job` 从 `group/project-name` 和 `group/project-name-2` 项目中 `main` 分支上最新成功的 `build-1` 和 `build-2` 作业下载产物。

你可以在 `依赖:项目` 中使用 [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)，例如：

```yaml
build_job:
  stage: build
  script:
    - ls -lhR
  needs:
    - project: $CI_PROJECT_PATH
      job: $DEPENDENCY_JOB_NAME
      ref: $ARTIFACTS_DOWNLOAD_REF
      artifacts: true
```

**更多细节**：

- 要从当前项目的不同流水线下载产物，请将 `项目` 设置为与当前项目相同，但使用与当前流水线不同的 ref。在同一 ref 上运行的并发流水线可能会覆盖产物。
- 运行流水线的用户必须对群组或项目具有报告者、开发者、维护者或所有者角色，或者群组/项目必须具有公开可见性。
- 你不能在同一作业中同时使用 `依赖:项目` 和 [`触发器`](#trigger)。
- 使用 `依赖:项目` 从其他流水线下载产物时，该作业不会等待需要的作业完成。[使用 `依赖` 等待作业完成](needs.md) 仅限于同一流水线中的作业。确保另一个流水线中需要的作业在依赖它的作业尝试下载产物之前完成。
- 你不能从运行在 [`并行`](#parallel) 中的作业下载产物。
- 支持在 `项目`、`job` 和 `ref` 中使用 [CI/CD 变量](../variables/_index.md)。

**相关主题**：

- 要在[父子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)之间下载产物，请使用 [`依赖:流水线:作业`](#needspipelinejob)。

---

<a id="needspipelinejob"></a>

#### `依赖:流水线:作业`

[子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)可以从其父流水线或同一父子流水线层次结构中的另一个子流水线中成功完成的作业下载产物。

**关键字类型**：作业关键字。你只能在作业中使用它。

**支持的值**：

- `依赖:流水线`：一个流水线 ID。必须是在同一父子流水线层次结构中存在的流水线。
- `job`：要从中下载产物的作业。

**`依赖:流水线:作业` 示例**：

- 父流水线 (`.gitlab-ci.yml`)：

  ```yaml
  stages:
    - build
    - test

  create-artifact:
    stage: build
    script: echo "示例产物" > artifact.txt
    artifacts:
      paths: [artifact.txt]

  child-pipeline:
    stage: test
    trigger:
      include: child.yml
      strategy: mirror
    variables:
      PARENT_PIPELINE_ID: $CI_PIPELINE_ID
  ```

- 子流水线 (`child.yml`)：

  ```yaml
  use-artifact:
    script: cat artifact.txt
    needs:
      - pipeline: $PARENT_PIPELINE_ID
        job: create-artifact
  ```

在此示例中，父流水线中的 `create-artifact` 作业创建了一些产物。`child-pipeline` 作业触发一个子流水线，并将 `CI_PIPELINE_ID` 变量作为新的 `PARENT_PIPELINE_ID` 变量传递给子流水线。子流水线可以使用该变量通过 `依赖:流水线` 从父流水线下载产物。将 `create-artifact` 和 `child-pipeline` 作业放在连续的阶段中，可确保 `use-artifact` 作业仅在 `create-artifact` 成功完成后才执行。

**更多细节**：

- `流水线` 属性不接受当前流水线 ID (`$CI_PIPELINE_ID`)。
  要从当前流水线中的作业下载产物，请使用 [`依赖:产物`](#needsartifacts)。
- 你不能在 [trigger 作业](#trigger)中使用 `依赖:流水线:作业`，也不能从[多项目流水线](../pipelines/downstream_pipelines.md#multi-project-pipelines)获取产物。
  要从多项目流水线获取产物，请使用 [`依赖:项目`](#needsproject)。
- `依赖:流水线:作业` 中列出的作业必须以 `成功` 状态完成，否则无法获取产物。

---

<a id="needsoptional"></a>

#### `依赖:可选`

要为有时不存在于流水线中的作业添加依赖，请在 `依赖` 配置中添加 `可选: true`。如果未定义，则默认 `可选: false`。

使用 [`规则`](#rules)、[`only` 或 `except`](deprecated_keywords.md#only--except) 并且通过 [`include`](#include) 添加的作业可能并不总是被添加到流水线中。极狐GitLab 在启动流水线之前检查 `依赖` 关系：

- 如果 `依赖` 条目具有 `可选: true`，并且所需的作业存在于流水线中，则该作业会等待它完成后再开始。
- 如果所需的作业不存在，则该作业可以在满足所有其他依赖要求后开始。
- 如果 `依赖` 部分仅包含可选作业，并且没有作业被添加到流水线中，则该作业立即开始（相当于空的 `依赖` 条目：`依赖: []`）。
- 如果一个需要的作业具有 `可选: false`，但它没有被添加到流水线中，则流水线启动失败，并显示类似错误：`'job1' 作业需要 'job2' 作业，但 'job2' 未被添加到流水线中`。

**关键字类型**：作业关键字。你只能在作业中使用它。

**`依赖:可选` 示例**：

```yaml
build-job:
  stage: build

test-job1:
  stage: test

test-job2:
  stage: test
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

deploy-job:
  stage: deploy
  needs:
    - job: test-job2
      optional: true
    - job: test-job1
  environment: production

review-job:
  stage: deploy
  needs:
    - job: test-job2
      optional: true
  environment: review
```

在此示例中：

- `build-job`、`test-job1` 和 `test-job2` 按阶段顺序启动。
- 当分支是默认分支时，`test-job2` 被添加到流水线，因此：
  - `deploy-job` 等待 `test-job1` 和 `test-job2` 都完成。
  - `review-job` 等待 `test-job2` 完成。
- 当分支不是默认分支时，`test-job2` 未被添加到流水线，因此：
  - `deploy-job` 仅等待 `test-job1` 完成，不等待缺失的 `test-job2`。
  - `review-job` 没有其他依赖作业，立即开始（与 `build-job` 同时开始），就像 `依赖: []`。

**更多细节**：

- 你不能将 `依赖:可选` 与 [`依赖:并行:矩阵`](#needsparallelmatrix) 一起使用。

---

<a id="needspipeline"></a>

#### `依赖:流水线`

你可以使用 `依赖:流水线` 关键字将上游流水线的流水线状态镜像到作业。默认分支的最新流水线状态会被复制到作业中。

**关键字类型**：作业关键字。你只能在作业中使用它。

**支持的值**：

- 完整的项目路径，包括命名空间和群组。如果项目在同一群组或命名空间中，可以省略 `项目` 关键字中的群组/命名空间。例如：`项目: group/project-name` 或 `项目: project-name`。

**`依赖:流水线` 示例**：

```yaml
upstream_status:
  stage: test
  needs:
    pipeline: other/project
```

**更多细节**：

- 如果你向 `依赖:流水线` 中添加 `job` 关键字，该作业将不再镜像流水线状态。行为将变为 [`依赖:流水线:作业`](#needspipelinejob)。

---

<a id="needsparallelmatrix"></a>

#### `依赖:并行:矩阵`

{{< history >}}

- 在极狐GitLab 16.3 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/254821)。

{{< /history >}}

作业可以使用 [`并行:矩阵`](#parallelmatrix) 在单个流水线中多次并行运行同一作业，但每次作业实例使用不同的变量值。

使用 `依赖:并行:矩阵` 可以根据并行化作业使作业无序执行。

**关键字类型**：作业关键字。你只能在作业中使用它。必须与 `依赖:job` 一起使用。

**支持的值**：矩阵标识符的哈希数组：

- 标识符和值必须从 `并行:矩阵` 作业中定义的标识符和值中选择。
- 你可以使用[矩阵表达式](matrix_expressions.md)。

**`依赖:并行:矩阵` 示例**：

```yaml
linux:build:
  stage: build
  script: echo "正在构建 linux..."
  parallel:
    matrix:
      - PROVIDER: aws
        STACK:
          - monitoring
          - app1
          - app2
```

```yaml
test:
  script: rspec
  retry:
    max: 2
    when:
      - runner_system_failure
      - stuck_or_timeout_failure
```

---

<a id="retry-exit-codes"></a>

### `retry:exit_codes`

{{< history >}}

- 在极狐GitLab 16.10 引入，通过功能标志 `ci_retry_on_exit_codes` 控制。默认禁用。
- 在极狐GitLab 16.11 中于 JihuLab.com 和私有化部署上启用。
- 在极狐GitLab 17.5 中正式发布（GA）。移除了功能标志 `ci_retry_on_exit_codes`。

{{< /history >}}

使用 `retry:exit_codes` 与 `retry:max` 配合，仅针对特定失败情况进行作业重试。`retry:max` 是最大重试次数，类似于 [`retry`](#retry)，可以是 `0`、`1` 或 `2`。

**关键字类型**：作业关键字。只能作为作业的一部分或在 [`default` 部分](#default) 中使用。

**支持的值**：

- 单个退出码。
- 退出码数组。

**`retry:exit_codes` 示例**：

```yaml
test_job_1:
  script:
    - echo "Run a script that results in exit code 1. This job isn't retried."
    - exit 1
  retry:
    max: 2
    exit_codes: 137

test_job_2:
  script:
    - echo "Run a script that results in exit code 137. This job will be retried."
    - exit 137
  retry:
    max: 1
    exit_codes:
      - 255
      - 137
```

**相关主题**：

您可以使用变量为作业执行的某些阶段指定[重试尝试次数](../runners/configure_runners.md#job-stages-attempts)。

---

<a id="rules"></a>

### `rules`

使用 `rules` 在流水线中包含或排除作业。

规则在创建流水线时按顺序进行评估。一旦找到匹配项，就不会再检查后续规则，并根据配置决定将作业包含或排除在流水线中。如果没有规则匹配，则作业不会被添加到流水线中。

`rules` 接受一个规则数组。每个规则必须至少包含以下之一：

- `if`
- `changes`
- `exists`
- `when`

规则还可以选择性地与以下项组合：

- `allow_failure`
- `needs`
- `variables`
- `interruptible`

您可以将多个关键字组合在一起，构建[复杂规则](../jobs/job_rules.md#complex-rules)。

在以下情况下，作业会被添加到流水线中：

- 如果 `if`、`changes` 或 `exists` 规则匹配，并且配置为 `when: on_success`（如未定义则为默认值）、`when: delayed` 或 `when: always`。
- 如果遇到仅包含 `when: on_success`、`when: delayed` 或 `when: always` 的规则。

在以下情况下，作业不会被添加到流水线中：

- 没有规则匹配。
- 规则匹配且包含 `when: never`。

有关更多示例，请参见[使用 `rules` 指定作业运行时机](../jobs/job_rules.md)。

---

<a id="rules-if"></a>

#### `rules:if`

使用 `rules:if` 子句指定何时将作业添加到流水线：

- 如果 `if` 语句为真，则将作业添加到流水线。
- 如果 `if` 语句为真，但与 `when: never` 组合，则不添加作业。
- 如果 `if` 语句为假，则检查下一个 `rules` 条目（如果有）。

`if` 子句的评估依据：

- [CI/CD 变量](../variables/_index.md) 或 [预定义 CI/CD 变量](../variables/predefined_variables.md) 的值，但[有一些例外](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。
- 按顺序遵循 [`rules` 执行流程](#rules)。

**关键字类型**：作业级别和流水线级别。可以作为作业的一部分来配置作业行为，也可以与 [`workflow`](#workflow) 一起使用来配置流水线行为。

**支持的值**：

- [CI/CD 变量表达式](../jobs/job_rules.md#cicd-variable-expressions)。

**`rules:if` 示例**：

```yaml
job:
  script: echo "Hello, Rules!"
  rules:
    - if: $CI_MERGE_REQUEST_SOURCE_BRANCH_NAME =~ /^feature/ && $CI_MERGE_REQUEST_TARGET_BRANCH_NAME != $CI_DEFAULT_BRANCH
      when: never
    - if: $CI_MERGE_REQUEST_SOURCE_BRANCH_NAME =~ /^feature/
      when: manual
      allow_failure: true
    - if: $CI_MERGE_REQUEST_SOURCE_BRANCH_NAME
```

**补充详情**：

- 不能将[嵌套变量](../variables/where_variables_can_be_used.md#nested-variable-expansion) 与 `if` 一起使用。
- 如果规则匹配且未定义 `when`，则使用为作业定义的 `when`，如果未定义则默认为 `on_success`。
- 您可以在作业级别和规则中混合使用 `when`。`rules` 中的 `when` 配置优先于作业级别的 `when`。
- 与 [`script`](../variables/job_scripts.md) 部分中的变量不同，规则表达式中的变量始终格式化为 `$VARIABLE`。
  - 您可以在 `include` 中使用 `rules:if`，以[有条件地包含其他配置文件](includes.md#use-rules-with-include)。
- `=~` 和 `!~` 表达式右侧的 CI/CD 变量会[作为正则表达式进行评估](../jobs/job_rules.md#store-a-regular-expression-in-a-variable)。

**相关主题**：

- [常见的 `rules:if` 预定义变量表达式](../jobs/job_rules.md#common-if-clauses-with-predefined-variables)。
- [避免重复流水线](../jobs/job_rules.md#avoid-duplicate-pipelines)。
- [使用 `rules` 运行合并请求流水线](../pipelines/merge_request_pipelines.md#configure-merge-request-pipelines)。

---

<a id="rules-changes"></a>

#### `rules:changes`

使用 `rules:changes` 通过检查特定文件的变更来指定何时将作业添加到流水线。

对于新的分支流水线，或者没有 Git `push` 事件时，`rules: changes` 始终评估为真，作业始终运行。像标签流水线、计划流水线和手动流水线，都**没有**与之关联的 Git `push` 事件。为了覆盖这些情况，请使用 [`rules: changes: compare_to`](#rules-changes-compare_to) 来指定与流水线引用进行比较的分支。

如果不使用 `compare_to`，您应该只将 `rules: changes` 与[分支流水线](../pipelines/pipeline_types.md#branch-pipeline) 或[合并请求流水线](../pipelines/merge_request_pipelines.md) 一起使用，尽管在创建新分支时 `rules: changes` 仍然评估为真。在：

- 合并请求流水线中，`rules:changes` 会将变更与目标 MR 分支进行比较。
- 分支流水线中，`rules:changes` 会将变更与该分支上的上一个提交进行比较。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

一个数组，可以包含任意数量的：

- 文件路径。文件路径可以包含 [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。
- 通配符路径，支持：
  - 单个目录，例如 `path/to/directory/*`。
  - 一个目录及其所有子目录，例如 `path/to/directory/**/*`。
- 通配符 [glob](https://en.wikipedia.org/wiki/Glob_(programming)) 路径，用于所有具有相同扩展名或多个扩展名的文件，例如 `*.md` 或 `path/to/directory/*.{rb,py,sh}`。
- 根目录或所有目录中文件的双引号通配符路径，例如 `"*.json"` 或 `"**/*.json"`。

**`rules:changes` 示例**：

```yaml
docker build:
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes:
        - Dockerfile
      when: manual
      allow_failure: true

docker build alternative:
  variables:
    DOCKERFILES_DIR: 'path/to/dockerfiles'
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes:
        - $DOCKERFILES_DIR/**/*
```

在此示例中：

- 如果流水线是合并请求流水线，检查 `Dockerfile` 和 `$DOCKERFILES_DIR/**/*` 中的文件是否发生变更。
- 如果 `Dockerfile` 发生变更，则将作业作为手动作业添加到流水线中，并且即使该作业未被触发，流水线也会继续运行（`allow_failure: true`）。
- 如果 `$DOCKERFILES_DIR/**/*` 中的文件发生变更，则将作业添加到流水线中。
- 如果列出的文件均未发生变更，则不将此作业添加到任何流水线（相当于 `when: never`）。

**补充详情**：

- Glob 模式使用 Ruby 的 [`File.fnmatch`](https://docs.ruby-lang.org/en/master/File.html#method-c-fnmatch) 进行解释，并带有 [flags](https://docs.ruby-lang.org/en/master/File/Constants.html#module-File::Constants-label-Filename+Globbing+Constants+-28File-3A-3AFNM_-2A-29) `File::FNM_PATHNAME | File::FNM_DOTMATCH | File::FNM_EXTGLOB`。
- 出于性能考虑，极狐GitLab 对 `changes` 模式或文件路径最多执行 50,000 次检查。在第 50,000 次检查之后，带有模式 glob 的规则始终匹配。换句话说，当变更的文件超过 50,000 个时，或者变更的文件少于 50,000 但 `changes` 规则检查次数超过 50,000 次时，`changes` 规则始终假定匹配。
- 每个 `rules:changes` 部分最多可定义 50 个模式或文件路径。
- 如果任何匹配的文件发生变更（`OR` 运算），`changes` 将解析为 `true`。
- 有关更多示例，请参见[使用 `rules` 指定作业运行时机](../jobs/job_rules.md)。
- 您可以将 `$` 字符用于变量和路径。例如，如果 `$VAR` 变量存在，则使用其值。如果不存在，则 `$` 被解释为路径的一部分。
- 不要使用 `./`、双斜杠 (`//`) 或任何其他类型的相对路径。路径通过精确字符串比较进行匹配，不像在 shell 中那样进行评估。

**相关主题**：

- [使用 `rules: changes` 时作业或流水线可能意外运行](../jobs/job_troubleshooting.md#jobs-or-pipelines-run-unexpectedly-when-using-changes)。

---

<a id="rules-changes-paths"></a>

##### `rules:changes:paths`

{{< history >}}

- 在极狐GitLab 15.2 引入。

{{< /history >}}

使用 `rules:changes` 来指定仅在特定文件发生变更时才将作业添加到流水线，并使用 `rules:changes:paths` 来指定这些文件。

`rules:changes:paths` 与不带任何子键的 [`rules:changes`](#rules-changes) 相同。所有补充详情和相关主题均相同。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- 与 `rules:changes` 相同。

**`rules:changes:paths` 示例**：

```yaml
docker-build-1:
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes:
        - Dockerfile

docker-build-2:
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes:
        paths:
          - Dockerfile
```

在此示例中，两个作业的行为相同。

---

<a id="rules-changes-compare_to"></a>

##### `rules:changes:compare_to`

{{< history >}}

- 在极狐GitLab 15.3 引入，通过功能标志 `ci_rules_changes_compare` 控制。默认启用。
- 在极狐GitLab 15.5 中正式发布（GA）。移除了功能标志 `ci_rules_changes_compare`。
- 在极狐GitLab 17.2 中开始支持 CI/CD 变量。

{{< /history >}}

使用 `rules:changes:compare_to` 来指定要与 [`rules:changes:paths`](#rules-changes-paths) 中列出的文件进行变更比较的引用。

**关键字类型**：作业关键字。只能作为作业的一部分使用，并且必须与 `rules:changes:paths` 组合使用。

**支持的值**：

- 分支名称，如 `main`、`branch1` 或 `refs/heads/branch1`。
- 标签名称，如 `tag1` 或 `refs/tags/tag1`。
- 提交 SHA，如 `2fg31ga14b`。

支持 [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。

**`rules:changes:compare_to` 示例**：

```yaml
docker build:
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes:
        paths:
          - Dockerfile
        compare_to: 'refs/heads/branch1'
```

在此示例中，仅当 `Dockerfile` 相对于 `refs/heads/branch1` 发生了变更，且流水线源是合并请求事件时，才会包含 `docker build` 作业。

**补充详情**：

- 在某些情况下使用 `compare_to` 可能会导致意外结果：
  - 当使用[合并结果的流水线](../pipelines/merged_results_pipelines.md#troubleshooting)时，因为比较基础是极狐GitLab 创建的内部提交。
  - 在 fork 项目中存在已知问题。

**相关主题**：

- 您可以使用 `rules:changes:compare_to` 来[在分支为空时跳过作业](../jobs/job_rules.md#skip-jobs-if-the-branch-is-empty)。

---

<a id="rules-exists"></a>

#### `rules:exists`

{{< history >}}

- 在极狐GitLab 15.6 中开始支持 CI/CD 变量。
- 在极狐GitLab 17.7 中，对 `exists` 模式或文件路径的最大检查次数从 10,000 次增加到了 50,000 次。
- 在极狐GitLab 18.2 中开始支持目录路径。

{{< /history >}}

使用 `exists` 在仓库中存在特定文件或目录时运行作业。

**关键字类型**：作业关键字。可以作为作业的一部分或 [`include`](#include) 的一部分使用。

**支持的值**：

- 文件或目录路径数组。路径相对于项目目录 (`$CI_PROJECT_DIR`) 并且不能直接链接到其外部。文件路径可以使用 glob 模式和 [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。

**`rules:exists` 示例**：

```yaml
job1:
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - exists:
        - Dockerfile

job2:
  variables:
    DOCKERPATH: "**/Dockerfile"
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - exists:
        - $DOCKERPATH
```

在此示例中：

- 如果仓库根目录中存在 `Dockerfile`，则运行 `job1`。
- 如果仓库中任意位置存在 `Dockerfile`，则运行 `job2`。

**补充详情**：

- Glob 模式使用 Ruby 的 [`File.fnmatch`](https://docs.ruby-lang.org/en/master/File.html#method-c-fnmatch) 进行解释，并带有 [flags](https://docs.ruby-lang.org/en/master/File/Constants.html#module-File::Constants-label-Filename+Globbing+Constants+-28File-3A-3AFNM_-2A-29) `File::FNM_PATHNAME | File::FNM_DOTMATCH | File::FNM_EXTGLOB`。
- 出于性能考虑，极狐GitLab 对 `exists` 模式或文件路径最多执行 50,000 次检查。在第 50,000 次检查之后，带有模式 glob 的规则始终匹配。换句话说，在文件数量超过 50,000 的项目中，或者文件少于 50,000 但 `exists` 规则检查次数超过 50,000 次时，`exists` 规则始终假定匹配。
  - 如果有多个模式 glob，则限制为 50,000 除以 glob 的数量。例如，具有 5 个 pattern glob 的规则，文件限制为 10,000。
- 每个 `rules:exists` 部分最多可定义 50 个模式或文件路径。
- 如果找到任何列出的文件（`OR` 运算），`exists` 则解析为 `true`。
- 对于作业级别的 `rules:exists`，极狐GitLab 在运行流水线的项目和引用中搜索文件。当使用 [`include` 与 `rules:exists`](includes.md#include-with-rulesexists) 时，极狐GitLab 在包含 `include` 部分的文件所在的项目和引用中搜索文件或目录。当使用以下功能时，包含 `include` 部分的项目可以与运行流水线的项目不同：
  - [嵌套 includes](includes.md#use-nested-includes)。
  - [合规性流水线](../../user/compliance/compliance_pipelines.md)。
- `rules:exists` 无法搜索[产物](../jobs/job_artifacts.md)的存在，因为 `rules` 评估发生在作业运行和产物获取之前。
- 要测试目录是否存在，路径必须以正斜杠 (/) 结尾。

---

<a id="rules-exists-paths"></a>

##### `rules:exists:paths`

{{< history >}}

- 在极狐GitLab 16.11 引入，通过功能标志 `ci_support_rules_exists_paths_and_project` 控制。默认禁用。
- 在极狐GitLab 17.0 中正式发布（GA）。移除了功能标志 `ci_support_rules_exists_paths_and_project`。

{{< /history >}}

`rules:exists:paths` 与不带任何子键的 [`rules:exists`](#rules-exists) 相同。所有补充详情均相同。

**关键字类型**：作业关键字。可以作为作业的一部分或 [`include`](#include) 的一部分使用。

**支持的值**：

- 文件路径数组。

**`rules:exists:paths` 示例**：

```yaml
docker-build-1:
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      exists:
        - Dockerfile

docker-build-2:
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      exists:
        paths:
          - Dockerfile
```

在此示例中，两个作业的行为相同。

---

<a id="rules-exists-project"></a>

##### `rules:exists:project`

{{< history >}}

- 在极狐GitLab 16.11 引入，通过功能标志 `ci_support_rules_exists_paths_and_project` 控制。默认禁用。
- 在极狐GitLab 17.0 中正式发布（GA）。移除了功能标志 `ci_support_rules_exists_paths_and_project`。

{{< /history >}}

使用 `rules:exists:project` 来指定在哪个位置搜索 [`rules:exists:paths`](#rules-exists-paths) 中列出的文件。必须与 `rules:exists:paths` 一起使用。

**关键字类型**：作业关键字。可以作为作业的一部分或 [`include`](#include) 的一部分使用，并且必须与 `rules:exists:paths` 组合使用。

**支持的值**：

- `exists:project`：完整的项目路径，包括命名空间和群组。
- `exists:ref`：可选。用于搜索文件的提交引用。引用可以是标签、分支名称或 SHA。未指定时默认为项目的 `HEAD`。

**`rules:exists:project` 示例**：

```yaml
docker build:
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  rules:
    - exists:
        paths:
          - Dockerfile
        project: my-group/my-project
        ref: v1.0.0
```

在此示例中，仅当在项目 `my-group/my-project` 中标记为 `v1.0.0` 的提交上存在 `Dockerfile` 时，才会包含 `docker build` 作业。

---

<a id="rules-when"></a>

#### `rules:when`

可以单独使用 `rules:when`，也可以将其作为其他规则的一部分，以控制将作业添加到流水线的条件。`rules:when` 类似于 [`when`](#when)，但输入选项略有不同。

如果 `rules:when` 规则没有与 `if`、`changes` 或 `exists` 组合，那么在评估作业规则时，只要遇到它，它就会始终匹配。

**关键字类型**：作业级别。只能作为作业的一部分使用。

**支持的值**：

- `on_success`（默认值）：仅当早期阶段没有作业失败时才运行作业。
- `on_failure`：仅当早期阶段至少有一个作业失败时才运行作业。
- `never`：无论早期阶段作业的状态如何，都不运行作业。
- `always`：无论早期阶段作业的状态如何，都运行作业。
- `manual`：将作业作为[手动作业](../jobs/job_control.md#create-a-job-that-must-be-run-manually) 添加到流水线。 [`allow_failure`](#allow_failure) 的默认值更改为 `false`。
- `delayed`：将作业作为[延迟作业](../jobs/job_control.md#run-a-job-after-a-delay) 添加到流水线。

**`rules:when` 示例**：

```yaml
job1:
  rules:
    - if: $CI_COMMIT_REF_NAME == $CI_DEFAULT_BRANCH
    - if: $CI_COMMIT_REF_NAME =~ /feature/
      when: delayed
    - when: manual
  script:
    - echo
```

在此示例中，`job1` 会在以下情况下添加到流水线：

- 对于默认分支，使用 `when: on_success`（未定义 `when` 时的默认行为）。
- 对于特性分支，作为延迟作业。
- 在所有其他情况下，作为手动作业。

**补充详情**：

- 在评估 `on_success` 和 `on_failure` 的作业状态时：
  - 早期阶段中具有 [`allow_failure: true`](#allow_failure) 的作业即使失败也被视为成功。
  - 早期阶段中被跳过的作业，例如[尚未启动的手动作业](../jobs/job_control.md#create-a-job-that-must-be-run-manually)，被视为成功。
- 当使用 `rules:when: manual` 来[添加手动作业](../jobs/job_control.md#create-a-job-that-must-be-run-manually) 时：
  - [`allow_failure`](#allow_failure) 默认变为 `false`。此默认值与在 `rules` 外部使用 [`when: manual`](#when) 添加手动作业相反。
  - 要获得与在 `rules` 外部定义的 `when: manual` 相同的行为，请将 [`rules: allow_failure`](#rules-allow_failure) 设置为 `true`。

---

<a id="rules-allow_failure"></a>

#### `rules:allow_failure`

在 `rules` 中使用 [`allow_failure: true`](#allow_failure) 可以允许作业失败而不停止流水线。

您也可以将 `allow_failure: true` 与手动作业一起使用。流水线会继续运行，而不等待手动作业的结果。在规则中，`allow_failure: false` 与 `when: manual` 结合使用会导致流水线等待手动作业运行后再继续。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- `true` 或 `false`。如果未定义，则默认为 `false`。

**`rules:allow_failure` 示例**：

```yaml
job:
  script: echo "Hello, Rules!"
  rules:
    - if: $CI_MERGE_REQUEST_TARGET_BRANCH_NAME == $CI_DEFAULT_BRANCH
      when: manual
      allow_failure: true
```

如果规则匹配，则该作业是一个 `allow_failure: true` 的手动作业。

**补充详情**：

- 规则级别的 `rules:allow_failure` 会覆盖作业级别的 [`allow_failure`](#allow_failure)，并且仅在特定规则触发该作业时适用。

---

<a id="rules-needs"></a>

#### `rules:needs`

{{< history >}}

- 在极狐GitLab 16.0 引入，通过功能标志 `introduce_rules_with_needs` 控制。默认禁用。
- 在极狐GitLab 16.2 中正式发布（GA）。移除了功能标志 `introduce_rules_with_needs`。

{{< /history >}}

在规则中使用 `needs` 可针对特定条件更新作业的 [`needs`](#needs)。当条件与规则匹配时，作业的 `needs` 配置将完全替换为该规则中的 `needs`。

**关键字类型**：作业级别。只能作为作业的一部分使用。

**支持的值**：

- 字符串形式的作业名称数组。
- 一个哈希，包含作业名称，并可选择附加属性。
- 一个空数组 (`[]`)，用于在满足特定条件时将作业的需求设置为无。

**`rules:needs` 示例**：

```yaml
build-dev:
  stage: build
  rules:
    - if: $CI_COMMIT_BRANCH != $CI_DEFAULT_BRANCH
  script: echo "Feature branch, so building dev version..."

build-prod:
  stage: build
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
  script: echo "Default branch, so building prod version..."

tests:
  stage: test
  rules:
    - if: $CI_COMMIT_BRANCH != $CI_DEFAULT_BRANCH
      needs: ['build-dev']
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      needs: ['build-prod']
  script: echo "Running dev specs by default, or prod specs when default branch..."
```

在此示例中：

- 如果流水线在非默认分支上运行，因此规则匹配第一个条件，则 `specs` 作业需要 `build-dev` 作业。
- 如果流水线在默认分支上运行，因此规则匹配第二个条件，则 `specs` 作业需要 `build-prod` 作业。

**补充详情**：

- 规则中的 `needs` 会覆盖作业级别定义的任何 `needs`。覆盖后，其行为与[作业级别 `needs`](#needs) 相同。
- 规则中的 `needs` 可以接受 [`artifacts`](#needs-artifacts) 和 [`optional`](#needs-optional)。

---

<a id="rules-variables"></a>

#### `rules:variables`

在 `rules` 中使用 [`variables`](#variables) 为特定条件定义变量。

**关键字类型**：作业级别。只能作为作业的一部分使用。

**支持的值**：

- `VARIABLE-NAME: value` 格式的变量哈希。

**`rules:variables` 示例**：

job1:
  stage: build
  script:
    - echo "This job runs in the build stage."

last-job:
  stage: .post
  script:
    - echo "This job runs in the .post stage, after all other stages."

job2:
  stage: test
  script:
    - echo "This job runs in the test stage."
```

**更多细节**：

- [流水线执行策略](../../user/application_security/policies/pipeline_execution_policies.md) 可以定义一个 `.pipeline-policy-post` 阶段，该阶段在 `.post` 之后运行。

---

<a id="tags"></a>

### 标签

使用 `tags` 从项目可用的所有 Runner 中选择特定 Runner。

当你注册一个 Runner 时，可以指定 Runner 的标签，例如 `ruby`、`postgres` 或 `development`。要获取并运行一个任务，Runner 必须被分配了任务中列出的每个标签。

任务配置与默认配置不会合并在一起。如果流水线中定义了 [`default:tags`](#default)，并且任务也定义了 `tags`，则任务配置优先，默认配置不会被使用。

**关键字类型**：任务关键字。只能将其作为任务的一部分或在 [`default` 部分](#default)中使用。

**支持的值**：

- 标签名称数组，区分大小写。
- 支持 CI/CD 变量 [支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。

**`tags` 示例**：

```yaml
job:
  tags:
    - ruby
    - postgres
```

在此示例中，只有同时具有 `ruby` 和 `postgres` 标签的 Runner 才能运行该任务。

**更多细节**：

- 标签数量必须少于 `50`。

**相关主题**：

- [使用标签控制 Runner 可以运行哪些任务](../runners/configure_runners.md#control-jobs-that-a-runner-can-run)
- [为每个并行 matrix 任务选择不同的 Runner 标签](../jobs/job_control.md#select-different-runner-tags-for-each-parallel-matrix-job)
- 托管 Runner 的 Runner 标签：
  - [Linux 上的托管 Runner](../runners/hosted_runners/linux.md)
  - [启用 GPU 的托管 Runner](../runners/hosted_runners/gpu_enabled.md)
  - [macOS 上的托管 Runner](../runners/hosted_runners/macos.md)
  - [Windows 上的托管 Runner](../runners/hosted_runners/windows.md)

---

<a id="timeout"></a>

### 超时

使用 `timeout` 为特定任务配置超时。如果任务运行时间超过超时时间，则任务失败。

任务级超时时间可以比[项目级超时时间](../pipelines/settings.md#set-a-limit-for-how-long-jobs-can-run)长，但不能超过 [Runner 的超时时间](../runners/configure_runners.md#set-the-maximum-job-timeout)。

**关键字类型**：任务关键字。只能将其作为任务的一部分使用。

**支持的值**：以自然语言编写的时长。例如，以下均等效：

- `3600 秒`
- `60 分钟`
- `1 小时`

**`timeout` 示例**：

```yaml
build:
  script: build.sh
  timeout: 3 hours 30 minutes

test:
  script: rspec
  timeout: 3h 30m
```

**更多细节**：

- `timeout` 关键字在 `default` 配置中不受支持。请改为在单个任务配置中定义 `timeout`。更多信息，请参见议题 213634。

---

<a id="trigger"></a>

### 触发器

{{< history >}}

- 在极狐GitLab 16.4 中引入了对 `environment` 的支持。

{{< /history >}}

使用 `trigger` 声明任务是一个“触发器任务”，该任务会启动下游流水线，可以是：

- [多项目流水线](../pipelines/downstream_pipelines.md#multi-project-pipelines)。
- [子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)。

触发器任务只能使用有限的极狐GitLab CI/CD 配置关键字。可在触发器任务中使用的关键字包括：

- [`allow_failure`](#allow_failure)。
- [`extends`](#extends)。
- [`needs`](#needs)，但不包括 [`needs:project`](#needsproject)。
- [`only` 和 `except`](deprecated_keywords.md#only--except)。
- [`parallel`](#parallel)。
- [`rules`](#rules)。
- [`stage`](#stage)。
- [`trigger`](#trigger)。
- [`variables`](#variables)。
- [`when`](#when)（仅限值为 `on_success`、`on_failure`、`always` 或 `manual`）。
- [`resource_group`](#resource_group)。
- [`environment`](#environment)。

**关键字类型**：任务关键字。只能将其作为任务的一部分使用。

**支持的值**：

- 对于多项目流水线，下游项目的路径。CI/CD 变量[支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)在极狐GitLab 15.3 及更高版本中使用，但不包括[仅任务变量](../variables/predefined_variables.md#variable-availability)。或者，使用 [`trigger:project`](#triggerproject)。
- 对于子流水线，使用 [`trigger:include`](#triggerinclude)。

**`trigger` 示例**：

```yaml
trigger-multi-project-pipeline:
  trigger: my-group/my-project
```

**更多细节**：

- 可以在与 `trigger` 相同的任务中使用 [`when:manual`](#when)，但不能使用 API 启动 `when:manual` 触发器任务。更多详情，请参见议题 284086。
- 在运行手动触发器任务之前，不能[手动指定 CI/CD 变量](../jobs/job_control.md#specify-variables-when-running-manual-jobs)。
- 在顶层 `variables` 部分（全局）或在触发器任务中定义的 [CI/CD 变量](#variables) 将作为[触发器变量](../pipelines/downstream_pipelines.md#pass-cicd-variables-to-a-downstream-pipeline)转发到下游流水线。
- 默认情况下，[流水线变量](../variables/_index.md#cicd-variable-precedence)不会传递到下游流水线。使用 [`trigger:forward`](#triggerforward) 将这些变量转发到下游流水线。
- [仅任务变量](../variables/predefined_variables.md#variable-availability)在触发器任务中不可用。
- 在 [Runner 的 `config.toml`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runners-section) 中定义的环境变量不可用于触发器任务，也不会传递到下游流水线。
- 不能在触发器任务中使用 [`needs:pipeline:job`](#needspipelinejob)。

**相关主题**：

- [多项目流水线配置示例](../pipelines/downstream_pipelines.md#trigger-a-downstream-pipeline-from-a-job-in-the-gitlab-ciyml-file)。
- 要为特定分支、标签或提交运行流水线，可以使用[触发器令牌](../triggers/_index.md)来通过[流水线触发器 API](../../api/pipeline_triggers.md) 进行认证。触发器令牌与 `trigger` 关键字不同。

---

<a id="trigger-inputs"></a>

#### 触发器：输入

{{< history >}}

- 在极狐GitLab 17.11 中引入。

{{< /history >}}

使用 `trigger:inputs` 来设置多项目流水线的[输入](../inputs/_index.md)，当下游流水线配置使用了 [`spec:inputs`](#specinputs) 时。

**`trigger:inputs` 示例**：

```yaml
trigger:
  - project: 'my-group/my-project'
    inputs:
      website: "My website"
```

---

<a id="trigger-include"></a>

#### 触发器：包含

使用 `trigger:include` 声明任务是一个“触发器任务”，该任务会启动[子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)。

**关键字类型**：任务关键字。只能将其作为任务的一部分使用。

**支持的值**：

- 子流水线配置文件的路径。

**`trigger:include` 示例**：

```yaml
trigger-child-pipeline:
  trigger:
    include: path/to/child-pipeline.gitlab-ci.yml
```

**更多细节**：

使用方法：

- `trigger:include:artifact` 可触发[动态子流水线](../pipelines/downstream_pipelines.md#dynamic-child-pipelines)。
- `trigger:include:inputs` 可在下游流水线配置使用了 [`spec:inputs`](#specinputs) 时设置[输入](../inputs/_index.md)。
- `trigger:include:local` 用于在以下情况下指定子流水线配置文件的路径：
  - 合并[多个子流水线配置文件](../pipelines/downstream_pipelines.md#combine-multiple-child-pipeline-configuration-files)。
  - 与 `trigger:include:inputs` 结合使用时，向子流水线传递输入。例如：

    ```yaml
    staging-job:
      trigger:
        include:
          - local: path/to/child-pipeline.yml
            inputs:
              environment: staging
    ```

- `trigger:include:project` 用于触发子流水线，[使用不同项目中的配置文件](../pipelines/downstream_pipelines.md#use-a-child-pipeline-configuration-file-in-a-different-project)。如果该文件包含额外的 [`include`](#include) 条目，极狐GitLab 会在运行流水线的项目中查找这些文件，而不是在托管该文件的项目中。
- `trigger:include:template` 用于使用 CI/CD 模板触发子流水线。

**相关主题**：

- [子流水线配置示例](../pipelines/downstream_pipelines.md#trigger-a-downstream-pipeline-from-a-job-in-the-gitlab-ciyml-file)。

---

<a id="trigger-include-inputs"></a>

#### 触发器：包含输入

{{< history >}}

- 在极狐GitLab 17.11 中引入。

{{< /history >}}

使用 `trigger:include:inputs` 来设置子流水线的[输入](../inputs/_index.md)，当下游流水线配置使用了 [`spec:inputs`](#specinputs) 时。

**`trigger:inputs` 示例**：

```yaml
trigger-job:
  trigger:
    include:
      - local: path/to/child-pipeline.yml
        inputs:
          website: "My website"
```

---

<a id="trigger-project"></a>

#### 触发器：项目

使用 `trigger:project` 声明任务是一个“触发器任务”，该任务会启动[多项目流水线](../pipelines/downstream_pipelines.md#multi-project-pipelines)。

默认情况下，多项目流水线会针对默认分支触发。使用 `trigger:branch` 指定不同的分支。

**关键字类型**：任务关键字。只能将其作为任务的一部分使用。

**支持的值**：

- 下游项目的路径。CI/CD 变量[支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)在极狐GitLab 15.3 及更高版本中使用，但不包括[仅任务变量](../variables/predefined_variables.md#variable-availability)。

**`trigger:project` 示例**：

```yaml
trigger-multi-project-pipeline:
  trigger:
    project: my-group/my-project
```

**为不同分支使用 `trigger:project` 的示例**：

```yaml
trigger-multi-project-pipeline:
  trigger:
    project: my-group/my-project
    branch: development
```

**相关主题**：

- [多项目流水线配置示例](../pipelines/downstream_pipelines.md#trigger-a-downstream-pipeline-from-a-job-in-the-gitlab-ciyml-file)。
- 要为特定分支、标签或提交运行流水线，也可以使用[触发器令牌](../triggers/_index.md)来通过[流水线触发器 API](../../api/pipeline_triggers.md) 进行认证。触发器令牌与 `trigger` 关键字不同。

---

<a id="trigger-strategy"></a>

#### 触发器：策略

{{< history >}}

- `strategy:mirror` 选项在极狐GitLab 18.2 中引入。

{{< /history >}}

使用 `trigger:strategy` 强制 `trigger` 任务等待下游流水线完成，然后再将其标记为 **成功**。

此行为与默认行为不同，默认行为是在下游流水线创建后立即将 `trigger` 任务标记为 **成功**。

此设置使你的流水线执行变为线性而非并行。

**支持的值**：

- `mirror`：完全镜像下游流水线的状态。
- `depend`：不建议使用，请改用 `mirror`。触发器任务状态会显示 **失败**、**成功** 或 **运行中**，具体取决于下游流水线状态。请参见更多细节。

**`trigger:strategy` 示例**：

```yaml
trigger_job:
  trigger:
    include: path/to/child-pipeline.yml
    strategy: mirror
```

在此示例中，后续阶段的作业会等待被触发的流水线成功完成后才启动。

**更多细节**：

- 下游流水线中的[可选手动任务](../jobs/job_control.md#types-of-manual-jobs)不会影响下游流水线或上游触发器任务的状态。下游流水线可以在不运行任何可选手动任务的情况下成功完成。
- 默认情况下，后续阶段的作业在触发器任务完成之前不会启动。
- 下游流水线中的[阻塞手动任务](../jobs/job_control.md#types-of-manual-jobs)必须先运行，然后触发器任务才会被标记为成功或失败。
- 使用 `strategy:depend`（不再推荐，请改用 `strategy:mirror`）时：
  - 如果下游流水线状态由于手动任务而处于 **等待手动操作**（{{< icon name="status_manual" >}}），则触发器任务会显示 **运行中**（{{< icon name="status_running" >}}）。
  - 如果下游流水线有失败的作业，但该作业使用了 [`allow_failure: true`](#allow_failure)，则下游流水线被视为成功，触发器任务显示 **成功**。

---

<a id="trigger-forward"></a>

#### 触发器：转发

{{< history >}}

- 在极狐GitLab 15.1 中 GA。功能标志 `ci_trigger_forward_variables` 已移除。

{{< /history >}}

使用 `trigger:forward` 指定要转发到下游流水线的信息。你可以控制转发到[父子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)和[多项目流水线](../pipelines/downstream_pipelines.md#multi-project-pipelines)的内容。

除非嵌套的下游触发器任务也使用了 `trigger:forward`，否则默认情况下，转发的变量不会在嵌套的下游流水线中再次转发。

**支持的值**：

- `yaml_variables`：`true`（默认）或 `false`。为 `true` 时，在触发器任务中定义的变量会传递到下游流水线。
- `pipeline_variables`：`true` 或 `false`（默认）。为 `true` 时，[流水线变量](../variables/_index.md#cicd-variable-precedence)会传递到下游流水线。

**`trigger:forward` 示例**：

[手动运行此流水线](../pipelines/_index.md#run-a-pipeline-manually)，并设置 CI/CD 变量 `MYVAR = my value`：

```yaml
variables: # default variables for each job
  VAR: value

---

# Default behavior:
---

# - VAR is passed to the child
---

# - MYVAR is not passed to the child
child1:
  trigger:
    include: .child-pipeline.yml

---

# Forward pipeline variables:
---

# - VAR is passed to the child
---

# - MYVAR is passed to the child
child2:
  trigger:
    include: .child-pipeline.yml
    forward:
      pipeline_variables: true

---

# Do not forward YAML variables:
---

# - VAR is not passed to the child
---

# - MYVAR is not passed to the child
child3:
  trigger:
    include: .child-pipeline.yml
    forward:
      yaml_variables: false
```

**更多细节**：

- 使用 `trigger:forward` 转发到下游流水线的 CI/CD 变量是[流水线变量](../variables/_index.md#cicd-variable-precedence)，具有高优先级。如果下游流水线中定义了同名变量，该变量通常会被转发的变量覆盖。

---

<a id="when"></a>

### when

使用 `when` 配置任务运行的条件。如果未在任务中定义，默认值为 `when: on_success`。

**关键字类型**：任务关键字。可作为任务的一部分使用。`when: always` 和 `when: never` 也可用于 [`workflow:rules`](#workflow)。

**支持的值**：

- `on_success`（默认）：仅当之前阶段均未失败时才运行任务。
- `on_failure`：仅当之前阶段中至少有一个任务失败时才运行任务。
- `never`：无论之前阶段的状态如何，均不运行任务。只能在 [`rules`](#ruleswhen) 部分或 [`workflow: rules`](#workflowrules) 中使用。
- `always`：无论之前阶段的状态如何，均运行任务。
- `manual`：将任务作为[手动任务](../jobs/job_control.md#create-a-job-that-must-be-run-manually)添加到流水线中。
- `delayed`：将任务作为[延迟任务](../jobs/job_control.md#run-a-job-after-a-delay)添加到流水线中。

**`when` 示例**：

```yaml
stages:
  - build
  - cleanup_build
  - test
  - deploy
  - cleanup

build_job:
  stage: build
  script:
    - make build

cleanup_build_job:
  stage: cleanup_build
  script:
    - cleanup build when failed
  when: on_failure

test_job:
  stage: test
  script:
    - make test

deploy_job:
  stage: deploy
  script:
    - make deploy
  when: manual
  environment: production

cleanup_job:
  stage: cleanup
  script:
    - cleanup after jobs
  when: always
```

在此示例中，脚本执行如下：

1. 仅当 `build_job` 失败时才执行 `cleanup_build_job`。
1. 无论成功或失败，始终在流水线的最后一步执行 `cleanup_job`。
1. 当你在极狐GitLab UI 中手动运行 `deploy_job` 时执行该任务。

**更多细节**：

- 在评估 `on_success` 和 `on_failure` 的任务状态时：
  - 之前阶段中设置了 [`allow_failure: true`](#allow_failure) 的任务即使失败，也被视为成功。
  - 之前阶段中跳过的任务，例如[尚未启动的手动任务](../jobs/job_control.md#create-a-job-that-must-be-run-manually)，也被视为成功。
- 使用 `when: manual` 时，[`allow_failure`](#allow_failure) 的默认值为 `true`。而使用 [`rules:when: manual`](#ruleswhen) 时，默认值变为 `false`。

**相关主题**：

- `when` 可以与 [`rules`](#rules) 结合使用，以实现更动态的任务控制。
- `when` 可以与 [`workflow`](#workflow) 结合使用，以控制何时启动流水线。

---

<a id="manual_confirmation"></a>

#### manual_confirmation

{{< history >}}

- 在极狐GitLab 17.1 中引入。
- 在极狐GitLab 18.3 中引入了对环境停止作业的支持。

{{< /history >}}

使用 `manual_confirmation` 与 [`when: manual`](#when) 为手动任务定义自定义确认消息。如果未使用 `when: manual` 定义手动任务，则此关键字无效。

手动确认适用于所有手动任务，包括使用 [`environment:action: stop`](#environmentaction) 的环境停止任务。

**关键字类型**：任务关键字。只能将其作为任务的一部分使用。

**支持的值**：

- 包含确认消息的字符串。

**`manual_confirmation` 示例**：

```yaml
delete_job:
  stage: post-deployment
  script:
    - make delete
  when: manual
  manual_confirmation: 'Are you sure you want to delete this environment?'

stop_production:
  stage: cleanup
  script:
    - echo "Stopping production environment"
  environment:
    name: production
    action: stop
  when: manual
  manual_confirmation: "Are you sure you want to stop the production environment?"
```

---

<a id="start_in"></a>

### start_in

使用 `start_in` 将任务的执行延迟到任务创建后的指定时长。你必须为任务配置 `when: delayed`。

**关键字类型**：任务关键字。只能将其作为任务的一部分使用。

**可能的值**：以秒、分钟或小时为单位的时长。必须小于或等于一周。有效值示例：

- `'5'`（5 秒）
- `'10 秒'`
- `'30 分钟'`
- `'1 小时'`
- `'1 天'`

**`start_in` 示例**：

```yaml
deploy_production:
  stage: deploy
  script:
    - echo "Deploying to production"
  when: delayed
  start_in: 30 minutes
```

在此示例中，`deploy_production` 任务会在之前阶段完成后 30 分钟启动。

**更多细节**：

- 计时器在任务所在阶段开始时启动，而非在上一个任务完成时启动。
- 要立即手动启动延迟任务，请在流水线视图中选择 **播放**（{{< icon name="play" >}}）。
- 最短延迟为 1 秒，最长延迟为 1 周。
- `start_in` 仅当 [`when`](#when) 设置为 `delayed` 时才有效。如果你为 `when` 使用其他任何值，配置将无效。如果任务使用了 `rules`，则 `start_in` 和 `when` 必须在 `rules` 中定义，而不是在任务级别定义。否则，你会收到一个验证错误：`config key may not be used with 'rules': start_in`。
- `start_in` 不支持与 `workflow:rules` 一起使用，但不会导致语法违规。

**相关主题**：

- [延迟后运行任务](../jobs/job_control.md#run-a-job-after-a-delay)

---

<a id="variables"></a>

## 变量

使用 `variables` 定义 [CI/CD 变量](../variables/_index.md#define-a-cicd-variable-in-the-gitlab-ciyml-file)。

变量可以[在 CI/CD 任务中定义](#job-variables)，也可以作为顶级（全局）关键字为所有任务定义[默认 CI/CD 变量](#default-variables)。

**更多细节**：

- 所有 YAML 定义的变量也会设置到任何链接的 [Docker 服务容器](../services/_index.md)中。
- YAML 定义的变量适用于非敏感的项目配置。将敏感信息存储在[受保护变量](../variables/_index.md#protect-a-cicd-variable)或 [CI/CD 密钥](../secrets/_index.md)中。
- 默认情况下，[手动流水线变量](../variables/_index.md#use-pipeline-variables)和[计划流水线变量](../pipelines/schedules.md#create-a-pipeline-schedule)不会传递到下游流水线。使用 [`trigger:forward`](#triggerforward) 将这些变量转发到下游流水线。

**相关主题**：

- [预定义变量](../variables/predefined_variables.md)是 Runner 自动创建并提供给任务使用的变量。
- 你可以[通过变量配置 Runner 行为](../runners/configure_runners.md#configure-runner-behavior-with-variables)。

---

<a id="job-variables"></a>

### 任务变量

你可以在任务的 `script`、`before_script` 或 `after_script` 部分的命令中使用任务变量，也可以与某些[任务关键字](#job-keywords)一起使用。请查看每个任务关键字的**支持的值**部分，以确认其是否支持变量。

你不能将任务变量用作[全局关键字](#global-keywords)（例如 [`include`](includes.md#use-variables-with-include)）的值。

**支持的值**：变量名和值对：

- 变量名只能使用数字、字母和下划线（`_`）。在某些 shell 中，首字符必须是字母。
- 值必须为字符串。

CI/CD 变量[支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。

**任务 `variables` 示例**：

```yaml
review_job:
  variables:
    DEPLOY_SITE: "https://dev.example.com/"
    REVIEW_PATH: "/review"
  script:
    - deploy-review-script --url $DEPLOY_SITE --path $REVIEW_PATH
```

在此示例中：

- `review_job` 定义了 `DEPLOY_SITE` 和 `REVIEW_PATH` 两个任务变量。这两个任务变量都可以在 `script` 部分中使用。

---

<a id="default-variables"></a>

### 默认变量

在顶级 `variables` 部分中定义的变量作为所有任务的默认变量。

除任务已定义同名变量外，每个默认变量都可用于流水线中的每个任务。任务中定义的变量[优先级更高](../variables/_index.md#cicd-variable-precedence)，因此同名默认变量的值不会在任务中使用。

与任务变量一样，你不能将默认变量用作其他全局关键字（例如 [`include`](includes.md#use-variables-with-include)）的值。

**支持的值**：变量名和值对：

- 变量名只能使用数字、字母和下划线（`_`）。在某些 shell 中，首字符必须是字母。
- 值必须为字符串。

CI/CD 变量[支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。

**`variables` 示例**：

```yaml
variables:
  DEPLOY_SITE: "https://example.com/"

deploy_job:
  stage: deploy
  script:
    - deploy-script --url $DEPLOY_SITE --path "/"
  environment: production

deploy_review_job:
  stage: deploy
  variables:
    DEPLOY_SITE: "https://dev.example.com/"
    REVIEW_PATH: "/review"
  script:
    - deploy-review-script --url $DEPLOY_SITE --path $REVIEW_PATH
  environment: production
```

在此示例中：

- `deploy_job` 没有定义变量。默认的 `DEPLOY_SITE` 变量会被复制到该任务中，并可在 `script` 部分中使用。
- `deploy_review_job` 已经定义了 `DEPLOY_SITE` 变量，因此默认的 `DEPLOY_SITE` 不会被复制到该任务中。该任务还定义了一个 `REVIEW_PATH` 任务变量。这两个任务变量都可以在 `script` 部分中使用。

---

<a id="variables-description"></a>

#### `variables:description`

使用 `description` 关键字为默认变量定义描述。该描述会在[手动运行流水线时预填变量名](../pipelines/_index.md#prefill-variables-in-manual-pipelines)时显示。

**关键字类型**：只能将此关键字与默认 `variables` 一起使用，而不能与任务 `variables` 一起使用。

**支持的值**：

- 字符串。可以使用 Markdown。

**`variables:description` 示例**：
```yaml
variables:
  DEPLOY_NOTE:
    description: "部署备注。解释本次部署的原因。"
```

**额外细节**：

- 当未使用 `value` 时，该变量存在于不是手动触发的流水线中，默认值为空字符串（`''`）。

---

<a id="variables-value"></a>

#### 变量值

使用 `value` 关键字来定义流水线级别（默认）变量的值。当与 [`variables: description`](#variablesdescription) 一起使用时，变量值会在[手动运行流水线时预填充](../pipelines/_index.md#prefill-variables-in-manual-pipelines)。

**关键字类型**：此关键字只能与默认 `variables` 一起使用，不能与作业 `variables` 一起使用。

**支持的值**：

- 一个字符串。

**`variables:value` 示例**：

```yaml
variables:
  DEPLOY_ENVIRONMENT:
    value: "staging"
    description: "部署目标。若需要，可将此变量更改为 'canary' 或 'production'。"
```

**额外细节**：

- 如果未与 [`variables: description`](#variablesdescription) 一起使用，其行为与 [`variables`](#variables) 相同。

---

<a id="variables-options"></a>

#### 变量选项

{{< history >}}

- 在极狐GitLab 15.7 引入。

{{< /history >}}

使用 `variables:options` 来定义一个值数组，这些值可在[手动运行流水线时在 UI 中选择](../pipelines/_index.md#configure-a-list-of-selectable-prefilled-variable-values)。

必须与 `variables: value` 一起使用，并且为 `value` 定义的字符串：

- 也必须是 `options` 数组中的字符串之一。
- 是默认选择。

如果没有 [`description`](#variablesdescription)，此关键字无效。

**关键字类型**：此关键字只能与默认 `variables` 一起使用，不能与作业 `variables` 一起使用。

**支持的值**：

- 一个字符串数组。

**`variables:options` 示例**：

```yaml
variables:
  DEPLOY_ENVIRONMENT:
    value: "staging"
    options:
      - "production"
      - "staging"
      - "canary"
    description: "部署目标。默认设置为 'staging'。"
```

---

<a id="variables-expand"></a>

### 变量展开

{{< history >}}

- 在极狐GitLab 15.6 引入，带有一个名为 `ci_raw_variables_in_yaml_config` 的功能标志，默认禁用。
- 在极狐GitLab 15.6 于 JihuLab.com 上启用。
- 在极狐GitLab 15.7 于极狐GitLab 私有化部署上启用。
- 在极狐GitLab 15.8 GA，功能标志 `ci_raw_variables_in_yaml_config` 已移除。

{{< /history >}}

使用 `expand` 关键字来配置变量是否可展开。

**关键字类型**：此关键字可用于默认和作业 `variables`。

**支持的值**：

- `true`（默认）：变量可展开。
- `false`：变量不可展开。

**`variables:expand` 示例**：

```yaml
variables:
  VAR1: value1
  VAR2: value2 $VAR1
  VAR3:
    value: value3 $VAR1
    expand: false
```

- `VAR2` 的结果是 `value2 value1`。
- `VAR3` 的结果是 `value3 $VAR1`。

**额外细节**：

- `expand` 关键字只能与默认和作业 `variables` 关键字一起使用。
  不能与 [`rules:variables`](#rulesvariables) 或 [`workflow:rules:variables`](#workflowrulesvariables) 一起使用。