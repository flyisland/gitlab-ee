---
stage: AI-powered
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Customize GitLab Duo Agent Platform behavior to match your workflow, coding standards, and project requirements.
title: 自定义极狐GitLab Duo Agent Platform
---

您可以自定义 Agent Platform 以匹配您的工作流、编码标准或项目需求。

<a id="customization-options"></a>

## 自定义选项

| 方法    | AI 功能 | 使用场景    |
|-----------|------------|--------------|
| [使用自定义规则](custom_rules.md) 提供指令。 | - 极狐GitLab Duo Chat<br>- Agents<br>- Flows（不包括 Code Review Flow）<br>- 极狐GitLab Duo CLI | - 应用个人偏好。<br>- 执行团队标准。 |
| [创建 AGENTS.md 文件](agents_md.md) 提供指令。 | - 极狐GitLab Duo Chat<br>- Flows（不包括 Code Review Flow）<br>- 极狐GitLab Duo CLI<br>- 其他非极狐GitLab AI 编码工具 | - 考虑项目特定的上下文。<br>- 组织 monorepo。<br>- 执行目录特定的约定。 |
| [创建 MR 审核说明](review_instructions.md) 以确保项目中一致且特定的代码审核标准。 | - Code Review Flow | 应用：<br>- 语言特定的审核规则。<br>- 安全标准。<br>- 代码质量要求。<br>- 文件特定的指南。 |
| [创建 Agent Skills](agent_skills.md) 提供技能。 | - 极狐GitLab Duo Chat<br>- Flows（不包括 Code Review Flow）<br>- 极狐GitLab Duo CLI<br>- 其他非极狐GitLab AI 编码工具 | - 提供可共享的技能<br>- 添加自定义斜杠命令 |

<a id="best-practices"></a>

## 最佳实践

自定义 Agent Platform 时，请遵循以下最佳实践：

- 从最少、清晰、简单的指令开始，根据需要添加更多。
  尽量保持指令文件简短。
- 确保指令具体且可执行。根据需要提供示例。
- 选择与您的使用场景匹配的方法。
- 结合多种方法以定制和控制极狐GitLab Duo 的行为。
- 如果使用多种方法，请考虑以下项目文件结构：

  ```plaintext
  Project root directory
  |─ AGENTS.md                         # Applies to multiple Duo features
  |- skills/<skill-name>/
     |─ SKILL.md                       # Applies to multiple Duo features
  |─ .gitlab/duo/
     |─ chat-rules.md                  # Custom Chat-specific rules
     |─ mr-review-instructions.yaml    # Custom code review standards
     |─ ...                            # Other configuration as needed
  ```

  您可以在 `.gitlab/duo/` 文件夹中包含其他配置文件，例如 [自定义流程定义](../flows/custom.md)，或 [MCP 服务器配置](../../gitlab_duo/model_context_protocol/mcp_server.md) 文件。
- 在注释中记录您的选择，以解释某些指令存在的原因。
- 使用 [代码所有者](../../project/codeowners/_index.md) 保护自定义文件以管理更改。