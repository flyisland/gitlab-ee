---
stage: Security Risk Management
group: Security Policies
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于管理组织策略存储中安全策略的 REST API。
title: 策略存储 API
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

> [!warning]
> 此功能是一个[实验](../policy/development_stages_support.md)。
> 端点可能随时更改，恕不另行通知。

使用此 API 在策略存储中编写[安全策略](../user/application_security/policies/_index.md)。
策略属于某个组织，响应单个触发器，并携带构成其行为的规则和操作。

仅当以下所有条件都成立时，这些端点才可用：

- 已启用 `security_policies_v2` 功能标志。
- 管理员已在 **管理员** > **设置** > **安全与合规** 中为实例启用策略存储实验。
- 该组织已通过其 `policy_store_experiment_enabled` 组织设置选择加入，该设置通过 `policyStoreExperimentEnabled` 参数在 `organizationUpdate` GraphQL 变更中设置。

当上述任一条件不成立时，端点返回 `404 Not Found`。
当实例未获得安全编排策略的许可时，端点返回 `403 Forbidden`。

<a id="catalogs"></a>

## 目录

目录端点描述策略可以由哪些内容构建。
它们为每个调用者返回相同的静态内容，因此不需要身份验证，也不需要权限。

<a id="list-all-triggers"></a>

### 列出所有触发器

列出策略可以响应的所有触发器。

```plaintext
GET /security/policy_store/triggers
```

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性 | 类型   | 描述 |
| --------- | ------ | ----------- |
| `[].id`   | string | 触发器的 ID，在编写策略时用作 `trigger_type`。 |
| `[].name` | string | 触发器的显示名称。 |

示例请求：

```shell
curl --request GET \
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

列出策略可以采取的所有操作。

```plaintext
GET /security/policy_store/actions
```

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性 | 类型   | 描述 |
| --------- | ------ | ----------- |
| `[].id`   | string | 操作的 ID。 |
| `[].name` | string | 操作的显示名称。 |

示例请求：

```shell
curl --request GET \
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

列出策略可以由哪些规则类型构建。

```plaintext
GET /security/policy_store/rules
```

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性 | 类型   | 描述 |
| --------- | ------ | ----------- |
| `[].id`   | string | 规则类型的 ID。 |
| `[].name` | string | 规则类型的显示名称。 |

示例请求：

```shell
curl --request GET \
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

<a id="policies"></a>

## 策略

对策略端点的每次调用都必须[进行身份验证](rest/authentication.md)，并且调用者必须是组织的所有者或实例管理员。
无法管理组织的调用者会收到 `403 Forbidden`，而完全无法查看组织的调用者会收到 `404 Not Found`。

属于其他组织的策略与不存在的策略无法区分。
ID 不能用于跨组织读取或更改策略。

<a id="policy-scope"></a>

### 策略范围

除非策略带有范围，否则它在所有位置生效。
范围有两种编写方式，一个请求可以使用其中一种，但不能同时使用两种：

- `policy_scope`：结构化数据，由极狐GitLab 编译为 `scope_rego`。
- `scope_rego`：直接提供的 [Rego](https://www.openpolicyagent.org/docs/policy-language) 程序，按编写原样存储。

同时提供两者的请求返回 `400 Bad Request`。
空的 `scope_rego` 不计为第二种形式，因此任一操作都可以将其与 `policy_scope` 一起接受。
在[创建策略](#create-a-policy)时，空值与省略该值效果相同。
在[更新策略](#update-a-policy)时，它会停用已编写的程序，并根据 `policy_scope` 编译新程序。

`scope_rego` 始终出现在响应中，因为没有范围的策略会编译为适用于每个项目的程序。
当 Rego 是直接编写时，`policy_scope` 为 `null`，因为手写程序没有结构化形式。

`scope_dimensions` 列出 `scope_rego` 读取以决定策略是否适用的点分上下文路径，例如 `compliance_frameworks` 或 `project.id`。极狐GitLab 会派生此列表，因此会忽略您为该属性发送的任何值。此值始终是一个数组，当策略无范围时为空，除非 `scope_rego` 是直接编写而非从 `policy_scope` 编译的。在这种情况下，极狐GitLab 无法从手写程序中派生路径，因此 `scope_dimensions` 为 `null`，表示路径未知而非为空。

<a id="policy-scope-structure"></a>

#### 策略范围结构

`policy_scope` 包含一个或多个条件，`match_mode` 控制它们如何组合。
条件指定 ID，可以是整数，也可以是带有 `id` 键的对象。
极狐GitLab 会对 ID 进行去重和排序，因此编写顺序不会改变编译后的程序。

| 属性 | 类型 | 描述 |
| --------- | ---- | ----------- |
| `application` | object | 应用程序安全属性 ID 的 `including` 和 `excluding` 列表。 |
| `business_impact` | object | 业务影响安全属性 ID 的 `including` 和 `excluding` 列表。 |
| `business_unit` | object | 业务部门安全属性 ID 的 `including` 和 `excluding` 列表。 |
| `compliance_frameworks` | array | 项目必须携带的合规框架的 ID。直接接受列表，而不是 `including` 和 `excluding`。 |
| `exposure` | object | 暴露安全属性 ID 的 `including` 和 `excluding` 列表。 |
| `groups` | object | 群组 ID 的 `including` 和 `excluding` 列表。 |
| `match_mode` | string | 可以是 `all` 或 `any`。使用 `all` 时，每个条件都必须匹配。使用 `any` 时，一个匹配就足够。任何其他值都视为 `all`。 |
| `projects` | object | 项目 ID 的 `including` 和 `excluding` 列表。`excluding` 也接受 `{"type": "personal"}` 和 `{"type": "archived"}`，它们会排除该类型的所有项目。 |

例如：

```json
{
  "match_mode": "any",
  "compliance_frameworks": [{ "id": 5 }],
  "projects": { "including": [12, 34], "excluding": [{ "type": "archived" }] },
  "groups": { "including": [{ "id": 7 }] }
}
```

无法被极狐GitLab 识别为 ID 的值会返回 `400 Bad Request`。
这包括不是数字的值，以及超出 1 到 9223372036854775807 范围的数字。

有三种情况会被接受且值得了解，因为每种情况对策略范围的限定方式都与您可能预期的不同：

- 未指定任何 ID 的 `including` 列表对该条件不匹配任何内容。在 `match_mode: all` 下，策略随后不适用于任何项目。在 `match_mode: any` 下，另一个条件仍然可以匹配。
- 未指定任何 ID 的 `excluding` 列表不排除任何内容。
- 极狐GitLab 无法识别的条件没有效果。如果它是唯一提供的条件，则策略适用于每个项目。

<a id="rules-and-actions"></a>

### 规则和操作

`rules` 和 `actions` 是数组。
每个条目具有以下属性：

| 属性 | 类型           | 必填 | 描述 |
| --------- | -------------- | -------- | ----------- |
| `type`    | string         | 是      | 对于规则，为[列出所有规则类型](#list-all-rule-kinds)返回的 ID 之一。对于操作，为[列出所有操作](#list-all-actions)返回的 ID 之一。 |
| `value`   | string 或 hash | 否       | 条目所作用的内容。`custom` 规则将 Rego 源代码作为字符串。`calendar` 或 `environment` 规则接受哈希，每个操作也是如此。 |

条目不能为空。
空条目返回 `400 Bad Request`，错误会指出每个空白位置，例如 `rules[0] is blank`。

每个数组最多接受 5 个条目，每个条目序列化后不能超过 4096 字节。
超出任一限制都会返回 `400 Bad Request`。过大的条目会指出每个违规位置，例如 `rules has an entry exceeding maximum size of 4096 bytes at 0`。

请求会替换整个数组。
您不能添加或删除单个条目。

请以 JSON 形式发送 `rules` 和 `actions`，并带上 `Content-Type: application/json` 请求头。
表单编码的请求体可以携带两个数组，但其中的每个值都会以字符串形式到达，因此不是字符串的 `value` 无法以这种方式表达。

<a id="response-attributes"></a>

### 响应属性

策略端点返回以下属性：

| 属性         | 类型            | 描述 |
| ----------------- | --------------- | ----------- |
| `actions`         | array           | 策略采取的操作。 |
| `created_at`      | string          | 策略创建的日期和时间。 |
| `description`     | string          | 策略的描述。 |
| `id`              | integer         | 策略的 ID。 |
| `lifecycle_state` | string          | 可以是 `active` 或 `disabled`。 |
| `mode`            | string          | 可以是 `audit`、`warn` 或 `enforce` 之一。 |
| `name`            | string          | 策略的名称。 |
| `namespace_id`    | integer         | 拥有该策略的群组的 ID。目前始终为 `null`，因为没有端点接受 `namespace_id` 属性，因此通过此 API 创建的每个策略都由其组织拥有。 |
| `organization_id` | integer         | 策略所属组织的 ID。 |
| `policy_rego`     | string          | 策略的规则，编译为单个 Rego 模块。对于没有规则的策略为 `null`。 |
| `policy_scope`    | object          | 策略的结构化范围，当 Rego 是直接编写时为 `null`。 |
| `rules`           | array           | 策略的规则。 |
| `scope_dimensions`| array           | `scope_rego` 读取以决定策略是否适用的点分上下文路径。极狐GitLab 会派生此值，因此会忽略您为其发送的任何值。当 `scope_rego` 是直接编写时为 `null`，否则为一个数组，当策略无范围时为空。 |
| `scope_rego`      | string          | 策略的编译后范围，以 Rego 表示。 |
| `trigger_type`    | string          | 策略响应的触发器。 |
| `updated_at`      | string          | 策略最后更改的日期和时间。 |
| `version`         | integer         | 策略的修订版本。更改至少一个值的更新会将其加一。 |

<a id="list-all-policies"></a>

### 列出所有策略

列出属于某个组织的所有策略。

```plaintext
GET /organizations/:id/security/policy_store
```

支持的属性：

| 属性      | 类型    | 必填 | 描述 |
| -------------- | ------- | -------- | ----------- |
| `id`           | integer | 是      | 组织的 ID。 |
| `trigger_type` | string  | 否       | 仅返回响应此触发器的策略。为[列出所有触发器](#list-all-triggers)返回的 ID 之一。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 及一个[策略属性](#response-attributes)数组。

示例请求：

```shell
curl --request GET --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/organizations/1/security/policy_store"
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

<a id="retrieve-a-policy"></a>

### 检索策略

从组织中检索单个策略。

```plaintext
GET /organizations/:id/security/policy_store/:policy_id
```

支持的属性：

| 属性   | 类型    | 必填 | 描述 |
| ----------- | ------- | -------- | ----------- |
| `id`        | integer | 是      | 组织的 ID。 |
| `policy_id` | integer | 是      | 策略的 ID。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 及[策略属性](#response-attributes)。

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

<a id="create-a-policy"></a>

### 创建策略

在组织中创建策略。

```plaintext
POST /organizations/:id/security/policy_store
```

支持的属性：

| 属性         | 类型    | 必填 | 描述 |
| ----------------- | ------- | -------- | ----------- |
| `id`              | integer | 是      | 组织的 ID。 |
| `name`            | string  | 是      | 策略的名称。最多 255 个字符。在组织中必须唯一。 |
| `rules`           | array   | 是      | 策略的规则。至少需要一个条目，最多 5 个。每个条目序列化后不得超过 4096 字节。当条目编译为大于 65536 字节的 Rego 模块时会被拒绝。该模块作为 `policy_rego` 返回。 |
| `trigger_type`    | string  | 是      | 策略响应的触发器。为[列出所有触发器](#list-all-triggers)返回的 ID 之一。 |
| `actions`         | array   | 否       | 策略采取的操作。最多 5 个条目。每个条目序列化后不得超过 4096 字节。 |
| `description`     | string  | 否       | 策略的描述。最多 4096 个字符。 |
| `lifecycle_state` | string  | 否       | 可以是 `active` 或 `disabled`。默认为 `active`。 |
| `mode`            | string  | 否       | 可以是 `audit`、`warn` 或 `enforce` 之一。默认为 `enforce`。 |
| `policy_scope`    | object  | 否       | 策略的结构化范围。不能与非空的 `scope_rego` 组合。当它编译为超过 4096 个字符的 Rego 时会被拒绝。 |
| `scope_rego`      | string  | 否       | 策略的范围，以 Rego 编写。最多 4096 个字符。非空值不能与 `policy_scope` 组合。 |

如果成功，返回 [`201`](rest/troubleshooting.md#status-codes) 及[策略属性](#response-attributes)。
以下情况返回 `400 Bad Request`：

- 属性无效。
- 同时提供了两种范围形式。
- 该名称在组织中已被占用。
- 编译后的 `scope_rego` 超过 4096 个字符。
- `rules` 编译为超过 65536 字节的 Rego。
- `rules` 或 `actions` 包含超过 5 个条目。
- `rules` 或 `actions` 中的条目序列化后超过 4096 字节。

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
  "mode": "enforce",
  "lifecycle_state": "active",
  "created_at": "2026-08-07T13:56:32.985Z",
  "updated_at": "2026-08-07T13:56:32.985Z"
}
```

<a id="update-a-policy"></a>

### 更新策略

更新组织中的策略。
除路径参数外的每个属性都是可选的，但请求必须至少指定一个。
未发送的属性保持不变，更改至少一个值的更新会将 `version` 加一。
原样重复提交已存储值的请求不会更改任何内容，`version` 也保持不变。

```plaintext
PATCH /organizations/:id/security/policy_store/:policy_id
```

支持的属性：

| 属性         | 类型    | 必填 | 描述 |
| ----------------- | ------- | -------- | ----------- |
| `id`              | integer | 是      | 组织的 ID。 |
| `policy_id`       | integer | 是      | 策略的 ID。 |
| `actions`         | array   | 否       | 策略采取的操作。替换存储的操作，最多 5 个条目。每个条目序列化后不得超过 4096 字节。 |
| `description`     | string  | 否       | 策略的描述。最多 4096 个字符。 |
| `lifecycle_state` | string  | 否       | 可以是 `active` 或 `disabled`。 |
| `mode`            | string  | 否       | 可以是 `audit`、`warn` 或 `enforce` 之一。 |
| `name`            | string  | 否       | 策略的名称。最多 255 个字符。在组织中必须唯一。 |
| `policy_scope`    | object  | 否       | 策略的结构化范围。不能与非空的 `scope_rego` 组合。当它编译为超过 4096 个字符的 Rego 时会被拒绝。 |
| `rules`           | array   | 否       | 策略的规则。替换存储的规则，最多 5 个条目。每个条目序列化后不得超过 4096 字节。当条目编译为大于 65536 字节的 Rego 模块时会被拒绝。该模块作为 `policy_rego` 返回。 |
| `scope_rego`      | string  | 否       | 策略的范围，以 Rego 编写。最多 4096 个字符。发送空值以停用已编写的程序并从 `policy_scope` 重新编译。 |
| `trigger_type`    | string  | 否       | 策略响应的触发器。为[列出所有触发器](#list-all-triggers)返回的 ID 之一。 |

当您重命名策略时，极狐GitLab 必须重新编译生成的 `scope_rego`，因为策略名称出现在生成的程序中。
直接编写的 `scope_rego` 保持不变。

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 及[策略属性](#response-attributes)。
以下情况返回 `400 Bad Request`：

- 未提供要更改的属性。
- 属性无效。
- 同时提供了两种范围形式。
- 新名称在组织中已被占用。
- 重新编译的 `scope_rego` 超过 4096 个字符。
- 替换的 `rules` 编译为超过 65536 字节的 Rego。
- 替换的 `rules` 或 `actions` 包含超过 5 个条目。
- 替换的 `rules` 或 `actions` 中的条目序列化后超过 4096 字节。

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

<a id="delete-a-policy"></a>

### 删除策略

从组织中删除策略。

```plaintext
DELETE /organizations/:id/security/policy_store/:policy_id
```

支持的属性：

| 属性   | 类型    | 必填 | 描述 |
| ----------- | ------- | -------- | ----------- |
| `id`        | integer | 是      | 组织的 ID。 |
| `policy_id` | integer | 是      | 策略的 ID。 |

如果成功，返回 [`204`](rest/troubleshooting.md#status-codes) 及空响应体。

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/organizations/1/security/policy_store/1"
```
