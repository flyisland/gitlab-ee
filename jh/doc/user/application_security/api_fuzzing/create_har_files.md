---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何使用浏览器和工具创建 HAR 文件，以捕获 HTTP 流量用于 Web API 模糊测试，并检查其中是否包含敏感数据。
title: 创建 HAR 文件
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

HTTP 归档（HAR）格式文件是用于交换 HTTP 请求和 HTTP 响应相关信息的行业标准。HAR 文件的内容为 JSON 格式，包含浏览器与网站的交互信息。常用的文件扩展名为 `.har`。

HAR 文件可用于在 CI/CD 流水线中执行 [Web API 模糊测试](configuration/enabling_the_analyzer.md#http-archive-har)。

> [!warning]
> HAR 文件存储 Web 客户端与 Web 服务器之间交换的信息。它也可能存储敏感信息，例如身份验证令牌、API 密钥和会话 cookie。建议您在将 HAR 文件添加到代码仓库之前先检查其内容。

<a id="har-file-creation"></a>

## 创建 HAR 文件

您可以手动创建 HAR 文件，也可以使用专门用于记录 Web 会话的工具来创建。建议使用专门的工具。不过，务必确保这些工具创建的文件不会泄露敏感信息，并且可以安全使用。

以下工具可根据您的网络活动生成 HAR 文件。它们会自动记录您的网络活动并生成 HAR 文件：

- GitLab HAR recorder
- Insomnia API 客户端
- Fiddler 调试代理
- Safari Web 浏览器
- Chrome Web 浏览器
- Firefox Web 浏览器

> [!warning]
> HAR 文件可能包含敏感信息，例如身份验证令牌、API 密钥和会话 cookie。您应在将 HAR 文件添加到代码仓库之前先检查其内容。

<a id="gitlab-har-recorder"></a>

### GitLab HAR recorder

[GitLab HAR Recorder](https://gitlab.com/gitlab-org/security-products/har-recorder) 是一个用于记录 HTTP 消息并将其保存到 HAR 文件的命令行工具。

<a id="install-gitlab-har-recorder"></a>

#### 安装 GitLab HAR recorder

先决条件：

- 安装 Python 3.6 或更高版本。
- 对于 Microsoft Windows，您还必须安装 `Microsoft Visual C++ 14.0`。它包含在 [Visual Studio 下载页面](https://visualstudio.microsoft.com/downloads/)的 Build Tools for Visual Studio 中。
- 安装 HAR Recorder。

安装 GitLab HAR recorder：

  ```shell
  pip install gitlab-har-recorder --extra-index-url https://gitlab.com/api/v4/projects/22441624/packages/pypi/simple
  ```

<a id="create-a-har-file-with-gitlab-har-recorder"></a>

#### 使用 GitLab HAR recorder 创建 HAR 文件

1. 使用代理端口和 HAR 文件名启动记录器。
1. 使用代理完成浏览器操作。
   1. 确保使用了代理！
1. 停止记录器。

<a id="insomnia-api-client"></a>

### Insomnia API 客户端

[Insomnia API 客户端](https://insomnia.rest/) 是一款 API 设计工具，用途广泛，可帮助您设计、描述和测试 API。您也可以使用它生成可用于 [Web API 模糊测试](configuration/enabling_the_analyzer.md#http-archive-har)的 HAR 文件。

<a id="create-a-har-file-with-the-insomnia-api-client"></a>

#### 使用 Insomnia API 客户端创建 HAR 文件

1. 定义或导入您的 API。
   - Postman v2。
   - Curl。
   - OpenAPI v2、v3。
1. 验证每个 API 调用是否正常工作。
   - 如果您导入的是 OpenAPI 规范，请逐一检查并添加可用的数据。
1. 选择 **API** > **导入/导出**。
1. 选择 **导出数据** > **当前工作区**。
1. 选择要包含在 HAR 文件中的请求。
1. 选择 **导出**。
1. 在 **选择导出类型** 下拉列表中选择 **HAR -- HTTP 归档格式**。
1. 选择 **完成**。
1. 输入 HAR 文件的位置和文件名。

<a id="fiddler-debugging-proxy"></a>

### Fiddler 调试代理

[Fiddler](https://www.telerik.com/fiddler) 是一款 Web 调试工具。它可捕获 HTTP 和 HTTP(S) 网络流量，并允许您检查每个请求。它还允许您以 HAR 格式导出请求和响应。

<a id="create-a-har-file-with-fiddler"></a>

#### 使用 Fiddler 创建 HAR 文件

1. 前往 [Fiddler 主页](https://www.telerik.com/fiddler)并登录。如果您还没有账号，请创建一个账号。
1. 浏览调用 API 的页面。Fiddler 会自动捕获这些请求。
1. 选择一个或多个请求，然后在上下文菜单中选择 **导出** > **所选会话**。
1. 在 **选择格式** 下拉列表中选择 **HTTPArchive v1.2**。
1. 输入文件名并选择 **保存**。

Fiddler 会显示一条弹出消息，确认导出成功。

<a id="safari-web-browser"></a>

### Safari Web 浏览器

[Safari](https://www.apple.com/safari/) 是由 Apple 维护的 Web 浏览器。随着 Web 开发的发展，浏览器支持新的功能。使用 Safari，您可以查看网络流量并将其导出为 HAR 文件。

<a id="create-a-har-file-with-safari"></a>

#### 使用 Safari 创建 HAR 文件

先决条件：

- 启用 `Develop` 菜单项。
  1. 打开 Safari 的偏好设置。按 <kbd>Command</kbd>+<kbd>,</kbd>，或从菜单中选择 **Safari** > **偏好设置**。
  1. 选择 **高级** 标签页，然后选择 `Show Develop menu item in menu bar`。
  1. 关闭 **偏好设置** 窗口。

1. 打开 **网页检查器**。按 <kbd>Option</kbd>+<kbd>Command</kbd>+<kbd>i</kbd>，或从菜单中选择 **开发** > **显示网页检查器**。
1. 选择 **网络** 标签页，然后选择 **保留日志**。
1. 浏览调用 API 的页面。
1. 打开 **网页检查器** 并选择 **网络** 标签页。
1. 右键单击要导出的请求，然后选择 **导出 HAR**。
1. 输入文件名并选择 **保存**。

<a id="chrome-web-browser"></a>

### Chrome Web 浏览器

[Chrome](https://www.google.com/chrome/) 是由 Google 维护的 Web 浏览器。随着 Web 开发的发展，浏览器支持新的功能。使用 Chrome，您可以查看网络流量并将其导出为 HAR 文件。

<a id="create-a-har-file-with-chrome"></a>

#### 使用 Chrome 创建 HAR 文件

1. 从 Chrome 上下文菜单中选择 **检查**。
1. 选择 **网络** 标签页。
1. 选择 **保留日志**。
1. 浏览调用 API 的页面。
1. 选择一个或多个请求。
1. 右键单击并选择 **将所有内容保存为 HAR（包含内容）**。
1. 输入文件名并选择 **保存**。
1. 要追加其他请求，请选择这些请求并将它们保存到同一文件。

<a id="firefox-web-browser"></a>

### Firefox Web 浏览器

[Firefox](https://www.mozilla.org/en-US/firefox/new/) 是由 Mozilla 维护的 Web 浏览器。随着 Web 开发的发展，浏览器支持新的功能。使用 Firefox，您可以查看网络流量并将其导出为 HAR 文件。

<a id="create-a-har-file-with-firefox"></a>

#### 使用 Firefox 创建 HAR 文件

1. 从 Firefox 上下文菜单中选择 **检查**。
1. 选择 **网络** 标签页。
1. 浏览调用 API 的页面。
1. 检查 **网络** 标签页并确认请求正在被记录。如果出现消息
   `Perform a request or Reload the page to see detailed information about network activity`，
   请选择 **重新加载** 开始记录请求。
1. 选择一个或多个请求。
1. 右键单击并选择 **全部保存为 HAR**。
1. 输入文件名并选择 **保存**。
1. 要追加其他请求，请选择这些请求并将它们保存到同一文件。

<a id="har-verification"></a>

## HAR 验证

在使用 HAR 文件之前，务必确保它们不会泄露任何敏感信息。

对于每个 HAR 文件，您应：

- 查看 HAR 文件的内容
- 检查 HAR 文件中是否包含敏感信息
- 编辑或移除敏感信息

<a id="view-har-file-contents"></a>

### 查看 HAR 文件内容

建议使用能够以结构化方式呈现 HAR 文件内容的工具来查看。网上有多个 HAR 文件查看器。如果您不想上传 HAR 文件，可以使用安装在您计算机上的工具。HAR 文件使用 JSON 格式，因此也可以在文本编辑器中查看。

推荐用于查看 HAR 文件的工具包括：

- [HAR Viewer](http://www.softwareishard.com/har/viewer/) -（在线）
- [Google Admin Toolbox HAR Analyzer](https://toolbox.googleapps.com/apps/har_analyzer/) -（在线）
- [Fiddler](https://www.telerik.com/fiddler) - 本地
- [Insomnia API 客户端](https://insomnia.rest/) - 本地

<a id="review-har-file-content"></a>

## 检查 HAR 文件内容

检查 HAR 文件中是否存在以下任何内容：

- 可能有助于获取您的应用程序访问权限的信息，例如：身份验证令牌、cookie 和 API 密钥。
- [个人身份信息（PII）](https://en.wikipedia.org/wiki/Personal_data)。

强烈建议您[编辑或移除](#edit-or-remove-sensitive-information)任何敏感信息。

您可以先使用以下内容作为检查清单。它并非详尽无遗的列表。

- 查找密钥。例如：如果您的应用程序需要身份验证，请检查常见位置或身份验证信息：
  - 与身份验证相关的请求头。例如：cookie、authorization。这些请求头可能包含有效信息。
  - 与身份验证相关的请求。这些请求的正文可能包含用户凭据或令牌等信息。
  - 会话令牌。会话令牌可能授予对您应用程序的访问权限。这些令牌的位置可能各不相同。它们可能位于请求头、查询参数或正文中。
- 查找个人身份信息
  - 例如，如果您的应用程序检索用户列表及其个人数据：电话、姓名、电子邮件。
  - 身份验证信息也可能包含个人信息。

<a id="edit-or-remove-sensitive-information"></a>

## 编辑或移除敏感信息

编辑或移除在 [HAR 文件内容检查](#review-har-file-content)过程中发现的敏感信息。HAR 文件是 JSON 文件，可以在任何文本编辑器中编辑。

编辑 HAR 文件后，请在 HAR 文件查看器中打开它，以验证其格式和结构是否完好。
