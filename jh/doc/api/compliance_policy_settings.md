---
stage: Security Risk Management
group: Security Policies
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 合规与策略设置 API
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 18.2 中通过一个名为 `security_policies_csp` 的功能标志引入。默认禁用。
- 在 极狐GitLab 18.3 中于私有化部署默认启用。
- 已在 极狐GitLab 18.5 中 GA。功能标志 `security_policies_csp` 已移除。

{{< /history >}}

使用此 API 与您的 极狐GitLab 实例的安全策略设置进行交互。

先决条件：

- 您必须具有该实例的管理员访问权限。
- 您的实例必须具有旗舰版才可以使用安全策略。

<a id="retrieve-security-policy-settings"></a>

## 检索安全策略设置

检索此 极狐GitLab 实例的当前安全策略设置。

```plaintext
GET /admin/security/compliance_policy_settings
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/security/compliance_policy_settings"
```

示例响应：

```json
{
  "csp_namespace_id": 42
}
```

当未配置 CSP 命名空间时：

```json
{
  "csp_namespace_id": null
}
```

<a id="update-security-policy-settings"></a>

## 更新安全策略设置

更新此 极狐GitLab 实例的安全策略设置。

```plaintext
PUT /admin/security/compliance_policy_settings
```

| 属性         | 类型    | 是否必需 | 描述 |
|:------------------|:--------|:---------|:------------|
| `csp_namespace_id` | 整数 | 是     | 指定集中管理安全策略的群组 ID。必须为顶级群组。设置为 `null` 可清除此设置。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"csp_namespace_id": 42}' \
  --url "https://gitlab.example.com/api/v4/admin/security/compliance_policy_settings"
```

示例响应：

```json
{
  "csp_namespace_id": 42
}
```