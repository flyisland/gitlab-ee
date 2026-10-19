---
stage: Application Security Testing
group: Secret Detection
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目安全设置 API
description: 用于列出和更新项目安全选项（如密钥推送保护）的 API 端点。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

每个对项目安全设置的 API 调用都必须经过[认证](rest/authentication.md)。

如果项目是私有的，并且用户不是安全设置所属项目的成员，则对该项目的请求会返回 `404 Not Found` 状态码。

<a id="list-all-project-security-settings"></a>

## 列出所有项目安全设置

列出项目的所有安全设置。

先决条件：

- 您必须具有项目的 安全经理、开发者、维护者 或 所有者 角色。

```plaintext
GET /projects/:id/security_settings
```

| 属性          | 类型              | 是否必需 | 描述                                                                                                          |
| ------------- | ----------------- | -------- | ------------------------------------------------------------------------------------------------------------- |
| `id`          | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/7/security_settings"
```

响应示例：

```json
{
    "project_id": 7,
    "created_at": "2024-08-27T15:30:33.075Z",
    "updated_at": "2024-10-16T05:09:22.233Z",
    "auto_fix_container_scanning": true,
    "auto_fix_dast": true,
    "auto_fix_dependency_scanning": true,
    "auto_fix_sast": true,
    "continuous_vulnerability_scans_enabled": true,
    "container_scanning_for_registry_enabled": false,
    "secret_push_protection_enabled": true
}
```

<a id="update-the-secret_push_protection_enabled-setting"></a>

## 更新 `secret_push_protection_enabled` 设置

{{< history >}}

- [已重命名] 从 `pre_receive_secret_detection_enabled` 在 极狐GitLab 17.11。

{{< /history >}}

更新指定项目的 `secret_push_protection_enabled` 设置。

先决条件：

- 您必须具有项目的 维护者 或 所有者 角色。

```plaintext
PUT /projects/:id/security_settings
```

| 属性                             | 类型              | 是否必需 | 描述                                                         |
| -------------------------------- | ----------------- | -------- | ------------------------------------------------------------ |
| `id`                             | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `secret_push_protection_enabled` | boolean           | 是       | 为项目启用密钥推送保护。                                     |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/7/security_settings?secret_push_protection_enabled=false"
```

响应示例：

```json
{
    "project_id": 7,
    "created_at": "2024-08-27T15:30:33.075Z",
    "updated_at": "2024-10-16T05:09:22.233Z",
    "auto_fix_container_scanning": true,
    "auto_fix_dast": true,
    "auto_fix_dependency_scanning": true,
    "auto_fix_sast": true,
    "continuous_vulnerability_scans_enabled": true,
    "container_scanning_for_registry_enabled": false,
    "secret_push_protection_enabled": false
}
```

