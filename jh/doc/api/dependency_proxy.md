---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 依赖代理 API
description: Documentation for the REST API for the GitLab dependency proxy.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 来管理[依赖代理](../user/packages/dependency_proxy/_index.md)。

<a id="purge-the-dependency-proxy-for-a-group"></a>

## 清除群组的依赖代理

计划删除群组的缓存清单和二进制大对象。此端点需要群组的**所有者**角色。

```plaintext
DELETE /groups/:id/dependency_proxy/cache
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request DELETE \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/groups/5/dependency_proxy/cache"
```