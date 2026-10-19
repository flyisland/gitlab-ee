---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 细粒度个人访问令牌
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

细粒度个人访问令牌的作用范围限定为您定义的资源和权限。创建令牌时，您需要定义以下属性：

- 资源：一组 API 操作。资源被归入更大的边界（`Group and project`、`User` 和 `Global`）。
- 权限：令牌可对资源执行的特定操作。通常，这符合创建、读取、更新和删除操作。

<a id="create-a-fine-grained-personal-access-token"></a>

## 创建细粒度个人访问令牌

要创建细粒度个人访问令牌：

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**访问** > **个人访问令牌**。
1. 从**生成令牌**下拉列表中，选择**细粒度令牌**。
1. 填写**名称**和**描述**字段。
1. 在**到期日期**文本框中，输入令牌的到期日期。
   - 令牌将在该日期 UTC 午夜到期。
   - 如果未输入日期，到期日期将设置为从今天起 365 天。
   - 默认情况下，到期日期不能超过从今天起 365 天。在极狐GitLab 17.6 及更高版本中，
     管理员可以[修改访问令牌的最长有效期](../../administration/settings/account_and_limit_settings.md#limit-the-lifetime-of-access-tokens)。
1. 如果要添加群组或项目资源，请在**群组和项目访问**下选择一个选项。
1. 在**添加资源权限**下：
   1. 使用**群组和项目**、**用户**或**全局**标签页按边界筛选资源。
   1. 在左侧面板中，选择一个或多个资源。
   1. 在右侧面板中，为每个资源选择一个[可用权限](#available-fine-grained-permissions)。
1. 选择**生成令牌**。

此时会显示个人访问令牌。请将个人访问令牌保存在安全的地方。离开或刷新页面后，您将无法再次查看它。

<a id="how-fine-grained-tokens-authorize-each-request"></a>

## 细粒度令牌如何为每个请求授权

使用细粒度个人访问令牌发出的每个 API 请求都要通过两项检查。以下两项必须同时为真：

- 令牌对请求路径中的资源具有该操作的权限。
- 作为令牌所有者的您，可以执行该操作。

令牌检查控制令牌可以调用哪些 API 操作，以及在哪个资源上调用。该检查通过后，您自身的访问权限决定是否允许该操作。

<a id="impersonate-users-with-sudo"></a>

## 使用 sudo 模拟用户

管理员可以创建细粒度个人访问令牌，通过 REST API 上的 [`sudo`](../../api/rest/authentication.md#sudo) 参数模拟其他用户。

只有管理员才能创建具有 sudo 能力的令牌。非管理员尝试创建此类令牌时会收到错误。

细粒度令牌在模拟期间仍会强制执行其自身的权限。令牌只有在以下两项同时为真时才能执行操作：

- 被模拟的用户有权执行该操作。
- 令牌具有允许该操作的权限。

此行为与具有 `sudo` 范围的旧版个人访问令牌不同，后者可以以被模拟用户的身份执行任何操作。

> [!warning]
> 具有 sudo 能力的令牌可以充当任何用户。请将其权限和边界限制在最低必要范围内，并安全存储。

<a id="available-fine-grained-permissions"></a>

## 可用的细粒度权限

细粒度个人访问令牌可以使用的权限取决于令牌调用的端点：

- [REST API 的细粒度权限](fine_grained_access_tokens_rest.md)
- [GraphQL API 的细粒度权限](fine_grained_access_tokens_graphql.md)
- [Git 及其他操作的细粒度权限](fine_grained_access_tokens_other.md)

<a id="enforce-fine-grained-personal-access-tokens"></a>

## 强制使用细粒度个人访问令牌

您可以要求用户在指定的强制执行日期之后采用细粒度个人访问令牌。在此日期之后，任何现有的旧版个人访问令牌仍会列在用户个人资料中，但无法用于访问资源。

强制执行在 JihuLab.com 和极狐GitLab 私有化部署上的工作方式不同：

- 在 JihuLab.com 上，强制执行应用于顶级群组，并由所有子群组和项目继承。
- 在极狐GitLab 私有化部署上，强制执行应用于整个实例。

强制执行不适用于[服务账号](../../user/profile/service_accounts.md)、[群组访问令牌](../../user/group/settings/group_access_tokens.md)或[项目访问令牌](../../user/project/settings/project_access_tokens.md)的令牌。这些令牌在强制执行日期之后仍可继续使用，您仍然可以创建和轮换它们。

<a id="enforce-fine-grained-tokens-for-a-top-level-group"></a>

### 为顶级群组强制使用细粒度令牌

先决条件：

- 您必须具有顶级群组的所有者角色。

在 JihuLab.com 上，强制执行应用于该群组及其子群组和项目，并在强制执行日期之后阻止旧版个人访问令牌访问这些资源。用户仍然可以创建旧版令牌，但这些令牌无法访问该群组受强制执行的资源。

此设置在极狐GitLab 私有化部署上不可用。

您只能对顶级群组强制使用细粒度令牌。

要为顶级群组强制使用细粒度个人访问令牌：

1. 在左侧边栏中，选择**搜索或跳转到**并找到您的群组。
1. 选择**设置** > **通用**。
1. 展开**权限和群组功能**。
1. 选择**在特定日期后要求使用细粒度个人访问令牌**。
1. 输入一个未来的强制执行日期。
   强制执行日期采用协调世界时（UTC）。
1. 选择**保存更改**。

在强制执行日期之后，用户尝试使用旧版令牌访问顶级群组、任何子群组或项目中的资源时会收到错误。该错误会列出细粒度令牌所需的资源边界和权限。例如：

```plaintext
Access denied: This operation requires a fine-grained personal access token with the following project permissions: [Project: Read].
```

<a id="enforce-fine-grained-tokens-on-gitlab-self-managed"></a>

### 在极狐GitLab 私有化部署上强制使用细粒度令牌

先决条件：

- 您必须是管理员。

在极狐GitLab 私有化部署上，强制执行应用于整个实例，并在强制执行日期之后阻止用户创建或轮换旧版个人访问令牌。用户只能创建细粒度令牌。现有的旧版令牌在到期前仍可继续使用。

要为实例强制使用细粒度个人访问令牌：

1. 在左侧边栏中，选择底部的**管理员**。
1. 选择**设置** > **通用**。
1. 展开**账号和限制**。
1. 选择**在特定日期后要求使用细粒度个人访问令牌**。
1. 在**细粒度个人访问令牌强制执行日期**中，输入一个未来的日期。
1. 选择**保存更改**。

在强制执行日期之后，用户尝试创建或轮换旧版令牌时会收到错误。
