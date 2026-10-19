---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 代码仓子模块 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 来更新 [Git 子模块](https://git-scm.com/book/en/v2/Git-Tools-Submodules)。

<a id="update-a-submodule-reference"></a>

## 更新子模块引用

更新子模块的引用。用于某些工作流，特别是自动化工作流，以使使用它的其他项目保持最新。

```plaintext
PUT /projects/:id/repository/submodules/:submodule
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths) |
| `submodule` | 字符串 | 是 | 子模块的 URL 编码完整路径。例如，`lib%2Fclass%2Erb` |
| `branch` | 字符串 | 是 | 要提交到的分支名称 |
| `commit_sha` | 字符串 | 是 | 要更新子模块到的完整提交 SHA |
| `commit_message` | 字符串 | 否 | 提交信息。如果未提供信息，则设置默认值 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/submodules/lib%2Fmodules%2Fexample" \
  --data "branch=main" \
  --data "commit_sha=3ddec28ea23acc5caa5d8331a6ecb2a65fc03e88" \
  --data "commit_message=Update submodule reference"
```

示例响应：

```json
{
  "id": "ed899a2f4b50b4370feeea94676502b42383c746",
  "short_id": "ed899a2f4b5",
  "title": "Updated submodule example_submodule with oid 3ddec28ea23acc5caa5d8331a6ecb2a65fc03e88",
  "author_name": "Dmitriy Zaporozhets",
  "author_email": "dzaporozhets@sphereconsultinginc.com",
  "committer_name": "Dmitriy Zaporozhets",
  "committer_email": "dzaporozhets@sphereconsultinginc.com",
  "created_at": "2018-09-20T09:26:24.000-07:00",
  "message": "Updated submodule example_submodule with oid 3ddec28ea23acc5caa5d8331a6ecb2a65fc03e88",
  "parent_ids": [
    "ae1d9fb46aa2b07ee9836d49862ec4e2c46fbbba"
  ],
  "committed_date": "2018-09-20T09:26:24.000-07:00",
  "authored_date": "2018-09-20T09:26:24.000-07:00",
  "status": null
}
```

