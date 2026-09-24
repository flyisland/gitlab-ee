---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn how to write GitLab CI/CD `script` sections and improve job logs with special syntax or configuration.
title: 脚本与作业日志
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以在 [`script`](_index.md#script) 部分中使用特殊语法来：

- [拆分长命令](#split-long-commands) 为多行命令。
- [使用颜色代码](#add-color-codes-to-script-output) 使作业日志更易于查看。
- [创建自定义可折叠部分](../jobs/job_logs.md#create-custom-collapsible-sections) 以简化作业日志输出。

<a id="use-special-characters-with-script"></a>

## 在 `script` 中使用特殊字符

有时，`script` 命令必须用单引号或双引号括起来。例如，包含冒号 (`:`) 的命令必须用单引号 (`'`) 括起来。YAML 解析器需要将文本解释为字符串，而不是“键: 值”对。

例如，此脚本使用了冒号：

```yaml
job:
  script:
    - curl --request POST --header 'Content-Type: application/json' "https://gitlab.example.com/api/v4/projects"
```

要使其成为有效的 YAML，您必须用单引号将整个命令括起来。如果命令已经使用了单引号，则应在可能的情况下将其更改为双引号 (`"`)：

```yaml
job:
  script:
    - 'curl --request POST --header "Content-Type: application/json" "https://gitlab.example.com/api/v4/projects"'
```

您可以使用 [CI Lint](lint.md) 工具验证语法是否有效。

同时在使用以下字符时也要小心：

- `{`, `}`, `[`, `]`, `,`, `&`, `*`, `#`, `?`, `|`, `-`, `<`, `>`, `=`, `!`, `%`, `@`, `` ` ``.

<a id="ignore-non-zero-exit-codes"></a>

## 忽略非零退出码

当脚本命令返回非零退出码时，作业将失败并且后续命令不会执行。

将退出码存储在变量中可以避免这种行为：

```yaml
job:
  script:
    - exit_code=0
    - false || exit_code=$?
    - if [ $exit_code -ne 0 ]; then echo "Previous command failed"; fi;
```

<a id="set-a-default-before_script-or-after_script-for-all-jobs"></a>

## 为所有作业设置默认的 `before_script` 或 `after_script`

您可以将 [`before_script`](_index.md#before_script) 和 [`after_script`](_index.md#after_script) 与 [`default`](_index.md#default) 结合使用：

- 将 `before_script` 与 `default` 结合使用，可以定义一个默认命令数组，这些命令应在所有作业的 `script` 命令之前运行。
- 将 `after_script` 与 default 结合使用，可以定义一个默认命令数组，这些命令应在任何作业完成或被取消后运行。

您可以通过在作业中定义不同的内容来覆盖默认值。要忽略默认值，请使用 `before_script: []` 或 `after_script: []`：

```yaml
default:
  before_script:
    - echo "Execute this `before_script` in all jobs by default."
  after_script:
    - echo "Execute this `after_script` in all jobs by default."

job1:
  script:
    - echo "These script commands execute after the default `before_script`,"
    - echo "and before the default `after_script`."

job2:
  before_script:
    - echo "Execute this script instead of the default `before_script`."
  script:
    - echo "This script executes after the job's `before_script`,"
    - echo "but the job does not use the default `after_script`."
  after_script: []
```

<a id="skip-after_script-commands-if-a-job-is-canceled"></a>

## 取消作业时跳过 `after_script` 命令

{{< history >}}

- 在极狐GitLab 17.0 中引入，带有一个功能标志 `ci_canceling_status`。默认启用。需要极狐GitLab Runner 版本 16.11.1。
- 在极狐GitLab 17.3 中 GA。功能标志 `ci_canceling_status` 移除。

{{< /history >}}

如果作业在其 `before_script` 或 `script` 部分运行期间被取消，[`after_script`](_index.md) 命令仍会运行。

在 UI 中，当 `after_script` 执行时，作业状态为 `canceling`，并在 `after_script` 命令完成后变为 `canceled`。在 `after_script` 命令运行时，预定义变量 `$CI_JOB_STATUS` 的值为 `canceled`。

为了防止在取消作业后运行 `after_script` 命令，请配置 `after_script` 部分以：

1. 在 `after_script` 部分开始时检查预定义变量 `$CI_JOB_STATUS`。
1. 如果值为 `canceled`，则提前结束执行。

例如：

```yaml
job1:
  script:
    - my-script.sh
  after_script:
    - if [ "$CI_JOB_STATUS" == "canceled" ]; then exit 0; fi
    - my-after-script.sh
```

<a id="split-long-commands"></a>

## 拆分长命令

您可以使用 `|`（文字）和 `>`（折叠）[YAML 多行块标量指示符](https://yaml-multiline.info/) 将长命令拆分为多行命令，以提高可读性。

> [!warning]
> 如果多个命令合并为一个命令字符串，则仅报告最后一个命令的失败或成功。
> [由于一个错误，早期命令的失败将被忽略](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/25394)。
> 要解决此问题，请将每个命令作为单独的 `script` 项运行，或在每个命令字符串中添加 `exit 1` 命令。

您可以使用 `|`（文字）YAML 多行块标量指示符在作业描述的 `script` 部分中跨多行编写命令。每行被视为单独的命令。作业日志中仅重复显示第一个命令，但仍然执行其他命令：

```yaml
job:
  script:
    - |
      echo "First command line."
      echo "Second command line."
      echo "Third command line."
```

上述示例在作业日志中显示为：

```shell
$ echo First command line # collapsed multiline command
First command line
Second command line.
Third command line.
```

`>`（折叠）YAML 多行块标量指示符将各段之间的空行视为新命令的开始：

```yaml
job:
  script:
    - >
      echo "First command line
      is split over two lines."

      echo "Second command line."
```

这与不使用 `>` 或 `|` 块标量指示符的多行命令行为类似：

```yaml
job:
  script:
    - echo "First command line
      is split over two lines."

      echo "Second command line."
```

前两个示例在作业日志中显示为：

```shell
$ echo First command line is split over two lines. # collapsed multiline command
First command line is split over two lines.
Second command line.
```

当您省略 `>` 或 `|` 块标量指示符时，极狐GitLab 会将非空行连接起来形成命令。请确保连接后的行可以运行。

<!-- vale gitlab_base.MeaningfulLinkWords = NO -->

[Shell 此处文档](https://en.wikipedia.org/wiki/Here_document) 也可以与 `|` 和 `>` 运算符一起使用。以下示例将小写字母音译为大写字母：

<!-- vale gitlab_base.MeaningfulLinkWords = YES -->

```yaml
job:
  script:
    - |
      tr a-z A-Z << END_TEXT
        one two three
        four five six
      END_TEXT
```

结果为：

```shell
$ tr a-z A-Z << END_TEXT # collapsed multiline command
  ONE TWO THREE
  FOUR FIVE SIX
```

<a id="add-color-codes-to-script-output"></a>

## 向脚本输出添加颜色代码

脚本输出可以使用 [ANSI 转义码](https://en.wikipedia.org/wiki/ANSI_escape_code#Colors) 进行着色，或通过运行输出 ANSI 转义码的命令或程序。

例如，使用 [带颜色代码的 Bash](https://misc.flogisoft.com/bash/tip_colors_and_formatting)：

```yaml
job:
  script:
    - echo -e "\e[31mThis text is red,\e[0m but this text isn't\e[31m however this text is red again."
```

您可以在 Shell 环境变量中定义颜色代码，甚至可以在 [CI/CD 变量](../variables/_index.md#define-a-cicd-variable-in-the-gitlab-ciyml-file) 中定义，这使得命令更易于阅读且可重用。

例如，使用前面示例和 `before_script` 中定义的环境变量：

```yaml
job:
  before_script:
    - TXT_RED="\e[31m" && TXT_CLEAR="\e[0m"
  script:
    - echo -e "${TXT_RED}This text is red,${TXT_CLEAR} but this part isn't${TXT_RED} however this part is again."
    - echo "This text is not colored"
```

或者使用 [PowerShell 颜色代码](https://superuser.com/a/1259916)：

```yaml
job:
  before_script:
    - $esc="$([char]27)"; $TXT_RED="$esc[31m"; $TXT_CLEAR="$esc[0m"
  script:
    - Write-Host $TXT_RED"This text is red,"$TXT_CLEAR" but this text isn't"$TXT_RED" however this text is red again."
    - Write-Host "This text is not colored"
```