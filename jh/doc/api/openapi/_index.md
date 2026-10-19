---
stage: Developer Experience
group: API Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: OpenAPI
description: "使用 OpenAPI 3.0 规范探索极狐GitLab REST API"
---

极狐GitLab 使用 [OpenAPI 3.0 规范](https://spec.openapis.org/oas/v3.0.3)（原称 Swagger）记录其 REST API，这是一种用于描述 RESTful API 的标准、平台无关的格式。API 代码是 REST API 的唯一事实来源。OpenAPI 规范直接从 API 代码自动生成，并与其实现紧密耦合，确保文档始终准确且最新。

有关极狐GitLab API 的常规信息，请参阅[扩展极狐GitLab](../_index.md)。

<a id="openapi-specification-file"></a>

## OpenAPI 规范文件

原始 OpenAPI 3.0 规范可在 GitLab 单体代码仓库中获取：

- **文件：** [`doc/api/openapi/openapi_v3.yaml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/api/openapi/openapi_v3.yaml)
- **格式：** OpenAPI 3.0（YAML）

> [!note]
> OpenAPI 2.0 规范（`openapi_v2.yaml`）已弃用，不再接收更新。请改用 OpenAPI 3.0 规范（`openapi_v3.yaml`）。

<a id="interactive-rest-api-documentation"></a>

## 交互式 REST API 文档

REST API 使用 OpenAPI 3.0 规范进行了完整记录。您可以在 [REST API 文档](https://api.gitlab.com/rest/)中交互式浏览和测试每个端点。

该文档使用 [Scalar](https://scalar.com/) 渲染，这是一个开源的 API 参考工具。它根据极狐GitLab 源代码中的 OpenAPI 规范自动生成，因此始终反映 API 的当前状态。

<a id="add-authorization-credentials"></a>

### 添加授权凭据

某些端点需要身份验证。极狐GitLab 支持使用 HTTP Bearer 或 OAuth 2.0 凭据进行身份验证。

要添加授权凭据：

1. 转到 [REST API 文档](https://api.gitlab.com/rest/)。
1. 在右侧的 **身份验证** 面板中，从下拉列表中选择一种身份验证方法。
1. 输入您的凭据：
   - 对于 `http`，请输入您的[个人访问令牌](../../user/profile/personal_access_tokens.md)。
   - 对于 `oauth2`，请使用以极狐GitLab 作为身份提供者的授权码流程。
1. 选择 **授权**。

在会话期间，您的凭据会自动复用于所有后续请求。

<a id="send-a-live-request"></a>

### 发送实时请求

使用交互式请求工具向极狐GitLab 发送实时请求。

要发送实时请求：

1. 转到 [REST API 文档](https://api.gitlab.com/rest/)。
1. 展开一个操作。
1. 选择 **测试请求**。
1. 输入任何必需或可选参数。
1. 选择 **发送**。

该工具会显示 `curl` 命令、完整的请求 URL 以及服务器响应。
