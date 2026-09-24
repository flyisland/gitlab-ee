---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 内置任务流
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="Model information" >}}

- LLM: 国内 SOTA 模型

{{< /collapsible >}}

内置任务流由极狐GitLab 构建和维护，并显示极狐GitLab 维护徽章（{{< icon name="tanuki-verified" >}}）。

每个任务流都旨在解决特定问题或帮助您完成开发任务。

以下内置任务流可用：

| 任务流 | 描述 |
|------|-------------|
| [Agentic 破坏性变更解决](agentic-breaking-change-resolution.md) | 自动解决依赖项升级合并请求中的破坏性变更。 |
| [代码评审](code_review/_index.md) | 通过 AI 原生分析和反馈实现代码评审自动化。 |
| [转换为极狐GitLab CI/CD](convert_to_gitlab_ci.md) | 将 Jenkins 流水线迁移到 CI/CD。 |
| [开发者](developer.md) | 从议题创建可操作的合并请求，或在极狐GitLab Duo Agentic Chat 中完成不同任务。 |
| [修复 CI/CD 流水线](fix_pipeline.md) | 诊断并修复失败的作业。 |
| [推荐审核人](../../../project/merge_requests/reviews/automatic_reviewer_assignment.md#assign-reviewers-with-the-recommend-reviewers-flow) | 推荐并指派最适合评审合并请求的审核人。 |
| [SAST 误报检测](../../../application_security/vulnerabilities/false_positive_detection.md) | 自动识别并过滤 SAST 检测结果中的误报。 |
| [SAST 漏洞解决](agentic_sast_vulnerability_resolution.md) | 自动生成合并请求以解决 SAST 漏洞。 |
| [密钥误报检测](secret_false_positive_detection.md) | 自动识别并过滤密钥检测结果中的误报。 |
| [安全审查](security_review.md) | 检测合并请求变更中的业务逻辑安全漏洞。 |
| [软件开发](software_development.md) | 为整个软件开发生命周期中的工作创建 AI 生成的解决方案。 |

<a id="for-developers"></a>

## 面向开发者

要了解如何创建新的内置任务流并将其添加到极狐GitLab，请参阅 [内置任务流开发指南](../../../../development/ai_features/foundational_flows.md)。

<a id="configure-flow-execution-cicd-details"></a>

## 配置任务流执行的 CI/CD 详细信息

您可以配置任务流使用 CI/CD 执行的环境。

例如，在极狐GitLab 私有化部署上，管理员可以为内置任务流镜像配置自定义容器镜像仓库。

有关更多信息，请参阅 [配置任务流执行](../execution/_index.md)。

<a id="security-for-foundational-flows"></a>

## 内置任务流的安全性

在极狐GitLab UI 中，内置任务流可以访问以下极狐GitLab API：

- [Projects API](../../../../api/projects.md)
- [Issues API](../../../../api/issues.md)
- [Merge Requests API](../../../../api/merge_requests.md)
- [Repository Files API](../../../../api/repository_files.md)
- [Branches API](../../../../api/branches.md)
- [Commits API](../../../../api/commits.md)
- [CI 流水线 API](../../../../api/pipelines.md)
- [Labels API](../../../../api/labels.md)
- [Epics API](../../../../api/epics.md)
- [Notes API](../../../../api/notes.md)
- [Search API](../../../../api/search.md)

<a id="service-accounts"></a>

### 服务账号

内置任务流使用服务账号来完成任务。
有关更多信息，请参阅 [复合身份工作流](../../composite_identity.md#composite-identity-workflow)。

当内置任务流创建合并请求时，该合并请求归属于触发该任务流的人类用户，而非服务账号。
这样做是为了遵守要求职责分离的合规框架。请参阅 [合规性注意事项](../../composite_identity.md#compliance-considerations-for-merge-requests)。

<a id="turn-foundational-flows-on-or-off"></a>

## 开启或关闭内置任务流

您可以开启或关闭内置任务流：

- 在 JihuLab.com 上：适用于顶级群组和项目。
- 在极狐GitLab 私有化部署上：适用于实例、群组和项目。

您还可以开启或关闭任务流执行，以控制消耗计算分钟数的功能是否可以在极狐GitLab UI 中运行。
这些功能包括外部 Agent、内置任务流和自定义任务流。

这些设置控制极狐GitLab 中运行的任务流，例如您从议题或合并请求启动的任务流。

这些设置不控制您自己在 IDE 或 [极狐GitLab Duo CLI](../../../gitlab_duo_cli/_index.md) 会话中运行的任务流。在这些会话中，您可以在以下情况下运行内置任务流：

- 该项目或群组[已提供极狐GitLab Duo Agent Platform](../../turn_on_off.md)。
- 该任务流在您的订阅层级中可用。测试版任务流还需要
  开启 [实验和测试版功能](../../turn_on_off.md#turn-on-beta-and-experimental-features)。

例如，如果您关闭了某个内置任务流，您将无法再在极狐GitLab 中运行该任务流，
但用户仍然可以在 IDE 或极狐GitLab Duo CLI 会话中运行它。

<a id="on-gitlabcom"></a>

### 在 JihuLab.com 上

{{< tabs >}}

{{< tab title="For a top-level group" >}}

先决条件：

- 顶级群组的所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的顶级群组。
1. 选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **任务流执行** 下，选中 **允许任务流执行** 和 **允许内置任务流** 复选框。
1. 选中您要开启的每个内置任务流的复选框。
1. 选择 **保存更改**。

当您为顶级群组关闭内置任务流时，以该群组作为其默认极狐GitLab Duo 命名空间的用户将无法在任何命名空间中访问内置任务流。

{{< /tab >}}

{{< tab title="For a project" >}}

先决条件：

- 项目的维护者或所有者角色。
- 已为顶级群组开启任务流执行和内置任务流。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置 > 通用**。
1. 展开 **极狐GitLab Duo**。
1. 开启 **极狐GitLab Duo**、**允许任务流执行** 和 **允许内置任务流** 开关。
1. 选择 **保存更改**。

{{< /tab >}}

{{< /tabs >}}

<a id="on-gitlab-self-managed"></a>

### 在极狐GitLab 私有化部署上

{{< tabs >}}

{{< tab title="For an instance" >}}

先决条件：

- 管理员访问权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **任务流执行** 下，选中 **允许任务流执行** 和 **允许内置任务流** 复选框。
1. 可选。在 **镜像仓库** 文本框中，输入以下任一内容：

   - 一个仓库主机名，以使用该仓库中的默认镜像。
   - 一个完整的镜像引用，以完全覆盖该镜像（例如，`registry.example.com/group/project/image:tag`）。

   留空以使用默认的 `registry.gitlab.com`。
1. 选择 **保存更改**。

{{< /tab >}}

{{< tab title="For a group" >}}

先决条件：

- 群组的维护者或所有者角色。
- 已为实例开启任务流执行和内置任务流。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **极狐GitLab Duo 功能**。
1. 在 **任务流执行** 下，选中 **允许任务流执行** 和 **允许内置任务流** 复选框。
1. 仅对于顶级群组，选中您要开启的每个内置任务流的复选框。
1. 选择 **保存更改**。

为群组开启后，内置任务流可用于所有子群组和项目。

{{< /tab >}}

{{< tab title="For a project" >}}

先决条件：

- 项目的维护者或所有者角色。
- 已为实例和群组开启任务流执行和内置任务流。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置 > 通用**。
1. 展开 **极狐GitLab Duo**。
1. 开启 **极狐GitLab Duo**、**允许任务流执行** 和 **允许内置任务流** 开关。
1. 选择 **保存更改**。

{{< /tab >}}

{{< /tabs >}}
