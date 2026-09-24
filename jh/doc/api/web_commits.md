---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Web 提交 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 17.4。

{{< /history >}}

使用此 API 检索有关 [Web 提交](../user/project/repository/web_editor.md) 的信息。

<a id="retrieve-public-signing-key"></a>

## 检索公共签名密钥

检索极狐GitLab 用于签名 Web 提交的公钥。

```plaintext
GET /web_commits/public_key
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性          | 类型   | 描述                                          |
|--------------|--------|----------------------------------------------|
| `public_key` | string | 极狐GitLab 用于签名 Web 提交的公钥。         |

示例请求：

```shell
curl --request GET \
  --url "https://gitlab.example.com/api/v4/web_commits/public_key"
```

示例响应：

```json
[
  {
    "public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAiPWx6WM4lhHNedGfBpPJNPpZ7yKu+dnn1SJejgt4596k6YjzGGphH2TUxwKzxcKDKKezwkpfnxPkSMkuEspGRt/aZZ9wa++Oi7Qkr8prgHc4soW6NUlfDzpvZK2H5E7eQaSeP3SAwGmQKUFHCddNaP0L+hM7zhFNzjFvpaMgJw0="
  }
]
```