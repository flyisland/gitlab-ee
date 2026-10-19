---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 外部代码仓库的 CI/CD
description: 将极狐GitLab CI/CD 与 GitHub、Bitbucket 及其他外部代码仓库配合使用。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab CI/CD 可与 [GitHub](github_integration.md)、[Bitbucket Cloud](bitbucket_integration.md)
或任何其他 Git 服务器配合使用。存在一些[已知问题](#known-issues)。

无需将整个项目迁移到极狐GitLab，您可以连接外部代码仓库，从而享受极狐GitLab CI/CD 带来的优势。

连接外部代码仓库会设置[代码仓库镜像](../../user/project/repository/mirror/_index.md)，并创建一个轻量级项目，其中议题、合并请求、Wiki 和代码片段均处于禁用状态。这些功能[稍后可以重新启用](../../user/project/settings/_index.md#configure-project-features-and-permissions)。

<a id="connect-to-an-external-repository"></a>

## 连接到外部代码仓库

要连接到外部代码仓库：

1. 在右上角，选择**新建** ({{< icon name="plus" >}}) 和**新建项目/仓库**。
1. 选择**为外部仓库运行 CI/CD**。
1. 选择 **GitHub** 或**仓库（URL）**。
1. 填写相应字段。

如果**为外部代码仓库运行 CI/CD** 选项不可用：

- 极狐GitLab 实例可能未配置任何导入源。
  请让管理员检查[导入源配置](../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources)。
- [项目镜像](../../user/project/repository/mirror/_index.md)可能已禁用。
  如果已禁用，则只有管理员可以使用**为外部代码仓库运行 CI/CD** 选项。
  请让管理员检查[项目镜像配置](../../administration/settings/visibility_and_access_controls.md#enable-project-mirroring)。

<a id="pipelines-for-external-pull-requests"></a>

## 外部拉取请求的流水线

在将极狐GitLab CI/CD 与 [GitHub 上的外部代码仓库](github_integration.md)配合使用时，可以在拉取请求的上下文中运行流水线。

当您将更改推送到 GitHub 中的远程分支时，极狐GitLab CI/CD 可以为该分支运行流水线。但是，当您为该分支打开或更新拉取请求时，您可能希望：

- 运行额外的作业。
- 不运行特定作业。

例如：

```yaml
always-run:
  script: echo 'this should always run'

on-pull-requests:
  script: echo 'this should run on pull requests'
  rules:
    - if: $CI_PIPELINE_SOURCE == "external_pull_request_event"

except-pull-requests:
  script: echo 'This should not run for pull requests, but runs in other cases.'
  rules:
    - if: $CI_PIPELINE_SOURCE == "external_pull_request_event"
      when: never
    - when: on_success
```

<a id="pipeline-execution-for-external-pull-requests"></a>

### 外部拉取请求的流水线执行

当从 GitHub 导入代码仓库时，极狐GitLab 会订阅 `push` 和 `pull_request` 事件的 webhook。收到 `pull_request` 事件后，拉取请求数据会被存储并保留为引用。如果拉取请求刚刚创建，极狐GitLab 会立即为此外部拉取请求创建流水线。

如果更改被推送到拉取请求所引用的分支，且拉取请求仍处于打开状态，则会为此外部拉取请求创建流水线。

在这种情况下，极狐GitLab CI/CD 会创建 2 条流水线。一条用于分支推送，一条用于外部拉取请求。

拉取请求关闭后，即使有新更改推送到同一分支，也不会为此外部拉取请求创建流水线。

<a id="additional-predefined-variables"></a>

### 其他预定义变量

通过使用外部拉取请求的流水线，极狐GitLab 会向流水线作业公开其他[预定义变量](../variables/predefined_variables.md)。

这些变量名以 `CI_EXTERNAL_PULL_REQUEST_` 为前缀。

<a id="known-issues"></a>

### 已知问题

此功能不支持：

- GitHub Enterprise 所需的[手动连接方法](github_integration.md#connect-manually)。
  如果通过手动方式连接集成，外部拉取请求[不会触发流水线](https://gitlab.com/gitlab-org/gitlab/-/issues/323336#note_884820753)。
- 来自 fork 代码仓库的拉取请求。[来自 fork 代码仓库的拉取请求会被忽略](https://gitlab.com/gitlab-org/gitlab/-/issues/5667)。

鉴于极狐GitLab 会创建两条流水线，如果更改被推送到引用了某个打开的拉取请求的远程分支，这两条流水线都会通过 GitHub 集成影响该拉取请求的状态。如果您希望仅在外部拉取请求上运行流水线，而不在分支上运行，可以在作业定义中添加
`except: [branches]`。
[了解更多](https://gitlab.com/gitlab-org/gitlab/-/issues/24089#workaround)。

<a id="troubleshooting"></a>

## 故障排除

- [拉取镜像未触发流水线](../../user/project/repository/mirror/troubleshooting.md#pull-mirroring-is-not-triggering-pipelines)。
- [修复镜像时的硬失败](../../user/project/repository/mirror/pull.md#fix-hard-failures-when-mirroring)。
