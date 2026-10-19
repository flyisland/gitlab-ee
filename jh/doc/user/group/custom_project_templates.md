---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为了加快群组中的项目创建速度，您可以构建自定义项目模板并与群组共享。
title: 群组的自定义项目模板
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

创建项目时，您可以[从模板列表中选择](../project/_index.md)。这些模板（例如用于 GitLab Pages 或 Ruby 的模板）会用模板中所含文件的副本填充新项目。此信息与 [极狐GitLab 项目导入/导出](../project/settings/import_export.md)所使用的信息相同，可以帮助您更快速地启动新项目。

您可以[自定义可用模板的列表](../project/_index.md)，使群组中的所有项目都使用相同的列表。为此，您需要用一个子群组来存放要用作模板的项目。

您还可以为[实例配置自定义模板](../../administration/project_templates.md)。

<a id="set-up-project-templates-for-a-group"></a>

## 为群组设置项目模板

先决条件：

- 您必须具有该群组的所有者角色。

要在群组中设置自定义项目模板，请将包含项目模板的子群组添加到群组设置中：

1. 在该群组中，创建一个[子群组](subgroups/_index.md)。
1. [将项目添加到新子群组](_index.md#add-projects-to-a-group)作为您的模板。
1. 在该群组的左侧菜单中，选择**设置** > **通用**。
1. 展开 **自定义项目模板** 并选择该子群组。

下次群组成员创建项目时，他们可以选择该子群组中的任何项目。

嵌套子群组中的项目不包含在模板列表中。

<a id="which-projects-are-available-as-templates"></a>

## 哪些项目可用作模板

- 如果除 **GitLab Pages** 和 **安全性与合规性** 之外的所有[项目功能](../project/settings/_index.md#configure-project-features-and-permissions)
  都设置为 **具有访问权限的所有人**，则任何已认证用户都可以选择公开和内部项目作为新项目的模板。
- 私有项目只能由作为项目成员的用户选择。

在群组上下文之外创建项目时，您必须先从下拉列表中选择一个群组，然后才能浏览其模板。列表中只显示您有权访问的群组。

<a id="example-structure"></a>

## 示例结构

以下是 `myorganization`的项目模板的群组和项目结构示例：

```plaintext
# GitLab instance and group
gitlab.com/myorganization/
    # Subgroups
    internal
    tools
    # Subgroup for handling project templates
    websites
        templates
            # Project templates
            client-site-django
            client-site-gatsby
            client-site-html

        # Other projects
        client-site-a
        client-site-b
        client-site-c
        ...
```

<a id="what-is-copied-from-the-templates"></a>

## 从模板复制的内容

从模板创建项目时，所有可导出的项目条目都会从模板复制到新项目。这些条目包括：

- 代码仓库分支、提交和标签。
- 项目上传内容。
- 项目配置。
- 议题和合并请求及其评论和其他元数据。
- 标记、里程碑、代码片段和发布。
- CI/CD 流水线配置。

有关所复制内容的完整列表，请参阅[导出的项目条目](../project/settings/import_export.md#project-items-that-are-exported)。

<a id="permissions-and-sensitive-data"></a>

### 权限和敏感数据

复制行为因您的权限而异：

- 如果您是极狐GitLab 管理员，所有项目设置（包括项目成员）
  都会复制到新项目。
- 如果您拥有包含实例自定义模板的项目上的所有者角色，但
  您不是极狐GitLab 管理员：
  项目设置会被复制，但项目成员不会。
- 如果您不具有该项目上的所有者角色，且您不是极狐GitLab 管理员：
  项目部署密钥和项目 webhook 不会复制，因为它们包含敏感数据。

复制模板时，受保护分支和标签的访问级别也会受到影响：

- 如果您拥有新项目的顶级群组上的所有者角色，或者您是极狐GitLab
  管理员，这些访问级别会复制到新项目。
- 否则，受保护分支和标签的访问级别会重置为维护者。
  设置为 No one 的访问级别会保留。有关更多信息，请参阅
  [对导入条目的更改](../project/settings/import_export.md#changes-to-imported-items)。

部署密钥和 webhook 包含敏感密钥。仅当创建项目的身份在模板项目上具有所有者角色或具有管理员访问权限时，才会复制它们。当您使用 API 从模板创建项目时，此身份取决于令牌：

- 个人访问令牌：使用令牌所有者的权限。如果该用户在模板项目上具有所有者角色或是管理员，
  则会复制部署密钥和 webhook。
- 群组访问令牌或项目访问令牌：充当[机器人用户](settings/group_access_tokens.md#bot-users-for-groups)。该机器人用户仅是
  您创建令牌所在群组或项目的成员。如果该范围不包含
  模板项目，则该机器人用户在模板项目上不具有所有者角色，部署
  密钥和 webhook 不会被复制。要复制它们，请使用在模板项目上具有
  所有者角色的用户的个人访问令牌。

<a id="user-assignments-in-templates"></a>

## 模板中的用户分配

当您使用其他用户创建的模板时，模板中分配给某用户的任何条目都会重新分配给您。在配置受保护分支和标签等安全功能时，了解此重新分配很重要。例如，如果模板包含一个受保护分支：

- 在模板中，该分支允许模板所有者合并到默认分支。
- 在从模板创建的项目中，该分支允许您合并到
  默认分支。

复制模板时，受保护分支和标签的访问级别也会受到影响。有关更多信息，请参阅[权限和敏感数据](#permissions-and-sensitive-data)。

<a id="troubleshooting"></a>

## 故障排除

<a id="administrator-cannot-see-custom-project-templates-for-the-group-when-creating-a-project"></a>

### 管理员在创建项目时无法看到群组的自定义项目模板

群组的自定义项目模板仅对群组成员可用。如果您使用的管理员账号不是群组成员，则无法访问这些模板。
