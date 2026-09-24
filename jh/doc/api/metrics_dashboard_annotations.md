---
stage: Monitor
group: Respond
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/product/ux/technical-writing/#assignments
type: concepts, howto
---

# 仪表盘注释 API **(BASIC ALL)**

> 引入于极狐GitLab 12.10，相关功能标志禁用。

指标仪表盘注释允许您在图表上指示单个时间点或一段时间内的事件。

## 创建新注释

```plaintext
POST /environments/:id/metrics_dashboard/annotations/
POST /clusters/:id/metrics_dashboard/annotations/
```

参数：

| 参数               | 类型     | 是否必需 | 描述                                                                                                                                                          |
|:-----------------|:-------|:-----|:------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `dashboard_path` | string | yes  | 需要注释的仪表盘 ID。视为 CGI 转义的路径，且自动不转义                                                                                                                             |
| `starting_at`    | string | yes  | 日期时间字符串。格式为 ISO 8601，例如 `2016-03-11T03:45:40Z`。时间戳标记注释的起点                                                                                                   |
| `ending_at`      | string | no   | 日期时间字符串。格式为 ISO 8601，例如 `2016-03-11T03:45:40Z`。时间戳标记注释的终点。如未提供，注释展示为起点的单个事件 |
| `description`    | string | yes  | 注释描述                                                                                                                                                        |

```shell
curl --header "Private-Token: <your_access_token>" "https://gitlab.example.com/api/v4/environments/1/metrics_dashboard/annotations" \
 --data-urlencode "dashboard_path=.gitlab/dashboards/custom_metrics.yml" \
 --data-urlencode "starting_at=2016-03-11T03:45:40Z" \
 --data-urlencode "description=annotation description"
```

响应示例：

```json
{
  "id": 4,
  "starting_at": "2016-04-08T03:45:40.000Z",
  "ending_at": null,
  "dashboard_path": ".gitlab/dashboards/custom_metrics.yml",
  "description": "annotation description",
  "environment_id": 1,
  "cluster_id": null
}
```
