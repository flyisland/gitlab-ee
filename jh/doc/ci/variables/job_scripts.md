---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在作业脚本中使用 CI/CD 变量
description: 配置、用法和安全。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

所有 CI/CD 变量都会在作业环境中设置为环境变量。您可以在作业脚本中使用变量，具体格式取决于各环境的 shell。

要访问环境变量，请使用您的 [runner 执行器的 shell](https://gitlab.cn/docs/runner/executors/) 对应的语法。

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

要在 Windows Batch 中访问 CI/CD 变量，请在变量两侧加上 `%`：

```yaml
job_name:
  script:
    - echo %CI_JOB_ID%
```

您也可以在变量两侧加上 `!` 以使用[延迟展开](https://ss64.com/nt/delayedexpansion.html)。对于包含空格或换行符的变量，可能需要使用延迟展开：

```yaml
job_name:
  script:
    - echo !ERROR_MESSAGE!
```

<a id="in-service-containers"></a>

## 在服务容器中

[服务容器](../docker/using_docker_images.md)可以使用 CI/CD 变量，但默认只能访问[保存在 `.gitlab-ci.yml` 文件中的变量](_index.md#define-a-cicd-variable-in-the-gitlab-ciyml-file)。[在极狐GitLab UI 中添加的变量](_index.md#define-a-cicd-variable-in-the-ui)对服务容器不可用，因为服务容器默认不受信任。

要使 UI 中定义的变量在服务容器中可用，您可以在 `.gitlab-ci.yml`中将其重新赋值给另一个变量：

```yaml
variables:
  SA_PASSWORD_YAML_FILE: $SA_PASSWORD_UI
```

重新赋值的变量不能与原始变量同名。否则它不会被展开。

<a id="prevent-parsing-errors"></a>

## 防止解析错误

为脚本命令和变量值加引号，以防止 YAML 和 shell 解析错误：

- 当整个命令包含冒号（`:`）时，为其加引号，以防止 YAML 将其解释为键值对：

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

- 当您希望变量展开为多个独立的 shell 参数时，不要加引号：

  ```yaml
  job_name:
    variables:
      COMPILE_FLAGS: "-Wall -Werror -O2"
    script:
      - gcc $COMPILE_FLAGS main.c  # Expands to: gcc -Wall -Werror -O2 main.c
  ```

<a id="pass-an-environment-variable-from-the-script-section-to-artifacts-or-cache"></a>

## 将环境变量从 `script` 部分传递到 `artifacts` 或 `cache`

使用 `$GITLAB_ENV` 可以在 `artifacts` 或 `cache` 关键字中使用 `script` 部分中定义的环境变量。例如：

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

您无法创建值为数组的 CI/CD 变量，但可以使用 shell 脚本技巧实现类似行为。

例如，您可以将多个以空格分隔的值存储在一个变量中，然后通过脚本遍历这些值：

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

您可以在其他变量中使用变量：

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

您可以将变量用作字符串的一部分。您可以用花括号（`{}`）将变量括起来，以帮助区分变量名和周围的文本。如果不使用花括号，相邻文本会被解释为变量名的一部分。例如：

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

<a id="use-the--character-in-cicd-variables"></a>

### 在 CI/CD 变量中使用 `$` 字符

如果您不希望 `$` 字符被解释为另一个变量的开头，请改用 `$$`：

```yaml
job:
  variables:
    FLAGS: '-al'
    LS_CMD: 'ls "$FLAGS" $$TMP_DIR'
  script:
    - 'eval "$LS_CMD"'  # Executes 'ls -al $TMP_DIR'
```

当[将 CI/CD 变量传递给下游流水线](../pipelines/downstream_pipelines_troubleshooting.md#variable-with--character-does-not-get-passed-to-a-downstream-pipeline-properly)时，此方法无效。
