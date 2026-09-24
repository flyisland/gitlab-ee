---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Connect your GitHub repository to GitLab CI/CD.
title: 使用极狐GitLab CI/CD 与 GitHub 仓库
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab CI/CD 可通过创建[CI/CD 项目](_index.md)将 GitHub 仓库连接到极狐GitLab，来与 **GitHub.com** 和 **GitHub 企业版** 配合使用。

> [!note]
> 由于 [GitHub 限制](https://jihulab.com/gitlab-cn/gitlab/-/issues/9147)，
> [GitHub OAuth](../../integration/github.md#enable-github-oauth-in-gitlab)
> 不能用作外部 CI/CD 仓库对 GitHub 进行身份验证。

<a id="connect-with-personal-access-token"></a>

## 使用个人访问令牌连接

个人访问令牌仅可用于将 GitHub.com 仓库连接到极狐GitLab，并且 GitHub 用户必须具有[所有者角色](https://docs.github.com/en/get-started/learning-about-github/access-permissions-on-github)。

要执行一次性授权以授予极狐GitLab 访问你的仓库的权限：

1. 在 GitHub 中，创建一个令牌：
   1. 打开 <https://github.com/settings/tokens/new>。
   1. 创建一个个人访问令牌。
   1. 输入 **令牌描述** 并将作用域更新为允许
      `repo` 和 `admin:repo_hook`，以便极狐GitLab 可以访问你的项目、
      更新提交状态并创建 Webhook 以通知极狐GitLab 有新的提交。
1. 在极狐GitLab 中，创建一个项目：
   1. 在右上角，选择 **新建**（{{< icon name="plus" >}}）和 **新项目/代码仓**。
   1. 选择 **运行外部仓库的 CI/CD**。
   1. 选择 **GitHub**。
   1. 在 **个人访问令牌** 中，粘贴令牌。
   1. 选择 **列出仓库**。
   1. 选择 **连接** 以选择仓库。
1. 在 GitHub 中，添加一个 `.gitlab-ci.yml` 来[配置极狐GitLab CI/CD](../quick_start/_index.md)。

极狐GitLab：

1. 导入项目。
1. 启用[拉取镜像](../../user/project/repository/mirror/pull.md)。
1. 启用 [GitHub 项目集成](../../user/project/integrations/github.md)。
1. 在 GitHub 上创建 Webhook 以通知极狐GitLab 有新的提交。

<a id="connect-manually"></a>

## 手动连接

要将 **GitHub 企业版** 与 **JihuLab.com** 配合使用，请使用此方法。

要手动为你的仓库启用极狐GitLab CI/CD：

1. 在 GitHub 中，创建一个令牌：
   1. 打开 <https://github.com/settings/tokens/new>。
   1. 创建一个个人访问令牌。
   1. 输入 **令牌描述** 并将作用域更新为允许
      `repo`，以便极狐GitLab 可以访问你的项目并更新提交状态。
1. 在极狐GitLab 中，创建一个项目：
   1. 在右上角，选择 **新建**（{{< icon name="plus" >}}）和 **新项目/代码仓**。
   1. 选择 **运行外部仓库的 CI/CD** 和 **通过 URL 创建仓库**。
   1. 在 **Git 仓库 URL** 字段中，输入你的 GitHub 仓库的 HTTPS URL。
      如果你的项目是私有的，请使用你刚刚创建的个人访问令牌进行身份验证。
   1. 填写所有其他字段，然后选择 **创建项目**。
      极狐GitLab 会自动配置基于轮询的拉取镜像。
1. 在极狐GitLab 中，启用 [GitHub 项目集成](../../user/project/integrations/github.md)：
   1. 在左侧边栏中，选择 **设置** > **集成**。
   1. 选中 **激活** 复选框。
   1. 将你的个人访问令牌和 HTTPS 仓库 URL 粘贴到表单中，然后选择 **保存**。
1. 在极狐GitLab 中，创建一个具有 `API` 作用域的个人访问令牌，
   用于对通知极狐GitLab 新提交的 GitHub Webhook 进行身份验证。
1. 在 GitHub 中，从 **设置** > **Webhooks**，创建一个 Webhook 以通知极狐GitLab 新的提交。

   Webhook URL 应设置为极狐GitLab API，以
   [触发拉取镜像](../../api/project_pull_mirroring.md#start-the-pull-mirroring-process-for-a-project)，
   并使用你刚创建的极狐GitLab 个人访问令牌：

   ```plaintext
   https://jihulab.com/api/v4/projects/<NAMESPACE>%2F<PROJECT>/mirror/pull?private_token=<PERSONAL_ACCESS_TOKEN>
   ```

   选择 **让我选择单个事件** 选项，然后选中 **拉取请求** 和 **推送** 复选框。这些设置是[外部拉取请求流水线](_index.md#pipelines-for-external-pull-requests)所需要的。

1. 在 GitHub 中，添加一个 `.gitlab-ci.yml` 来配置极狐GitLab CI/CD。