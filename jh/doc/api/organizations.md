---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Organizations API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

使用此 API 与极狐GitLab 组织交互。更多信息，请参阅[组织](../user/organization/_index.md)。

<a id="create-an-organization"></a>

## 创建组织

{{< history >}}

- 在极狐GitLab 17.5 中作为[功能标志](../administration/feature_flags/_index.md) `allow_organization_creation` 引入，默认禁用。此功能是[实验](../policy/development_stages_support.md)。
- 在极狐GitLab 18.4 中变更。功能标志 `allow_organization_creation` 合并并重命名为 `organization_switching`。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参阅历史。

创建组织。

此端点是一个[实验](../policy/development_stages_support.md)，可能随时更改或移除，恕不另行通知。

```plaintext
POST /organizations
```

参数：

| 属性         | 类型   | 必需 | 描述                              |
|--------------|--------|------|-----------------------------------|
| `name`       | string | 是   | 组织名称                          |
| `path`       | string | 是   | 组织路径                          |
| `description`| string | 否   | 组织描述                          |
| `avatar`     | file   | 否   | 组织的头像图片                    |

请求示例：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
--form "name=New Organization" \
--form "path=new-org" \
--form "description=A new organization" \
--form "avatar=@/path/to/avatar.png" \
"https://gitlab.example.com/api/v4/organizations"
```

响应示例：

```json
{
  "id": 42,
  "name": "New Organization",
  "path": "new-org",
  "description": "A new organization",
  "created_at": "2024-09-18T02:35:15.371Z",
  "updated_at": "2024-09-18T02:35:15.371Z",
  "web_url": "https://gitlab.example.com/o/new-org/-/overview",
  "avatar_url": "https://gitlab.example.com/uploads/-/system/organizations/organization_detail/avatar/42/avatar.png"
}
```