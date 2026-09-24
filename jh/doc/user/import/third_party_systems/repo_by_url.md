---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过 Git URL 迁移
description: "通过使用 Git URL 将仓库导入到极狐GitLab。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

通过 Git URL 导入现有仓库。以这种方式执行的导入不包括极狐GitLab 议题或合并请求。

<a id="prerequisites"></a>

## 先决条件

{{< history >}}

- 在极狐GitLab 16.0 中引入了要求维护者角色而非开发者角色的规定，并向后移植到了极狐GitLab 15.11.1 和极狐GitLab 15.10.5。

{{< /history >}}

- [通过 URL 导入仓库的源](../../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources) 已启用。如果未启用，请要求您的极狐GitLab 管理员启用它。通过 URL 导入仓库的源在 JihuLab.com 上默认启用。
- 在要导入的目标群组上具有维护者或所有者角色。
- 如果导入私有仓库，可能需要访问令牌而不是密码来对源仓库进行身份验证访问。

<a id="import-a-repository-through-the-ui"></a>

## 通过 UI 导入仓库

要通过 UI 导入仓库：

1. 在右上角，选择 **创建新项目** ({{< icon name="plus" >}}) 和 **新建项目/仓库**。
1. 选择 **导入项目**。
1. 选择 **通过 URL 导入仓库**。
1. 输入 **Git 仓库 URL**。
1. 填写其余字段。从私有仓库导入需要用户名和密码（或访问令牌）。
1. 选择 **创建项目**。

您新创建的项目将显示。

<a id="import-a-repository-through-the-api"></a>

## 通过 API 导入仓库

您可以使用 [项目 API](../../../api/projects.md#create-a-project) 导入 Git 仓库：

```shell
curl --location "https://gitlab.example.com/api/v4/projects/" \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer <your-token>' \
--data-raw '{
    "description": "新项目描述",
    "path": "new_project_path",
    "import_url": "https://username:password@example.com/group/project.git"
}'
```

某些提供程序不允许使用密码，而是要求提供访问令牌。

<a id="import-a-timed-out-repository"></a>

## 导入超时的仓库

大型仓库的导入可能会在三小时后超时。要导入超时的仓库：

1. 克隆仓库：

   ```shell
   git clone --mirror https://example.com/group/project.git
   ```

   `--mirror` 选项确保复制所有分支、标签和引用。

1. 添加新的远程仓库：

   ```shell
   cd repository.git
   git remote add new-origin https://jihulab.com/group/project.git
   ```

1. 将所有内容推送到新的远程仓库：

   ```shell
   git push --mirror new-origin
   ```

