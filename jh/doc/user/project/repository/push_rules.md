---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use push rules to control the content and format of Git commits your repository accepts. Set standards for commit messages, and block secrets or credentials from being added accidentally.
title: 推送规则
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.3 中，推送规则的最大正则表达式长度已[更改](https://gitlab.com/gitlab-org/gitlab/-/issues/411901)，从 255 个字符增加到 511 个字符。

{{< /history >}}

推送规则是[`预接收` Git 钩子](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks#:~:text=pre%2Dreceive,with%20the%20push.)，你可以通过用户友好的界面启用它们。推送规则让你能够更好地控制可以推送到代码仓库的内容。虽然极狐GitLab 提供了[受保护分支](branches/protected.md)，但你可能需要更具体的规则，例如：

- 评估提交的内容。
- 确认提交信息符合预期格式。
- 强制执行[分支命名规则](branches/_index.md#name-your-branch)。
- 评估文件的详细信息。
- 阻止删除 Git 标签。
- 要求签名提交。

极狐GitLab 在推送规则中使用 [RE2 语法](https://github.com/google/re2/wiki/Syntax)作为正则表达式。你可以在 [regex101 正则表达式测试器](https://regex101.com/) 上测试它们。
每个正则表达式长度限制为 511 个字符。

有关自定义推送规则，请使用[服务器钩子](../../../administration/server_hooks.md)。

> [!note]
> 在 Fork 同步期间会绕过推送规则。
> 当你从上游项目[更新你的 Fork](forking_workflow.md#update-your-fork) 时，更改会直接应用，而不会根据 Fork 的推送规则进行验证。

推送规则作为模板工作，而不是继承设置：

- 全局推送规则作为新项目的模板。创建全局推送规则后，它们会被复制到此后创建的所有项目中。
- 项目推送规则是独立的副本。项目创建后，其推送规则不会在你更改全局或群组规则时自动更新。
- 删除项目推送规则会移除该项目的所有推送规则控制。项目不会恢复使用全局或群组规则。

要将更新后的全局推送规则应用于现有项目，你必须为每个项目单独[覆盖全局推送规则](#override-global-push-rules-per-project)。

> [!note]
> 如果从项目中删除了推送规则，那么该项目就完全没有推送规则了。
> 项目不会自动从群组或实例继承规则。
> 要恢复推送规则，你必须为项目重新配置它们。

## 启用全局推送规则
<a id="enable-global-push-rules"></a>

你可以创建作为所有新项目模板的推送规则。
你可以在单个项目或[群组](#group-push-rules)中覆盖这些规则。

当你配置全局推送规则时：

- 所有在你配置全局推送规则之后创建的项目都会继承此配置的副本。
- 现有项目不会受到影响。要手动更新这些项目，请参阅[为每个项目覆盖全局推送规则](#override-global-push-rules-per-project)。
- 对全局推送规则的更改不会更新已经配置了推送规则的项目。

先决条件：

- 你必须是管理员。

要创建全局推送规则：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **推送规则**。
1. 展开 **推送规则**。
1. 设置你想要的规则。
1. 选择 **保存推送规则**。

## 群组推送规则
<a id="group-push-rules"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

群组推送规则允许群组维护者为特定群组中新建的项目设置推送规则。

要为群组配置推送规则：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏，选择 **设置** > **代码库**。
1. 展开 **预定义推送规则** 部分。
1. 选择你想要的设置。
1. 选择 **保存推送规则**。

新项目从以下来源继承推送规则：

- 已定义了推送规则的最近父级群组。
- 如果没有父级群组定义了推送规则，则为整个实例设置的推送规则。

只有项目会继承推送规则。子群组不会从父群组继承推送规则。要验证哪些推送规则适用于新项目，请在子群组中创建一个项目并检查该项目的推送规则。

## 为每个项目覆盖全局推送规则
<a id="override-global-push-rules-per-project"></a>

项目推送规则独立于全局推送规则。
当你为项目设置推送规则时，这些规则会替换该项目先前配置的任何规则。

要为项目设置推送规则：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **设置** > **代码库**。
1. 展开 **推送规则**。
1. 设置你想要的规则。
1. 选择 **保存推送规则**。

要使项目匹配新的全局推送规则，你必须将项目的推送规则配置为与全局设置匹配。项目不会自动继承对全局推送规则的更改。

## 验证用户
<a id="verify-users"></a>

使用这些规则来验证进行提交的用户。

> [!note]
> 这些推送规则仅适用于提交，不适用于[标签](tags/_index.md)。

- **拒绝未验证用户**：提交者邮箱必须与用户[已验证的邮箱地址](../../profile/_index.md#add-emails-to-your-user-profile) 或[私有提交邮箱地址](../../profile/_index.md#use-an-automatically-generated-private-commit-email) 之一匹配。
- **拒绝不一致的用户名**：对于作者和提交者邮箱相同的提交，提交作者姓名必须与用户的极狐GitLab 账户名称匹配。当这些邮箱不同时，会跳过此检查，例如在从其他贡献者那里拣选或变基提交的工作流中会出现这种情况。

  此规则通过捕获用户 Git 设置中的错误配置来帮助维护提交卫生，但不能防止冒充。对于加密身份验证，请改用[**拒绝未签名提交**](#require-signed-commits)。
- **检查提交作者是否为极狐GitLab 用户**：提交作者和提交者的邮箱地址都必须与极狐GitLab 用户[已验证的邮箱地址](../../profile/_index.md#add-emails-to-your-user-profile) 匹配。
- **提交作者的邮箱**：作者和提交者的邮箱地址都必须与正则表达式匹配。要允许任何邮箱地址，请留空。

当使用[项目的机器人用户](../settings/project_access_tokens.md#bot-users-for-projects) 或[群组的机器人用户](../../group/settings/group_access_tokens.md#bot-users-for-groups) 时，你必须添加生成的邮箱后缀，以便机器人令牌可以进行提交和推送更改。

## 验证提交信息
<a id="validate-commit-messages"></a>

对你的提交消息使用这些规则：

- **要求提交消息匹配表达式**：消息必须与表达式匹配。要允许任何提交消息，请留空。
  使用多行模式，可以通过使用 `(?-m)` 禁用。一些验证示例：

  - `JIRA\-\d+` 要求每个提交都引用一个 Jira 议题，例如 `Refactored css. Fixes JIRA-123`。
  - `[[:^punct:]]\b$` 如果最后一个字符是标点符号，则拒绝提交。
    单词边界字符 (`\b`) 可防止误报，因为 Git 会在提交消息的末尾添加一个换行符 (`\n`)。

  在极狐GitLab UI 中创建的提交消息将 `\r\n` 设置为换行符。
  在你的正则表达式中使用 `(\r\n?|\n)` 而不是 `\n` 来正确匹配它。

  例如，给定以下多行提交描述：

  ```plaintext
  JIRA:
  描述
  ```

  你可以使用此正则表达式验证它：`JIRA:(\r\n?|\n)\w+`。

- **拒绝匹配表达式的提交消息**：提交消息不得与表达式匹配。要允许任何提交消息，请留空。
  使用多行模式，可以通过使用 `(?-m)` 禁用。

## 验证分支名称
<a id="validate-branch-names"></a>

要验证分支名称，请为 **分支名称** 输入正则表达式。
要允许任何分支名称，请留空。你的[默认分支](branches/default.md) 始终是被允许的。出于安全目的，某些格式的分支名称默认受到限制。包含 40 个十六进制字符（类似于 Git 提交哈希）的名称是被禁止的。

一些验证示例：

- 分支必须以 `JIRA-` 开头。

  ```plaintext
  ^JIRA-
  ```

- 分支必须以 `-JIRA` 结尾。

  ```plaintext
  -JIRA$
  ```

- 分支长度必须在 `4` 到 `15` 个字符之间，且只接受小写字母、数字和连字符。

  ```plaintext
  ^[a-z0-9\\-]{4,15}$
  ```

## 防止意外后果
<a id="prevent-unintended-consequences"></a>

使用这些规则以防止意外后果。

- **拒绝未签名的提交**：提交[必须被签名](signed_commits/_index.md)。此规则
  可能会阻止一些[在 Web IDE 中创建的](#reject-unsigned-commits-and-the-web-ide)合法提交，
  并允许[由极狐GitLab 创建的未签名提交出现在提交历史中](#require-signed-commits)。
- **不允许用户使用 `git push` 删除 Git 标签**：用户无法使用 `git push` 删除 Git 标签。

## 验证文件
<a id="validate-files"></a>

使用这些规则来验证提交中包含的文件。

- **防止推送密钥文件**：文件不得包含[密钥](#prevent-pushing-secrets-to-the-repository)。
- **禁止的文件名**：代码仓库中不存在的文件不得匹配正则表达式。要允许所有文件名，请留空。参见[常见示例](#prohibit-files-by-name)。
- **最大文件大小**：添加或更新的文件不得超过此文件大小（以 MB 为单位）。要允许任何大小的文件，请设置为 `0`。Git LFS 跟踪的文件不受此限制。

### 防止向仓库推送密钥
<a id="prevent-pushing-secrets-to-the-repository"></a>

切勿将密钥（例如凭证文件和 SSH 私钥）提交到版本控制系统。在极狐GitLab 中，你可以使用预定义的文件名模式列表来防止匹配的文件被推送到代码仓库。包含匹配文件的合并请求将被阻止。
此推送规则不限制已经提交到仓库的文件。
你必须使用[为每个项目覆盖全局推送规则](#override-global-push-rules-per-project)中描述的过程，更新现有项目的配置以使用该规则。

此规则阻止的文件如下所列。有关完整的标准列表，请参阅
[`files_denylist.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/gitlab/checks/files_denylist.yml)。

- AWS CLI 凭证 blobs：
  - `.aws/credentials`
  - `aws/credentials`
  - `homefolder/aws/credentials`
- 私有 RSA SSH 密钥：
  - `/ssh/id_rsa`
  - `/.ssh/personal_rsa`
  - `/config/server_rsa`
  - `id_rsa`
  - `.id_rsa`
- 私有 DSA SSH 密钥：
  - `/ssh/id_dsa`
  - `/.ssh/personal_dsa`
  - `/config/server_dsa`
  - `id_dsa`
  - `.id_dsa`
- 私有 ED25519 SSH 密钥：
  - `/ssh/id_ed25519`
  - `/.ssh/personal_ed25519`
  - `/config/server_ed25519`
  - `id_ed25519`
  - `.id_ed25519`
- 私有 ECDSA SSH 密钥：
  - `/ssh/id_ecdsa`
  - `/.ssh/personal_ecdsa`
  - `/config/server_ecdsa`
  - `id_ecdsa`
  - `.id_ecdsa`
- 私有 ECDSA_SK SSH 密钥：
  - `/ssh/id_ecdsa_sk`
  - `/.ssh/personal_ecdsa_sk`
  - `/config/server_ecdsa_sk`
  - `id_ecdsa_sk`
  - `.id_ecdsa_sk`
- 私有 ED25519_SK SSH 密钥：
  - `/ssh/id_ed25519_sk`
  - `/.ssh/personal_ed25519_sk`
  - `/config/server_ed25519_sk`
  - `id_ed25519_sk`
  - `.id_ed25519_sk`
- 任何以这些后缀结尾的文件：
  - `*.pem`
  - `*.key`
  - `*.history`
  - `*_history`

### 按名称禁止文件
<a id="prohibit-files-by-name"></a>

在 Git 中，文件名包括文件名称和名称前的所有目录。
当你执行 `git push` 时，推送中的每个文件名都会与 **禁止的文件名** 中的正则表达式进行比较。

> [!note]
> 此功能使用 [RE2 语法](https://github.com/google/re2/wiki/Syntax)，
> 该语法不支持正向前瞻或负向前瞻。

正则表达式可以：

- 匹配仓库中任何位置的文件名。
- 匹配特定位置的文件名。
- 匹配部分文件名。
- 通过扩展名排除特定文件类型。
- 组合多个表达式以排除多种模式。

### 正则表达式示例
<a id="regular-expression-examples"></a>

这些示例使用了常见的正则表达式字符串边界模式：

- `^`：匹配字符串的开头。
- `$`：匹配字符串的结尾。
- `\.`：匹配一个字面量的句点字符。反斜杠对句点进行转义。
- `\/`：匹配一个字面量的正斜杠。反斜杠对正斜杠进行转义。

#### 阻止特定文件类型
<a id="prevent-specific-file-types"></a>

- 要阻止将 `.exe` 文件推送到仓库中的任何位置：

  ```plaintext
  \.exe$
  ```

#### 阻止特定文件
<a id="prevent-specific-files"></a>

- 要阻止推送特定的配置文件：

  - 在仓库根目录中：

    ```plaintext
    ^config\.yml$
    ```

  - 在特定目录中：

    ```plaintext
    ^directory-name\/config\.yml$
    ```

- 在任何位置 - 此示例阻止推送任何名为 `install.exe` 的文件：

  ```plaintext
  (^|\/)install\.exe$
  ```

#### 组合模式
<a id="combine-patterns"></a>

你可以将多个模式组合成一个表达式。此示例组合了所有前面的表达式：

```plaintext
(\.exe|^config\.yml|^directory-name\/config\.yml|(^|\/)install\.exe)$
```

## 要求签名提交
<a id="require-signed-commits"></a>

[签名提交](signed_commits/_index.md) 是用于验证 Git 提交的真实性和完整性的数字签名。使用 **拒绝未签名提交** 推送规则来对外部贡献者强制执行签名提交，同时允许极狐GitLab 创建的提交保持未签名状态。

当你启用 **拒绝未签名提交** 推送规则时：

- 从极狐GitLab 外部推送的提交（使用 `git push`）必须包含有效的加密签名。未签名的提交将被拒绝。
- 通过极狐GitLab UI 或 API 创建的提交即使没有签名也是允许的。这些提交可以来自 Web IDE、合并请求操作和 API 操作。

> [!warning]
> 由于在极狐GitLab 中创建的提交不受此规则约束，因此即使启用了规则，未签名的提交仍可能出现在你的提交历史中。该规则仅验证从外部 Git 客户端推送的提交。
>
> 更多信息，请参见 [issue 5361](https://gitlab.com/gitlab-org/gitaly/-/issues/5361)。

签名必须使用受支持的签名方法创建：

- GPG
- SSH
- X.509

具有无效或损坏签名的提交将被拒绝。

### 启用规则
<a id="enable-the-rule"></a>

要启用 **拒绝未签名提交** 推送规则：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **设置** > **代码库**。
1. 展开 **推送规则**。
1. 选择 **拒绝未签名提交**。
1. 选择 **保存推送规则**。

### 拒绝未签名提交和 Web IDE
<a id="reject-unsigned-commits-and-the-web-ide"></a>

如果项目具有 **拒绝未签名提交** 推送规则，则默认情况下，用户无法通过极狐GitLab Web IDE 创建提交。

要在具有此推送规则的项目中允许通过 Web IDE 提交，极狐GitLab 管理员必须禁用功能标志 `reject_unsigned_commits_by_gitlab`：

```ruby
Feature.disable(:reject_unsigned_commits_by_gitlab)
```

当此功能标志被禁用时，在 Web IDE 中创建的提交无需签名即可被允许。
更多信息，请参见[启用或禁用该功能](../../../administration/feature_flags/_index.md#enable-or-disable-the-feature)。

## 拒绝未经 DCO 认证的提交
<a id="reject-commits-that-arent-dco-certified"></a>

使用[开发者原产地证书](https://developercertificate.org/)（DCO）签名的提交证明贡献者编写了或有权利提交该提交中所贡献的代码。
你可以要求所有提交到项目的代码都符合 DCO。此推送规则要求每个提交消息中都包含 `Signed-off-by:` 尾行，并拒绝任何缺少它的提交。

## 故障排除
<a id="troubleshooting"></a>

### 批量更新所有项目的推送规则
<a id="bulk-update-push-rules-for-all-projects"></a>

要将所有项目的推送规则更新为相同，请使用 [Rails 控制台](../../../administration/operations/rails_console.md#starting-a-rails-console-session)，或编写脚本使用[推送规则 API 端点](../../../api/project_push_rules.md) 更新每个项目。

例如，要启用 **检查提交作者是否为极狐GitLab 用户** 和 **不允许用户使用 `git push` 删除 Git 标签** 复选框，并创建一个只允许来自特定邮箱域的提交的过滤器，通过 Rails 控制台进行：

> [!warning]
> 更改数据的命令如果未正确运行或在合适条件下运行，可能会造成损害。务必先在测试环境中运行命令，并准备好一个备份实例用于恢复。

``` ruby
Project.find_each do |p|
  pr = p.push_rule || PushRule.new(project: p)
  # 检查提交作者是否为极狐GitLab 用户
  pr.member_check = true
  # 不允许用户使用 `git push` 删除 Git 标签
  pr.deny_delete_tag = true
  # 提交作者的邮箱
  pr.author_email_regex = '@domain\.com$'
  pr.save!
end
```

