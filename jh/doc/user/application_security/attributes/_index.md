---
stage: Security Risk Management
group: Security Platform Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安全属性
description: Security attributes allows security teams to apply custom metadata labels to projects and groups, enabling them to filter and prioritize security risks based on business context.
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.5 中引入，带有名为 `security_context_labels` 和 `security_categories_and_attributes` 的功能标志。默认禁用。此功能在 [测试版](../../../policy/development_stages_support.md) 中引入。
- 在极狐GitLab 18.6 中，在 JihuLab.com、私有化部署上启用。
- 在极狐GitLab 18.9 中 GA。移除了功能标志 `security_inventory_dashboard`。

{{< /history >}}

安全团队现在可以使用安全属性将特定于其自身组织和业务需求的元数据应用到项目中。

安全属性按类别组织，基于：

- 业务影响
- 应用
- 业务单元
- 互联网暴露程度
- 位置

通过跨项目应用这些属性，你可以根据自己组织的风险状况和业务需求，更快地确定哪些项目需要采取措施。使用安全属性，你可以：

- 识别任务关键且需要更强扫描覆盖的项目。
- 审查每个应用或业务单元的扫描覆盖情况。
- 定位那些构成可公开访问和暴露的应用的项目。

在 [史诗 16939](https://jihulab.com/groups/gitlab-org/-/work_items/16939) 中跟踪安全清单的开发情况。随着此功能的持续开发，请分享[你的反馈](https://jihulab.com/gitlab-cn/gitlab/-/issues/553062)。

<a id="manage-security-attributes-for-groups"></a>

## 管理群组的安全属性

先决条件：

- 您必须在顶级群组（命名空间）中具有安全经理、维护者或所有者角色才能管理安全属性。

要管理群组的安全属性：

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏，选择 **安全** > **安全配置**。

<a id="manage-security-attributes-for-projects"></a>

## 管理项目的安全属性

先决条件：

- 您必须在顶级群组（命名空间）中具有安全经理、维护者或所有者角色才能管理安全属性。

要管理项目的安全属性：

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏，选择 **安全** > **安全配置**。
1. 选择 **安全属性** 选项卡。

## 故障排查

在使用安全属性时，您可能会遇到以下问题。

### 安全配置菜单项缺失

即使在该群组中具有安全经理、维护者或所有者角色，用户也可能没有所需的权限来访问 **安全配置** 菜单项。

该菜单项仅在认证用户在包含子群组的顶级群组（命名空间）中具有安全经理、维护者或所有者角色时，才会对群组显示。

要管理安全属性，请要求维护者完成配置更改，或向您的管理员请求维护者角色。

