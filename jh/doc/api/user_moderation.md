---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用户审核 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 来审核用户账号。有关更多信息，请参见[审核用户](../administration/moderate_users.md)。

<a id="approve-access-to-a-user"></a>

## 批准用户访问

批准对正在等待审批的指定用户账号的访问。

先决条件：

- 您必须拥有实例的管理员权限。

```plaintext
POST /users/:id/approve
```

支持的属性：

| 属性      | 类型    | 是否必需 | 描述          |
|------------|---------|----------|--------------------|
| `id`       | 整数 | 是      | 用户账号 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/42/approve"
```

返回：

- 成功时返回 `201 Created`。
- 如果找不到用户，返回 `404 User Not Found`。
- 如果用户因被管理员或 LDAP 同步阻止而无法批准，返回 `403 Forbidden`。
- 如果用户已被停用，返回 `409 Conflict`。

示例响应：

```json
{ "message": "成功" }
```

```json
{ "message": "404 用户未找到" }
```

```json
{ "message": "您尝试批准的用户不是待批准状态" }
```

<a id="reject-access-to-a-user"></a>

## 拒绝用户访问

拒绝对正在等待审批的指定用户账号的访问。

先决条件：

- 您必须拥有实例的管理员权限。

```plaintext
POST /users/:id/reject
```

支持的属性：

| 属性      | 类型    | 是否必需 | 描述          |
|------------|---------|----------|--------------------|
| `id`       | 整数 | 是      | 用户账号 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/42/reject"
```

返回：

- 成功时返回 `200 OK`。
- 如果未以管理员身份认证，返回 `403 Forbidden`。
- 如果找不到用户，返回 `404 User Not Found`。
- 如果用户不是待批准状态，返回 `409 Conflict`。

示例响应：

```json
{ "message": "成功" }
```

```json
{ "message": "404 用户未找到" }
```

```json
{ "message": "用户没有待处理的请求" }
```

<a id="deactivate-a-user"></a>

## 停用用户

停用指定的用户账号。有关被禁止用户的更多信息，请参见[激活和停用用户](../administration/moderate_users.md#deactivate-and-reactivate-users)。

先决条件：

- 您必须拥有实例的管理员权限。

```plaintext
POST /users/:id/deactivate
```

支持的属性：

| 属性      | 类型    | 是否必需 | 描述          |
|------------|---------|----------|--------------------|
| `id`       | 整数 | 是      | 用户账号 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/42/deactivate"
```

返回：

- 成功时返回 `201 OK`。
- 如果找不到用户，返回 `404 User Not Found`。
- 尝试停用以下用户时返回 `403 Forbidden`：
  - 被管理员或 LDAP 同步阻止。
  - 非[休眠](../administration/moderate_users.md#automatically-deactivate-dormant-users)。
  - 内部用户。

<a id="reactivate-a-user"></a>

## 重新激活用户

重新激活之前被停用的指定用户账号。

先决条件：

- 您必须拥有实例的管理员权限。

```plaintext
POST /users/:id/activate
```

支持的属性：

| 属性      | 类型    | 是否必需 | 描述          |
|------------|---------|----------|--------------------|
| `id`       | 整数 | 是      | 用户账号 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/42/activate"
```

返回：

- 成功时返回 `201 OK`。
- 如果找不到用户，返回 `404 User Not Found`。
- 如果用户因被管理员或 LDAP 同步阻止而无法激活，返回 `403 Forbidden`。

<a id="block-access-to-a-user"></a>

## 阻止用户访问

阻止指定的用户账号。有关被禁止用户的更多信息，请参见[阻止和解阻用户](../administration/moderate_users.md#block-and-unblock-users)。

先决条件：

- 您必须拥有实例的管理员权限。

```plaintext
POST /users/:id/block
```

支持的属性：

| 属性      | 类型    | 是否必需 | 描述          |
|------------|---------|----------|--------------------|
| `id`       | 整数 | 是      | 用户账号 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/42/block"
```

返回：

- 成功时返回 `201 OK`。
- 如果找不到用户，返回 `404 User Not Found`。
- 尝试阻止以下用户时返回 `403 Forbidden`：
  - 通过 LDAP 被阻止的用户。
  - 内部用户。

<a id="unblock-access-to-a-user"></a>

## 解除对用户的访问阻止

解除阻止之前被阻止的指定用户账号。

先决条件：

- 您必须拥有实例的管理员权限。

```plaintext
POST /users/:id/unblock
```

支持的属性：

| 属性      | 类型    | 是否必需 | 描述          |
|------------|---------|----------|--------------------|
| `id`       | 整数 | 是      | 用户账号 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/42/unblock"
```

返回：

- 成功时返回 `201 OK`。
- 如果找不到用户，返回 `404 User Not Found`。
- 尝试解除阻止一个被 LDAP 同步阻止的用户时，返回 `403 Forbidden`。

<a id="ban-a-user"></a>

## 封禁用户

封禁指定的用户账号。有关被禁止用户的更多信息，请参见[封禁和解封用户](../administration/moderate_users.md#ban-and-unban-users)。

先决条件：

- 您必须拥有实例的管理员权限。

```plaintext
POST /users/:id/ban
```

支持的属性：

| 属性      | 类型    | 是否必需 | 描述          |
|------------|---------|----------|--------------------|
| `id`       | 整数 | 是      | 用户账号 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/42/ban"
```

返回：

- 成功时返回 `201 OK`。
- 如果找不到用户，返回 `404 User Not Found`。
- 尝试封禁一个非活跃用户时，返回 `403 Forbidden`。

<a id="unban-a-user"></a>

## 解封用户

解封之前被封禁的指定用户账号。

先决条件：

- 您必须拥有实例的管理员权限。

```plaintext
POST /users/:id/unban
```

支持的属性：

| 属性      | 类型    | 是否必需 | 描述          |
|------------|---------|----------|--------------------|
| `id`       | 整数 | 是      | 用户账号 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/42/unban"
```

返回：

- 成功时返回 `201 OK`。
- 如果找不到用户，返回 `404 User Not Found`。
- 尝试解封一个未被封禁的用户时，返回 `403 Forbidden`。