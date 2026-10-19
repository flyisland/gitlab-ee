---
stage: Security Risk Management
group: Security Policies
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于管理存储在组织与群组策略存储中的安全策略的 REST API。
title: 策略存储 API
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

使用此 API 在策略存储中编写[安全策略](../user/application_security/policies/_index.md)。一个策略属于一个组织，响应单个触发器，并携带构成其行为的规则和操作。

仅当以下所有条件都成立时，这些端点才可用：

- 已启用 `security_policies_v2` 功能标志。
- 管理员已在**管理员** > **设置** > **安全与合规**中为实例启用策略存储实验。
- 对于组织端点，组织已选择启用。
- 对于群组端点，顶级群组已选择启用。

当功能标志、实例设置或组织选择启用任一条件不成立时，端点返回 `404 Not Found`。当实例未获得安全编排策略的许可，或群组未选择启用时，端点返回 `403 Forbidden`。

<a id="catalogs"></a>

## 目录

目录端点描述策略可以基于什么构建，并向每个符合条件的调用方返回相同的静态内容。调用方必须是已认证用户，且其组织已启用 `security_policies_v2` 功能标志。当此条件不成立时，端点返回 `404 Not Found`。

<a id="list-all-triggers"></a>

### 列出所有触发器

列出策略可以响应的所有触发器。

```plaintext
GET /security/policy_store/triggers
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型   | 描述 |
| --------- | ------ | ----------- |
| `[].id`   | string | 触发器的 ID，在编写策略时用作 `trigger_type`。 |
| `[].name` | string | 触发器的显示名称。 |

示例请求：

```shell
curl --request GET --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/security/policy_store/triggers"
```

示例响应：

```json
[
  { "id": "deployment_requested", "name": "Deployment requested" },
  { "id": "environment_advanced", "name": "Environment advanced" },
  { "id": "deployment_promoted", "name": "Deployment promoted" }
]
```

<a id="list-all-actions"></a>

### 列出所有操作

列出策略可以执行的所有操作。

```plaintext
GET /security/policy_store/actions
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型   | 描述 |
| --------- | ------ | ----------- |
| `[].id`   | string | 操作的 ID。 |
| `[].name` | string | 操作的显示名称。 |

示例请求：

```shell
curl --request GET --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/security/policy_store/actions"
```

示例响应：

```json
[
  { "id": "block", "name": "Block" },
  { "id": "require_approval", "name": "Require approval" }
]
```

<a id="list-all-rule-kinds"></a>

### 列出所有规则类型

列出策略可以基于其构建的所有规则类型。

```plaintext
GET /security/policy_store/rules
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型   | 描述 |
| --------- | ------ | ----------- |
| `[].id`   | string | 规则类型的 ID。 |
| `[].name` | string | 规则类型的显示名称。 |

示例请求：

```shell
curl --request GET --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/security/policy_store/rules"
```

示例响应：

```json
[
  { "id": "custom", "name": "Custom" },
  { "id": "calendar", "name": "Calendar" },
  { "id": "environment", "name": "Environment" }
]
```

<a id="policy-attributes"></a>

## 策略属性

组织和群组策略端点使用相同的策略范围、规则、操作和响应属性。

<a id="policy-scope-attributes"></a>

### 策略范围属性

`policy_scope` 包含一个或多个条件，`match_mode` 控制它们的组合方式。条件以整数或带 `id` 键的对象形式指定 ID。极狐GitLab 会对 ID 去重并排序，因此编写顺序不会改变编译后的程序。

| 属性 | 类型 | 描述 |
| --------- | ---- | ----------- |
| `application` | object | 应用程序安全属性 ID 的 `including` 和 `excluding` 列表。 |
| `business_impact` | object | 业务影响安全属性 ID 的 `including` 和 `excluding` 列表。 |
| `business_unit` | object | 业务单元安全属性 ID 的 `including` 和 `excluding` 列表。 |
| `compliance_frameworks` | array | 项目必须携带的合规框架 ID。直接接受列表，而不是 `including` 和 `excluding`。 |
| `exposure` | object | 暴露面安全属性 ID 的 `including` 和 `excluding` 列表。 |
| `groups` | object | 群组 ID 的 `including` 和 `excluding` 列表。 |
| `match_mode` | string | 取值为 `all` 或 `any`。使用 `all` 时，每个条件都必须匹配。使用 `any` 时，匹配一个即可。任何其他值都会被视为 `all`。 |
| `projects` | object | 项目 ID 的 `including` 和 `excluding` 列表。`excluding` 还接受 `{"type": "personal"}` 和 `{"type": "archived"}`，用于排除该类型的所有项目。 |

例如：

```json
{
  "match_mode": "any",
  "compliance_frameworks": [{ "id": 5 }],
  "projects": { "including": [12, 34], "excluding": [{ "type": "archived" }] },
  "groups": { "including": [{ "id": 7 }] }
}
```

极狐GitLab 无法读取为 ID 的值会返回 `400 Bad Request`。这包括不是数字的值，以及超出 1 到 9223372036854775807 范围的数字。

有三种情况会被接受，且值得了解，因为每种情况对策略的范围限定都可能与您的预期不同：

- 未指定任何 ID 的 `including` 列表对该条件不匹配任何内容。在
  `match_mode: all` 下，该策略随后不适用于任何项目。在 `match_mode: any` 下，另一个
  条件仍可匹配。
- 未指定任何 ID 的 `excluding` 列表不排除任何内容。
- 极狐GitLab 无法识别的条件不产生任何效果。如果它是提供的唯一条件，
  则该策略适用于所有项目。

<a id="rule-and-action-attributes"></a>

### 规则和操作属性

`rules` 和 `actions` 是数组。每个条目具有以下属性：

| 属性 | 类型           | 是否必需 | 描述 |
| --------- | -------------- | -------- | ----------- |
| `type`    | string         | 是      | 对于规则，取[列出所有规则类型](#list-all-rule-kinds)返回的 ID 之一。对于操作，取[列出所有操作](#list-all-actions)返回的 ID 之一。 |
| `value`   | string or hash | 否       | 条目作用的对象。`custom` 规则接受字符串形式的 Rego 源代码。`calendar` 或 `environment` 规则接受哈希，每个操作也是如此。 |

每个数组最多接受 5 个条目，每个条目序列化后必须不超过 4096 字节。条目过大时的错误会指明每个位置，例如
`rules has an entry exceeding maximum size of 4096 bytes at 0`。
条目不能为空。空条目会返回 `400 Bad Request`，错误会指明每个空位置，例如 `rules[0] is blank`。

`custom` 规则的 Rego，以及所有规则合并到的 `policy_rego` 模块，都必须能够解析。无法解析的 `custom` 规则会返回 `400 Bad Request`。错误会指明该规则的位置，并包含引擎的消息，其中带有您在 `value`中发送的 Rego 的行号和列号，例如 ``rules[0] is invalid: error: expecting `}` while parsing object (at line:column)``。所有规则合并到 `policy_rego` 模块后，该模块也会被解析。由于每条规则都已单独解析过，此阶段的失败会被视为策略引擎的故障：请求返回 `500 Internal Server Error`，策略不会被存储，并且该故障会报告给错误跟踪。

请使用 `Content-Type: application/json` 请求头，以 JSON 形式发送 `rules` 和 `actions`。表单编码的请求体可以携带这两个数组，但其中的每个值都会以字符串形式到达，因此非字符串的 `value` 无法以这种方式表达。

<a id="response-attributes"></a>

### 响应属性

策略端点返回以下属性：

| 属性         | 类型            | 描述 |
| ----------------- | --------------- | ----------- |
| `actions`         | array           | 策略执行的操作。 |
| `created_at`      | string          | 策略的创建日期和时间。 |
| `description`     | string          | 策略的描述。 |
| `id`              | integer         | 策略的 ID。 |
| `lifecycle_state` | string          | 取值为 `active` 或 `disabled`。 |
| `mode`            | string          | 取值为 `audit`、`warn` 或 `enforce` 之一。 |
| `name`            | string          | 策略的名称。 |
| `namespace_id`    | integer         | 拥有该策略的群组的 ID。对于通过组织端点创建的策略，该值为 `null`，因为该策略归组织所有。 |
| `organization_id` | integer         | 该策略所属组织的 ID。 |
| `policy_rego`     | string          | 该策略的规则，编译为单个 Rego 模块。对于没有规则的策略，该值为 `null`。 |
| `policy_scope`    | object          | 策略的结构化范围；当 Rego 是直接编写时，该值为 `null`。 |
| `rules`           | array           | 策略的规则。 |
| `scope_dimensions`| array           | `scope_rego` 读取以决定策略是否适用的点分上下文路径。极狐GitLab 会推导此值，因此会忽略您为其发送的任何值。当 `scope_rego` 是直接编写时，该值为 `null`，否则为数组；当策略未限定范围时为空数组。 |
| `scope_rego`      | string          | 策略的范围，以 [Rego](https://www.openpolicyagent.org/docs/policy-language)（Open Policy Agent 的策略语言）程序表示。可以直接编写，也可以从 `policy_scope` 编译而来。该值始终存在，因为没有范围的策略会编译为适用于所有项目的程序。 |
| `trigger_type`    | string          | 策略响应的触发器。 |
| `updated_at`      | string          | 策略最后更改的日期和时间。 |
| `version`         | integer         | 策略的修订版本。至少更改一个值的更新会使其加一。 |

<a id="organization-policies"></a>

## 组织策略

使用组织端点管理组织的策略。

先决条件：

- 您必须是组织的所有者或实例的管理员。

要选择启用某个组织，请发送 `organizationUpdate` GraphQL 变更，并将 `policyStoreExperimentEnabled` 设置为 `true`。如果该实验对组织不可用，该变更会返回错误。

对策略端点的每次调用都必须经过[身份验证](rest/authentication.md)。无法管理该组织的调用方会收到 `403 Forbidden`，而完全无法看到该组织的调用方会收到 `404 Not Found`。

属于另一个组织的策略与不存在的策略无法区分。ID 不能用于跨组织读取或更改策略。

<a id="list-all-organization-policies"></a>

### 列出所有组织策略

列出属于某个组织的所有策略。

```plaintext
GET /organizations/:id/security/policy_store
```

支持的属性：

| 属性         | 类型    | 是否必需 | 描述 |
| ----------------- | ------- | -------- | ----------- |
| `id`              | integer | 是      | 组织的 ID。 |
| `lifecycle_state` | string  | 否       | 仅返回 `active` 策略、仅返回 `disabled` 策略，或返回 `all` 策略。默认为 `active`。 |
| `page`            | integer | 否       | 要返回的结果页。默认为 `1`。 |
| `per_page`        | integer | 否       | 每页的结果数。默认为 `20`，任何大于 `100`的值都会上限为 `100`。 |
| `trigger_type`    | string  | 否       | 仅返回响应该触发器的策略。取[列出所有触发器](#list-all-triggers)返回的 ID 之一。 |

此端点返回[分页](rest/_index.md#offset-based-pagination)结果。出于性能原因，无论组织有多少策略，它都不会返回 `x-total` 或 `x-total-pages` 响应头，也不会返回 `rel="last"` `link`：请检查 `x-next-page` 以确定是否还有下一页。

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及[策略属性](#response-attributes)数组。

示例请求：

```shell
curl --request GET --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/organizations/1/security/policy_store?per_page=20"
```

示例响应：

```json
[
  {
    "id": 1,
    "organization_id": 1,
    "namespace_id": null,
    "name": "Block deployments on critical findings",
    "description": null,
    "version": 1,
    "trigger_type": "deployment_requested",
    "rules": [{ "type": "custom", "value": "package governance" }],
    "policy_rego": "package governance\n",
    "actions": [{ "type": "block" }],
    "policy_scope": null,
    "scope_dimensions": [],
    "scope_rego": "package gitlab.scope\n\napplicable := [result.policy | some result in results; result.applies]\n...",
    "mode": "enforce",
    "lifecycle_state": "active",
    "created_at": "2026-08-07T13:56:32.985Z",
    "updated_at": "2026-08-07T13:56:32.985Z"
  }
]
```

<a id="retrieve-an-organization-policy"></a>

### 检索组织策略

从组织中检索单个策略。

```plaintext
GET /organizations/:id/security/policy_store/:policy_id
```

支持的属性：

| 属性   | 类型    | 是否必需 | 描述 |
| ----------- | ------- | -------- | ----------- |
| `id`        | integer | 是      | 组织的 ID。 |
| `policy_id` | integer | 是      | 策略的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及[策略属性](#response-attributes)。

示例请求：

```shell
curl --request GET --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/organizations/1/security/policy_store/1"
```

示例响应：

```json
{
  "id": 1,
  "organization_id": 1,
  "namespace_id": null,
  "name": "Block deployments on critical findings",
  "description": null,
  "version": 1,
  "trigger_type": "deployment_requested",
  "rules": [{ "type": "custom", "value": "package governance" }],
  "policy_rego": "package governance\n",
  "actions": [{ "type": "block" }],
  "policy_scope": null,
  "scope_dimensions": [],
  "scope_rego": "package gitlab.scope\n\napplicable := [result.policy | some result in results; result.applies]\n...",
  "mode": "enforce",
  "lifecycle_state": "active",
  "created_at": "2026-08-07T13:56:32.985Z",
  "updated_at": "2026-08-07T13:56:32.985Z"
}
```

<a id="create-an-organization-policy"></a>

### 创建组织策略

在组织中创建策略。

```plaintext
POST /organizations/:id/security/policy_store
```

支持的属性：

| 属性         | 类型    | 是否必需 | 描述 |
| ----------------- | ------- | -------- | ----------- |
| `id`              | integer | 是      | 组织的 ID。 |
| `name`            | string  | 是      | 策略的名称。最多 255 个字符。在组织中必须唯一。 |
| `rules`           | array   | 是      | 策略的规则。有关条目属性，请参见[规则和操作属性](#rule-and-action-attributes)。至少需要一个条目，最多 5 个。每个条目序列化后必须不超过 4096 字节。当条目编译为大于 65536 字节的 Rego 模块时会被拒绝。该模块会作为 `policy_rego` 返回。 |
| `trigger_type`    | string  | 是      | 策略响应的触发器。取[列出所有触发器](#list-all-triggers)返回的 ID 之一。 |
| `actions`         | array   | 否       | 策略执行的操作。有关条目属性，请参见[规则和操作属性](#rule-and-action-attributes)。最多 5 个条目。每个条目序列化后必须不超过 4096 字节。 |
| `description`     | string  | 否       | 策略的描述。最多 4096 个字符。 |
| `lifecycle_state` | string  | 否       | 取值为 `active` 或 `disabled`。默认为 `active`。 |
| `mode`            | string  | 否       | 取值为 `audit`、`warn` 或 `enforce` 之一。默认为 `warn`。 |
| `policy_scope`    | object  | 否       | 策略的结构化范围，极狐GitLab 会将其编译为 `scope_rego`。有关其属性，请参见[策略范围属性](#policy-scope-attributes)。不能与非空的 `scope_rego` 组合使用。当编译为超过 4096 个字符的 Rego 时会被拒绝。 |
| `scope_rego`      | string  | 否       | 策略的范围，直接以 Rego 程序编写。极狐GitLab 会按您编写的内容原样存储。最多 4096 个字符。非空值不能与 `policy_scope` 组合使用。空值与省略它的效果相同。无法解析为 Rego 的值会返回 `400 Bad Request`。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及[策略属性](#response-attributes)。以下情况会返回 `400 Bad Request`：

- 某个属性无效。
- 同时提供了两种范围形式。
- 该名称在组织中已被占用。
- 编译后的 `scope_rego` 超过 4096 个字符。
- `rules` 编译为超过 65536 字节的 Rego。
- `rules` 或 `actions` 携带超过 5 个条目。
- `rules` 或 `actions`中的某个条目序列化后超过 4096 字节。

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "Block deployments on critical findings",
    "trigger_type": "deployment_requested",
    "rules": [{ "type": "custom", "value": "package governance" }],
    "actions": [{ "type": "block" }],
    "policy_scope": { "compliance_frameworks": [{ "id": 5 }] }
  }' \
  --url "https://gitlab.example.com/api/v4/organizations/1/security/policy_store"
```

示例响应：

```json
{
  "id": 1,
  "organization_id": 1,
  "namespace_id": null,
  "name": "Block deployments on critical findings",
  "description": null,
  "version": 1,
  "trigger_type": "deployment_requested",
  "rules": [{ "type": "custom", "value": "package governance" }],
  "policy_rego": "package governance\n",
  "actions": [{ "type": "block" }],
  "policy_scope": { "compliance_frameworks": [{ "id": 5 }] },
  "scope_dimensions": ["compliance_frameworks"],
  "scope_rego": "package gitlab.scope\n\napplicable := [result.policy | some result in results; result.applies]\n...",
  "mode": "warn",
  "lifecycle_state": "active",
  "created_at": "2026-08-07T13:56:32.985Z",
  "updated_at": "2026-08-07T13:56:32.985Z"
}
```

<a id="update-an-organization-policy"></a>

### 更新组织策略

更新组织中的策略。除路径参数外的每个属性都是可选的，但请求必须至少指定一个。未发送的属性保持原样，至少更改一个值的更新会使 `version` 加一。重新声明已存储值的请求不会更改任何内容，并保持 `version` 不变。

```plaintext
PATCH /organizations/:id/security/policy_store/:policy_id
```

支持的属性：

| 属性         | 类型    | 是否必需 | 描述 |
| ----------------- | ------- | -------- | ----------- |
| `id`              | integer | 是      | 组织的 ID。 |
| `policy_id`       | integer | 是      | 策略的 ID。 |
| `actions`         | array   | 否       | 策略执行的操作。有关条目属性，请参见[规则和操作属性](#rule-and-action-attributes)。替换已存储的操作，最多 5 个条目。每个条目序列化后必须不超过 4096 字节。 |
| `description`     | string  | 否       | 策略的描述。最多 4096 个字符。 |
| `lifecycle_state` | string  | 否       | 取值为 `active` 或 `disabled`。 |
| `mode`            | string  | 否       | 取值为 `audit`、`warn` 或 `enforce` 之一。 |
| `name`            | string  | 否       | 策略的名称。最多 255 个字符。在组织中必须唯一。 |
| `policy_scope`    | object  | 否       | 策略的结构化范围，极狐GitLab 会将其编译为 `scope_rego`。有关其属性，请参见[策略范围属性](#policy-scope-attributes)。不能与非空的 `scope_rego` 组合使用。当编译为超过 4096 个字符的 Rego 时会被拒绝。 |
| `rules`           | array   | 否       | 策略的规则。有关条目属性，请参见[规则和操作属性](#rule-and-action-attributes)。替换已存储的规则，最多 5 个条目。每个条目序列化后必须不超过 4096 字节。当条目编译为大于 65536 字节的 Rego 模块时会被拒绝。该模块会作为 `policy_rego` 返回。 |
| `scope_rego`      | string  | 否       | 策略的范围，直接以 Rego 程序编写。极狐GitLab 会按您编写的内容原样存储。最多 4096 个字符。发送空值可停用已编写的程序，并从 `policy_scope` 重新编译。无法解析为 Rego 的值会返回 `400 Bad Request`。 |
| `trigger_type`    | string  | 否       | 策略响应的触发器。取[列出所有触发器](#list-all-triggers)返回的 ID 之一。 |

重命名策略时，极狐GitLab 必须重新编译生成的 `scope_rego`，因为策略名称会出现在生成的程序中。直接编写的 `scope_rego` 会保持原样。

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及[策略属性](#response-attributes)。以下情况会返回 `400 Bad Request`：

- 未提供要更改的属性。
- 某个属性无效。
- 同时提供了两种范围形式。
- 新名称在组织中已被占用。
- 重新编译后的 `scope_rego` 超过 4096 个字符。
- 替换后的 `rules` 编译为超过 65536 字节的 Rego。
- 替换后的 `rules` 或 `actions` 携带超过 5 个条目。
- 替换后的 `rules` 或 `actions`中的某个条目序列化后超过 4096 字节。

示例请求：

```shell
curl --request PATCH --header "PRIVATE-TOKEN: <your_access_token>" \
  --data-urlencode "name=Renamed policy" \
  --url "https://gitlab.example.com/api/v4/organizations/1/security/policy_store/1"
```

示例响应：

```json
{
  "id": 1,
  "organization_id": 1,
  "namespace_id": null,
  "name": "Renamed policy",
  "description": null,
  "version": 2,
  "trigger_type": "deployment_requested",
  "rules": [{ "type": "custom", "value": "package governance" }],
  "policy_rego": "package governance\n",
  "actions": [{ "type": "block" }],
  "policy_scope": null,
  "scope_dimensions": [],
  "scope_rego": "package gitlab.scope\n\napplicable := [result.policy | some result in results; result.applies]\n...",
  "mode": "enforce",
  "lifecycle_state": "active",
  "created_at": "2026-08-07T13:56:32.985Z",
  "updated_at": "2026-08-07T14:02:47.198Z"
}
```

<a id="delete-an-organization-policy"></a>

### 删除组织策略

从组织中删除策略。

```plaintext
DELETE /organizations/:id/security/policy_store/:policy_id
```

支持的属性：

| 属性   | 类型    | 是否必需 | 描述 |
| ----------- | ------- | -------- | ----------- |
| `id`        | integer | 是      | 组织的 ID。 |
| `policy_id` | integer | 是      | 策略的 ID。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/organizations/1/security/policy_store/1"
```

<a id="group-policies"></a>

## 群组策略

使用群组端点管理群组的策略。在这些端点中，`id` 是群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。

先决条件：

- 该群组必须是已选择启用策略存储实验的顶级群组。
- 要列出或检索策略，您必须拥有该群组的所有者角色、是审计员，或是实例的管理员。
- 要创建、更新或删除策略，您必须拥有该群组的所有者角色，或是实例的管理员。

群组通过其 `policy_store_experiment_enabled` 设置选择启用。已通过安全策略项目配置了安全策略的群组无法选择启用。

<a id="list-all-group-policies"></a>

### 列出所有群组策略

列出属于某个群组的所有策略。

```plaintext
GET /groups/:id/security/policy_store
```

支持的属性：

| 属性         | 类型              | 是否必需 | 描述 |
| ----------------- | ----------------- | -------- | ----------- |
| `id`              | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `lifecycle_state` | string            | 否       | 仅返回 `active` 策略、仅返回 `disabled` 策略，或返回 `all` 策略。默认为 `active`。 |
| `page`            | integer           | 否       | 要返回的结果页。默认为 `1`。 |
| `per_page`        | integer           | 否       | 每页的结果数。默认为 `20`，任何大于 `100`的值都会上限为 `100`。 |
| `trigger_type`    | string            | 否       | 仅返回响应该触发器的策略。取[列出所有触发器](#list-all-triggers)返回的 ID 之一。 |

此端点返回分页结果。出于性能原因，无论群组有多少策略，它都不会返回 `x-total` 或 `x-total-pages` 响应头，也不会返回 `rel="last"` `link`：请检查 `x-next-page` 以确定是否还有下一页。

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及[策略属性](#response-attributes)数组。

示例请求：

```shell
curl --request GET --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/security/policy_store?per_page=20"
```

示例响应：

```json
[
  {
    "id": 1,
    "organization_id": 1,
    "namespace_id": 5,
    "name": "Block deployments on critical findings",
    "description": null,
    "version": 1,
    "trigger_type": "deployment_requested",
    "rules": [{ "type": "custom", "value": "package governance" }],
    "policy_rego": "package governance\n",
    "actions": [{ "type": "block" }],
    "policy_scope": null,
    "scope_dimensions": [],
    "scope_rego": "package gitlab.scope\n\napplicable := [result.policy | some result in results; result.applies]\n...",
    "mode": "enforce",
    "lifecycle_state": "active",
    "created_at": "2026-08-07T13:56:32.985Z",
    "updated_at": "2026-08-07T13:56:32.985Z"
  }
]
```

<a id="retrieve-a-group-policy"></a>

### 检索群组策略

从群组中检索单个策略。

```plaintext
GET /groups/:id/security/policy_store/:policy_id
```

支持的属性：

| 属性   | 类型              | 是否必需 | 描述 |
| ----------- | ----------------- | -------- | ----------- |
| `id`        | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `policy_id` | integer           | 是      | 策略的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及[策略属性](#response-attributes)。

示例请求：

```shell
curl --request GET --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/security/policy_store/1"
```

示例响应：

```json
{
  "id": 1,
  "organization_id": 1,
  "namespace_id": 5,
  "name": "Block deployments on critical findings",
  "description": null,
  "version": 1,
  "trigger_type": "deployment_requested",
  "rules": [{ "type": "custom", "value": "package governance" }],
  "policy_rego": "package governance\n",
  "actions": [{ "type": "block" }],
  "policy_scope": null,
  "scope_dimensions": [],
  "scope_rego": "package gitlab.scope\n\napplicable := [result.policy | some result in results; result.applies]\n...",
  "mode": "enforce",
  "lifecycle_state": "active",
  "created_at": "2026-08-07T13:56:32.985Z",
  "updated_at": "2026-08-07T13:56:32.985Z"
}
```

<a id="create-a-group-policy"></a>

### 创建群组策略

在群组中创建策略。

```plaintext
POST /groups/:id/security/policy_store
```

支持的属性：

| 属性         | 类型              | 是否必需 | 描述 |
| ----------------- | ----------------- | -------- | ----------- |
| `id`              | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`            | string            | 是      | 策略的名称。最多 255 个字符。在组织中必须唯一。 |
| `rules`           | array             | 是      | 策略的规则。有关条目属性，请参见[规则和操作属性](#rule-and-action-attributes)。至少需要一个条目，最多 5 个。每个条目序列化后必须不超过 4096 字节。当条目编译为大于 65536 字节的 Rego 模块时会被拒绝。该模块会作为 `policy_rego` 返回。 |
| `trigger_type`    | string            | 是      | 策略响应的触发器。取[列出所有触发器](#list-all-triggers)返回的 ID 之一。 |
| `actions`         | array             | 否       | 策略执行的操作。有关条目属性，请参见[规则和操作属性](#rule-and-action-attributes)。最多 5 个条目。每个条目序列化后必须不超过 4096 字节。 |
| `description`     | string            | 否       | 策略的描述。最多 4096 个字符。 |
| `lifecycle_state` | string            | 否       | 取值为 `active` 或 `disabled`。默认为 `active`。 |
| `mode`            | string            | 否       | 取值为 `audit`、`warn` 或 `enforce` 之一。默认为 `warn`。 |
| `policy_scope`    | object            | 否       | 策略的结构化范围，极狐GitLab 会将其编译为 `scope_rego`。有关其属性，请参见[策略范围属性](#policy-scope-attributes)。不能与非空的 `scope_rego` 组合使用。当编译为超过 4096 个字符的 Rego 时会被拒绝。 |
| `scope_rego`      | string            | 否       | 策略的范围，直接以 Rego 程序编写。极狐GitLab 会按您编写的内容原样存储。最多 4096 个字符。非空值不能与 `policy_scope` 组合使用。空值与省略它的效果相同。无法解析为 Rego 的值会返回 `400 Bad Request`。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及[策略属性](#response-attributes)。以下情况会返回 `400 Bad Request`：

- 某个属性无效。
- 同时提供了两种范围形式。
- 该名称在组织中已被占用。
- 编译后的 `scope_rego` 超过 4096 个字符。
- `rules` 编译为超过 65536 字节的 Rego。
- `rules` 或 `actions` 携带超过 5 个条目。
- `rules` 或 `actions`中的某个条目序列化后超过 4096 字节。

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "Block deployments on critical findings",
    "trigger_type": "deployment_requested",
    "rules": [{ "type": "custom", "value": "package governance" }],
    "actions": [{ "type": "block" }],
    "policy_scope": { "compliance_frameworks": [{ "id": 5 }] }
  }' \
  --url "https://gitlab.example.com/api/v4/groups/5/security/policy_store"
```

示例响应：

```json
{
  "id": 1,
  "organization_id": 1,
  "namespace_id": 5,
  "name": "Block deployments on critical findings",
  "description": null,
  "version": 1,
  "trigger_type": "deployment_requested",
  "rules": [{ "type": "custom", "value": "package governance" }],
  "policy_rego": "package governance\n",
  "actions": [{ "type": "block" }],
  "policy_scope": { "compliance_frameworks": [{ "id": 5 }] },
  "scope_dimensions": ["compliance_frameworks"],
  "scope_rego": "package gitlab.scope\n\napplicable := [result.policy | some result in results; result.applies]\n...",
  "mode": "warn",
  "lifecycle_state": "active",
  "created_at": "2026-08-07T13:56:32.985Z",
  "updated_at": "2026-08-07T13:56:32.985Z"
}
```

<a id="update-a-group-policy"></a>

### 更新群组策略

更新群组中的策略。除路径参数外的每个属性都是可选的，但请求必须至少指定一个。未发送的属性保持原样，至少更改一个值的更新会使 `version` 加一。重新声明已存储值的请求不会更改任何内容，并保持 `version` 不变。

```plaintext
PATCH /groups/:id/security/policy_store/:policy_id
```

支持的属性：

| 属性         | 类型              | 是否必需 | 描述 |
| ----------------- | ----------------- | -------- | ----------- |
| `id`              | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `policy_id`       | integer           | 是      | 策略的 ID。 |
| `actions`         | array             | 否       | 策略执行的操作。有关条目属性，请参见[规则和操作属性](#rule-and-action-attributes)。替换已存储的操作，最多 5 个条目。每个条目序列化后必须不超过 4096 字节。 |
| `description`     | string            | 否       | 策略的描述。最多 4096 个字符。 |
| `lifecycle_state` | string            | 否       | 取值为 `active` 或 `disabled`。 |
| `mode`            | string            | 否       | 取值为 `audit`、`warn` 或 `enforce` 之一。 |
| `name`            | string            | 否       | 策略的名称。最多 255 个字符。在组织中必须唯一。 |
| `policy_scope`    | object            | 否       | 策略的结构化范围，极狐GitLab 会将其编译为 `scope_rego`。有关其属性，请参见[策略范围属性](#policy-scope-attributes)。不能与非空的 `scope_rego` 组合使用。当编译为超过 4096 个字符的 Rego 时会被拒绝。 |
| `rules`           | array             | 否       | 策略的规则。有关条目属性，请参见[规则和操作属性](#rule-and-action-attributes)。替换已存储的规则，最多 5 个条目。每个条目序列化后必须不超过 4096 字节。当条目编译为大于 65536 字节的 Rego 模块时会被拒绝。该模块会作为 `policy_rego` 返回。 |
| `scope_rego`      | string            | 否       | 策略的范围，直接以 Rego 程序编写。极狐GitLab 会按您编写的内容原样存储。最多 4096 个字符。发送空值可停用已编写的程序，并从 `policy_scope` 重新编译。无法解析为 Rego 的值会返回 `400 Bad Request`。 |
| `trigger_type`    | string            | 否       | 策略响应的触发器。取[列出所有触发器](#list-all-triggers)返回的 ID 之一。 |

重命名策略时，极狐GitLab 必须重新编译生成的 `scope_rego`，因为策略名称会出现在生成的程序中。直接编写的 `scope_rego` 会保持原样。

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及[策略属性](#response-attributes)。以下情况会返回 `400 Bad Request`：

- 未提供要更改的属性。
- 某个属性无效。
- 同时提供了两种范围形式。
- 新名称在组织中已被占用。
- 重新编译后的 `scope_rego` 超过 4096 个字符。
- 替换后的 `rules` 编译为超过 65536 字节的 Rego。
- 替换后的 `rules` 或 `actions` 携带超过 5 个条目。
- 替换后的 `rules` 或 `actions`中的某个条目序列化后超过 4096 字节。

示例请求：

```shell
curl --request PATCH --header "PRIVATE-TOKEN: <your_access_token>" \
  --data-urlencode "name=Renamed policy" \
  --url "https://gitlab.example.com/api/v4/groups/5/security/policy_store/1"
```

示例响应：

```json
{
  "id": 1,
  "organization_id": 1,
  "namespace_id": 5,
  "name": "Renamed policy",
  "description": null,
  "version": 2,
  "trigger_type": "deployment_requested",
  "rules": [{ "type": "custom", "value": "package governance" }],
  "policy_rego": "package governance\n",
  "actions": [{ "type": "block" }],
  "policy_scope": null,
  "scope_dimensions": [],
  "scope_rego": "package gitlab.scope\n\napplicable := [result.policy | some result in results; result.applies]\n...",
  "mode": "enforce",
  "lifecycle_state": "active",
  "created_at": "2026-08-07T13:56:32.985Z",
  "updated_at": "2026-08-07T14:02:47.198Z"
}
```

<a id="delete-a-group-policy"></a>

### 删除群组策略

从群组中删除策略。

```plaintext
DELETE /groups/:id/security/policy_store/:policy_id
```

支持的属性：

| 属性   | 类型              | 是否必需 | 描述 |
| ----------- | ----------------- | -------- | ----------- |
| `id`        | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `policy_id` | integer           | 是      | 策略的 ID。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/security/policy_store/1"
```
