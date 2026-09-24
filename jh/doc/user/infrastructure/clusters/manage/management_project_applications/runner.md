---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用集群管理项目安装极狐GitLab Runner
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

假设你已经使用[管理项目模板](../../../../clusters/management_project_template.md)创建了一个项目，要安装极狐GitLab Runner，你应该在 `helmfile.yaml` 中取消注释这一行：

```yaml
  - path: applications/gitlab-runner/helmfile.yaml
```

极狐GitLab Runner 默认安装到你集群的 `gitlab-managed-apps` 命名空间中。

<a id="required-variables"></a>

## 必需的变量

要让极狐GitLab Runner 正常工作，你必须在 `applications/gitlab-runner/values.yaml.gotmpl` 文件中指定以下内容：

- `gitlabUrl`：极狐GitLab 服务器的完整 URL（例如 `https://gitlab.example.com`），用于注册 Runner。
- Runner 令牌：必须从你的极狐GitLab 实例[获取](../../../../../ci/runners/_index.md)。你可以使用以下任一令牌：

  - `runnerToken`：用于在[极狐GitLab UI 中创建](../../../../../ci/runners/runners_scope.md)的 runner 配置的 runner 认证令牌。
  - `runnerRegistrationToken`（在 GitLab 15.6 中[已弃用](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/102681)，并计划在 GitLab 20.0 中移除）：用于向极狐GitLab 添加新 runner 的注册令牌。

这些值可以使用 [CI/CD 变量](../../../../../ci/variables/_index.md) 指定：

- `CI_SERVER_URL` 用于 `gitlabUrl`。如果你使用的是 JihuLab.com，则无需设置此变量。
- `GITLAB_RUNNER_TOKEN` 用于 `runnerToken`。
- `GITLAB_RUNNER_REGISTRATION_TOKEN` 用于 `runnerRegistrationToken`（已弃用）。

指定这些值的方法互斥。你可以选择：

- 将变量 `GITLAB_RUNNER_TOKEN` 和 `CI_SERVER_URL` 作为 CI 变量指定（推荐）。
- 在 `applications/gitlab-runner/values.yaml.gotmpl` 中为 `runnerToken:` 和 `gitlabUrl:` 提供值。

runner 注册令牌允许 runner 连接到项目。请将其视为密钥，以防止通过 runner 进行恶意使用和代码泄露。将 runner 注册令牌指定为[受保护的变量](../../../../../ci/variables/_index.md#protect-a-cicd-variable)和[掩码变量](../../../../../ci/variables/_index.md#mask-a-cicd-variable)。不要将令牌提交到 `values.yaml.gotmpl` 文件中的 Git 仓库。

你可以通过在集群管理项目中定义 `applications/gitlab-runner/values.yaml.gotmpl` 文件来自定义极狐GitLab Runner 的安装。有关可用的配置选项，请参阅 [chart](https://jihulab.com/gitlab-cn/charts/gitlab-runner)。