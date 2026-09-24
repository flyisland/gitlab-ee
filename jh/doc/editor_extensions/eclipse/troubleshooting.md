---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Connect and use GitLab Duo in Eclipse.
title: Eclipse 排障
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: GitLab Duo Core、Pro 或 Enterprise
- Offering: JihuLab.com，私有化部署
- Status: Beta

{{< /details >}}

{{< history >}}

- 于 GitLab 17.11 从实验阶段变更为 Beta。

{{< /history >}}

<a id="review-the-error-log"></a>

## 审查错误日志

1. 在 IDE 的菜单栏中，选择 **窗口**。
1. 展开 **显示视图**，然后选择 **错误日志**。
1. 搜索引用 `gitlab-eclipse-plugin` 插件的错误。

<a id="locate-the-workspace-log-file"></a>

## 找到工作区日志文件

工作区日志文件 `.log` 位于目录 `<your-eclipse-workspace>/.metadata` 中。

<a id="enable-gitlab-language-server-debug-logs"></a>

## 启用 GitLab Language Server 调试日志

启用 GitLab Language Server 调试日志：

1. 在 IDE 中打开偏好设置：
   - 对于 macOS，选择 **Eclipse** > **设置**。
   - 对于 Windows 或 Linux，选择 **窗口** > **首选项**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 在 **Language Server 日志级别** 中输入 `debug`。
1. 选择 **应用并关闭**。

调试日志记录在 `language_server.log` 文件中。要查看此文件，请执行以下任一操作：

- 转到以下目录，将 `<user>` 和 `<eclipse-version>` 替换为相应的值：
  - macOS：`/Users/<user>/eclipse-workspace/.metadata/.plugins/com.gitlab.eclipse.gitlab-eclipse-plugin`
  - Windows：`<drive>:\Users\<user>\eclipse-workspace\.metadata\.plugins\com.gitlab.eclipse.gitlab-eclipse-plugin`
  - Linux：`/home/<user>/eclipse-workspace/.metadata/.plugins/com.gitlab.eclipse.gitlab-eclipse-plugin`
- 打开 **错误日志**。搜索日志 `Language server logs saved to: <file>.`，其中 `<file>` 是 `language_server.log` 文件的绝对路径。

<a id="required-information-for-support"></a>

## 支持所需信息

创建支持请求时，请提供以下信息：

1. 您当前的 GitLab for Eclipse 插件版本。
   1. 在 IDE 中打开 `About Eclipse` 对话框。
      - 对于 macOS，选择 **Eclipse** > **About Eclipse**。
      - 对于 Windows 或 Linux，选择 **帮助** > **About Eclipse IDE**。
   1. 选择 **安装详情**。
   1. 找到 **GitLab for Eclipse** 并复制 **版本** 值。
1. 您的 Eclipse 版本。
   1. 在 IDE 中打开 `About Eclipse` 对话框。
      - 对于 macOS，选择 **Eclipse** > **About Eclipse**。
      - 对于 Windows 或 Linux，选择 **帮助** > **About Eclipse IDE**。
1. 您的操作系统。
1. 您使用的是 JihuLab.com 还是私有化部署实例？
1. 您是否使用代理？
1. 您是否使用自签名证书？
1. 工作区日志。
1. Language Server 调试日志。
1. 如适用，提供问题视频或截图。
1. 如适用，提供重现问题的步骤。
1. 如适用，提供尝试解决问题的步骤。

<a id="certificate-errors"></a>

## 证书错误

如果您的机器通过代理连接到 极狐GitLab 实例，您可能会在 Eclipse 中遇到 SSL 证书错误。极狐GitLab Duo 会尝试检测系统存储中的证书；但是，Language Server 无法这样做。如果您看到来自 Language Server 的证书错误，请尝试启用传递证书颁发机构 (CA) 证书的选项：

要执行此操作：

1. 在 IDE 的右下角，选择 GitLab 图标。
1. 在对话框中，选择 **显示设置**。这将打开 **设置** 对话框并定位到 **工具** > **极狐GitLab Duo**。
1. 选择 **GitLab Language Server** 以展开该部分。
1. 选择 **HTTP 代理选项** 以展开。
1. 执行以下任一操作：
   - 在 **Language Server** 下，对于 **CA 证书**，选择 **浏览** 并选择包含 CA 证书的 `.pem` 文件。
   - 在 **连接** 下，选中 **忽略证书错误** 复选框。
1. 选择 **应用并关闭**。

<a id="ignore-certificate-errors"></a>

### 忽略证书错误

如果 极狐GitLab Duo 仍然无法连接，您可能需要忽略证书错误。启用调试模式后，您可能在 GitLab Language Server 日志中看到错误：

```plaintext
2024-10-31T10:32:54:165 [错误]: 获取: 请求 https://jihulab.com/api/v4/personal_access_tokens/self 失败，原因是:
无法获取本地颁发者证书
FetchError: 请求 https://jihulab.com/api/v4/personal_access_tokens/self 失败，原因: 无法获取本地颁发者证书
```

从设计上来说，此设置存在安全风险：这些错误会提醒您潜在的安全漏洞。只有完全确定问题是由代理引起时，才应启用此设置。

前提条件：

- 您已在系统浏览器中验证了证书链，或者您的机器管理员已确认可以安全忽略此错误。

要执行此操作：

1. 参考 Eclipse 关于 SSL 证书的文档。
1. 在 IDE 中打开偏好设置：
   - 对于 macOS，选择 **Eclipse** > **设置**。
   - 对于 Windows 或 Linux，选择 **窗口** > **首选项**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 确认您的默认浏览器信任 **URL to GitLab instance** 值。
1. 选中 **忽略证书错误** 复选框。
1. 选择 **验证设置**。
1. 选择 **应用并关闭**。