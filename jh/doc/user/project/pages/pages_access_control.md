---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Pages 访问控制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- Pages 的群组 SAML SSO 支持 在 极狐GitLab 18.2 中被引入，附带一个名为 `ff_oauth_redirect_to_sso_login` 的功能标志。默认禁用。
- OAuth 应用的群组 SAML SSO 支持 在 极狐GitLab 18.3 中于 JihuLab.com 和私有化部署上启用。
- 在 极狐GitLab 18.5 中 GA。功能标志 `ff_oauth_redirect_to_sso_login` 已移除。

{{< /history >}}

你可以在你的项目上启用 Pages 访问控制，如果你的管理员在你的 极狐GitLab 实例上启用了访问控制功能。启用后，默认情况下，只有经过身份验证的[项目成员](../../permissions.md#project-permissions)（至少访客）可以访问你的网站：

1. 在顶部栏上，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 要启用访问控制，切换 **Pages** 开关。如果你看不到切换按钮，表示该功能未启用。请求你的管理员 [启用它](../../../administration/pages/_index.md#access-control)。
1. Pages 访问控制下拉列表允许你设置谁可以查看通过 极狐GitLab Pages 托管的页面，具体取决于你的项目可见性：

   - 如果你的项目是私有的：
     - **仅项目成员**：只有[项目成员](../members/_index.md)可以浏览网站。
     - **所有人**：所有人，无论是否登录 极狐GitLab，都可以浏览网站，无需项目成员资格。
   - 如果你的项目是内部的：
     - **仅项目成员**：只有项目成员可以浏览网站。
     - **具有访问权限的所有人**：已登录 极狐GitLab 的所有人都可以浏览网站，无论是否为项目成员。[外部用户](../../../administration/external_users.md) 只有在拥有项目成员资格时才能访问网站。
     - **所有人**：所有人，无论是否登录 极狐GitLab，都可以浏览网站，无需项目成员资格。
   - 如果你的项目是公开的：
     - **仅项目成员**：只有项目成员可以浏览网站。
     - **具有访问权限的所有人**：已登录和未登录 极狐GitLab 的所有人都可以浏览网站，无需项目成员资格。

1. 选择 **保存更改**。你的更改可能不会立即生效。极狐GitLab Pages 使用缓存机制以提高效率。你的更改在缓存失效前不会生效，这通常需要不到一分钟。

下次有人尝试访问你的网站且访问控制已启用时，他们会看到一个页面，要求登录 极狐GitLab 并验证他们能否访问该网站。

当关联的群组配置了 [SAML SSO](../../group/saml_sso/_index.md) 并且访问控制已启用，用户必须使用 SSO 进行身份验证才能访问该网站。

当在[实例](../../../administration/pages/_index.md#disable-public-access-to-all-pages-sites)或[群组](#remove-public-access-for-group-pages)级别禁用公共访问时，项目将失去 **所有人** 可见性级别选项，并根据项目的可见性设置限制为项目成员或具有访问权限的所有人。

<a id="remove-public-access-for-group-pages"></a>

## 移除群组 Pages 的公共访问

{{< history >}}

- 在 极狐GitLab 17.9 中引入。

{{< /history >}}

为群组配置一个设置，以移除 Pages 的公开可见性选项。启用后，该群组及其子群组中的所有项目将失去使用“所有人”可见性级别的选项，并根据项目的可见性设置限制为项目成员或具有访问权限的所有人。

先决条件

- Pages 的公共访问不得[在实例级别被禁用](../../../administration/pages/_index.md#disable-public-access-to-all-pages-sites)。
- 你必须拥有该群组的所有者角色。

操作步骤：

1. 在顶部栏上，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **权限和群组功能**。
1. 在 **Pages 公共访问** 下，选择 **移除公共访问** 复选框。
1. 选择 **保存更改**。

极狐GitLab Pages 使用缓存以提高效率。访问设置的更改通常在缓存更新时的一分钟内生效。

<a id="authenticate-with-an-access-token"></a>

## 使用访问令牌进行身份验证

{{< history >}}

- 在 极狐GitLab 17.10 中引入。

{{< /history >}}

要对受限制的 极狐GitLab Pages 站点进行身份验证，你可以提供带有访问令牌的 `Authorization` 标头。

先决条件：

- 你必须拥有以下任一具有 `read_api` 范围的访问令牌：
  - [个人访问令牌](../../profile/personal_access_tokens.md#create-a-personal-access-token)
  - [项目访问令牌](../settings/project_access_tokens.md#create-a-project-access-token)
  - [群组访问令牌](../../group/settings/group_access_tokens.md#create-a-group-access-token)
  - [OAuth 2.0 令牌](../../../api/oauth2.md)

例如，要使用符合 OAuth 标准的标头中的访问令牌：

```shell
curl --header "Authorization: Bearer <your_access_token>" <published_pages_url>
```

对于无效或未经授权的访问令牌，返回 [`404`](../../../api/rest/troubleshooting.md#status-codes)。

<a id="terminating-a-pages-session"></a>

## 终止 Pages 会话

要退出你的 极狐GitLab Pages 网站，请撤销 极狐GitLab Pages 的应用程序访问令牌：

1. 在右上角，选择你的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **应用程序**。
1. 在 **已授权的应用程序** 部分，找到 **极狐GitLab Pages** 条目，然后选择 **撤销**。

