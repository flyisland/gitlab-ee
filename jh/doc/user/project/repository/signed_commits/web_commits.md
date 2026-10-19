---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 来自极狐GitLab UI 的签名提交
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

当您使用极狐GitLab 用户界面创建提交时，该提交并非由您直接推送。而是代表您创建该提交。

为对这些提交进行签名，极狐GitLab 使用为实例配置的全局密钥。由于极狐GitLab 无法访问您的私钥，因此创建的提交无法使用与您的账号关联的密钥进行签名。

> [!note]
> 使用极狐GitLab 验证签名签署的提交也可能来自
> [代码仓库镜像](../mirror/_index.md)操作。在这两种情况下，Gitaly
> 都会使用实例配置的签名密钥对提交进行加密签名。

例如，如果用户 A 应用了用户 B 撰写的[建议](../../merge_requests/reviews/suggestions.md)，则该提交包含以下内容：

```plaintext
Author: User A <a@example.com>
Committer: GitLab <noreply@jihulab.com>

Co-authored-by: User B <b@example.com>
```

<a id="prerequisites"></a>

## 先决条件

在您可以为极狐GitLab UI 提交使用提交签名之前，必须先[配置它](../../../../administration/gitaly/configure_gitaly.md#configure-commit-signing-for-gitlab-ui-commits)。

<a id="turn-on-web-based-commit-signing-for-a-group-or-project"></a>

## 为群组或项目开启基于 Web 的提交签名

{{< details >}}

Offering: JihuLab.com

{{< /details >}}

您可以为群组中的所有项目或单个项目开启基于 Web 的提交签名。

开启基于 Web 的提交签名后，通过极狐GitLab UI（Web 编辑器、Web IDE 和合并请求）创建的所有提交都会自动使用实例配置的签名密钥进行签名。

<a id="for-a-group"></a>

### 为群组

先决条件：

- 您必须拥有该群组的所有者角色。

为群组中的所有项目开启基于 Web 的提交签名：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**通用**。
1. 选中**对基于 Web 的提交进行签名**复选框。

群组中的项目会继承此设置。

<a id="for-a-project"></a>

### 为项目

先决条件：

- 您必须拥有该项目的维护者或所有者角色。

> [!note]
> 该项目不得属于已开启基于 Web 的提交签名的群组。
> 如果群组设置已开启，则项目复选框不可用。

为项目开启基于 Web 的提交签名：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**通用**。
1. 选中**对基于 Web 的提交进行签名**复选框。

<a id="committer-field-of-the-commits"></a>

## 提交的提交者字段

在 Git 中，提交同时具有作者和提交者。对于 Web 提交，`Committer` 字段是可配置的。要更新此字段，请参阅[为极狐GitLab UI 提交配置提交签名](../../../../administration/gitaly/configure_gitaly.md#configure-commit-signing-for-gitlab-ui-commits)。

极狐GitLab 提供多项安全功能，这些功能依赖于将 `Committer` 字段设置为创建该提交的用户。例如：

- [推送规则](../push_rules.md)：（`Reject unverified users` 或 `Commit author's email`）。
- [阻止合并请求审批](../../merge_requests/approvals/settings.md#prevent-approvals-by-users-who-add-commits)。

对于由实例签名的提交，`Committer` 字段包含实例电子邮件地址，因此 `Commit author's email` 推送规则改为检查 `Author` 字段。`Reject unverified users` 推送规则会针对在极狐GitLab UI 中创建的提交检查 `Author` 字段。对于作为常规 Git 推送到达的已签名提交，例如来自[推送镜像](../mirror/push.md)的提交，极狐GitLab 会跳过该规则。

<a id="commits-created-using-rest-api"></a>

## 使用 REST API 创建的提交

[使用 REST API 创建的提交](../../../../api/commits.md#create-a-commit)也被视为基于 Web 的提交。使用 REST API 端点，您可以设置提交的 `author_name` 和 `author_email` 字段，从而可以代表其他用户创建提交。

启用提交签名后，使用 REST API 创建且 `author_name` 和 `author_email` 与发送 API 请求的用户不同的提交会被拒绝。

<a id="troubleshooting"></a>

## 故障排除

<a id="web-commits-become-unsigned-after-rebase"></a>

### 变基后 Web 提交变为未签名

当出现以下情况时，分支中先前已签名的提交会变为未签名：

- 已为从极狐GitLab UI 创建的提交配置提交签名。
- 从极狐GitLab UI 对合并请求进行变基。

这是因为先前的提交被修改，并被添加到目标分支之上。极狐GitLab 无法对这些提交进行签名。

要变通解决此问题，请在本地对分支进行变基，然后将更改推送回极狐GitLab。
