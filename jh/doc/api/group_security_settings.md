---
stage: Security Risk Management
group: Security Platform Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Update group security settings in 极狐GitLab. Configure secret push protection and other security policies for all projects within a group.
title: 群组安全设置 API
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 17.7 引入。

{{< /history >}}

所有群组安全设置的 API 调用都必须经过 [认证](rest/authentication.md)。

如果用户不是私有群组的成员，对私有群组的请求将返回 `404 Not Found` 状态码。

<a id="update-group-security-settings"></a>

## 更新群组安全设置

为指定群组更新群组安全设置。

前提条件：

- 您必须拥有该群组的 Security Manager、维护者或所有者角色。

```plaintext
PUT /groups/:id/security_settings
```

| 属性 | 类型 | 是否必需 | 描述 |
| -------------------------------- | ----------------- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | ID 或群组的 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `secret_push_protection_enabled` | 布尔值 | 是 | 为群组中的项目启用密钥推送保护。 |
| `projects_to_exclude` | 整数数组 | 否 | 要从密钥推送保护中排除的项目的 ID。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/7/security_settings?secret_push_protection_enabled=true&projects_to_exclude[]=1&projects_to_exclude[]=2"
```

示例响应：

```json
{
  "secret_push_protection_enabled": true,
  "errors": []
}
```

