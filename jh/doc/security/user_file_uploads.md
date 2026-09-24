---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Manage access control and security for files uploaded to issues, merge requests, and epics.
title: 用户文件上传
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

用户可以将文件上传至：

- 项目中的议题或合并请求。
- 群组中的史诗。

极狐GitLab 为这些上传的文件生成带有随机 32 位字符 ID 的直接 URL，以防止未授权用户猜测 URL。这种随机化机制为包含敏感信息的文件提供了一定的安全保障。

用户上传到极狐GitLab 议题、合并请求和史诗的文件，其 URL 路径中包含 `/uploads/<32-character-id>`。

> [!warning]
> 下载未知或不受信任来源上传的文件时请谨慎，尤其是可执行文件或脚本。

<a id="access-control-for-uploaded-files"></a>

## 上传文件的访问控制

{{< history >}}

- 强制授权检查在极狐GitLab 15.3 中 GA。功能标志 `enforce_auth_checks_on_uploads` 已移除。
- 用户界面中的项目设置在极狐GitLab 15.3 中引入。

{{< /history >}}

对于上传到以下位置的非图片文件的访问权限：

- 议题或合并请求由项目可见性决定。
- 群组史诗由群组可见性决定。

对于公开项目或群组，任何人都可以通过直接附件 URL 访问这些文件，即使议题、合并请求或史诗是机密的。
对于私有和内部项目，极狐GitLab 确保只有经过身份验证的项目成员可以访问非图片文件上传，例如 PDF。
默认情况下，图片文件没有相同的限制，任何人都可以使用 URL 查看它们。为了保护图片文件，[启用所有媒体文件的授权检查](#enable-authorization-checks-for-all-media-files)，使其仅对经过身份验证的用户可见。

对图片进行身份验证检查可能会导致通知邮件正文中出现显示问题。
邮件通常通过未对极狐GitLab 进行身份验证的客户端（例如 Outlook、Apple Mail 或你的移动设备）阅读。
如果客户端未获得极狐GitLab 授权，邮件中的图片将显示为损坏且不可用。

<a id="enable-authorization-checks-for-all-media-files"></a>

## 启用所有媒体文件的授权检查

在私有和内部项目中，只有经过身份验证的项目成员才能查看非图片附件（包括 PDF）。

要对私有或内部项目中的图片文件应用身份验证要求：

前提条件：

- 你必须具有项目的维护者或所有者角色。
- 你的项目可见性设置必须为 **私有** 或 **内部**。

要为所有媒体文件配置身份验证设置：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 滚动到 **项目可见性** 并选择 **要求身份验证才能查看媒体文件**。

> [!note]
> 你无法为公开项目选择此选项。

<a id="delete-uploaded-files"></a>

## 删除上传的文件

{{< history >}}

- 在极狐GitLab 15.3 中引入。
- REST API 在极狐GitLab 17.2 中添加了支持。

{{< /history >}}

当上传的文件包含敏感或机密信息时，你应该删除该文件。删除文件后，用户将无法访问该文件，并且直接 URL 将返回 404 错误。

项目所有者和维护者可以使用[交互式 GraphQL 探索器](../api/graphql/_index.md#interactive-graphql-explorer) 访问 [GraphQL 端点](../api/graphql/reference/_index.md#mutationuploaddelete) 并删除上传的文件。

例如：

```graphql
mutation{
  uploadDelete(input: { projectPath: "<path/to/project>", secret: "<32-character-id>" , filename: "<filename>" }) {
    upload {
      id
      size
      path
    }
    errors
  }
}
```

没有所有者或维护者角色的项目成员无法访问此 GraphQL 端点。

你还可以使用 REST API 为[项目](../api/project_markdown_uploads.md#delete-an-uploaded-file-by-secret-and-filename) 或[群组](../api/group_markdown_uploads.md#delete-an-uploaded-file-by-secret-and-filename) 删除上传的文件。