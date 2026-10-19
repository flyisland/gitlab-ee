---
stage: AI Coding
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Duo 代码评审（非 Agentic）
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo Enterprise
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](model_selection.md#default-models)
- 使用 **Non-Agentic Code Review** 设置[选择其他模型](model_selection.md#select-a-model-for-a-feature)。
- 适用于[自部署模型的极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

> [!note]
> 根据您的附加组件和群组设置，极狐GitLab 会运行两种代码评审功能之一：
>
> - 代码评审任务流：Agentic 版本，属于极狐GitLab Duo Agent Platform。
> - 极狐GitLab Duo 代码评审：非 Agentic 版本，仅适用于拥有极狐GitLab Duo Enterprise 附加组件的用户。
>
> 本页介绍非 Agentic 版本。
> 了解[这两种功能的对比](../project/merge_requests/duo_in_merge_requests.md#use-gitlab-duo-to-review-your-code)。

极狐GitLab Duo 代码评审可帮助您简化项目中的代码评审。

<a id="use-gitlab-duo-code-review"></a>

## 使用极狐GitLab Duo 代码评审

当您的合并请求可以接受评审时，使用极狐GitLab Duo 代码评审执行初始评审：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**代码** > **合并请求**，然后找到您的合并请求。
1. 在评论框中，输入快速操作`/assign_reviewer @GitLabDuo`，或将极狐GitLab Duo 指派为审核人。


在[议题 517386](https://gitlab.com/gitlab-org/gitlab/-/issues/517386)中提供有关此功能的反馈。

<a id="contextual-awareness"></a>

### 上下文感知

当您使用极狐GitLab Duo 代码评审时，以下数据会发送到大型语言模型：

- 合并请求标题
- 合并请求描述
- 应用更改前的文件内容（用于提供上下文）
- 合并请求差异
- 文件名
- 自定义指令

要指定要排除的内容，请参阅[从代码评审中排除上下文](context.md#exclude-context-from-code-review)。

<a id="behavior-on-large-merge-requests"></a>

#### 大型合并请求中的行为

极狐GitLab Duo 代码评审会将合并请求差异和已更改文件的原始内容发送到模型。合并后的提示词受[所选模型](model_selection.md)的上下文窗口限制。

对于大型合并请求，极狐GitLab Duo 代码评审会使用回退机制来提高成功评审的几率：

1. 初始请求包含合并请求差异和原始文件内容。
1. 如果该请求失败，极狐GitLab Duo 代码评审会自动重试，但不包含原始文件
   内容。
1. 如果重试也失败，极狐GitLab Duo 代码评审会返回一条通用错误消息。

不包含文件内容的重试会减小提示词大小，但也会减少模型在评审您的更改时可用的上下文。评论可能不如包含原始文件内容的评审那样具体。

极狐GitLab Duo 代码评审的 AI 网关请求超时时间为 120 秒。未在此时间窗口内完成的评审也会显示为通用错误。

要降低大型合并请求评审失败的风险：

- 将大型合并请求拆分为较小的合并请求。
- 对与评审无关的文件[排除上下文](context.md#exclude-context-from-code-review)。
- 请群组所有者或实例管理员使用 **Non-Agentic Code Review** 设置选择其他模型。
  请参阅 [JihuLab.com](model_selection.md#select-a-model-for-a-feature) 或
  [极狐GitLab 私有化部署](../../administration/gitlab_duo/model_selection.md#select-a-model-for-the-instance)。

<a id="interact-with-gitlab-duo-in-reviews"></a>

## 在评审中与极狐GitLab Duo 交互

您可以在评论中提及`@GitLabDuo`，以便在您的合并请求上与极狐GitLab Duo 交互。您可以就其评审评论提出后续问题，也可以就合并请求中的任何讨论串提出问题。

与极狐GitLab Duo 的交互有助于在您改进合并请求的过程中改善建议和反馈。

提供给极狐GitLab Duo 的反馈不会影响之后对其他合并请求的评审。有一项功能请求希望添加此功能，请参阅[议题 560116](https://gitlab.com/gitlab-org/gitlab/-/issues/560116)。

<a id="custom-code-review-instructions"></a>

## 自定义代码评审指令

您可以创建自定义合并请求审查指令，以确保项目中一致且具体的代码评审标准。

有关更多信息，请参阅[为极狐GitLab Duo 自定义审查指令](customize_duo/review_instructions.md)。

<a id="automatic-reviews"></a>

## 自动评审

极狐GitLab Duo 的自动评审可确保您的项目、群组或实例中的所有合并请求都获得初始评审。

当用户创建合并请求时，极狐GitLab Duo 会自动评审它，除非：

- 它被标记为草稿。要让极狐GitLab Duo 评审该合并请求，请将其标记为就绪。
- 它不包含任何更改。要让极狐GitLab Duo 评审该合并请求，请向其添加更改。
- 它匹配您设置的一条或多条排除规则。要让极狐GitLab Duo 评审该合并请求，
  请手动请求评审。

{{< tabs >}}

{{< tab title="项目" >}}

先决条件：

- 项目的维护者或所有者角色。

要为项目开启自动评审：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **合并请求**。
1. 在**极狐GitLab Duo 代码评审**部分，选择**启用极狐GitLab Duo 自动评审**。
1. 选择**保存更改**。

{{< /tab >}}

{{< tab title="群组" >}}

先决条件：

- 群组的所有者角色。

要为群组开启自动评审：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**合并请求**部分。
1. 在**极狐GitLab Duo 代码评审**部分，选择**启用极狐GitLab Duo 自动评审**。
1. 选择**保存更改**。

设置会从群组级联到项目。更具体的设置会覆盖更宽泛的设置。

{{< /tab >}}

{{< tab title="Instance" >}}

先决条件：

- 管理员访问权限

要为实例开启自动评审：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 在**极狐GitLab Duo 代码评审**部分，选择**启用极狐GitLab Duo 自动评审**。
1. 选择**保存更改**。

设置会从实例级联到群组再到项目。更具体的设置会覆盖更宽泛的设置。

{{< /tab >}}

{{< /tabs >}}

启用自动评审后，您可以指定规则来排除特定合并请求。

<a id="exclude-merge-requests-for-a-project"></a>

### 为项目排除合并请求

为项目开启自动评审后，极狐GitLab Duo 会评审每个符合条件的合并请求。要排除特定合并请求，请在 `.gitlab/duo/mr-review-automated-rules.yaml` 文件中定义排除规则。

排除规则只会阻止自动评审。您仍然可以为任何被排除的合并请求手动请求评审。

要定义排除规则：

1. 在代码仓库的根目录中，创建`.gitlab/duo` 目录（如果尚不存在）。
1. 在`.gitlab/duo` 目录中，创建名为 `mr-review-automated-rules.yaml`的文件。
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
   例如，`dependabot/*`匹配任何以 `dependabot/`开头的源分支。

   例如，要跳过针对发布分支的合并请求
   或由机器人账号创建的合并请求的自动评审：

   ```yaml
   exclude:
     target_branches:
       - "release/*"
     authors:
       - "*-bot"
   ```

1. 将该文件提交到代码仓库的默认分支。

极狐GitLab Duo 会从代码仓库的默认分支读取排除规则。极狐GitLab Duo 不会在其他分支上应用规则。

<a id="exclude-merge-requests-for-a-group"></a>

### 为群组排除合并请求

要为群组及其子群组中的所有项目定义排除规则，请指定一个用作模板的项目。该模板项目必须包含`.gitlab/duo/mr-review-automated-rules.yaml` 文件。

极狐GitLab Duo 会将群组模板项目中的排除规则与各个项目中定义的规则合并。如果同一类别在两个层级都有定义，则项目的规则优先。当群组及其子群组各自设置模板项目时，极狐GitLab Duo 会合并每个层级的规则。

> [!note]
> 如果您已配置某个项目来为群组存储[自定义审查指令](customize_duo/review_instructions.md#configure-custom-review-instructions-for-a-group)，请将您的 `mr-review-automated-rules.yaml`
> 存储在同一项目中。
> 您只能指定单个项目来自定义群组的代码评审，因此极狐GitLab 也会自动
> 在该项目中检查排除规则。您无需再次执行以下步骤。

先决条件：

- 群组的所有者角色。
- 群组中的某个项目包含您要设置的排除规则。

要为群组配置排除规则：

{{< tabs >}}

{{< tab title="JihuLab.com" >}}

对于顶级群组：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的顶级群组。
1. 在左侧边栏中，选择**设置** > **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo 功能** > **自定义代码评审**下，选择包含
   `.gitlab/duo/mr-review-automated-rules.yaml` 文件的项目。
1. 选择**保存更改**。

对于群组或子群组：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组或子群组。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**极狐GitLab Duo 功能**。
1. 在**自定义代码评审**下，选择包含
   `.gitlab/duo/mr-review-automated-rules.yaml` 文件的项目。
1. 选择**保存更改**。

{{< /tab >}}

{{< tab title="极狐GitLab 私有化部署" >}}

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组或子群组。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**极狐GitLab Duo 功能**。
1. 在**自定义代码评审**下，选择包含
   `.gitlab/duo/mr-review-automated-rules.yaml` 文件的项目。
1. 选择**保存更改**。

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排除

<a id="review-fails-on-a-large-merge-request"></a>

### 大型合并请求评审失败

对于包含许多大型已更改文件的合并请求，极狐GitLab Duo 代码评审可能无法发布评审。常见原因包括：

- 差异和原始文件内容的总大小超出了模型的上下文窗口。
- AI 网关请求耗时超过 120 秒。

有关重试和超时行为的详细信息，请参阅[大型合并请求中的行为](#behavior-on-large-merge-requests)。

要变通解决此失败：

- 将合并请求拆分为较小的合并请求。
- 对与评审无关的文件[排除上下文](context.md#exclude-context-from-code-review)。
- 请群组所有者或实例管理员使用 **Non-Agentic Code Review** 设置选择其他模型。
  请参阅 [JihuLab.com](model_selection.md#select-a-model-for-a-feature) 或
  [极狐GitLab 私有化部署](../../administration/gitlab_duo/model_selection.md#select-a-model-for-the-instance)。

有关更多信息，请参阅[议题 596794](https://gitlab.com/gitlab-org/gitlab/-/work_items/596794)。
