---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use Git submodules to include code from other repositories in CI/CD pipelines with relative URLs, absolute URLs, and CI/CD variables.
title: 在极狐GitLab CI/CD 中使用 Git 子模块
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 [Git 子模块](https://git-scm.com/book/en/v2/Git-Tools-Submodules) 将一个 Git 仓库作为另一个 Git 仓库的子目录。你可以将另一个仓库克隆到你的项目中，并保持提交记录独立。

<a id="configure-the-gitmodules-file"></a>

## 配置 `.gitmodules` 文件

使用 Git 子模块时，你的项目应该有一个名为 `.gitmodules` 的文件。你有多种配置选项使其在极狐GitLab CI/CD 作业中正常工作。

<a id="using-absolute-urls"></a>

### 使用绝对 URL

{{< history >}}

- 在极狐GitLab Runner 15.11 中引入。

{{< /history >}}

例如，如果满足以下条件，你生成的 `.gitmodules` 配置可能如下所示：
- 你的项目位于 `https://gitlab.com/secret-group/my-project`。
- 你的项目依赖于 `https://gitlab.com/group/project`，你想将其作为子模块包含。
- 你使用 SSH 地址（如 `git@gitlab.com:secret-group/my-project.git`）检出源代码。

```ini
[submodule "project"]
  path = project
  url = git@gitlab.com:group/project.git
```

在这种情况下，使用 [`GIT_SUBMODULE_FORCE_HTTPS`](configure_runners.md#rewrite-submodule-urls-to-https) 变量指示极狐GitLab Runner 在克隆子模块之前将 URL 转换为 HTTPS。

或者，如果你在本地也使用 HTTPS，可以配置 HTTPS URL：

```ini
[submodule "project"]
  path = project
  url = https://gitlab.com/group/project.git
```

在这种情况下，你无需配置额外的变量，但需要使用[个人访问令牌](../../user/profile/personal_access_tokens.md)在本地克隆它。

<a id="using-relative-urls"></a>

### 使用相对 URL

> [!warning]
> 如果你使用相对 URL，子模块在派生工作流中可能解析不正确。
> 如果你的项目预期会有派生，请改用绝对 URL。

当你的子模块位于同一极狐GitLab 服务器上时，你也可以在 `.gitmodules` 文件中使用相对 URL：

```ini
[submodule "project"]
  path = project
  url = ../../project.git
```

上述配置指示 Git 在克隆源代码时自动推断要使用的 URL。你可以在所有 CI/CD 作业中使用 HTTPS 进行克隆，并继续使用 SSH 在本地克隆。

对于不在同一极狐GitLab 服务器上的子模块，始终使用完整 URL：

```ini
[submodule "project-x"]
  path = project-x
  url = https://gitserver.com/group/project-x.git
```

<a id="use-git-submodules-in-cicd-jobs"></a>

## 在 CI/CD 作业中使用 Git 子模块

先决条件：

- 如果你使用 [`CI_JOB_TOKEN`](../jobs/ci_job_token.md) 在流水线作业中克隆子模块，你必须对子模块仓库具有报告者、开发者、维护者或所有者角色才能拉取代码。
- 必须在上游子模块项目中正确配置 [CI/CD 作业令牌访问](../jobs/ci_job_token.md#control-job-token-access-to-your-project)。

要使子模块在 CI/CD 作业中正常工作：

1. 你可以将 `GIT_SUBMODULE_STRATEGY` 变量设置为 `normal` 或 `recursive`，以告知 runner [在作业前获取你的子模块](configure_runners.md#git-submodule-strategy)：

   ```yaml
   variables:
     GIT_SUBMODULE_STRATEGY: recursive
   ```

1. 对于位于同一极狐GitLab 服务器上且配置了 Git 或 SSH URL 的子模块，请确保设置 [`GIT_SUBMODULE_FORCE_HTTPS`](configure_runners.md#rewrite-submodule-urls-to-https) 变量。

1. 使用 `GIT_SUBMODULE_DEPTH` 独立于 [`GIT_DEPTH`](configure_runners.md#shallow-cloning) 变量配置子模块的克隆深度：

   ```yaml
   variables:
     GIT_SUBMODULE_DEPTH: 1
   ```

1. 你可以使用 [`GIT_SUBMODULE_PATHS`](configure_runners.md#sync-or-exclude-specific-submodules-from-ci-jobs) 过滤或排除特定子模块，以控制同步哪些子模块。

   ```yaml
   variables:
     GIT_SUBMODULE_PATHS: submoduleA submoduleB
   ```

1. 你可以使用 [`GIT_SUBMODULE_UPDATE_FLAGS`](configure_runners.md#git-submodule-update-flags) 提供额外的标志来控制高级检出行为。

   ```yaml
   variables:
     GIT_SUBMODULE_STRATEGY: recursive
     GIT_SUBMODULE_UPDATE_FLAGS: --jobs 4
   ```

<a id="check-out-nested-submodules"></a>

### 检出嵌套子模块

{{< history >}}

- 在极狐GitLab Runner 18.6 中引入。

{{< /history >}}

嵌套子模块是包含自身子模块的子模块。你可能只需要检出特定的嵌套子模块，而不是仓库中的所有子模块。

极狐GitLab Runner 18.6 及更高版本将 Git 配置（包括凭据）外部化到单独的文件中，以避免污染构建目录。当你进入子模块目录并运行 Git 命令时，主仓库的配置会根据 `GIT_SUBMODULE_STRATEGY` 自动继承给所有子模块：

- 如果使用 `GIT_SUBMODULE_STRATEGY: normal`，则初始化顶级子模块。
- 如果使用 `GIT_SUBMODULE_STRATEGY: recursive`，则初始化所有嵌套子模块。

要检出嵌套子模块的子集：

1. 将 `GIT_SUBMODULE_STRATEGY` 设置为 `normal`：

   ```yaml
      variables:
        GIT_SUBMODULE_STRATEGY: normal
   ```

1. 在你的作业中，显式传递外部化配置：

   ```yaml
      my-job:
        script:
          - git submodule sync
          - git submodule update --init
          - cd path/to/submodule-with-nested-submodule
          - git -c "include.path=$(git -C $CI_PROJECT_DIR config include.path)" submodule update --init nested-submodule
   ```

`git -C $CI_PROJECT_DIR config include.path` 命令从主仓库检索外部化配置文件的路径。这确保在检出嵌套子模块时凭据和其他设置可用。

<a id="use-submodules-from-another-gitlab-instance"></a>

## 从另一个极狐GitLab 实例使用子模块

当你的子模块托管在与主项目不同的极狐GitLab 实例上时，当前实例的 `CI_JOB_TOKEN` 无法向外部实例进行身份验证。你必须使用在外部实例上创建的令牌进行身份验证。

你有两种主要方法向外部极狐GitLab 实例进行身份验证：

- URL 重写：修改 Git URL 以包含身份验证凭据。
- Git 凭据助手：存储 Git 在需要时自动使用的凭据。

你选择的身份验证方法取决于你的极狐GitLab Runner 执行器类型：

- 容器化执行器（Docker 或 Kubernetes）：每个作业在隔离的容器中运行，因此全局 Git 配置更改仅影响当前作业，并在容器销毁时自动清理。

- Shell 执行器：作业直接在 runner 主机系统上运行，因此全局 Git 配置更改在作业之间持久存在。如果不同作业使用不同的凭据，这可能导致身份验证冲突。

> [!warning]
> 使用 shell 执行器时，避免使用持久化身份验证凭据的 `git config --global` 命令。这些设置在作业之间保持活动状态，如果不同作业使用不同的凭据，可能导致身份验证失败或安全问题。

你可以使用以下令牌类型之一：

- [个人访问令牌](../../user/profile/personal_access_tokens.md)
- [部署令牌](../../user/project/deploy_tokens/_index.md)
- [项目访问令牌](../../user/project/settings/project_access_tokens.md)

<a id="configure-authentication-with-url-rewriting"></a>

### 使用 URL 重写配置身份验证

要使用 URL 重写配置身份验证：

1. 在你的 `.gitmodules` 文件中，为子模块使用绝对 HTTPS URL：

   ```ini
   [submodule "external-project"]
     path = external-project
     url = https://other-gitlab.example.com/group/project.git
   ```

1. 在外部极狐GitLab 实例上，创建一个具有 `read_repository` 范围的令牌。
1. 在你的主项目中，将令牌添加为[掩码 CI/CD 变量](../variables/_index.md#mask-a-cicd-variable)。例如，将其命名为 `EXTERNAL_GITLAB_TOKEN`。
1. 在你的 `.gitlab-ci.yml` 文件中，根据你的执行器类型配置身份验证：

   对于容器化执行器（Docker 或 Kubernetes）：

   ```yaml
   variables:
     GIT_SUBMODULE_STRATEGY: recursive

   my-job:
     before_script:
       - git config --global url."https://<username>:${EXTERNAL_GITLAB_TOKEN}@other-gitlab.example.com/".insteadOf "https://other-gitlab.example.com/"
     script:
       - echo "Submodules are fetched with authentication"
       - ls -la external-project/
   ```

   对于 shell 执行器：

   ```yaml
   variables:
     GIT_SUBMODULE_STRATEGY: none

   my-job:
     before_script:
       - parent_include_path=$(git -C $CI_PROJECT_DIR config include.path)
       - git -c "include.path=${parent_include_path}" -c "url.https://<username>:${EXTERNAL_GITLAB_TOKEN}@other-gitlab.example.com/.insteadOf=https://other-gitlab.example.com/" submodule update --init --recursive --force
     script:
       - echo "Submodules are fetched with authentication"
       - ls -la external-project/
   ```

   将 `<username>` 替换为与令牌关联的极狐GitLab 用户名。

   要仅为容器化执行器中的所有作业全局配置身份验证：

   ```yaml
   hooks:
     pre_get_sources_script:
       - git config --global url."https://<username>:${EXTERNAL_GITLAB_TOKEN}@other-gitlab.example.com/".insteadOf "https://other-gitlab.example.com/"
   ```

<a id="configure-authentication-with-git-credential-helper"></a>

### 使用 Git 凭据助手配置身份验证

要使用 Git 凭据助手配置身份验证：

1. 在外部极狐GitLab 实例上，创建一个具有 `read_repository` 范围的令牌。
1. 在你的主项目中，将令牌添加为[掩码 CI/CD 变量](../variables/_index.md#mask-a-cicd-variable)。例如，将其命名为 `EXTERNAL_GITLAB_TOKEN`。
1. 在你的 `.gitlab-ci.yml` 文件中，根据你的执行器类型配置凭据助手：

   对于容器化执行器（Docker 或 Kubernetes）：

   ```yaml
   my-job:
     before_script:
       - git config --global credential.helper store
       - echo "https://<username>:${EXTERNAL_GITLAB_TOKEN}@other-gitlab.example.com" >> ~/.git-credentials
     script:
       - echo "Submodules are fetched with authentication"
       - ls -la external-project/
   ```

   对于 shell 执行器：

   ```yaml
   my-job:
     before_script:
       - TEMP_CREDS=$(mktemp)
       - echo "https://<username>:${EXTERNAL_GITLAB_TOKEN}@other-gitlab.example.com" > "$TEMP_CREDS"
       - git config credential.helper "store --file=$TEMP_CREDS"
       - trap "rm -f $TEMP_CREDS" EXIT
     script:
       - echo "Submodules are fetched with authentication"
       - ls -la external-project/
   ```

   将 `<username>` 替换为与令牌关联的极狐GitLab 用户名。

<a id="troubleshooting"></a>

## 故障排除

<a id="cant-find-the-gitmodules-file"></a>

### 找不到 `.gitmodules` 文件

`.gitmodules` 文件可能很难找到，因为它通常是一个隐藏文件。你可以查看特定操作系统的文档，了解如何查找和显示隐藏文件。

如果没有 `.gitmodules` 文件，则子模块设置可能位于 [`git config`](https://www.atlassian.com/git/tutorials/setting-up-a-repository/git-config) 文件中。

<a id="error-fatal-run_command-returned-non-zero-status"></a>

### 错误：`fatal: run_command returned non-zero status`

当使用子模块且 `GIT_STRATEGY` 设置为 `fetch` 时，作业中可能会发生此错误。

将 `GIT_STRATEGY` 设置为 `clone` 应该可以解决此问题。

<a id="fatal:-could-not-read-username-for-'https://gitlab.com':-no-such-device-or-address"></a>

### 错误：`fatal: could not read Username for 'https://jihulab.com': No such device or address`

当你的 CI/CD 作业尝试克隆、获取或执行其他与子模块相关的 Git 操作时，可能会遇到此错误。
此问题发生在以下情况：

- 从子模块目录内运行 Git 命令（如 `git fetch`），因为外部化的 Git 配置可能不会自动继承给所有 Git 操作。
- 使用嵌套子模块，因为极狐GitLab Runner 18.6 及更高版本外部化 Git 配置，这些配置可能不会自动被子模块继承。
- 使用极狐GitLab 托管的 runner，且子模块引用了 `https://gitlab.com`，因为 `CI_SERVER_FQDN` 与 `gitlab.com` 不同。
  极狐GitLab Runner 在初始检出期间自动执行 Git URL 替换，但这可能不适用于子模块目录内的后续 Git 操作。

要解决此问题：

- 对于嵌套子模块，请参阅[检出嵌套子模块](#check-out-nested-submodules)。
- 对于子模块目录内的 Git 操作，显式传递外部化配置：

  ```yaml
    my-job:
      script:
        - cd path/to/submodule
        - git -c "include.path=$(git -C $CI_PROJECT_DIR config include.path)" fetch origin
  ```

- 对于极狐GitLab 托管的 runner 或在子模块内有多个 Git 操作的作业，
  使用 `CI_JOB_TOKEN` 配置 URL 替换：

  ```yaml
  my-job:
    script:
      - cd path/to/submodule
      - git -c "include.path=$(git -C $CI_PROJECT_DIR config include.path)" -c "url.https://gitlab-ci-token:${CI_JOB_TOKEN}@${CI_SERVER_FQDN}/.insteadOf=https://gitlab.com/" fetch origin
  ```

  有关执行器特定的配置选项，请参阅[从另一个极狐GitLab 实例使用子模块](#use-submodules-from-another-gitlab-instance)。