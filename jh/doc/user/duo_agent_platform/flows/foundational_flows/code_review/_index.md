---
stage: AI Coding
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 代码评审任务流
---

{{< details >}}

- Tier: [基础版](../../../../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="Model information" >}}

- LLM：国内 SOTA 模型
- 极狐GitLab 19.0 或更早版本的 LLM：[默认 LLM](../../../../gitlab_duo/model_selection.md#default-models)（用于 **代码评审**）
- 在 JihuLab.com 上，使用 **Agentic 代码评审** 设置[选择不同的模型](../../../model_selection.md#select-a-model-for-a-feature)。
- 在极狐GitLab 私有化部署上，使用适合您的极狐GitLab 版本的设置[选择不同的模型](../../../../../administration/gitlab_duo/model_selection.md#select-a-model-for-code-review-flow)。
- 可用于[自部署模型的极狐GitLab Duo](../../../../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

> [!note]
> 根据您的附加组件和群组设置，极狐GitLab 会运行以下两种代码评审功能之一：
>
> - 代码评审任务流：Agentic 版本，属于极狐GitLab Duo Agent Platform 的一部分。
> - 极狐GitLab Duo 代码评审：非 Agentic 版本，仅适用于拥有极狐GitLab Duo Enterprise 附加组件的用户。
>
> 本页介绍 Agentic 版本。
>
> 有关这两个功能的比较方式以及如何开启极狐GitLab Duo Enterprise 席位的代码评审任务流的详细信息，
> 请参阅[使用极狐GitLab Duo 评审您的代码。](../../../../project/merge_requests/duo_in_merge_requests.md#use-gitlab-duo-to-review-your-code)。

代码评审任务流可帮助您利用 Agentic AI 简化代码评审。

此任务流：

- 分析代码更改。
- 提供对代码仓库结构和跨文件依赖关系的增强上下文理解。
- 提供带有可操作反馈的详细评审意见。
- 支持针对您项目定制的自定义评审指令。

<a id="prerequisites"></a>

## 前提条件

- 满足 [极狐GitLab Duo Agent Platform 的前提条件](../../../_index.md#prerequisites)。
- 为[顶级群组](../_index.md#turn-foundational-flows-on-or-off)开启 **允许内置任务流** 和 **代码评审**。
- 对项目具有开发者、维护者或所有者角色。
- 如果您属于多个极狐GitLab Duo 命名空间，请[设置默认的极狐GitLab Duo 命名空间](../../../../profile/preferences.md#set-a-default-gitlab-duo-namespace)。
- [配置您自己的 Runner](../../execution/_index.md#configure-runners-to-execute-flows)，为其添加 `gitlab--duo` 标签并使用支持 Docker 镜像的执行器，或为您的项目开启 [极狐GitLab 托管 Runner](../../../../../ci/runners/hosted_runners/_index.md)。代码评审任务流作为 CI/CD 作业运行，需要 Runner 来执行。

<a id="use-the-flow"></a>

## 使用此任务流

代码评审任务流可在极狐GitLab UI 和 REST API 中使用。

<a id="request-a-review-in-the-gitlab-ui"></a>

### 在极狐GitLab UI 中请求评审

> [!flag]
> 此功能的可用性由功能标志控制。

要在极狐GitLab UI 中请求评审：

1. 在左侧边栏中，选择 **代码** > **合并请求**，找到您的合并请求。
1. 使用以下任一方法请求评审：
   - 将 `@GitLabDuo` 指派为审核人。
   - 在评论框中，输入快速操作 `/assign_reviewer @GitLabDuo`。
   - 在评论框中，提及 `@GitLabDuo` 并请求评审。
   - 在极狐GitLab Duo 侧边栏中，打开新的或现有的 Agentic Chat 对话。
     要求 Agentic Chat 评审该合并请求。
1. 要监控进度，请在左侧边栏中选择 **AI** > **会话**。

   如果您在 Agentic Chat 中，还可以执行以下操作：
   - 在聊天对话中查看进度。
   - 在对话中选择 **查看 Agent 会话**。

<a id="request-a-review-through-the-rest-api"></a>

### 通过 REST API 请求评审

{{< details >}}

- Status: 实验

{{< /details >}}

要通过 REST API 请求评审，请使用以下参数[触发此任务流](../../../../../api/duo_agent_platform_flows.md#trigger-a-flow)：

- 将 `project_id` 设置为包含要评审的合并请求的项目。
- 将 `goal` 设置为要评审的合并请求的 IID，或该合并请求的完整 URL。
- 将 `workflow_definition` 设置为 `code_review/v1`。或者，将 `ai_catalog_item_consumer_id` 设置为代码评审任务流的[消费者 ID](../../../../../api/duo_agent_platform_flows.md#look-up-the-consumer-id)。
- 将 `start_workflow` 设置为 `true` 以立即开始评审。

以下示例触发对合并请求 `42` 的代码评审：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "project_id": "5",
    "goal": "42",
    "workflow_definition": "code_review/v1",
    "start_workflow": true
  }' \
  --url "https://gitlab.example.com/api/v4/ai/duo_workflows/workflows"
```

<a id="interact-with-gitlab-duo-in-reviews"></a>

## 在评审中与极狐GitLab Duo 交互

除了将极狐GitLab Duo 指派为审核人之外，您还可以通过以下方式与极狐GitLab Duo 交互：

- 回复评审意见以要求澄清或提出替代方法。
- 在任何讨论线程中提及 `@GitLabDuo` 以提出后续问题。

在评论中与极狐GitLab Duo 的讨论使用极狐GitLab Duo Agent Platform 并[消耗 Credits](../../../../../subscriptions/gitlab_credits.md)。

提供给极狐GitLab Duo 的反馈不会影响对其他合并请求的后续评审。
在[议题 560116](https://gitlab.com/gitlab-org/gitlab/-/issues/560116) 中提出了添加此功能的建议。

<a id="contextual-awareness"></a>

## 上下文感知

代码评审任务流分两个阶段运行：

1. 预扫描：此任务流检查合并请求的差异，并使用它们来识别要从项目代码仓库中获取的相关上下文。预扫描通常包括目录列表和相关文件的内容，例如更改所引用的测试和依赖项。实际获取的上下文取决于差异分析。
1. 评审：此任务流使用以下数据在大语言模型中进行评审。评审阶段无法按需获取额外上下文。

   - 预扫描步骤的结果。
   - 合并请求标题。
   - 合并请求描述。
   - 合并请求差异。
   - 文件的原始版本。
   - 文件名。
   - 自定义评审指令。

要指定排除的内容，请参阅
[从极狐GitLab Duo 中排除上下文](../../../context.md#exclude-context-from-gitlab-duo)。

<a id="file-and-context-limits"></a>

### 文件和上下文限制

代码评审任务流应用两个限制以将提示保持在可处理的大小范围内：

- 对于超过 10,000 行的文件，仅将差异发送给模型。不包含完整文件内容。
- 预扫描收集的总上下文上限约为 1 MiB。当超过上限时，在评审阶段运行之前，上下文会被截断至约 800 KiB。

这些限制适用于此任务流收集的数据，并且与
[所选模型](../../../model_selection.md) 的上下文窗口相互独立。

对于非常大的合并请求，评审可能会遗漏被截断的上下文。为降低
风险：

- 将合并请求拆分为更小的合并请求。
- 为与评审无关的文件[排除上下文](../../../context.md#exclude-context-from-gitlab-duo)。
- 请群组所有者或实例管理员为
  [JihuLab.com](../../../model_selection.md#select-a-model-for-a-feature)
  或 [极狐GitLab 私有化部署](../../../../../administration/gitlab_duo/model_selection.md#select-a-model-for-code-review-flow) 选择不同的模型。

<a id="custom-code-review-instructions"></a>

## 自定义代码评审指令

使用 `mr-review-instructions.yaml` 文件自定义代码评审任务流的行为。

您可以使用特定于代码仓库的评审指令来指导极狐GitLab Duo：

- 关注特定的代码质量方面（例如安全性、性能和可维护性）。
- 强制执行项目独有的编码标准和最佳实践。
- 针对特定的文件模式应用定制的评审标准。
- 为某些类型的更改提供更详细的解释。

代码评审任务流不引用 `AGENTS.md` 和 `SKILL.md` 文件。

要配置自定义指令，请参阅[为极狐GitLab Duo 自定义评审指令](../../../customize/review_instructions.md)。

<a id="automatic-reviews"></a>

## 自动评审

来自极狐GitLab Duo 的自动评审可确保您项目或群组中的所有合并请求
都能收到初步评审。

当用户创建合并请求时，极狐GitLab Duo 会自动评审，除非：

- 它被标记为草稿。要让极狐GitLab Duo 评审该合并请求，请将其标记为就绪。
- 它不包含任何更改。要让极狐GitLab Duo 评审该合并请求，请向其添加更改。
- 它匹配您设置的一条或多条排除规则。要让极狐GitLab Duo 评审该合并请求，
  请手动请求评审。

对于极狐GitLab 19.1 及更高版本中 JihuLab.com 上的新极狐GitLab Duo 试用，群组的自动评审默认开启。

{{< tabs >}}

{{< tab title="Project" >}}

前提条件：

- 对项目具有维护者或所有者角色。

要为项目开启自动评审：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 在 **极狐GitLab Duo 代码评审** 部分，选择 **启用极狐GitLab Duo 的自动评审**。
1. 选择 **保存更改**。

{{< /tab >}}

{{< tab title="Group" >}}

前提条件：

- 对群组具有所有者角色。

要为群组开启自动评审：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **合并请求** 部分。
1. 在 **极狐GitLab Duo 代码评审** 部分，选择 **启用极狐GitLab Duo 的自动评审**。
1. 选择 **保存更改**。

设置从群组级联到项目。更具体的设置会覆盖更广泛的设置。

{{< /tab >}}

{{< /tabs >}}

启用自动评审后，您可以指定规则以排除特定的合并请求。

有关自动评审的 Credits 使用量如何归属的信息，请参阅
[确定运行哪个代码评审功能](../../../../project/merge_requests/duo_in_merge_requests.md#determine-which-review-feature-runs)。

<a id="exclude-merge-requests-for-a-project"></a>

### 为项目排除合并请求

当为项目开启自动评审时，
极狐GitLab Duo 会评审每个符合条件的合并请求。
要排除特定的合并请求，请在
`.gitlab/duo/mr-review-automated-rules.yaml` 文件中定义排除规则。

排除规则仅阻止自动评审。
您仍然可以手动请求评审任何被排除的合并请求。

要定义排除规则：

1. 在代码仓库的根目录中，如果 `.gitlab/duo` 目录尚不存在，请创建它。
1. 在 `.gitlab/duo` 目录中，创建一个名为 `mr-review-automated-rules.yaml` 的文件。
1. 使用以下格式添加排除规则：

   ```yaml
   exclude:
     target_branches:
       - <pattern>
     source_branches:
       - <pattern>
     authors:
       - <pattern>
   ```

   每个键都是可选的。
   当合并请求匹配任何类别中的任何模式时，极狐GitLab Duo 会跳过自动评审：

   - `target_branches`：匹配合并请求的目标分支名称。
   - `source_branches`：匹配合并请求的源分支名称。
   - `authors`：匹配合并请求作者的用户名。

   模式支持通配符（glob）匹配。
   例如，`dependabot/*` 匹配任何以 `dependabot/` 开头的源分支。

   例如，要跳过针对发布分支或由机器人账号创建的合并请求的自动评审：

   ```yaml
   exclude:
     target_branches:
       - "release/*"
     authors:
       - "*-bot"
   ```

1. 将文件提交到代码仓库的默认分支。

极狐GitLab Duo 从代码仓库的默认分支读取排除规则。
极狐GitLab Duo 不应用其他分支上的规则。

<a id="exclude-merge-requests-for-a-group"></a>

### 为群组排除合并请求

要为群组及其子群组中的所有项目定义排除规则，请指定一个项目作为
模板。
模板项目必须包含 `.gitlab/duo/mr-review-automated-rules.yaml` 文件。

极狐GitLab Duo 将群组模板项目中的排除规则与
各个项目中定义的规则合并。
如果两个级别都定义了相同的类别，则项目的规则优先。
当群组及其子群组各自设置模板项目时，极狐GitLab Duo 会合并
每个级别的规则。

> [!note]
> 如果您已经配置了一个项目来存储群组的[自定义评审指令](../../../customize/review_instructions.md#configure-custom-review-instructions-for-a-group)，
> 请将您的 `mr-review-automated-rules.yaml` 存储在同一项目中。
> 您只能指定一个项目来自定义群组的代码评审，因此极狐GitLab 也会自动
> 检查该项目中的排除规则。您无需再次执行以下步骤。

前提条件：

- 对群组具有所有者角色。
- 群组中的一个项目包含您要设置的排除规则。

要为群组配置排除规则：

{{< tabs >}}

{{< tab title="GitLab.com" >}}

对于顶级群组：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的顶级群组。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **极狐GitLab Duo 功能** > **自定义代码评审** 下，选择包含
   `.gitlab/duo/mr-review-automated-rules.yaml` 文件的项目。
1. 选择 **保存更改**。

对于群组或子群组：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组或子群组。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **极狐GitLab Duo 功能**。
1. 在 **自定义代码评审** 下，选择包含
   `.gitlab/duo/mr-review-automated-rules.yaml` 文件的项目。
1. 选择 **保存更改**。

{{< /tab >}}

{{< tab title="GitLab Self-Managed and GitLab Dedicated" >}}

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组或子群组。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **极狐GitLab Duo 功能**。
1. 在 **自定义代码评审** 下，选择包含
   `.gitlab/duo/mr-review-automated-rules.yaml` 文件的项目。
1. 选择 **保存更改**。

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排查

使用代码评审任务流时，您可能会遇到问题。

有关如何解决这些问题的信息，请参阅[故障排查](troubleshooting.md)。
