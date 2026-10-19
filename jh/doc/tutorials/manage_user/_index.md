---
stage: Tenant Scale
group: Organizations
info: For assistance with this tutorial, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
title: '教程：设置您的组织'
description: 设置、配置、入门和组织结构。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<!-- vale gitlab_base.FutureTense = NO -->

本教程将教您如何通过以下方式设置和管理公司的极狐GitLab 组织：

- 创建群组、子群组和项目
- 为这些群组、子群组和项目中的群组成员分配不同的角色

在本教程中，您是一家小型软件公司的 IT 管理员。该公司使用极狐GitLab，分为市场、销售和开发部门。

您已经设置了市场和销售组织。在本教程中，您将设置软件开发组织。该组织有以下正式员工：

- 一名 IT 管理员：您。
- 一名产品经理：Alex Smith。
- 一名工程经理：Blake Wang。
- 三名软件开发人员：Charlie Devi、Devon Ivanov 和 Evan Kim。
- 一名 UX 设计师：Frankie Ali。
- 一名技术文档工程师：Grayson Garcia。
- 一名外包内容策略师：Hunter Silva。

您将创建：

- 软件开发组织。
- 用于管理工作内容的群组、子群组和项目。
- 要添加到群组和项目的用户，并为这些用户分配角色。
- 组织中用于特定工作内容的项目，并将用户添加到该项目。

<a id="before-you-begin"></a>

## 先决条件

- 确保您拥有极狐GitLab 私有化部署的管理员访问权限。

<a id="create-the-organization-parent-group-and-subgroups"></a>

## 创建组织父群组和子群组

首先，您将创建一个名为 Development 的群组。Development 群组将作为整个软件开发组织的父群组。

要创建 Development 群组：

1. 打开极狐GitLab 私有化部署。
1. 在右上角，选择**创建新的**（{{< icon name="plus" >}}）和**新建群组**。
1. 选择**创建群组**。
1. 在**群组名称**中，输入 `Development`。
1. 在**群组 URL**下，输入 `development-group`。您将看到一条消息
   显示“群组路径可用”。群组 URL 用于命名空间。
   命名空间提供了一个组织相关项目的位置。
1. 在**可见性级别**下，选择**私有**。这样，该群组的任何子群组
   也必须是私有的。
1. 在**谁将使用这个群组？**下，选择**我的公司或团队**。
1. 在**您会用这个群组做什么？**下拉列表中，选择**我想存储我的代码**。
1. 暂时不要邀请任何极狐GitLab 成员或其他用户加入该群组。
1. 选择**创建群组**。

您已经为组织创建了父群组。接下来，您将创建子群组。

<a id="create-the-organization-subgroups"></a>

## 创建组织子群组

在本教程中，我们假设 Development 分为以下工作领域：

- 产品管理
- 工程
- 用户体验
  - UX 设计
  - 技术文档

现在，您将创建子群组以反映此组织结构。

子群组和项目的可见性设置必须至少与其父群组的可见性设置一样严格。例如，您不能拥有私有父群组和公开子群组。

要创建组织子群组：

1. 在顶部栏中，选择**搜索或跳转到**。
1. 选择**查看我的所有群组**。
1. 选择 **Development**。由于您拥有所有者角色，您应该会在群组名称旁边
   看到**所有者**标签。
1. 在父群组的概览页面上，选择**创建子组**。
1. 在**子组名称**中，输入 `Product Management`。
1. **子组标识串**会自动填充为 **product-management**。
   不要更改此字段。
1. 对于**可见性级别**，您只能选择**私有**，因为父群组
   Development 也是私有的。
1. 选择**创建子组**。
1. 对以下子群组重复这些步骤：
   - `Engineering`
   - `User Experience`

接下来，创建 UX Design 和 Technical Writing 子群组。这些子群组将嵌套
在 User Experience 子群组下：

1. 在顶部栏中，选择**搜索或跳转到**。
1. 选择**查看我的所有群组**。
1. 选择 **Development**。
1. 在**子组和项目**选项卡下，选择 **User Experience**。
1. 在 **User Experience** 概览页面上，选择**创建子组**。
1. 在**子组名称**中，输入 `UX Design`。
1. 选择**创建子组**。
1. 对 Technical Writing 子群组重复这些步骤。

您现在已为组织创建了子群组。接下来，您将为组织创建用户。

<a id="create-the-users-for-your-organization"></a>

## 为组织创建用户

现在，您将手动为组织创建用户。这些用户是测试用户。要创建第一个测试用户 Alex Smith：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 选择**新建用户**。
1. 填写必填字段：
   - **名称**：`Alex Smith`
   - **用户名**：`alexsmith`
   - **电子邮件**：`alexsmith@example.com`
   - 其他所有字段保持不变。
1. 选择**创建用户**。

对于真实用户，重置链接会发送到用户的电子邮箱，并且该用户在首次登录时必须设置密码。但是，由于此用户是使用虚假电子邮箱的测试用户，您必须在不使用电子邮件确认的情况下设置该用户的密码。

<a id="set-the-test-users-password"></a>

### 设置测试用户的密码

创建用户后，您将被定向到该用户的概览页面。或者，在左侧边栏中，您可以选择**用户**并搜索该用户。

选择用户后：

1. 选择**编辑**。
1. 填写**密码**和**密码确认**字段。
1. 选择**保存更改**。

您已经创建了第一个测试用户。现在，对其他用户重复这些步骤：

| 姓名             | 用户名        | 电子邮件 |
|------------------|-----------------|-------|
| `Blake Wang`     | `blakewang`     | `blakewang@example.com` |
| `Charlie Devi`   | `charliedevi`   | `charliedevi@example.com` |
| `Devon Ivanov`   | `devonivanov`   | `devonivanov@example.com` |
| `Evan Kim`       | `evankim`       | `evankim@example.com` |
| `Frankie Ali`    | `frankieali`    | `frankieali@example.com` |
| `Grayson Garcia` | `graysongarcia` | `graysongarcia@example.com` |
| `Hunter Silva`   | `huntersilva`   | `huntersilva@example.com` |

您已经为组织创建了用户。接下来，您将把这些用户添加到不同的群组和子群组中。

<a id="add-users-to-the-group-and-subgroups"></a>

## 将用户添加到群组和子群组

您可以通过将用户添加到群组，让他们访问该群组中的所有项目。

首先，您将把所有用户添加到父群组 Development。

1. 在顶部栏中，选择**搜索或跳转到**并找到 **Development** 群组。
1. 选择**管理** > **成员**。
1. 选择**邀请成员**。
1. 在**用户名、姓名或电子邮件地址**下拉列表中，选择 `Alex Smith`。
1. 在**选择最大角色**下拉列表中，选择**所有者**。
1. 将**访问过期日期**留空。
1. 选择**邀请**。
1. 对以下用户重复此过程：

   | 用户           | 角色       | 访问过期日期 |
   |----------------|------------|------------------------|
   | Blake Wang     | 维护者 | 留空            |
   | Charlie Devi   | 开发者  | 留空            |
   | Devon Ivanov   | 开发者  | 留空            |
   | Evan Kim       | 开发者  | 留空            |
   | Frankie Ali    | 报告者   | 留空            |
   | Grayson Garcia | 报告者   | 留空            |
   | Hunter Silva   | 访客      | `2025-12-31`           |

   如果多个用户具有相同的角色和访问到期日期，您可以同时邀请他们。

<a id="confirm-that-everything-is-set-up-correctly"></a>

### 确认一切设置正确

在 Development 群组及所有子群组的**群组成员**页面上，检查
这些群组的成员关系。

- **来源**是用户成为该群组成员的来源。添加的成员是直接成员，因为
  您直接将他们添加到了该群组。
- **角色**是添加的成员在该群组中允许拥有的最高访问级别。
  您可以选择该角色来更改添加的成员在该群组中的角色。

您作为父群组成员添加的所有用户也是所有子群组的成员，并具有相同的角色。

<a id="filter-a-subgroup-on-membership-type"></a>

#### 按成员关系类型筛选子群组

您可以筛选子群组，以显示哪些用户是该子群组的直接成员，以及哪些成员从父群组继承了该子群组的成员关系。

1. 在顶部栏中，选择**搜索或跳转到**并找到 **Development** 群组。
1. 选择 **User Experience** 子群组。
1. 在左侧边栏中，选择**管理** > **成员**。
1. 在**成员**页面上，选择**筛选成员**字段。
1. 选择**成员**，然后选择**间接**，并按 <kbd>Return</kbd>。

现在，您只会看到继承了该子群组成员关系的 User Experience 子群组成员。您可以通过查看每个成员的**来源**列来验证继承的成员。它应该显示：`Inherited from Development`。

您希望每个用户只成为与其在组织中角色相关联的子群组的成员。您决定从群组和子群组中移除这些用户。

<a id="remove-users-from-the-groups-and-subgroups"></a>

## 从群组和子群组中移除用户

您不能直接从子群组中移除成员。您只能从父群组中移除他们。

返回父群组，移除除 Alex Smith 之外的所有人：

1. 在顶部栏中，选择**搜索或跳转到**并找到父群组。
1. 选择**管理** > **成员**。
1. 在要移除的成员行上，选择垂直省略号（{{< icon name="ellipsis_v" >}}）
   然后选择**删除成员**。
1. 在**删除成员**确认对话框中，选中
   **同时从子组和项目中删除直接用户成员身份**复选框。
1. 选择**删除成员**。

现在，父群组和子群组中只有一个成员，并且该成员拥有所有者角色。

接下来，您将把用户直接添加到子群组中。

<a id="add-users-to-the-subgroups"></a>

## 将用户添加到子群组

现在，您将把用户直接添加到不同的子群组中。

<a id="add-users-to-the-product-management-subgroup"></a>

### 将用户添加到 Product Management 子群组

1. 在顶部栏中，选择**搜索或跳转到**并找到 **Development** 群组。
1. 选择 **Product Management** 子群组。
1. 在左侧边栏中，选择**管理** > **成员**。

除您之外，Alex 是该子群组唯一的成员，并且是直接成员，这是正确的。但是，您认为他们应该拥有维护者角色，而不是所有者角色。

<a id="change-user-role-in-the-subgroup"></a>

#### 更改子群组中的用户角色

您不能直接在成员页面上更改他们的角色。要更改他们在子群组中的角色，请以维护者身份邀请他们加入子群组。

1. 选择**邀请成员**。
1. 填写产品经理 Alex Smith 的字段。
   - 为 Alex 授予**维护者**角色。
   - 将**访问过期日期**留空。
1. 选择**邀请**。

您将看到以下消息：

```plaintext
The following member couldn't be invited
Review the invite errors and try again:
- Alex Smith: Access level should be greater than or equal to Owner inherited membership from group Development
```

> [!note]
> 您不能授予 Alex 一个访问级别低于其在子群组父群组中角色的子群组角色，
> 因为他们从父群组继承了成员关系。

您决定让 Alex 继续作为该子群组的所有者，因为考虑到他们在组织中的角色，这是合适的。选择**取消**取消此邀请。

Product Management 子群组拥有正确的成员和角色。接下来，您将
把用户添加到 Engineering 子群组。

<a id="add-users-to-the-engineering-subgroup"></a>

### 将用户添加到 Engineering 子群组

现在，您将邀请一些用户加入 Engineering 子群组。

1. 在顶部栏中，选择**搜索或跳转到**并找到 **Development** 群组。
1. 选择 **Engineering** 子群组。
1. 在左侧边栏中，选择**管理** > **成员**。唯一的
   成员是您和 Alex。两个成员都拥有所有者角色，这是一个继承的角色。
1. 选择**邀请成员**。
1. 填写以下成员的字段：

   | 用户         | 角色       | 访问过期日期 |
   |--------------|------------|------------------------|
   | Blake Wang   | 维护者 | 留空            |
   | Charlie Devi | 开发者  | 留空            |
   | Devon Ivanov | 开发者  | 留空            |
   | Evan Kim     | 开发者  | 留空            |

1. 选择**邀请**。

   Blake Wang 在该子群组中拥有维护者角色，与其作为
   工程经理的职责一致。三名开发人员都拥有开发者角色，这是一个
   直接角色。
1. 您可以直接在该子群组的成员页面上更改他们的角色。在**角色**下，选择 `Maintainer`，将 Blake Wang 的角色
   更改为该子群组的所有者。
1. 返回 Development 群组的成员页面。您会看到 Engineering
   子群组的成员不是父群组的成员。

通过将用户直接添加到他们需要成为成员的群组和子群组中，您可以避免用户不必要地成为群组成员的问题。您可以更精确地控制对不同群组和项目的访问。

<a id="add-users-to-the-user-experience-subgroup"></a>

## 将用户添加到 User Experience 子群组

User Experience 子群组还有两个嵌套子群组：

- UX Design
- Technical Writing

就用户而言，UX Design 应只包括 Frankie Ali 和 Hunter Silva，
Technical Writing 应只包括 Grayson Garcia。

如果您将这三名用户都添加到 User Experience 子群组，由于继承的权限，他们都将被包含在两个嵌套子群组中。

因此，您将把这些用户直接添加到适当的嵌套子群组中，
而不是添加到 User Experience 子群组中。

1. 在顶部栏中，选择**搜索或跳转到**并找到 **Development** 群组。
1. 选择 **User Experience** 子群组，然后选择 **UX Design** 子群组。
1. 在左侧边栏中，选择**管理** > **成员**。您和 Alex
   Smith 是唯一的成员。这些是继承的角色。
1. 选择**邀请成员**。
1. 为以下成员填写字段并选择**邀请**：

   | 用户         | 角色       | 访问过期日期 |
   |--------------|------------|------------------------|
   | Frankie Ali  | 维护者 | 留空            |
   | Hunter Silva | 访客      | `2025-12-31`           |

1. 对 **Technical Writing** 子群组重复此操作：

   | 用户           | 角色       | 访问过期日期 |
   |----------------|------------|------------------------|
   | Grayson Garcia | 维护者 | 留空            |

您已将用户添加到适当的嵌套子群组中。您决定
Grayson Garcia 也应该加入 **User Experience** 子群组。

<a id="add-users-to-other-subgroups"></a>

### 将用户添加到其他子群组

您可以将 Grayson 以特定角色添加到 **User Experience** 子群组，同时
保持其在 **Technical Writing** 子群组中的角色不变。

1. 转到 **User Experience** 子群组。
1. 在左侧边栏中，选择**管理** > **成员**。您和 Alex
   Smith 是唯一的成员。这些是继承的角色。
1. 选择**邀请成员**。
1. 以开发者身份邀请 Grayson Garcia，该角色的权限级别
   低于其在 **Technical Writing** 子群组中的维护者角色。

为 Grayson 授予开发者角色意味着他们在 User Experience 子群组中
不具有不必要的高权限级别。

但是，由于继承的权限，将 Grayson Garcia 添加到 User Experience
子群组也会将他们作为开发者添加到 UX Design 嵌套子群组中。

> [!note]
> 请注意群组和子群组的继承权限。
> 将用户添加到最少数量的群组和子群组。
> 这种方法可以最大限度地减少无意中将用户
> 添加到他们不需要成为成员的群组中的可能性。

1. 转到 User Experience 子群组成员页面。
1. 将 Frankie Ali 和 Hunter Silva 添加为**报告者**。为 Hunter 设置相同的到期日期。
1. 转到 Technical Writing 嵌套子群组。

由于继承的权限，Frankie Ali 和 Hunter Silva 现在是 Technical Writing 子群组的成员。

您已成功使用群组、子群组和成员设置了您的组织。

接下来，您将在其中一个群组中创建一个项目，供成员开展工作。

<a id="create-a-project"></a>

## 创建项目

现在，假设您有一项工作内容需要组织中的某些成员来处理。该工作内容面向整个组织。为了组织这项工作，您将在 Development 父群组中创建一个项目，并将不同的用户添加到该项目中。

1. 在顶部栏中，选择**搜索或跳转到**并找到 **Development** 群组。
1. 在右上角，选择**创建新的**（{{< icon name="plus" >}}）和**新建项目/仓库**。
1. 选择**创建空白项目**。
1. 输入项目详细信息：
   - 在**项目名称**字段中，输入 `Release 2.0` 作为项目名称。
   - 将**项目标识**字段保持原样，它基于项目名称。
   - 要修改项目的查看和用户访问权限，您可以更改
     **可见性级别**。鉴于父群组是私有的，该项目
     也只能是**私有**。
   - 要创建一个 `README` 文件，以便初始化 Git 代码仓库、拥有
     默认分支并可以克隆，请选中**使用自述文件初始化仓库**
     复选框。
   - 要分析项目中的源代码以查找已知安全漏洞，
     请选中**启用静态应用安全测试（SAST）**复选框。
   - 要分析源代码中的密钥和凭据以防止未经授权的访问，请选中**启用密钥检测**复选框。
1. 选择**新建项目**。

您现在已在父群组中创建了一个项目。

在此项目中，转到**管理** > **成员**。

父群组的现有成员（您和 Alex）已经是该项目的成员。当您的项目属于某个群组时，项目成员会从该群组继承其角色。

其他用户需要成为此项目的一部分。现在，您将把用户直接添加到项目中。

<a id="add-users-to-the-project-and-parent-group"></a>

## 将用户添加到项目和父群组

1. 在顶部栏中，选择**搜索或跳转到**并找到 **Release 2.0** 项目。
1. 在左侧边栏中，选择**管理** > **成员**。
1. 选择**邀请成员**。邀请以下用户：

   | 用户           | 角色       | 访问过期日期 |
   |----------------|------------|------------------------|
   | Charlie Devi   | 维护者 | 留空            |
   | Frankie Ali    | 维护者 | 留空            |
   | Grayson Garcia | 维护者 | 留空            |

1. 选择**邀请**。
1. 由于您将这些用户直接添加到了项目中，您可以在需要时
   在项目成员页面上更改他们的角色。将 Grayson Garcia 的角色
   更改为**开发者**以测试这一点。
1. 转到 Development 父群组成员页面。您刚刚添加到
   项目的用户不在那里，尽管该项目位于父群组中。
1. 将相同的用户以**访客**角色直接添加到父群组。您可以
   直接在此页面上更改他们的角色。将 Frankie 的角色更改为**报告者**。
1. 返回 Release 2.0 项目成员页面。成员的项目角色
   仍然是 2 名维护者和 1 名开发者。

您已成功将三名子群组成员添加到父群组中的项目，并为这些用户在项目和父群组中分配了特定角色。
