---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Avatar API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用该 API 与用户头像进行交互。

<a id="retrieve-user-account-avatar"></a>

## 获取用户账户头像

获取与指定公共电子邮件地址关联的用户账户[头像](../user/profile/_index.md#access-your-user-settings)的 URL。该端点不需要身份验证。

- 如果成功，则返回头像的 URL。
- 如果没有账户与该电子邮件地址关联，则返回外部头像服务的结果。
- 如果公共可见性受限并且请求未经身份验证，则返回 `403 Forbidden`。

```plaintext
GET /avatar?email=admin@example.com
```

参数：

| 参数 | 类型   | 是否必需 | 描述 |
| --------- | ------- | -------- | ----------- |
| `email`   | string  | 是      | 账户的公共电子邮件地址。 |
| `size`    | integer | 否       | 单像素尺寸。仅用于 `Gravatar` 或配置的 `Libravatar` 服务器的头像查找。 |

示例请求：

```shell
curl --request GET \
  --url "https://gitlab.example.com/api/v4/avatar?email=admin@example.com&size=32"
```

示例响应：

```json
{
  "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=64&d=identicon"
}
```