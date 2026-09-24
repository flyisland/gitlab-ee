---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 外部流水线验证
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="external-pipeline-validation"></a>

## 外部流水线验证

你可以在流水线创建之前，使用外部服务对其进行验证。

极狐GitLab 会向外部服务 URL 发送一个 POST 请求，并将流水线数据作为载荷。外部服务返回的响应代码决定极狐GitLab 是接受还是拒绝该流水线。如果响应代码为：

- `200`，则接受流水线。
- `406`，则拒绝流水线。
- 其他代码，则接受流水线并记录日志。

如果发生错误或请求超时，则接受流水线。

被外部验证服务拒绝的流水线不会被创建，也不会出现在极狐GitLab UI 或 API 的流水线列表中。如果你在 UI 中创建的流水线被拒绝，则会显示 `Pipeline cannot be run. External validation failed`。

<a id="configure-external-pipeline-validation"></a>

## 配置外部流水线验证

要配置外部流水线验证，请添加 [`EXTERNAL_VALIDATION_SERVICE_URL` 环境变量](../environment_variables.md) 并将其设置为外部服务 URL。

默认情况下，外部服务请求在五秒后超时。要覆盖默认值，请将 `EXTERNAL_VALIDATION_SERVICE_TIMEOUT` 环境变量设置为所需的秒数。

<a id="payload-schema"></a>

## 载荷结构

{{< history >}}

- `tag_list` 在极狐GitLab 16.11 中引入。

{{< /history >}}

```json
{
  "type": "object",
  "required" : [
    "project",
    "user",
    "credit_card",
    "pipeline",
    "builds",
    "total_builds_count",
    "namespace"
  ],
  "properties" : {
    "project": {
      "type": "object",
      "required": [
        "id",
        "path",
        "created_at",
        "shared_runners_enabled",
        "group_runners_enabled"
      ],
      "properties": {
        "id": { "type": "integer" },
        "path": { "type": "string" },
        "created_at": { "type": ["string", "null"], "format": "date-time" },
        "shared_runners_enabled": { "type": "boolean" },
        "group_runners_enabled": { "type": "boolean" }
      }
    },
    "user": {
      "type": "object",
      "required": [
        "id",
        "username",
        "email",
        "created_at"
      ],
      "properties": {
        "id": { "type": "integer" },
        "username": { "type": "string" },
        "email": { "type": "string" },
        "created_at": { "type": ["string", "null"], "format": "date-time" },
        "current_sign_in_ip": { "type": ["string", "null"] },
        "last_sign_in_ip": { "type": ["string", "null"] },
        "sign_in_count": { "type": "integer" }
      }
    },
    "credit_card": {
      "type": "object",
      "required": [
        "similar_cards_count",
        "similar_holder_names_count"
      ],
      "properties": {
        "similar_cards_count": { "type": "integer" },
        "similar_holder_names_count": { "type": "integer" }
      }
    },
    "pipeline": {
      "type": "object",
      "required": [
        "sha",
        "ref",
        "type"
      ],
      "properties": {
        "sha": { "type": "string" },
        "ref": { "type": "string" },
        "type": { "type": "string" }
      }
    },
    "builds": {
      "type": "array",
      "items": {
        "type": "object",
        "required": [
          "name",
          "stage",
          "image",
          "tag_list",
          "services",
          "script"
        ],
        "properties": {
          "name": { "type": "string" },
          "stage": { "type": "string" },
          "image": { "type": ["string", "null"] },
          "tag_list": { "type": ["array", "null"] },
          "services": {
            "type": ["array", "null"],
            "items": { "type": "string" }
          },
          "script": {
            "type": "array",
            "items": { "type": "string" }
          }
        }
      }
    },
    "total_builds_count": { "type": "integer" },
    "namespace": {
      "type": "object",
      "required": [
        "plan",
        "trial"
      ],
      "properties": {
        "plan": { "type": "string" },
        "trial": { "type": "boolean" }
      }
    },
    "provisioning_group": {
      "type": "object",
      "required": [
        "plan",
        "trial"
      ],
      "properties": {
        "plan": { "type": "string" },
        "trial": { "type": "boolean" }
      }
    }
  }
}
```

`namespace` 字段仅在[极狐GitLab 专业版和旗舰版](https://gitlab.cn/pricing/) 中可用。