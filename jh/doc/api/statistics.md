---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 应用统计 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 从您的 极狐GitLab 实例获取统计信息。

前提条件：

- 您必须具备实例的管理员访问权限。

<a id="retrieve-application-statistics"></a>

获取应用统计信息

从您的 极狐GitLab 实例获取统计信息。

> [!note]
> 对于小于 10,000 的值，此端点返回精确计数。对于 10,000 及以上的值，当计算中使用 [TablesampleCountStrategy](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/database/count/tablesample_count_strategy.rb?ref_type=heads#L16) 和 [ReltuplesCountStrategy](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/database/count/reltuples_count_strategy.rb?ref_type=heads) 策略时，此端点仅返回近似数据。

```plaintext
GET /application/statistics
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/application/statistics"
```

示例响应：

```json
{
   "forks": 10,
   "issues": 76,
   "merge_requests": 27,
   "notes": 954,
   "snippets": 50,
   "ssh_keys": 10,
   "milestones": 40,
   "users": 50,
   "groups": 10,
   "projects": 20,
   "active_users": 50
}
```

