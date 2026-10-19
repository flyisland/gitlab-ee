---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 VS Code 扩展配合自签名证书
---

即使您的极狐 GitLab 实例使用自签名 SSL 证书，您仍然可以使用极狐 GitLab for VS Code 扩展。

如果您也使用代理连接到您的极狐 GitLab 实例，请在 [议题 314](https://jihulab.com/gitlab-cn/gitlab-vscode-extension/-/issues/314) 中告知我们。如果在完成这些步骤后您仍有连接问题，请查阅 [史诗 6244](https://jihulab.com/groups/gitlab-cn/-/epics/6244)，其中链接了极狐 GitLab for VS Code 扩展的所有现有 SSL 议题。

<a id="use-the-extension-with-a-self-signed-ca"></a>

## 使用扩展配合自签名 CA

前提条件：

- 您的极狐 GitLab 实例使用由自签名证书颁发机构 (CA) 签署的证书。
- 您的极狐 GitLab for VS Code 版本为 6.51.1 或更高版本。
- 您的 VS Code 版本为 1.101.2 (2025 年 5 月) 或更高版本。
- `gitlab.ca` VS Code 设置**未**在使用中。

1. 确保您的 CA 证书已正确添加到系统中以便扩展工作。VS Code 读取系统证书存储，并更改所有 node `http` 请求以信任证书：

   ```mermaid
   %%{init: { "fontFamily": "GitLab Sans" }}%%
   graph LR
      accTitle: 自签名证书链
      accDescr: 显示签署极狐 GitLab 实例证书的自签名 CA。

      A[自签名 CA] -- signed --> B[您的极狐 GitLab 实例证书]
   ```

   必须明确指定极狐 GitLab 实例证书的 CA 为受信任的 CA。如果使用了中间证书，则这些证书必须在系统上可用。如果整个链无法成功验证，扩展内的网络连接将无法进行身份验证。

   更多信息，请参阅 Visual Studio Code 议题跟踪器中的 [在 WSL 中安装 Python 支持时出现自签名证书错误](https://github.com/microsoft/vscode/issues/131836#issuecomment-909983815)。

1. 在您的 VS Code `settings.json` 中，设置 `"http.systemCertificates": true`。默认值为 `true`，因此您可能不需要更改此值。
1. 完成以下针对您的操作系统的部分中的说明。

<a id="windows"></a>

### Windows

> [!note]
> 这些说明已在 Windows 10 和 VS Code 1.60.0 上经过测试。

确保证书存储中可以看到您的自签名 CA：

1. 打开命令提示符。
1. 运行 `certmgr`。
1. 确保您在 **受信任的根证书颁发机构** > **证书** 中看到您的证书。

<a id="linux"></a>

### Linux

> [!note]
> 这些说明已在 Arch Linux `5.14.3-arch1-1` 和 VS Code 1.60.0 上经过测试。

1. 使用操作系统的工具确认您可以将我们的自签名 CA 添加到系统：
   - `update-ca-trust` (Fedora, RHEL, CentOS)
   - `update-ca-certificates` (Ubuntu, Debian, OpenSUSE, SLES)
   - `trust` (Arch)
1. 确认 CA 证书位于 `/etc/ssl/certs/ca-certificates.crt` 或 `/etc/ssl/certs/ca-bundle.crt`。
   VS Code [检查此位置](https://github.com/microsoft/vscode/issues/131836#issuecomment-909983815)。

<a id="macos"></a>

### MacOS

> [!note]
> 这些说明已在 macOS Tahoe 26、VS Code 1.101.2 和极狐 GitLab for VS Code 6.51.1 上经过测试。

确保在钥匙串中看到自签名 CA：

1. 前往 **访达** > **应用程序** > **实用工具** > **钥匙串访问**。
1. 在左侧列中，选择 **系统**。
1. 在列表中找到您的自签名 CA 证书。
1. 右键单击证书并选择 **显示简介**。
1. 展开 **信任** 部分。
1. 确保 **安全套接字层 (SSL)** 选项设置为“始终信任”。
