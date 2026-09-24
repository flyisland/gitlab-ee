---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Projects, issues, authentication, security providers.
title: 与极狐GitLab 集成
---

您可以将极狐GitLab 与外部应用程序集成以增强功能。

<a id="project-integrations"></a>

## 项目集成

Jenkins、Jira 和 Slack 等应用程序可作为[项目集成](../user/project/integrations/_index.md)使用。

<a id="issue-trackers"></a>

## 议题跟踪器

您可以配置[外部议题跟踪器](external-issue-tracker.md)并使用：

- 将外部议题跟踪器与极狐GitLab 议题跟踪器结合使用
- 仅使用外部议题跟踪器

<a id="authentication-providers"></a>

## 身份验证提供程序

您可以将极狐GitLab 与 LDAP 和 SAML 等身份验证提供程序集成。

更多信息，请参见[极狐GitLab 身份验证和授权](../administration/auth/_index.md)。

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
- [Veracode](https://docs.veracode.com/r/c_integration_buildservs#gitlab)

<!-- vale gitlab_base.Spelling = YES -->

极狐GitLab 可以检查您的应用程序是否存在安全漏洞。更多信息，请参见[保护您的应用程序](../user/application_security/secure_your_application.md)。

<a id="troubleshooting"></a>

## 故障排除

使用集成时，您可能会遇到以下问题。

<a id="ssl-certificate-errors"></a>

### SSL 证书错误

当您使用自签名证书将极狐GitLab 与外部应用程序集成时，您可能会在极狐GitLab 的不同部分遇到 SSL 证书错误。

作为解决方法，请执行以下操作之一：

- 将证书添加到操作系统受信任链。更多信息，请参见：
  - [将受信任的根证书添加到服务器](https://manuals.gfi.com/en/kerio/connect/content/server-configuration/ssl-certificates/adding-trusted-root-certificates-to-the-server-1605.html)
  - [如何将证书颁发机构 (CA) 添加到 Ubuntu？](https://superuser.com/questions/437330/how-do-you-add-a-certificate-authority-ca-to-ubuntu)
- 对于使用 Linux 软件包的安装，请将证书添加到极狐GitLab 受信任链：
  1. [安装自签名证书](https://gitlab.cn/docs/omnibus/settings/ssl/#install-custom-public-certificates)。
  1. 将自签名证书与极狐GitLab 受信任证书连接。
     在升级过程中，自签名证书可能会被覆盖。

     ```shell
     cat jira.pem >> /opt/gitlab/embedded/ssl/certs/cacert.pem
     ```

  1. 重启极狐GitLab。

     ```shell
     sudo gitlab-ctl restart
     ```

<a id="search-sidekiq-logs-in-kibana"></a>

### 在 Kibana 中搜索 Sidekiq 日志

要在 Kibana 中查找特定集成，请使用以下 KQL 搜索字符串：

```plaintext
`json.integration_class.keyword : "Integrations::Jira" and json.project_path : "path/to/project"`
```

您可以在以下位置找到信息：

- `json.exception.backtrace`
- `json.exception.class`
- `json.exception.message`
- `json.message`

<a id="error-test-failed-save-anyway"></a>

### 错误：`测试失败。仍然保存`

当您在未初始化的仓库上配置集成时，集成可能会失败并显示 `测试失败。仍然保存` 错误。发生此错误是因为当项目没有推送事件时，集成使用推送数据来构建测试有效负载。

要解决此问题，请通过向项目推送测试文件来初始化仓库，然后重新配置集成。