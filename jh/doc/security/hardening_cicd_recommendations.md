---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 加固 - CI/CD 建议
---

通用加固指南和理念在[主要加固文档](hardening.md)中概述。

以下部分讨论了 CI/CD 的加固建议和概念。

<a id="basic-recommendations"></a>

## 基本建议

如何配置不同的 CI/CD 设置取决于你如何使用 CI/CD。例如，如果你正在使用它来构建软件包，则通常需要实时访问外部资源，如 Docker 镜像或外部代码仓库。如果你正在使用它进行基础设施即代码 (IaC)，则通常需要存储外部系统的凭据以自动化部署。针对这些场景以及其他众多场景，你需要存储在 CI/CD 操作期间使用的潜在敏感信息。由于具体场景数量众多，我们总结了一些基本信息，以帮助加固 CI/CD 流程。

一般指导是：

- 保护密钥。
- 确保网络通信加密。
- 使用全面的日志记录进行审计和故障排除。

<a id="specific-recommendations"></a>

## 特定建议

流水线是极狐GitLab CI/CD 的核心组件，它分阶段执行作业，代表项目用户自动化任务。有关处理流水线的具体指南，请参阅[流水线安全](../ci/pipeline_security/_index.md)信息。

部署是 CI/CD 的一部分，它将流水线的结果部署到给定环境。默认设置没有施加许多限制，而且由于不同角色和职责的用户可以触发能与这些环境交互的流水线，因此你应该限制这些环境。有关更多信息，请参阅[受保护的环境](../ci/environments/protected_environments.md)。