---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: CI/CD YAML 语法参考
description: 流水线配置关键字、语法、示例和输入。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本文档列出了极狐GitLab `.gitlab-ci.yml` 文件的配置选项。您可以在该文件中定义构成流水线的 CI/CD 作业。

- 如果您已经熟悉[基本的 CI/CD 概念](../_index.md)，可以按照演示[基本](../quick_start/_index.md)
  或[复杂](../quick_start/tutorial.md)流水线的教程，尝试创建
  自己的 `.gitlab-ci.yml` 文件。
- 如需查看示例集合，请参阅 [极狐GitLab CI/CD 示例](../examples/_index.md)。
- 如需查看企业中使用的大型 `.gitlab-ci.yml` 文件，请参阅
  [`gitlab`的 `.gitlab-ci.yml` 文件](https://gitlab.com/gitlab-org/gitlab/-/blob/master/.gitlab-ci.yml)。

在编辑 `.gitlab-ci.yml` 文件时，您可以使用 [CI Lint](lint.md) 工具对其进行校验。

极狐GitLab CI/CD 配置使用 YAML 格式，因此除非另有说明，关键字的顺序并不重要。

使用 [CI/CD 表达式](expressions.md)可获得更动态的流水线配置选项。

<!--
If you are editing content on this page, follow the instructions for documenting keywords:
<https://docs.gitlab.com/development/cicd/cicd_reference_documentation_guide/>
-->

<a id="keywords"></a>

## 关键字

极狐GitLab CI/CD 流水线配置包括：

- 用于配置流水线行为的[全局关键字](#global-keywords)：

  | 关键字                           | 描述 |
  |-----------------------------------|:------------|
  | [`default`](#default)             | 为作业关键字自定义默认值。 |
  | [`include`](#include)             | 从其他 YAML 文件导入配置。 |
  | [`stages`](#stages)               | 流水线阶段的名称和顺序。 |
  | [`variables`](#default-variables) | 为流水线中的所有作业定义默认 CI/CD 变量。 |
  | [`workflow`](#workflow)           | 控制运行哪些类型的流水线。 |

- [头部关键字](#header-keywords)

  | 关键字         | 描述 |
  |-----------------|:------------|
  | [`spec`](#spec) | 为外部配置文件定义规范。 |

- 使用[作业关键字](#job-keywords)配置的[作业](../jobs/_index.md)：

  | 关键字                                       | 描述 |
  |:----------------------------------------------|:------------|
  | [`after_script`](#after_script)               | 覆盖在作业之后执行的一组命令。 |
  | [`allow_failure`](#allow_failure)             | 允许作业失败。失败的作业不会导致流水线失败。 |
  | [`artifacts`](#artifacts)                     | 作业成功时要附加到作业的文件和目录列表。 |
  | [`before_script`](#before_script)             | 覆盖在作业之前执行的一组命令。 |
  | [`cache`](#cache)                             | 应在后续运行之间缓存的文件列表。 |
  | [`coverage`](#coverage)                       | 给定作业的代码覆盖率设置。 |
  | [`dast_configuration`](#dast_configuration)   | 在作业级别使用 DAST 配置文件中的配置。 |
  | [`dependencies`](#dependencies)               | 通过提供要从中获取产物的作业列表，限制将哪些产物传递给特定作业。 |
  | [`environment`](#environment)                 | 作业部署到的环境的名称。 |
  | [`extends`](#extends)                         | 此作业继承的配置条目。 |
  | [`identity`](#identity)                       | 使用身份联合向第三方服务进行身份验证。 |
  | [`image`](#image)                             | 使用 Docker 镜像。 |
  | [`inherit`](#inherit)                         | 选择所有作业继承哪些全局默认值。 |
  | [`interruptible`](#interruptible)             | 定义当作业因更新的运行而变得多余时，是否可以取消该作业。 |
  | [`manual_confirmation`](#manual_confirmation) | 为手动作业定义自定义确认消息。 |
  | [`needs`](#needs)                             | 比阶段顺序更早地执行作业。 |
  | [`pages`](#pages)                             | 上传作业结果以用于 GitLab Pages。 |
  | [`parallel`](#parallel)                       | 应并行运行多少个作业实例。 |
  | [`release`](#release)                         | 指示 runner 生成一个[发布](../../user/project/releases/_index.md)对象。 |
  | [`resource_group`](#resource_group)           | 限制作业并发。 |
  | [`retry`](#retry)                             | 作业失败时可以自动重试的时机和次数。 |
  | [`rules`](#rules)                             | 要评估的条件列表，用于确定作业的选定属性以及是否创建该作业。 |
  | [`script`](#script)                           | 由 runner 执行的 Shell 脚本。 |
  | [`run`](#run)                                 | 由 runner 执行的运行配置。 |
  | [`secrets`](#secrets)                         | 作业所需的 CI/CD 密钥。 |
  | [`services`](#services)                       | 使用 Docker 服务镜像。 |
  | [`stage`](#stage)                             | 定义作业阶段。 |
  | [`start_in`](#start_in)                       | 将作业执行延迟指定的时长。需要 `when: delayed`。 |
  | [`tags`](#tags)                               | 用于选择 runner 的标签列表。 |
  | [`timeout`](#timeout)                         | 定义自定义的作业级超时，其优先级高于项目范围的设置。 |
  | [`trigger`](#trigger)                         | 定义下游流水线触发器。 |
  | [`variables`](#job-variables)                 | 为各个作业定义 CI/CD 变量。 |
  | [`when`](#when)                               | 何时运行作业。 |

- 不再推荐使用的[已弃用关键字](deprecated_keywords.md)。

---

<a id="global-keywords"></a>

## 全局关键字

有些关键字不是在作业中定义的。这些关键字控制流水线行为或导入额外的流水线配置。

---

<a id="default"></a>

### `default`

您可以为某些关键字设置全局默认值。每个默认关键字都会复制到每个尚未定义该关键字的作业中。

默认配置不会与作业配置合并。如果作业已经定义了某个关键字，则作业关键字优先，该关键字的默认配置不会被使用。

**关键字类型**：全局关键字。

**支持的值**：以下关键字可以具有自定义默认值：

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
- `rspec` 作业没有定义 `image` 或 `retry`，因此它使用默认值
  `image: ruby:3.0` 和 `retry: 2`。
- `rspec 2.7` 作业没有定义 `retry`，但它显式定义了 `image`。
  它使用默认的 `retry: 2`，但忽略默认的 `image`，并使用作业中定义的
  `image: ruby:2.7`。

**其他详细信息**：

- 使用 [`inherit:default`](#inheritdefault) 控制作业中默认关键字的继承。
- 全局默认值不会传递给[下游流水线](../pipelines/downstream_pipelines.md)，
  下游流水线独立于触发它的上游流水线运行。

---

<a id="include"></a>

### `include`

使用 `include` 将外部 YAML 文件包含到您的 CI/CD 配置中。您可以将一个很长的 `.gitlab-ci.yml` 文件拆分为多个文件以提高可读性，或减少在多个位置重复相同的配置。

您还可以将模板文件存储在中央代码仓库中，并将它们包含到项目中。

`include` 文件会：

- 与 `.gitlab-ci.yml` 文件中的文件合并。
- 始终先被评估，然后与 `.gitlab-ci.yml` 文件的内容合并，
  无论 `include` 关键字的位置如何。

解析所有文件的时间限制为 30 秒。

**关键字类型**：全局关键字。

**支持的值**：`include` 子键：

- [`include:component`](#includecomponent)
- [`include:local`](#includelocal)
- [`include:project`](#includeproject)
- [`include:remote`](#includeremote)
- [`include:template`](#includetemplate)

以及可选的：

- [`include:inputs`](#includeinputs)
- [`include:rules`](#includerules)
- [`include:integrity`](#includeintegrity)
- [`include:cache`](#includecache)

**其他详细信息**：

- 只有[特定的 CI/CD 变量](includes.md#use-variables-with-include)可以与
  `include` 关键字一起使用。
- 使用合并功能，通过本地配置自定义和覆盖包含的 CI/CD 配置。
- 您可以通过在 `.gitlab-ci.yml` 文件中使用相同的作业名称或全局关键字
  来覆盖包含的配置。这两个配置会合并在一起，并且
  `.gitlab-ci.yml` 文件中的配置优先于包含的配置。
- 如果您重新运行：
  - 作业，则不会再次获取 `include` 文件。流水线中的所有作业都使用
    创建流水线时获取的配置。对源 `include` 文件的任何更改
    都不会影响作业的重新运行。
  - 流水线，则会再次获取 `include` 文件。如果它们在上次
    流水线运行之后发生了更改，则新的流水线会使用更改后的配置。
- 默认情况下，每个流水线最多可以有 150 个 include，包括[嵌套 include](includes.md#use-nested-includes)。此外：
  - 极狐GitLab 私有化部署上的用户可以
    更改[最大 include 数](../../administration/cicd/limits.md#maximum-number-of-includes)值。
  - 在嵌套 include 中，同一个文件可以被多次包含，但重复的 include
    会计入该限制。

---

<a id="includecomponent"></a>

#### `include:component`

使用 `include:component` 将 [CI/CD 组件](../components/_index.md)添加到流水线配置中。

**关键字类型**：全局关键字。

**支持的值**：CI/CD 组件的完整地址，格式为
`<fully-qualified-domain-name>/<project-path>/<component-name>@<specific-version>`。

**`include:component` 示例**：

```yaml
include:
  - component: $CI_SERVER_FQDN/my-org/security-components/secret-detection@1.0
```

**其他详细信息**：

- 如果组件的源项目是私有的，则运行流水线的用户必须至少具有报告者角色。
  对于内部项目，任何经过身份验证的非外部用户都可以访问该组件。
  对于公开项目，无需成员身份。

**相关主题**：

- [使用 CI/CD 组件](../components/_index.md#use-a-component)。

---

<a id="includelocal"></a>

#### `include:local`

使用 `include:local` 包含与包含 `include` 关键字的配置文件位于同一代码仓库和分支中的文件。请使用 `include:local` 而不是符号链接。

**关键字类型**：全局关键字。

**支持的值**：

相对于根目录（`/`）的完整路径：

- YAML 文件必须具有 `.yml` 或 `.yaml` 扩展名。
- 您可以在文件路径中[使用 `*` 和 `**` 通配符](includes.md#use-includelocal-with-wildcard-file-paths)。
- 您可以使用[特定的 CI/CD 变量](includes.md#use-variables-with-include)。

**`include:local` 示例**：

```yaml
include:
  - local: '/templates/.gitlab-ci-template.yml'
```

您还可以使用更简短的语法来定义路径：

```yaml
include: '.gitlab-ci-production.yml'
```

**其他详细信息**：

- `.gitlab-ci.yml` 文件和本地文件必须位于同一分支上。
- 您不能通过 Git 子模块路径包含本地文件。
- `include` 配置始终基于包含 `include` 关键字的文件的位置进行评估，
  而不是基于运行流水线的项目。如果
  [嵌套 `include`](includes.md#use-nested-includes) 位于另一个项目的配置文件中，
  则 `include: local` 会在该其他项目中查找该文件。

---

<a id="includeproject"></a>

#### `include:project`

要包含同一极狐GitLab 实例上另一个私有项目中的文件，请使用 `include:project` 和 `include:file`。

**关键字类型**：全局关键字。

**支持的值**：

- `include:project`：完整的极狐GitLab 项目路径。
- `include:file` 相对于根目录（`/`）的完整文件路径或文件路径数组。
  YAML 文件必须具有 `.yml` 或 `.yaml` 扩展名。
- `include:ref`：可选。要从中获取文件的 ref。未指定时默认为项目的 `HEAD`。
  可以是分支名称、标签名称或提交 SHA。为避免同名
  分支和标签之间的歧义，请使用完全限定的 ref，例如 `refs/heads/<branch>`
  或 `refs/tags/<tag>`。
- 您可以使用[特定的 CI/CD 变量](includes.md#use-variables-with-include)。

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

您还可以指定 `ref`：

```yaml
include:
  - project: 'my-group/my-project'
    ref: refs/heads/main                           # Git branch, fully qualified
    file: '/templates/.gitlab-ci-template.yml'
  - project: 'my-group/my-project'
    ref: refs/tags/v1.0.0                          # Git tag, fully qualified
    file: '/templates/.gitlab-ci-template.yml'
  - project: 'my-group/my-project'
    ref: main                                      # Git branch or tag, short form
    file: '/templates/.gitlab-ci-template.yml'
  - project: 'my-group/my-project'
    ref: 787123b47f14b552955ca2786bc9542ae66fee5b  # Git SHA
    file: '/templates/.gitlab-ci-template.yml'
```

**其他详细信息**：

- `include` 配置始终基于包含 `include` 关键字的文件的位置进行评估，
  而不是基于运行流水线的项目。如果
  [嵌套 `include`](includes.md#use-nested-includes) 位于另一个项目的配置文件中，
  则 `include: local` 会在该其他项目中查找该文件。
- 当流水线启动时，会评估通过所有方法包含的 `.gitlab-ci.yml` 文件配置。
  该配置是某一时刻的快照，并会持久保存在数据库中。极狐GitLab 不会反映对
  所引用的 `.gitlab-ci.yml` 文件配置的任何更改，直到下一个流水线启动。
- 对于 `include:project`中的任何私有项目，运行流水线的用户必须至少具有报告者角色。
  对于内部项目，任何经过身份验证的非外部用户都可以访问所包含的文件。
  对于公开项目，无需成员身份。
  如果用户对所包含的项目没有足够的权限，则会显示 `not found or access denied` 错误。
- 包含另一个项目的 CI/CD 配置文件时要小心。CI/CD 配置文件更改时不会触发任何流水线或通知。
  从安全角度来看，这类似于拉取第三方依赖项。对于 `ref`，请考虑：
  - 使用特定的 SHA 哈希，这应该是最稳定的选项。使用
    完整的 40 字符 SHA 哈希以确保引用所需的提交，因为
    为 `ref` 使用短 SHA 哈希可能会产生歧义。
  - 使用完全限定的 ref，例如 `refs/heads/<branch>` 或 `refs/tags/<tag>`，而不是
    像 `main` 这样的短名称。短名称可能同时匹配分支和标签。如果两者都存在，
    则会从标签中获取文件，即使您本意是从同名的
    受保护分支中包含该文件。
  - 对另一个项目中的 `ref` 同时应用[受保护分支](../../user/project/repository/branches/protected.md)和[受保护标签](../../user/project/protected_tags.md#prevent-tag-creation-with-branch-names)规则。
    受保护标签和分支在更改之前更有可能经过变更管理流程。

---

<a id="includeremote"></a>

#### `include:remote`

使用 `include:remote` 和完整 URL 来包含来自不同位置的文件。

**关键字类型**：全局关键字。

**支持的值**：

可通过 HTTP/HTTPS `GET` 请求访问的公开 URL：

- 不支持使用远程 URL 进行身份验证。
- YAML 文件必须具有 `.yml` 或 `.yaml` 扩展名。
- 您可以使用[特定的 CI/CD 变量](includes.md#use-variables-with-include)。

**`include:remote` 示例**：

```yaml
include:
  - remote: 'https://gitlab.com/example-project/-/raw/main/.gitlab-ci.yml'
```

**其他详细信息**：

- 所有[嵌套 include](includes.md#use-nested-includes) 都以公开用户身份在无上下文的情况下执行，
  因此您只能包含公开项目或模板。嵌套 include 的 `include` 部分中没有可用的变量。
- 包含另一个项目的 CI/CD 配置文件时要小心。当另一个项目的文件发生更改时，
  不会触发任何流水线或通知。从安全角度来看，这类似于
  拉取第三方依赖项。要验证所包含文件的完整性，请考虑使用 [`integrity`](#includeintegrity) 关键字。
  如果您链接到您拥有的另一个极狐GitLab 项目，请考虑同时使用
  [受保护分支](../../user/project/repository/branches/protected.md)和[受保护标签](../../user/project/protected_tags.md#prevent-tag-creation-with-branch-names)
  来强制执行变更管理规则。

---

<a id="includetemplate"></a>

#### `include:template`

使用 `include:template` 包含 [`.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/tree/master/lib/gitlab/ci/templates)。

**关键字类型**：全局关键字。

**支持的值**：

- CI/CD 模板的文件名，例如 `Auto-DevOps.gitlab-ci.yml`。
- 您可以使用[特定的 CI/CD 变量](includes.md#use-variables-with-include)。

**`include:template` 示例**：

```yaml
# File sourced from the GitLab template collection
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

- 所有模板都可以在 [`lib/gitlab/ci/templates`](https://gitlab.com/gitlab-org/gitlab/-/tree/master/lib/gitlab/ci/templates)中查看。
  并非所有模板都设计为与 `include:template` 一起使用，因此在使用某个模板之前
  请先查看模板注释。
- 所有[嵌套 include](includes.md#use-nested-includes) 都以公开用户身份在无上下文的情况下执行，
  因此您只能包含公开项目或模板。嵌套 include 的 `include` 部分中没有可用的变量。

---

<a id="includeinputs"></a>

#### `include:inputs`

当所包含的配置使用 [`spec:inputs`](#specinputs) 并添加到流水线时，使用 `include:inputs` 设置输入参数的值。

**关键字类型**：全局关键字。

**支持的值**：字符串、数值或布尔值。

**`include:inputs` 示例**：

```yaml
include:
  - local: 'custom_configuration.yml'
    inputs:
      website: "My website"
```

在此示例中：

- `custom_configuration.yml`中包含的配置被添加到流水线，
  其中 `website` 输入被设置为值 `My website`，用于所包含的配置。

**其他详细信息**：

- 如果所包含的配置文件使用 [`spec:inputs:type`](#specinputstype)，
  则输入值必须与定义的类型匹配。
- 如果所包含的配置文件使用 [`spec:inputs:options`](#specinputsoptions)，
  则输入值必须与所列选项之一匹配。

**相关主题**：

- [使用 `include` 时设置输入值](../inputs/_index.md#for-configuration-added-with-include)。

---

<a id="includerules"></a>

#### `include:rules`

您可以将 [`rules`](#rules) 与 `include` 一起使用，以有条件地包含其他配置文件。

**关键字类型**：全局关键字。

**支持的值**：以下 `rules` 子键：

- [`rules:if`](#rulesif)。
- [`rules:exists`](#rulesexists)。
- [`rules:changes`](#ruleschanges)。

[支持某些 CI/CD 变量](includes.md#use-variables-with-include)。

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

- `true`，则 `build_jobs.yml` 配置会包含在流水线中。
- 不为 `true` 或不存在，则 `build_jobs.yml` 配置不会包含在流水线中。

**相关主题**：

- 将 `include` 与以下内容一起使用的示例：
  - [`rules:if`](includes.md#include-with-rulesif)。
  - [`rules:changes`](includes.md#include-with-ruleschanges)。
  - [`rules:exists`](includes.md#include-with-rulesexists)。

---

<a id="includeintegrity"></a>

#### `include:integrity`

将 `integrity` 与 `include:remote` 一起使用，以指定所包含远程文件的 SHA256 哈希。如果 `integrity` 与实际内容不匹配，则不会处理该远程文件，并且流水线会失败。

**关键字类型**：全局关键字。

**支持的值**：所包含内容的 Base64 编码 SHA256 哈希。

**`include:integrity` 示例**：

```yaml
include:
  - remote: 'https://gitlab.com/example-project/-/raw/main/.gitlab-ci.yml'
    integrity: 'sha256-L3/GAoKaw0Arw6hDCKeKQlV1QPEgHYxGBHsH4zG1IY8='
```

---

<a id="includecache"></a>

#### `include:cache`

将 `cache` 与 `include:remote` 一起使用，以缓存获取的远程文件内容并减少 HTTP 请求。启用后，远程文件会在指定的生存时间（TTL）内被缓存。此缓存可提高复用相同远程 include 的配置的流水线性能。

在设置缓存时长时，请考虑性能与新鲜度之间的权衡。较长的缓存时长可提高性能，但如果远程文件频繁更改，可能会使用过时的内容。

未定义 `cache` 时，每次都会获取远程文件。

**关键字类型**：全局关键字。

**支持的值**：

- `true`：启用缓存，默认生存时间（TTL）为 1 小时。
- 时长（字符串）：有效的 TTL 时长字符串使用时间单位，
  例如 `minutes`、`hours` 或 `days`（最小 `1 minute`）。

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
- 远程文件被缓存后，即使远程文件内容发生更改，
  也会继续使用缓存版本，直到 TTL 过期。
- 如果您将 [`integrity`](#includeintegrity) 与 `cache` 一起使用，则每次流水线运行时
  都会执行完整性检查，即使使用的是缓存内容。

---

<a id="stages"></a>

### `stages`

使用 `stages` 定义包含作业组的阶段。在作业中使用 [`stage`](#stage) 将作业配置为在特定阶段运行。

如果 `.gitlab-ci.yml` 文件中未定义 `stages`，则默认的流水线阶段为：

- [`.pre`](#stage-pre)
- `build`
- `test`
- `deploy`
- [`.post`](#stage-post)

`stages`中各项的顺序定义了作业的执行顺序：

- 同一阶段中的作业并行运行。
- 下一阶段中的作业在上一阶段的作业成功完成后运行。

如果流水线仅包含 `.pre` 或 `.post` 阶段中的作业，则它不会运行。在不同阶段中必须至少有一个其他作业。

**关键字类型**：全局关键字。

**`stages` 示例**：

```yaml
stages:
  - build
  - test
  - deploy
```

在此示例中：

1. `build`中的所有作业并行执行。
1. 如果 `build`中的所有作业都成功，则 `test` 作业并行执行。
1. 如果 `test`中的所有作业都成功，则 `deploy` 作业并行执行。
1. 如果 `deploy`中的所有作业都成功，则流水线被标记为 `passed`。

如果任何作业失败，则流水线被标记为 `failed`，并且后续阶段中的作业不会启动。当前阶段中的作业不会停止，会继续运行。

**其他详细信息**：

- 如果作业未指定 [`stage`](#stage)，则该作业会被分配 `test` 阶段。
- 如果定义了某个阶段但没有作业使用它，则该阶段在流水线中不可见，
  这有助于[合规流水线配置](../../user/compliance/compliance_pipelines.md)：
  - 可以在合规配置中定义阶段，但如果未使用则保持隐藏。
  - 当开发人员在作业定义中使用这些已定义的阶段时，它们会变为可见。

**相关主题**：

- 要使作业更早启动并忽略阶段顺序，请使用 [`needs`](#needs) 关键字。

---

<a id="workflow"></a>

### `workflow`

使用 [`workflow`](workflow.md) 控制流水线行为。

您可以在 `workflow` 配置中使用一些[预定义的 CI/CD 变量](../variables/predefined_variables.md)，但不能使用仅在作业启动时才定义的变量。

**相关主题**：

- [`workflow: rules` 示例](workflow.md#workflow-rules-examples)
- [在分支流水线和合并请求流水线之间切换](workflow.md#switch-between-branch-pipelines-and-merge-request-pipelines)

---

<a id="workflowauto_cancelon_new_commit"></a>

#### `workflow:auto_cancel:on_new_commit`

使用 `workflow:auto_cancel:on_new_commit` 配置[自动取消冗余流水线](../pipelines/settings.md#auto-cancel-redundant-pipelines)功能的行为。

**支持的值**：

- `conservative`：取消流水线，但仅当尚未启动任何具有 `interruptible: false`的作业时。未定义时的默认值。
- `interruptible`：仅取消具有 `interruptible: true`的作业。
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
  interruptible: false  # Default when not defined.
  script: sleep 60
```

在此示例中：

- 当新提交被推送到分支时，极狐GitLab 会创建一个新的流水线，并且 `job1` 和 `job2` 启动。
- 如果在作业完成之前有新提交被推送到该分支，则仅取消 `job1`。

---

<a id="workflowauto_cancelon_job_failure"></a>

#### `workflow:auto_cancel:on_job_failure`

使用 `workflow:auto_cancel:on_job_failure` 配置当一个作业失败时应立即取消哪些作业。

**支持的值**：

- `all`：一旦某个作业失败，就取消流水线和所有正在运行的作业。
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

在此示例中，如果 `job2` 失败，则 `job1` 如果仍在运行则会被取消，并且 `job3` 不会启动。

**相关主题**：

- [从下游流水线自动取消父流水线](../pipelines/downstream_pipelines.md#auto-cancel-the-parent-pipeline-from-a-downstream-pipeline)

---

<a id="workflowname"></a>

#### `workflow:name`

您可以在 `workflow:` 中使用 `name` 为流水线定义名称。

所有流水线都会被分配所定义的名称。名称中的任何前导或尾随空格都会被移除。

**支持的值**：

- 字符串。
- [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。
- 两者的组合。

**`workflow:name` 示例**：

使用预定义变量的流水线名称：

```yaml
workflow:
  name: 'Pipeline for branch: $CI_COMMIT_BRANCH'
```

根据流水线条件使用不同流水线名称的配置：

```yaml
variables:
  PROJECT1_PIPELINE_NAME: 'Default pipeline name'  # A default is not required

workflow:
  name: '$PROJECT1_PIPELINE_NAME'
  rules:
    - if: '$CI_MERGE_REQUEST_LABELS =~ /pipeline:run-in-ruby3/'
      variables:
        PROJECT1_PIPELINE_NAME: 'Ruby 3 pipeline'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      variables:
        PROJECT1_PIPELINE_NAME: 'MR pipeline: $CI_MERGE_REQUEST_SOURCE_BRANCH_NAME'
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH  # For default branch pipelines, use the default name
```

**其他详细信息**：

- 如果名称为空字符串，则不会为流水线分配名称。仅由 CI/CD 变量组成的名称
  如果所有变量也都为空，则可能求值为空字符串。
- `workflow:rules:variables` 会成为所有作业中可用的[默认变量](#default-variables)，
  包括 [`trigger`](#trigger) 作业，这些作业默认会将变量转发到下游流水线。
  如果下游流水线使用相同的变量，则该[变量会被上游变量值覆盖](../variables/_index.md#cicd-variable-precedence)。
  请确保执行以下任一操作：
  - 在每个项目的流水线配置中使用唯一的变量名称，例如 `PROJECT1_PIPELINE_NAME`。
  - 在触发作业中使用 [`inherit:variables`](#inheritvariables)，并列出
    您想要转发到下游流水线的确切变量。

---

<a id="workflowrules"></a>

#### `workflow:rules`

`workflow`中的 `rules` 关键字类似于[在作业中定义的 `rules`](#rules)，但它控制是否创建整个流水线。

当没有任何规则求值为 true 时，流水线不会运行。

**支持的值**：您可以使用一些与作业级 [`rules`](#rules) 相同的关键字：

- [`rules: if`](#rulesif)。
- [`rules: changes`](#ruleschanges)。
- [`rules: exists`](#rulesexists)。
- [`when`](#when)，与 `workflow` 一起使用时只能为 `always` 或 `never`。
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

在此示例中，如果提交标题（提交消息的第一行）不以 `-draft` 结尾，并且流水线针对以下任一情况，则流水线会运行：

- 合并请求
- 默认分支。

**其他详细信息**：

- 如果您的规则同时匹配分支流水线（默认分支除外）和合并请求流水线，
  则可能会出现[重复流水线](../jobs/job_rules.md#avoid-duplicate-pipelines)。
- `start_in`、`allow_failure` 和 `needs` 在 `workflow:rules`中不受支持，
  但不会导致语法违规。尽管它们没有效果，也不要
  在 `workflow:rules`中使用它们，因为这可能会在将来导致语法失败。有关更多详细信息，请参阅
  [议题 436473](https://gitlab.com/gitlab-org/gitlab/-/issues/436473)。

**相关主题**：

- [`workflow:rules`的常见 `if` 子句](workflow.md#common-if-clauses-for-workflowrules)。
- [使用 `rules` 运行合并请求流水线](../pipelines/merge_request_pipelines.md#configure-merge-request-pipelines)。

---

<a id="workflowrulesvariables"></a>

#### `workflow:rules:variables`

您可以在 `workflow:rules`中使用 [`variables`](#variables) 为特定流水线条件定义变量。

当条件匹配时，会创建该变量，并且流水线中的所有作业都可以使用它。如果该变量已在顶层定义为默认变量，则 `workflow` 变量优先，并覆盖该默认变量。

**关键字类型**：全局关键字。

**支持的值**：变量名称和值对：

- 名称只能使用数字、字母和下划线（`_`）。
- 值必须是字符串。

**`workflow:rules:variables` 示例**：

```yaml
variables:
  DEPLOY_VARIABLE: "default-deploy"

workflow:
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      variables:
        DEPLOY_VARIABLE: "deploy-production"  # Override globally-defined DEPLOY_VARIABLE
    - if: $CI_COMMIT_BRANCH =~ /feature/
      variables:
        IS_A_FEATURE: "true"                  # Define a new variable.
    - if: $CI_COMMIT_BRANCH                   # Run the pipeline in other cases

job1:
  variables:
    DEPLOY_VARIABLE: "job1-default-deploy"
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      variables:                                   # Override DEPLOY_VARIABLE defined
        DEPLOY_VARIABLE: "job1-deploy-production"  # at the job level.
    - when: on_success                             # Run the job in other cases
  script:
    - echo "Run script with $DEPLOY_VARIABLE as an argument"
    - echo "Run another script if $IS_A_FEATURE exists"

job2:
  script:
    - echo "Run script with $DEPLOY_VARIABLE as an argument"
    - echo "Run another script if $IS_A_FEATURE exists"
```

当分支为默认分支时：

- job1 的 `DEPLOY_VARIABLE` 为 `job1-deploy-production`。
- job2 的 `DEPLOY_VARIABLE` 为 `deploy-production`。

当分支为 `feature` 时：

- job1 的 `DEPLOY_VARIABLE` 为 `job1-default-deploy`，并且 `IS_A_FEATURE` 为 `true`。
- job2 的 `DEPLOY_VARIABLE` 为 `default-deploy`，并且 `IS_A_FEATURE` 为 `true`。

当分支为其他内容时：

- job1 的 `DEPLOY_VARIABLE` 为 `job1-default-deploy`。
- job2 的 `DEPLOY_VARIABLE` 为 `default-deploy`。

**其他详细信息**：

- `workflow:rules:variables` 会成为所有作业中可用的[默认变量](#variables)，
  包括 [`trigger`](#trigger) 作业，这些作业默认会将变量转发到下游流水线。
  如果下游流水线使用相同的变量，则该[变量会被上游变量值覆盖](../variables/_index.md#cicd-variable-precedence)。
  请确保执行以下任一操作：
  - 在每个项目的流水线配置中使用唯一的变量名称，例如 `PROJECT1_VARIABLE_NAME`。
  - 在触发作业中使用 [`inherit:variables`](#inheritvariables)，并列出
    您想要转发到下游流水线的确切变量。

---

<a id="workflowrulesauto_cancel"></a>

#### `workflow:rules:auto_cancel`

使用 `workflow:rules:auto_cancel` 配置 [`workflow:auto_cancel:on_new_commit`](#workflowauto_cancelon_new_commit) 或 [`workflow:auto_cancel:on_job_failure`](#workflowauto_cancelon_job_failure) 功能的行为。

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
    - when: always                  # Run the pipeline in other cases

test-job1:
  script: sleep 10
  interruptible: false

test-job2:
  script: sleep 10
  interruptible: true
```

在此示例中，默认情况下，所有作业的 [`workflow:auto_cancel:on_new_commit`](#workflowauto_cancelon_new_commit) 被设置为 `interruptible`，[`workflow:auto_cancel:on_job_failure`](#workflowauto_cancelon_job_failure) 被设置为 `all`。但如果流水线针对受保护分支运行，则该规则会用 `on_new_commit: none` 和 `on_job_failure: none` 覆盖默认值。例如，如果流水线针对以下情况运行：

- 非受保护分支，并且推送了新提交，则 `test-job1` 继续运行，而 `test-job2` 被取消。
- 受保护分支，并且推送了新提交，则 `test-job1` 和 `test-job2` 都继续运行。

---

<a id="header-keywords"></a>

## 头部关键字

有些关键字必须在 YAML 配置文件的头部部分中定义。头部必须位于文件的顶部，并通过 `---` 与配置的其余部分分隔开。

---

<a id="spec"></a>

### `spec`

在 YAML 文件的头部添加 `spec` 部分，以控制包含该文件的流水线的行为。

规范必须在配置文件的顶部声明，位于通过 `---` 与配置的其余部分分隔开的头部部分中。

---

<a id="specinputs"></a>

#### `spec:inputs`

您可以使用 `spec:inputs` 为 CI/CD 配置定义[输入](../inputs/_index.md)。

使用插值格式 `$[[ inputs.input-id ]]` 引用头部部分之外的值。输入会在流水线创建期间获取配置时被求值和插值。使用 `inputs` 时，插值会在配置与 `.gitlab-ci.yml` 文件的内容合并之前完成。

**关键字类型**：头部关键字。`spec` 必须在配置文件的顶部声明，位于头部部分中。

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

**其他详细信息**：

- 除非您使用 [`spec:inputs:default`](#specinputsdefault)
  设置默认值，否则输入是必填的。除非您只将输入与
  [`include:inputs`](#includeinputs) 一起使用，否则请避免使用必填输入。
- 除非您使用 [`spec:inputs:type`](#specinputstype) 设置
  不同的输入类型，否则输入应为字符串。
- 包含插值块的字符串不得超过 1 MB。
- 插值块内的字符串不得超过 1 KB。
- 您可以[在运行新流水线时](../inputs/_index.md#for-a-pipeline)定义输入值。

**相关主题**：

- [使用 `spec:inputs` 定义输入参数](../inputs/_index.md#define-input-parameters-with-specinputs)。

---

<a id="specinputsdefault"></a>

##### `spec:inputs:default`

除非您使用 `spec:inputs:default` 设置默认值，否则输入在被包含时是必填的。

使用 `default: ''` 表示没有默认值。

**关键字类型**：头部关键字。`spec` 必须在配置文件的顶部声明，位于头部部分中。

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
# The pipeline configuration would follow...
```

在此示例中：

- `website` 是必填的，必须定义。
- `user` 是可选的。如果未定义，则值为 `test-user`。
- `flags` 是可选的。如果未定义，则没有值。

**其他详细信息**：

- 当输入出现以下情况时，流水线会因验证错误而失败：
  - 同时使用 `default` 和 [`options`](#specinputsoptions)，但默认值
    不是所列选项之一。
  - 同时使用 `default` 和 `regex`，但默认值与正则表达式不匹配。
  - 值与 [`type`](#specinputstype) 不匹配。

---

<a id="specinputsdescription"></a>

##### `spec:inputs:description`

使用 `description` 为特定输入提供描述。描述不会影响输入的行为，仅用于帮助该文件的用户理解该输入。

**关键字类型**：头部关键字。`spec` 必须在配置文件的顶部声明，位于头部部分中。

**支持的值**：表示描述的字符串。

**`spec:inputs:description` 示例**：

```yaml
spec:
  inputs:
    flags:
      description: 'Sample description of the `flags` input details.'
---
# The pipeline configuration would follow...
```

---

<a id="specinputsoptions"></a>

##### `spec:inputs:options`

输入可以使用 `options` 为输入指定允许值的列表。每个输入最多 50 个选项。

**关键字类型**：头部关键字。`spec` 必须在配置文件的顶部声明，位于头部部分中。

**支持的值**：输入选项的数组。

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
# The pipeline configuration would follow...
```

在此示例中：

- `environment` 是必填的，必须使用列表中的某个值来定义。

**其他详细信息**：

- 在以下情况下，流水线会因验证错误而失败：
  - 输入同时使用 `options` 和 [`default`](#specinputsdefault)，但默认值
    不是所列选项之一。
  - 任何输入选项与 [`type`](#specinputstype) 不匹配，该类型
    可以是 `string` 或 `number`，但在使用 `options` 时不能是 `boolean`。

---

<a id="specinputsregex"></a>

##### `spec:inputs:regex`

使用 `spec:inputs:regex` 指定输入必须匹配的正则表达式。

**关键字类型**：头部关键字。`spec` 必须在配置文件的顶部声明，位于头部部分中。

**支持的值**：必须是正则表达式。

**`spec:inputs:regex` 示例**：

```yaml
spec:
  inputs:
    version:
      regex: ^v\d\.\d+(\.\d+)?$
---
# The pipeline configuration would follow...
```

在此示例中，`v1.0` 或 `v1.2.3`的输入与正则表达式匹配并通过验证。`v1.A.B`的输入与正则表达式不匹配，验证失败。

**其他详细信息**：

- `inputs:regex` 只能与 [`type`](#specinputstype) 为 `string` 一起使用，
  不能与 `number` 或 `boolean` 一起使用。
- 不要用 `/` 字符将正则表达式括起来。例如，使用 `regex.*`，
  而不是 `/regex.*/`。
- `inputs:regex` 使用 [RE2](https://github.com/google/re2/wiki/Syntax) 解析正则表达式。
- 对输入进行正则表达式验证发生在变量展开之前。
  如果输入文本包含变量名称，则验证的是输入的原始值（变量名称），
  而不是变量值。

---

<a id="specinputsrules"></a>

##### `spec:inputs:rules`

使用 `spec:inputs:rules` 根据其他输入的值，为某个输入定义有条件的 `options` 和 `default` 值。

**关键字类型**：头部关键字。`spec` 必须在配置文件的顶部声明，位于头部部分中。

**支持的值**：规则对象的数组。每条规则可以具有：

- `if`：用于检查输入值的条件表达式，使用 [`$[[ inputs.input-id ]]` 语法](../inputs/_index.md#define-input-parameters-with-specinputs)。
- `options`：输入的允许值数组。
- `default`：当此规则匹配时输入的默认值。使用 [`default: null`](../inputs/_index.md#allow-user-entered-values-with-default-null) 允许用户为输入输入自己的值。

**`spec:inputs:rules` 示例**：

```yaml
spec:
  inputs:
    environment:
      options: ['development', 'production']
      default: 'development'

    instance_type:
      description: 'VM instance size'
      rules:
        - if: $[[ inputs.environment ]] == 'development'
          options: ['small', 'medium']
          default: 'small'
        - if: $[[ inputs.environment ]] == 'production'
          options: ['large', 'xlarge']
          default: 'large'
---

deploy:
  script: echo "Deploying $[[ inputs.instance_type ]] instance"
```

在此示例中，当 `environment` 为 `development` 时，用户只能选择 `small` 或 `medium` 实例。当 `environment` 为 `production` 时，只有 `large` 或 `xlarge` 实例可用。

**其他详细信息**：

- 规则按顺序求值。使用第一个具有匹配 `if` 条件的规则。
- 没有 `if` 条件的规则在没有其他规则匹配时充当回退规则。
- 回退规则必须定义至少包含一个值的 `options`。
- 所有具有 `options`的规则还必须定义存在于 `options` 列表中的 `default` 值。
- 对于同一个输入，不能同时使用 `rules` 和顶层 `options` 或 `default`。

**相关主题**：

- [使用 `spec:inputs:rules` 定义条件输入选项](../inputs/_index.md#define-conditional-input-options-with-specinputsrules)。

---

<a id="specinputstype"></a>

##### `spec:inputs:type`

默认情况下，输入应为字符串。使用 `spec:inputs:type` 为输入设置不同的必需类型。

**关键字类型**：头部关键字。`spec` 必须在配置文件的顶部声明，位于头部部分中。

**支持的值**：可以是以下之一：

- `array`，接受输入的[数组](../inputs/_index.md#array-type)。
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
# The pipeline configuration would follow...
```

---

<a id="specinclude"></a>

#### `spec:include`

使用 `spec:include` 包含来自其他文件的外部输入定义。您可以在多个流水线配置之间共享和复用输入定义。

**关键字类型**：头部关键字。`spec` 必须在配置文件的顶部声明，位于头部部分中。

**支持的值**：include 位置的数组。仅支持 `local`、`remote` 和 `project` include。

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
  script: echo "Deploying to $[[ inputs.environment ]]"
```

包含来自不同来源的多个 include：

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
  script: echo "Deploying to $[[ inputs.environment ]]"
```

**其他详细信息**：

- 您不能在 [CI/CD 组件](../components/_index.md#component-spec-section)中使用 `spec:include`。
- 外部输入文件必须只包含 `inputs` 键。其他键会导致验证错误。
- 先合并外部输入，然后应用内联输入。
- 内联输入不能与所包含的输入同名。
- 当您包含多个输入文件时，它们会按指定的顺序合并。
- 支持 [`local`](#includelocal)、[`remote`](#includeremote) 和 [`project`](#includeproject) include 类型。
  不支持 `template`、`component` 或 `artifact` include。
- include 位置基于包含 `spec` 部分的文件的代码仓库和 ref 进行解析，
  而不是基于包含它的文件。
  `local` 位置相对于声明 `spec:include`的文件而言是本地的。
- 您不能在通过 [`include:remote`](#includeremote) 或
  [`include:template`](#includetemplate) 添加的文件中使用 `local` 位置，因为这些文件没有可供解析的代码仓库。
  请改用 [`include:project`](#includeproject)。

**相关主题**：

- [使用来自外部文件的输入](../inputs/_index.md#define-pipeline-inputs-in-external-files)。

---

<a id="speccomponent"></a>

#### `spec:component`

使用 `spec:component` 定义在 [CI/CD 组件](../components/_index.md)中可用于插值的组件上下文数据。

组件上下文提供有关组件本身的元数据，例如其名称、版本和提交 SHA。这允许组件模板动态引用其自身的元数据。

使用插值格式 `$[[ component.field-name ]]` 在组件模板中引用组件上下文值。

**关键字类型**：头部关键字。`spec` 必须在配置文件的顶部声明，位于头部部分中。

**支持的值**：字符串数组。每个字符串必须是以下之一：

- `name`：组件路径中指定的组件名称。
- `sha`：组件的提交 SHA。
- `version`：从目录资源解析出的语义版本。在以下情况下返回 `null`：
  - 该组件不是目录资源。
  - 引用是分支名称或提交 SHA（不是已发布的版本）。
- `reference`：组件路径中 `@` 之后指定的原始引用。
  例如，`1.0`、`~latest`、分支名称或提交 SHA。

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

**其他详细信息**：

- 在使用以下内容时，`version` 字段会解析为实际的语义版本：
  - 完整版本，如 `@1.0.0`（返回 `1.0.0`）
  - 部分版本，如 `@1.0`（返回最新的匹配版本，例如 `1.0.2`）
  - `@~latest`（返回最新版本）
- `reference` 字段始终返回 `@` 之后指定的确切值：
  - `@1.0` 返回 `1.0`（而 `version` 可能返回 `1.0.2`）
  - `@~latest` 返回 `~latest`（而 `version` 返回实际版本号）
  - `@abc123` 返回 `abc123`（而 `version` 返回 `null`）

**相关主题**：

- [在组件中使用组件上下文](../components/_index.md#use-component-context-in-components)。

---

<a id="specdescription"></a>

#### `spec:description`

使用 `spec:description` 提供组件的简短描述。该描述会显示在 CI/CD Catalog 的组件详情页面上，位于输入表格上方。

**关键字类型**：头部关键字。`spec` 必须在配置文件的顶部声明，位于头部部分中。

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

<a id="job-keywords"></a>

## 作业关键字

以下主题说明如何使用关键字配置 CI/CD 流水线。

---

<a id="after_script"></a>

### `after_script`

使用 `after_script` 定义一个命令数组，在作业的 `before_script` 和 `script` 部分完成后最后运行。`after_script` 命令还会在以下情况下运行：

- 作业在 `before_script` 或 `script` 部分仍在运行时被取消。
- 作业以 `script_failure` 失败类型失败，但不包括[其他失败类型](#retrywhen)。

作业配置和默认配置不会合并在一起。如果流水线定义了 [`default:after_script`](#default)，并且该作业也定义了 `after_script`，则作业配置优先，默认配置不会被使用。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：一个数组，包括：

- 单行命令。
- [拆分为多行](script.md#split-long-commands)的长命令。
- [YAML 锚点](yaml_optimization.md#yaml-anchors-for-scripts)。

[支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file) CI/CD 变量。

**`after_script` 示例**：

```yaml
job:
  script:
    - echo "An example script section."
  after_script:
    - echo "Execute this command after the `script` section completes."
```

**其他详细信息**：

您在 `after_script`中指定的脚本会在新的 shell 中执行，与任何 `before_script` 或 `script` 命令分开。因此，它们：

- 会将当前工作目录重置为默认值（根据[定义 runner 如何处理 Git 请求的变量](../runners/configure_runners.md#configure-runner-behavior-with-variables)）。
- 无法访问由 `before_script` 或 `script`中定义的命令所做的更改，
  包括：
  - 在 `script` 脚本中导出的命令别名和变量。
  - 工作树之外的更改（取决于 runner 执行器），例如
    由 `before_script` 或 `script` 脚本安装的软件。
- 具有单独的超时。默认值为 5 分钟，可以通过
  [`RUNNER_AFTER_SCRIPT_TIMEOUT`](../runners/configure_runners.md#set-script-and-after_script-timeouts) 变量进行配置。
- 不会影响作业的退出代码。如果 `script` 部分成功，而
  `after_script` 超时或失败，则作业以代码 `0`（`Job Succeeded`）退出。
- 对于超时的作业：
  - 默认情况下，`after_script` 命令不会执行。
  - 您可以[配置超时值](../runners/configure_runners.md#ensuring-after_script-execution)，通过设置不超过作业超时的适当 `RUNNER_SCRIPT_TIMEOUT` 和 `RUNNER_AFTER_SCRIPT_TIMEOUT` 值，确保 `after_script` 运行。
- 在顶层（而不是在 `default` 部分中）使用 `after_script` 已被[弃用](deprecated_keywords.md#globally-defined-image-services-cache-before_script-after_script)。

**执行时机和文件包含**：

`after_script` 命令在缓存和产物上传操作之前执行。

- 如果您配置了产物收集：
  - 在 `after_script`中创建或修改的文件会包含在产物中。
  - 在 `after_script`中所做的更改会包含在缓存上传中。
- `after_script` 在指定的缓存或产物路径中创建或修改的任何文件都会被捕获并上传。您可以将此时机用于以下场景：
  - 在主脚本之后生成测试报告或覆盖率数据。
  - 创建摘要文件或日志。
  - 对构建输出进行后处理。

在以下示例中，唯一未被包含的文件是在产物或缓存上传阶段之后创建或修改的文件：

```yaml
job:
  script:
    - echo "main" > output.txt
    - build_something

  after_script:
    - echo "modified in after_script" >> output.txt  # This WILL be in the artifact
    - generate_test_report > report.html            # This WILL be in the artifact

  artifacts:
    paths:
      - output.txt
      - report.html

  cache:
    paths:
      - output.txt  # Will include the "modified in after_script" line
```

有关更多信息，请参阅[作业执行流程](../jobs/job_execution.md)。

**相关主题**：

- [将 `after_script` 与 `default` 一起使用](script.md#set-a-default-before_script-or-after_script-for-all-jobs)
  来定义应在所有作业之后运行的默认命令数组。
- 您可以将作业配置为[如果作业被取消则跳过 `after_script` 命令](script.md#skip-after_script-commands-if-a-job-is-canceled)。
- 您可以[忽略非零退出代码](script.md#ignore-non-zero-exit-codes)。
- [在 `after_script`中使用颜色代码](script.md#add-color-codes-to-script-output)
  以使作业日志更易于查看。
- [创建自定义可折叠部分](../jobs/job_logs.md#create-custom-collapsible-sections)
  以简化作业日志输出。
- 您可以[忽略 `after_script`中的错误](../runners/configure_runners.md#ignore-errors-in-after_script)。

---

<a id="allow_failure"></a>

### `allow_failure`

使用 `allow_failure` 确定当作业失败时流水线是否应继续运行。

- 要让流水线继续运行后续作业，请使用 `allow_failure: true`。
- 要阻止流水线运行后续作业，请使用 `allow_failure: false`。

当允许作业失败（`allow_failure: true`）时，橙色警告（{{< icon name="status_warning" >}}）表示作业失败。但是，流水线是成功的，并且关联的提交被标记为已通过，且没有警告。

在以下情况下也会显示相同的警告：

- 该阶段中的所有其他作业都成功。
- 流水线中的所有其他作业都成功。

`allow_failure`的默认值为：

- 对于[手动作业](../jobs/job_control.md#create-a-job-that-must-be-run-manually)为 `true`。
- 对于在 [`rules`](#rules)中使用 `when: manual`的作业为 `false`。
- 在所有其他情况下为 `false`。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

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

- 如果 `job1` 失败，则 `deploy` 阶段中的作业不会启动。
- 如果 `job2` 失败，则 `deploy` 阶段中的作业仍可以启动。

**其他详细信息**：

- 您可以将 `allow_failure` 用作 [`rules`](#rulesallow_failure)的子键。
- 如果设置了 `allow_failure: true`，则该作业始终被视为成功，并且如果此作业失败，具有 [`when: on_failure`](#when)的后续作业不会启动。
- 您可以将 `allow_failure: false` 与手动作业一起使用，以创建[阻塞式手动作业](../jobs/job_control.md#types-of-manual-jobs)。
  被阻塞的流水线不会运行后续阶段中的任何作业，直到该手动作业
  启动并成功完成。

---

<a id="allow_failureexit_codes"></a>

#### `allow_failure:exit_codes`

使用 `allow_failure:exit_codes` 控制何时应允许作业失败。对于所列出的任何退出代码，该作业为 `allow_failure: true`，对于任何其他退出代码，`allow_failure` 为 false。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

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

### `artifacts`

使用 `artifacts` 指定要保存为[作业产物](../jobs/job_artifacts.md)的文件。作业产物是一系列文件和目录，在作业[成功、失败或始终](#artifactswhen)时附加到作业上。

作业完成后，产物会发送到极狐GitLab。如果大小小于[最大产物大小](../../user/jihulab_com/_index.md#gitlab-cicd)，则可以在极狐GitLab UI 中下载。

默认情况下，后续阶段中的作业会自动下载早期阶段中的作业创建的所有产物。您可以使用 [`dependencies`](#dependencies) 控制作业中的产物下载行为。

使用 [`needs`](#needs) 关键字时，作业只能下载 `needs` 配置中定义的作业的产物。

默认情况下，仅为成功的作业收集作业产物，并且产物在[缓存](#cache)之后恢复。

作业配置和默认配置不会合并在一起。如果流水线定义了 [`default:artifacts`](#default)，而作业也定义了 `artifacts`，则作业配置优先，不使用默认配置。

[详细了解产物](../jobs/job_artifacts.md)。

---

<a id="artifactspaths"></a>

#### `artifacts:paths`

路径相对于项目目录（`$CI_PROJECT_DIR`），不能直接链接到其外部。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- 文件路径数组，相对于项目目录。
- 您可以使用 [glob](https://en.wikipedia.org/wiki/Glob_(programming)) 模式和 [`doublestar.Glob`](https://pkg.go.dev/github.com/bmatcuk/doublestar@v1.2.2?tab=doc#Match) 模式通配符。
- 对于 [GitLab Pages 作业](#pages)：
  - 在 [极狐GitLab 17.10 及更高版本](https://gitlab.com/gitlab-org/gitlab/-/issues/428018)中，
    [`pages.publish`](#pagespublish) 路径会自动附加到 `artifacts:paths`，
    因此您无需再次指定。
  - 在 [极狐GitLab 17.10 及更高版本](https://gitlab.com/gitlab-org/gitlab/-/issues/428018)中，
    当未指定 [`pages.publish`](#pagespublish) 路径时，
    `public` 目录会自动附加到 `artifacts:paths`。

支持 CI/CD 变量（[参见说明](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)）。

**`artifacts:paths` 示例**：

```yaml
job:
  artifacts:
    paths:
      - binaries/
      - .config
```

此示例创建一个包含 `.config` 和 `binaries` 目录中所有文件的产物。

**其他详细信息**：

- 如果未与 [`artifacts:name`](#artifactsname) 一起使用，产物文件
  命名为 `artifacts`，下载时变为 `artifacts.zip`。

**相关主题**：

- 要限制特定作业从哪些作业获取产物，请参阅 [`dependencies`](#dependencies)。
- [创建作业产物](../jobs/job_artifacts.md#create-job-artifacts)。

---

<a id="artifactsexclude"></a>

#### `artifacts:exclude`

使用 `artifacts:exclude` 防止文件被添加到产物归档中。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- 文件路径数组，相对于项目目录。
- 您可以使用 [glob](https://en.wikipedia.org/wiki/Glob_(programming)) 或
  [`doublestar.PathMatch`](https://pkg.go.dev/github.com/bmatcuk/doublestar@v1.2.2?tab=doc#PathMatch) 模式通配符。

**`artifacts:exclude` 示例**：

```yaml
artifacts:
  paths:
    - binaries/
  exclude:
    - binaries/**/*.o
```

此示例存储 `binaries/` 中的所有文件，但不包括位于 `binaries/` 子目录中的 `*.o` 文件。

**其他详细信息**：

- `artifacts:exclude` 路径不会递归搜索。
- 与 [`artifacts:untracked`](#artifactsuntracked) 匹配的文件也可以使用
  `artifacts:exclude` 排除。

**相关主题**：

- [从作业产物中排除文件](../jobs/job_artifacts.md#without-excluded-files)。

---

<a id="artifactsexpire_in"></a>

#### `artifacts:expire_in`

使用 `expire_in` 指定[作业产物](../jobs/job_artifacts.md)在过期并被删除之前存储多长时间。`expire_in` 设置不影响：

- 最新作业的产物，除非[为项目](../jobs/job_artifacts.md#keep-artifacts-from-most-recent-successful-jobs)
  或[为整个实例](../../administration/settings/continuous_integration.md#keep-artifacts-from-latest-successful-pipelines)禁用了保留最新作业产物。

产物过期后，默认情况下会每小时（通过 cron 作业）删除，并且不再可访问。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

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

**其他详细信息**：

- 过期时间段从产物上传并存储在极狐GitLab 上时开始。如果未定义过期时间，则默认为[实例范围的设置](../../administration/settings/continuous_integration.md#set-default-artifacts-expiration)。
- 要覆盖过期日期并保护产物不被自动删除：
  - 在作业页面上选择**保持**。
  - 将 `expire_in`的值设置为 `never`。
- 如果过期时间太短，长流水线后续阶段中的作业可能会尝试从早期作业获取
  已过期的产物。如果产物已过期，尝试获取它们的作业会失败，并出现
  [`could not retrieve the needed artifacts` 错误](../jobs/job_artifacts_troubleshooting.md#error-message-this-job-could-not-start-because-it-could-not-retrieve-the-needed-artifacts)。
  将过期时间设置得更长，或在后续作业中使用 [`dependencies`](#dependencies)
  以确保它们不会尝试获取已过期的产物。
- `artifacts:expire_in` 不影响 GitLab Pages 部署。要配置 Pages 部署的过期时间，请使用 [`pages.expire_in`](#pagesexpire_in)。

---

<a id="artifactsexpose_as"></a>

#### `artifacts:expose_as`

使用 `artifacts:expose_as` 关键字[在合并请求 UI 中公开产物](../jobs/job_artifacts.md#link-to-job-artifacts-in-the-merge-request-ui)。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- 在合并请求 UI 中为产物下载链接显示的名称。
  必须与 [`artifacts:paths`](#artifactspaths) 结合使用。

**`artifacts:expose_as` 示例**：

```yaml
test:
  script: ["echo 'test' > file.txt"]
  artifacts:
    expose_as: 'artifact 1'
    paths: ['file.txt']
```

**其他详细信息**：

- 每个作业只能使用一次 `expose_as`，每个合并请求最多 10 个作业。
- 不支持 Glob 模式。
- 产物始终会发送到极狐GitLab。它们会显示在 UI 中，除非 `artifacts:paths` 值：
  - 使用 [CI/CD 变量](../variables/_index.md)。
  - 定义了一个目录，但不以 `/` 结尾。例如，`directory/` 可与 `artifacts:expose_as` 一起使用，
    但 `directory` 不行。
- 如果 `artifacts:paths` 仅包含单个文件，则链接会直接打开该文件。
  在所有其他情况下，链接会打开[产物浏览器](../jobs/job_artifacts.md#download-job-artifacts)。
- 默认情况下会下载链接的文件。
  如果启用了 [GitLab Pages](../../administration/pages/_index.md)，您可以直接在浏览器中预览某些产物文件扩展名。
  有关详细信息，请参阅[浏览产物归档的内容](../jobs/job_artifacts.md#browse-the-contents-of-the-artifacts-archive)。

**相关主题**：

- [在合并请求 UI 中公开作业产物](../jobs/job_artifacts.md#link-to-job-artifacts-in-the-merge-request-ui)。

---

<a id="artifactsname"></a>

#### `artifacts:name`

使用 `artifacts:name` 关键字定义所创建产物归档的名称。您可以为每个归档指定唯一的名称。

如果未定义，默认名称为 `artifacts`，下载时变为 `artifacts.zip`。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- 产物归档的名称。支持 CI/CD 变量（[参见说明](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)）。
  必须与 [`artifacts:paths`](#artifactspaths) 结合使用。

**`artifacts:name` 示例**：

要创建以当前作业命名的归档：

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

<a id="artifactspublic"></a>

#### `artifacts:public`

> [!note]
> `artifacts:public` 现已被 [`artifacts:access`](#artifactsaccess) 取代，后者
> 有更多选项。

使用 `artifacts:public` 控制公共流水线中的作业产物是否可供匿名用户，或访客和报告者角色通过极狐GitLab UI 和 API 下载。

> [!warning]
> 此选项仅影响极狐GitLab UI 和 API 访问。使用作业令牌的 CI/CD 作业
> 仍可通过 runner API 访问产物，无论此设置如何。要限制
> 作业令牌访问，请将项目的 [CI/CD 可见性设置](../../user/project/settings/_index.md#configure-project-features-and-permissions)
> 配置为**仅项目成员**。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- `true`（默认）：公共流水线中作业的产物可供任何人下载，
  包括匿名用户，或访客和报告者角色。
- `false`：作业中的产物仅可供具有开发者、维护者或所有者角色的用户下载。

**`artifacts:public` 示例**：

```yaml
job:
  artifacts:
    public: false
```

---

<a id="artifactsaccess"></a>

#### `artifacts:access`

使用 `artifacts:access` 确定谁可以从极狐GitLab UI 或 API 访问作业产物。此选项不会阻止您将产物转发到下游流水线。

您不能在同一作业中同时使用 [`artifacts:public`](#artifactspublic) 和 `artifacts:access`。

> [!warning]
> 此选项仅影响极狐GitLab UI 和 API 访问。使用作业令牌的 CI/CD 作业
> 仍可通过 runner API 访问产物，无论此设置如何。要限制
> 作业令牌访问，请将项目的 [CI/CD 可见性设置](../../user/project/settings/_index.md#configure-project-features-and-permissions)
> 配置为**仅项目成员**。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- `all`（默认）：公共流水线中作业的产物可供任何人下载，
  包括匿名、访客和报告者用户。
- `developer`：作业中的产物仅可供具有开发者、维护者或所有者角色的用户下载。
- `maintainer`：作业中的产物仅可供具有维护者或所有者角色的用户下载。
- `none`：作业中的产物不可供任何人下载。

**`artifacts:access` 示例**：

```yaml
job:
  artifacts:
    access: 'developer'
```

**其他详细信息**：

- `artifacts:access` 也会影响所有 [`artifacts:reports`](#artifactsreports)，
  因此您也可以限制对[报告产物](artifacts_reports.md)的访问。

---

<a id="artifactsreports"></a>

#### `artifacts:reports`

使用 [`artifacts:reports`](artifacts_reports.md) 收集作业中包含的模板生成的产物。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- 请参阅可用的[产物报告类型](artifacts_reports.md)列表。

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

**其他详细信息**：

- 不支持使用[来自子流水线的产物](#needspipelinejob)在父流水线中合并报告。
  有关详细信息，请参阅[史诗 8205](https://gitlab.com/groups/gitlab-org/-/work_items/8205)。
- 要浏览和下载报告输出文件，请包含 [`artifacts:paths`](#artifactspaths) 关键字。这会两次上传和存储该产物。
- 为 `artifacts: reports` 创建的产物始终会上传，无论作业结果（成功或失败）如何。
  您可以使用 [`artifacts:expire_in`](#artifactsexpire_in) 为产物设置过期
  日期。

---

<a id="artifactsuntracked"></a>

#### `artifacts:untracked`

使用 `artifacts:untracked` 将所有 Git 未跟踪文件添加为产物（连同 `artifacts:paths`中定义的路径）。`artifacts:untracked` 忽略代码仓库 `.gitignore`中的配置，因此 `.gitignore`中匹配的产物也会被包含。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- `true` 或 `false`（如果未定义则为默认值）。

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

<a id="artifactswhen"></a>

#### `artifacts:when`

使用 `artifacts:when` 在作业失败时或尽管失败也上传产物。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- `on_success`（默认）：仅在作业成功时上传产物。
- `on_failure`：仅在作业失败时上传产物。
- `always`：始终上传产物（作业超时时除外）。例如，当
  [上传产物](../testing/unit_test_reports.md#add-screenshots-to-test-reports)
  以排查失败的测试时。

**`artifacts:when` 示例**：

```yaml
job:
  artifacts:
    when: on_failure
```

**其他详细信息**：

- 为 [`artifacts:reports`](#artifactsreports) 创建的产物始终会上传，
  无论作业结果（成功或失败）如何。`artifacts:when` 不会改变此行为。

---

<a id="before_script"></a>

### `before_script`

使用 `before_script` 定义一个命令数组，这些命令应在每个作业的 `script` 命令之前运行，但在[产物](#artifacts)恢复之后运行。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：一个数组，包括：

- 单行命令。
- [拆分为多行](script.md#split-long-commands)的长命令。
- [YAML 锚点](yaml_optimization.md#yaml-anchors-for-scripts)。

支持 CI/CD 变量（[参见说明](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)）。

**`before_script` 示例**：

```yaml
job:
  before_script:
    - echo "Execute this command before any 'script:' commands."
  script:
    - echo "This command executes after the job's 'before_script' commands."
```

**其他详细信息**：

- 您在 `before_script`中指定的脚本会与您在主体
  [`script`](#script)中指定的任何脚本连接。合并后的脚本在单个 shell 中一起执行。
- 在顶层使用 `before_script`，但不在 `default` 部分中使用，[已弃用](deprecated_keywords.md#globally-defined-image-services-cache-before_script-after_script)。

**相关主题**：

- [将 `before_script` 与 `default` 一起使用](script.md#set-a-default-before_script-or-after_script-for-all-jobs)
  来定义应在所有作业的 `script` 命令之前运行的默认命令数组。
  - 作业配置和默认配置不会合并在一起。
    如果流水线定义了 [`default:before_script`](#default)，而作业也定义了 `before_script`，
    则作业配置优先，不使用默认配置。
- 您可以[忽略非零退出码](script.md#ignore-non-zero-exit-codes)。
- [将颜色代码与 `before_script` 一起使用](script.md#add-color-codes-to-script-output)
  使作业日志更易于查看。
- [创建自定义可折叠部分](../jobs/job_logs.md#create-custom-collapsible-sections)
  以简化作业日志输出。

---

<a id="cache"></a>

### `cache`

使用 `cache` 指定要在作业之间缓存的文件和目录列表。您只能使用本地工作副本中的路径。

缓存：

- 在流水线和作业之间共享。
- 默认情况下，不在[受保护](../../user/project/repository/branches/protected.md)和未受保护分支之间共享。
- 在[产物](#artifacts)之前恢复。
- 最多限制为四个[不同的缓存](../caching/_index.md#use-multiple-caches)。

您可以[为特定作业禁用缓存](../caching/_index.md#disable-cache-for-specific-jobs)，例如覆盖：

- 使用 [`default`](#default) 定义的默认缓存。
- 使用 [`include`](#include) 添加的作业的配置。

作业配置和默认配置不会合并在一起。如果流水线定义了 [`default:cache`](#default)，而作业也定义了 `cache`，则作业配置优先，不使用默认配置。

有关缓存的更多信息，请参阅[极狐GitLab CI/CD 中的缓存](../caching/_index.md)。

在顶层使用 `cache`，但不在 `default` 部分中使用，[已弃用](deprecated_keywords.md#globally-defined-image-services-cache-before_script-after_script)。

---

<a id="cachepaths"></a>

#### `cache:paths`

使用 `cache:paths` 关键字选择要缓存的文件或目录。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- 相对于项目目录（`$CI_PROJECT_DIR`）的路径数组。
  您可以使用 [glob](https://en.wikipedia.org/wiki/Glob_(programming)) 和
  [`doublestar.Glob`](https://pkg.go.dev/github.com/bmatcuk/doublestar@v1.2.2?tab=doc#Match) 模式通配符。

支持 [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。

**`cache:paths` 示例**：

缓存 `binaries`中所有以 `.apk` 结尾的文件以及 `.config` 文件：

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

**其他详细信息**：

- `cache:paths` 关键字会包含文件，即使它们是未跟踪的或位于您的 `.gitignore` 文件中。

**相关主题**：

- 有关更多 `cache:paths` 示例，请参阅 [CI/CD 缓存示例](../caching/examples.md)。

---

<a id="cachekey"></a>

#### `cache:key`

使用 `cache:key` 关键字为每个缓存提供唯一的标识键。所有使用相同缓存键的作业使用相同的缓存，包括在不同流水线中。

如果未设置，默认键为 `default`。所有使用 `cache` 关键字但没有 `cache:key`的作业共享 `default` 缓存。

必须与 `cache: paths` 一起使用，否则不会缓存任何内容。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- 一个字符串。
- 一个预定义的 [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。
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

**其他详细信息**：

- 如果您使用 **Windows Batch** 运行 shell 脚本，则必须将
  `$` 替换为 `%`。例如：`key: %CI_COMMIT_REF_SLUG%`
- `cache:key` 值不能包含：
  - `/` 字符，或等效的 URI 编码 `%2F`。
  - 仅由 `.` 字符（任意数量）组成，或等效的 URI 编码 `%2E`。
- 缓存在作业之间共享，因此如果您为不同作业使用不同的
  路径，则还应设置不同的 `cache:key`。
  否则缓存内容可能会被覆盖。

**相关主题**：

- 您可以指定一个[回退缓存键](../caching/_index.md#use-a-fallback-cache-key)，
  以便在找不到指定的 `cache:key` 时使用。
- 您可以在单个作业中[使用多个缓存键](../caching/_index.md#use-multiple-caches)。
- 有关更多 `cache:key` 示例，请参阅 [CI/CD 缓存示例](../caching/examples.md)。

---

<a id="cachekeyfiles"></a>

##### `cache:key:files`

> [!flag]
> 此功能的可用性由功能标志控制。

使用 `cache:key:files` 在指定文件的内容更改时生成新的缓存键。如果内容保持不变，则缓存键在各分支和流水线之间保持一致。您可以重用缓存并减少重建次数，从而加快后续流水线运行速度。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- 最多 10 个文件路径或模式的数组。

不支持 CI/CD 变量。

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

此示例为 Ruby 和 Node.js 依赖项创建缓存。该缓存与 `Gemfile.lock` 和 `package.json` 文件的当前版本相关联。当其中一个文件更改时，会计算新的缓存键并创建新的缓存。任何未来使用相同 `Gemfile.lock` 和 `package.json` 以及 `cache:key:files`的作业运行都会使用新缓存，而不是重建依赖项。

**其他详细信息**：

- 缓存 `key` 是根据所列文件内容计算的 SHA。如果文件不存在，则在键计算中忽略它。
  如果指定的文件都不存在，则回退键为 `default`。
- 可以使用像 `**/package.json` 这样的通配符模式。
- 最多可以指定 10 个文件。

---

<a id="cachekeyfiles_commits"></a>

##### `cache:key:files_commits`

使用 `cache:key:files_commits` 在指定文件的最新提交更改时生成新的缓存键。`cache:key:files_commits` 缓存键会在指定文件有新提交时更改，即使文件内容保持不变。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

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

此示例基于 `package.json` 和 `yarn.lock`的提交历史创建缓存。如果这些文件的提交历史更改，则会计算新的缓存键并创建新的缓存。

**其他详细信息**：

- 缓存 `key` 是根据每个指定文件的最新提交计算的 SHA。
- 如果文件不存在，则在键计算中忽略它。
- 如果指定的文件都不存在，则回退键为 `default`。
- 不能在同一缓存配置中与 [`cache:key:files`](#cachekeyfiles) 一起使用。

---

<a id="cachekeyprefix"></a>

##### `cache:key:prefix`

使用 `cache:key:prefix` 将前缀与为 [`cache:key:files`](#cachekeyfiles) 计算的 SHA 组合。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- 一个字符串。
- 一个预定义的 [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。
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

例如，添加 `$CI_JOB_NAME`的 `prefix` 会使键看起来像 `rspec-feef9576d21ee9b6a32e30c5c79d0a0ceb68d1e5`。如果某个分支更改了 `Gemfile.lock`，则该分支会为 `cache:key:files` 生成新的 SHA 校验和。会生成新的缓存键，并为该键创建新的缓存。如果找不到 `Gemfile.lock`，则会将前缀添加到 `default`，因此示例中的键将是 `rspec-default`。

**其他详细信息**：

- 如果 `cache:key:files`中没有任何文件在任何提交中更改，则会将前缀添加到 `default` 键。

---

<a id="cacheuntracked"></a>

#### `cache:untracked`

使用 `untracked: true` 缓存 Git 代码仓库中所有未跟踪的文件。未跟踪文件包括以下文件：

- 由于 [`.gitignore` 配置](https://git-scm.com/docs/gitignore)而被忽略的文件。
- 已创建但未通过 [`git add`](https://git-scm.com/docs/git-add) 添加到检出中的文件。

如果作业下载以下内容，缓存未跟踪文件可能会创建意外的大型缓存：

- 依赖项，如 gems 或 node modules，它们通常是未跟踪的。
- 来自不同作业的[产物](#artifacts)。从产物中提取的文件默认是未跟踪的。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- `true` 或 `false`（默认）。

**`cache:untracked` 示例**：

```yaml
rspec:
  script: test
  cache:
    untracked: true
```

**其他详细信息**：

- 您可以将 `cache:untracked` 与 `cache:paths` 结合使用，以缓存所有未跟踪文件以及配置路径中的文件。
  使用 `cache:paths` 缓存任何特定文件，包括已跟踪文件或工作目录之外的文件，
  并使用 `cache: untracked` 同时缓存所有未跟踪文件。例如：

  ```yaml
  rspec:
    script: test
    cache:
      untracked: true
      paths:
        - binaries/
  ```

  在此示例中，作业缓存代码仓库中的所有未跟踪文件以及 `binaries/` 中的所有文件。
  如果 `binaries/` 中有未跟踪文件，则它们会被这两个关键字覆盖。

---

<a id="cacheunprotect"></a>

#### `cache:unprotect`

使用 `cache:unprotect` 设置缓存在[受保护](../../user/project/repository/branches/protected.md)和未受保护分支之间共享。

> [!warning]
> 当设置为 `true` 时，无权访问受保护分支的用户可以读取和写入
> 受保护分支使用的缓存键。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

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

<a id="cachewhen"></a>

#### `cache:when`

使用 `cache:when` 根据作业状态定义何时保存缓存。

必须与 `cache: paths` 一起使用，否则不会缓存任何内容。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- `on_success`（默认）：仅在作业成功时保存缓存。
- `on_failure`：仅在作业失败时保存缓存。
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

此示例无论作业失败还是成功都会存储缓存。

---

<a id="cachepolicy"></a>

#### `cache:policy`

要更改缓存的上传和下载行为，请使用 `cache:policy` 关键字。默认情况下，作业在开始时下载缓存，并在作业结束时上传对缓存的更改。此缓存风格是 `pull-push` 策略（默认）。

要将作业设置为仅在作业开始时下载缓存，但在作业结束时从不上传更改，请使用 `cache:policy:pull`。

要将作业设置为仅在作业结束时上传缓存，但在作业开始时从不下载缓存，请使用 `cache:policy:push`。

当您有许多并行执行且使用相同缓存的作业时，请使用 `pull` 策略。此策略可加快作业执行速度并减少缓存服务器上的负载。您可以使用具有 `push` 策略的作业来构建缓存。

必须与 `cache: paths` 一起使用，否则不会缓存任何内容。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

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

- 您可以[使用变量控制作业的缓存策略](../caching/examples.md#use-a-variable-to-control-a-jobs-cache-policy)。

---

<a id="cachefallback_keys"></a>

#### `cache:fallback_keys`

使用 `cache:fallback_keys` 指定一个键列表，以便在 `cache:key` 找不到缓存时尝试从中恢复缓存。缓存按 `fallback_keys` 部分中指定的顺序检索。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- 缓存键数组

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

### `coverage`

使用 `coverage` 和自定义正则表达式配置如何从作业输出中提取代码覆盖率。极狐GitLab 会在合并请求小组件、流水线作业列表和分析图表中显示匹配的百分比。

**支持的值**：

- 一个 RE2 正则表达式。必须以 `/` 开头和结尾。必须匹配覆盖率数字。
  也可以匹配周围的文本，因此您无需使用正则表达式字符组
  来捕获确切的数字。
  由于它使用 RE2 语法，所有组都必须是非捕获组。

**`coverage` 示例**：

```yaml
job1:
  script: rspec
  coverage: '/Code coverage: \d+(?:\.\d+)?/'
```

在此示例中：

1. 极狐GitLab 检查作业日志中是否有与正则表达式匹配的内容。像
   `Code coverage: 67.89% of lines covered` 这样的行会匹配。
1. 然后极狐GitLab 检查匹配的片段是否与 `\d+(?:\.\d+)?` 匹配，以提取
   数字。示例正则表达式匹配 `67.89`。

**其他详细信息**：

- 如果作业输出中有多行匹配，则使用最后一行。
- 如果单行中有多个匹配项，则使用最后一个匹配项。
- 如果匹配的片段中有多个覆盖率数字，则使用第一个数字。
- 移除前导零。
- 不记录来自[子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)的
  覆盖率输出。请参阅[议题 280818](https://gitlab.com/gitlab-org/gitlab/-/issues/280818)。
- 要在合并请求差异中显示逐行差异注释，请单独配置
  [`artifacts:reports:coverage_report`](artifacts_reports.md#artifactsreportscoverage_report)。
  配置其中一个不会启用另一个。

**相关主题**：

- [覆盖率正则表达式模式](../testing/code_coverage/coverage_reporting.md#coverage-regex-patterns)
- [覆盖率可视化](../testing/code_coverage/coverage_visualization.md)

---

<a id="dast_configuration"></a>

### `dast_configuration`

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 `dast_configuration` 关键字指定要在 CI/CD 配置中使用的站点配置文件和扫描器配置文件。这两个配置文件必须首先在项目中创建。作业的阶段必须为 `dast`。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

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

在此示例中，`dast` 作业扩展了使用 `include` 关键字添加的 `dast` 配置，以选择特定的站点配置文件和扫描器配置文件。

**其他详细信息**：

- 站点配置文件或扫描器配置文件中包含的设置优先于
  DAST 模板中包含的设置。

**相关主题**：

- [站点配置文件](../../user/application_security/dast/profiles.md#site-profile)。
- [扫描器配置文件](../../user/application_security/dast/profiles.md#scanner-profile)。

---

<a id="dependencies"></a>

### `dependencies`

使用 `dependencies` 关键字定义要从中获取[产物](#artifacts)的特定作业列表。指定的作业必须都在早期阶段。您也可以将作业设置为完全不下载任何产物。

当作业中未定义 `dependencies` 时，早期阶段中的所有作业都被视为依赖项，该作业会从这些作业获取所有产物。

要从同一阶段中的作业获取产物，必须使用 [`needs:artifacts`](#needsartifacts)。您不应在同一作业中将 `dependencies` 与 `needs` 结合使用。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- 要从中获取产物的作业名称。
- 空数组（`[]`），用于将作业配置为不下载任何产物。

**`dependencies` 示例**：

```yaml
build mac:
  stage: build
  script: make build:mac
  artifacts:
    paths:
      - binaries/

build linux:
  stage: build
  script: make build:linux
  artifacts:
    paths:
      - binaries/

test mac:
  stage: test
  script: make test:mac
  dependencies:
    - build mac

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

在此示例中，两个作业有产物：`build mac` 和 `build linux`。执行 `test mac` 时，会在构建上下文中下载并提取来自 `build mac`的产物。`test linux` 和来自 `build linux`的产物也是如此。

由于[阶段](#stages)优先级，`deploy` 作业会下载所有先前作业的产物。

**其他详细信息**：

- 如果较早的作业不生成产物，或者是未运行的手动作业，
  则依赖作业仍会运行，并且不会生成错误。
- 如果依赖作业的产物[已过期](#artifactsexpire_in)或
  [已删除](../jobs/job_artifacts.md#delete-job-log-and-artifacts)，则该作业会失败。

---

<a id="environment"></a>

### `environment`

使用 `environment` 定义作业部署到的[环境](../environments/_index.md)。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：作业部署到的环境名称，采用以下格式之一：

- 纯文本，包括字母、数字、空格以及以下字符：`-`、`_`、`/`、`$`、`{`、`}`。
- CI/CD 变量，包括预定义变量、项目变量、群组变量、实例变量，或在
  `.gitlab-ci.yml` 文件中定义的变量。您不能使用在 `script` 部分中定义的变量。

**`environment` 示例**：

```yaml
deploy to production:
  stage: deploy
  script: git push production HEAD:main
  environment: production
```

**其他详细信息**：

- 如果您指定了 `environment` 且不存在具有该名称的环境，则会
  创建一个环境。

---

<a id="environmentname"></a>

#### `environment:name`

为[环境](../environments/_index.md)设置名称。

常见环境名称有 `qa`、`staging` 和 `production`，但您可以使用任何名称。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：作业部署到的环境名称，采用以下格式之一：

- 纯文本，包括字母、数字、空格以及以下字符：`-`、`_`、`/`、`$`、`{`、`}`。
- [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)，
  包括预定义变量、项目变量、群组变量、实例变量，或在
  `.gitlab-ci.yml` 文件中定义的变量。您不能使用在 `script` 部分中定义的变量。

**`environment:name` 示例**：

```yaml
deploy to production:
  stage: deploy
  script: git push production HEAD:main
  environment:
    name: production
```

---

<a id="environmenturl"></a>

#### `environment:url`

为[环境](../environments/_index.md)设置 URL。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：单个 URL，采用以下格式之一：

- 纯文本，如 `https://prod.example.com`。
- [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)，
  包括预定义变量、项目变量、群组变量、实例变量，或在
  `.gitlab-ci.yml` 文件中定义的变量。您不能使用在 `script` 部分中定义的变量。

**`environment:url` 示例**：

```yaml
deploy to production:
  stage: deploy
  script: git push production HEAD:main
  environment:
    name: production
    url: https://prod.example.com
```

**其他详细信息**：

- 作业完成后，您可以通过在合并请求、环境或部署页面上选择按钮来访问该 URL。

---

<a id="environmenton_stop"></a>

#### `environment:on_stop`

可以使用在 `environment` 下定义的 `on_stop` 关键字来关闭（停止）环境。它声明一个不同的作业来运行以关闭环境。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**其他详细信息**：

- 有关更多详细信息和示例，请参阅 [`environment:action`](#environmentaction)。

---

<a id="environmentaction"></a>

#### `environment:action`

使用 `action` 关键字指定作业与环境交互的方式。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：以下关键字之一：

| **值** | **描述** |
|:----------|:----------------|
| `start`   | 默认值。表示作业启动环境。部署在作业启动后创建。 |
| `prepare` | 表示作业仅准备环境。它不会触发部署。[详细了解准备环境](../environments/_index.md#access-an-environment-for-preparation-or-verification-purposes)。 |
| `stop`    | 表示作业停止环境。[详细了解停止环境](../environments/_index.md#stopping-an-environment)。 |
| `verify`  | 表示作业仅验证环境。它不会触发部署。[详细了解验证环境](../environments/_index.md#access-an-environment-for-preparation-or-verification-purposes)。 |
| `access`  | 表示作业仅访问环境。它不会触发部署。[详细了解访问环境](../environments/_index.md#access-an-environment-for-preparation-or-verification-purposes)。 |

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

`auto_stop_in` 关键字指定环境的生命周期。当环境过期时，极狐GitLab 会自动停止它。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：用自然语言表示的一段时间。例如，以下都是等效的：

- `168 hours`
- `7 days`
- `one week`
- `never`

支持 CI/CD 变量（[参见说明](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)）。

**`environment:auto_stop_in` 示例**：

```yaml
review_app:
  script: deploy-review-app
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    auto_stop_in: 1 day
```

创建 `review_app`的环境时，环境的生命周期设置为 `1 day`。每次部署 review app 时，该生命周期也会重置为 `1 day`。

`auto_stop_in` 关键字可用于所有[环境操作](#environmentaction)，但 `stop` 除外。某些操作可用于重置环境的计划停止时间。有关详细信息，请参阅[为准备或验证目的访问环境](../environments/_index.md#access-an-environment-for-preparation-or-verification-purposes)。

**相关主题**：

- [环境自动停止文档](../environments/_index.md#stop-an-environment-after-a-certain-time-period)。

---

<a id="environmentkubernetes"></a>

#### `environment:kubernetes`

使用 `kubernetes` 关键字为环境配置 [Kubernetes 仪表板](../environments/kubernetes_dashboard.md)
和 [极狐GitLab 管理的 Kubernetes 资源](../../user/clusters/agent/managed_kubernetes_resources.md)。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- `agent`：一个字符串，指定[极狐GitLab Kubernetes Agent](../../user/clusters/agent/_index.md)。格式为 `path/to/agent/project:agent-name`。如果 agent 连接到运行流水线的项目，请使用 `$CI_PROJECT_PATH:agent-name`。
- `dashboard:namespace`：一个字符串，表示部署环境的 Kubernetes 命名空间。命名空间必须与 `agent` 关键字一起设置。`namespace` [已弃用](deprecated_keywords.md#environmentkubernetesnamespace-and-environmentkubernetesflux_resource_path)。
- `dashboard:flux_resource_path`：一个字符串，表示 Flux 资源的完整路径，例如 `HelmRelease`。Flux 资源必须与
  `agent` 和 `dashboard:namespace` 关键字一起设置。`flux_resource_path` [已弃用](deprecated_keywords.md#environmentkubernetesnamespace-and-environmentkubernetesflux_resource_path)。
- `managed_resources`：一个哈希，带有 `enabled` 关键字，用于为环境配置
  [极狐GitLab 管理的 Kubernetes 资源](../../user/clusters/agent/managed_kubernetes_resources.md)。
  - `managed_resources:enabled`：一个布尔值，表示是否为环境启用 极狐GitLab 管理的 Kubernetes 资源。
- `dashboard`：一个哈希，带有 `dashboard:namespace` 和 `dashboard:flux_resource_path` 关键字，用于为环境配置
  [Kubernetes 仪表板](../environments/kubernetes_dashboard.md)。

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

禁用受管资源时的 **`environment:kubernetes` 示例**：

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

- 将 `deploy` 作业设置为部署到 `production` 环境。
- 将名为 `agent-name`的 [agent](../../user/clusters/agent/_index.md) 与环境关联。
- 为环境配置 [Kubernetes 仪表板](../environments/kubernetes_dashboard.md)，
  命名空间为 `my-namespace`，`flux_resource_path` 设置为
  `helm.toolkit.fluxcd.io/v2/namespaces/flux-system/helmreleases/helm-release-resource`。

**其他详细信息**：

- 要使用仪表板，您必须
  [安装极狐GitLab Kubernetes Agent](../../user/clusters/agent/install/_index.md) 并为
  环境的项目或其父群组
  [配置 `user_access`](../../user/clusters/agent/user_access.md)。
- 运行作业的用户必须有权访问集群 agent。
  否则，仪表板会忽略 `agent`、`namespace` 和 `flux_resource_path` 属性。
- 如果您只想设置 `agent`，则不必设置 `namespace`，也不能设置 `flux_resource_path`。但是，此配置会在 Kubernetes 仪表板中列出集群中的所有命名空间。

---

<a id="environmentdeployment_tier"></a>

#### `environment:deployment_tier`

使用 `deployment_tier` 关键字指定部署环境的层级。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：以下之一：

- `production`
- `staging`
- `testing`
- `development`
- `other`
- [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)，
  包括预定义变量、项目变量、群组变量、实例变量，或在
  `.gitlab-ci.yml` 文件中定义的变量。您不能使用在 `script` 部分中定义的变量。

**`environment:deployment_tier` 示例**：

```yaml
deploy:
  script: echo
  environment:
    name: customer-portal
    deployment_tier: production
```

**其他详细信息**：

- 从此作业定义创建的环境会根据此值分配一个[层级](../environments/_index.md#deployment-tier-of-environments)。
- 如果稍后添加此值，现有环境的层级不会更新。现有环境必须使用 [Environments API](../../api/environments.md#update-an-existing-environment) 更新其层级。

**相关主题**：

- [环境的部署层级](../environments/_index.md#deployment-tier-of-environments)。

---

<a id="dynamic-environments"></a>

#### 动态环境

使用 CI/CD [变量](../variables/_index.md)动态命名环境。

例如：

```yaml
deploy as review app:
  stage: deploy
  script: make deploy
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    url: https://$CI_ENVIRONMENT_SLUG.example.com/
```

`deploy as review app` 作业被标记为部署，以动态创建 `review/$CI_COMMIT_REF_SLUG` 环境。`$CI_COMMIT_REF_SLUG`
是由 runner 设置的 [CI/CD 变量](../variables/_index.md)。
`$CI_ENVIRONMENT_SLUG` 变量基于环境名称，但适合包含在 URL 中。如果 `deploy as review app` 作业在名为 `pow`的分支中运行，则可以通过类似 `https://review-pow.example.com/` 的 URL 访问此环境。

常见用例是为分支创建动态环境并将其
用作 review app。您可以在
<https://gitlab.com/gitlab-examples/review-apps-nginx/> 看到一个使用 review app 的示例。

---

<a id="extends"></a>

### `extends`

使用 `extends` 重用配置部分。它是 [YAML 锚点](yaml_optimization.md#anchors)的替代方案，并且更灵活、更易读。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- 流水线中另一个作业的名称。
- 流水线中其他作业名称的列表（数组）。

**`extends` 示例**：

```yaml
.tests:
  stage: test
  image: ruby:3.0

rspec:
  extends: .tests
  script: rake rspec

rubocop:
  extends: .tests
  script: bundle exec rubocop
```

在此示例中，`rspec` 作业使用 `.tests` 模板作业的配置。创建流水线时，极狐GitLab：

- 基于键执行反向深度合并。
- 将 `.tests` 内容与 `rspec` 作业合并。
- 不合并键的值。

合并后的配置等效于以下作业：

```yaml
rspec:
  stage: test
  image: ruby:3.0
  script: rake rspec

rubocop:
  stage: test
  image: ruby:3.0
  script: bundle exec rubocop
```

**其他详细信息**：

- 您可以为 `extends` 使用多个父项。
- `extends` 关键字支持最多十一层继承，但您应
  避免使用超过三层。
- 在前面的示例中，`.tests` 是一个[隐藏作业](../jobs/_index.md#hide-a-job)，
  但您也可以从常规作业扩展配置。

**相关主题**：

- [使用 `extends` 重用配置部分](yaml_optimization.md#use-extends-to-reuse-configuration-sections)。
- 使用 `extends` 重用[包含的配置文件](yaml_optimization.md#use-extends-and-include-together)中的配置。

---

<a id="hooks"></a>

### `hooks`

使用 `hooks` 指定在作业执行的某些阶段（例如在检索 Git 代码仓库之前）在 runner 上执行的命令列表。

作业配置和默认配置不会合并在一起。如果流水线定义了 [`default:hooks`](#default)，而作业也定义了 `hooks`，则作业配置优先，不使用默认配置。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- 钩子及其命令的哈希。可用的钩子：`pre_get_sources_script`。

---

<a id="hookspre_get_sources_script"></a>

#### `hooks:pre_get_sources_script`

使用 `hooks:pre_get_sources_script` 指定在克隆 Git 代码仓库及任何子模块之前在 runner 上执行的命令列表。例如，您可以使用它来：

- 调整 [Git 配置](../jobs/job_troubleshooting.md#get_sources-job-section-fails-because-of-an-http2-problem)。
- 导出[跟踪变量](../../topics/git/troubleshooting_git.md#debug-git-with-traces)。

**支持的值**：一个数组，包括：

- 单行命令。
- [拆分为多行](script.md#split-long-commands)的长命令。
- [YAML 锚点](yaml_optimization.md#yaml-anchors-for-scripts)。

支持 CI/CD 变量（[参见说明](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)）。

**`hooks:pre_get_sources_script` 示例**：

```yaml
job1:
  hooks:
    pre_get_sources_script:
      - echo 'hello job1 pre_get_sources_script'
  script: echo 'hello job1 script'
```

**相关主题**：

- [极狐GitLab Runner 配置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runners-section)

---

<a id="identity"></a>

### `identity`

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Status: 测试版

{{< /details >}}

此功能处于[测试版](../../policy/development_stages_support.md)。

使用 `identity` 通过身份联合向第三方服务进行身份验证。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：一个标识符。支持的提供商：

- `google_cloud`：Google Cloud。必须使用 [Google Cloud IAM 集成](../../integration/google_cloud_iam.md)进行配置。

**`identity` 示例**：

```yaml
job_with_workload_identity:
  identity: google_cloud
  script:
    - gcloud compute instances list
```

**相关主题**：

- [工作负载身份联合](https://docs.cloud.google.com/iam/docs/workload-identity-federation)。
- [Google Cloud IAM 集成](../../integration/google_cloud_iam.md)。

---

<a id="id_tokens"></a>

### `id_tokens`

使用 `id_tokens` 创建 [ID 令牌](../secrets/id_token_authentication.md)以向第三方服务进行身份验证。以这种方式创建的所有 JWT 都支持 OIDC 身份验证。必需的 `aud` 子关键字用于为 JWT 配置 `aud` 声明。

作业配置和默认配置不会合并在一起。如果流水线定义了 [`default:id_tokens`](#default)，而作业也定义了 `id_tokens`，则作业配置优先，不使用默认配置。

**支持的值**：

- 令牌名称及其 `aud` 声明。`aud` 支持：
  - 单个字符串。
  - 字符串数组。
  - [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。

**`id_tokens` 示例**：

```yaml
job_with_id_tokens:
  id_tokens:
    ID_TOKEN_1:
      aud: https://vault.example.com
    ID_TOKEN_2:
      aud:
        - https://gcp.com
        - https://aws.com
    SIGSTORE_ID_TOKEN:
      aud: sigstore
  script:
    - command_to_authenticate_with_vault $ID_TOKEN_1
    - command_to_authenticate_with_aws $ID_TOKEN_2
    - command_to_authenticate_with_gcp $ID_TOKEN_2
```

**相关主题**：

- [ID 令牌身份验证](../secrets/id_token_authentication.md)。
- [连接到云服务](../cloud_services/_index.md)。
- [使用 Sigstore 进行无密钥签名](signing_examples.md)。

---

<a id="image"></a>

### `image`

使用 `image` 指定作业运行所在的 Docker 镜像。

作业配置和默认配置不会合并在一起。如果流水线定义了 [`default:image`](#default)，而作业也定义了 `image`，则作业配置优先，不使用默认配置。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：镜像名称，如果需要，还包括镜像仓库路径，采用以下格式之一：

- `<image-name>`（与使用带有 `latest` 标签的 `<image-name>` 相同）
- `<image-name>:<tag>`
- `<image-name>@<digest>`

支持 CI/CD 变量（[参见说明](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)）。

**`image` 示例**：

```yaml
default:
  image: ruby:3.0

rspec:
  script: bundle exec rspec

rspec 2.7:
  image: registry.example.com/my-group/my-project/ruby:2.7
  script: bundle exec rspec
```

在此示例中，`ruby:3.0` 镜像是流水线中所有作业的默认镜像。`rspec 2.7` 作业不使用默认值，因为它用作业特定的 `image` 部分覆盖了默认值。

**其他详细信息**：

- 在顶层使用 `image`，但不在 `default` 部分中使用，[已弃用](deprecated_keywords.md#globally-defined-image-services-cache-before_script-after_script)。

**相关主题**：

- [在 Docker 容器中运行 CI/CD 作业](../docker/using_docker_images.md)。

---

<a id="imagename"></a>

#### `image:name`

作业运行所在的 Docker 镜像的名称。类似于单独使用的 [`image`](#image)。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：镜像名称，如果需要，还包括镜像仓库路径，采用以下格式之一：

- `<image-name>`（与使用带有 `latest` 标签的 `<image-name>` 相同）
- `<image-name>:<tag>`
- `<image-name>@<digest>`

支持 CI/CD 变量（[参见说明](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)）。

**`image:name` 示例**：

```yaml
test-job:
  image:
    name: "registry.example.com/my/image:latest"
  script: echo "Hello world"
```

**相关主题**：

- [在 Docker 容器中运行 CI/CD 作业](../docker/using_docker_images.md)。

---

<a id="imageentrypoint"></a>

#### `image:entrypoint`

作为容器入口点执行的命令或脚本。

创建 Docker 容器时，`entrypoint` 会转换为 Docker `--entrypoint` 选项。
语法类似于 [Dockerfile `ENTRYPOINT` 指令](https://docs.docker.com/reference/dockerfile/#entrypoint)，
其中每个 shell 令牌都是数组中的单独字符串。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- 一个字符串。

**`image:entrypoint` 示例**：

```yaml
test-job:
  image:
    name: super/sql:experimental
    entrypoint: [""]
  script: echo "Hello world"
```

**相关主题**：

- [覆盖镜像的入口点](../docker/using_docker_images.md#override-the-entrypoint-of-an-image)。

---

<a id="imagedocker"></a>

#### `image:docker`

使用 `image:docker` 将选项传递给使用 [Docker 执行器](https://gitlab.cn/docs/runner/executors/docker/)
或 [Kubernetes 执行器](https://gitlab.cn/docs/runner/executors/kubernetes/)的 runner。
此关键字不适用于其他执行器类型。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

Docker 执行器的选项哈希，可包括：

- `platform`：选择要拉取的镜像的架构。未指定时，
  默认与主机 runner 相同的平台。
- `user`：指定运行容器时要使用的用户名或 UID。

**`image:docker` 示例**：

```yaml
arm-sql-job:
  script: echo "Run sql tests"
  image:
    name: super/sql:experimental
    docker:
      platform: arm64/v8
      user: dave
```

**其他详细信息**：

- `image:docker:platform` 映射到 [`docker pull --platform` 选项](https://docs.docker.com/reference/cli/docker/image/pull/#options)。
- `image:docker:user` 映射到 [`docker run --user` 选项](https://docs.docker.com/reference/cli/docker/container/run/#options)。
- 使用 Docker 执行器时，要运行针对与
  runner 主机不同架构构建的镜像，主机必须注册有 `binfmt_misc`的模拟支持。
  例如，要[安装 QEMU 模拟器](https://docs.docker.com/build/building/multi-platform/#install-qemu-manually)，
  请在主机上运行 `docker run --privileged --rm tonistiigi/binfmt --install all`。
  如果没有模拟支持，作业会失败并显示 `exec format error` 消息。
  在极狐GitLab Runner 19.1 及更早版本中，与主机不匹配的 `platform` 值可能会
  被静默忽略，容器会改为使用主机架构运行。

---

<a id="imagekubernetes"></a>

#### `image:kubernetes`

使用 `image:kubernetes` 将选项传递给极狐GitLab Runner [Kubernetes 执行器](https://gitlab.cn/docs/runner/executors/kubernetes/)。
此关键字不适用于其他执行器类型。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

Kubernetes 执行器的选项哈希，可包括：

- `user`：指定容器运行时使用的用户名或 UID。您也可以使用 `UID:GID` 格式来设置 GID。

**仅使用 UID 的 `image:kubernetes` 示例**：

```yaml
arm-sql-job:
  script: echo "Run sql tests"
  image:
    name: super/sql:experimental
    kubernetes:
      user: "1001"
```

**同时使用 UID 和 GID 的 `image:kubernetes` 示例**：

```yaml
arm-sql-job:
  script: echo "Run sql tests"
  image:
    name: super/sql:experimental
    kubernetes:
      user: "1001:1001"
```

---

<a id="imagepull_policy"></a>

#### `image:pull_policy`

runner 用于获取 Docker 镜像的拉取策略。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- 单个拉取策略，或数组中的多个拉取策略。
  可以是 `always`、`if-not-present` 或 `never`。

**`image:pull_policy` 示例**：

```yaml
job1:
  script: echo "A single pull policy."
  image:
    name: ruby:3.0
    pull_policy: if-not-present

job2:
  script: echo "Multiple pull policies."
  image:
    name: ruby:3.0
    pull_policy: [always, if-not-present]
```

**其他详细信息**：

- 如果 runner 不支持定义的拉取策略，作业会失败并显示类似以下内容的错误：
  `ERROR: Job failed (system failure): the configured PullPolicies ([always]) are not allowed by AllowedPullPolicies ([never])`。

**相关主题**：

- [在 Docker 容器中运行 CI/CD 作业](../docker/using_docker_images.md)。
- [配置 runner 如何拉取镜像](https://gitlab.cn/docs/runner/executors/docker/#configure-how-runners-pull-images)。
- [设置多个拉取策略](https://gitlab.cn/docs/runner/executors/docker/#set-multiple-pull-policies)。

---

<a id="inputs"></a>

### `inputs`

使用 `inputs` 为作业定义类型化且经过验证的输入。[作业输入](../jobs/job_inputs.md)可以在手动运行或重试作业时覆盖。

作业输入是提供类型安全和验证的参数。与 [CI/CD 变量](../variables/_index.md)不同，在运行或重试作业时只能指定作业中明确定义的输入。所有作业输入名称都必须预定义。

使用 `${{ job.inputs.INPUT_NAME }}` [Moa 表达式](../functions/moa.md)语法引用作业输入值。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

输入名称的哈希，其中每个输入使用一个或多个子键进行配置：

- [`default`](#inputsdefault)（必需）
- [`type`](#inputstype)
- [`options`](#inputsoptions)
- [`description`](#inputsdescription)
- [`regex`](#inputsregex)

**`inputs` 示例**：

```yaml
test_job:
  inputs:
    test_suite:
      default: unit
      description: Which test suite to run
      options: [unit, integration, e2e]
    parallel_count:
      type: number
      default: 5
      description: Number of parallel test runners
    verbose:
      type: boolean
      default: false
      description: Enable verbose test output
  script:
    - 'echo "Running ${{ job.inputs.test_suite }} tests"'
    - 'if [ "${{ job.inputs.verbose }}" == "true" ]; then export TEST_VERBOSE=1; fi'
    - ./run_tests.sh --suite ${{ job.inputs.test_suite }} --parallel ${{ job.inputs.parallel_count }}
```

**其他详细信息**：

- 作业输入在创建作业时以及您尝试使用新输入值重试作业时进行验证。
  如果验证失败，作业不会启动。
- 作业输入的作用域限定在定义它们的作业中，其他作业无法访问。
- 有关支持作业输入的关键字的完整列表，请参阅[可以使用作业输入的位置](../jobs/job_inputs.md#where-you-can-use-job-inputs)。

---

<a id="inputsdefault"></a>

#### `inputs:default`

所有作业输入都必须使用 `default` 定义默认值。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：与输入的 [`type`](#inputstype) 匹配的任何值。

**`inputs:default` 示例**：

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

#### `inputs:type`

使用 `type` 定义输入值的数据类型。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- `string`（默认）
- `number`
- `boolean`
- `array`。

**`inputs:type` 示例**：

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

#### `inputs:description`

使用 `description` 提供有关输入用途的信息。描述不影响输入的行为。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：一个字符串。

**`inputs:description` 示例**：

```yaml
deploy_job:
  inputs:
    environment:
      default: staging
      description: Target deployment environment
```

---

<a id="inputsoptions"></a>

#### `inputs:options`

使用 `options` 指定输入的允许值列表。

输入值必须与列出的选项之一完全匹配（区分大小写）。如果值与选项不匹配，则验证失败。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：允许值的数组。

**`inputs:options` 示例**：

```yaml
deploy_job:
  inputs:
    environment:
      default: staging
      options: [development, staging, production]
```

---

<a id="inputsregex"></a>

#### `inputs:regex`

使用 `regex` 指定输入值必须匹配的正则表达式模式。

如果值与正则表达式不匹配，则验证失败。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：一个正则表达式字符串。

**`inputs:regex` 示例**：

```yaml
deploy_job:
  inputs:
    version:
      default: v1.0.0
      regex: ^v\d+\.\d+\.\d+$
```

在此示例中，输入值 `v1.1.1` 通过正则表达式验证，但输入 `v1.1.1-beta` 不通过。

---

<a id="inherit"></a>

### `inherit`

使用 `inherit` 来[控制默认关键字和变量的继承](../jobs/_index.md#control-the-inheritance-of-default-keywords-and-variables)。

---

<a id="inheritdefault"></a>

#### `inherit:default`

使用 `inherit:default` 来控制[默认关键字](#default)的继承。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- `true`（默认）或 `false`，用于启用或禁用所有默认关键字的继承。
- 要继承的特定默认关键字列表。

**`inherit:default` 示例**：

```yaml
default:
  retry: 2
  image: ruby:3.0
  interruptible: true

job1:
  script: echo "This job does not inherit any default keywords."
  inherit:
    default: false

job2:
  script: echo "This job inherits only the two listed default keywords. It does not inherit 'interruptible'."
  inherit:
    default:
      - retry
      - image
```

**其他详细信息**：

- 您也可以在一行中列出要继承的默认关键字：`default: [keyword1, keyword2]`

---

<a id="inheritvariables"></a>

#### `inherit:variables`

使用 `inherit:variables` 来控制[默认变量](#default-variables)关键字的继承。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- `true`（默认）或 `false`，用于启用或禁用所有默认变量的继承。
- 要继承的特定变量列表。

**`inherit:variables` 示例**：

```yaml
variables:
  VARIABLE1: "This is default variable 1"
  VARIABLE2: "This is default variable 2"
  VARIABLE3: "This is default variable 3"

job1:
  script: echo "This job does not inherit any default variables."
  inherit:
    variables: false

job2:
  script: echo "This job inherits only the two listed default variables. It does not inherit 'VARIABLE3'."
  inherit:
    variables:
      - VARIABLE1
      - VARIABLE2
```

**其他详细信息**：

- 您也可以在一行中列出要继承的默认变量：`variables: [VARIABLE1, VARIABLE2]`

---

<a id="interruptible"></a>

### `interruptible`

使用 `interruptible` 来配置[自动取消多余的流水线](../pipelines/settings.md#auto-cancel-redundant-pipelines)功能。如果同一 ref 上有新提交触发了流水线，该功能会在作业完成前将其取消。如果禁用，该关键字不起作用。

例如，如果您使用**新流水线**为同一提交重新运行流水线，该关键字不起作用。

**自动取消多余的流水线**功能的行为可以通过 [`workflow:auto_cancel:on_new_commit`](#workflowauto_cancelon_new_commit) 设置来控制。

**关键字类型**：作业关键字。只能作为作业的一部分使用，或用在 [`default` 部分](#default)中。

**支持的值**：

- `true` 或 `false`（默认）。

**使用默认行为的 `interruptible` 示例**：

```yaml
workflow:
  auto_cancel:
    on_new_commit: conservative # the default behavior

stages:
  - stage1
  - stage2
  - stage3

step-1:
  stage: stage1
  script:
    - echo "Can be canceled."
  interruptible: true

step-2:
  stage: stage2
  script:
    - echo "Can not be canceled."

step-3:
  stage: stage3
  script:
    - echo "Because step-2 can not be canceled, this step can never be canceled, even though it's set as interruptible."
  interruptible: true
```

在此示例中，新的流水线会导致正在运行的流水线：

- 如果只有 `step-1` 正在运行或处于待处理状态，则被取消。
- 在 `step-2` 开始后，不被取消。

**使用 `auto_cancel:on_new_commit:interruptible` 设置的 `interruptible` 示例**：

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
    - echo "Can be canceled."
  interruptible: true

step-2:
  stage: stage2
  script:
    - echo "Can not be canceled."

step-3:
  stage: stage3
  script:
    - echo "Can be canceled."
  interruptible: true
```

在此示例中，新的流水线会导致正在运行的流水线取消 `step-1` 和 `step-3`（如果它们正在运行或处于待处理状态）。

**其他详细信息**：

- 只有在作业启动后可以安全取消时，才设置 `interruptible: true`，例如构建作业。部署作业通常不应被取消，以防止部分部署。
- 使用默认行为或 `workflow:auto_cancel:on_new_commit: conservative` 时：
  - 尚未启动的作业始终被视为 `interruptible: true`，无论该作业的配置如何。`interruptible` 配置仅在作业启动后才会被考虑。
  - **正在运行**的流水线只有在所有正在运行的作业都配置了 `interruptible: true`，或者任何时候都没有配置了 `interruptible: false`的作业启动过时，才会被取消。一旦配置了 `interruptible: false`的作业启动，整个流水线就不再被视为可中断。
  - 如果流水线触发了下游流水线，但下游流水线中还没有配置了 `interruptible: false`的作业启动，则下游流水线也会被取消。
- 您可以在流水线的第一个阶段中添加一个可选的、带有 `interruptible: false`的手动作业，以允许用户手动阻止流水线被自动取消。用户启动作业后，流水线就无法被**自动取消多余的流水线**功能取消。
- 将 `interruptible` 与[触发作业](#trigger)一起使用时：
  - 被触发的下游流水线永远不会受到触发作业的 `interruptible` 配置的影响。
  - 如果 [`workflow:auto_cancel`](#workflowauto_cancelon_new_commit) 设置为 `conservative`，则触发作业的 `interruptible` 配置不起作用。
  - 如果 [`workflow:auto_cancel`](#workflowauto_cancelon_new_commit) 设置为 `interruptible`，则带有 `interruptible: true`的触发作业可以被自动取消。

---

<a id="needs"></a>

### `needs`

使用 `needs` 来乱序执行作业。使用 `needs`的作业之间的关系可以可视化为[有向无环图](needs.md)。

您可以忽略阶段顺序，运行某些作业而无需等待其他作业完成。多个阶段中的作业可以并发运行。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- 作业数组（最多 50 个作业）。
- 空数组（`[]`），用于将作业设置为在流水线创建后立即启动。

**`needs` 示例**：

```yaml
linux:build:
  stage: build
  script: echo "Building linux..."

mac:build:
  stage: build
  script: echo "Building mac..."

lint:
  stage: test
  needs: []
  script: echo "Linting..."

linux:rspec:
  stage: test
  needs: ["linux:build"]
  script: echo "Running rspec on linux..."

mac:rspec:
  stage: test
  needs: ["mac:build"]
  script: echo "Running rspec on mac..."

production:
  stage: deploy
  script: echo "Running production..."
  environment: production
```

此示例创建了四条执行路径：

- Linter：`lint` 作业立即运行，无需等待 `build` 阶段完成，因为它没有 needs（`needs: []`）。
- Linux 路径：`linux:rspec` 作业在 `linux:build` 作业完成后立即运行，无需等待 `mac:build` 完成。
- macOS 路径：`mac:rspec` 作业在 `mac:build` 作业完成后立即运行，无需等待 `linux:build` 完成。
- `production` 作业在所有先前的作业完成后立即运行：`lint`、`linux:build`、`linux:rspec`、`mac:build`、`mac:rspec`。

**其他详细信息**：

- 单个作业在 `needs` 数组中可包含的作业数量上限：
  - 对于 JihuLab.com，上限为 50。更多信息，请参见[议题 350398](https://gitlab.com/gitlab-org/gitlab/-/issues/350398)。
  - 对于极狐GitLab 私有化部署，默认上限为 50。可以通过[更新管理区域中的 CI/CD 限制](../../administration/cicd/limits.md#maximum-number-of-needs-dependencies)来更改此上限。
- 如果 `needs` 引用的作业使用了 [`parallel`](#parallel) 关键字，则它依赖于并行创建的所有作业，而不仅仅是一个作业。默认情况下，它还会从所有并行作业下载产物。如果产物名称相同，它们会相互覆盖，只保存最后下载的一个。
  - 要让 `needs` 引用并行作业的子集（而不是所有并行作业），请使用 [`needs:parallel:matrix`](#needsparallelmatrix) 关键字。
- 您可以引用与您正在配置的作业处于同一阶段的作业。
- 如果 `needs` 引用的作业可能被 `only`、`except` 或 `rules` 从流水线中排除，则流水线可能无法创建。使用 [`needs:optional`](#needsoptional) 关键字来解决流水线创建失败的问题。
- 如果流水线中有带有 `needs: []` 的作业，以及 [`.pre`](#stage-pre) 阶段中的作业，它们都会在流水线创建后立即启动。带有 `needs: []` 的作业立即启动，`.pre` 阶段中的作业也会立即启动。

---

<a id="needsartifacts"></a>

#### `needs:artifacts`

当作业使用 `needs` 时，默认情况下它不再下载先前阶段的所有产物，因为带有 `needs`的作业可以在更早的阶段完成之前启动。使用 `needs` 时，您只能从 `needs` 配置中列出的作业下载产物。

使用 `artifacts: true`（默认）或 `artifacts: false` 来控制在使用 `needs`的作业中何时下载产物。

**关键字类型**：作业关键字。只能作为作业的一部分使用。必须与 `needs:job` 一起使用。

**支持的值**：

- `true`（默认）或 `false`。

**`needs:artifacts` 示例**：

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

- `test-job1` 作业下载 `build_job1` 产物
- `test-job2` 作业不下载 `build_job2` 产物。
- `test-job3` 作业下载所有三个 `build_jobs`的产物，因为对于所有三个所需作业，`artifacts` 为 `true`，或默认为 `true`。

**其他详细信息**：

- 您不应在同一作业中同时使用 `needs` 和 [`dependencies`](#dependencies)。

---

<a id="needsproject"></a>

#### `needs:project`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 `needs:project` 从其他流水线中最多五个作业下载产物。产物从指定 ref 的最新成功指定作业下载。要指定多个作业，请将每个作业作为单独的数组项添加到 `needs` 关键字下。

如果该 ref 有正在运行的流水线，带有 `needs:project`的作业不会等待该流水线完成。相反，产物会从指定作业的最新成功运行中下载。

`needs:project` 必须与 `job`、`ref` 和 `artifacts` 一起使用。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- `needs:project`：完整的项目路径，包括命名空间和群组。
- `job`：要从中下载产物的作业。
- `ref`：要从中下载产物的 ref。
- `artifacts`：必须为 `true` 才能下载产物。

**`needs:project` 示例**：

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

您可以在 `needs:project`中使用 [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)，例如：

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

**其他详细信息**：

- 要从当前项目中的其他流水线下载产物，请将 `project` 设置为与当前项目相同，但使用与当前流水线不同的 ref。在同一 ref 上运行的并发流水线可能会覆盖产物。
- 运行流水线的用户必须对该群组或项目具有报告者、开发者、维护者或所有者角色，或者该群组/项目必须具有公开可见性。
- 您不能在同一作业中将 `needs:project` 与 [`trigger`](#trigger) 一起使用。
- 使用 `needs:project` 从另一个流水线下载产物时，作业不会等待所需作业完成。[使用 `needs` 等待作业完成](needs.md)仅限于同一流水线中的作业。请确保另一个流水线中的所需作业在需要它的作业尝试下载产物之前完成。
- 您不能从在 [`parallel`](#parallel)中运行的作业下载产物。
- 支持在 `project`、`job` 和 `ref`中使用 [CI/CD 变量](../variables/_index.md)。

**相关主题**：

- 要在[父子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)之间下载产物，请使用 [`needs:pipeline:job`](#needspipelinejob)。

---

<a id="needspipelinejob"></a>

#### `needs:pipeline:job`

[子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)可以从成功完成的作业下载产物。该作业可以位于其父流水线中，也可以位于同一层级中的另一个子流水线中。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- `needs:pipeline`：一个流水线 ID。必须是同一父子流水线层级中存在的流水线。
- `job`：要从中下载产物的作业。
- `optional`：与 [`needs:optional`](#needsoptional) 一起使用，以依赖有时不存在于父流水线中的作业。

**`needs:pipeline:job` 示例**：

- 父流水线（`.gitlab-ci.yml`）：

  ```yaml
  stages:
    - build
    - test

  create-artifact:
    stage: build
    script: echo "sample artifact" > artifact.txt
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

- 子流水线（`child.yml`）：

  ```yaml
  use-artifact:
    script: cat artifact.txt
    needs:
      - pipeline: $PARENT_PIPELINE_ID
        job: create-artifact
  ```

在此示例中，父流水线中的 `create-artifact` 作业创建了一些产物。`child-pipeline` 作业触发了一个子流水线，并将 `CI_PIPELINE_ID` 变量作为新的 `PARENT_PIPELINE_ID` 变量传递给子流水线。子流水线可以在 `needs:pipeline`中使用该变量，从父流水线下载产物。将 `create-artifact` 和 `child-pipeline` 作业依次放在前后相继的阶段中，可确保 `use-artifact` 作业仅在 `create-artifact` 成功完成后才执行。

**其他详细信息**：

- `pipeline` 属性不接受当前流水线 ID（`$CI_PIPELINE_ID`）。要从当前流水线中的作业下载产物，请使用 [`needs:artifacts`](#needsartifacts)。
- 您不能在[触发作业](#trigger)中使用 `needs:pipeline:job`，也不能从[多项目流水线](../pipelines/downstream_pipelines.md#multi-project-pipelines)获取产物。要从多项目流水线获取产物，请使用 [`needs:project`](#needsproject)。
- `needs:pipeline:job`中列出的作业必须以 `success` 状态完成，否则无法获取产物。[议题 367229](https://gitlab.com/gitlab-org/gitlab/-/issues/367229) 提议允许从任何带有产物的作业获取产物。

---

<a id="needsoptional"></a>

#### `needs:optional`

要依赖有时不存在于流水线中的作业，请将 `optional: true` 添加到 `needs` 配置中。如果未定义，`optional: false` 为默认值。您可以将 `optional: true` 与 [`needs:pipeline:job`](#needspipelinejob) 一起使用，以依赖有时不存在于父或另一个子流水线中的作业。

使用 [`rules`](#rules)、[`only` 或 `except`](deprecated_keywords.md#only--except) 并通过 [`include`](#include) 添加的作业可能并不总是被添加到流水线中。极狐GitLab 在启动流水线之前会检查 `needs` 关系：

- 如果 `needs` 条目具有 `optional: true` 且所需作业存在于流水线中，则作业会等待其完成后再启动。
- 如果所需作业不存在，则作业可以在满足所有其他 needs 要求时启动。
- 如果 `needs` 部分仅包含可选作业，且没有作业被添加到流水线中，则作业立即启动（与空的 `needs` 条目相同：`needs: []`）。
- 如果所需作业具有 `optional: false`，但它未被添加到流水线中，则流水线无法启动，并出现类似以下错误：`'job1' job needs 'job2' job, but it was not added to the pipeline`。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**`needs:optional` 示例**：

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
- 当分支为默认分支时，`test-job2` 被添加到流水线中，因此：
  - `deploy-job` 等待 `test-job1` 和 `test-job2` 都完成。
  - `review-job` 等待 `test-job2` 完成。
- 当分支不是默认分支时，`test-job2` 未被添加到流水线中，因此：
  - `deploy-job` 只等待 `test-job1` 完成，而不等待缺失的 `test-job2`。
  - `review-job` 没有其他所需作业，会立即启动（与 `build-job` 同时），就像 `needs: []` 一样。

**其他详细信息**：

- 您不能将 `needs:optional` 与 [`needs:parallel:matrix`](#needsparallelmatrix) 一起使用。

---

<a id="needspipeline"></a>

#### `needs:pipeline`

您可以使用 `needs:pipeline` 关键字将上游流水线的流水线状态镜像到作业。默认分支的最新流水线状态会被复制到该作业。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- 完整的项目路径，包括命名空间和群组。如果项目位于同一群组或命名空间中，您可以从 `project` 关键字中省略它们。例如：`project: group/project-name` 或 `project: project-name`。

**`needs:pipeline` 示例**：

```yaml
upstream_status:
  stage: test
  needs:
    pipeline: other/project
```

**其他详细信息**：

- 如果您将 `job` 关键字添加到 `needs:pipeline`，作业将不再镜像流水线状态。行为会变为 [`needs:pipeline:job`](#needspipelinejob)。

---

<a id="needsparallelmatrix"></a>

#### `needs:parallel:matrix`

作业可以使用 [`parallel:matrix`](#parallelmatrix) 在单个流水线中并行多次运行一个作业。作业的每个实例使用不同的变量值。

使用 `needs:parallel:matrix` 根据并行作业乱序执行作业。

**关键字类型**：作业关键字。只能作为作业的一部分使用。必须与 `needs:job` 一起使用。

**支持的值**：矩阵标识符的哈希数组：

- 标识符和值必须从 `parallel:matrix` 作业中定义的标识符和值中选择。
- 您可以使用[矩阵表达式](matrix_expressions.md)。

**`needs:parallel:matrix` 示例**：

```yaml
linux:build:
  stage: build
  script: echo "Building linux..."
  parallel:
    matrix:
      - PROVIDER: aws
        STACK:
          - monitoring
          - app1
          - app2

linux:rspec:
  stage: test
  needs:
    - job: linux:build
      parallel:
        matrix:
          - PROVIDER: aws
            STACK: app1
  script: echo "Running rspec on linux..."
```

上一个示例会生成以下作业：

```plaintext
linux:build: [aws, monitoring]
linux:build: [aws, app1]
linux:build: [aws, app2]
linux:rspec
```

`linux:rspec` 作业在 `linux:build: [aws, app1]` 作业完成后立即运行。

**其他详细信息**：

- 您不能将 `needs:parallel:matrix` 与 [`needs:optional`](#needsoptional) 一起使用。
- `needs:parallel:matrix`中矩阵标识符的顺序必须与所需作业中矩阵变量的顺序一致。例如，颠倒上一个示例中 `linux:rspec` 作业中变量的顺序将是无效的：

  ```yaml
  linux:rspec:
    stage: test
    needs:
      - job: linux:build
        parallel:
          matrix:
            - STACK: app1        # The variable order does not match `linux:build` and is invalid.
              PROVIDER: aws
    script: echo "Running rspec on linux..."
  ```

**相关主题**：

- [使用 needs 和多个并行作业指定并行作业](../jobs/job_control.md#specify-a-parallelized-job-using-needs-with-multiple-parallelized-jobs)。
- [`needs:parallel:matrix`中的矩阵表达式](matrix_expressions.md#matrix-expressions-in-needsparallelmatrix)。

<a id="pages"></a>

### `pages`

使用 `pages` 定义一个 [GitLab Pages](../../user/project/pages/_index.md) 作业，将静态内容上传到极狐GitLab。然后该内容会作为网站发布。

您必须：

- 定义 `pages: true` 以发布名为 `public`的目录
- 或者，如果您想使用不同的内容目录，请定义 [`pages.publish`](#pagespublish)。
- 在内容目录的根目录中有一个非空的 `index.html` 文件。

**关键字类型**：作业关键字或作业名称（已废弃）。只能作为作业的一部分使用。

**支持的值**：

- 布尔值。设置为 `true` 时使用默认配置
- 配置选项的哈希，详情请参见以下部分。

**`pages` 示例**：

```yaml
create-pages:
  stage: deploy
  script:
    - mv my-html-content public
  pages: true  # specifies that this is a Pages job and publishes the default public directory
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
  environment: production
```

此示例将 `my-html-content/` 目录重命名为 `public/`。该目录会作为产物导出，并通过 GitLab Pages 发布。

**使用配置哈希的示例**：

```yaml
create-pages:
  stage: deploy
  script:
    - echo "nothing to do here"
  pages:  # specifies that this is a Pages job and publishes the default public directory
    publish: my-html-content
    expire_in: "1 week"
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
  environment: production
```

此示例不移动目录，而是直接使用 `publish` 属性。它还将 Pages 部署配置为一周后取消发布。

**其他详细信息**：

- 将 `pages` 用作作业名称[已废弃](deprecated_keywords.md#publish-keyword-and-pages-job-name-for-gitlab-pages)。
- 要将 `pages` 用作作业名称而不触发 Pages 部署，请将 `pages` 属性设置为 false

---

<a id="pagespublish"></a>

#### `pages.publish`

使用 `pages.publish` 来配置 [`pages` 作业](#pages)的内容目录。

**关键字类型**：作业关键字。只能作为 `pages` 作业的一部分使用。

**支持的值**：包含 Pages 内容的目录路径。在 [极狐GitLab 17.10 及更高版本](https://gitlab.com/gitlab-org/gitlab/-/issues/428018)中，如果未指定，则使用默认的 `public` 目录；如果指定，此路径会自动追加到 [`artifacts:paths`](#artifactspaths)。

**`pages.publish` 示例**：

```yaml
create-pages:
  stage: deploy
  script:
    - npx @11ty/eleventy --input=path/to/eleventy/root --output=dist
  pages:
    publish: dist  # this path is automatically appended to artifacts:paths
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
  environment: production
```

此示例使用 [Eleventy](https://www.11ty.dev) 生成静态网站，并将生成的 HTML 文件输出到 `dist/` 目录。该目录会作为产物导出，并通过 GitLab Pages 发布。

也可以在 `pages.publish` 字段中使用变量。例如：

```yaml
create-pages:
  stage: deploy
  script:
    - mkdir -p $CUSTOM_FOLDER/$CUSTOM_PATH
    - cp -r public $CUSTOM_FOLDER/$CUSTOM_SUBFOLDER
  pages:
    publish: $CUSTOM_FOLDER/$CUSTOM_SUBFOLDER  # this path is automatically appended to artifacts:paths
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
  variables:
    CUSTOM_FOLDER: "custom_folder"
    CUSTOM_SUBFOLDER: "custom_subfolder"
```

指定的发布路径必须相对于构建根目录。

**其他详细信息**：

- 顶层 `publish` 关键字[已废弃](deprecated_keywords.md#publish-keyword-and-pages-job-name-for-gitlab-pages)，现在必须嵌套在 `pages` 关键字下

---

<a id="pagespath_prefix"></a>

#### `pages.path_prefix`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

使用 `pages.path_prefix` 为 GitLab Pages 的[并行部署](../../user/project/pages/_index.md#parallel-deployments)配置路径前缀。

**关键字类型**：作业关键字。只能作为 `pages` 作业的一部分使用。

**支持的值**：

- 字符串
- [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)
- 两者的组合

给定的值会转换为小写并缩短为 63 字节。除字母数字字符或句点外的所有内容都会替换为连字符。不允许开头和结尾的连字符或句点。

**`pages.path_prefix` 示例**：

```yaml
create-pages:
  stage: deploy
  script:
    - echo "Pages accessible through ${CI_PAGES_URL}"
  pages:  # specifies that this is a Pages job and publishes the default public directory
    path_prefix: "$CI_COMMIT_BRANCH"
```

在此示例中，会为每个分支创建不同的 Pages 部署。

---

<a id="pagesexpire_in"></a>

#### `pages.expire_in`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 `expire_in` 指定部署在过期前应保持可用的时长。部署过期后，会由每 10 分钟运行一次的 cron 作业将其停用。

默认情况下，[并行部署](../../user/project/pages/_index.md#parallel-deployments)会在 24 小时后自动过期。要禁用此行为，请将值设置为 `never`。

**关键字类型**：作业关键字。只能作为 `pages` 作业的一部分使用。

**支持的值**：过期时间。如果未提供单位，则时间以秒为单位。也支持变量。有效值包括：

- `'42'`
- `42 seconds`
- `3 mins 4 sec`
- `2 hrs 20 min`
- `2h20min`
- `6 mos 1 day`
- `47 yrs 6 mos and 4d`
- `3 weeks and 2 days`
- `never`
- `$DURATION`

**`pages.expire_in` 示例**：

```yaml
create-pages:
  stage: deploy
  script:
    - echo "Pages accessible through ${CI_PAGES_URL}"
  pages:  # specifies that this is a Pages job and publishes the default public directory
    expire_in: 1 week
```

---

<a id="parallel"></a>

### `parallel`

使用 `parallel` 在单个流水线中并行多次运行一个作业。

必须存在多个 runner，或者必须将单个 runner 配置为并发运行多个作业。

并行作业按顺序命名，从 `job_name 1/N` 到 `job_name N/N`。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- 从 `1` 到 `200`的数值。

**`parallel` 示例**：

```yaml
test:
  script: rspec
  parallel: 5
```

此示例创建 5 个并行运行的作业，命名为 `test 1/5` 到 `test 5/5`。

**其他详细信息**：

- 每个并行作业都设置了 `CI_NODE_INDEX` 和 `CI_NODE_TOTAL` [预定义 CI/CD 变量](../variables/_index.md#predefined-cicd-variables)。
- 带有使用 `parallel`的作业的流水线可能会：
  - 创建的并行运行作业数量超过可用 runner 数量。多余的作业会排队，并在等待可用 runner 时标记为 `pending`。
  - 如果创建流水线会导致所有活动流水线中的作业总数[超过实例限制](../../administration/cicd/limits.md#number-of-jobs-in-active-pipelines)，则失败并出现 `job_activity_limit_exceeded` 错误。

**相关主题**：

- [并行化大型作业](../jobs/job_control.md#parallelize-large-jobs)。

---

<a id="parallelmatrix"></a>

#### `parallel:matrix`

使用 `parallel:matrix` 在单个流水线中并行多次运行一个作业，但作业的每个实例使用不同的变量值。

必须存在多个 runner，或者必须将单个 runner 配置为并发运行多个作业。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：变量的哈希数组：

- 矩阵标识符（会成为变量名）只能使用数字、字母和下划线（`_`）。
- 值必须是字符串或字符串数组。
- 排列数量不能超过 200。

**`parallel:matrix` 示例**：

```yaml
deploystacks:
  stage: deploy
  script:
    - bin/deploy
  parallel:
    matrix:
      - PROVIDER: aws
        STACK:
          - monitoring
          - app1
          - app2
      - PROVIDER: [gcp, vultr]
        STACK: [data, processing]
  environment: $PROVIDER/$STACK
```

该示例生成 7 个并行的 `deploystacks` 作业，每个作业的 `PROVIDER` 和 `STACK` 值都不同：

- `deploystacks: [aws, monitoring]`
- `deploystacks: [aws, app1]`
- `deploystacks: [aws, app2]`
- `deploystacks: [gcp, data]`
- `deploystacks: [gcp, processing]`
- `deploystacks: [vultr, data]`
- `deploystacks: [vultr, processing]`

**其他详细信息**：

- `parallel:matrix` 作业会将矩阵值添加到作业名称中，以区分各个作业。但是，较长的值可能导致作业名称超过 255 个字符的限制。更多信息，请参见[史诗 11791](https://gitlab.com/groups/gitlab-org/-/work_items/11791)。
- 矩阵变量值可在 [`rules:if`](#rulesif) 表达式中作为 CI/CD 变量使用。更多信息，请参见[在 `rules:if`中使用矩阵变量](../jobs/job_control.md#use-matrix-variables-in-rulesif)。
- 您不能创建多个值相同但名称不同的矩阵配置。作业名称是根据矩阵值而非名称生成的，因此值相同的矩阵条目会生成相同的作业名称，从而相互覆盖。

  例如，此 `test` 配置会尝试创建两组相同的作业，但 `OS2` 版本会覆盖 `OS` 版本：

  ```yaml
  test:
    parallel:
      matrix:
        - OS: [ubuntu]
          PROVIDER: [aws, gcp]
        - OS2: [ubuntu]
          PROVIDER: [aws, gcp]
  ```

**相关主题**：

- [运行一维并行作业矩阵](../jobs/job_control.md#run-a-one-dimensional-matrix-of-parallel-jobs)。
- [运行触发的并行作业矩阵](../jobs/job_control.md#run-a-matrix-of-parallel-trigger-jobs)。
- [为每个并行矩阵作业选择不同的 runner 标签](../jobs/job_control.md#select-different-runner-tags-for-each-parallel-matrix-job)。
- [在规则中使用矩阵变量](../jobs/job_control.md#use-matrix-variables-in-rules)。
- [`needs:parallel:matrix`中的矩阵表达式](matrix_expressions.md#matrix-expressions-in-needsparallelmatrix)。

---

<a id="release"></a>

### `release`

使用 `release` 创建[发布](../../user/project/releases/_index.md)。

发布作业必须能够访问 [`glab` CLI](https://gitlab.cn/docs/cli/)，且该 CLI 必须位于 `$PATH`中。

如果您使用 [Docker 执行器](https://gitlab.cn/docs/runner/executors/docker/)，可以使用来自 GitLab 上游容器镜像仓库的此镜像：`registry.gitlab.com/gitlab-org/cli:latest`

如果您使用 [Shell 执行器](https://gitlab.cn/docs/runner/executors/shell/)或类似执行器，请在注册 runner 的服务器上[安装 `glab` CLI](https://gitlab.cn/docs/cli/#install-the-cli)。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：`release` 子键：

- [`tag_name`](#releasetag_name)
- [`tag_message`](#releasetag_message)（可选）
- [`name`](#releasename)（可选）
- [`description`](#releasedescription)
- [`ref`](#releaseref)（可选）
- [`milestones`](#releasemilestones)（可选）
- [`released_at`](#releasereleased_at)（可选）
- [`assets:links`](#releaseassetslinks)（可选）

**`release` 关键字示例**：

```yaml
release_job:
  stage: release
  image: registry.gitlab.com/gitlab-org/cli:latest
  rules:
    - if: $CI_COMMIT_TAG                  # Run this job when a tag is created manually
  script:
    - echo "Running the release job."
  release:
    tag_name: $CI_COMMIT_TAG
    name: 'Release $CI_COMMIT_TAG'
    description: 'Release created using the CLI.'
```

此示例会在以下情况下创建发布：

- 当您推送 Git 标签时。
- 当您在 UI 中的**代码** > **标签**处添加 Git 标签时。

**其他详细信息**：

- 发布作业必须包含 `script` 关键字。发布作业可以使用脚本命令的输出。如果您不需要脚本，可以使用占位符：

  ```yaml
  script:
    - echo "release job"
  ```

  更多详情，请参见[议题 223856](https://gitlab.com/gitlab-org/gitlab/-/issues/223856)，该议题旨在移除此限制。

- `release` 部分在 `script` 关键字之后、`after_script` 之前执行。
- 仅当作业的主脚本成功时才会创建发布。
- 如果发布已存在，则不会更新，带有 `release` 关键字的作业会失败。
- `release` 关键字使用 [`glab` CLI](https://gitlab.cn/docs/cli/)，并通过 `glab release create` 创建发布。默认情况下，发布使用 [`CI_JOB_TOKEN`](../jobs/ci_job_token.md) 进行身份验证。如果在作业中定义了以下任何 CI/CD 变量，`glab` 会改用该令牌，顺序为：`GITLAB_TOKEN`、`GITLAB_ACCESS_TOKEN` 或 `OAUTH_TOKEN`。在 `glab`的令牌解析中，这些令牌的[优先级](https://gitlab.cn/docs/cli/authentication/#token-precedence)高于 `CI_JOB_TOKEN`。如果此令牌缺少所需的 API 范围，发布可能会失败并出现 401 Unauthorized 错误。

**相关主题**：

- [`release` 关键字的 CI/CD 示例](../../user/project/releases/_index.md#creating-a-release-by-using-a-cicd-job)。
- [从 `release-cli` 迁移到 `glab` CLI](../../user/project/releases/release_cli.md)
- [在单个流水线中创建多个发布](../../user/project/releases/_index.md#create-multiple-releases-in-a-single-pipeline)。
- [使用自定义 SSL CA 证书颁发机构](../../user/project/releases/_index.md#use-a-custom-ssl-ca-certificate-authority)。

---

<a id="releasetag_name"></a>

#### `release:tag_name`

必需。发布的 Git 标签。

如果项目中尚不存在该标签，则会在创建发布的同时创建它。新标签使用与流水线关联的 SHA。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- 标签名称。

[支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file) CI/CD 变量。

**`release:tag_name` 示例**：

要在向项目添加新标签时创建发布：

- 使用 `$CI_COMMIT_TAG` CI/CD 变量作为 `tag_name`。
- 使用 [`rules:if`](#rulesif) 将作业配置为仅针对新标签运行。

```yaml
job:
  script: echo "Running the release job for the new tag."
  release:
    tag_name: $CI_COMMIT_TAG
    description: 'Release description'
  rules:
    - if: $CI_COMMIT_TAG
```

要同时创建发布和新标签，您的 [`rules`](#rules) 不应将作业配置为仅针对新标签运行。语义化版本控制示例：

```yaml
job:
  script: echo "Running the release job and creating a new tag."
  release:
    tag_name: ${MAJOR}_${MINOR}_${REVISION}
    description: 'Release description'
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
```

---

<a id="releasetag_message"></a>

#### `release:tag_message`

如果标签不存在，新创建的标签会使用 `tag_message` 指定的消息进行注解。如果省略，则创建轻量标签。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- 文本字符串。

**`release:tag_message` 示例**：

```yaml
  release_job:
    stage: release
    release:
      tag_name: $CI_COMMIT_TAG
      description: 'Release description'
      tag_message: 'Annotated tag message'
```

---

<a id="releasename"></a>

#### `release:name`

发布名称。如果省略，则使用 `release: tag_name`的值填充。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- 文本字符串。

**`release:name` 示例**：

```yaml
  release_job:
    stage: release
    release:
      name: 'Release $CI_COMMIT_TAG'
```

---

<a id="releasedescription"></a>

#### `release:description`

发布的详细描述。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- 包含详细描述的字符串。
- 包含描述的文件的路径。
  - 文件位置必须相对于项目目录（`$CI_PROJECT_DIR`）。
  - 如果文件是符号链接，它必须位于 `$CI_PROJECT_DIR`中。
  - `./path/to/file` 和文件名不能包含空格。

**`release:description` 示例**：

```yaml
job:
  release:
    tag_name: ${MAJOR}_${MINOR}_${REVISION}
    description: './path/to/CHANGELOG.md'
```

**其他详细信息**：

- `description` 由运行 `glab`的 shell 求值。您可以使用 CI/CD 变量来定义描述，但某些 shell [使用不同的语法](../variables/job_scripts.md)来引用变量。同样，某些 shell 可能需要转义特殊字符。例如，反引号（`` ` ``）可能需要使用反斜杠（` \ `）转义。

---

<a id="releaseref"></a>

#### `release:ref`

如果 `release: tag_name` 尚不存在，则为发布的 `ref`。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- 提交 SHA、另一个标签名称或分支名称。

---

<a id="releasemilestones"></a>

#### `release:milestones`

发布关联的每个里程碑的标题。

---

<a id="releasereleased_at"></a>

#### `release:released_at`

发布就绪的日期和时间。

**支持的值**：

- 用引号括起、以 ISO 8601 格式表示的日期。

**`release:released_at` 示例**：

```yaml
released_at: '2021-03-15T08:00:00Z'
```

**其他详细信息**：

- 如果未定义，则使用当前日期和时间。

---

<a id="releaseassetslinks"></a>

#### `release:assets:links`

使用 `release:assets:links` 在发布中包含[资产链接](../../user/project/releases/release_fields.md#release-assets)。

**`release:assets:links` 示例**：

```yaml
assets:
  links:
    - name: 'asset1'
      url: 'https://example.com/assets/1'
    - name: 'asset2'
      url: 'https://example.com/assets/2'
      filepath: '/pretty/url/1' # optional
      link_type: 'other' # optional
```

---

<a id="resource_group"></a>

### `resource_group`

使用 `resource_group` 创建一个[资源组](../resource_groups/_index.md)，以确保同一项目的不同流水线中的作业互斥。

例如，如果属于同一资源组的多个作业同时排队，则只有一个作业会启动。其他作业会等待，直到 `resource_group` 空闲。

资源组的行为类似于其他编程语言中的信号量。

您可以选择[处理模式](../resource_groups/_index.md#process-modes)，根据您的部署偏好策略性地控制作业并发。默认处理模式为 `unordered`。要更改资源组的处理模式，请使用 [API](../../api/resource_groups.md#update-a-resource-group) 发送请求来编辑现有资源组。

您可以为每个环境定义多个资源组。例如，在部署到物理设备时，您可能有多个物理设备。每个设备都可以部署，但在任何给定时间每个设备只能进行一次部署。

**关键字类型**：作业关键字。只能作为作业的一部分使用。

**支持的值**：

- 只能包含字母、数字、`-`、`_`、`/`、`$`、`{`、`}`、`.` 和空格。不能以 `/` 开头或结尾。[支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file) CI/CD 变量。

**`resource_group` 示例**：

```yaml
deploy-to-production:
  script: deploy
  resource_group: production
```

在此示例中，两个单独流水线中的两个 `deploy-to-production` 作业永远不会同时运行。因此，您可以确保生产环境永远不会发生并发部署。

**相关主题**：

- [使用跨项目/父子流水线进行流水线级并发控制](../resource_groups/_index.md#pipeline-level-concurrency-control-with-cross-projectparent-child-pipelines)。

---

<a id="retry"></a>

### `retry`

使用 `retry` 配置作业失败时重试的次数。如果未定义，默认为 `0`，作业不会重试。

当作业失败时，作业最多会被再处理两次，直到成功或达到最大重试次数。

默认情况下，所有失败类型都会导致作业重试。使用 [`retry:when`](#retrywhen) 或 [`retry:exit_codes`](#retryexit_codes) 来选择要重试的失败类型。

**关键字类型**：作业关键字。只能作为作业的一部分使用，或用在 [`default` 部分](#default)中。

**支持的值**：

- `0`（默认）、`1` 或 `2`。

**`retry` 示例**：

```yaml
test:
  script: rspec
  retry: 2

test_advanced:
  script:
    - echo "Run a script that results in exit code 137."
    - exit 137
  retry:
    max: 2
    when: runner_system_failure
    exit_codes: 137
```

如果退出代码为 `137` 或发生 runner 系统故障，`test_advanced` 最多会重试 2 次。

---

<a id="retrywhen"></a>

#### `retry:when`

将 `retry:when` 与 `retry:max` 一起使用，以仅针对特定失败情况重试作业。`retry:max` 是最大重试次数，与 [`retry`](#retry) 类似，可以是 `0`、`1` 或 `2`。

**关键字类型**：作业关键字。只能作为作业的一部分使用，或用在 [`default` 部分](#default)中。

**支持的值**：

- 单个失败类型，或一个或多个失败类型的数组：

<!--
  If you change any of the following values, make sure to update the `RETRY_WHEN_IN_DOCUMENTATION`
  array in `spec/lib/gitlab/ci/config/entry/retry_spec.rb`.
  The test there makes sure that all documented
  values are valid as a configuration option and therefore should always
  stay in sync with this documentation.
-->

- `always`：在任何失败时重试（默认）。
- `unknown_failure`：当失败原因未知时重试。
- `script_failure`：在以下情况重试：
  - 脚本失败。
  - runner 拉取 Docker 镜像失败。对于 `docker`、`docker+machine`、`kubernetes` [执行器](https://gitlab.cn/docs/runner/executors/)。
  - 在极狐GitLab 19.1 中引入，某些失败会从 `script_failure` 更改为更准确的 `runner_configuration_error`。
- `api_failure`：在 API 失败时重试。
- `stuck_or_timeout_failure`：当作业卡住或超时时重试。在极狐GitLab 19.1 中已废弃。会在 `stuck_pending_with_matching_runners`、`stuck_pending_no_matching_runners`、`no_updates_running` 或 `no_updates_canceling`中的任一情况下重试。请改用这些值。在极狐GitLab 19.0 及更高版本中，此原因仅为历史数据保留。新作业会改用下面列出的某个更具体的原因。要在这些情况下重试作业，请同时配置新的原因。
- `stuck_pending_with_matching_runners`：当作业长时间保持待处理状态，即使有匹配的 runner 可用时重试。
- `stuck_pending_no_matching_runners`：当作业因为没有 runner 匹配作业的要求（例如标签或受保护状态）而长时间保持待处理状态时重试。
- `no_updates_running`：当作业处于运行状态但长时间没有活动时重试，例如因为作业脚本挂起或 runner 失去连接。
- `no_updates_canceling`：当作业处于取消中状态但长时间没有活动时重试。
- `runner_system_failure`：如果存在 runner 系统故障（例如作业设置失败）则重试。
  - 在极狐GitLab 19.1 中引入，某些失败会从 `runner_system_failure` 更改为更准确的 `runner_external_dependency_failure` 或 `runner_interrupted`。
- `runner_configuration_error`：如果作业因 CI/CD 或 runner 配置错误而失败，例如无效的镜像或标签、不兼容的拉取策略或配置错误的 runner，则重试。
- `runner_external_dependency_failure`：如果 runner 因网络或 DNS 问题无法访问外部依赖（如镜像仓库），则重试。
- `runner_interrupted`：如果 runner 在作业运行期间被中断，例如因重启、关闭或主机回收，则重试。
- `runner_unsupported`：如果 runner 不受支持，则重试。
- `stale_schedule`：如果延迟的作业无法执行，则重试。
- `job_execution_timeout`：如果脚本超过了为作业设置的最大执行时间，则重试。在极狐GitLab 19.1 中已废弃。会在 `server_timeout_running` 或 `server_timeout_canceling`中重试。请改用这些值。
- `server_timeout_running`：当正在运行的作业超过其最大执行时间，且服务器端超时强制执行丢弃该作业时重试。
- `server_timeout_canceling`：当正在取消的作业超过其最大执行时间，且服务器端超时强制执行在取消期间丢弃该作业时重试。
- `archived_failure`：如果作业已归档且无法运行，则重试。
- `unmet_prerequisites`：如果作业未能完成先决任务，则重试。
- `scheduler_failure`：如果调度器未能将作业分配给 runner，则重试。
- `data_integrity_failure`：如果存在未知的作业问题，则重试。

**`retry:when` 示例**（单个失败类型）：

```yaml
test:
  script: rspec
  retry:
    max: 2
    when: runner_system_failure
```

如果发生 runner 系统故障以外的失败，作业不会重试。

**`retry:when` 示例**（失败类型数组）：

```yaml
test:
  script: rspec
  retry:
    max: 2
    when:
      - runner_system_failure
      - stuck_pending_with_matching_runners
      - stuck_pending_no_matching_runners
      - no_updates_running
```

---

<a id="retryexit_codes"></a>

#### `retry:exit_codes`

将 `retry:exit_codes` 与 `retry:max` 一起使用，以仅针对特定失败情况重试作业。`retry:max` 是最大重试次数，与 [`retry`](#retry) 类似，可以是 `0`、`1` 或 `2`。

**关键字类型**：作业关键字。只能作为作业的一部分使用，或用在 [`default` 部分](#default)中。

**支持的值**：

- 单个退出代码。
- 退出代码数组。

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

您可以使用变量指定[作业执行某些阶段的重试次数](../runners/configure_runners.md#job-stages-attempts)。

---

<a id="rules"></a>

### `rules`

使用 `rules` 在流水线中包含或排除作业。

规则在创建流水线时进行评估，并按顺序依次评估。找到匹配项后，不再检查其他规则，作业会根据配置被包含到流水线中或从中排除。如果没有规则匹配，则该作业不会添加到流水线中。

`rules` 接受一个规则数组。每条规则必须至少包含以下之一：

- `if`
- `changes`
- `exists`
- `when`

规则还可以选择性地与以下内容组合：

- `allow_failure`
- `needs`
- `variables`
- `interruptible`

您可以将多个关键字组合在一起，实现[复杂规则](../jobs/job_rules.md#complex-rules)。

作业会被添加到流水线中：

- 如果 `if`、`changes` 或 `exists` 规则匹配，并且配置了 `when: on_success`（未定义时的默认值）、
  `when: delayed` 或 `when: always`。
- 如果到达的规则仅包含 `when: on_success`、`when: delayed` 或 `when: always`。

作业不会被添加到流水线中：

- 如果没有规则匹配。
- 如果某条规则匹配且包含 `when: never`。

更多示例，请参见[使用 `rules` 指定作业运行时机](../jobs/job_rules.md)。

---

<a id="rulesif"></a>

#### `rules:if`

使用 `rules:if` 子句指定何时将作业添加到流水线中：

- 如果 `if` 语句为真，则将作业添加到流水线中。
- 如果 `if` 语句为真，但与其组合的是 `when: never`，则不将作业添加到流水线中。
- 如果 `if` 语句为假，则检查下一个 `rules` 项（如果还有的话）。

`if` 子句的评估依据：

- [CI/CD 变量](../variables/_index.md)或[预定义 CI/CD 变量](../variables/predefined_variables.md)的值，
  但[有一些例外](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。
- 按照 [`rules` 执行流程](#rules)的顺序。

作业之间不一致的规则可能导致意外行为，不过 [`workflow`](#workflow) 规则有助于缓解此问题。例如，可能会意外配置出导致[重复流水线](../jobs/job_rules.md#avoid-duplicate-pipelines)的作业。

**关键字类型**：作业特定和流水线特定。您可以将其作为作业的一部分来配置作业行为，或与 [`workflow`](#workflow) 一起使用来配置流水线行为。

**支持的值**：

- 一个 [CI/CD 变量表达式](../jobs/job_rules.md#cicd-variable-expressions)。

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

**其他详细信息**：

- 您不能将[嵌套变量](../variables/where_variables_can_be_used.md#nested-variable-expansion)
  与 `if` 一起使用。更多详情，请参见[议题 327780](https://gitlab.com/gitlab-org/gitlab/-/issues/327780)。
- 如果某条规则匹配且未定义 `when`，则该规则使用为作业定义的 `when`，
  如果未定义，则默认为 `on_success`。
- 您可以在作业级别混用 `when` 与规则中的 `when`。
  `rules`中的 `when` 配置优先于作业级别的 `when`。
- 与 [`script`](../variables/job_scripts.md)
  部分中的变量不同，规则表达式中的变量始终格式化为 `$VARIABLE`。
  - 您可以将 `rules:if` 与 `include` 一起使用，以[有条件地包含其他配置文件](includes.md#use-rules-with-include)。
- `=~` 和 `!~` 表达式右侧的 CI/CD 变量会[作为正则表达式进行评估](../jobs/job_rules.md#store-a-regular-expression-in-a-variable)。

**相关主题**：

- [`rules`的常用 `if` 表达式](../jobs/job_rules.md#common-if-clauses-with-predefined-variables)。
- [使用 `rules` 运行合并请求流水线](../pipelines/merge_request_pipelines.md#configure-merge-request-pipelines)。

---

<a id="ruleschanges"></a>

#### `rules:changes`

使用 `rules:changes` 通过检查特定文件的变更来指定何时将作业添加到流水线中。

对于新分支流水线，或者没有 Git `push` 事件时，`rules: changes` 始终评估为真，作业始终运行。像标签流水线、计划流水线和手动流水线这类流水线都没有关联的 Git `push` 事件。要覆盖这些情况，请使用 [`rules: changes: compare_to`](#ruleschangescompare_to) 指定要与流水线 ref 进行比较的分支。

如果您不使用 `compare_to`，则应仅将 `rules: changes` 与[分支流水线](../pipelines/pipeline_types.md#branch-pipeline)或[合并请求流水线](../pipelines/merge_request_pipelines.md)一起使用。不过，创建新分支时 `rules: changes` 仍会评估为真。具体如下：

- 合并请求流水线中，`rules:changes` 将变更与目标合并请求分支进行比较。
- 分支流水线中，`rules:changes` 将变更与该分支上的前一个提交进行比较。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

一个数组，可包含任意数量的：

- 文件路径。文件路径可以包含 [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。
- 通配符路径，用于：
  - 单个目录，例如 `path/to/directory/*`。
  - 一个目录及其所有子目录，例如 `path/to/directory/**/*`。
- 通配符 [glob](https://en.wikipedia.org/wiki/Glob_(programming)) 路径，用于所有具有
  相同扩展名或多个扩展名的文件，例如 `*.md` 或 `path/to/directory/*.{rb,py,sh}`。
  以 `*` 开头的路径必须用双引号（`"`）括起来。
- 指向根目录或所有目录中文件的通配符路径，需用双引号括起来。
  例如 `"*.json"` 或 `"**/*.json"`。

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

- 如果流水线是合并请求流水线，则检查 `Dockerfile` 以及
  `$DOCKERFILES_DIR/**/*` 中的文件是否有变更。
- 如果 `Dockerfile` 发生变更，则将作业作为手动作业添加到流水线中，并且即使该作业未触发，
  流水线也会继续运行（`allow_failure: true`）。
- 如果 `$DOCKERFILES_DIR/**/*` 中的文件发生变更，则将作业添加到流水线中。
- 如果所列文件均未变更，则不将任一作业添加到任何流水线中（等同于 `when: never`）。

**其他详细信息**：

- Glob 模式使用 Ruby 的 [`File.fnmatch`](https://docs.ruby-lang.org/en/master/File.html#method-c-fnmatch)
  进行解释，并带有[标志](https://docs.ruby-lang.org/en/master/File/Constants.html#module-File::Constants-label-Filename+Globbing+Constants+-28File-3A-3AFNM_-2A-29)
  `File::FNM_PATHNAME | File::FNM_DOTMATCH | File::FNM_EXTGLOB`。
- 出于性能原因，极狐GitLab 对
  `changes` 模式或文件路径最多执行 50,000 次检查。第 50,000 次检查之后，带模式的
  glob 规则始终匹配。换句话说，当变更文件超过 50,000 个，或者变更文件少于 50,000 个但
  `changes` 规则被检查超过 50,000 次时，`changes` 规则始终假定为匹配。
- 每个 `rules:changes` 部分最多可定义 50 个模式或文件路径。
- 如果任何匹配的文件发生变更，`changes` 会解析为 `true`（一种 `OR` 运算）。
- 更多示例，请参见[使用 `rules` 指定作业运行时机](../jobs/job_rules.md)。
- 您可以将 `$` 字符同时用于变量和路径。例如，如果
  `$VAR` 变量存在，则使用其值。如果不存在，则 `$` 会被解释
  为路径的一部分。
- 不要使用 `./`、双斜杠（`//`）或任何其他类型的相对路径。
  路径通过精确字符串比较进行匹配，不会像在 shell 中那样进行评估。

**相关主题**：

- [使用 `rules: changes` 时作业或流水线可能意外运行](../jobs/job_troubleshooting.md#jobs-or-pipelines-run-unexpectedly-when-using-changes)。

---

<a id="ruleschangespaths"></a>

##### `rules:changes:paths`

使用 `rules:changes` 指定仅当特定文件发生变更时才将作业添加到流水线中，并使用 `rules:changes:paths` 指定这些文件。

`rules:changes:paths` 与使用不带任何子键的 [`rules:changes`](#ruleschanges) 相同。所有其他详细信息和相关主题都相同。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

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

<a id="ruleschangescompare_to"></a>

##### `rules:changes:compare_to`

使用 `rules:changes:compare_to` 指定在比较 [`rules:changes:paths`](#ruleschangespaths) 下列出的文件变更时，要与哪个 ref 进行比较。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，并且必须与 `rules:changes:paths` 组合使用。

**支持的值**：

- 分支名称，例如 `main`、`branch1` 或 `refs/heads/branch1`。
- 标签名称，例如 `tag1` 或 `refs/tags/tag1`。
- 提交 SHA，例如 `2fg31ga14b`。

[支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file) CI/CD 变量。

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

在此示例中，仅当 `Dockerfile` 相对于 `refs/heads/branch1` 发生变更，且流水线来源是合并请求事件时，才会包含 `docker build` 作业。

**其他详细信息**：

- 在某些情况下使用 `compare_to` 可能导致意外结果：
  - 使用[合并结果流水线](../pipelines/merged_results_pipelines.md#troubleshooting)时，
    因为比较基准是极狐GitLab 创建的内部提交。
  - 在 fork 项目中，请参见[议题 424584](https://gitlab.com/gitlab-org/gitlab/-/issues/424584)。

**相关主题**：

- 您可以使用 `rules:changes:compare_to` 来[在分支为空时跳过作业](../jobs/job_rules.md#skip-jobs-if-the-branch-is-empty)。

---

<a id="ruleschangesregexp"></a>

##### `rules:changes:regexp`

使用 `rules:changes:regexp` 通过 Ruby 正则表达式（而非 glob 模式）匹配变更的文件路径。

`regexp:` 和 `paths:` 互斥。每个 `rules:changes` 块中只能使用其中一个。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- 一个 Ruby 正则表达式字符串。最大长度为 255 个字符。
  该模式会与每个变更的文件路径进行匹配。
  只要至少有一个路径匹配，规则即满足。

[支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file) CI/CD 变量。模式中的变量会在匹配模式之前展开。255 个字符的限制同样适用于展开后的模式。

**`rules:changes:regexp` 示例**：

```yaml
backend-tests:
  script: rspec
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes:
        regexp: '\A(?!docs/).*'
```

在此示例中，当至少有一个变更文件位于 `docs/` 目录之外时，`backend-tests` 会运行。

**其他详细信息**：

- 除非您为其添加锚点，否则该模式会匹配路径的任意部分。要匹配完整路径，
  请使用 `\A` 和 `\z` 为模式添加锚点。
- 请使用 `\A` 和 `\z` 而非 `^` 和 `$` 为模式添加锚点。Git 允许文件路径中包含换行符，
  而 `^` 和 `$` 会在换行边界处匹配。像 `^(?!docs/)` 这样的模式可能匹配到精心构造的
  包含换行符的路径，例如 `docs/` 下的文件后跟一个换行符和另一个路径。
- 与使用 RE2 的 `rules:if` 不同，`rules:changes:regexp` 使用 [Ruby 原生正则表达式引擎](https://docs.ruby-lang.org/en/3.3/Regexp.html)。
- 支持前瞻和后顾。
- 为防止 ReDoS 攻击，该模式受两个超时限制。每个单路径匹配
  有 50 毫秒的超时，所有路径的评估总预算为 2 秒。
  如果任一超时被超出，流水线会因配置错误而失败。
- 如果展开后的模式超过 255 个字符，流水线会因
  配置错误而失败。
- 出于性能原因，如果变更文件超过 50,000 个，该规则会评估为 `true`，
  而不运行该模式。
- 您可以将 `regexp:` 与 `compare_to:` 组合使用，以控制要与哪个 ref 进行比较。

---

<a id="rulesexists"></a>

#### `rules:exists`

使用 `exists` 在代码仓库中存在特定文件或目录时运行作业。

**关键字类型**：作业关键字。您可以将其作为作业或 [`include`](#include)的一部分使用。

**支持的值**：

- 一个文件或目录路径数组。路径相对于项目目录（`$CI_PROJECT_DIR`），
  不能直接链接到其外部。文件路径可以使用 glob 模式和
  [CI/CD 变量](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。

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

- 如果代码仓库的根目录中存在 `Dockerfile`，则运行 `job1`。
- 如果代码仓库中任意位置存在 `Dockerfile`，则运行 `job2`。

**其他详细信息**：

- Glob 模式使用 Ruby 的 [`File.fnmatch`](https://docs.ruby-lang.org/en/master/File.html#method-c-fnmatch)
  进行解释，并带有[标志](https://docs.ruby-lang.org/en/master/File/Constants.html#module-File::Constants-label-Filename+Globbing+Constants+-28File-3A-3AFNM_-2A-29)
  `File::FNM_PATHNAME | File::FNM_DOTMATCH | File::FNM_EXTGLOB`。
- 出于性能原因，极狐GitLab 对
  `exists` 模式或文件路径最多执行 50,000 次检查。第 50,000 次检查之后，带模式的
  glob 规则始终匹配。换句话说，在文件超过 50,000 个的项目中，或者文件少于 50,000 个但
  `exists` 规则被检查超过 50,000 次时，`exists` 规则始终假定为匹配。
  - 如果有多个带模式的 glob，则限制为 50,000 除以 glob 的数量。
    例如，一条包含 5 个带模式 glob 的规则的文件限制为 10,000。
- 每个 `rules:exists` 部分最多可定义 50 个模式或文件路径。
- 如果找到所列文件中的任意一个，`exists` 会解析为 `true`（一种 `OR` 运算）。
- 使用作业级 `rules:exists` 时，极狐GitLab 会在运行流水线的项目和
  ref 中搜索文件。当[将 `include` 与 `rules:exists` 一起使用](includes.md#include-with-rulesexists)时，
  极狐GitLab 会在包含 `include` 部分的文件所在项目和 ref 中搜索文件或目录。
  在使用以下内容时，包含 `include` 部分的项目可能与
  运行流水线的项目不同：
  - [嵌套 include](includes.md#use-nested-includes)。
  - [合规流水线](../../user/compliance/compliance_pipelines.md)。
- `rules:exists` 无法搜索[产物](../jobs/job_artifacts.md)是否存在，
  因为 `rules`的评估发生在作业运行和获取产物之前。
- 要测试目录是否存在，路径必须以正斜杠（/）结尾

---

<a id="rulesexistspaths"></a>

##### `rules:exists:paths`

`rules:exists:paths` 与使用不带任何子键的 [`rules:exists`](#rulesexists) 相同。所有其他详细信息都相同。

**关键字类型**：作业关键字。您可以将其作为作业或 [`include`](#include)的一部分使用。

**支持的值**：

- 一个文件路径数组。

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

<a id="rulesexistsproject"></a>

##### `rules:exists:project`

使用 `rules:exists:project` 指定在何处搜索 [`rules:exists:paths`](#rulesexistspaths) 下列出的文件。必须与 `rules:exists:paths` 一起使用。

**关键字类型**：作业关键字。您可以将其作为作业或 [`include`](#include)的一部分使用，并且必须与 `rules:exists:paths` 组合使用。

**支持的值**：

- `exists:project`：完整的项目路径，包括命名空间和群组。
- `exists:ref`：可选。用于搜索文件的提交 ref。ref 可以是标签、分支名称或 SHA。未指定时默认为项目的 `HEAD`。

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

在此示例中，仅当项目 `my-group/my-project`中标记为 `v1.0.0`的提交上存在 `Dockerfile` 时，才会包含 `docker build` 作业。

---

<a id="rulesexistsregexp"></a>

##### `rules:exists:regexp`

使用 `rules:exists:regexp` 通过 Ruby 正则表达式（而非 glob 模式）匹配代码仓库中的文件路径。

`regexp:` 和 `paths:` 互斥。每个 `rules:exists` 块中只能使用其中一个。

**关键字类型**：作业关键字。您可以将其作为作业或 [`include`](#include)的一部分使用。

**支持的值**：

- 一个 Ruby 正则表达式字符串。最大长度为 255 个字符。
  该模式会与代码仓库中的每个文件路径进行匹配。
  只要至少有一个路径匹配，规则即满足。

[支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file) CI/CD 变量。模式中的变量会在匹配模式之前展开。255 个字符的限制同样适用于展开后的模式。

**`rules:exists:regexp` 示例**：

```yaml
run-if-go-files-exist:
  script: go test ./...
  rules:
    - exists:
        regexp: '\.go$'
```

在此示例中，如果代码仓库中任意位置存在任何 `.go` 文件，则该作业会运行。

**其他详细信息**：

- 除非您为其添加锚点，否则该模式会匹配路径的任意部分。要匹配完整路径，
  请使用 `\A` 和 `\z` 为模式添加锚点。
- 请使用 `\A` 和 `\z` 而非 `^` 和 `$` 为模式添加锚点。Git 允许文件路径中包含换行符，
  而 `^` 和 `$` 会在换行边界处匹配。像 `^(?!docs/)` 这样的模式可能匹配到精心构造的
  包含换行符的路径，例如 `docs/` 下的文件后跟一个换行符和另一个路径。
- 与使用 RE2 的 `rules:if` 不同，`rules:exists:regexp` 使用 [Ruby 原生正则表达式引擎](https://docs.ruby-lang.org/en/3.3/Regexp.html)。
- 支持前瞻和后顾。
- 为防止 ReDoS 攻击，该模式受两个超时限制。每个单路径匹配
  有 50 毫秒的超时，所有路径的评估总预算为 2 秒。
  如果任一超时被超出，流水线会因配置错误而失败。
- 如果展开后的模式超过 255 个字符，流水线会因
  配置错误而失败。
- 出于性能原因，如果代码仓库包含超过 50,000 个文件，该规则
  会评估为 `true`，而不运行该模式。
- 您可以将 `regexp:` 与 `project:` 和 `ref:` 组合使用，以在其他项目中搜索。

---

<a id="ruleswhen"></a>

#### `rules:when`

单独使用 `rules:when`，或将其作为其他规则的一部分，以控制将作业添加到流水线的条件。`rules:when` 与 [`when`](#when) 类似，但输入选项略有不同。

如果 `rules:when` 规则未与 `if`、`changes` 或 `exists` 组合使用，则在评估作业规则时，只要到达该规则，它就始终匹配。

**关键字类型**：作业特定。您只能将其作为作业的一部分使用。

**支持的值**：

- `on_success`（默认）：仅当较早阶段中没有作业失败时运行该作业。
- `on_failure`：仅当较早阶段中至少有一个作业失败时运行该作业。
- `never`：无论较早阶段中作业的状态如何，都不运行该作业。
- `always`：无论较早阶段中作业的状态如何，都运行该作业。
- `manual`：将作业作为[手动作业](../jobs/job_control.md#create-a-job-that-must-be-run-manually)添加到流水线中。
  [`allow_failure`](#allow_failure)的默认值变为 `false`。
- `delayed`：将作业作为[延迟作业](../jobs/job_control.md#run-a-job-after-a-delay)添加到流水线中。

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

在此示例中，`job1` 会被添加到流水线中：

- 对于默认分支，使用 `when: on_success`，这是未定义 `when` 时的默认行为。
- 对于功能分支，作为延迟作业。
- 在所有其他情况下，作为手动作业。

**其他详细信息**：

- 在评估 `on_success` 和 `on_failure`的作业状态时：
  - 较早阶段中带有 [`allow_failure: true`](#allow_failure)的作业被视为成功，即使它们失败了。
  - 较早阶段中被跳过的作业，例如[尚未启动的手动作业](../jobs/job_control.md#create-a-job-that-must-be-run-manually)，
    被视为成功。
- 使用 `rules:when: manual` [添加手动作业](../jobs/job_control.md#create-a-job-that-must-be-run-manually)时：
  - [`allow_failure`](#allow_failure) 默认变为 `false`。此默认值与
    使用 [`when: manual`](#when) 添加手动作业时相反。
  - 要实现与在 `rules` 之外定义 `when: manual` 相同的行为，请将 [`rules: allow_failure`](#rulesallow_failure) 设置为 `true`。

---

<a id="rulesallow_failure"></a>

#### `rules:allow_failure`

在 `rules`中使用 [`allow_failure: true`](#allow_failure)，以允许作业失败而不停止流水线。

您也可以将 `allow_failure: true` 与手动作业一起使用。流水线会继续运行，而不等待手动作业的结果。`allow_failure: false` 与规则中的 `when: manual` 组合使用时，会导致流水线在继续之前等待手动作业运行。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- `true` 或 `false`。未定义时默认为 `false`。

**`rules:allow_failure` 示例**：

```yaml
job:
  script: echo "Hello, Rules!"
  rules:
    - if: $CI_MERGE_REQUEST_TARGET_BRANCH_NAME == $CI_DEFAULT_BRANCH
      when: manual
      allow_failure: true
```

如果规则匹配，则该作业是一个带有 `allow_failure: true`的手动作业。

**其他详细信息**：

- 规则级别的 `rules:allow_failure` 会覆盖作业级别的 [`allow_failure`](#allow_failure)，
  并且仅在特定规则触发该作业时适用。

---

<a id="rulesneeds"></a>

#### `rules:needs`

在规则中使用 `needs`，以针对特定条件更新作业的 [`needs`](#needs)。当条件匹配某条规则时，作业的 `needs` 配置会被完全替换为该规则中的 `needs`。

**关键字类型**：作业特定。您只能将其作为作业的一部分使用。

**支持的值**：

- 一个由作业名称字符串组成的数组。
- 一个包含作业名称的哈希，可选地带有其他属性。
- 一个空数组（`[]`），用于在满足特定条件时将作业的 needs 设置为无。

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

**其他详细信息**：

- 规则中的 `needs` 会覆盖作业级别定义的任何 `needs`。被覆盖时，其行为与[作业级 `needs`](#needs) 相同。
- 规则中的 `needs` 可以接受 [`artifacts`](#needsartifacts) 和 [`optional`](#needsoptional)。

---

<a id="rulesvariables"></a>

#### `rules:variables`

在 `rules`中使用 [`variables`](#variables) 为特定条件定义变量。

**关键字类型**：作业特定。您只能将其作为作业的一部分使用。

**支持的值**：

- 一个变量哈希，格式为 `VARIABLE-NAME: value`。

**`rules:variables` 示例**：

```yaml
job:
  variables:
    DEPLOY_VARIABLE: "default-deploy"
  rules:
    - if: $CI_COMMIT_REF_NAME == $CI_DEFAULT_BRANCH
      variables:                              # Override DEPLOY_VARIABLE defined
        DEPLOY_VARIABLE: "deploy-production"  # at the job level.
    - if: $CI_COMMIT_REF_NAME =~ /feature/
      variables:
        IS_A_FEATURE: "true"                  # Define a new variable.
  script:
    - echo "Run script with $DEPLOY_VARIABLE as an argument"
    - echo "Run another script if $IS_A_FEATURE exists"
```

---

<a id="rulesinterruptible"></a>

#### `rules:interruptible`

在规则中使用 `interruptible`，以针对特定条件更新作业的 [`interruptible`](#interruptible) 值。

**关键字类型**：作业特定。您只能将其作为作业的一部分使用。

**支持的值**：

- `true` 或 `false`。

**`rules:interruptible` 示例**：

```yaml
job:
  script: echo "Hello, Rules!"
  interruptible: true
  rules:
    - if: $CI_COMMIT_REF_NAME == $CI_DEFAULT_BRANCH
      interruptible: false  # Override interruptible defined at the job level.
    - when: on_success
```

**其他详细信息**：

- 规则级别的 `rules:interruptible` 会覆盖作业级别的 [`interruptible`](#interruptible)，
  并且仅在特定规则触发该作业时适用。

---

<a id="run"></a>

### `run`

{{< details >}}

- Status: 实验

{{< /details >}}

> [!note]
> 此功能可用于测试，但尚未准备好用于生产环境。

使用 `run` 定义要在作业中执行的一系列[步骤](../functions/_index.md)。每个步骤可以是脚本或预定义步骤。

您还可以提供可选的环境变量和输入。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- 一个哈希数组，其中每个哈希表示一个步骤，包含以下可能的键：
  - `name`：表示步骤名称的字符串。
  - `script`：包含要执行的 shell 命令的字符串。
  - `step`：标识要运行的预定义步骤的字符串。
  - `env`：可选。特定于此步骤的环境变量哈希。
  - `inputs`：可选。预定义步骤的输入参数哈希。

每个数组条目必须有一个 `name`，以及一个 `script` 或 `step`（但不能同时有两者）。

**`run` 示例**：

``` yaml
job:
  run:
    - name: 'hello_steps'
      script: 'echo "hello from step1"'
    - name: 'bye_steps'
      step: gitlab.com/gitlab-org/ci-cd/runner-tools/echo-step@main
      inputs:
        echo: 'bye steps!'
      env:
        var1: 'value 1'
```

在此示例中，该作业有两个步骤：

- `hello_steps` 运行 `echo` shell 命令。
- `bye_steps` 使用带有环境变量和输入参数的预定义步骤。

**其他详细信息**：

- 一个步骤可以有 `script` 或 `step` 键，但不能同时有两者。
- `run` 配置不能与现有的 [`script`](#script)、[`after_script`](#after_script) 或 [`before_script`](#before_script) 关键字一起使用。
- 可以使用 [YAML 块标量语法](script.md#split-long-commands)定义多行脚本。

---

<a id="script"></a>

### `script`

使用 `script` 指定供 runner 执行的命令。

除[触发作业](#trigger)外，所有作业都需要 `script` 关键字。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：一个数组，包含：

- 单行命令。
- [拆分为多行](script.md#split-long-commands)的长命令。
- [YAML 锚点](yaml_optimization.md#yaml-anchors-for-scripts)。

[支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file) CI/CD 变量。

**`script` 示例**：

```yaml
job1:
  script: "bundle exec rspec"

job2:
  script:
    - uname -a
    - bundle exec rspec
```

**其他详细信息**：

- 当您在 [`script`中使用这些特殊字符](script.md#use-special-characters-with-script)时，必须使用单引号（`'`）或双引号（`"`）。

**相关主题**：

- 您可以[忽略非零退出码](script.md#ignore-non-zero-exit-codes)。
- [在 `script`中使用颜色代码](script.md#add-color-codes-to-script-output)，
  使作业日志更易于查看。
- [创建自定义可折叠部分](../jobs/job_logs.md#create-custom-collapsible-sections)，
  以简化作业日志输出。

---

<a id="secrets"></a>

### `secrets`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 `secrets` 指定 [CI/CD 密钥](../secrets/_index.md)，以便：

- 从外部密钥提供商检索。
- 在作业中作为 [CI/CD 变量](../variables/_index.md)提供
  （默认为 [`file` 类型](../variables/_index.md#use-file-type-cicd-variables)）。

---

<a id="secretsvault"></a>

#### `secrets:vault`

使用 `secrets:vault` 指定由 [HashiCorp Vault](https://www.vaultproject.io/) 提供的密钥。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- `engine:name`：密钥引擎的名称。可以是 `kv-v2`（默认）、`kv-v1` 或 `generic` 之一。
- `engine:path`：密钥引擎的路径。
- `path`：密钥的路径。
- `field`：存储密码的字段名称。

**`secrets:vault` 示例**：

要显式指定所有详细信息并使用 [KV-V2](https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v2) 密钥引擎：

```yaml
job:
  secrets:
    DATABASE_PASSWORD:  # Store the path to the secret in this CI/CD variable
      vault:  # Translates to secret: `ops/data/production/db`, field: `password`
        engine:
          name: kv-v2
          path: ops
        path: production/db
        field: password
```

您可以缩短此语法。使用短语法时，`engine:name` 和 `engine:path` 都默认为 `kv-v2`：

```yaml
job:
  secrets:
    DATABASE_PASSWORD:  # Store the path to the secret in this CI/CD variable
      vault: production/db/password  # Translates to secret: `kv-v2/data/production/db`, field: `password`
```

要在短语法中指定自定义密钥引擎路径，请添加以 `@` 开头的后缀：

```yaml
job:
  secrets:
    DATABASE_PASSWORD:  # Store the path to the secret in this CI/CD variable
      vault: production/db/password@ops  # Translates to secret: `ops/data/production/db`, field: `password`
```

---

<a id="secretsgcp_secret_manager"></a>

#### `secrets:gcp_secret_manager`

使用 `secrets:gcp_secret_manager` 指定由 [GCP 密钥管理器](https://cloud.google.com/security/products/secret-manager) 提供的密钥。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- `name`：密钥的名称。
- `version`：密钥的版本。

**`secrets:gcp_secret_manager` 示例**：

```yaml
job:
  secrets:
    DATABASE_PASSWORD:
      gcp_secret_manager:
        name: 'test'
        version: 2
```

**相关主题**：

- [在极狐GitLab CI/CD 中使用 GCP 密钥管理器密钥](../secrets/gcp_secret_manager.md)。

---

<a id="secretsgitlab_secrets_manager"></a>

#### `secrets:gitlab_secrets_manager`

使用 `secrets:gitlab_secrets_manager` 指定来自[极狐GitLab 密钥管理器](../secrets/secrets_manager/_index.md)的密钥。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- `name`：密钥的名称。
- `source`：可选。密钥的来源。未指定时默认为当前项目。对于群组密钥，请使用 `group/<full-path-to-group>`。

**`secrets:gitlab_secrets_manager` 示例**：

```yaml
job:
  secrets:
    MY_DEPLOY_SECRET:
      gitlab_secrets_manager:
        name: deployment_token
```

---

<a id="secretsazure_key_vault"></a>

#### `secrets:azure_key_vault`

使用 `secrets:azure_key_vault` 指定由 [Azure Key Vault](https://azure.microsoft.com/en-us/products/key-vault/) 提供的密钥。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- `name`：密钥的名称。
- `version`：密钥的版本。

**`secrets:azure_key_vault` 示例**：

```yaml
job:
  secrets:
    DATABASE_PASSWORD:
      azure_key_vault:
        name: 'test'
        version: 'test'
```

**相关主题**：

- [在极狐GitLab CI/CD 中使用 Azure Key Vault 密钥](../secrets/azure_key_vault.md)。

---

<a id="secretsfile"></a>

#### `secrets:file`

使用 `secrets:file` 将密钥配置为存储为 [`file` 或 `variable` 类型的 CI/CD 变量](../variables/_index.md#use-file-type-cicd-variables)

默认情况下，密钥作为 `file` 类型的 CI/CD 变量传递给作业。密钥的值存储在文件中，变量包含该文件的路径。

如果您的软件无法使用 `file` 类型的 CI/CD 变量，请设置 `file: false`，以将密钥值直接存储在变量中。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- `true`（默认）或 `false`。

**`secrets:file` 示例**：

```yaml
job:
  secrets:
    DATABASE_PASSWORD:
      vault: production/db/password@ops
      file: false
```

**其他详细信息**：

- `file` 关键字是 CI/CD 变量的设置，必须嵌套在
  CI/CD 变量名称下，而不是在 `vault` 部分中。

---

<a id="secretstoken"></a>

#### `secrets:token`

使用 `secrets:token` 通过引用令牌的 CI/CD 变量，显式选择在与外部密钥提供商进行身份验证时要使用的令牌。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- ID 令牌的名称

**`secrets:token` 示例**：

```yaml
job:
  id_tokens:
    AWS_TOKEN:
      aud: https://aws.example.com
    VAULT_TOKEN:
      aud: https://vault.example.com
  secrets:
    DB_PASSWORD:
      vault: gitlab/production/db
      token: $VAULT_TOKEN
```

**其他详细信息**：

- 当未设置 `token` 关键字且只定义了一个令牌时，会自动使用该已定义的令牌。
- 如果定义了多个令牌，您应通过设置 `token` 关键字来指定要使用的令牌。
  如果您不指定要使用的令牌，则无法预测每次运行作业时使用的是哪个令牌。

---

<a id="services"></a>

### `services`

使用 `services` 指定您的脚本成功运行所需的任何其他 Docker 镜像。[`services` 镜像](../services/_index.md)会链接到 [`image`](#image) 关键字中指定的镜像。

作业配置和默认配置不会合并在一起。如果流水线定义了 [`default:services`](#default)，而作业也定义了 `services`，则作业配置优先，不使用默认配置。

> [!warning]
> 要启用服务间网络，请将 `FF_NETWORK_PER_BUILD` 设置为 `true`。
> 如果没有此功能标志，服务可能无法正常工作。更多信息，请参见
> [功能标志](https://gitlab.cn/docs/runner/configuration/feature-flags/)

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：服务镜像的名称，包括所需的仓库路径，采用以下格式之一：

- `<image-name>`（等同于使用带 `latest` 标签的 `<image-name>`）
- `<image-name>:<tag>`
- `<image-name>@<digest>`

[支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file) CI/CD 变量，但不支持用于 `alias`。要动态自定义 `alias`，请改用 [CI/CD 输入](../inputs/_index.md)。

**`services` 示例**：

```yaml
default:
  image:
    name: ruby:2.6
    entrypoint: ["/bin/bash"]

  services:
    - name: my-postgres:11.7
      alias: db-postgres
      entrypoint: ["/usr/local/bin/db-postgres"]
      command: ["start"]

  before_script:
    - bundle install

test:
  script:
    - bundle exec rake spec
```

在此示例中，极狐GitLab 为该作业启动两个容器：

- 一个运行 `script` 命令的 Ruby 容器。
- 一个 PostgreSQL 容器。Ruby 容器中的 `script` 命令可以连接到
  主机名为 `db-postgres`的 PostgreSQL 数据库。

**其他详细信息**：

- 在顶层使用 `services`（而不是在 `default` 部分中）已被[弃用](deprecated_keywords.md#globally-defined-image-services-cache-before_script-after_script)。

**相关主题**：

- [`services`的可用设置](../services/_index.md#available-settings-for-services)。
- [在 `.gitlab-ci.yml` 文件中定义 `services`](../services/_index.md#define-services-in-the-gitlab-ciyml-file)。
- [在 Docker 容器中运行 CI/CD 作业](../docker/using_docker_images.md)。
- [使用 Docker 构建 Docker 镜像](../docker/using_docker_build.md)。

---

<a id="servicesname"></a>

#### `services:name`

用于该服务的镜像的完整名称。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：服务镜像的名称，包括所需的仓库路径，采用以下格式之一：

- `<image-name>`（等同于使用带 `latest` 标签的 `<image-name>`）
- `<image-name>:<tag>`
- `<image-name>@<digest>`

[支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file) CI/CD 变量。

**`services:name` 示例**：

```yaml
services:
  - name: postgres:11.7
  - name: registry.example.com/my-org/custom-service:latest
```

**其他详细信息**：

- 在使用多个相同的服务镜像，或服务镜像名称较长时，使用 [`alias`](#servicesalias) 定义唯一的名称别名。
- 当与 `entrypoint`、`command` 或 `variables` 等其他服务选项一起使用时，`name` 关键字是必需的。
- 更多信息，请参见[访问服务](../services/_index.md#accessing-the-services)。

---

<a id="servicesalias"></a>

#### `services:alias`

用于从作业容器访问服务的其他别名。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：一个字符串，包含一个或多个以空格或逗号分隔的别名。

**`services:alias` 示例**：

```yaml
services:
  - name: postgres:11.7
    alias: db,postgres,pg
  - name: mysql:latest
    alias: mysql-1
```

**其他详细信息**：

- 多个别名可以用空格或逗号分隔。
- 更多信息，请参见[访问服务](../services/_index.md#accessing-the-services)
  以及[将别名用作 Kubernetes 执行器的服务容器名称](../services/_index.md#using-aliases-as-service-container-names-for-the-kubernetes-executor)。

---

<a id="servicesdocker"></a>

#### `services:docker`

使用 `services:docker` 将选项传递给极狐GitLab Runner 的 Docker 执行器。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

Docker 执行器的选项哈希，可包括：

- `platform`：选择要拉取的镜像的架构。未指定时，
  默认为与主机 runner 相同的平台。
- `user`：指定运行容器时要使用的用户名或 UID。

**`services:docker` 示例**：

```yaml
arm-sql-job:
  script: echo "Run sql tests in service container"
  image: ruby:2.6
  services:
    - name: super/sql:experimental
      docker:
        platform: arm64/v8
        user: dave
```

**其他详细信息**：

- `services:docker:platform` 映射到 [`docker pull --platform` 选项](https://docs.docker.com/reference/cli/docker/image/pull/#options)。
- `services:docker:user` 映射到 [`docker run --user` 选项](https://docs.docker.com/reference/cli/docker/container/run/#options)。
- 使用 Docker 执行器时，要运行针对与 runner 主机不同架构构建的服务镜像，
  主机必须注册有 `binfmt_misc`的模拟支持。
  更多信息，请参见 [`image:docker`](#imagedocker)。

---

<a id="serviceskubernetes"></a>

#### `services:kubernetes`

使用 `services:kubernetes` 将选项传递给极狐GitLab Runner [Kubernetes 执行器](https://gitlab.cn/docs/runner/executors/kubernetes/)。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

Kubernetes 执行器的选项哈希，可包括：

- `user`：指定容器运行时要使用的用户名或 UID。您还可以使用 `UID:GID` 格式来设置 GID。

**仅包含 UID 的 `services:kubernetes` 示例**：

```yaml
arm-sql-job:
  script: echo "Run sql tests"
  image: ruby:2.6
  services:
    - name: super/sql:experimental
      kubernetes:
        user: "1001"
```

**同时包含 UID 和 GID 的 `services:kubernetes` 示例**：

```yaml
arm-sql-job:
  script: echo "Run sql tests"
  image: ruby:2.6
  services:
    - name: super/sql:experimental
      kubernetes:
        user: "1001:1001"
```

---

<a id="servicesentrypoint"></a>

#### `services:entrypoint`

作为容器入口点执行的命令或脚本。

创建 Docker 容器时，`entrypoint` 会转换为 Docker 的 `--entrypoint` 选项。
语法类似于 [Dockerfile `ENTRYPOINT` 指令](https://docs.docker.com/reference/dockerfile/#entrypoint)，
其中每个 shell 令牌都是数组中的一个单独字符串。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：一个表示入口点命令的字符串数组。

**`services:entrypoint` 示例**：

```yaml
services:
  - name: my-postgres:11.7
    entrypoint: ["/usr/local/bin/db-postgres"]
```

---

<a id="servicescommand"></a>

#### `services:command`

应用作容器命令的命令或脚本。

它会转换为在镜像名称之后传递给 Docker 的参数。语法类似于
[Dockerfile `CMD`](https://docs.docker.com/reference/dockerfile/#cmd) 指令，
其中每个 shell 令牌都是数组中的一个单独字符串。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：一个表示命令的字符串数组。

**`services:command` 示例**：

```yaml
services:
  - name: super/sql:latest
    command: ["/usr/bin/super-sql", "run"]
```

---

<a id="servicesvariables"></a>

#### `services:variables`

仅传递给该服务的其他环境变量。服务变量仅传递给服务容器，作业容器无法使用。

语法与[作业变量](../variables/_index.md)相同。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：一个环境变量名称和值的哈希。

**`services:variables` 示例**：

```yaml
services:
  - name: postgres:11.7
    alias: db
    variables:
      POSTGRES_DB: "my_custom_db"
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "example"
      PGDATA: "/var/lib/postgresql/data"
```

**其他详细信息**：

- 服务变量不能引用自身，它们不支持变量展开或插值。
- 在作业或流水线级别定义的变量会自动传递给服务。更多信息，请参见[将 CI/CD 变量传递给服务](../services/_index.md#passing-cicd-variables-to-services)。
- 服务变量仅对为其定义的特定服务可用。

---

<a id="servicespull_policy"></a>

#### `services:pull_policy`

runner 用于获取 Docker 镜像的拉取策略。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- 单个拉取策略，或数组中的多个拉取策略。
  可以是 `always`、`if-not-present` 或 `never`。

**`services:pull_policy` 示例**：

```yaml
job1:
  script: echo "A single pull policy."
  services:
    - name: postgres:11.6
      pull_policy: if-not-present

job2:
  script: echo "Multiple pull policies."
  services:
    - name: postgres:11.6
      pull_policy: [always, if-not-present]
```

**其他详细信息**：

- 如果 runner 不支持所定义的拉取策略，作业会失败，并显示类似以下内容的错误：
  `ERROR: Job failed (system failure): the configured PullPolicies ([always]) are not allowed by AllowedPullPolicies ([never])`。

**相关主题**：

- [在 Docker 容器中运行 CI/CD 作业](../docker/using_docker_images.md)。
- [配置 runner 如何拉取镜像](https://gitlab.cn/docs/runner/executors/docker/#configure-how-runners-pull-images)。
- [设置多个拉取策略](https://gitlab.cn/docs/runner/executors/docker/#set-multiple-pull-policies)。

---

<a id="stage"></a>

### `stage`

使用 `stage` 定义作业在哪个[阶段](#stages)中运行。同一 `stage`中的作业可以并行执行（请参见**其他详细信息**）。

如果未定义 `stage`，作业默认使用 `test` 阶段。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：一个字符串，可以是：

- [默认阶段](#stages)。
- 用户定义的阶段。

**`stage` 示例**：

```yaml
stages:
  - build
  - test
  - deploy

job1:
  stage: build
  script:
    - echo "This job compiles code."

job2:
  stage: test
  script:
    - echo "This job tests the compiled code. It runs when the build stage completes."

job3:
  script:
    - echo "This job also runs in the test stage."

job4:
  stage: deploy
  script:
    - echo "This job deploys the code. It runs when the test stage completes."
  environment: production
```

**其他详细信息**：

- 阶段名称必须为 255 个字符或更少。
- 如果作业在不同的 runner 上运行，则可以并行运行。
- 如果您只有一个 runner，则当该 runner 的
  [`concurrent` 设置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-global-section)
  大于 `1` 时，作业可以并行运行。

---

<a id="stage-pre"></a>

#### `stage: .pre`

使用 `.pre` 阶段使作业在流水线开始时运行。默认情况下，`.pre` 是流水线中的第一个阶段。用户定义的阶段在 `.pre` 之后执行。您不必在 [`stages`](#stages)中定义 `.pre`。

如果流水线仅包含 `.pre` 或 `.post` 阶段中的作业，则它不会运行。必须至少有一个位于其他阶段的作业。

**关键字类型**：您只能将其与作业的 `stage` 关键字一起使用。

**`stage: .pre` 示例**：

```yaml
stages:
  - build
  - test

job1:
  stage: build
  script:
    - echo "This job runs in the build stage."

first-job:
  stage: .pre
  script:
    - echo "This job runs in the .pre stage, before all other stages."

job2:
  stage: test
  script:
    - echo "This job runs in the test stage."
```

**其他详细信息**：

- 如果流水线中有带 [`needs: []`](#needs) 的作业以及 `.pre` 阶段中的作业，它们
  都会在流水线创建后立即启动。带 `needs: []` 的作业会立即启动，
  忽略任何阶段配置。
- [流水线执行策略](../../user/application_security/policies/pipeline_execution_policies.md)可以定义在 `.pre` 之前运行的 `.pipeline-policy-pre` 阶段。

---

<a id="stage-post"></a>

#### `stage: .post`

使用 `.post` 阶段使作业在流水线结束时运行。默认情况下，`.post` 是流水线中的最后一个阶段。用户定义的阶段在 `.post` 之前执行。您不必在 [`stages`](#stages)中定义 `.post`。

如果流水线仅包含 `.pre` 或 `.post` 阶段中的作业，则它不会运行。必须至少有一个位于其他阶段的作业。

**关键字类型**：您只能将其与作业的 `stage` 关键字一起使用。

**`stage: .post` 示例**：

```yaml
stages:
  - build
  - test

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

**其他详细信息**：

- [流水线执行策略](../../user/application_security/policies/pipeline_execution_policies.md)可以定义在 `.post` 之后运行的 `.pipeline-policy-post` 阶段。

---

<a id="tags"></a>

### `tags`

使用 `tags` 从项目可用的所有 runner 列表中选择特定的 runner。

注册 runner 时，您可以指定 runner 的标签，例如 `ruby`、`postgres` 或 `development`。要获取并运行作业，runner 必须被分配作业中列出的每个标签。

作业配置和默认配置不会合并在一起。如果流水线定义了 [`default:tags`](#default)，而作业也定义了 `tags`，则作业配置优先，不使用默认配置。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用，或在 [`default` 部分](#default)中使用。

**支持的值**：

- 一个标签名称数组，区分大小写。
- [支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file) CI/CD 变量。

**`tags` 示例**：

```yaml
job:
  tags:
    - ruby
    - postgres
```

在此示例中，只有同时具有 `ruby` 和 `postgres` 标签的 runner 才能运行该作业。

**其他详细信息**：

- 标签数量必须少于 `50`。

**相关主题**：

- [使用标签控制 runner 可以运行哪些作业](../runners/configure_runners.md#control-jobs-that-a-runner-can-run)
- [为每个并行矩阵作业选择不同的 runner 标签](../jobs/job_control.md#select-different-runner-tags-for-each-parallel-matrix-job)
- 托管 runner 的 runner 标签：
  - [Linux 上的托管 runner](../runners/hosted_runners/linux.md)
  - [启用 GPU 的托管 runner](../runners/hosted_runners/gpu_enabled.md)
  - [macOS 上的托管 runner](../runners/hosted_runners/macos.md)
  - [Windows 上的托管 runner](../runners/hosted_runners/windows.md)

---

<a id="timeout"></a>

### `timeout`

使用 `timeout` 为特定作业配置超时。如果作业运行时间超过超时时间，则作业失败。

作业级超时可以长于[项目超时](../pipelines/settings.md#set-a-limit-for-how-long-jobs-can-run)，但不能长于 [runner 的超时](../runners/configure_runners.md#set-the-maximum-job-timeout)。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：用自然语言表示的一段时间。例如，以下写法都等效：

- `3600 seconds`
- `60 minutes`
- `one hour`

**`timeout` 示例**：

```yaml
build:
  script: build.sh
  timeout: 3 hours 30 minutes

test:
  script: rspec
  timeout: 3h 30m
```

**其他详细信息**：

- `default` 配置中不支持 `timeout` 关键字。请改为在各个作业配置中定义 `timeout`。
  更多信息，请参见[议题 213634](https://gitlab.com/gitlab-org/gitlab/-/issues/213634)。

---

<a id="trigger"></a>

### `trigger`

使用 `trigger` 声明某个作业是“触发作业”，它会启动[下游流水线](../pipelines/downstream_pipelines.md)，该流水线可以是：

- [多项目流水线](../pipelines/downstream_pipelines.md#multi-project-pipelines)。
- [子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)。

触发作业只能使用有限的一组极狐GitLab CI/CD 配置关键字。触发作业中可用的关键字有：

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

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- 对于多项目流水线，为下游项目的路径。[支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file) CI/CD 变量，
  但不支持[仅作业变量](../variables/predefined_variables.md#variable-availability)。
  或者，使用 [`trigger:project`](#triggerproject)。
- 对于子流水线，使用 [`trigger:include`](#triggerinclude)。

**`trigger` 示例**：

```yaml
trigger-multi-project-pipeline:
  trigger: my-group/my-project
```

**其他详细信息**：

- 您可以在与 `trigger` 相同的作业中使用 [`when:manual`](#when)，但不能
  使用 API 启动 `when:manual` 触发作业。更多详情，请参见[议题 284086](https://gitlab.com/gitlab-org/gitlab/-/issues/284086)。
- 在运行手动触发作业之前，您不能[手动指定 CI/CD 变量](../jobs/job_control.md#specify-variables-when-running-manual-jobs)。
- 在顶层 `variables` 部分（全局）或触发作业中定义的 [CI/CD 变量](#variables)会作为[触发变量](../pipelines/downstream_pipelines.md#pass-cicd-variables-to-a-downstream-pipeline)
  转发到下游流水线。
- 默认情况下，[流水线变量](../variables/_index.md#cicd-variable-precedence)不会传递
  到下游流水线。使用 [`trigger:forward`](#triggerforward) 将这些变量
  转发到下游流水线。
- [仅作业变量](../variables/predefined_variables.md#variable-availability)
  在触发作业中不可用。
- [在 runner 的 `config.toml`中定义](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runners-section)的环境变量对触发作业不可用，也不会传递到下游流水线。
- 您不能在触发作业中使用 [`needs:pipeline:job`](#needspipelinejob)。

**相关主题**：

- [多项目流水线配置示例](../pipelines/downstream_pipelines.md#trigger-a-downstream-pipeline-from-a-job-in-the-gitlab-ciyml-file)。
- 要为特定分支、标签或提交运行流水线，您可以使用[触发令牌](../triggers/_index.md)
  通过[流水线触发器 API](../../api/pipeline_triggers.md) 进行身份验证。
  触发令牌与 `trigger` 关键字不同。

---

<a id="triggerinputs"></a>

#### `trigger:inputs`

当下游流水线配置使用 [`spec:inputs`](#specinputs) 时，使用 `trigger:inputs` 为多项目流水线设置[输入](../inputs/_index.md)。

**`trigger:inputs` 示例**：

```yaml
trigger:
  - project: 'my-group/my-project'
    inputs:
      website: "My website"
```

---

<a id="triggerinclude"></a>

#### `trigger:include`

使用 `trigger:include` 声明某个作业是“触发作业”，它会启动[子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- 子流水线配置文件的路径。

路径中对 CI/CD 变量的支持有限，请参见 [`trigger:include` 路径中的变量为空或值不符合预期](../pipelines/downstream_pipelines_troubleshooting.md#variable-in-a-triggerinclude-path-is-empty-or-has-an-unexpected-value)。请考虑改用[输入](../inputs/_index.md)。

**`trigger:include` 示例**：

```yaml
trigger-child-pipeline:
  trigger:
    include: path/to/child-pipeline.gitlab-ci.yml
```

**其他详细信息**：

使用：

- `trigger:include:artifact` 触发[动态子流水线](../pipelines/downstream_pipelines.md#dynamic-child-pipelines)。
- `trigger:include:inputs` 在下游流水线配置
  使用 [`spec:inputs`](#specinputs) 时设置[输入](../inputs/_index.md)。
- `trigger:include:local` 用于在以下情况下指定子流水线配置文件的路径：
  - 组合[多个子流水线配置文件](../pipelines/downstream_pipelines.md#combine-multiple-child-pipeline-configuration-files)。
  - 与 `trigger:include:inputs` 组合使用，以将输入传递给子流水线。例如：

    ```yaml
    staging-job:
      trigger:
        include:
          - local: path/to/child-pipeline.yml
            inputs:
              environment: staging
    ```

- `trigger:include:project` 触发[使用其他项目中的配置文件](../pipelines/downstream_pipelines.md#use-a-child-pipeline-configuration-file-in-a-different-project)的子流水线。
  如果该文件包含其他 [`include`](#include) 条目，极狐GitLab 会在
  运行流水线的项目中查找这些文件，而不是在托管该文件的项目中查找。
- `trigger:include:template` 使用 CI/CD 模板触发子流水线。

**相关主题**：

- [子流水线配置示例](../pipelines/downstream_pipelines.md#trigger-a-downstream-pipeline-from-a-job-in-the-gitlab-ciyml-file)。

---

<a id="triggerincludeinputs"></a>

#### `trigger:include:inputs`

当下游流水线配置使用 [`spec:inputs`](#specinputs) 时，使用 `trigger:include:inputs` 为子流水线设置[输入](../inputs/_index.md)。

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

<a id="triggerproject"></a>

#### `trigger:project`

使用 `trigger:project` 声明某个作业是“触发作业”，它会启动[多项目流水线](../pipelines/downstream_pipelines.md#multi-project-pipelines)。

默认情况下，多项目流水线会针对默认分支触发。使用 `trigger:branch` 指定其他分支。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**支持的值**：

- 下游项目的路径。[支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file) CI/CD 变量，
  但不支持[仅作业变量](../variables/predefined_variables.md#variable-availability)。

**`trigger:project` 示例**：

```yaml
trigger-multi-project-pipeline:
  trigger:
    project: my-group/my-project
```

**针对其他分支的 `trigger:project` 示例**：

```yaml
trigger-multi-project-pipeline:
  trigger:
    project: my-group/my-project
    branch: development
```

**相关主题**：

- [多项目流水线配置示例](../pipelines/downstream_pipelines.md#trigger-a-downstream-pipeline-from-a-job-in-the-gitlab-ciyml-file)。
- 要为特定分支、标签或提交运行流水线，您还可以使用[触发令牌](../triggers/_index.md)
  通过[流水线触发器 API](../../api/pipeline_triggers.md) 进行身份验证。
  触发令牌与 `trigger` 关键字不同。

---

<a id="triggerstrategy"></a>

#### `trigger:strategy`

使用 `trigger:strategy` 强制 `trigger` 作业等待下游流水线完成后，才被标记为**成功**。

此行为与默认行为不同，默认情况下 `trigger` 作业会在下游流水线创建后立即被标记为**成功**。

此设置会使您的流水线执行变为线性而非并行。

**支持的值**：

- `mirror`：完全镜像下游流水线的状态。
- `depend`：不推荐，请改用 `mirror`。触发作业状态会显示**已失败**、**成功**
  或**运行中**，具体取决于下游流水线的状态。请参见其他详细信息。

**`trigger:strategy` 示例**：

```yaml
trigger_job:
  trigger:
    include: path/to/child-pipeline.yml
    strategy: mirror
```

在此示例中，后续阶段中的作业会等待被触发的流水线成功完成后才开始。

**其他详细信息**：

- 下游流水线中的[可选手动作业](../jobs/job_control.md#types-of-manual-jobs)
  不会影响下游流水线或上游触发作业的状态。
  下游流水线可以在不运行任何可选手动作业的情况下成功完成。
- 默认情况下，后续阶段中的作业要等到触发作业完成后才会开始。
- 下游流水线中的[阻塞手动作业](../jobs/job_control.md#types-of-manual-jobs)
  必须先运行，触发作业才会被标记为成功或失败。
- 使用 `strategy:depend` 时（不再推荐，请改用 `strategy:mirror`）：
  - 如果下游流水线状态为
    **等待手动操作**（{{< icon name="status_manual" >}}），则触发作业会显示**运行中**（{{< icon name="status_running" >}}）。
  - 如果下游流水线有失败的作业，但该作业使用了 [`allow_failure: true`](#allow_failure)，
    则下游流水线被视为成功，触发作业会显示**成功**。

---

<a id="triggerforward"></a>

#### `trigger:forward`

使用 `trigger:forward` 指定要转发到下游流水线的内容。您可以控制转发到[父子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)和[多项目流水线](../pipelines/downstream_pipelines.md#multi-project-pipelines)的内容。

默认情况下，转发的变量不会在嵌套的下游流水线中再次转发，除非嵌套的下游触发作业也使用 `trigger:forward`。

**支持的值**：

- `yaml_variables`：`true`（默认）或 `false`。当为 `true` 时，触发作业中定义的
  变量会传递到下游流水线。这包括作业继承的
  [默认变量](#default-variables)，以及直接在
  触发作业的 `variables` 块中定义的变量。
- `pipeline_variables`：`true` 或 `false`（默认）。当为 `true` 时，[流水线变量](../variables/_index.md#use-pipeline-variables)
  会传递到下游流水线。这包括来自手动流水线运行、
  计划流水线的变量，以及
  `needs`中列出的作业的 dotenv 变量。

**`trigger:forward` 示例**：

[手动运行此流水线](../pipelines/_index.md#run-a-pipeline-manually)，并使用 CI/CD 变量 `MYVAR = my value`：

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

**其他详细信息**：

- 使用 `trigger:forward` 转发到下游流水线的 CI/CD 变量是[流水线变量](../variables/_index.md#cicd-variable-precedence)，
  具有较高的优先级。如果下游流水线中定义了同名的变量，
  该变量通常会被转发的变量覆盖。
- `forward:yaml_variables` 也会影响 [`trigger:include`](#triggerinclude) 路径中的 CI/CD 变量。
  更多信息，请参见
  [`trigger:include` 路径中的变量为空或值不符合预期](../pipelines/downstream_pipelines_troubleshooting.md#variable-in-a-triggerinclude-path-is-empty-or-has-an-unexpected-value)。

---

<a id="when"></a>

### `when`

使用 `when` 配置作业运行的条件。如果未在作业中定义，默认值为 `when: on_success`。

**关键字类型**：作业关键字。您可以将其作为作业的一部分使用。`when: always` 和 `when: never` 也可用于 [`workflow:rules`](#workflow)。

**支持的值**：

- `on_success`（默认）：仅当早期阶段没有作业失败时才运行该作业。
- `on_failure`：仅当早期阶段至少有一个作业失败时才运行该作业。
- `never`：无论早期阶段作业的状态如何，都不运行该作业。
  只能在 [`rules`](#ruleswhen) 部分或 [`workflow: rules`](#workflowrules)中使用。
- `always`：无论早期阶段作业的状态如何，都运行该作业。
- `manual`：将作业作为[手动作业](../jobs/job_control.md#create-a-job-that-must-be-run-manually)添加到流水线中。
- `delayed`：将作业作为[延迟作业](../jobs/job_control.md#run-a-job-after-a-delay)添加到流水线中。

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

在此示例中，脚本：

1. 仅当 `build_job` 失败时才执行 `cleanup_build_job`。
1. 无论成功还是失败，始终将 `cleanup_job` 作为流水线中的最后一步执行。
1. 当您在极狐GitLab UI 中手动运行 `deploy_job` 时执行该作业。

**其他详细信息**：

- 在评估 `on_success` 和 `on_failure`的作业状态时：
  - 早期阶段中带有 [`allow_failure: true`](#allow_failure)的作业即使失败，也会被视为成功。
  - 早期阶段中被跳过的作业，例如[尚未启动的手动作业](../jobs/job_control.md#create-a-job-that-must-be-run-manually)，会被视为成功。
- 使用 `when: manual` 时，[`allow_failure`](#allow_failure)的默认值为 `true`。使用 [`rules:when: manual`](#ruleswhen) 时，默认值变为 `false`。

**相关主题**：

- `when` 可与 [`rules`](#rules) 一起使用，以实现更动态的作业控制。
- `when` 可与 [`workflow`](#workflow) 一起使用，以控制流水线何时可以启动。

---

<a id="manual_confirmation"></a>

#### `manual_confirmation`

将 `manual_confirmation` 与 [`when: manual`](#when) 一起使用，为手动作业定义自定义确认消息。如果没有使用 `when: manual` 定义手动作业，此关键字无效。

手动确认适用于所有手动作业，包括使用 [`environment:action: stop`](#environmentaction)的环境停止作业。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

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

### `start_in`

使用 `start_in` 在作业创建后延迟指定时长再执行该作业。您必须为该作业配置 `when: delayed`。

**关键字类型**：作业关键字。您只能将其作为作业的一部分使用。

**可能的输入**：以秒、分钟或小时为单位的时间段。必须小于或等于一周。有效值示例：

- `'5'`（5 秒）
- `'10 seconds'`
- `'30 minutes'`
- `'1 hour'`
- `'1 day'`

**`start_in` 示例**：

```yaml
deploy_production:
  stage: deploy
  script:
    - echo "Deploying to production"
  when: delayed
  start_in: 30 minutes
```

在此示例中，`deploy_production` 作业在前一阶段完成 30 分钟后启动。

**其他详细信息**：

- 计时器在作业所在阶段开始时启动，而不是在前一个作业完成时启动。
- 要立即手动启动延迟作业，请在流水线视图中选择**运行**（{{< icon name="play" >}}）。
- 最短延迟时间为一秒，最长延迟时间为一周。
- `start_in` 仅在 [`when`](#when) 设置为 `delayed` 时才有效。如果您为 `when` 使用任何其他值，该配置无效。
  如果作业使用 `rules`，则 `start_in` 和 `when` 必须在 `rules`中定义，而不是在作业级别定义。
  否则，您会收到验证错误：`config key may not be used with 'rules': start_in`。
- `start_in` 不支持与 `workflow:rules` 一起使用，但不会导致任何语法违规。

**相关主题**：

- [延迟后运行作业](../jobs/job_control.md#run-a-job-after-a-delay)

---

<a id="variables"></a>

## `variables`

使用 `variables` 定义 [CI/CD 变量](../variables/_index.md#define-a-cicd-variable-in-the-gitlab-ciyml-file)。

变量可以[在 CI/CD 作业中定义](#job-variables)，也可以作为顶级（全局）关键字来为所有作业定义[默认 CI/CD 变量](#default-variables)。

**其他详细信息**：

- 所有 YAML 定义的变量也会设置到任何关联的 [Docker 服务容器](../services/_index.md)。
- YAML 定义的变量用于非敏感项目配置。请将敏感信息存储在
  [受保护变量](../variables/_index.md#protect-a-cicd-variable)或 [CI/CD 密钥](../secrets/_index.md)中。
- [手动流水线变量](../variables/_index.md#use-pipeline-variables)
  和[计划流水线变量](../pipelines/schedules.md#create-a-pipeline-schedule)
  默认不会传递到下游流水线。使用 [`trigger:forward`](#triggerforward)
  将这些变量转发到下游流水线。

**相关主题**：

- [预定义变量](../variables/predefined_variables.md)是 runner
  自动创建并在作业中可用的变量。
- 您可以[使用变量配置 runner 行为](../runners/configure_runners.md#configure-runner-behavior-with-variables)。

---

<a id="job-variables"></a>

### 作业 `variables`

您可以在作业的 `script`、`before_script` 或 `after_script` 部分的命令中使用作业变量，也可以与某些[作业关键字](#job-keywords)一起使用。请查看每个作业关键字的**支持的值**部分，以确认其是否支持变量。

您不能将作业变量用作[全局关键字](#global-keywords)（如 [`include`](includes.md#use-variables-with-include)）的值。

**支持的值**：变量名称和值对：

- 名称只能使用数字、字母和下划线（`_`）。在某些 shell 中，
  第一个字符必须是字母。
- 值必须是字符串。

CI/CD 变量[受支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。

**作业 `variables` 示例**：

```yaml
review_job:
  variables:
    DEPLOY_SITE: "https://dev.example.com/"
    REVIEW_PATH: "/review"
  script:
    - deploy-review-script --url $DEPLOY_SITE --path $REVIEW_PATH
```

在此示例中：

- `review_job` 定义了 `DEPLOY_SITE` 和 `REVIEW_PATH` 作业变量。
  这两个作业变量都可以在 `script` 部分中使用。

---

<a id="default-variables"></a>

### 默认 `variables`

在顶级 `variables` 部分中定义的变量将作为所有作业的默认变量。

每个默认变量都可用于流水线中的每个作业，除非该作业已经定义了同名变量。作业中定义的变量[优先级更高](../variables/_index.md#cicd-variable-precedence)，因此同名的默认变量的值无法在该作业中使用。

与作业变量一样，您不能将默认变量用作其他全局关键字的值，例如 [`include`](includes.md#use-variables-with-include)。

**支持的值**：变量名称和值对：

- 名称只能使用数字、字母和下划线（`_`）。在某些 shell 中，
  第一个字符必须是字母。
- 值必须是字符串。

CI/CD 变量[受支持](../variables/where_variables_can_be_used.md#gitlab-ciyml-file)。

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

- `deploy_job` 没有定义变量。默认的 `DEPLOY_SITE` 变量被复制到该作业，
  并可在 `script` 部分中使用。
- `deploy_review_job` 已经定义了 `DEPLOY_SITE` 变量，因此默认的 `DEPLOY_SITE`
  不会被复制到该作业。该作业还定义了 `REVIEW_PATH` 作业变量。
  这两个作业变量都可以在 `script` 部分中使用。

---

<a id="variablesdescription"></a>

#### `variables:description`

使用 `description` 关键字为默认变量定义描述。该描述会与[手动运行流水线时预填的变量名称](../pipelines/_index.md#prefill-variables-in-manual-pipelines)一起显示。

**关键字类型**：您只能将此关键字用于默认 `variables`，不能用于作业 `variables`。

**支持的值**：

- 字符串。您可以使用 Markdown。

**`variables:description` 示例**：

```yaml
variables:
  DEPLOY_NOTE:
    description: "The deployment note. Explain the reason for this deployment."
```

**其他详细信息**：

- 当不带 `value` 使用时，该变量存在于非手动触发的流水线中，
  且默认值为空字符串（`''`）。

---

<a id="variablesvalue"></a>

#### `variables:value`

使用 `value` 关键字定义流水线级别（默认）变量的值。当与 [`variables: description`](#variablesdescription) 一起使用时，变量值会在[手动运行流水线时预填](../pipelines/_index.md#prefill-variables-in-manual-pipelines)。

**关键字类型**：您只能将此关键字用于默认 `variables`，不能用于作业 `variables`。

**支持的值**：

- 字符串。

**`variables:value` 示例**：

```yaml
variables:
  DEPLOY_ENVIRONMENT:
    value: "staging"
    description: "The deployment target. Change this variable to 'canary' or 'production' if needed."
```

**其他详细信息**：

- 如果不与 [`variables: description`](#variablesdescription) 一起使用，其行为
  与 [`variables`](#variables) 相同。

---

<a id="variablesoptions"></a>

#### `variables:options`

使用 `variables:options` 定义一个值数组，这些值可[在手动运行流水线时在 UI 中选择](../pipelines/_index.md#configure-a-list-of-selectable-prefilled-variable-values)。

必须与 `variables: value` 一起使用，并且为 `value` 定义的字符串：

- 也必须是 `options` 数组中的字符串之一。
- 是默认选择项。

如果没有 [`description`](#variablesdescription)，此关键字无效。

**关键字类型**：您只能将此关键字用于默认 `variables`，不能用于作业 `variables`。

**支持的值**：

- 字符串数组。

**`variables:options` 示例**：

```yaml
variables:
  DEPLOY_ENVIRONMENT:
    value: "staging"
    options:
      - "production"
      - "staging"
      - "canary"
    description: "The deployment target. Set to 'staging' by default."
```

---

<a id="variablesexpand"></a>

### `variables:expand`

使用 `expand` 关键字配置变量是否可展开。

**关键字类型**：您可以将此关键字用于默认变量和作业 `variables`。

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

- `VAR2`的结果是 `value2 value1`。
- `VAR3`的结果是 `value3 $VAR1`。

**其他详细信息**：

- `expand` 关键字只能与默认变量和作业 `variables` 关键字一起使用。
  您不能将其与 [`rules:variables`](#rulesvariables) 或 [`workflow:rules:variables`](#workflowrulesvariables) 一起使用。
