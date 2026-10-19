---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 管理上传到议题、合并请求和史诗的文件访问控制与安全。
title: 用户文件上传
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

用户可以将文件上传到：

- 项目中的议题或合并请求。
- 群组中的史诗。

极狐GitLab 会为这些上传的文件生成带有随机 32 字符 ID 的直接 URL，以防止未授权用户猜测 URL。这种随机化处理为包含敏感信息的文件提供了一定的安全性。

用户上传到极狐GitLab 议题、合并请求和史诗的文件，其 URL 路径中包含 `/uploads/<32-character-id>`。

> [!warning]
> 下载未知或不受信任来源上传的文件时请务必谨慎，尤其是当该文件是可执行文件或脚本时。

<a id="access-control-for-uploaded-files"></a>

## 上传文件的访问控制

对上传的非图片文件的访问权限取决于：

- 议题或合并请求：由项目可见性决定。
- 群组史诗：由群组可见性决定。

对于公开项目或群组，任何人都可以通过直接附件 URL 访问这些文件，即使该议题、合并请求或史诗是机密的。对于私有和内部项目，极狐GitLab 确保只有经过身份验证的项目成员才能访问非图片文件上传，例如 PDF。默认情况下，图片文件没有相同的限制，任何人都可以使用该 URL 查看它们。要保护图片文件，请[为所有媒体文件启用授权检查](#enable-authorization-checks-for-all-media-files)，使其仅对经过身份验证的用户可见。

对图片的身份验证检查可能会导致通知邮件正文中出现显示问题。邮件通常是从未通过极狐GitLab 身份验证的客户端（例如 Outlook、Apple Mail 或您的移动设备）中读取的。如果客户端未通过极狐GitLab 身份验证，邮件中的图片会显示为损坏且不可用。

<a id="enable-authorization-checks-for-all-media-files"></a>

## 为所有媒体文件启用授权检查

在私有和内部项目中，只有经过身份验证的项目成员才能查看非图片附件（包括 PDF）。

要对私有或内部项目中的图片文件应用身份验证要求：

先决条件：

- 您必须拥有该项目的维护者或所有者角色。
- 您的项目可见性设置必须为**私有**或**内部**。

为所有媒体文件配置身份验证设置：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**。
1. 滚动到**项目可见性**，然后选择**查看媒体文件需要身份验证**。

> [!note]
> 您无法为公开项目选择此选项。

<a id="delete-uploaded-files"></a>

## 删除上传的文件

当上传的文件包含敏感或机密信息时，您应删除该文件。删除该文件后，用户将无法访问该文件，直接 URL 会返回 404 错误。

项目所有者和维护者可以使用[交互式 GraphQL 浏览器](../api/graphql/_index.md#interactive-graphql-explorer)访问 [GraphQL 端点](../api/graphql/reference/_index.md#mutationuploaddelete)并删除上传的文件。

例如：

```graphql
mutation{
  uploadDelete(input: { projectPath: "<path/to/project>", secret: "<32-character-id>", filename: "<filename>" }) {
    upload {
      id
      size
      path
    }
    errors
  }
}
```

不具有维护者或所有者角色的项目成员无法访问此 GraphQL 端点。

您也可以使用[项目](../api/project_markdown_uploads.md#delete-an-uploaded-file-by-secret-and-filename)或[群组](../api/group_markdown_uploads.md#delete-an-uploaded-file-by-secret-and-filename)的 REST API 来删除上传的文件。
