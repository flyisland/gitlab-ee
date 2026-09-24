---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 合规框架报告
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.5 中引入，默认禁用，带有名为 `compliance_framework_report_ui` 的功能标志。
- 在极狐GitLab 16.4 及更早版本中，**合规框架报告** 指的是现在所谓的 **合规项目报告**。之前命名的 **合规框架报告** 在极狐GitLab 16.5 中被重命名为 **合规项目报告**。
- 在极狐GitLab 16.8 中默认启用。
- 在极狐GitLab 16.10 中 GA。功能标志 `compliance_framework_report_ui` 已移除。

{{< /history >}}

通过合规框架报告，您可以查看群组中的所有合规框架。报告的每一行显示：

- 框架名称。
- 关联项目。

该群组的默认框架带有一个 **默认** 标记。

<a id="view-the-compliance-frameworks-report"></a>

## 查看合规框架报告

要查看合规框架报告：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的群组。
1. 在左侧边栏中，选择 **安全** > **合规中心**。
1. 在页面上，选择 **框架** 选项卡。

<a id="create-a-new-compliance-framework"></a>

## 新建合规框架

先决条件：

- 您必须是管理员或具有该群组的安全经理或所有者角色。

要从合规框架报告新建合规框架：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的群组。
1. 在左侧边栏中，选择 **安全** > **合规中心**。
1. 在页面上，选择 **框架** 选项卡。
1. 选择 **新框架**。
1. 选择 **创建空白框架**。
1. 选择 **添加框架** 以创建合规框架。

<a id="edit-a-compliance-framework"></a>

## 编辑合规框架

先决条件：

- 您必须是管理员或具有该群组的安全经理或所有者角色。

要从合规框架报告编辑合规框架：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的群组。
1. 在左侧边栏中，选择 **安全** > **合规中心**。
1. 在页面上，选择 **框架** 选项卡。
1. 将鼠标悬停在框架上，然后选择 **编辑框架**。
1. 选择 **保存更改** 以编辑合规框架。

<a id="delete-a-compliance-framework"></a>

## 删除合规框架

先决条件：

- 您必须是管理员或具有该群组的安全经理或所有者角色。

要从合规框架报告删除合规框架：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的群组。
1. 在左侧边栏中，选择 **安全** > **合规中心**。
1. 在页面上，选择 **框架** 选项卡。
1. 将鼠标悬停在框架上，然后选择 **编辑框架**。
1. 选择 **删除框架** 以删除合规框架。

<a id="set-and-remove-a-compliance-framework-as-default"></a>

## 设置和取消默认合规框架

{{< history >}}

- 在极狐GitLab 17.10 中引入。

{{< /history >}}

先决条件：

- 您必须是管理员或具有该群组的安全经理或所有者角色。

要从合规框架报告将合规框架设置为默认：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的群组。
1. 在左侧边栏中，选择 **安全** > **合规中心**。
1. 在页面上，选择 **框架** 选项卡。
1. 在您要设置为默认的合规框架旁边，选择 {{< icon name="pencil" >}} 操作。
1. 选择 **设为默认** 以设置为默认。

要从合规框架报告取消将合规框架设置为默认：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的群组。
1. 在左侧边栏中，选择 **安全** > **合规中心**。
1. 在页面上，选择 **框架** 选项卡。
1. 在默认的合规框架旁边，选择 {{< icon name="pencil" >}} 操作。
1. 选择 **取消默认** 以取消设置为默认。

<a id="export-a-report-of-compliance-frameworks-in-a-group"></a>

## 导出群组合规框架报告

{{< history >}}

- 在极狐GitLab 16.11 中引入，默认禁用，带有名为 `compliance_frameworks_report_csv_export` 的功能标志。
- 在极狐GitLab 17.1 中 GA。功能标志 `compliance_frameworks_report_csv_export` 已移除。

{{< /history >}}

导出群组中合规框架报告的内容。报告最大为 15 MB，以避免邮件附件过大。

先决条件：

- 您必须是管理员或具有该群组的安全经理或所有者角色。

要导出群组中项目的标准遵守报告：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的群组。
1. 在左侧边栏中，选择 **安全** > **合规中心**。
1. 在右上角，选择 **导出**。
1. 选择 **导出框架报告**。

一份报告将编译好并通过电子邮件附件形式发送到您的电子邮箱。