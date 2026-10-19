---
stage: Tenant Scale
group: Organizations
info: For assistance with this tutorial, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
title: '教程：将您的个人项目移动到群组'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

如果您在[个人命名空间](../../user/namespace/_index.md)下创建了项目，您可以执行常见任务，例如管理议题、合并请求、源代码管理和 CI/CD。

不过，随着时间推移，您的个人项目可能无法满足需求，您可能希望将项目移动到群组命名空间。使用群组命名空间，您可以：

- 让一组用户访问您的项目，而无需逐个添加用户。
- 查看群组中所有项目的所有议题和合并请求。
- 查看群组命名空间中所有项目的所有唯一用户。
- 管理用量配额。
- 开始试用或升级到付费订阅层级。如果您受到
  [用户限制变更](https://about.gitlab.com/blog/efficient-free-tier/)的影响，
  并且需要更多用户，此选项非常重要。

本教程介绍如何将项目从个人命名空间移动到群组命名空间。

<a id="steps"></a>

## 步骤

以下是步骤概览：

1. [创建群组](#create-a-group)。
1. [将项目移动到群组](#move-your-project-to-a-group)。
1. [使用您的群组](#work-with-your-group)。

<a id="create-a-group"></a>

### 创建群组

首先，请确保您有一个合适的群组可用于移动项目。该群组必须允许创建项目，并且您必须至少拥有该群组的维护者角色。

如果您没有群组，请创建一个：

1. 在右上角，选择 **创建新的**（{{< icon name="plus" >}}）和 **新建群组**。
1. 在 **群组名称**中，输入群组的名称。
1. 在 **群组 URL** 中，输入群组的路径，该路径将用作命名空间。
1. 选择[可见性级别](../../user/public_access.md)。
1. 可选。填写信息以个性化您的体验。
1. 选择 **创建群组**。

<a id="move-your-project-to-a-group"></a>

### 将项目移动到群组

在将项目移动到群组之前：

- 您必须拥有该项目的所有者角色。
- 移除所有[容器镜像](../../user/packages/container_registry/_index.md#move-or-rename-container-registry-repositories)
- 移除所有 npm 软件包。如果将项目转移到其他根命名空间，该项目不得包含任何 npm 软件包。当您更新用户或群组的路径，或转移子群组或项目时，必须先移除所有 npm 软件包。您无法更新包含 npm 软件包的项目的根命名空间。请确保更新您的 .npmrc 文件以遵循命名约定，并在必要时运行 npm publish。

现在您可以移动项目了：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开 **高级**。
1. 在 **转移项目** 下，选择要将项目转移到的群组。
1. 选择 **转移项目**。
1. 输入项目名称并选择 **确认**。

您将被重定向到项目的新页面。如果您有多个个人项目，可以对每个项目重复这些步骤。

> [!note]
> 有关这些迁移步骤的更多信息，
> 请参阅[将项目转移到其他命名空间](../../user/project/working_with_projects.md#transfer-a-project)。
> 迁移后可能需要后续工作，以更新
> 相关资源和工具（例如网站和软件包管理器）中的项目路径。

<a id="work-with-your-group"></a>

### 使用您的群组

您现在可以在群组中查看您的项目：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在 **子组和项目** 下查找您的项目。

开始享受群组带来的好处吧！例如，作为群组所有者，您可以快速查看命名空间中的所有唯一用户：

1. 在您的群组中，选择 **设置** > **使用配额**。
1. **席位** 选项卡显示群组中所有项目的所有用户。
