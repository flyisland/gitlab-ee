---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 集群发现 API（基于证书）（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能在极狐GitLab 14.5 中已弃用。

## 检索基于证书的集群

<a id="retrieve-certificate-based-clusters"></a>

检索在群组、子群组或项目中注册的基于证书的集群。已禁用和已启用的集群也会返回。

```plaintext
GET /discover-cert-based-clusters
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --- | --- | --- | --- |
| `group_id` | integer or string | 是 | 群组的 ID |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/discover-cert-based-clusters?group_id=1"
```

示例响应：

```json
{
  "groups": {
    "my-clusters-group": [
      {
        "id": 2,
        "name": "group-cluster-1"
      }
    ],
    "my-clusters-group/subgroup1/subsubgroup1": [
      {
        "id": 4,
        "name": "subsubgroup-cluster"
      }
    ]
  },
  "projects": {
    "my-clusters-group/subgroup1/subsubgroup1/subsubgroup-project-with-cluster": [
      {
        "id": 3,
        "name": "subsubgroup-project-cluster"
      }
    ],
    "my-clusters-group/project1-with-cluster": [
      {
        "id": 1,
        "name": "test"
      }
    ]
  }
}
```