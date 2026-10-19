---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过 Git URL 迁移
description: "使用 Git URL 将代码仓库导入到极狐GitLab。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 Git URL 导入您现有的代码仓库。以这种方式执行的导入不包含极狐GitLab 议题或合并请求。

<a id="prerequisites"></a>

## 先决条件

- 已启用[通过 URL 导入代码仓库的导入源](../../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources)。
  如果未启用，请让极狐GitLab 管理员启用。在 JihuLab.com 上，通过 URL 导入代码仓库的导入源默认已启用。
- 在要导入到的目标群组上拥有维护者或所有者角色。
- 如果要导入私有代码仓库，可能需要用于对源代码仓库进行身份验证的访问令牌，而不是密码。

<a id="import-a-repository-through-the-ui"></a>

## 通过 UI 导入代码仓库

要通过 UI 导入代码仓库：

1. 在右上角，选择**新建**（{{< icon name="plus" >}}）和**新建项目/代码仓库**。
1. 选择**导入项目**。
1. 选择**通过 URL 导入代码仓库**。
1. 输入 **Git 代码仓库 URL**。
1. 填写其余字段。从私有代码仓库导入时，需要用户名和密码（或访问令牌）。
1. 选择**创建项目**。

系统会显示您新建的项目。

<a id="import-a-repository-through-the-api"></a>

## 通过 API 导入代码仓库

您可以使用[项目 API](../../../api/projects.md#create-a-project) 导入 Git 代码仓库：

```shell
curl --location "https://gitlab.example.com/api/v4/projects/" \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer <your-token>' \
--data-raw '{
    "description": "New project description",
    "path": "new_project_path",
    "import_url": "https://username:password@example.com/group/project.git"
}'
```

某些提供商不允许使用密码，而是要求使用访问令牌。

<a id="import-a-timed-out-repository"></a>

## 导入超时的代码仓库

大型代码仓库的导入可能会在三小时后超时。要导入超时的代码仓库：

1. 克隆代码仓库：

   ```shell
   git clone --mirror https://example.com/group/project.git
   ```

   `--mirror` 选项可确保复制所有分支、标签和引用。

1. 添加新的远程代码仓库：

   ```shell
   cd repository.git
   git remote add new-origin https://gitlab.com/group/project.git
   ```

1. 将所有内容推送到新的远程代码仓库：

   ```shell
   git push --mirror new-origin
   ```
