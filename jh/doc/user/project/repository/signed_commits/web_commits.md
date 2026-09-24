---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 来自极狐GitLab UI 的签名提交
---

<a id="signed-commits-from-the-gitlab-ui"></a>

## 来自极狐GitLab UI 的签名提交

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在 GitLab 16.3 中，为已签名的极狐GitLab UI 提交显示 **Verified** 徽章的功能已引入，搭配一个名为 `gitaly_gpg_signing` 的功能标志。默认为禁用。
- 在 GitLab 16.3 中，使用 `rotated_signing_keys` 选项中指定的多个密钥验证签名已引入。
- 在 GitLab 17.0 中，`gitaly_gpg_signing` 功能标志在私有化部署上默认启用。

{{< /history >}}

> [!flag]
> 此功能的可用性由一个功能标志控制。
> 更多信息，请查看历史记录。
> 此功能可用于测试，但尚未准备好用于生产环境。

当您通过极狐GitLab 用户界面创建提交时，该提交并非由您直接推送。
相反，该提交是代表您创建的。

为了对这些提交签名，极狐GitLab 使用为实例配置的全局密钥。
由于极狐GitLab 无法访问您的私钥，因此无法使用与您账户关联的密钥对创建的提交进行签名。

例如，如果用户 A 应用了由用户 B 编写的[建议](../../merge_requests/reviews/suggestions.md)，
则提交内容如下：

```plaintext
作者：User A <a@example.com>
提交者：GitLab <noreply@jihulab.com>

合作者：User B <b@example.com>
```

<a id="prerequisites"></a>

## 先决条件

在使用提交签名为极狐GitLab UI 提交之前，您必须[配置它](../../../../administration/gitaly/configure_gitaly.md#configure-commit-signing-for-gitlab-ui-commits)。

<a id="turn-on-web-based-commit-signing-for-a-group-or-project"></a>

## 为群组或项目开启基于 Web 的提交签名

{{< details >}}

Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- 在 GitLab 18.3 中引入，搭配一个名为 `configure_web_based_commit_signing` 的功能标志。默认为禁用。
- 在 GitLab 18.9 中在 JihuLab.com 上启用。
- 在 GitLab 18.10 中 GA。功能标志 `configure_web_based_commit_signing` 已移除。

{{< /history >}}

您可以为群组中的所有项目或单个项目开启基于 Web 的提交签名。

当开启基于 Web 的提交签名后，通过极狐GitLab UI（Web 编辑器、Web IDE 和合并请求）进行的所有提交都会使用实例配置的签名密钥自动签名。

<a id="for-a-group"></a>

### 对于群组

先决条件：

- 您必须拥有该群组的所有者角色。

要为群组中的所有项目开启基于 Web 的提交签名：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **通用**。
1. 选中 **签署基于 Web 的提交** 复选框。

群组中的项目继承此设置。

<a id="for-a-project"></a>

### 对于项目

先决条件：

- 您必须拥有该项目的维护者或所有者角色。

> [!note]
> 项目不得属于已开启基于 Web 的提交签名的群组。
> 如果群组设置已开启，项目复选框将不可用。

要为项目开启基于 Web 的提交签名：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **通用**。
1. 选中 **签署基于 Web 的提交** 复选框。

<a id="committer-field-of-the-commits"></a>

## 提交的提交者字段

在 Git 中，提交既有作者也有提交者。
对于 Web 提交，`Committer` 字段是可配置的。要更新此字段，请参阅
[为极狐GitLab UI 提交配置提交签名](../../../../administration/gitaly/configure_gitaly.md#configure-commit-signing-for-gitlab-ui-commits)。

极狐GitLab 提供了多项依赖于 `Committer` 字段设置为创建提交的用户的安全功能。
例如：

- [推送规则](../push_rules.md)：(`拒绝未验证的用户` 或 `提交作者的电子邮件`)。
- [合并请求审批阻止](../../merge_requests/approvals/settings.md#prevent-approvals-by-users-who-add-commits)。

当实例对提交签名时，极狐GitLab 会依赖 `Author` 字段来实现这些功能。

<a id="commits-created-using-rest-api"></a>

## 使用 REST API 创建的提交

[使用 REST API 创建的提交](../../../../api/commits.md#create-a-commit) 也被视为基于 Web 的提交。
通过 REST API 端点，您可以设置提交的 `author_name` 和 `author_email` 字段，
这样就可以代表其他用户创建提交。

当启用提交签名时，如果使用 REST API 创建的提交的 `author_name` 和 `author_email` 与发送 API 请求的用户不同，则会被拒绝。

<a id="troubleshooting"></a>

## 故障排除

<a id="web-commits-become-unsigned-after-rebase"></a>

### 变基后 Web 提交变成未签名

分支中以前签名的提交在以下情况下会变成未签名：

- 为从极狐GitLab UI 创建的提交配置了提交签名。
- 从极狐GitLab UI 对合并请求进行变基。

发生这种情况是因为之前的提交被修改，并添加到目标分支之上。极狐GitLab 无法对这些提交进行签名。

要解决此问题，请在本地对分支进行变基，然后将更改推送回极狐GitLab。

