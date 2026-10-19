---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Release CLI 工具（已弃用）
---

<!--- start_remove The following content will be removed on remove_date: '2027-08-18' -->

> [!warning]
> 此功能已在极狐GitLab 18.0 中[弃用](https://gitlab.com/gitlab-org/cli/-/issues/7859)，
> 并计划在 20.0 中移除。请改用 [GitLab CLI](../../../editor_extensions/gitlab_cli/_index.md)。
>
> 此变更为破坏性变更。

<a id="migrate-from-release-cli-to-glab-cli"></a>

## 从 `release-cli` 迁移到 `glab` CLI

要根据您作业的配置从 `release-cli` 迁移到 `glab` CLI，请更新以下任一配置：

1. 如果您的作业使用 `release` 关键字，请更新为使用 `cli:latest` 镜像：

   ```yaml
   release_job:
     stage: release
     image: registry.gitlab.com/gitlab-org/cli:latest
     rules:
       - if: $CI_COMMIT_TAG
     script:
       - echo "Running the release job."
     release:
       tag_name: $CI_COMMIT_TAG
       name: 'Release $CI_COMMIT_TAG'
       description: 'Release created using the CLI.'
   ```

   有关更多信息，请参阅 [`release`](../../../ci/yaml/_index.md#release)。

1. 如果您的作业在 `script` 块中使用 `release-cli` 命令，请更新为使用 `glab release create`，
   并为 [Releases API](../../../api/releases/_index.md) 配置身份验证。

<a id="authenticate-with-the-cicd-job-token"></a>

### 使用 CI/CD 作业令牌进行身份验证

要使用 [`CI_JOB_TOKEN`](../../../ci/jobs/ci_job_token.md) 进行身份验证，请将 `GLAB_ENABLE_CI_AUTOLOGIN` 设置为 `true`。
`glab` CLI 会在 `JOB-TOKEN` 请求头中发送 `CI_JOB_TOKEN`，Releases API 会接受该请求头。

```yaml
release_job:
  stage: release
  image: registry.gitlab.com/gitlab-org/cli:latest
  rules:
    - if: $CI_COMMIT_TAG
  variables:
    GLAB_ENABLE_CI_AUTOLOGIN: "true"
  script:
    - |
      glab release create "$CI_COMMIT_TAG" \
      --name "Release $CI_COMMIT_TAG" \
      --notes "Release created with glab."
```

<a id="authenticate-with-an-access-token"></a>

### 使用访问令牌进行身份验证

要使用[个人](../../profile/personal_access_tokens.md)、
[项目](../settings/project_access_tokens.md)或
[群组](../../group/settings/group_access_tokens.md)访问令牌进行身份验证，
请将 `GITLAB_TOKEN` 设置为您的访问令牌。
该令牌必须具有 `api` 范围。

```yaml
release_job:
  stage: release
  image: registry.gitlab.com/gitlab-org/cli:latest
  rules:
    - if: $CI_COMMIT_TAG
  variables:
    GITLAB_TOKEN: $RELEASE_ACCESS_TOKEN
  script:
    - |
      glab release create "$CI_COMMIT_TAG" \
      --name "Release $CI_COMMIT_TAG" \
      --notes "Release created with glab."
```

> [!warning]
> 请勿将 `GITLAB_TOKEN` 设置为 `$CI_JOB_TOKEN`。
> `glab` CLI 会在 `PRIVATE-TOKEN` 请求头中发送 `GITLAB_TOKEN`，但 Releases API 仅接受 `JOB-TOKEN` 请求头中的作业令牌。
> 此组合会返回 `404 Not Found`。
> 要使用 CI/CD 作业令牌进行身份验证，请改为将 `GLAB_ENABLE_CI_AUTOLOGIN` 设置为 `true`。

有关完整选项列表，请参阅
[`glab release create`](https://gitlab.cn/docs/cli/release/create/) 命令参考。

<a id="fall-back-to-release-cli"></a>

## 回退到 `release-cli`

使用 `release` 关键字的 CI/CD 作业会使用一个脚本，如果 Runner 上没有所需的 `glab` 版本，
该脚本会回退到使用 `release-cli`。此回退逻辑是一种安全措施，
可确保尚未迁移到使用 `glab` CLI 的项目可以继续正常工作。

此回退[计划在极狐GitLab 20.0 中随 `release-cli` 的移除而删除](https://gitlab.com/gitlab-org/gitlab/-/issues/537919)。

<!--- end_remove -->
