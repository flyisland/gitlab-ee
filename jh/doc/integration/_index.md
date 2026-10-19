---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 项目、议题、身份验证、安全提供商。
title: 与极狐GitLab 集成
---

您可以将极狐GitLab 与外部应用程序集成，以增强功能。

<a id="project-integrations"></a>

## 项目集成

Jenkins、Jira 和 Slack 等应用程序可作为[项目集成](../user/project/integrations/_index.md)使用。

<a id="issue-trackers"></a>

## 议题跟踪器

您可以配置[外部议题跟踪器](external-issue-tracker.md)并使用：

- 外部议题跟踪器与极狐GitLab 议题跟踪器配合使用
- 仅使用外部议题跟踪器

<a id="authentication-providers"></a>

## 身份验证提供商

您可以将极狐GitLab 与 LDAP 和 SAML 等身份验证提供商集成。

有关更多信息，请参见[极狐GitLab 身份验证和授权](../administration/auth/_index.md)。

<a id="security-improvements"></a>

## 安全改进

Akismet 和 reCAPTCHA 等解决方案可用于垃圾信息防护。

您还可以将极狐GitLab 与以下安全合作伙伴集成：

<!-- vale gitlab_base.Spelling = NO -->

- [Anchore](https://docs.anchore.com/current/docs/integration/ci_cd/gitlab/)
- [Prisma Cloud](https://docs.prismacloud.io/en/enterprise-edition/content-collections/application-security/get-started/connect-code-and-build-providers/code-repositories/add-gitlab)
- [Checkmarx](https://checkmarx.atlassian.net/wiki/spaces/SD/pages/1929937052/GitLab+Integration)
- [CodeSecure](https://codesecure.com/our-integrations/codesonar-sast-gitlab-ci-pipeline/)
- [Fortify](https://www.microfocus.com/en-us/fortify-integrations/gitlab)
- [Jscrambler](https://docs.jscrambler.com/code-integrity/documentation/gitlab-ci-integration)
- [Mend](https://www.mend.io/gitlab/)
- [Semgrep](https://semgrep.dev/for/gitlab/)
- [StackHawk](https://docs.stackhawk.com/continuous-integration/gitlab/)
- [Tenable](https://docs.tenable.com/vulnerability-management/Content/vulnerability-management/VulnerabilityManagementOverview.htm)
- [Venafi](https://marketplace.venafi.com/xchange/620d2d6ed419fb06a5c5bd36/solution/6292c2ef7550f2ee553cf223)
- [Veracode](https://docs.veracode.com/r/GitLab_Workflow_Integration)

<!-- vale gitlab_base.Spelling = YES -->

极狐GitLab 可以检查您的应用程序是否存在安全漏洞。有关更多信息，请参见[保护您的应用程序](../user/application_security/secure_your_application.md)。

<a id="troubleshooting"></a>

## 故障排除

使用集成时，您可能会遇到以下问题。

<a id="ssl-certificate-errors"></a>

### SSL 证书错误

当您使用自签名证书将极狐GitLab 与外部应用程序集成时，可能会在极狐GitLab 的不同部分遇到 SSL 证书错误。

作为变通方法，请执行以下操作之一：

- 将该证书添加到操作系统信任链。有关更多信息，请参见：
  - [向服务器添加受信任的根证书](https://manuals.gfi.com/en/kerio/connect/content/server-configuration/ssl-certificates/adding-trusted-root-certificates-to-the-server-1605.html)
  - [如何向 Ubuntu 添加证书颁发机构 (CA)？](https://superuser.com/questions/437330/how-do-you-add-a-certificate-authority-ca-to-ubuntu)
- 对于使用 Linux 软件包的安装，将该证书添加到极狐GitLab 信任链：
  1. [安装自签名证书](https://gitlab.cn/docs/omnibus/settings/ssl/#install-custom-public-certificates)。
  1. 将自签名证书与极狐GitLab 受信任证书拼接。
     自签名证书可能会在升级期间被覆盖。

     ```shell
     cat jira.pem >> /opt/gitlab/embedded/ssl/certs/cacert.pem
     ```

  1. 重启极狐GitLab。

     ```shell
     sudo gitlab-ctl restart
     ```

<a id="search-sidekiq-logs-in-kibana"></a>

### 在 Kibana 中搜索 Sidekiq 日志

要在 Kibana 中定位特定集成，请使用以下 KQL 搜索字符串：

```plaintext
`json.integration_class.keyword : "Integrations::Jira" and json.project_path : "path/to/project"`
```

您可以在以下位置找到信息：

- `json.exception.backtrace`
- `json.exception.class`
- `json.exception.message`
- `json.message`

<a id="error-test-failed-save-anyway"></a>

### 错误：`Test Failed. Save Anyway`

当您在未初始化的代码仓库上配置集成时，该集成可能会失败并出现 `Test Failed. Save Anyway` 错误。出现此错误是因为当项目没有推送事件时，该集成使用推送数据来构建测试负载。

要解决此问题，请通过向项目推送测试文件来初始化代码仓库，然后重新配置该集成。
