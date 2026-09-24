---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在任务脚本中使用 CI/CD 变量
description: Configuration, usage, and security.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

所有 CI/CD 变量都会在任务环境中被设置为环境变量。你可以按照每种环境 shell 的标准格式在任务脚本中使用这些变量。

要访问环境变量，请根据你的 [Runner 执行器的 shell](https://gitlab.cn/docs/runner/executors/) 使用相应语法。

<a id="with-bash-and-sh"></a>

## 使用 Bash 和 `sh`

要在 Bash、`sh` 及类似 shell 中访问环境变量，请在 CI/CD 变量前加上 `$`：

```yaml
job_name:
  script:
    - echo "$CI_JOB_ID"
```

<a id="with-powershell"></a>

## 使用 PowerShell

要在 Windows PowerShell 环境中访问变量（包括系统设置的环境变量），请在变量名前加上 `$env:` 或 `$`：

```yaml
job_name:
  script:
    - echo $env:CI_JOB_ID
    - echo $CI_JOB_ID
    - echo $env:PATH
```

<a id="with-windows-batch"></a>

## 使用 Windows Batch

要在 Windows Batch 中访问 CI/CD 变量，请用 `%` 包围变量：

```yaml
job_name:
  script:
    - echo %CI_JOB_ID%
```

你还可以用 `!` 包围变量以实现[延迟扩展](https://ss64.com/nt/delayedexpansion.html)。如果变量包含空格或换行符，可能需要使用延迟扩展：

```yaml
job_name:
  script:
    - echo !ERROR_MESSAGE!
```

<a id="in-service-containers"></a>

## 在服务容器中

[服务容器](../docker/using_docker_images.md)可以使用 CI/CD 变量，但默认情况下只能访问[保存在 `.gitlab-ci.yml` 文件中的变量](_index.md#define-a-cicd-variable-in-the-gitlab-ciyml-file)。[在极狐GitLab UI 中添加的变量](_index.md#define-a-cicd-variable-in-the-ui)对服务容器不可用，因为默认情况下服务容器不受信任。

要让服务容器能够使用在 UI 中定义的变量，你可以在 `.gitlab-ci.yml` 中将其重新赋值给另一个变量：

```yaml
variables:
  SA_PASSWORD_YAML_FILE: $SA_PASSWORD_UI
```

重新赋值的变量不能与原始变量同名，否则它将无法展开。

<a id="prevent-parsing-errors"></a>

## 防止解析错误

为脚本命令和变量值加上引号，以防止 YAML 和 shell 解析错误：

- 对包含冒号（`:`）的整个命令加引号，以防止 YAML 将其解释为键值对：

  ```yaml
  job_name:
    script:
      - 'echo "Status: Complete"'  # Single quotes prevent YAML colon parsing
  ```

- 当变量值可能包含空格或特殊字符时，为变量加引号：

  ```yaml
  job_name:
    script:
      - echo "$FILE_PATH"          # Quote if FILE_PATH might have spaces
  ```

- 当你希望变量被展开为单独的 shell 参数时，避免加引号：

  ```yaml
  job_name:
    variables:
      COMPILE_FLAGS: "-Wall -Werror -O2"
    script:
      - gcc $COMPILE_FLAGS main.c  # Expands to: gcc -Wall -Werror -O2 main.c
  ```

<a id="pass-an-environment-variable-from-the-script-section-to-artifacts-or-cache"></a>

## 将环境变量从 `script` 部分传递到 `artifacts` 或 `cache`

{{< history >}}

- 于极狐GitLab 16.4 引入。

{{< /history >}}

使用 `$GITLAB_ENV` 可以在 `artifacts` 或 `cache` 关键字中使用在 `script` 部分定义的环境变量。例如：

```yaml
build-job:
  stage: build
  script:
    - echo "ARCH=$(arch)" >> $GITLAB_ENV
    - touch some-file-$(arch)
  artifacts:
    paths:
      - some-file-$ARCH
```

<a id="store-multiple-values-in-one-variable"></a>

## 在一个变量中存储多个值

你无法创建值是数组的 CI/CD 变量，但可以使用 shell 脚本技巧来实现类似的行为。

例如，你可以在一个变量中存储用空格分隔的多个值，然后通过脚本遍历这些值：

```yaml
job1:
  variables:
    FOLDERS: src test docs
  script:
    - |
      for FOLDER in $FOLDERS
        do
          echo "The path is root/${FOLDER}"
        done
```

<a id="use-cicd-variables-in-other-variables"></a>

## 在其他变量中使用 CI/CD 变量

你可以在其他变量中使用变量：

```yaml
job:
  variables:
    FLAGS: '-al'
    LS_CMD: 'ls "$FLAGS"'
  script:
    - 'eval "$LS_CMD"'  # Executes 'ls -al'
```

<a id="as-part-of-a-string"></a>

### 作为字符串的一部分

你可以将变量用作字符串的一部分。你可以用花括号（`{}`）包围变量，以帮助区分变量名和周围文本。如果不使用花括号，相邻文本会被视为变量名的一部分。例如：

```yaml
job:
  variables:
    FLAGS: '-al'
    DIR: 'path/to/directory'
    LS_CMD: 'ls "$FLAGS"'
    CD_CMD: 'cd "${DIR}_files"'
  script:
    - 'eval "$LS_CMD"'  # Executes 'ls -al'
    - 'eval "$CD_CMD"'  # Executes 'cd path/to/directory_files'
```

<a id="use-the-dollar-character-in-cicd-variables"></a>

### 在 CI/CD 变量中使用 `$` 字符

如果你不希望 `$` 字符被解释为另一个变量的起始，可以使用 `$$` 代替：

```yaml
job:
  variables:
    FLAGS: '-al'
    LS_CMD: 'ls "$FLAGS" $$TMP_DIR'
  script:
    - 'eval "$LS_CMD"'  # Executes 'ls -al $TMP_DIR'
```

这在[将 CI/CD 变量传递给下游流水线](../pipelines/downstream_pipelines_troubleshooting.md#variable-with--character-does-not-get-passed-to-a-downstream-pipeline-properly)时不起作用。

<a id="related-topics"></a>

## 相关主题

- [使用 dotenv 将环境变量传递给后续任务](dotenv_variables.md#pass-variables-to-later-jobs)

