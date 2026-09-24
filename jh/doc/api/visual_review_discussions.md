---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

<!--- start_remove The following content will be removed on remove_date: '2024-05-22' -->
# 可视化评审讨论 API **(PREMIUM ALL)**

> - 引入于极狐GitLab 12.5。
> - 移动到极狐GitLab 专业版于 13.9。

WARNING:
此功能废弃于极狐GitLab 15.8，并计划于 17.0 移除。此为突破性变更。

<!--Visual Review discussions are notes on merge requests sent as
feedback from [Visual Reviews](../ci/review_apps/index.md#visual-reviews-deprecated)-->

## 创建新的合并请求主题

为单个项目合并请求创建一个新的主题。类似于创建注释，但稍后可以添加其他评论（回复）。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/visual_review_discussions
```

参数：

| 参数                        | 类型             | 是否必需 | 描述                                                    |
|---------------------------|----------------|------|-------------------------------------------------------|
| `id`                      | integer/string | yes  | ID 或 [URL 编码的项目路径](rest/index.md#namespaced-path-encoding) |
| `merge_request_iid`       | integer        | yes  | 合并请求 IID                                              |
| `body`                    | string         | yes  | 主题的内容                                                 |
| `position`                | hash           | no   | 创建差异注释时的位置                                            |
| `position[base_sha]`      | string         | yes  | 源分支中的基础提交 SHA                                         |
| `position[start_sha]`     | string         | yes  | 在目标分支中引用提交的 SHA                                       |
| `position[head_sha]`      | string         | yes  | 引用此合并请求的 HEAD 的 SHA                                   |
| `position[position_type]` | string         | yes  | 位置引用的类型：`text` 或 `image`                              |
| `position[new_path]`      | string         | no   | 更改后的文件路径                                              |
| `position[new_line]`      | integer        | no   | 更改后的行数（仅为 `text` 差异注释存储）                              |
| `position[old_path]`      | string         | no   | 更改前的文件路径                                              |
| `position[old_line]`      | integer        | no   | 更改前的行数（仅为 `text` 差异注释存储）                              |
| `position[width]`         | integer        | no   | 图片宽度（仅为 `image` 差异注释存储）                               |
| `position[height]`        | integer        | no   | 图片高度（仅为 `image` 差异注释存储）                               |
| `position[x]`             | integer        | no   | X 坐标（仅为 `image` 差异注释存储）                               |
| `position[y]`             | integer        | no   | Y 坐标（仅为 `image` 差异注释存储）                               |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/visual_review_discussions?body=comment"
```
<!--- end_remove -->
