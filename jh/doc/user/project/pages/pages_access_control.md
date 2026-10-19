---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitLab Pages 访问控制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果您的管理员已在极狐GitLab 实例上[启用访问控制功能](../../../administration/pages/_index.md#access-control)，您就可以在项目中启用 Pages 访问控制。启用后，默认情况下只有经过身份验证的[项目成员](../../permissions.md#project-permissions)（至少为访客）可以访问您的网站：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**。
1. 要启用访问控制，请切换 **Pages**。如果您没有看到切换按钮，说明该功能尚未启用。请让您的管理员[启用它](../../../administration/pages/_index.md#access-control)。

1. Pages 访问控制下拉列表允许您根据项目的可见性设置谁可以查看由 GitLab Pages 托管的页面：

   - 如果您的项目是私有的：
     - **仅项目成员**：只有[项目成员](../members/_index.md)可以浏览网站。
     - **所有人**：所有人，无论是否登录极狐GitLab，都可以浏览网站，无论其是否为项目成员。
   - 如果您的项目是内部的：
     - **仅项目成员**：只有项目成员可以浏览网站。
     - **所有有访问权限的人**：所有登录极狐GitLab 的人都可以浏览网站，无论其是否为项目成员。[外部用户](../../../administration/external_users.md)只有在项目中拥有成员身份时才能访问网站。
     - **所有人**：所有人，无论是否登录极狐GitLab，都可以浏览网站，无论其是否为项目成员。
   - 如果您的项目是公开的：
     - **仅项目成员**：只有项目成员可以浏览网站。
     - **所有有访问权限的人**：所有人，无论是否登录极狐GitLab，都可以浏览网站，无论其是否为项目成员。

1. 选择**保存更改**。您的更改可能不会立即生效。GitLab Pages 为了提高效率使用了缓存机制。您的更改可能要到缓存失效后才会生效，通常不到一分钟。

下次有人尝试访问您的网站且访问控制已启用时，系统会显示一个页面，要求其登录极狐GitLab 并验证其是否可以访问该网站。

当关联群组配置了 [SAML SSO](../../group/saml_sso/_index.md) 且访问控制已启用时，用户必须先通过 SSO 进行身份验证，然后才能访问网站。

当在[实例](../../../administration/pages/_index.md#disable-public-access-to-all-pages-sites)或[群组](#remove-public-access-for-group-pages)级别禁用公开访问时，项目将失去**所有人**可见性级别选项，并根据项目的可见性设置限制为仅项目成员或所有有访问权限的人。

<a id="remove-public-access-for-group-pages"></a>

## 移除群组 Pages 的公开访问权限

为群组配置一项设置，以移除 Pages 的公开可见性选项。启用后，该群组及其子群组中的所有项目都将失去使用“所有人”可见性级别的选项，并根据项目的可见性设置限制为仅项目成员或所有有访问权限的人。

先决条件

- 不得在[实例级别禁用 Pages 的公开访问权限](../../../administration/pages/_index.md#disable-public-access-to-all-pages-sites)。
- 您必须拥有该群组的所有者角色。

操作步骤：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**权限和群组功能**。
1. 在 **Pages 公开访问**下，选中**移除公开访问权限**复选框。
1. 选择**保存更改**。

GitLab Pages 为了提高效率使用了缓存。访问设置的更改通常会在缓存更新后一分钟内生效。

<a id="authenticate-with-an-access-token"></a>

## 使用访问令牌进行身份验证

要对受限制的 GitLab Pages 站点进行身份验证，您可以在 `Authorization` 请求头中提供访问令牌。

先决条件：

- 您必须拥有以下具有 `read_api` 范围的访问令牌之一：
  - [个人访问令牌](../../profile/personal_access_tokens.md#create-a-personal-access-token)
  - [项目访问令牌](../settings/project_access_tokens.md#create-a-project-access-token)
  - [群组访问令牌](../../group/settings/group_access_tokens.md#create-a-group-access-token)
  - [OAuth 2.0 令牌](../../../api/oauth2.md)

例如，要使用符合 OAuth 规范的请求头来使用访问令牌：

```shell
curl --header "Authorization: Bearer <your_access_token>" <published_pages_url>
```

对于无效或未经授权的访问令牌，会返回 [`404`](../../../api/rest/troubleshooting.md#status-codes)。

<a id="terminating-a-pages-session"></a>

## 终止 Pages 会话

要退出您的 GitLab Pages 网站，请撤销 GitLab Pages 的应用程序访问令牌：

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**访问** > **应用程序**。
1. 在**已授权的应用程序**部分，找到 **GitLab Pages** 条目，然后选择**撤销**。
