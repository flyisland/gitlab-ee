---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Markdown API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 15.3 中引入所需认证，并带有名为 `authenticate_markdown_api` 的功能标志。默认启用。

{{< /history >}}

使用此 API 将 [Markdown](../user/markdown.md) 内容渲染为 HTML。

所有对此 API 的请求都必须经过[认证](rest/authentication.md)。

> [!flag]
> The availability of this feature is controlled by a feature flag.
> For more information, see the history.
> This feature is available for testing, but not ready for production use.

<a id="render-markdown-content"></a>

## 渲染 Markdown 内容

将 Markdown 内容渲染为 HTML。

```plaintext
POST /markdown
```

| 属性      | 类型     | 是否必需       | 描述                                                     |
| --------- | -------- | -------------- | -------------------------------------------------------- |
| `text`    | 字符串   | 是             | 要渲染的 Markdown 文本                                    |
| `gfm`     | 布尔值   | 否             | 使用极狐GitLab Flavored Markdown 渲染文本。默认为 `false` |
| `project` | 字符串   | 否             | 使用极狐GitLab Flavored Markdown 创建引用时，将 `project` 作为上下文 |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type:application/json" \
  --data '{"text":"Hello world! :tada:", "gfm":true, "project":"group_example/project_example"}' "https://gitlab.example.com/api/v4/markdown"
```

响应示例：

```json
{ "html": "<p dir=\"auto\">Hello world! <gl-emoji title=\"party popper\" data-name=\"tada\" data-unicode-version=\"6.0\">🎉</gl-emoji></p>" }
```