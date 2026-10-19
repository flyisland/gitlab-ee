---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 浏览并筛选极狐GitLab Duo Agent 活动的统一记录，用于合规和治理目的。
title: 审计 AI 事件
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能处于[测试版](../../policy/development_stages_support.md)。
> 如有变更，恕不另行通知。
> 更多信息，请参阅 [GitLab 测试协议](https://handbook.gitlab.com/handbook/legal/testing-agreement/)。

使用 AI 审计事件报告，获取极狐GitLab Duo Agent 活动的统一、可浏览记录。每个 Agent 会话都会生成一份全面的审计产物，供您检查。

<a id="view-ai-audit-events"></a>

## 查看 AI 审计事件

AI 审计事件可在 **治理** 页面的 **审计事件** 标签页中查看。

先决条件：

- 您对顶级群组具有所有者角色。

要查看群组的 AI 审计事件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的顶级群组。
1. 选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改治理**。
1. 选择 **Agent 产物** 标签页。

该标签页显示 Agent 会话列表。每行显示：

- Agent 类型（工作流定义）。
- 会话运行所在的项目。
- 会话中的审计事件数量。
- 会话开始时间。

<a id="filter-sessions"></a>

## 筛选会话

您可以筛选会话列表以缩小结果范围：

- **项目**：按项目路径筛选，或排除特定项目。
- **日期范围**：筛选在特定日期之后或之前创建的会话。
- **触发者**：按触发会话的用户筛选，或排除特定用户。

<a id="view-session-details"></a>

## 查看会话详情

要检查会话中的事件：

1. 选择会话行以打开会话详情面板。
   该面板显示会话元数据和按时间顺序排列的审计事件列表。
1. 选择单个事件以查看其完整详情，包括实体和目标信息。

<a id="enable-ai-audit-event-storage"></a>

## 启用 AI 审计事件存储

AI 审计事件存储默认处于禁用状态。
您必须显式启用存储，Agent 会话数据才会写入数据库或 ClickHouse。
禁用存储不会影响 AI 审计事件的实时流式传输。

该设置从实例级联到群组再到项目：

- 在群组级别禁用并锁定时，该群组中的项目无法覆盖它。
- 在群组级别启用并锁定时，该群组中的所有项目都已启用存储，且无法禁用。

先决条件：

- 您必须对群组或项目具有所有者角色或安全管理员角色。

<a id="enable-storage-for-a-group"></a>

### 为群组启用存储

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **数据和隐私** 部分，选择 **存储 AI 审计事件**。
1. 选择 **保存更改**。

<a id="enable-storage-for-a-project"></a>

### 为项目启用存储

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 选择 **设置** > **通用**。
1. 展开 **极狐GitLab Duo** 部分。
1. 打开 **存储 AI 审计事件** 开关。
1. 选择 **保存更改**。

如果该设置被父级群组锁定，则控件将被禁用，无法在项目级别更改。

<a id="event-attribution-with-composite-identity"></a>

## 使用复合身份进行事件归属

当 Agent 会话使用[复合身份](composite_identity.md)（Agent 会话的默认身份）运行时，该会话的 AI 审计事件将归属于服务账号。
`author_id` 字段包含服务账号的用户 ID，服务账号显示为事件作者。

事件 `details` 字段记录启动会话的人类用户：

| 字段                   | 描述                |
|-------------------------|----------------------------|
| `human_author_id`       | 人类用户的用户 ID  |
| `human_author_name`     | 人类用户的姓名     |
| `human_author_username` | 人类用户的用户名 |

当会话使用人类用户自己的令牌进行身份验证时，该人类用户是事件作者，且不会添加 `human_author_*` 字段。
