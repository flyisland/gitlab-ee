---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将你的分支合并到主分支
---

在[创建分支](branch.md)、完成所需更改并[在本地提交](commit.md)后，你可以[将分支推送](commit.md#send-changes-to-gitlab)及其提交推送到极狐GitLab。

在 `git push` 的响应中，极狐GitLab 会提供创建合并请求的直接链接。例如：

```plaintext
...
remote: 要为 my-new-branch 创建合并请求，请访问：
remote:   https://gitlab.example.com/my-group/my-project/merge_requests/new?merge_request%5Bsource_branch%5D=my-new-branch
```

要将你的分支合并到主分支：

1. 访问 Git 提供的链接中的页面，并[创建你的合并请求](../../user/project/merge_requests/creating_merge_requests.md)。合并请求的 **源分支** 是你的分支，**目标分支** 应是主分支。
1. 如有需要，让你的[合并请求被审核](../../user/project/merge_requests/reviews/_index.md#request-a-review)。
1. 让某人[合并你的合并请求](../../user/project/merge_requests/_index.md#merge-a-merge-request)，或自行合并该合并请求，根据你的流程而定。

<a id="related-topics"></a>

## 相关主题

- [合并请求](../../user/project/merge_requests/_index.md)
- [合并方法](../../user/project/merge_requests/methods/_index.md)
- [合并冲突](../../user/project/merge_requests/conflicts.md)