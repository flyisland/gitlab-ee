---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page,
  see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 将 dotenv 变量传递给特定作业
description: 使用 dotenv 报告在流水线中的作业之间传递环境变量。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要将环境变量传递给其他作业，请使用 dotenv 文件。dotenv 文件是扩展名为 `.env` 的文件，其中存储了环境变量键值对列表。例如，在 `sample.env` 文件中：

```plaintext
REVIEW_URL=review.example.com/123456
BUILD_VERSION=v1.0.0
```

将 dotenv 文件保存为 [dotenv 报告产物](../yaml/artifacts_reports.md#artifactsreportsdotenv)，
它可以传递给同一流水线中的其他作业、下游流水线，或用于设置动态环境 URL。

您可以通过以下方式使用 dotenv 变量：

- 在一个作业中生成值，并在后续作业中使用这些值。
- 在流水线阶段之间传递计算值。
- 根据部署输出设置动态环境 URL。
- 在多项目流水线之间共享变量。

您可以在作业的 `script` 部分中使用 dotenv 变量，也可以在支持 [Runner 上的变量展开](where_variables_can_be_used.md#gitlab-ciyml-file) 的关键字中使用。
您不能在 `rules` 部分中使用 dotenv 变量。

Dotenv 变量的[优先级](_index.md#cicd-variable-precedence)高于作业变量
以及 `.gitlab-ci.yml` 中定义的默认变量，但低于项目、群组、实例或流水线变量。

如果同一个变量名在 `dotenv` 报告中出现多次，则使用最后一个值。

<a id="pass-variables-to-later-jobs"></a>

## 将变量传递给后续作业

默认情况下，dotenv 变量可用于后续阶段中的所有作业。要在作业之间传递变量：

1. 在某个作业中，创建一个文件（例如 `build.env`），其中包含格式为 `VARIABLE_NAME=value` 的变量，
   每行一个变量。
1. 将该文件输出为 `dotenv` 报告产物。
1. 在后续作业的脚本中使用这些变量。

例如，`build-job` 创建了包含 `BUILD_VERSION=v1.0.0` 的 `build.env`，而 `test-job` 会自动将其作为环境变量接收：

```yaml
build-job:
  stage: build
  script:
    - echo "BUILD_VERSION=v1.0.0" >> build.env
  artifacts:
    reports:
      dotenv: build.env

test-job:
  stage: test
  script:
    - echo "Testing version $BUILD_VERSION"  # Output: 'Testing version v1.0.0'
```

> [!warning]
> 请勿在 dotenv 文件中包含凭据、API 密钥或令牌等敏感数据。
> 流水线用户可以访问 dotenv 文件内容。要限制访问，请使用
> [`artifacts:access`](../yaml/_index.md#artifactsaccess)。

<a id="control-which-jobs-receive-dotenv-variables"></a>

## 控制哪些作业接收 dotenv 变量

要控制哪些作业接收 dotenv 变量，请使用
[`dependencies`](../yaml/_index.md#dependencies) 或 [`needs`](../yaml/_index.md#needs) 关键字。

<a id="inherit-from-specific-jobs"></a>

### 仅从特定作业继承

使用 `dependencies` 将继承范围限制为仅特定作业：

```yaml
build-job1:
  stage: build
  script:
    - echo "BUILD_VERSION=v1.0.0" >> build.env
  artifacts:
    reports:
      dotenv: build.env

build-job2:
  stage: build
  script:
    - echo "This job has no dotenv artifacts"

test-job:
  stage: test
  script:
    - echo "$BUILD_VERSION"  # Output: 'v1.0.0'
  dependencies:
    - build-job1
    # build-job2 is not listed, so its artifacts are not inherited
```

<a id="exclude-dotenv-variables"></a>

### 排除 dotenv 变量

要阻止作业从某个指定作业接收 dotenv 变量，请使用带有 `artifacts: false` 的 `needs`。这会阻止从该作业下载所有产物，而不仅仅是 dotenv 变量：

```yaml
test-job:
  stage: test
  script:
    - echo "$BUILD_VERSION"  # Output: '' (empty)
  needs:
    - job: build-job1
      artifacts: false
```

此示例中的 [`needs`](../yaml/_index.md#needs) 还会使作业在 `build-job1` 完成后立即开始。

或者使用空的 [`dependencies`](../yaml/_index.md) 数组来阻止从所有上游作业下载产物：

```yaml
test-job:
  stage: test
  script:
    - echo "$BUILD_VERSION"  # Output: '' (empty)
  dependencies: []
```

<a id="pass-variables-to-downstream-pipelines"></a>

## 将变量传递给下游流水线

您可以通过 dotenv 变量继承将 dotenv 变量传递给下游流水线。
在[多项目流水线](../pipelines/downstream_pipelines.md#multi-project-pipelines)中，
在上游作业中创建 dotenv 产物，并在下游作业中使用 `needs` 来继承它：

1. 将变量保存在 `.env` 文件中。
1. 将 `.env` 文件保存为 `dotenv` 报告产物。
1. 触发下游流水线。

```yaml
build_vars:
  stage: build
  script:
    - echo "BUILD_VERSION=hello" >> build.env
  artifacts:
    reports:
      dotenv: build.env

deploy:
  stage: deploy
  trigger: my/downstream_project
```

在下游流水线中，将作业设置为使用 `needs` 从上游作业继承产物。该作业会接收 dotenv 变量，然后可以在脚本中访问 `BUILD_VERSION`：

```yaml
test:
  stage: test
  script:
    - echo $BUILD_VERSION
  needs:
    - project: my/upstream_project
      job: build_vars
      ref: master
      artifacts: true
```

<a id="set-a-dynamic-environment-url"></a>

## 设置动态环境 URL

如果外部托管平台为每次部署动态生成 URL，您可以使用 dotenv 变量在部署作业完成后将该 URL 设置为环境 URL。

有关更多信息，请参阅[设置动态环境 URL](../environments/_index.md#set-a-dynamic-environment-url)。

<a id="store-complex-values"></a>

## 存储复杂值

Dotenv 文件有特定的格式限制，例如对多行值以及需要转义的特殊字符的限制。如果您的值包含 JSON、跨越多行，或包含需要转义的字符，请避免使用 dotenv 变量。请改用单独的文件产物。
有关值约束的完整列表，请参阅[格式要求](#format-requirements)。

不要这样做：

```yaml
# Not supported
- echo 'CONFIG={"key": "value"}' >> build.env
```

请使用单独的产物：

```yaml
build-job:
  stage: build
  script:
    - echo '{"key": "value"}' > config.json
  artifacts:
    paths:
      - config.json
```

<a id="dotenv-file-requirements"></a>

## Dotenv 文件要求

Dotenv 文件必须满足以下格式、大小和变量要求。

极狐GitLab 使用 [dotenv gem](https://github.com/bkeepers/dotenv) 来处理 dotenv 文件，
但在[原始 dotenv 规则](https://github.com/motdotla/dotenv?tab=readme-ov-file#what-rules-does-the-parsing-engine-follow)
和该 gem 的实现之外，还应用了额外的限制。

<a id="format-requirements"></a>

### 格式要求

- 仅支持 [UTF-8 编码](../jobs/job_artifacts_troubleshooting.md#error-message-fatal-invalid-argument-when-uploading-a-dotenv-artifact-on-a-windows-runner)。
- 文件不能包含空行或注释（以 `#` 开头的行）。
- 变量名只能包含 ASCII 字母（`A-Za-z`）、数字（`0-9`）和下划线（`_`）。
- dotenv 文件不支持引号。单引号或双引号会按原样保留，不能用于转义。
- 值不能包含换行符或其他需要转义的特殊字符。
- 不支持多行值。极狐GitLab 会在上传时拒绝该文件。
- 前导和尾随空格或换行符（`\n`）会被去除。

<a id="size-and-variable-limits"></a>

### 大小和变量限制

| 限制                                                      | 值 |
| ---------------------------------------------------------- | ----- |
| 最大文件大小                                          | 5 KB  |
| 极狐GitLab 私有化部署上默认最大继承变量数 | 20    |

有关 JihuLab.com 的套餐限制，请参阅 [JihuLab.com CI/CD 设置](../../user/jihulab_com/_index.md#gitlab-cicd)。

要更改极狐GitLab 私有化部署上的这些限制，请参阅 [CI/CD 限制](../../administration/cicd/limits.md#limit-dotenv-file-size)。
