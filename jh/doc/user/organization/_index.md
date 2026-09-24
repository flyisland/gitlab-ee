---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 组织
description: Namespace hierarchy.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- Status: 实验

{{< /details >}}

{{< history >}}

- 在 GitLab 16.1 [引入]，通过功能标志 `ui_for_organizations`，默认禁用。

{{< /history >}}

> [!flag]
> 此功能的可用性由一个功能标志控制。
> 更多信息，请参见历史记录。
> 此功能可供测试使用，但仍处于开发阶段，尚未准备好用于生产环境。

<a id="organizations"></a>

# 组织

组织将位于[顶级命名空间](../namespace/_index.md)之上，以便您管理作为 极狐GitLab 管理员所做的一切操作，包括：

- 定义并应用设置到您的所有群组、子群组和项目。
- 汇总您的所有群组、子群组和项目的数据。

> [!disclaimer]

有关组织开发状态的更多信息，参见 [epic 9265](https://gitlab.com/groups/gitlab-org/-/epics/9265)。

<a id="create-an-organization"></a>

## 创建组织

{{< history >}}

- 在 GitLab 16.11 [引入]，通过功能标志 `allow_organization_creation`，默认禁用。
- 在 GitLab 18.4 中，功能标志改为 `organization_switching`，默认禁用。功能标志 `allow_organization_creation` 已被移除。

{{< /history >}}

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建组织**。
1. 在 **组织名称** 文本框中，输入组织名称。
1. 在 **组织 URL** 文本框中，输入组织的路径。
1. 在 **组织描述** 文本框中，输入组织描述。支持 [有限的 Markdown 子集](#supported-markdown-for-organization-description)。
1. 在 **组织头像** 字段，选择 **上传** 或拖放头像。
1. 选择 **创建组织**。

<a id="switch-organizations"></a>

## 切换组织

{{< history >}}

- 在 GitLab 16.11 [引入]，通过功能标志 `organization_switching`，默认禁用。

{{< /history >}}

如果您是多个组织的成员，您可以在它们之间切换。要切换组织：

1. 在左侧边栏顶部，选择 **当前组织** 下拉列表。
1. 选择您要切换到的组织。

<a id="supported-markdown-for-organization-description"></a>

## 组织描述支持的 Markdown

**组织描述** 字段支持 [极狐GitLab Flavored Markdown](../markdown.md) 的一个有限子集，包括：

- [强调](../markdown.md#emphasis)
- [链接](../markdown.md#links)
- [上标 / 下标](../markdown.md#superscripts-and-subscripts)