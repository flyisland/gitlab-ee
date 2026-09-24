---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组活动分析 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 获取有关群组活动的信息。更多信息，请参见[群组活动分析](../user/group/manage.md#group-activity-analytics)。

<a id="retrieve-count-of-recently-created-issues-for-a-group"></a>

## 检索一个群组最近创建的议题数量

检索指定群组最近创建的议题数量。

```plaintext
GET /analytics/group_activity/issues_count
```

参数：

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `group_path` | string | 是 | 群组路径 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/analytics/group_activity/issues_count?group_path=gitlab-org"
```

响应示例：

```json
{ "issues_count": 10 }
```

<a id="retrieve-count-of-recently-created-merge-requests-for-a-group"></a>

## 检索一个群组最近创建的合并请求数量

检索指定群组最近创建的合并请求数量。

```plaintext
GET /analytics/group_activity/merge_requests_count
```

参数：

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `group_path` | string | 是 | 群组路径 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/analytics/group_activity/merge_requests_count?group_path=gitlab-org"
```

响应示例：

```json
{ "merge_requests_count": 10 }
```

<a id="retrieve-count-of-members-recently-added-to-a-group"></a>

## 检索最近添加到群组的成员数量

检索最近添加到指定群组的成员数量。

```plaintext
GET /analytics/group_activity/new_members_count
```

参数：

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `group_path` | string | 是 | 群组路径 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/analytics/group_activity/new_members_count?group_path=gitlab-org"
```

响应示例：

```json
{ "new_members_count": 10 }
```