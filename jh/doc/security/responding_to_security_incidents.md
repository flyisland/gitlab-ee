---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 响应安全事件
---

当安全事件发生时，你应主要遵循组织定义的流程。极狐GitLab 安全运营团队创建了本指南：

- 面向极狐GitLab 私有化部署实例和 JihuLab.com 群组的管理员和维护者。
- 提供如何响应与极狐GitLab 服务相关的各种安全事件的额外信息和最佳实践。
- 作为组织定义的安全事件处理流程的补充。它**不是替代品**。

使用本指南，你应该能够自信地处理与极狐GitLab 相关的安全事件。必要时，本指南会链接到极狐GitLab 文档的其他部分。

> [!warning]
> 使用本指南中的建议/推荐，风险自负。

<a id="common-security-incident-scenarios"></a>

## 常见安全事件场景

<a id="credential-exposure-to-public-internet"></a>

### 凭据泄露到公共互联网

此场景指由于错误配置或人为失误，导致敏感的身份验证或授权信息暴露到互联网的安全事件。此类信息可能包括：

- 密码。
- 个人访问令牌。
- 群组/项目访问令牌。
- Runner 令牌。
- 流水线触发令牌。
- SSH 密钥。

此场景还可能包括通过极狐GitLab 服务泄露关于第三方凭据的敏感信息。泄露可能通过例如意外提交到公开极狐GitLab 项目，或 CI/CD 设置错误配置而发生。更多信息，请参见：

- [极狐GitLab 令牌概览](tokens/_index.md)
- [极狐GitLab CI/CD 变量安全](../ci/variables/_index.md#cicd-variable-security)

<a id="response"></a>

#### 响应

与凭据泄露相关的安全事件严重性可能从低到严重不等，取决于令牌类型及其关联权限。在响应此类事件时，你应：

- 确定令牌的类型和范围。
- 根据令牌信息识别令牌所有者和相关团队。
  - 对于个人访问令牌，你可以使用[个人访问令牌 API](../api/personal_access_tokens.md#retrieve-a-personal-access-token) 快速检索令牌详细信息。
- 在评估令牌的范围和潜在影响后，[撤销](../api/personal_access_tokens.md#revoke-a-personal-access-token) 或[轮换](../api/group_access_tokens.md#rotate-a-group-access-token) 令牌。撤销生产令牌需要在暴露令牌带来的安全风险和撤销令牌可能导致的可用性风险之间取得平衡。仅在以下情况下撤销令牌：
  - 你确信了解撤销令牌的潜在影响。
  - 遵循公司的安全事件响应指南。
- 记录凭据暴露的时间和撤销凭据的时间。
- 审查极狐GitLab 审计日志，以识别与暴露令牌相关的任何未授权活动。根据令牌的范围和类型，搜索与以下内容相关的审计事件：
  - 新创建的用户。
  - 令牌。
  - 恶意流水线。
  - 代码更改。
  - 项目设置更改。

<a id="event-types"></a>

#### 事件类型

- 审查可用于你的群组或命名空间的[审计事件](../administration/compliance/audit_event_reports.md)。
- 攻击者可能试图创建令牌、SSH 密钥或用户帐户以维持持久性。查找与这些活动相关的[审计事件](../user/compliance/audit_event_types.md)。
- 关注与 CI 相关的[审计事件](../user/compliance/audit_event_types.md#continuous-integration)，以识别对 CI/CD 变量的任何修改。
- 审查[作业日志](../administration/cicd/job_logs.md)，查看攻击者运行的任何流水线。

<a id="suspected-compromised-user-account"></a>

### 疑似用户帐户被入侵

<a id="response"></a>

#### 响应

如果你怀疑用户帐户或机器人帐户已被入侵，你应：

- [阻止该用户](../administration/moderate_users.md#block-a-user) 以减轻当前风险。
- 重置用户可能已访问的任何凭据。例如，具有维护者或所有者角色的用户可以查看受保护的 [CI/CD 变量](../ci/variables/_index.md) 和 [runner 注册令牌](tokens/_index.md#runner-registration-tokens-legacy)。
- [重置用户密码](reset_user_password.md)。
- 让用户[启用双因素认证](../user/profile/account/two_factor_authentication.md) (2FA)，并考虑[对实例或群组强制执行 2FA](two_factor_authentication.md)。
- 完成调查并减轻影响后，解除对用户的阻止。

<a id="event-types"></a>

#### 事件类型

审查你可用的[审计事件](../administration/compliance/audit_event_reports.md)，以识别任何可疑的帐户行为。例如：

- 可疑的登录事件。
- 创建或删除个人、项目和群组访问令牌。
- 创建或删除 SSH 或 GPG 密钥。
- 创建、修改或删除双因素认证。
- 代码仓库更改。
- 群组或项目配置更改。
- 添加或修改 runner。
- 添加或修改 webhook 或 Git 钩子。
- 添加或修改授权的 OAuth 应用程序。
- 更改连接的 SAML 身份提供程序。
- 更改电子邮件地址或通知。

<a id="cicd-related-security-incidents"></a>

### 与 CI/CD 相关的安全事件

CI/CD 工作流是现代软件开发不可或缺的一部分，主要由开发人员和 SRE 用来构建、测试并将代码部署到生产环境。由于这些工作流与生产环境相连，它们通常需要访问 CI/CD 流水线中的敏感密钥。与 CI/CD 相关的安全事件可能因你的设置而异，但可以大致分类如下：

- 与暴露的极狐GitLab CI/CD 作业令牌相关的安全事件。
- 通过错误配置的极狐GitLab CI/CD 暴露的密钥。

<a id="response"></a>

#### 响应

<a id="exposed-gitlab-cicd-job-token"></a>

##### 暴露的极狐GitLab CI/CD 作业令牌

当流水线作业即将运行时，极狐GitLab 会生成一个唯一的令牌，并将其作为 `CI_JOB_TOKEN` [预定义变量](../ci/variables/predefined_variables.md) 注入。你可以使用极狐GitLab CI/CD 作业令牌对特定 API 端点进行身份验证。此令牌具有与触发作业运行的用户相同的 API 访问权限。令牌仅在流水线作业运行期间有效。作业完成后，令牌过期，无法再使用。

在典型情况下，`CI_JOB_TOKEN` 不会显示在作业日志中。但是，你可能通过以下方式无意中暴露此数据：

- 在流水线中启用详细日志记录。
- 运行将 shell 环境变量输出到控制台的命令。
- 未能正确保护 runner 基础设施可能无意中暴露此数据。

在这种情况下，你应：

- 检查代码仓库中的源代码是否有最近的修改。你可以检查已修改文件的提交历史，以确定进行更改的人员。如果你怀疑编辑可疑，请使用[疑似用户帐户被入侵指南](responding_to_security_incidents.md#suspected-compromised-user-account) 调查用户活动。
- 对该文件所调用的任何代码的恶意修改都可能导致问题，应进行调查，并可能导致密钥泄露。
- 在确定撤销的生产影响后，考虑轮换暴露的密钥。
- 审查你可用的[审计日志](../administration/compliance/audit_event_reports.md)，查找对用户和项目设置的任何可疑修改。

<a id="secrets-exposed-through-misconfigured-gitlab-cicd"></a>

##### 通过错误配置的极狐GitLab CI/CD 暴露的密钥

当存储为 CI 变量的密钥未[被屏蔽](../ci/variables/_index.md#mask-a-cicd-variable)时，它们可能会在作业日志中暴露。例如，回显环境变量或遇到详细的错误消息。根据项目可见性，如果项目是公开的，作业日志可能在公司内部或互联网上可访问。为减轻此类安全事件，你应：

- 按照[暴露密钥指南](#credential-exposure-to-public-internet) 撤销暴露的密钥。
- 考虑屏蔽这些变量。这将防止它们直接反映在作业日志中。但是，屏蔽并非万无一失。例如，屏蔽的变量仍可能被写入产物文件或发送到远程系统。
- 考虑保护这些变量。这确保它们仅在保护分支中可用。
- 考虑禁用公共流水线，以防止作业日志和产物的公共访问。
- 审查产物保留和过期策略。
- 遵循 CI/CD [作业令牌安全指南](../ci/jobs/ci_job_token.md#gitlab-cicd-job-token-security) 了解更多最佳实践信息。
- 审查暴露密钥系统的审计日志，例如 AWS 的 CloudTrail 日志或 GCP 的 CloudAudit 日志，以确定暴露时是否有任何可疑更改。
- 审查你可用的审计日志，查找对用户和项目设置的任何可疑修改。

<a id="suspected-compromised-instance"></a>

### 疑似实例被入侵

极狐GitLab 私有化部署客户和管理员负责：

- 其底层基础设施的安全。
- 保持极狐GitLab 安装为最新版本。

重要的是[定期更新极狐GitLab](../policy/maintenance.md)，更新操作系统及其软件，并根据供应商指导加固主机。

<a id="response"></a>

#### 响应

如果你怀疑极狐GitLab 实例已被入侵，你应：

- 审查你可用的[审计事件](../administration/compliance/audit_event_reports.md)，查找可疑帐户行为。
- 审查[所有用户](../administration/moderate_users.md)（包括管理 root 用户），并在必要时遵循[疑似用户帐户被入侵指南](responding_to_security_incidents.md#suspected-compromised-user-account)中的步骤。
- 审查凭据清单（如果可用）。
- 更改所有敏感凭据、变量、令牌和密钥。例如，位于实例配置、数据库、CI/CD 流水线或其他位置的。
- 更新到最新版本的极狐GitLab，并计划在每个安全补丁发布后进行更新。
- 此外，以下建议是服务器被恶意攻击者入侵时事件响应计划中的常见步骤：
  1. 将任何服务器状态和日志保存到一次写入位置，以供后续调查。
  1. 查找未识别的后台进程。
  1. 检查系统上的开放端口。我们的[默认端口指南](../administration/package_information/defaults.md) 可作为起点。
  1. 从已知良好的备份或从头重建主机，并应用所有最新的安全补丁。
  1. 审查网络日志以发现不常见的流量。
  1. 建立网络监控和网络级别的控制。
  1. 仅限制入站和出站网络访问权给授权用户和服务器。
  1. 确保所有日志路由到独立的只写数据存储。

<a id="event-types"></a>

#### 事件类型

审查[系统访问审计事件](../user/compliance/audit_event_types.md#system-access)，以确定与系统设置、用户权限和用户登录事件相关的任何更改。

<a id="misconfigured-project-or-group-settings"></a>

### 错误配置的项目或群组设置

安全事件可能由于项目或群组设置配置不当而发生，可能导致对敏感或专有数据的未授权访问。这些事件可能包括但不限于：

- 项目可见性的更改。
- 合并请求审批设置的修改。
- 项目删除。
- 向项目添加可疑的 webhook。
- 保护分支设置的更改。

<a id="response"></a>

#### 响应

如果你怀疑项目设置有未授权的修改，请考虑采取以下步骤：

- 首先审查可用的[审计事件](../administration/compliance/audit_event_reports.md)，以确定负责该操作的用户。
- 如果用户帐户看起来可疑，请遵循[疑似用户帐户被入侵指南](responding_to_security_incidents.md#suspected-compromised-user-account) 中概述的步骤。
- 考虑通过参考审计事件并咨询项目所有者和维护者，将设置恢复到原始状态。

<a id="event-types"></a>

#### 事件类型

- 审计日志可以根据 `target_type` 字段进行过滤。根据安全事件上下文，对该字段应用过滤器以缩小范围。
- 查找特定的[合规管理](../user/compliance/audit_event_types.md#compliance-management) 审计事件和[群组和项目审计事件](../user/compliance/audit_event_types.md#groups-and-projects)。

<a id="engaging-gitlab-for-assistance-with-a-security-incident"></a>

### 寻求极狐GitLab 协助处理安全事件

在寻求极狐GitLab 帮助之前，请搜索 [极狐GitLab 文档](https://gitlab.cn/docs)。你应该在完成初步调查并有其他问题或需要帮助时联系支持。极狐GitLab 支持的资格由[你的许可证决定](https://gitlab.cn/support/#gitlab-support-service-levels)。

<a id="security-best-practices"></a>

### 安全最佳实践

审查[极狐GitLab 安全文档](_index.md) 以获取管理环境的建议。

<a id="hardening-recommendations"></a>

#### 加固建议

有关改善极狐GitLab 环境安全状况的更多信息，请参见[加固建议](hardening.md)。

你还可以考虑实施滥用速率限制，如 [Git 滥用速率限制](../user/group/reporting/git_abuse_rate_limit.md) 中所述。设置滥用速率限制可能有助于自动缓解某些类型的安全事件。

<a id="detections"></a>

### 检测

极狐GitLab SIRT 在[极狐GitLab SIRT 公共项目](https://jihulab.com/gitlab-security-oss/guard/-/tree/main/detections)中维护一个检测存储库的活跃仓库。

此仓库中的检测基于审计事件，并采用通用 Sigma 规则格式。你可以使用 sigma 规则转换器以获取所需格式的规则。访问仓库以获取有关 Sigma 格式和相关工具的更多信息。确保已将极狐GitLab 审计日志引入你的 SIEM。你应遵循[适用于私有化部署实例](../administration/compliance/audit_event_streaming.md)或 [JihuLab.com 顶级群组](../user/compliance/audit_event_streaming.md)的审计事件流指南，将审计事件流式传输到所需目标。