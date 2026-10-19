---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 加固 - CI/CD 建议
---

通用加固指南和理念在[主要加固文档](hardening.md)中概述。

CI/CD 的加固建议和相关概念将在以下章节中讨论。

<a id="basic-recommendations"></a>

## 基本建议

如何配置不同的 CI/CD 设置取决于您对 CI/CD 的使用方式。例如，如果您使用它来构建软件包，通常需要实时访问外部资源，例如 Docker 镜像或外部代码仓库。如果您将其用于基础设施即代码（IaC），通常需要存储外部系统的凭据以自动化部署。对于这些以及许多其他场景，您需要存储在 CI/CD 操作期间使用的潜在敏感信息。由于各个场景本身众多，这里总结了一些基本信息，以帮助加固 CI/CD 流程。

一般指导原则是：

- 保护密钥。
- 确保网络通信已加密。
- 使用详尽的日志记录，以便审计和故障排除。

<a id="specific-recommendations"></a>

## 具体建议

流水线是极狐GitLab CI/CD 的核心组件，它按阶段执行作业，代表项目用户自动执行任务。有关处理流水线的具体指南，请参阅[流水线安全](../ci/pipeline_security/_index.md)相关信息。

部署是 CI/CD 中针对给定环境部署流水线结果的部分。默认设置不会施加太多限制，并且由于具有不同角色和职责的不同用户可以触发可与这些环境交互的流水线，您应限制这些环境。有关更多信息，请参阅[受保护环境](../ci/environments/protected_environments.md)。
