---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: DAST 配置文件
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

DAST 站点配置文件和扫描器配置文件保存与您的应用程序以及用于评估这些应用程序的扫描器相关的信息。定义配置文件后，您可以将其用于流水线和按需 DAST 作业。

DAST 配置文件、DAST 扫描器配置文件和 DAST 站点配置文件的创建、更新和删除都会记录在[审计事件记录](../../../administration/compliance/audit_event_reports.md)中。

<a id="site-profile"></a>

## 站点配置文件

站点配置文件定义了要由 DAST 扫描的已部署应用程序、网站或 API 的属性和配置详情。

站点配置文件包含：

- **配置文件名称**：您为要扫描的站点指定的名称。当站点配置文件在 `.gitlab-ci.yml` 或按需扫描中被引用时，无法重命名。
- **站点类型**：要扫描的目标类型，可以是网站扫描或 API 扫描。
- **目标 URL**：DAST 运行所针对的 URL。
- **排除的 URL**：要从扫描中排除的 URL 列表，以逗号分隔。
  您可以使用 [RE2 风格的正则表达式](https://github.com/google/re2/wiki/Syntax)。正则表达式不能包含问号（`?`）字符，因为它是合法的 URL 字符。
- **请求头**：HTTP 请求头列表，包括名称和值，以逗号分隔。这些请求头会添加到 DAST 发出的每个请求中。
- **身份验证**：
  - **已认证 URL**：目标网站上包含登录 HTML 表单的页面 URL。用户名和密码会随登录表单一起提交，以创建已认证的扫描。
  - **用户名**：用于向网站进行身份验证的用户名。
  - **密码**：用于向网站进行身份验证的密码。
  - **用户名字段**：登录 HTML 表单中用户名字段的名称。
  - **密码字段**：登录 HTML 表单中密码字段的名称。
  - **提交字段**：登录 HTML 表单中，选中后即提交该表单的元素的 `id` 或 `name`。
- **扫描方法**：执行 API 测试的方法类型。支持的方法有 OpenAPI、Postman Collections、HTTP Archive (HAR) 或 GraphQL。
  - **GraphQL 端点路径**：GraphQL 端点的路径。此路径会与目标 URL 拼接，以提供扫描要测试的 URI。GraphQL 端点必须支持内省查询。
  - **文件 URL**：OpenAPI、Postman Collection 或 HTTP Archive 文件的 URL。
- **其他变量**：用于配置特定扫描行为的环境变量列表。这些变量提供与基于流水线的 DAST 扫描相同的配置选项，例如设置超时、添加身份验证成功 URL 或启用高级扫描功能。

选择 API 站点类型时，会使用主机覆盖来确保被扫描的 API 与目标位于同一主机上。这样做是为了降低对错误的 API 运行主动扫描的风险。

配置后，请求头和密码字段在存储到数据库之前会使用 [`aes-256-gcm`](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) 加密。此数据只能使用有效的密钥文件读取和解密。

您可以在 `.gitlab-ci.yml` 和按需扫描中引用站点配置文件。

```yaml
stages:
  - dast

include:
  - template: DAST.gitlab-ci.yml

dast:
  stage: dast
  dast_configuration:
    site_profile: "<profile name>"
```

<a id="site-profile-validation"></a>

### 站点配置文件验证

站点配置文件验证可降低对错误网站运行主动扫描的风险。您必须验证站点，才能对其运行按需扫描。

站点配置文件验证不是安全功能。如有必要，您可以使用[流水线扫描](browser/configuration/enabling_the_analyzer.md)对未验证的站点运行 DAST。

每种站点验证方法在功能上都是等效的，因此请使用最适合您的一种：

- **文本文件验证**：要求将文本文件上传到目标站点。该文本文件会被分配一个项目唯一的名称和内容。验证过程会检查该文件的内容。
- **请求头验证**：要求将请求头 `Gitlab-On-Demand-DAST` 添加到目标站点，
  并使用项目唯一的值。验证过程会检查该请求头是否存在，并检查其值。
- **元标签验证**：要求将名为 `gitlab-dast-validation`的元标签添加到
  目标站点，并使用项目唯一的值。请确保将其添加到页面的 `<head>` 部分。
  验证过程会检查该元标签是否存在，并检查其值。

<a id="create-a-site-profile"></a>

### 创建站点配置文件

创建站点配置文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**安全** > **安全配置**。
1. 在**动态应用程序安全测试 (DAST)** 部分，选择**管理配置文件**。
1. 选择**新建** > **站点配置文件**。
1. 填写字段，然后选择**保存配置文件**。

站点配置文件已保存，可用于按需扫描。

<a id="edit-a-site-profile"></a>

### 编辑站点配置文件

在扫描前编辑站点配置文件以更改其设置。

如果站点配置文件已链接到安全策略，则无法从此页面编辑该配置文件。有关更多信息，请参阅[扫描执行策略](../policies/scan_execution_policies.md)。

要激活站点验证流水线，您必须定义一个带有 `dast-validation-runner` 标签的 runner，或定义一个可以运行无标签作业的 runner。

先决条件：

- 如果 DAST 扫描使用该配置文件，您必须能够推送到与该扫描关联的分支。

编辑站点配置文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**安全** > **安全配置**。
1. 在**动态应用程序安全测试 (DAST)** 部分，选择**管理配置文件**。
1. 选择**站点配置文件**标签页。
1. 在该配置文件所在行，选择**更多操作** ({{< icon name="ellipsis_v" >}}) 菜单，然后选择**编辑**。
1. 编辑字段，然后选择**保存配置文件**。

如果更新了站点配置文件的目标 URL 或已认证 URL，则与该配置文件关联的请求头和密码字段会被清除。

<a id="delete-a-site-profile"></a>

### 删除站点配置文件

> [!note]
> 如果站点配置文件已链接到安全策略，用户无法从此页面删除该配置文件。
> 有关更多信息，请参阅[扫描执行策略](../policies/scan_execution_policies.md)。
> 如果站点配置文件已链接到[按需扫描](on-demand_scan.md)并被删除，
> 该按需扫描也会被删除。

删除站点配置文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**安全** > **安全配置**。
1. 在**动态应用程序安全测试 (DAST)** 部分，选择**管理配置文件**。
1. 选择**站点配置文件**标签页。
1. 在该配置文件所在行，选择**更多操作** ({{< icon name="ellipsis_v" >}}) 菜单，然后选择**删除**。
1. 选择**删除**以确认删除。

<a id="validate-a-site-profile"></a>

### 验证站点配置文件

要运行主动扫描，必须验证站点。

先决条件：

- 项目中必须有可用的 runner 来运行验证作业。

验证站点配置文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**安全** > **安全配置**。
1. 在**动态应用程序安全测试 (DAST)** 部分，选择**管理配置文件**。
1. 选择**站点配置文件**标签页。
1. 在该配置文件所在行，选择**验证**。
1. 选择验证方法。
   1. 对于**文本文件验证**：
      1. 下载**第 2 步**中列出的验证文件。
      1. 将验证文件上传到主机上的**第 3 步**中的位置，或您
         偏好的任何位置。
      1. 如有需要，在**第 3 步**中编辑文件位置。
      1. 选择**验证**。
   1. 对于**请求头验证**：
      1. 选择**第 2 步**中的剪贴板图标。
      1. 编辑要验证的站点的请求头，并粘贴剪贴板内容。
      1. 选择**第 3 步**中的输入字段，并输入请求头的位置。
      1. 选择**验证**。
   1. 对于**元标签验证**：
      1. 选择**第 2 步**中的剪贴板图标。
      1. 编辑要验证的站点的内容，并粘贴剪贴板内容。
      1. 选择**第 3 步**中的输入字段，并输入元标签的位置。
      1. 选择**验证**。

站点已验证，可以对其运行主动扫描。站点配置文件的验证状态仅在手动撤销，或其文件、请求头或元标签被编辑时才会被撤销。

<a id="retry-a-failed-validation"></a>

### 重试失败的验证

失败的站点验证尝试会列在**管理配置文件**页面的**站点配置文件**标签页上。

重试站点配置文件失败的验证：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**安全** > **安全配置**。
1. 在**动态应用程序安全测试 (DAST)** 部分，选择**管理配置文件**。
1. 选择**站点配置文件**标签页。
1. 在该配置文件所在行，选择**重试验证**。

<a id="revoke-a-site-profiles-validation-status"></a>

### 撤销站点配置文件的验证状态

> [!warning]
> 当站点配置文件的验证状态被撤销时，所有共享同一 URL 的站点配置文件
> 的验证状态也会被撤销。

撤销站点配置文件的验证状态：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**安全** > **安全配置**。
1. 在**动态应用程序安全测试 (DAST)** 部分，选择**管理配置文件**。
1. 在已验证的配置文件旁，选择**撤销验证**。

站点配置文件的验证状态已被撤销。

<a id="validated-site-profile-headers"></a>

### 已验证站点配置文件的请求头

以下代码示例展示了如何在您的应用程序中提供所需的站点配置文件请求头。

<a id="ruby-on-rails-example-for-on-demand-scan"></a>

#### 用于按需扫描的 Ruby on Rails 示例

以下是在 Ruby on Rails 应用程序中添加自定义请求头的方法：

```ruby
class DastWebsiteTargetController < ActionController::Base
  def dast_website_target
    response.headers['Gitlab-On-Demand-DAST'] = '0dd79c9a-7b29-4e26-a815-eaaf53fcab1c'
    head :ok
  end
end
```

<a id="django-example-for-on-demand-scan"></a>

#### 用于按需扫描的 Django 示例

以下是在 [Django 中添加自定义请求头](https://docs.djangoproject.com/en/2.2/ref/request-response/#setting-header-fields)的方法：

```python
class DastWebsiteTargetView(View):
    def head(self, *args, **kwargs):
      response = HttpResponse()
      response['Gitlab-On-Demand-DAST'] = '0dd79c9a-7b29-4e26-a815-eaaf53fcab1c'

      return response
```

<a id="node-with-express-example-for-on-demand-scan"></a>

#### 用于按需扫描的 Node（配合 Express）示例

以下是在 [Node（配合 Express）中添加自定义请求头](https://expressjs.com/en/5x/api.html#res.append)的方法：

```javascript
app.get('/dast-website-target', function(req, res) {
  res.append('Gitlab-On-Demand-DAST', '0dd79c9a-7b29-4e26-a815-eaaf53fcab1c')
  res.send('Respond to DAST ping')
})
```

<a id="scanner-profile"></a>

## 扫描器配置文件

扫描器配置文件定义了安全扫描器的配置详情。

扫描器配置文件包含：

- **配置文件名称**：您为扫描器配置文件指定的名称。例如 "Spider_15"。当扫描器
  配置文件在 `.gitlab-ci.yml` 或按需扫描中被引用时，无法重命名。
- **扫描模式**：被动扫描会监控发送到目标的所有 HTTP 消息（请求和响应）。主动扫描会攻击目标以发现潜在漏洞。
- **爬取超时**：允许爬虫遍历站点的最大分钟数。
- **目标超时**：DAST 在开始扫描前等待站点可用的最大秒数。
- **调试消息**：在 DAST 控制台输出中包含调试消息。

您可以在 `.gitlab-ci.yml` 和按需扫描中引用扫描器配置文件。

```yaml
stages:
  - dast

include:
  - template: DAST.gitlab-ci.yml

dast:
  stage: dast
  dast_configuration:
    scanner_profile: "<profile name>"
```

<a id="create-a-scanner-profile"></a>

### 创建扫描器配置文件

创建扫描器配置文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**安全** > **安全配置**。
1. 在**动态应用程序安全测试 (DAST)** 部分，选择**管理配置文件**。
1. 选择**新建** > **扫描器配置文件**。
1. 填写表单。有关每个字段的详情，请参阅[扫描器配置文件](#scanner-profile)。
1. 选择**保存配置文件**。

<a id="edit-a-scanner-profile"></a>

### 编辑扫描器配置文件

先决条件：

- 如果 DAST 扫描使用该配置文件，您必须能够推送到与该扫描关联的分支。

> [!note]
> 如果扫描器配置文件已链接到安全策略，则无法从此页面编辑该配置文件。
> 有关更多信息，请参阅[扫描执行策略](../policies/scan_execution_policies.md)。

编辑扫描器配置文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**安全** > **安全配置**。
1. 在**动态应用程序安全测试 (DAST)** 部分，选择**管理配置文件**。
1. 选择**扫描器配置文件**标签页。
1. 在该扫描器所在行，选择**更多操作** ({{< icon name="ellipsis_v" >}}) 菜单，然后选择**编辑**。
1. 编辑表单。
1. 选择**保存配置文件**。

<a id="delete-a-scanner-profile"></a>

### 删除扫描器配置文件

> [!note]
> 如果扫描器配置文件已链接到安全策略，用户无法从此页面删除该配置文件。
> 有关更多信息，请参阅[扫描执行策略](../policies/scan_execution_policies.md)。
> 如果扫描器配置文件已链接到[按需扫描](on-demand_scan.md)并被删除，
> 该按需扫描也会被删除。

删除扫描器配置文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**安全** > **安全配置**。
1. 在**动态应用程序安全测试 (DAST)** 部分，选择**管理配置文件**。
1. 选择**扫描器配置文件**标签页。
1. 在该扫描器所在行，选择**更多操作** ({{< icon name="ellipsis_v" >}}) 菜单，然后选择**删除**。
1. 选择**删除**。
