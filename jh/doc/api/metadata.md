---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 元数据 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.2 引入。
- `enterprise` 在极狐GitLab 15.6 引入。
- `kas.externalK8sProxyUrl` 在极狐GitLab 17.6 引入。

{{< /history >}}

获取指定极狐GitLab实例的元数据信息。

```plaintext
GET /metadata
GET /version
```

响应体属性：

| 属性 | 类型 | 描述 |
|:--------------------------|:---------------|:------------------------------------------------------------------------------------------------------------------------------|
| `version` | 字符串 | 极狐GitLab实例的版本。 |
| `revision` | 字符串 | 极狐GitLab实例的修订版。 |
| `kas` | 对象 | 有关极狐GitLab Kubernetes代理服务器 (KAS) 的元数据。 |
| `kas.enabled` | 布尔 | 指示KAS是否已启用。 |
| `kas.externalUrl` | 字符串或 null | 代理用于与KAS通信的URL。如果`kas.enabled`为`false`则为`null`。 |
| `kas.externalK8sProxyUrl` | 字符串或 null | Kubernetes工具用于与KAS Kubernetes API代理通信的URL。如果`kas.enabled`为`false`则为`null`。 |
| `kas.version` | 字符串或 null | KAS的版本。如果`kas.enabled`为`false`或极狐GitLab实例无法从KAS获取服务器信息时则为`null`。 |
| `enterprise` | 布尔 | 指示极狐GitLab实例是否为企业版。 |

请求示例：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/metadata"
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/version"
```

响应示例：

```json
{
  "version": "18.1.1-ee",
  "revision": "ceb07b24cb0",
  "kas": {
    "enabled": true,
    "externalUrl": "grpc://gitlab.example.com:8150",
    "externalK8sProxyUrl": "https://gitlab.example.com:8150/k8s-proxy",
    "version": "18.1.1"
  },
  "enterprise": true
}
```