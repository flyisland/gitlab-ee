---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 代码下拉列表中的自定义 Git 客户端
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- Status: 测试版

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。

将自定义客户端添加到项目页面上**代码**下拉列表的**打开方式**部分。用户随后可以直接将代码仓库克隆到极狐GitLab 默认未列出的 Git 客户端中。

<a id="configure-custom-clients"></a>

## 配置自定义客户端

先决条件：

- 您必须是管理员。
- 必须启用 `custom_code_dropdown_clients` 功能标志。

要配置条目：

1. 在右上角，选择**管理员**。
1. 选择**设置** > **代码仓库**。
1. 展开**通用**。
1. 选择**添加客户端**。
1. 填写各字段。
   至少输入一个 URL 模板。
   - **显示名称**：在下拉列表中向用户显示的标签。不翻译。
   - **SSH URL 模板**：用户选择 **SSH** 时打开的 URL。
   - **HTTPS URL 模板**：用户选择 **HTTPS** 时打开的 URL。
1. 选择**添加**。

要编辑条目，请在其旁边选择**编辑客户端**（{{< icon name="pencil" >}}），更新各字段，然后选择**保存**。

要删除条目，请在其旁边选择**删除客户端**（{{< icon name="remove" >}}），然后在确认对话框中选择**删除客户端**。

您最多可以配置 20 个条目。

<a id="url-templates"></a>

## URL 模板

每个 URL 模板必须恰好包含一次占位符 `{url}`。渲染代码下拉列表时，极狐GitLab 会在服务器端将该占位符替换为项目的百分号编码克隆 URL。

<a id="allowed-url-schemes"></a>

### 允许的 URL 方案

输入您要集成的客户端所期望的方案。任何 URL 方案都可接受，但以下方案除外，因为浏览器可以使用它们运行脚本或读取本地文件：

- `javascript`
- `data`
- `vbscript`
- `file`
- `blob`
- `filesystem`
- `about`

选择某个条目会将 URL 传递给用户操作系统为该方案注册的应用程序。

> [!note]
> 极狐GitLab 无法验证该应用程序会如何处理该 URL。请只添加您信任的客户端。

如果用户的操作系统上没有为该方案注册任何应用程序，浏览器将无法打开该链接。

<a id="examples"></a>

### 示例

以下条目已根据厂商文档进行验证。

在向用户发布条目之前，请务必根据您要集成的客户端的官方文档确认当前的 URI 方案。

| 显示名称 | SSH URL 模板 | HTTPS URL 模板 | 来源 |
|---|---|---|---|
| VSCodium | `vscodium://vscode.git/clone?url={url}` | `vscodium://vscode.git/clone?url={url}` | [VSCodium prepare_vscode.sh](https://github.com/VSCodium/vscodium/blob/master/prepare_vscode.sh) 将 `urlProtocol` 注册为 `vscodium`，复用上游 VS Code 的 `vscode.git/clone` 处理器。 |
| Tower | `gittower://openRepo/{url}` | `gittower://openRepo/{url}` | [Tower 文档（macOS）](https://www.git-tower.com/help/guides/integration/url-scheme/mac)、[Tower 文档（Windows）](https://www.git-tower.com/help/guides/integration/url-scheme/windows)|
| Sourcetree、Fork | `sourcetree://cloneRepo?cloneUrl={url}` | `sourcetree://cloneRepo?cloneUrl={url}` | Fork 会拦截同一方案。 |

某些客户端与单个 `{url}` 占位符模型不兼容。例如，
GitKraken 和 GitHub Desktop 还需要为每个代码仓库提供额外参数。其他客户端（如
Zed 和 Working Copy）出现在第三方文档中，但缺少官方的厂商 URI 方案参考。添加此类条目之前，请先与厂商核实。
