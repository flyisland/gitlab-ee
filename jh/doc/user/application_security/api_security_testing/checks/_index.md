---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: API 安全测试漏洞检查
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[API 安全测试](../_index.md)提供了漏洞检查，用于扫描被测 API 中的漏洞。

<a id="passive-checks"></a>

## 被动检查

| 检查                                                                        | 严重性 | 类型    | 配置文件 |
|:-----------------------------------------------------------------------------|:---------|:--------|:---------|
| [应用程序信息检查](application_information_check.md)            | 中   | 被动 | Passive, Passive-Quick, Active-Quick, Active-Full, Quick, Full |
| [明文认证检查](cleartext_authentication_check.md)          | 高     | 被动 | Passive, Passive-Quick, Active-Quick, Active-Full, Quick, Full |
| [JSON 劫持](json_hijacking_check.md)                                    | 中   | 被动 | Passive, Passive-Quick, Active-Quick, Active-Full, Quick, Full |
| [敏感信息](sensitive_information_disclosure_check.md)           | 高     | 被动 | Passive, Passive-Quick, Active-Quick, Active-Full, Quick, Full |
| [会话 Cookie](session_cookie_check.md)                                    | 中   | 被动 | Passive, Passive-Quick, Active-Quick, Active-Full, Quick, Full |

<a id="active-checks"></a>

## 主动检查

| 检查                                                                        | 严重性 | 类型    | 配置文件 |
|:-----------------------------------------------------------------------------|:---------|:--------|:---------|
| [CORS](cors_check.md)                                                        | 中   | 主动  | Active-Full, Full |
| [DNS 重绑定](dns_rebinding_check.md)                                      | 中   | 主动  | Active-Full, Full |
| [框架调试模式](framework_debug_mode_check.md)                        | 高     | 主动  | Active-Quick, Active-Full, Quick, Full |
| [Heartbleed OpenSSL 漏洞](heartbleed_open_ssl_check.md)             | 高     | 主动  | Active-Full, Full |
| [HTML 注入检查](html_injection_check.md)                              | 中   | 主动  | Active-Quick, Active-Full, Quick, Full |
| [不安全的 HTTP 方法](insecure_http_methods_check.md)                      | 中   | 主动  | Active-Quick, Active-Full, Quick, Full |
| [JSON 注入](json_injection_check.md)                                    | 中   | 主动  | Active-Quick, Active-Full, Quick, Full |
| [开放重定向](open_redirect_check.md)                                      | 中   | 主动  | Active-Full, Full |
| [操作系统命令注入](os_command_injection_check.md)                        | 高     | 主动  | Active-Quick, Active-Full, Quick, Full |
| [路径遍历](path_traversal_check.md)                                    | 高     | 主动  | Active-Full, Full |
| [敏感文件](sensitive_file_disclosure_check.md)                         | 中   | 主动  | Active-Full, Full |
| [Shellshock](shellshock_check.md)                                            | 高     | 主动  | Active-Full, Full |
| [SQL 注入](sql_injection_check.md)                                      | 高     | 主动  | Active-Quick, Active-Full, Quick, Full |
| [TLS 配置](tls_server_configuration_check.md)                       | 高     | 主动  | Active-Full, Full |
| [认证令牌](authentication_token_check.md)                        | 高     | 主动  | Active-Quick, Active-Full, Quick, Full |
| [XML 外部实体](xml_external_entity_check.md)                          | 高     | 主动  | Active-Full, Full |
| [XML 注入](xml_injection_check.md)                                      | 中   | 主动  | Active-Quick, Active-Full, Quick, Full |

<a id="api-security-testing-checks-by-profile"></a>

## 按配置文件划分的 API 安全测试检查

<a id="passive-quick"></a>

### Passive-Quick

- [应用程序信息检查](application_information_check.md)
- [明文认证检查](cleartext_authentication_check.md)
- [JSON 劫持](json_hijacking_check.md)
- [敏感信息](sensitive_information_disclosure_check.md)
- [会话 Cookie](session_cookie_check.md)

<a id="active-quick"></a>

### Active-Quick

- [应用程序信息检查](application_information_check.md)
- [明文认证检查](cleartext_authentication_check.md)
- [框架调试模式](framework_debug_mode_check.md)
- [HTML 注入检查](html_injection_check.md)
- [不安全的 HTTP 方法](insecure_http_methods_check.md)
- [JSON 劫持](json_hijacking_check.md)
- [JSON 注入](json_injection_check.md)
- [操作系统命令注入](os_command_injection_check.md)
- [敏感信息](sensitive_information_disclosure_check.md)
- [会话 Cookie](session_cookie_check.md)
- [SQL 注入](sql_injection_check.md)
- [认证令牌](authentication_token_check.md)
- [XML 注入](xml_injection_check.md)

<a id="active-full"></a>

### Active-Full

- [应用程序信息检查](application_information_check.md)
- [明文认证检查](cleartext_authentication_check.md)
- [CORS](cors_check.md)
- [DNS 重绑定](dns_rebinding_check.md)
- [框架调试模式](framework_debug_mode_check.md)
- [Heartbleed OpenSSL 漏洞](heartbleed_open_ssl_check.md)
- [HTML 注入检查](html_injection_check.md)
- [不安全的 HTTP 方法](insecure_http_methods_check.md)
- [JSON 劫持](json_hijacking_check.md)
- [JSON 注入](json_injection_check.md)
- [开放重定向](open_redirect_check.md)
- [操作系统命令注入](os_command_injection_check.md)
- [路径遍历](path_traversal_check.md)
- [敏感文件](sensitive_file_disclosure_check.md)
- [敏感信息](sensitive_information_disclosure_check.md)
- [会话 Cookie](session_cookie_check.md)
- [Shellshock](shellshock_check.md)
- [SQL 注入](sql_injection_check.md)
- [TLS 配置](tls_server_configuration_check.md)
- [认证令牌](authentication_token_check.md)
- [XML 注入](xml_injection_check.md)
- [XML 外部实体](xml_external_entity_check.md)

<a id="quick"></a>

### Quick

- [应用程序信息检查](application_information_check.md)
- [明文认证检查](cleartext_authentication_check.md)
- [框架调试模式](framework_debug_mode_check.md)
- [HTML 注入检查](html_injection_check.md)
- [不安全的 HTTP 方法](insecure_http_methods_check.md)
- [JSON 劫持](json_hijacking_check.md)
- [JSON 注入](json_injection_check.md)
- [操作系统命令注入](os_command_injection_check.md)
- [敏感信息](sensitive_information_disclosure_check.md)
- [会话 Cookie](session_cookie_check.md)
- [SQL 注入](sql_injection_check.md)
- [认证令牌](authentication_token_check.md)
- [XML 注入](xml_injection_check.md)

<a id="full"></a>

### Full

- [应用程序信息检查](application_information_check.md)
- [明文认证检查](cleartext_authentication_check.md)
- [CORS](cors_check.md)
- [DNS 重绑定](dns_rebinding_check.md)
- [框架调试模式](framework_debug_mode_check.md)
- [Heartbleed OpenSSL 漏洞](heartbleed_open_ssl_check.md)
- [HTML 注入检查](html_injection_check.md)
- [不安全的 HTTP 方法](insecure_http_methods_check.md)
- [JSON 劫持](json_hijacking_check.md)
- [JSON 注入](json_injection_check.md)
- [开放重定向](open_redirect_check.md)
- [操作系统命令注入](os_command_injection_check.md)
- [路径遍历](path_traversal_check.md)
- [敏感文件](sensitive_file_disclosure_check.md)
- [敏感信息](sensitive_information_disclosure_check.md)
- [会话 Cookie](session_cookie_check.md)
- [Shellshock](shellshock_check.md)
- [SQL 注入](sql_injection_check.md)
- [TLS 配置](tls_server_configuration_check.md)
- [认证令牌](authentication_token_check.md)
- [XML 注入](xml_injection_check.md)
- [XML 外部实体](xml_external_entity_check.md)
