---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将您的分支合并到主分支
---

在[创建分支](branch.md)、完成所需更改并[在本地提交](commit.md)后，您需要[推送分支](commit.md#send-changes-to-gitlab)及其提交到极狐GitLab。

在 `git push`的响应中，极狐GitLab 会提供一个直接创建合并请求的链接。例如：

```plaintext
...
remote: To create a merge request for my-new-branch, visit:
remote:   https://gitlab.example.com/my-group/my-project/merge_requests/new?merge_request%5Bsource_branch%5D=my-new-branch
```

要将您的分支合并到主分支：

1. 前往 Git 提供的链接所指向的页面，
   [创建您的合并请求](../../user/project/merge_requests/creating_merge_requests.md)。该合并请求的
   **源分支**是您的分支，**目标分支**应为主分支。
1. 如有必要，请让他人[评审您的合并请求](../../user/project/merge_requests/reviews/_index.md#request-a-review)。
1. 请他人[合并您的合并请求](../../user/project/merge_requests/_index.md#merge-a-merge-request)，或根据您的流程
   自行合并该合并请求。
