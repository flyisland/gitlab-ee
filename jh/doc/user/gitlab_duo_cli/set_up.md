---
stage: AI Clients
group: Developer Clients
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 安装并认证极狐GitLab Duo CLI。
title: 设置极狐GitLab Duo CLI
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以通过 [GitLab CLI](https://gitlab.cn/docs/cli/)（`glab`）使用极狐GitLab Duo CLI。借助 GitLab CLI，您可以访问其他极狐GitLab 功能，并且只需使用 OAuth 或个人访问令牌认证一次。

或者，您也可以将极狐GitLab Duo CLI（`duo`）作为独立 AI 工具安装和使用，并使用个人访问令牌单独认证。

两种设置都支持交互式和无头模式，以及所有极狐GitLab Duo CLI 选项、命令和功能。

<a id="prerequisites"></a>

## 前提条件

- 极狐GitLab 19.2 或更高版本。
- [极狐GitLab Duo Agent Platform 的前提条件](../duo_agent_platform/_index.md#prerequisites)。
- 对于极狐GitLab 私有化部署，需要[访问极狐GitLab Duo CLI](_index.md#manage-gitlab-duo-cli-access)。
- 已设置[默认极狐GitLab Duo 命名空间](../profile/preferences.md#namespace-resolution-in-your-local-environment)，或已打开一个可访问极狐GitLab Duo 的项目。

> [!note]
> 如果您使用的是极狐GitLab 18.11 至 19.1，可以通过开启 [测试版和实验性功能](../duo_agent_platform/turn_on_off.md#turn-on-beta-and-experimental-features)来使用最新版本的极狐GitLab Duo CLI。

<a id="with-the-gitlab-cli"></a>

## 通过 GitLab CLI 使用

前提条件：

- [GitLab CLI](https://gitlab.cn/docs/cli/) 1.107.0 或更高版本。
- GitLab CLI 已[认证](https://gitlab.cn/docs/cli/#authenticate-with-gitlab)。

要通过 GitLab CLI 设置极狐GitLab Duo CLI：

1. 运行极狐GitLab Duo CLI 的 `glab` 命令：

   ```shell
   glab duo cli
   ```

1. 按照提示安装极狐GitLab Duo CLI 二进制文件。

GitLab CLI 会自动处理认证，因此您可以立即开始使用极狐GitLab Duo CLI。

<a id="without-the-gitlab-cli"></a>

## 不使用 GitLab CLI

要将极狐GitLab Duo CLI 作为独立工具使用，请先安装，然后进行认证。

<a id="install"></a>

### 安装

要将极狐GitLab Duo CLI 作为编译后的二进制文件安装，请下载并运行安装脚本。

在 macOS 和 Linux 上：

```shell
bash <(curl --fail --silent --show-error --location "https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/raw/main/packages/cli/scripts/install_duo_cli.sh")
```

在 Windows 上：

```shell
irm "https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/raw/main/packages/cli/scripts/install_duo_cli.ps1" | iex
```

<a id="authenticate"></a>

### 认证

> [!note]
> 如果您首次运行 `duo` 时，系统上已安装并认证了 `glab`，则 `duo` 会自动将 `glab` 用作凭据助手。您无需单独认证。这要求 `glab` 1.85.2 或更高版本以及 `duo` 8.68.0 或更高版本。
>
> 如果您在此功能可用之前已认证 `duo`，并希望改用 `glab` 作为凭据助手，请从 `~/.gitlab/storage.json` 中删除您的认证设置。

前提条件：

- 具有 `api` 权限的[个人访问令牌](../profile/personal_access_tokens.md)。

要认证：

1. 在终端中运行 `duo`。首次运行极狐GitLab Duo CLI 时，会出现配置界面。
1. 输入 **极狐GitLab 实例 URL**，然后按 <kbd>Enter</kbd>：
   - 对于 JihuLab.com，输入 `https://jihulab.com`。
   - 对于极狐GitLab 私有化部署，输入您的实例 URL。
1. 对于 **极狐GitLab 令牌**，输入您的个人访问令牌。
1. 要保存并退出 CLI，请按 <kbd>Enter</kbd>。
1. 要重启 CLI，请在终端中运行 `duo`。

要在初始设置后修改配置，请使用 `duo config edit`。

<a id="authenticate-with-environment-variables"></a>

### 使用环境变量认证

前提条件：

- 具有 `api` 权限的[个人访问令牌](../profile/personal_access_tokens.md)。

极狐GitLab Duo CLI 遵循标准代理环境变量：

- `HTTP_PROXY` 或 `http_proxy`：HTTP 请求的代理 URL。
- `HTTPS_PROXY` 或 `https_proxy`：HTTPS 请求的代理 URL。
- `NO_PROXY` 或 `no_proxy`：以逗号分隔的、不经过代理的主机列表。

要使用环境变量认证：

1. 将 `GITLAB_TOKEN` 或 `GITLAB_OAUTH_TOKEN` 设置为您的个人访问令牌。

   ```shell
   export GITLAB_TOKEN="<your-personal-access-token>"
   ```

1. 可选。将 `GITLAB_BASE_URL` 或 `GITLAB_URL` 设置为您的自定义极狐GitLab 实例 URL，例如 `https://gitlab.example.com`。默认值为 `https://gitlab.com`。

   ```shell
   export GITLAB_BASE_URL="<your-instance-url>"
   ```

此方法适用于无头模式、CI/CD 流水线以及无法进行交互式认证的脚本化工作流。
