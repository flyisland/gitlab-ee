---
stage: Deploy
group: Environments
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 版本 API
---

{{< details >}}

1. Tier: 基础版, 专业版, 旗舰版
1. Offering: JihuLab.com, 私有化部署

{{< /details >}}

{{< alert type="note" >}}

我们建议您使用 [Metadata API](metadata.md) 而不是 Version API。它包含了更多信息，并且与 GraphQL 元数据端点对齐。从极狐GitLab 15.5 开始，Version API 是 Metadata API 的镜像。

{{< /alert >}}

检索极狐GitLab 实例的版本信息。对经过身份验证的用户响应 `200 OK`。

```plaintext
GET /version
```

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  "https://gitlab.example.com/api/v4/version"
```

<a id="example-responses"></a>

## 示例响应

<a id="gitlab-15.5-and-later"></a>

### 极狐GitLab 15.5 及更高版本

请参见 [Metadata API](metadata.md) 了解响应。

<a id="gitlab-15.4-and-earlier"></a>

### 极狐GitLab 15.4 及更早版本

```json
{
  "version": "8.13.0-pre",
  "revision": "4e963fe"
}
```

