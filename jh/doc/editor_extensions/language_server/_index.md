---
stage: AI Clients
group: Duo Client SDK
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解 GitLab Language Server。
title: GitLab Language Server
---

[GitLab Language Server](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp)
为各种 IDE 中的多个 GitLab 编辑器扩展提供支持。

<a id="configure-the-language-server-to-use-a-proxy"></a>

## 配置语言服务器以使用代理

`gitlab-lsp` 子进程使用 [`proxy-from-env`](https://www.npmjs.com/package/proxy-from-env?activeTab=readme) NPM 模块，根据以下环境变量确定代理设置：

- `NO_PROXY`
- `HTTPS_PROXY`
- `http_proxy`（小写）

要配置语言服务器以使用代理：

{{< tabs >}}

{{< tab title="Visual Studio Code" >}}

1. 在 Visual Studio Code 中，打开您的[用户或工作区设置](https://code.visualstudio.com/docs/configure/settings)。
1. 配置 [`http.proxy`](https://code.visualstudio.com/docs/setup/network#_legacy-proxy-server-support)
   以指向您的 HTTP 代理。
1. 重启 Visual Studio Code，以确保与极狐GitLab 的连接使用最新的代理设置。

{{< /tab >}}

{{< tab title="JetBrains IDEs" >}}

1. 在您的 JetBrains IDE 中，配置 [HTTP 代理](https://www.jetbrains.com/help/idea/settings-http-proxy.html)设置。
1. 重启您的 IDE，以确保与极狐GitLab 的连接使用最新的代理设置。
1. 从 **工具** > **极狐GitLab Duo** 菜单中，选择 **验证设置**。确保健康检查通过。

{{< /tab >}}

{{< /tabs >}}

<a id="connect-gitlab-duo-directly"></a>

## 直接连接极狐GitLab Duo

当您配置语言服务器以使用代理时，
由语言服务器处理的极狐GitLab Duo 和其他极狐GitLab 功能的流量
默认使用该代理。如果您的代理阻止此流量，请配置您的编辑器扩展以直接连接该流量。

直接连接仅适用于由语言服务器处理的流量。其他编辑器扩展的网络请求继续使用编辑器的代理配置。

{{< tabs >}}

{{< tab title="Visual Studio Code" >}}

1. 在 Visual Studio Code 中，打开您的[用户设置](https://code.visualstudio.com/docs/configure/settings)。
1. 搜索 `gitlab.duo.proxy.directConnection` 并启用它。

{{< /tab >}}

{{< tab title="JetBrains IDEs" >}}

1. 在您的 JetBrains IDE 中，转到 **设置** > **工具** > **极狐GitLab Duo**。
1. 在 **高级** > **GitLab Language Server** 下，选择 **直接从语言服务器连接极狐GitLab Duo**。
1. 选择 **确定** 或 **应用**。

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排除

<a id="update-your-editor-extension"></a>

### 更新您的编辑器扩展

语言服务器与每个 GitLab 编辑器扩展捆绑在一起。为确保您拥有最新的功能和缺陷修复，请更新到扩展的最新版本：

- [Eclipse 的更新说明](../eclipse/_index.md#update-the-plugin)
- [JetBrains IDE 的更新说明](../jetbrains_ide/_index.md#update-the-extension)
- [Neovim 的更新说明](../neovim/_index.md#update-the-extension)
- [Visual Studio 的更新说明](../visual_studio/_index.md#update-the-extension)
- [Visual Studio Code 的更新说明](../visual_studio_code/_index.md#update-the-extension)

<a id="enable-proxy-authentication"></a>

### 启用代理身份验证

使用经过身份验证的代理时，您可能会遇到 `407 Access Denied (authentication_failed)` 错误：

```plaintext
Request failed: Can't add GitLab account for https://gitlab.com. Check your instance URL and network connection.
Fetching resource from https://jihulab.com/api/v4/personal_access_tokens/self failed
```

要在语言服务器中启用代理身份验证，请按照您的 IDE 对应的步骤操作：

{{< tabs >}}

{{< tab title="Visual Studio Code" >}}

1. 在 Visual Studio Code 中，打开您的[用户或工作区设置](https://code.visualstudio.com/docs/configure/settings)。
1. 配置 [`http.proxy`](https://code.visualstudio.com/docs/setup/network#_legacy-proxy-server-support)，
   包括用户名和密码，以通过您的 HTTP 代理进行身份验证。
1. 重启 Visual Studio Code，以确保与极狐GitLab 的连接使用最新的代理设置。

> [!note]
> VS Code 扩展不支持 VS Code 中用于通过 HTTP 代理对语言服务器进行身份验证的旧版
> [`http.proxyAuthorization`](https://code.visualstudio.com/docs/setup/network#_legacy-proxy-server-support)
> 设置。相关支持已在
> [议题 1672](https://gitlab.com/gitlab-org/gitlab-vscode-extension/-/issues/1672)中提出。

{{< /tab >}}

{{< tab title="JetBrains IDEs" >}}

1. 在您的 JetBrains IDE 中配置 [HTTP 代理](https://www.jetbrains.com/help/idea/settings-http-proxy.html)设置。
   1. 如果使用 **手动代理配置**，请在 **代理认证** 下输入您的凭据，并选择 **记住**。
1. 重启您的 JetBrains IDE，以确保与极狐GitLab 的连接使用最新的代理设置。
1. 从 **工具** > **极狐GitLab Duo** 菜单中，选择 **验证设置**。确保健康检查通过。

{{< /tab >}}

{{< /tabs >}}

> [!note]
> Bearer 身份验证已在[议题 548](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/issues/548)中提出。
