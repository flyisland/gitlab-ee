---
stage: Tenant Scale
group: Organizations
info: For assistance with this tutorial, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
title: '教程：将你的个人项目移至群组'
---

{{< details >}}

- Tier: 基础版、专业版、旗舰版
- Offering: JihuLab.com

{{< /details >}}

如果你在[个人命名空间](../../user/namespace/_index.md)下创建了项目，你可以执行常见任务，例如管理议题、合并请求、源代码控制和 CI/CD。

然而，有时你的个人项目可能无法满足需求，你希望将项目移动到群组命名空间。使用群组命名空间，你可以：

- 向一组用户授予项目访问权限，而不是逐个添加用户。
- 查看群组中所有项目的所有议题和合并请求。
- 查看群组命名空间中所有项目中的所有唯一用户。
- 管理用量配额。
- 开始试用或升级到付费订阅层级。如果你受到[用户限制更改](https://gitlab.cn/blog/efficient-free-tier/)的影响，并且需要更多用户，此选项非常重要。

本教程向你展示如何将你的项目从个人命名空间移动到群组命名空间。

<a id="steps"></a>

## 步骤

以下是步骤概览：

1. [创建群组](#create-a-group)。
1. [将你的项目移至群组](#move-your-project-to-a-group)。
1. [使用你的群组](#work-with-your-group)。

<a id="create-a-group"></a>

### 创建群组

首先，请确保你有一个合适的群组来移动你的项目。该群组必须允许创建项目，并且你必须至少拥有该群组的维护者角色。

如果你还没有群组，请创建一个：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建群组**。
1. 在 **群组名称** 中，输入群组的名称。
1. 在 **群组 URL** 中，输入群组的路径，该路径将用作命名空间。
1. 选择[可见性级别](../../user/public_access.md)。
1. 可选。填写信息以个性化你的体验。
1. 选择 **创建群组**。

<a id="move-your-project-to-a-group"></a>

### 将你的项目移至群组

在将你的项目移至群组之前：

- 你必须拥有该项目的所有者角色。
- 移除所有[容器镜像](../../user/packages/container_registry/_index.md#move-or-rename-container-registry-repositories)
- 移除所有 npm 软件包。如果你将项目转移到不同的根命名空间，项目不得包含任何 npm 软件包。当你更新用户或群组的路径，或转移子群组或项目时，你必须首先移除所有 npm 软件包。你不能更新包含 npm 软件包的项目的根命名空间。请确保更新你的 .npmrc 文件以遵循命名约定，如有必要，运行 npm publish。

现在你可以移动你的项目了：

1. 在顶栏，选择 **搜索或跳转到** 并查找你的项目。
1. 在左侧边栏，选择 **设置** > **常规**。
1. 展开 **高级**。
1. 在 **转移项目** 下，选择要转移项目的目标群组。
1. 选择 **转移项目**。
1. 输入项目名称并选择 **确认**。

你将被重定向到项目的新页面。如果你有多个个人项目，你可以为每个项目重复这些步骤。

> [!note]
> 有关这些迁移步骤的更多信息，请参阅[将你的项目转移到其他命名空间](../../user/project/working_with_projects.md#transfer-a-project)。
> 迁移可能导致需要跟进工作，更新相关资源和工具（例如网站和软件包管理器）中的项目路径。

<a id="work-with-your-group"></a>

### 使用你的群组

现在你可以查看群组中的项目：

1. 在顶栏，选择 **搜索或跳转到** 并查找你的群组。
1. 在 **子群组和项目** 下查找你的项目。

开始享受群组的优势！例如，作为群组所有者，你可以快速查看命名空间中的所有唯一用户：

1. 在你的群组中，选择 **设置** > **用量配额**。
1. **席位** 选项卡显示群组中所有项目中的所有用户。