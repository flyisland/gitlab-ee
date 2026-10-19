```yaml
---
stage: AI-powered
group: Workflow Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: REST API to manage the AI Catalog.
title: AI Catalog 管理 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="seed-gitlab-managed-external-agents"></a>

## 植入极狐GitLab 管理的外部代理

{{< details >}}

状态：实验

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.8 中作为实验特性引入。

{{< /history >}}

使用此 API 向 AI Catalog 植入 [极狐GitLab 管理的外部代理](../../user/duo_agent_platform/agents/external.md)。

此功能为 [实验特性](../../policy/development_stages_support.md)，未来版本可能变更或移除。

前提条件：

- 你必须具有管理员角色。

```plaintext
POST /api/v4/admin/ai_catalog/seed_external_agents
```

请求示例：

```plaintext
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://primary.example.com/api/v4/admin/ai_catalog/seed_external_agents"
```

成功响应 (HTTP 201):

```json
{
    "message": "外部代理植入成功"
}
```

错误响应示例 (HTTP 422):

```json
{
    "message": "错误：外部代理已植入"
}
```

错误响应 - 用户不是管理员 (HTTP 403):

```json
{
    "message": "403 禁止访问"
}
```

```