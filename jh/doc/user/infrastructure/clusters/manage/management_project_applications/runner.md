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

假设您已经基于[管理项目模板](../../../../clusters/management_project_template.md)创建了项目，要安装极狐GitLab Runner，您应取消注释 `helmfile.yaml`中的以下行：

```yaml
  - path: applications/gitlab-runner/helmfile.yaml
```

极狐GitLab Runner 默认安装在集群的 `gitlab-managed-apps` 命名空间中。

<a id="required-variables"></a>

## 必需变量

要使极狐GitLab Runner 正常工作，您必须在 `applications/gitlab-runner/values.yaml.gotmpl` 文件中指定以下内容：

- `gitlabUrl`：用于注册 Runner 的极狐GitLab 服务器完整 URL（例如 `https://gitlab.example.com`）。
- Runner 令牌：必须从您的极狐GitLab 实例中[获取](../../../../../ci/runners/_index.md)。您可以使用以下任一令牌：

  - `runnerToken`：[在极狐GitLab UI 中创建](../../../../../ci/runners/runners_scope.md)的 Runner 配置的 Runner 身份验证令牌。
  - `runnerRegistrationToken`（在极狐GitLab 15.6 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/102681)，并计划在极狐GitLab 20.0 中移除。）：用于向极狐GitLab 添加新 Runner 的注册令牌。

这些值可以使用 [CI/CD 变量](../../../../../ci/variables/_index.md)指定：

- `CI_SERVER_URL` 用于 `gitlabUrl`。如果您使用 JihuLab.com，则无需设置此变量。
- `GITLAB_RUNNER_TOKEN` 用于 `runnerToken`。
- `GITLAB_RUNNER_REGISTRATION_TOKEN` 用于 `runnerRegistrationToken`（已弃用）。

指定这些值的方法互斥。您可以：

- 将变量 `GITLAB_RUNNER_TOKEN` 和 `CI_SERVER_URL` 指定为 CI 变量（推荐）。
- 在 `applications/gitlab-runner/values.yaml.gotmpl`中为 `runnerToken:` 和 `gitlabUrl:` 提供值。

Runner 注册令牌允许 Runner 连接到项目。请将其视为密钥，以防止恶意使用和通过 Runner 泄露代码。请将 Runner 注册令牌指定为[受保护变量](../../../../../ci/variables/_index.md#protect-a-cicd-variable)和[掩码变量](../../../../../ci/variables/_index.md#mask-a-cicd-variable)。请勿将令牌提交到 `values.yaml.gotmpl` 文件所在的 Git 代码仓库中。

您可以通过在集群管理项目中定义 `applications/gitlab-runner/values.yaml.gotmpl` 文件来自定义极狐GitLab Runner 的安装。有关可用的配置选项，请参阅
[chart](https://gitlab.com/gitlab-org/charts/gitlab-runner)。
