---
stage: AI-powered
group: Agent Foundations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Create and manage triggers to control when flows run in your project.
title: 触发器
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 于极狐GitLab 18.3 [引入] 使用功能标志 `ai_flow_triggers`。默认启用。
- 在极狐GitLab 18.8 [变更] 要求额外的功能标志 `ai_catalog_create_third_party_flows`。默认禁用。
- 在极狐GitLab 18.8 [GA]。

{{< /history >}}

> [!flag]
> 要更改流配置文件的位置，必须启用功能标志。
> 有关更多信息，请参阅历史记录。

触发器决定何时运行流或外部代理。
无法为自定义代理或内置 Agent 创建触发器。

例如，您可以指定在讨论中提及时，或将其指派为审核人时，触发相应的流。

<a id="create-a-trigger"></a>

## 创建触发器

{{< history >}}

- **指派** 和 **指派审核人** 事件类型于极狐GitLab 18.5 [引入]。
- 流水线事件触发事件类型于极狐GitLab 18.9 [引入] 作为[实验](../../../policy/development_stages_support.md)，使用功能标志 `ai_flow_trigger_pipeline_hooks`。默认禁用。

{{< /history >}}

先决条件：

- 您必须具有该项目的维护者或所有者角色。

创建触发器：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的项目。
1. 在左侧边栏中，选择 **AI** > **触发器**。
1. 选择 **新建流触发器**。
1. 在 **描述** 中，输入触发器的描述。
1. 从 **事件类型** 下拉列表中，选择一个或多个事件类型：
   - **提及**：当服务账号用户在议题或合并请求的评论中被提及时。
   - **指派**：当服务账号用户被分配到议题或合并请求时。
   - **指派审核人**：当服务账号用户被指定为合并请求的审核人时。
   - **流水线事件**：当流水线更改状态时。可能的状态包括 `created`、`started`、`succeeded` 和 `failed`。
1. 从 **服务账号** 下拉列表中，选择一个用户作为[复合身份](../composite_identity.md)。
1. 对于 **配置源**，选择以下之一：
   - **AI 目录**：从此项目配置的流中，选择一个流以供触发器执行。
   - **配置路径**：输入流配置文件的路径（例如 `.gitlab/duo/flows/claude.yaml`）。要查看此选项，必须启用 `ai_catalog_create_third_party_flows` 功能标志。
1. 选择 **创建流触发器**。

触发器现在出现在 **AI** > **触发器** 中。

<a id="edit-a-trigger"></a>

### 编辑触发器

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的项目。
1. 在左侧边栏中，选择 **AI** > **触发器**。
1. 对于您要更改的触发器，选择 **编辑流触发器** ({{< icon name="pencil" >}})。
1. 进行更改并选择 **保存更改**。

<a id="delete-a-trigger"></a>

### 删除触发器

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的项目。
1. 在左侧边栏中，选择 **AI** > **触发器**。
1. 对于您要更改的触发器，选择 **删除流触发器** ({{< icon name="remove" >}})。
1. 在确认对话框中，选择 **确定**。