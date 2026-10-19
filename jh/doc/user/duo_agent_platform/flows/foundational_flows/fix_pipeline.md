---
stage: AI-powered
group: Agent Foundations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 修复 CI/CD 流水线流程
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 18.4 中作为[一项实验](../../../../policy/development_stages_support.md)引入，带有[功能标志](../../../../administration/feature_flags/_index.md) `duo_workflow_in_ci` 和 `ai_duo_agent_fix_pipeline_button`。`duo_workflow_in_ci` 默认启用。`ai_duo_agent_fix_pipeline_button` 默认禁用。这些功能标志可以在实例或项目级别启用或禁用。
- 在 极狐GitLab 18.5 中于 JihuLab.com 和私有化部署上启用。
- 功能标志 `ai_duo_agent_fix_pipeline_button` 在 极狐GitLab 18.5 中默认启用。
- 在 极狐GitLab 18.8 中 GA。功能标志 `ai_duo_agent_fix_pipeline_button` 已移除。功能标志 `duo_workflow_in_ci` 在 极狐GitLab 18.9 中移除。
- 在 极狐GitLab 18.10 中于 JihuLab.com 上提供，基础版可使用极狐GitLab 积分。

{{< /history >}}

<a id="fix-cicd-pipeline-flow"></a>

# 修复 CI/CD 流水线流程

修复 CI/CD 流水线流程可帮助你自动诊断和修复 极狐GitLab CI/CD 流水线中的问题。该流程：

- 分析流水线失败日志和错误信息。
- 识别配置问题和语法错误。
- 根据失败类型建议具体的修复方案。
- 创建一个包含更改的合并请求，尝试修复失败的流水线。

该流程可以自动修复多种流水线问题，包括：

- 语法和配置错误。
- 常见作业失败。
- 依赖关系和工作流问题。

该流程仅在 极狐GitLab UI 中可用。

<a id="prerequisites"></a>

## 先决条件

要使用该流程，你必须：

- 拥有一个已失败的流水线。
- 在项目中具有开发者、维护者或所有者角色。
- 满足[其他先决条件](../../_index.md#prerequisites)。
- [确保极狐GitLab Duo 服务账号可以创建提交和分支](../../troubleshooting.md#session-is-stuck-in-created-state)。
- 确保在顶级群组中[开启了](_index.md#turn-foundational-flows-on-or-off) **允许内置任务流** 和 **修复 CI/CD 流水线**。

<a id="fix-the-pipeline-in-a-merge-request"></a>

## 在合并请求中修复流水线

要在合并请求中修复 CI/CD 流水线：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **代码** > **合并请求** 并打开你的合并请求。
1. 要修复流水线，你可以：
   - 选择 **概览** 选项卡，在失败的流水线下方选择 **使用 Duo 修复流水线**。
   - 选择 **流水线** 选项卡，在最右侧列中选择 **使用 Duo 修复流水线** ({{< icon name="tanuki-ai" >}})。

1. 要监控进度，选择 **AI** > **会话**。

会话完成后，一条评论会显示一个指向包含修复的合并请求的链接，或者描述可能的后续步骤。

<a id="fix-other-cicd-pipelines"></a>

## 修复其他 CI/CD 流水线

要修复未关联合并请求的 CI/CD 流水线：

1. 选择 **构建** > **流水线**。
1. 选择你失败的流水线。
1. 在右上角，选择 **使用 Duo 修复流水线**。
1. 要监控进度，选择 **AI** > **会话**。

<a id="what-the-flow-analyzes"></a>

## 流程分析的内容

修复 CI/CD 流水线流程会检查：

- 流水线日志：错误信息、失败的作业输出和退出代码。
- 合并请求更改：可能导致失败的更改。
- 当前仓库内容：用于识别语法、代码检查或导入错误。
- 脚本错误：命令失败、缺少可执行文件或权限问题。

<a id="flow-log-processing"></a>

## 流程日志处理

修复 CI/CD 流水线流程存在一个与日志处理相关的已知问题。

AI 网关仅处理作业日志的最后 150 KiB。如果你的作业产生大量输出，流程可能无法捕获日志中较早出现的相关失败信息。

要解决此问题，可以尝试以下方法：

- 通过移除调试日志和进度指示器来减少详细输出。
- 使用 shell 重定向 (`> /dev/null`) 重定向非关键输出。
- 在脚本末尾添加一个摘要步骤，回显关键错误信息。
- 使用 `after_script` 在主脚本完成后输出诊断信息。
- 将冗长的作业拆分为更小、更专注且日志更简洁的作业。