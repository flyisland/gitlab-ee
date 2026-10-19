---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Markdown API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 将 [Markdown](../user/markdown.md) 内容渲染为 HTML。

对此 API 的所有请求都必须经过[身份验证](rest/authentication.md)。

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

<a id="render-markdown-content"></a>

## 渲染 Markdown 内容

将 Markdown 内容渲染为 HTML。

```plaintext
POST /markdown
```

| 属性 | 类型    | 是否必需      | 描述                                |
| --------- | ------- | ------------- | ------------------------------------------ |
| `text`    | string  | 是           | 要渲染的 Markdown 文本                |
| `gfm`     | boolean | 否            | 使用极狐GitLab 风格 Markdown 渲染文本。默认为 `false` |
| `project` | string  | 否            | 使用极狐GitLab 风格 Markdown 创建引用时，将 `project` 用作上下文  |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"text":"Hello world! :tada:", "gfm":true, "project":"group_example/project_example"}' \
  --url "https://gitlab.example.com/api/v4/markdown"
```

响应示例：

```json
{ "html": "<p dir=\"auto\">Hello world! <gl-emoji title=\"party popper\" data-name=\"tada\" data-unicode-version=\"6.0\">🎉</gl-emoji></p>" }
```
