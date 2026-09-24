---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目统计 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 可以检索[项目](../user/project/_index.md)的统计信息。所有端点都需要身份验证。

你必须对代码仓有读取权限。[个人访问令牌](../user/profile/personal_access_tokens.md)必须具有 `read_api` 作用域。[群组访问令牌](../user/group/settings/group_access_tokens.md)可以使用报告者角色和 `read_api` 作用域。

此 API 会检索通过 HTTP 方式克隆或拉取项目的次数。SSH 获取不包含在内。

<a id="retrieve-the-statistics-of-the-last-30-days"></a>

## 获取最近 30 天的统计信息

获取指定项目最近 30 天的克隆和拉取统计信息。

```plaintext
GET /projects/:id/statistics
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|-------------------|----------|--------------------------------------------------------------------------------|
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果请求成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
|------------------------|---------|-------------|
| `fetches` | 对象 | 项目的拉取统计信息。 |
| `fetches.days` | 数组 | 每日拉取统计信息的数组。 |
| `fetches.days[].count` | 整数 | 特定日期的拉取次数。 |
| `fetches.days[].date` | 字符串 | ISO 格式的日期（`YYYY-MM-DD`）。 |
| `fetches.total` | 整数 | 最近 30 天的拉取总次数。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/42/statistics"
```

响应示例：

```json
{
  "fetches": {
    "total": 50,
    "days": [
      {
        "count": 10,
        "date": "2018-01-10"
      },
      {
        "count": 10,
        "date": "2018-01-09"
      },
      {
        "count": 10,
        "date": "2018-01-08"
      },
      {
        "count": 10,
        "date": "2018-01-07"
      },
      {
        "count": 10,
        "date": "2018-01-06"
      }
    ]
  }
}
```