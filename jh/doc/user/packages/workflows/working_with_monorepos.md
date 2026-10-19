---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Monorepo 软件包管理工作流
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

将 monorepo 项目用作软件包仓库，以将软件包发布到多个项目。

<a id="publish-packages-to-a-project-and-its-child-projects"></a>

## 将软件包发布到项目及其子项目

要将软件包发布到项目及其子项目，您必须为每个软件包添加配置文件。要了解如何为特定软件包管理器配置软件包，请参阅[支持的软件包管理器](../package_registry/supported_functionality.md)。

以下示例展示了如何使用 [npm](../npm_registry/_index.md) 为项目及其子项目发布软件包。

先决条件：

- 一个[个人访问令牌](../../profile/personal_access_tokens.md)，
  其作用域设置为 `api`。
- 一个测试项目。

在此示例中，`MyProject` 是父项目。它在 `components` 目录中包含一个名为 `ChildProject`的子项目：

```plaintext
MyProject/
  |- src/
  |   |- components/
  |       |- ChildProject/
  |- package.json
```

要为 `MyProject` 发布软件包：

1. 进入 `MyProject` 目录。
1. 通过运行 `npm init` 初始化项目。确保软件包名称遵循[命名约定](../npm_registry/_index.md#naming-convention)。
1. 创建一个 `.npmrc` 文件。包含仓库 URL 和项目端点。例如：

   ```yaml
   //gitlab.example.com/api/v4/projects/<project_id>/packages/npm/:_authToken="${NPM_TOKEN}"
   @scope:registry=https://gitlab.example.com/api/v4/projects/<project_id>/packages/npm/
   ```

1. 从命令行发布您的软件包。将 `<token>` 替换为您的个人访问令牌：

   ```shell
   NPM_TOKEN=<token> npm publish
   ```

> [!warning]
> 切勿将极狐GitLab 令牌（或任何令牌）直接硬编码到 `.npmrc` 文件或任何其他可能
> 提交到代码仓库的文件中。

您应该会在项目的软件包仓库中看到为 `MyProject` 发布的软件包。

要在 `ChildProject`中发布软件包，请按照相同的步骤操作。`.npmrc` 文件的内容可以与您在 `MyProject`中添加的内容完全相同。

为 `ChildProject` 发布软件包后，您应该会在项目的软件包仓库中看到该软件包。

<a id="publishing-packages-to-other-projects"></a>

## 将软件包发布到其他项目

软件包与极狐GitLab 上的项目相关联。但是，软件包并不与该项目的代码相关联。

例如，在为 npm 或 Maven 配置软件包时，`project_id` 会设置软件包发布到的仓库 URL。

例如：

- npm：`https://gitlab.example.com/api/v4/projects/<project_id>/packages/npm/`
- maven：`https://gitlab.example.com/api/v4/projects/<project_id>/packages/maven/`

如果您将仓库 URL 中的 `project_id` 更改为另一个项目，您的软件包将发布到该项目。

通过更改 `project_id`，您可以将多个软件包与代码分开发布到一个项目。更多信息，请参阅[将所有软件包存储在一个极狐GitLab 项目中](project_registry.md)。
