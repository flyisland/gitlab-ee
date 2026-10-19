---
stage: Security Risk Management
group: Security Platform Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安全属性
description: 安全属性允许安全团队为项目和群组应用自定义元数据标记，使他们能够根据业务上下文筛选安全风险并确定其优先级。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

安全团队现在可以使用安全属性，将特定于其自身组织和业务需求的元数据应用到项目中。

安全属性按以下类别进行组织：

- 业务影响
- 应用程序
- 业务部门
- 互联网暴露
- 位置

通过将这些属性应用到您的项目中，您可以根据自己组织的风险状况和业务需求，更快速地识别哪些项目需要采取行动。借助安全属性，您可以：

- 识别对关键业务至关重要且需要更全面扫描覆盖的项目。
- 查看每个应用程序或业务部门的扫描覆盖范围。
- 定位构成可公开访问和暴露的应用程序的项目。

在[史诗 16939](https://gitlab.com/groups/gitlab-org/-/work_items/16939)中跟踪安全清单的开发进展。随着此功能的持续开发，欢迎分享[您的反馈](https://gitlab.com/gitlab-org/gitlab/-/issues/553062)。

<a id="manage-security-attributes-for-groups"></a>

## 管理群组的安全属性

先决条件：

- 您必须在顶级群组（命名空间）中拥有安全管理员、维护者或所有者角色，才能管理安全属性。

要管理群组的安全属性：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **安全配置**。

<a id="manage-security-attributes-for-projects"></a>

## 管理项目的安全属性

先决条件：

- 您必须在顶级群组（命名空间）中拥有安全管理员、维护者或所有者角色，才能管理安全属性。

要管理项目的安全属性：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**安全** > **安全配置**。
1. 选择**安全属性**标签页。

<a id="troubleshooting"></a>

## 故障排除

使用安全属性时，您可能会遇到以下问题。

<a id="security-configuration-menu-item-missing"></a>

### 缺少安全配置菜单项

即使用户在该群组中拥有安全管理员、维护者或所有者角色，也可能没有访问**安全配置**菜单项所需的权限。

仅当已认证用户在包含该子群组的顶级群组（命名空间）中拥有安全管理员、维护者或所有者角色时，该菜单项才会对群组显示。

要管理安全属性，请让维护者完成配置更改，或向管理员申请维护者角色。
