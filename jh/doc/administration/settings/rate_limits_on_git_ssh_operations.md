---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure rate limits on Git SSH operations on 极狐GitLab Self-Managed.
title: Git SSH 操作的速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 对使用 SSH 的 Git 操作按用户帐户和项目应用速率限制。当用户超过速率限制时，极狐GitLab 会拒绝该用户对该项目的后续连接请求。

速率限制适用于 Git 命令（[plumbing](https://git-scm.com/book/en/v2/Git-Internals-Plumbing-and-Porcelain)）级别。每个命令的速率限制为每分钟 600 次。例如：

- `git push` 的速率限制为每分钟 600 次。
- `git pull` 有自己的速率限制，为每分钟 600 次。

`git-upload-pack`、`git pull` 和 `git clone` 命令共享一个速率限制，因为它们共享命令。

<a id="configure-gitlab-shell-operation-limit"></a>

## 配置极狐GitLab Shell 操作限制

{{< history >}}

- 引入于极狐GitLab 16.2。

{{< /history >}}

前提条件：

- 管理员访问权限。

`使用 SSH 的 Git 操作` 默认启用。默认为每个用户每分钟 600 次。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **Git SSH 操作速率限制**。
1. 输入 **每分钟最大 Git 操作数** 的值。
   - 要禁用速率限制，请将其设置为 `0`。
1. 选择 **保存更改**。

