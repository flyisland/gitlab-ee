---
title: 群组自定义项目模板
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 用于在群组上下文之外浏览群组模板的群组选择器在极狐GitLab 18.11 中引入，带有名为 `constrain_group_project_templates` 的功能标志。默认禁用。

{{< /history >}}

当你创建项目时，你可以[从模板列表中选择](../project/_index.md)。这些模板，例如用于极狐GitLab Pages 或 Ruby 的模板，会用模板中包含的文件的副本填充新项目。此信息与[极狐GitLab 项目导入/导出](../project/settings/import_export.md)所使用的信息相同，并且可以帮助你更快地启动新项目。

你可以[自定义可用模板列表](../project/_index.md)，以便群组中的所有项目都拥有相同的列表。为此，你需要将要作为模板使用的项目填充到一个子群组中。

你还可以配置[实例的自定义模板](../../administration/custom_project_templates.md)。

<a id="set-up-project-templates-for-a-group"></a>

## 为群组设置项目模板

前提条件：

- 你必须拥有该群组的所有者角色。

要在群组中设置自定义项目模板，请将包含项目模板的子群组添加到群组设置中：

1. 在该群组中，创建一个[子群组](subgroups/_index.md)。
1. 将项目[添加到新子群组](_index.md#add-projects-to-a-group)作为你的模板。
1. 在群组左侧菜单中，选择 **设置** > **通用**。
1. 展开 **自定义项目模板** 并选择该子群组。

下次群组成员创建项目时，他们可以选择子群组中的任何项目。

嵌套子群组中的项目不包含在模板列表中。

<a id="which-projects-are-available-as-templates"></a>

## 哪些项目可用作模板

- 如果所有[项目功能](../project/settings/_index.md#configure-project-features-and-permissions)（除了 **极狐GitLab Pages** 和 **安全性与合规性** 之外）都设置为 **具有访问权限的所有人**，则公共和内部项目可以被任何经过身份验证的用户选作新项目的模板。
- 私有项目只能由该项目成员的用户选择。

当启用 `constrain_group_project_templates` 功能标志后，在群组上下文之外创建项目的用户必须先从下拉列表中选择一个群组，然后才能浏览其模板。仅列出用户有权访问的群组。

存在一个已知问题：除非启用 `project_templates_without_min_access` 功能标志，否则[继承成员](../project/members/_index.md#membership-types)无法选择项目模板。在 JihuLab.com 上，此功能标志被禁用，因此用户必须被授予模板项目的直接成员身份。

<a id="example-structure"></a>

## 示例结构

以下是以 `myorganization` 为例的用于项目模板的群组与项目结构示例：

```plaintext
# 极狐GitLab 实例与群组
gitlab.com/myorganization/
    # 子群组
    internal
    tools
    # 用于处理项目模板的子群组
    websites
        templates
            # 项目模板
            client-site-django
            client-site-gatsby
            client-site-html

        # 其他项目
        client-site-a
        client-site-b
        client-site-c
        ...
```

<a id="what-is-copied-from-the-templates"></a>

## 模板中复制了什么内容

当你从模板创建项目时，所有可导出的项目项都会从模板复制到新项目中。这些项目包括：

- 仓库分支、提交和标签。
- 项目上传文件。
- 项目配置。
- 议题和合并请求及其评论和其他元数据。
- 标签、里程碑、代码片段和发布。
- CI/CD 流水线配置。

有关所复制内容的完整列表，请参阅[导出的项目项](../project/settings/import_export.md#project-items-that-are-exported)。

<a id="permissions-and-sensitive-data"></a>

### 权限和敏感数据

根据你的权限，复制行为可能会有所不同：

- 如果你拥有包含实例自定义模板的项目的所有者角色，或者你是极狐GitLab 管理员：所有项目设置，包括项目成员，都会复制到新项目中。
- 如果你没有该项目的所有者角色，或者你不是极狐GitLab 管理员：项目部署密钥和项目 webhook 不会复制，因为它们包含敏感数据。

<a id="user-assignments-in-templates"></a>

## 模板中的用户分配

当你使用其他用户创建的模板时，模板中已分配给某个用户的所有事项都会重新分配给你。了解这种重新分配在你配置受保护分支和标签等安全功能时很重要。例如，如果模板包含一个受保护分支：

- 在模板中，该分支允许模板所有者合并到默认分支。
- 在根据模板创建的项目中，该分支允许你合并到默认分支。

<a id="troubleshooting"></a>

## 故障排除

<a id="administrator-cannot-see-custom-project-templates-for-the-group-when-creating-a-project"></a>

### 管理员在创建项目时看不到群组的自定义项目模板

群组的自定义项目模板仅对群组成员可用。如果你使用的管理员账号不是群组成员，则无法访问这些模板。