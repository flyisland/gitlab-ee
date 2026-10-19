---
stage: Monitor
group: Respond
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/product/ux/technical-writing/#assignments
type: concepts, howto
---

# 用户星标的指标仪表盘 API **(BASIC ALL)**

星标的仪表盘功能可以在选择列表顶部显示收藏的仪表盘，从而使用户更容易导航到常用仪表盘。

## 向仪表盘添加星标

> 引入于极狐GitLab 13.0。

```plaintext
POST /projects/:id/metrics/user_starred_dashboards
```

参数：

| 参数               | 类型             | 是否必需 | 描述                                                                                      |
|:-----------------|:---------------|:-----|:----------------------------------------------------------------------------------------|
| `id`             | integer/string | yes  | ID 或 [URL 编码的项目路径](rest/index.md#namespaced-path-encoding)                                   |
| `dashboard_path` | string         | yes  | URL 编码的文件路径，该文件定义应该被标为收藏的仪表盘 |

```shell
curl --header 'Private-Token: <your_access_token>' "https://gitlab.example.com/api/v4/projects/20/metrics/user_starred_dashboards" \
 --data-urlencode "dashboard_path=config/prometheus/dashboards/common_metrics.yml"
```

响应示例：

```json
{
  "id": 5,
  "dashboard_path": "config/prometheus/common_metrics.yml",
  "user_id": 1,
  "project_id": 20
}
```

## 从仪表盘移除星标

> 引入于极狐GitLab 13.0。

```plaintext
DELETE /projects/:id/metrics/user_starred_dashboards
```

参数：

| 参数               | 类型             | 是否必需 | 描述                                                    |
|:-----------------|:---------------|:-----|:------------------------------------------------------|
| `id`             | integer/string | yes  | ID 或 [URL 编码的项目路径](rest/index.md#namespaced-path-encoding) |
| `dashboard_path` | string         | no   | URL 编码的文件路径，该文件定义不应被标为收藏的仪表盘。如未提供，给定项目中的所有仪表盘都会被取消收藏  |

```shell
curl --request DELETE --header 'Private-Token: <your_access_token>' "https://gitlab.example.com/api/v4/projects/20/metrics/user_starred_dashboards" \
 --data-urlencode "dashboard_path=config/prometheus/dashboards/common_metrics.yml"
```

响应示例：

```json
{
  "deleted_rows": 1
}
```
