---
stage: Create
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: Learn about the GitLab Language Server.
title: 极狐GitLab 语言服务器
---

极狐GitLab Language Server 为各种 IDE 中的极狐GitLab 编辑器扩展提供支持。

<a id="configure-the-language-server-to-use-a-proxy"></a>

## 配置语言服务器以使用代理

`gitlab-lsp` 子进程使用 `proxy-from-env` NPM 模块从这些环境变量中确定代理设置：

- `NO_PROXY`
- `HTTPS_PROXY`
- `http_proxy`（小写）

要配置语言服务器以使用代理，请执行以下操作：

{{< tabs >}}

{{< tab title="Visual Studio Code" >}}

1. 在 Visual Studio Code 中，打开您的[用户或工作区设置](https://code.visualstudio.com/docs/getstarted/settings)。
1. 配置 [`http.proxy`](https://code.visualstudio.com/docs/setup/network#_legacy-proxy-server-support) 指向您的 HTTP 代理。
1. 重启 Visual Studio Code 以确保连接到极狐GitLab 使用最新的代理设置。

{{< /tab >}}

{{< tab title="JetBrains IDEs" >}}

1. 在 JetBrains IDE 中，配置 [HTTP Proxy](https://www.jetbrains.com/help/idea/settings-http-proxy.html) 设置。
1. 重启您的 IDE 以确保连接到极狐GitLab 使用最新的代理设置。

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排除

<a id="enable-proxy-authentication"></a>

### 启用代理认证

使用认证代理时，您可能会遇到 `407 Access Denied (authentication_failed)` 错误：

```plaintext
Request failed: Can't add GitLab account for https://JihuLab.com. Check your instance URL and network connection.
Fetching resource from https://JihuLab.com/api/v4/personal_access_tokens/self failed
```

要在语言服务器中启用代理认证，请按照以下步骤为您的 IDE 配置：

{{< tabs >}}

{{< tab title="Visual Studio Code" >}}

1. 打开您的用户或工作区[设置](https://code.visualstudio.com/docs/getstarted/settings)。
1. 配置 [`http.proxy`](https://code.visualstudio.com/docs/setup/network#_legacy-proxy-server-support)，包括用户名和密码，以使用您的 HTTP 代理进行认证。
1. 重启 Visual Studio Code 以确保连接到极狐GitLab 使用最新的代理设置。

{{< alert type="note" >}}

VS Code 扩展不支持在 VS Code 中使用旧版 [`http.proxyAuthorization`](https://code.visualstudio.com/docs/setup/network#_legacy-proxy-server-support) 设置来通过 HTTP 代理对语言服务器进行认证。支持已在 [issue 1672](https://jihulab.com/gitlab-cn/gitlab-vscode-extension/-/issues/1672) 中提出。

{{< /alert >}}

{{< /tab >}}

{{< tab title="JetBrains IDEs" >}}

1. 在 JetBrains IDE 中配置 [HTTP Proxy](https://www.jetbrains.com/help/idea/settings-http-proxy.html) 设置。
   1. 如果使用**手动代理配置**，请输入您的凭据到**代理认证**下，并选择**记住**。
1. 重启您的 JetBrains IDE 以确保连接到极狐GitLab 使用最新的代理设置。

{{< /tab >}}

{{< /tabs >}}

