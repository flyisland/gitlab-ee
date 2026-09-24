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

DAST 站点和扫描器配置文件保存了与您的应用程序以及用于评估它们的扫描器相关的信息。
定义配置文件后，您可以在流水线和按需 DAST 作业中使用它。

DAST 配置文件、DAST 扫描器配置文件和 DAST 站点配置文件的创建、更新和删除都包含在[审计日志](../../../administration/compliance/audit_event_reports.md)中。

<a id="site-profile"></a>

## 站点配置文件

{{< history >}}

- 站点配置文件功能、扫描方法和文件 URL 在 极狐GitLab 15.6 中[在 JihuLab.com 和私有化部署上启用](https://gitlab.com/gitlab-org/gitlab/-/issues/345837)。
- GraphQL 端点路径功能在 极狐GitLab 15.7 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/378692)。
- 额外的变量在 极狐GitLab 17.9 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/177703)。

{{< /history >}}

站点配置文件定义了已部署的应用程序、网站或 API 的属性和配置细节，供 DAST 扫描。

一个站点配置文件包含：

- **配置文件名**：您为要扫描的站点指定的名称。虽然在 `.gitlab-ci.yml` 或按需扫描中引用了站点配置文件，但它**不能**被重命名。
- **站点类型**：要扫描的目标类型，可以是网站或 API 扫描。
- **目标 URL**：DAST 运行的 URL。
- **排除的 URL**：要从扫描中排除的 URL 列表，以逗号分隔。您可以使用 [RE2 风格的正则表达式](https://github.com/google/re2/wiki/Syntax)。正则表达式不能包含问号 (`?`) 字符，因为它是有效的 URL 字符。
- **请求头**：一个以逗号分隔的 HTTP 请求头列表，包括名称和值。这些请求头将添加到 DAST 发出的每个请求中。
- **认证**：
  - **已认证的 URL**：包含目标网站上登录 HTML 表单的页面的 URL。用户名和密码将与登录表单一起提交以创建经过认证的扫描。
  - **用户名**：用于认证网站的用户名。
  - **密码**：用于认证网站的密码。
  - **用户名字段**：登录 HTML 表单中用户名字段的名称。
  - **密码字段**：登录 HTML 表单中密码字段的名称。
  - **提交表单字段**：选择后提交登录 HTML 表单的元素的 `id` 或 `name`。
- **扫描方法**：用于执行 API 测试的方法类型。支持的方法包括 OpenAPI、Postman Collections、HTTP Archive (HAR) 或 GraphQL。
  - **GraphQL 端点路径**：GraphQL 端点的路径。此路径与目标 URL 拼接，为扫描提供要测试的 URI。GraphQL 端点必须支持 introspection 查询。
  - **文件 URL**：OpenAPI、Postman Collection 或 HTTP Archive 文件的 URL。
- **额外变量**：用于配置特定扫描行为的环境变量列表。这些变量提供了与基于流水线的 DAST 扫描相同的配置选项，例如设置超时、添加认证成功 URL 或启用高级扫描功能。

选择 API 站点类型时，会使用主机覆盖来确保被扫描的 API 与目标位于相同的主机上。这样做是为了降低对错误 API 运行主动扫描的风险。

配置后，请求头和密码字段会在存储到数据库之前使用 [`aes-256-gcm`](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) 加密。
这些数据只能通过有效的密钥文件读取和解密。

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

站点配置文件验证可降低对错误网站运行主动扫描的风险。您必须先验证站点才能对其运行按需扫描。

站点配置文件验证不是一项安全功能。如有必要，您可以通过[流水线扫描](browser/configuration/enabling_the_analyzer.md)对未经验证的站点运行 DAST。

每种站点验证方法在功能上是等效的，请使用最适合您的一种：

- **文本文件验证**：需要将一个文本文件上传到目标站点。该文本文件被分配了一个在项目中唯一的名称和内容。验证过程会检查文件内容。
- **请求头验证**：需要将请求头 `Gitlab-On-Demand-DAST` 添加到目标站点，其值在项目中是唯一的。验证过程会检查该请求头是否存在，并检查其值。
- **Meta 标签验证**：需要将名为 `gitlab-dast-validation` 的 meta 标签添加到目标站点，其值在项目中是唯一的。确保将其添加到页面的 `<head>` 部分。验证过程会检查该 meta 标签是否存在，并检查其值。

<a id="create-a-site-profile"></a>

### 创建站点配置文件

要创建站点配置文件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **动态应用程序安全测试（DAST）** 部分，选择 **管理配置文件**。
1. 选择 **新建** > **站点配置文件**。
1. 填写字段，然后选择 **保存配置文件**。

站点配置文件已保存，可用于按需扫描。

<a id="edit-a-site-profile"></a>

### 编辑站点配置文件

编辑站点配置文件可在扫描前更改其设置。

如果站点配置文件已关联到安全策略，您无法从此页面编辑该配置文件。有关更多信息，请参阅[扫描执行策略](../policies/scan_execution_policies.md)。

要激活站点验证流水线，您必须定义一个带有 `dast-validation-runner` 标签的 Runner，或者定义一个可以运行未标记作业的 Runner。

先决条件：

- 如果 DAST 扫描使用了该配置文件，您必须能够推送到与扫描关联的分支。

要编辑站点配置文件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **动态应用程序安全测试（DAST）** 部分，选择 **管理配置文件**。
1. 选择 **站点配置文件** 选项卡。
1. 在配置文件的行中，选择 **更多操作**（{{< icon name="ellipsis_v" >}}）菜单，然后选择 **编辑**。
1. 编辑字段，然后选择 **保存配置文件**。

如果站点配置文件的目标或已认证 URL 已更新，则与该配置文件关联的请求头和密码字段将被清除。

<a id="delete-a-site-profile"></a>

### 删除站点配置文件

> [!note]
> 如果站点配置文件已关联到安全策略，用户无法从此页面删除该配置文件。
> 有关更多信息，请参阅[扫描执行策略](../policies/scan_execution_policies.md)。
> 如果站点配置文件已关联到[按需扫描](on-demand_scan.md)并被删除，
> 按需扫描也将被删除。

要删除站点配置文件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **动态应用程序安全测试（DAST）** 部分，选择 **管理配置文件**。
1. 选择 **站点配置文件** 选项卡。
1. 在配置文件的行中，选择 **更多操作**（{{< icon name="ellipsis_v" >}}）菜单，然后选择 **删除**。
1. 选择 **删除** 以确认删除。

<a id="validate-a-site-profile"></a>

### 验证站点配置文件

验证站点是运行主动扫描的必要条件。

先决条件：

- 项目中必须有一个可用的 Runner 来运行验证作业。

要验证站点配置文件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **动态应用程序安全测试（DAST）** 部分，选择 **管理配置文件**。
1. 选择 **站点配置文件** 选项卡。
1. 在配置文件的行中，选择 **验证**。
1. 选择验证方法。
   1. 对于 **文本文件验证**：
      1. 下载 **步骤 2** 中列出的验证文件。
      1. 将该验证文件上传到主机上 **步骤 3** 中指定的位置或您偏好的任何位置。
      1. 如果需要，在 **步骤 3** 中编辑文件位置。
      1. 选择 **验证**。
   1. 对于 **请求头验证**：
      1. 选择 **步骤 2** 中的剪贴板图标。
      1. 编辑要验证的站点的请求头，并粘贴剪贴板内容。
      1. 选择 **步骤 3** 中的输入字段并输入请求头的位置。
      1. 选择 **验证**。
   1. 对于 **Meta 标签验证**：
      1. 选择 **步骤 2** 中的剪贴板图标。
      1. 编辑要验证的站点的内容，并粘贴剪贴板内容。
      1. 选择 **步骤 3** 中的输入字段并输入 meta 标签的位置。
      1. 选择 **验证**。

站点已通过验证，可以对其运行主动扫描。站点配置文件的验证状态仅在手动撤销，或其文件、请求头或 meta 标签被编辑时才会被撤销。

<a id="retry-a-failed-validation"></a>

### 重试失败的验证

失败的站点验证尝试会列在 **管理配置文件** 页面的 **站点配置文件** 选项卡上。

要重试站点配置文件的失败验证：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **动态应用程序安全测试（DAST）** 部分，选择 **管理配置文件**。
1. 选择 **站点配置文件** 选项卡。
1. 在配置文件的行中，选择 **重试验证**。

<a id="revoke-a-site-profiles-validation-status"></a>

### 撤销站点配置文件的验证状态

> [!warning]
> 撤销站点配置文件的验证状态后，共享相同 URL 的所有站点配置文件的验证状态也将被撤销。

要撤销站点配置文件的验证状态：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **动态应用程序安全测试（DAST）** 部分，选择 **管理配置文件**。
1. 在已验证的配置文件旁边，选择 **撤销验证**。

站点配置文件的验证状态已被撤销。

<a id="validated-site-profile-headers"></a>

### 已验证的站点配置文件请求头

以下代码示例展示了如何在您的应用程序中提供所需的站点配置文件请求头。

<a id="ruby-on-rails-example-for-on-demand-scan"></a>

#### Ruby on Rails 按需扫描示例

以下是如何在 Ruby on Rails 应用程序中添加自定义请求头的方法：

```ruby
class DastWebsiteTargetController < ActionController::Base
  def dast_website_target
    response.headers['Gitlab-On-Demand-DAST'] = '0dd79c9a-7b29-4e26-a815-eaaf53fcab1c'
    head :ok
  end
end
```

<a id="django-example-for-on-demand-scan"></a>

#### Django 按需扫描示例

以下是如何在 Django 中添加[自定义请求头的方法](https://docs.djangoproject.com/en/2.2/ref/request-response/#setting-header-fields)：

```python
class DastWebsiteTargetView(View):
    def head(self, *args, **kwargs):
      response = HttpResponse()
      response['Gitlab-On-Demand-DAST'] = '0dd79c9a-7b29-4e26-a815-eaaf53fcab1c'

      return response
```

<a id="node-with-express-example-for-on-demand-scan"></a>

#### Node (with Express) 按需扫描示例

以下是如何在 Node (with Express) 中添加[自定义请求头的方法](https://expressjs.com/en/5x/api.html#res.append)：

```javascript
app.get('/dast-website-target', function(req, res) {
  res.append('Gitlab-On-Demand-DAST', '0dd79c9a-7b29-4e26-a815-eaaf53fcab1c')
  res.send('Respond to DAST ping')
})
```

<a id="scanner-profile"></a>

## 扫描器配置文件

{{< history >}}

- 在 极狐GitLab 17.0 中引入了基于浏览器的按需 DAST 扫描，弃用了 AJAX 蜘蛛选项。
- 在 极狐GitLab 17.0 中引入了基于浏览器的按需 DAST 扫描，并将蜘蛛超时重命名为爬取超时。

{{< /history >}}

扫描器配置文件定义了安全扫描器的配置细节。

一个扫描器配置文件包含：

- **配置文件名**：您为扫描器配置文件指定的名称。例如，“Spider_15”。虽然在 `.gitlab-ci.yml` 或按需扫描中引用了扫描器配置文件，但它**不能**被重命名。
- **扫描模式**：被动扫描会监视发送到目标的所有 HTTP 消息（请求和响应）。主动扫描会攻击目标以发现潜在的漏洞。
- **爬取超时**：允许爬虫遍历站点的最大分钟数。
- **目标超时**：DAST 在开始扫描之前等待站点可用的最大秒数。
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

要创建扫描器配置文件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **动态应用程序安全测试（DAST）** 部分，选择 **管理配置文件**。
1. 选择 **新建** > **扫描器配置文件**。
1. 填写表单。有关每个字段的详细信息，请参阅[扫描器配置文件](#scanner-profile)。
1. 选择 **保存配置文件**。

<a id="edit-a-scanner-profile"></a>

### 编辑扫描器配置文件

先决条件：

- 如果 DAST 扫描使用了该配置文件，您必须能够推送到与扫描关联的分支。

> [!note]
> 如果扫描器配置文件已关联到安全策略，您无法从此页面编辑该配置文件。
> 有关更多信息，请参阅[扫描执行策略](../policies/scan_execution_policies.md)。

要编辑扫描器配置文件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **动态应用程序安全测试（DAST）** 部分，选择 **管理配置文件**。
1. 选择 **扫描器配置文件** 选项卡。
1. 在扫描器的行中，选择 **更多操作**（{{< icon name="ellipsis_v" >}}）菜单，然后选择 **编辑**。
1. 编辑表单。
1. 选择 **保存配置文件**。

<a id="delete-a-scanner-profile"></a>

### 删除扫描器配置文件

> [!note]
> 如果扫描器配置文件已关联到安全策略，用户无法从此页面删除该配置文件。
> 有关更多信息，请参阅[扫描执行策略](../policies/scan_execution_policies.md)。
> 如果扫描器配置文件已关联到[按需扫描](on-demand_scan.md)并被删除，
> 按需扫描也将被删除。

要删除扫描器配置文件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **动态应用程序安全测试（DAST）** 部分，选择 **管理配置文件**。
1. 选择 **扫描器配置文件** 选项卡。
1. 在扫描器的行中，选择 **更多操作**（{{< icon name="ellipsis_v" >}}）菜单，然后选择 **删除**。
1. 选择 **删除**。