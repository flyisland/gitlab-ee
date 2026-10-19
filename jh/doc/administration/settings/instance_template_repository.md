---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 配置可供所有项目使用的文件模板集合。
title: 实例模板代码仓库
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在托管系统中，企业通常需要跨团队共享自己的模板。此功能允许管理员选择一个项目，作为实例范围的文件模板集合。随后，这些模板会通过 [Web 编辑器](../../user/project/repository/web_editor.md)向所有用户公开，同时该项目仍保持安全。

<a id="configuration"></a>

## 配置

要选择用作自定义模板代码仓库的项目：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **模板**。
1. 展开**模板**。
1. 从下拉列表中，选择要用作模板代码仓库的项目。
1. 选择**保存更改**。
1. 将自定义模板添加到所选代码仓库。

添加模板后，您可以在整个实例中使用它们。它们可在 [Web 编辑器](../../user/project/repository/web_editor.md)和 [API 设置](../../api/settings.md)中使用。

这些模板不能用作 `.gitlab-ci.yml`中 [`include:template`](../../ci/yaml/_index.md#includetemplate) 键的值。

<a id="supported-file-types-and-locations"></a>

## 支持的文件类型和位置

极狐GitLab 支持用于议题和合并请求模板的 Markdown 文件，以及其他文件类型模板。

支持以下 Markdown 描述模板：

| 类型               | 目录                         | 扩展名         |
| :---------------:  | :-----------:                     | :-----------:     |
| 议题              | `.gitlab/issue_templates`         | `.md`             |
| 合并请求      | `.gitlab/merge_request_templates` | `.md`             |

更多信息，请参见[描述模板](../../user/project/description_templates.md)。

其他支持的文件类型模板包括：

| 类型                    | 目录            | 扩展名     |
| :---------------:       | :-----------:        | :-----------: |
| `Dockerfile`            | `Dockerfile`         | `.dockerfile` |
| `.gitignore`            | `gitignore`          | `.gitignore`  |
| `.gitlab-ci.yml`        | `gitlab-ci`          | `.yml`        |
| `LICENSE`               | `LICENSE`            | `.txt`        |

每个模板都必须位于各自的子目录中，具有正确的扩展名，且不能为空。层级结构应如下所示：

```plaintext
|-- README.md
    |-- issue_templates
        |-- feature_request.md
    |-- merge_request_templates
        |-- default.md
|-- Dockerfile
    |-- custom_dockerfile.dockerfile
    |-- another_dockerfile.dockerfile
|-- gitignore
    |-- custom_gitignore.gitignore
    |-- another_gitignore.gitignore
|-- gitlab-ci
    |-- custom_gitlab-ci.yml
    |-- another_gitlab-ci.yml
|-- LICENSE
    |-- custom_license.txt
    |-- another_license.txt
```

通过极狐GitLab UI 添加新文件时，您的自定义模板会显示在下拉列表中：

![用于创建新文件的极狐GitLab UI，下拉列表中显示可供选择的 Dockerfile 模板。](img/file_template_user_dropdown_v17_10.png)

如果此功能已禁用或不存在任何模板，则选择下拉列表中不会显示**自定义**部分。
