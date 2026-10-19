---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 组织 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

使用此 API 与极狐GitLab 组织进行交互。更多信息，请参见[组织](../user/organization/_index.md)。

<a id="create-an-organization"></a>

## 创建组织

> [!flag]
> 此功能的可用性由功能标志控制。

创建组织。

此端点为[实验](../policy/development_stages_support.md)功能，可能会在不另行通知的情况下变更或移除。

```plaintext
POST /organizations
```

参数：

| 属性     | 类型   | 是否必需 | 描述                           |
|---------------|--------|----------|---------------------------------------|
| `name`        | string | 是      | 组织的名称          |
| `path`        | string | 是      | 组织的路径          |
| `description` | string | 否       | 组织的描述   |
| `avatar`      | file   | 否       | 组织的头像图片 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "name=New Organization" \
  --form "path=new-org" \
  --form "description=A new organization" \
  --form "avatar=@/path/to/avatar.png" \
  --url "https://gitlab.example.com/api/v4/organizations"
```

示例响应：

```json
{
  "id": 42,
  "uuid": "0192f8c2-1a2b-7cde-89ab-0123456789ab",
  "name": "New Organization",
  "path": "new-org",
  "description": "A new organization",
  "created_at": "2024-09-18T02:35:15.371Z",
  "updated_at": "2024-09-18T02:35:15.371Z",
  "web_url": "https://gitlab.example.com/o/new-org/-/overview",
  "avatar_url": "https://gitlab.example.com/uploads/-/system/organizations/organization_detail/avatar/42/avatar.png"
}
```
