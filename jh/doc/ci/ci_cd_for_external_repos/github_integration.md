---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 将您的 GitHub 代码仓库连接到极狐GitLab CI/CD。
title: 将极狐GitLab CI/CD 与 GitHub 代码仓库配合使用
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

通过创建 [CI/CD 项目](_index.md)将您的 GitHub 代码仓库连接到极狐GitLab，即可将极狐GitLab CI/CD 与 **GitHub.com** 和 **GitHub Enterprise** 配合使用。

> [!note]
> 由于 [GitHub 的限制](https://gitlab.com/gitlab-org/gitlab/-/issues/9147)，
> [GitHub OAuth](../../integration/github.md#enable-github-oauth-in-gitlab)
> 无法用于将 GitHub 作为外部 CI/CD 代码仓库进行身份验证。

<a id="connect-with-personal-access-token"></a>

## 使用个人访问令牌连接

个人访问令牌只能用于将 GitHub.com 代码仓库连接到极狐GitLab，并且该 GitHub 用户必须具有[所有者角色](https://docs.github.com/en/get-started/learning-about-github/access-permissions-on-github)。

要使用 GitHub 执行一次性授权，以授予极狐GitLab 访问您的代码仓库的权限：

1. 在 GitHub 中，创建一个令牌：
   1. 打开 <https://github.com/settings/tokens/new>。
   1. 创建一个个人访问令牌。
   1. 输入 **令牌描述**，并将范围更新为允许
      `repo` 和 `admin:repo_hook`，以便极狐GitLab 可以访问您的项目、
      更新提交状态，并创建一个 Webhook 以在有新提交时通知极狐GitLab。
1. 在极狐GitLab 中，创建一个项目：
   1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建项目/仓库**。
   1. 选择 **为外部仓库运行 CI/CD**。
   1. 选择 **GitHub**。
   1. 在 **个人访问令牌**中，粘贴该令牌。
   1. 选择 **列出仓库**。
   1. 选择 **连接** 以选择代码仓库。
1. 在 GitHub 中，添加一个 `.gitlab-ci.yml` 以[配置极狐GitLab CI/CD](../quick_start/_index.md)。

极狐GitLab：

1. 导入该项目。
1. 启用[拉取镜像](../../user/project/repository/mirror/pull.md)。
1. 启用 [GitHub 项目集成](../../user/project/integrations/github.md)。
1. 在 GitHub 上创建一个 Webhook，以在有新提交时通知极狐GitLab。

<a id="connect-manually"></a>

## 手动连接

要将 **GitHub Enterprise** 与 **JihuLab.com** 配合使用，请使用此方法。

要为您的代码仓库手动启用极狐GitLab CI/CD：

1. 在 GitHub 中，创建一个令牌：
   1. 打开 <https://github.com/settings/tokens/new>。
   1. 创建一个个人访问令牌。
   1. 输入 **令牌描述**，并将范围更新为允许
      `repo`，以便极狐GitLab 可以访问您的项目并更新提交状态。
1. 在极狐GitLab 中，创建一个项目：
   1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建项目/仓库**。
   1. 选择 **为外部仓库运行 CI/CD** 和 **仓库（URL）**。
   1. 在 **Git 仓库 URL** 字段中，输入您的 GitHub 代码仓库的 HTTPS URL。
      如果您的项目是私有的，请使用您刚刚创建的个人访问令牌进行身份验证。
   1. 填写所有其他字段并选择 **新建项目**。
      极狐GitLab 会自动配置基于轮询的拉取镜像。
1. 在极狐GitLab 中，启用 [GitHub 项目集成](../../user/project/integrations/github.md)：
   1. 在左侧边栏中，选择**设置** > **集成**。
   1. 选中**活跃**复选框。
   1. 将您的个人访问令牌和 HTTPS 代码仓库 URL 粘贴到表单中，然后选择 **保存**。
1. 在极狐GitLab 中，创建一个具有 `API` 范围的个人访问令牌，
   以对通知极狐GitLab 有新提交的 GitHub Webhook 进行身份验证。
1. 在 GitHub 中，从 **Settings** > **Webhooks** 创建一个 Webhook，以在有新提交时
   通知极狐GitLab。

   Webhook URL 应设置为极狐GitLab API，以
   [触发拉取镜像](../../api/project_pull_mirroring.md#start-the-pull-mirroring-process-for-a-project)，
   并使用您刚刚创建的极狐GitLab 个人访问令牌：

   ```plaintext
   https://jihulab.com/api/v4/projects/<NAMESPACE>%2F<PROJECT>/mirror/pull?private_token=<PERSONAL_ACCESS_TOKEN>
   ```

   选择 **让我选择单个事件** 选项，然后选中 **拉取请求** 和 **推送** 复选框。这些设置是[外部拉取请求的流水线](_index.md#pipelines-for-external-pull-requests)所需要的。

1. 在 GitHub 中，添加一个 `.gitlab-ci.yml` 以配置极狐GitLab CI/CD。
