---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何编写极狐GitLab CI/CD `script` 部分，并使用特殊语法或配置改进作业日志。
title: 脚本和作业日志
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以在 [`script`](_index.md#script) 部分中使用特殊语法来：

- [将长命令拆分](#split-long-commands)为多行命令。
- [使用颜色代码](#add-color-codes-to-script-output)使作业日志更易于查看。
- [创建自定义可折叠部分](../jobs/job_logs.md#create-custom-collapsible-sections)
  以简化作业日志输出。

<a id="use-special-characters-with-script"></a>

## 在 `script`中使用特殊字符

有时，`script` 命令必须用单引号或双引号包裹。例如，包含冒号（`:`）的命令必须用单引号（`'`）包裹。YAML 解析器需要将该文本解释为字符串，而不是
“key: value”对。

例如，此脚本使用了冒号：

```yaml
job:
  script:
    - curl --request POST --header 'Content-Type: application/json' "https://gitlab.example.com/api/v4/projects"
```

要被视为有效的 YAML，您必须将整个命令用单引号包裹。如果该命令已经使用了单引号，则应尽可能将其改为双引号（`"`）：

```yaml
job:
  script:
    - 'curl --request POST --header "Content-Type: application/json" "https://gitlab.example.com/api/v4/projects"'
```

您可以使用 [CI Lint](lint.md) 工具验证语法是否有效。

使用以下字符时也要小心：

- `{`, `}`, `[`, `]`, `,`, `&`, `*`, `#`, `?`, `|`, `-`, `<`, `>`, `=`, `!`, `%`, `@`, `` ` ``。

<a id="ignore-non-zero-exit-codes"></a>

## 忽略非零退出码

当脚本命令返回非零退出码时，作业会失败，后续命令不会执行。

将退出码存储在变量中可避免此行为：

```yaml
job:
  script:
    - exit_code=0
    - false || exit_code=$?
    - if [ $exit_code -ne 0 ]; then echo "Previous command failed"; fi;
```

<a id="set-a-default-before_script-or-after_script-for-all-jobs"></a>

## 为所有作业设置默认的 `before_script` 或 `after_script`

您可以将 [`before_script`](_index.md#before_script) 和 [`after_script`](_index.md#after_script) 与 [`default`](_index.md#default) 一起使用：

- 将 `before_script` 与 `default` 一起使用，可定义一组默认命令，
  这些命令应在所有作业的 `script` 命令之前运行。
- 将 `after_script` 与 default 一起使用，可定义一组默认命令，
  这些命令应在任何作业完成或被取消后运行。

您可以通过在作业中定义不同的默认值来覆盖默认值。要忽略默认值，请使用 `before_script: []` 或 `after_script: []`：

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

## 如果作业被取消，则跳过 `after_script` 命令

如果作业在该作业的 `before_script` 或 `script` 部分运行期间被取消，[`after_script`](_index.md) 命令会运行。

在 `after_script` 执行期间，作业在 UI 中的状态为 `canceling`，并在 `after_script` 命令完成后变为 `canceled`。在 `after_script` 命令运行期间，预定义变量 `$CI_JOB_STATUS`的值为 `canceled`。

要防止在取消作业后运行 `after_script` 命令，请将 `after_script` 部分配置为：

1. 在 `after_script` 部分开始时检查 `$CI_JOB_STATUS` 预定义变量。
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

您可以使用 `|`（字面量）和 `>`（折叠）[YAML 多行块标量指示符](https://yaml-multiline.info/)将长命令拆分为多行命令，以提高可读性。

> [!warning]
> 如果将多个命令合并为一个命令字符串，则只会报告最后一个命令的
> 失败或成功。
> [由于一个缺陷，较早命令的失败会被忽略](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/25394)。
> 要变通解决此问题，请将每个命令作为单独的 `script` 项运行，或为每个命令字符串
> 添加一个 `exit 1` 命令。

您可以使用 `|`（字面量）YAML 多行块标量指示符，在作业描述的 `script` 部分中将命令写成多行。每一行都被视为单独的命令。作业日志中只会重复显示第一个命令，但其他命令仍会执行：

```yaml
job:
  script:
    - |
      echo "First command line."
      echo "Second command line."
      echo "Third command line."
```

上一个示例在作业日志中显示为：

```shell
$ echo First command line # collapsed multiline command
First command line
Second command line.
Third command line.
```

`>`（折叠）YAML 多行块标量指示符会将各部分之间的空行视为新命令的开始：

```yaml
job:
  script:
    - >
      echo "First command line
      is split over two lines."

      echo "Second command line."
```

其行为类似于不带 `>` 或 `|` 块标量指示符的多行命令：

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

当您省略 `>` 或 `|` 块标量指示符时，极狐GitLab 会将非空行连接起来形成命令。请确保这些行在连接后可以运行。

<!-- vale gitlab_base.MeaningfulLinkWords = NO -->

[Shell here 文档](https://en.wikipedia.org/wiki/Here_document)也适用于
`|` 和 `>` 操作符。以下示例将小写字母转写为大写：

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

## 为脚本输出添加颜色代码

可以使用 [8 位 ANSI 转义码](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit)为脚本输出着色，也可以通过运行输出 ANSI 转义码的命令或程序来实现。

例如，使用[带颜色代码的 Bash](https://misc.flogisoft.com/bash/tip_colors_and_formatting)：

```yaml
job:
  script:
    - echo -e "\e[31mThis text is red,\e[0m but this text isn't\e[31m however this text is red again."
```

您可以在 Shell 环境变量中定义颜色代码，甚至可以在 [CI/CD 变量](../variables/_index.md#define-a-cicd-variable-in-the-gitlab-ciyml-file)中定义，这会使命令更易于阅读和复用。

例如，使用上一个示例以及在 `before_script`中定义的环境变量：

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

24 位颜色代码[不受支持](https://gitlab.com/gitlab-org/gitlab/-/work_items/471530)。
