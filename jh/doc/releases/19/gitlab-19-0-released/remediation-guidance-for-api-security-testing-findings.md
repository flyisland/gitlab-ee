---
title: API 安全测试发现结果的修复指导
stage: application_security_testing
level: secondary
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
documentation_link: "../../../user/application_security/api_security_testing/checks/"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/584601"
categories: [ API Security ]
weight: 40
---

API 安全漏洞报告现在包含每个发现结果的修复指导。
此前，API 安全测试能够识别漏洞，但未提供修复方法的相关指导。
开发者必须自行研究修复步骤。现在，每个发现结果都直接在漏洞报告中给出针对特定漏洞的修复步骤，
以及对相关 OWASP 和 CWE 标识符的引用。

以下检查现已包含修复指导：

- [应用信息](../../../user/application_security/api_security_testing/checks/application_information_check.md)
- [明文认证](../../../user/application_security/api_security_testing/checks/cleartext_authentication_check.md)
- [CORS](../../../user/application_security/api_security_testing/checks/cors_check.md)
- [DNS 重绑定](../../../user/application_security/api_security_testing/checks/dns_rebinding_check.md)
- [框架调试模式](../../../user/application_security/api_security_testing/checks/framework_debug_mode_check.md)
- [Heartbleed OpenSSL 漏洞](../../../user/application_security/api_security_testing/checks/heartbleed_open_ssl_check.md)
- [HTML 注入](../../../user/application_security/api_security_testing/checks/html_injection_check.md)
- [不安全的 HTTP 方法](../../../user/application_security/api_security_testing/checks/insecure_http_methods_check.md)
- [JSON 劫持](../../../user/application_security/api_security_testing/checks/json_hijacking_check.md)
- [JSON 注入](../../../user/application_security/api_security_testing/checks/json_injection_check.md)
- [开放重定向](../../../user/application_security/api_security_testing/checks/open_redirect_check.md)
- [OS 命令注入](../../../user/application_security/api_security_testing/checks/os_command_injection_check.md)
- [路径遍历](../../../user/application_security/api_security_testing/checks/path_traversal_check.md)
- [敏感文件](../../../user/application_security/api_security_testing/checks/sensitive_file_disclosure_check.md)
- [敏感信息](../../../user/application_security/api_security_testing/checks/sensitive_information_disclosure_check.md)
- [会话 Cookie](../../../user/application_security/api_security_testing/checks/session_cookie_check.md)
- [Shellshock](../../../user/application_security/api_security_testing/checks/shellshock_check.md)
- [SQL 注入](../../../user/application_security/api_security_testing/checks/sql_injection_check.md)
- [TLS 配置](../../../user/application_security/api_security_testing/checks/tls_server_configuration_check.md)
- [认证令牌](../../../user/application_security/api_security_testing/checks/authentication_token_check.md)
- [XML 注入](../../../user/application_security/api_security_testing/checks/xml_injection_check.md)
