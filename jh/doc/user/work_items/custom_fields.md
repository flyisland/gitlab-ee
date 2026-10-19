---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: "Create and use custom fields for work items to track specific information unique to your workflow. Configure field types to enhance planning and reporting capabilities."
title: 自定义字段
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 17.11 中引入，带有一个[功能标志](../../administration/feature_flags/_index.md)名为 `custom_fields_feature`。已在 JihuLab.com 和私有化部署环境中启用。
- 在 极狐GitLab 18.0 中成为 GA。功能标志 `custom_fields_feature` 已移除。

{{< /history >}}

自定义字段为工作项（如议题和史诗）添加符合你特定计划需求的专业信息。
为群组配置自定义字段，以跟踪诸如业务价值、风险评估、优先级排名或团队属性等数据点。
这些字段会出现在该群组、其子群组及项目中的所有工作项中。

自定义字段帮助团队标准化整个工作流程中记录和报告信息的方式。
这种标准化在项目间创造了一致性，并支持更强大的筛选和报告能力。
从多种字段类型中选择，以满足不同的数据需求和规划场景：

- 单选
- 多选
- 数字
- 文本

<a id="configure-custom-fields-for-a-group"></a>

## 为群组配置自定义字段

为顶级群组配置自定义字段，使其可用于该群组、其子群组及项目中的工作项。

<a id="create-a-custom-field"></a>

### 创建自定义字段

创建自定义字段以捕获团队需要跟踪的特定信息。
你可以为一种或多种工作项类型配置每个字段，根据组织需求定制工作流程。

注意以下限制：

- 一个顶级群组最多可有 50 个活跃自定义字段。
- 每种工作项类型最多可分配 10 个自定义字段。

前提条件：

- 你必须具有该群组的维护者或所有者角色。

要创建自定义字段：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的群组。该群组必须为顶级。
1. 在左侧边栏中，选择 **设置** > **工作项**。
1. 选择 **创建字段**。
1. 填写字段：
   - 在 **类型** 中，选择该字段应有的类型：
     - 单选
     - 多选
     - 数字
     - 文本
     字段类型在创建后不可更改。
   - 在 **用于** 中，选择你希望此字段可用的工作项类型。
   - 在 **选项**（针对单选和多选字段）中，输入可能的选项。一个单选或多选字段最多可有 50 个选项。
     - 通过将拖拽图标 ({{< icon name="grip" >}}) 拖动到每个选项的左侧来重新排序选项。
     - 要一次添加多个选项，请选择输入框并粘贴一个列表，每行一个。
1. 选择 **保存**。

<a id="edit-a-custom-field"></a>

### 编辑自定义字段

编辑现有自定义字段以反映组织不断变化的需求。
你可以修改字段名称、适用的工作项类型以及可用选项，而不会丢失现有数据。

前提条件：

- 你必须具有该群组的维护者或所有者角色。

要编辑自定义字段：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的群组。该群组必须为顶级。
1. 在左侧边栏中，选择 **设置** > **工作项**。
1. 在要编辑的字段旁边，选择 **编辑 `<field name>`** ({{< icon name="pencil" >}})。
1. 对任意字段进行更改。
1. 选择 **更新**。

<a id="archive-a-custom-field"></a>

### 存档自定义字段

存档不再需要的自定义字段，同时保留其历史数据。
存档会将该字段从所有拥有该字段的工作项中移除。

前提条件：

- 你必须具有该群组的维护者或所有者角色。

要存档自定义字段：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的群组。该群组必须为顶级。
1. 在左侧边栏中，选择 **设置** > **工作项**。
1. 在要存档的字段旁边，选择 **存档 `<field name>`** ({{< icon name="archive" >}})。

<a id="unarchive-a-custom-field"></a>

### 取消存档自定义字段

当你需要再次使用之前存档的自定义字段时，可以将其恢复。
之前为该字段设置有值的工作项，会保留存档前相同的值。

前提条件：

- 你必须具有该群组的维护者或所有者角色。

要取消存档自定义字段：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的群组。该群组必须为顶级。
1. 在左侧边栏中，选择 **设置** > **工作项**。
1. 选择 **已存档** 标签页以列出已存档字段。
1. 在要取消存档的字段旁边，选择 **取消存档 `<field name>`** ({{< icon name="redo" >}})。

<a id="set-custom-field-values-for-a-work-item"></a>

## 为工作项设置自定义字段值

使用为群组配置的自定义字段，为工作项添加相关信息。

前提条件：

- 你必须具有工作项所属项目或群组的计划者、报告者、开发者、维护者或所有者角色。
- 如果你具有访客角色，则只能在创建工作项时设置自定义字段。

1. 转到一个工作项。
1. 在右侧边栏中，找到要编辑的自定义字段部分，然后选择 **编辑**。
1. 输入或选择所需的值。
   - 文本字段值最多可有 1024 个字符。
1. 选择该字段外的任意区域。

<a id="field-type-selection-guide"></a>

## 字段类型选择指南

创建自定义字段时，请选择与你要跟踪的数据类型匹配的字段类型。
正确的字段类型能提高数据质量，并让报告更有效。

<a id="single-select-fields"></a>

### 单选字段

在以下情况下使用单选字段：

- 用户应从预定义列表中选择一项，且只能选一项。
- 选项互斥。
- 你希望强制一致性并阻止自由文本输入。

单选字段适用于：

- 优先级指标（如 `High`、`Medium`、`Low`）
- 类别分配
- 团队分配
- 审批状态
- 优先级级别

<a id="multi-select-fields"></a>

### 多选字段

在以下情况下使用多选字段：

- 可能同时适用多个值。
- 你需要跟踪重叠的属性。
- 工作项可能属于多个类别。

多选字段适用于：

- 标签
- 所需技能
- 受影响的组件
- 利益相关者群组
- 功能能力

<a id="number-fields"></a>

### 数字字段

在以下情况下使用数字字段：

- 你需要收集量化数据。
- 你想执行计算或聚合。
- 信息需要按数字排序。

数字字段适用于：

- 成本估算
- 时间估算
- 业务价值评分
- 排名或优先级评分
- 完成百分比

<a id="text-fields"></a>

### 文本字段

在以下情况下使用文本字段：

- 你需要捕获无法归入预定义类别的唯一信息。
- 数据变化很大。
- 你需要提供上下文或详细信息。

文本字段适用于：

- 附加上下文
- 外部引用 ID
- 联系信息
- 简要注释或评论
- URL 或链接

<a id="naming-conventions-for-custom-fields"></a>

## 自定义字段的命名约定

为自定义字段制定一致的命名约定，使其更易于理解和使用。
良好的字段命名能提高采用率和数据质量。

<a id="general-guidelines"></a>

### 通用指南

- 保持名称简洁但具有描述性。
- 使用组织理解的清晰、具体的语言。
- 保持大小写一致（推荐使用标题风格）。
- 除非广为人知，否则避免使用缩写。
- 在适用时包含度量单位。

<a id="naming-single-select-and-multi-select-fields"></a>

### 为单选和多选字段命名

以类别名称开头，后跟描述符。例如：

- `Risk Level` 而不是 `Risk`
- `Customer Segment` 而不是 `Segment`
- `Development Phase` 而不是 `Phase`
- `Approval Status` 而不是 `Status`

<a id="naming-number-fields"></a>

### 为数字字段命名

在字段名称中包含度量单位。例如：

- `Effort Points` 而不是 `Points`
- `Budget Estimate ($)` 而不是 `Budget`
- `Implementation Time (days)` 而不是 `Time`
- `Business Value Score` 而不是 `Value`

<a id="naming-text-fields"></a>

### 为文本字段命名

明确指示应输入哪些信息。例如：

- `External Reference ID` 而不是 `Reference`
- `Implementation Notes` 而不是 `Notes`
- `Requirements Source` 而不是 `Source`

<a id="team-specific-prefixes"></a>

### 团队特定前缀

如果多个团队使用同一个极狐GitLab 实例，考虑添加团队前缀以避免混淆：

- `DEV: Sprint Priority`
- `QA: Test Environment`
- `UX: Design Status`
- `PM: Market Segment`

这种方法有助于团队快速识别哪些字段与他们的工作相关。

