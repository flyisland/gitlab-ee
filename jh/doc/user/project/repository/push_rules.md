---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用推送规则控制代码仓库接受的 Git 提交的内容和格式。为提交消息设定标准，并阻止密钥或凭据被意外添加。
title: 推送规则
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

推送规则是您可以通过用户友好界面启用的 [`pre-receive` Git 钩子](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks#:~:text=pre%2Dreceive,with%20the%20push.)。推送规则让您能更好地控制哪些内容可以推送到代码仓库，哪些内容不能推送。虽然极狐GitLab 提供了[受保护分支](branches/protected.md)，但您可能需要更具体的规则，例如：

- 评估提交的内容。
- 确认提交消息符合预期格式。
- 强制执行[分支名称规则](branches/_index.md#name-your-branch)。
- 评估文件的详细信息。
- 阻止删除 Git 标签。
- 要求签名提交。

极狐GitLab 在推送规则中使用 [RE2 语法](https://github.com/google/re2/wiki/Syntax)编写正则表达式。您可以在 [regex101 正则表达式测试器](https://regex101.com/)上测试它们。每个正则表达式限制为 511 个字符。

对于自定义推送规则，请使用[服务器钩子](../../../administration/server_hooks.md)。

> [!note]
> 推送规则在 Fork 同步期间会被绕过。
> 当您从上游项目[更新您的 Fork](forking_workflow.md#update-your-fork) 时，更改会直接应用，而不会根据 Fork 的推送规则进行验证。

推送规则作为模板工作，而不是继承的设置：

- 全局推送规则作为新项目的模板。当您创建全局推送规则时，它们会被复制到此后创建的所有项目中。
- 项目推送规则是独立的副本。项目创建后，其推送规则不会在您更改全局或群组规则时自动更新。
- 删除项目推送规则会移除项目中的所有推送规则控制。项目不会恢复为使用全局或群组规则。

要将更新后的全局推送规则应用到现有项目，您必须为每个项目单独[覆盖全局推送规则](#override-global-push-rules-per-project)。

> [!note]
> 如果您从项目中删除推送规则，该项目将完全没有推送规则。
> 该项目不会自动从群组或实例继承规则。
> 要恢复推送规则，您必须为该项目重新配置它们。

<a id="enable-global-push-rules"></a>

## 启用全局推送规则

您可以创建作为所有新项目模板的推送规则。您可以在单个项目或[群组](#group-push-rules)中覆盖这些规则。

当您配置全局推送规则时：

- 在您配置全局推送规则之后创建的所有项目都会继承此配置的副本。
- 现有项目不受影响。要手动更新这些项目，请参阅[按项目覆盖全局推送规则](#override-global-push-rules-per-project)。
- 对全局推送规则的更改不会更新已配置推送规则的项目。

先决条件：

- 您必须是管理员。

要创建全局推送规则：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**推送规则**。
1. 展开**推送规则**。
1. 设置您想要的规则。
1. 选择**保存推送规则**。

<a id="group-push-rules"></a>

## 群组推送规则

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

群组推送规则允许群组维护者为特定群组中新建的项目设置推送规则。

要为群组配置推送规则：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**预定义推送规则**部分。
1. 选择您想要的设置。
1. 选择**保存推送规则**。

新项目从以下位置继承推送规则：

- 定义了推送规则的最近父群组。
- 如果没有父群组定义推送规则，则为整个实例设置的推送规则。

只有项目会继承推送规则。子群组不会从父群组继承推送规则。要验证哪些推送规则适用于新项目，请在子群组中创建一个项目并检查该项目的推送规则。

<a id="override-global-push-rules-per-project"></a>

## 按项目覆盖全局推送规则

项目推送规则独立于全局推送规则。当您为项目设置推送规则时，这些规则会替换该项目之前配置的任何规则。

要为项目设置推送规则：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**推送规则**。
1. 设置您想要的规则。
1. 选择**保存推送规则**。

要使项目匹配新的全局推送规则，您必须将项目的推送规则配置为与全局设置一致。项目不会自动继承对全局推送规则的更改。

<a id="verify-users"></a>

## 验证用户

使用这些规则来验证进行提交的用户。

> [!note]
> 这些推送规则仅适用于提交，不适用于[标签](tags/_index.md)。

- **拒绝未验证用户**：提交者邮箱必须与用户的[已验证邮箱地址](../../profile/_index.md#add-emails-to-your-user-profile)或[私有提交邮箱地址](../../profile/_index.md#use-an-automatically-generated-private-commit-email)之一匹配。
- **拒绝不一致的用户名**：对于作者和提交者邮箱相同的提交，提交作者名称必须与用户的极狐GitLab 账号名称匹配。当这些邮箱不同时，会跳过此检查，这发生在从其他贡献者那里拣选或变基提交等工作流中。

  此规则通过捕获用户 Git 设置中的错误配置来帮助维护提交卫生，但不能防止冒充。要进行加密身份验证，请改用[**拒绝未签名提交**](#require-signed-commits)。
- **检查提交作者是否为极狐GitLab 用户**：提交作者和提交者的邮箱地址都必须与极狐GitLab 用户的[已验证邮箱地址](../../profile/_index.md#add-emails-to-your-user-profile)匹配。
- **提交作者邮箱**：作者和提交者的邮箱地址都必须与正则表达式匹配。要允许任何邮箱地址，请留空。

当使用[项目机器人用户](../settings/project_access_tokens.md#bot-users-for-projects)或[群组机器人用户](../../group/settings/group_access_tokens.md#bot-users-for-groups)时，您必须添加生成的邮箱后缀，以便机器人令牌可以提交和推送更改。

<a id="commits-signed-by-gitlab"></a>

### 由极狐GitLab 签名的提交

[由极狐GitLab 签名](signed_commits/web_commits.md)的提交使用实例邮箱地址作为提交者，例如 `noreply@example.com`。此地址不属于极狐GitLab 用户。无论这些提交如何到达项目，以下规则都不会检查这些提交的提交者邮箱地址：

- **拒绝未验证用户**
- **检查提交作者是否为极狐GitLab 用户**
- **提交作者邮箱**

极狐GitLab 改为检查作者邮箱地址。例外是**拒绝未验证用户**，极狐GitLab 会跳过通过 Git 推送到达的提交，例如[代码仓库镜像](mirror/_index.md)。

<a id="validate-commit-messages"></a>

## 验证提交消息

对您的提交消息使用这些规则：

- **在提交消息中要求表达式**：消息必须与表达式匹配。要允许任何提交消息，请留空。使用多行模式，可以通过使用 `(?-m)` 禁用。一些验证示例：

  - `JIRA\-\d+` 要求每个提交都引用一个 Jira 议题，例如 `Refactored css. Fixes JIRA-123`。
  - `[[:^punct:]]\b$` 会在最后一个字符是标点符号时拒绝提交。单词边界字符（`\b`）可以防止漏报（假阴性），因为 Git 会在提交消息末尾添加换行符（`\n`）。

  在极狐GitLab UI 中创建的提交消息将 `\r\n` 设置为换行符。在您的正则表达式中使用 `(\r\n?|\n)` 而不是 `\n` 来正确匹配它。

  例如，给定以下多行提交描述：

  ```plaintext
  JIRA:
  Description
  ```

  您可以使用此正则表达式验证它：`JIRA:(\r\n?|\n)\w+`。

- **在提交消息中拒绝表达式**：提交消息不得与表达式匹配。要允许任何提交消息，请留空。使用多行模式，可以通过使用 `(?-m)` 禁用。

<a id="validate-branch-names"></a>

## 验证分支名称

要验证您的分支名称，请为**分支名称**输入正则表达式。要允许任何分支名称，请留空。您的[默认分支](branches/default.md)始终被允许。出于安全目的，某些格式的分支名称默认受到限制。具有 40 个十六进制字符（类似于 Git 提交哈希）的名称被禁止。

一些验证示例：

- 分支必须以 `JIRA-` 开头。

  ```plaintext
  ^JIRA-
  ```

- 分支必须以 `-JIRA` 结尾。

  ```plaintext
  -JIRA$
  ```

- 分支长度必须在 `4` 到 `15` 个字符之间，只接受小写字母、数字和破折号。

  ```plaintext
  ^[a-z0-9\\-]{4,15}$
  ```

<a id="prevent-unintended-consequences"></a>

## 防止意外后果

使用这些规则来防止意外后果。

- **拒绝未签名提交**：提交[必须签名](signed_commits/_index.md)。此规则可以阻止一些[在 Web IDE 中创建](#reject-unsigned-commits-and-the-web-ide)的合法提交，并允许[由极狐GitLab 创建的未签名提交出现在提交历史中](#require-signed-commits)。
- **不允许用户使用 `git push` 删除 Git 标签**：用户不能使用 `git push` 删除 Git 标签。

<a id="validate-files"></a>

## 验证文件

使用这些规则来验证提交中包含的文件。

- **阻止推送密钥文件**：文件不得包含[密钥](#prevent-pushing-secrets-to-the-repository)。
- **禁止的文件名**：代码仓库中不存在的文件不得与正则表达式匹配。要允许所有文件名，请留空。请参阅[常见示例](#prohibit-files-by-name)。
- **最大文件大小**：添加或更新的文件不得超过此文件大小（以 MB 为单位）。要允许任意大小的文件，请设置为 `0`。由 Git LFS 跟踪的文件不受此限制。

<a id="prevent-pushing-secrets-to-the-repository"></a>

### 阻止将密钥推送到代码仓库

切勿将密钥（例如凭据文件和 SSH 私钥）提交到版本控制系统。在极狐GitLab 中，您可以使用预定义的文件名模式列表来阻止匹配的文件被推送到代码仓库。包含匹配文件的合并请求会被阻止。此推送规则不限制已提交到代码仓库的文件。您必须使用[按项目覆盖全局推送规则](#override-global-push-rules-per-project)中描述的过程来更新现有项目的配置以使用该规则。

此规则阻止的文件如下所列。有关完整标准列表，请参阅 [`files_denylist.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/gitlab/checks/files_denylist.yml)。

- AWS CLI 凭据 blob：
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

<a id="prohibit-files-by-name"></a>

### 按名称禁止文件

在 Git 中，文件名包括文件的名称以及名称前面的所有目录。当您 `git push` 时，推送中的每个文件名都会与**禁止的文件名**中的正则表达式进行比较。

> [!note]
> 此功能使用 [RE2 语法](https://github.com/google/re2/wiki/Syntax)，不支持正向或负向前瞻。

正则表达式可以：

- 匹配代码仓库中任何位置的文件名。
- 匹配特定位置的文件名。
- 匹配部分文件名。
- 按扩展名排除特定文件类型。
- 组合多个表达式以排除多种模式。

<a id="regular-expression-examples"></a>

### 正则表达式示例

这些示例使用常见的正则表达式字符串边界模式：

- `^`：匹配字符串的开头。
- `$`：匹配字符串的结尾。
- `\.`：匹配字面句点字符。反斜杠对句点进行转义。
- `\/`：匹配字面正斜杠。反斜杠对正斜杠进行转义。

<a id="prevent-specific-file-types"></a>

#### 阻止特定文件类型

- 要阻止将 `.exe` 文件推送到代码仓库中的任何位置：

  ```plaintext
  \.exe$
  ```

<a id="prevent-specific-files"></a>

#### 阻止特定文件

- 要阻止推送特定配置文件：

  - 在代码仓库根目录中：

    ```plaintext
    ^config\.yml$
    ```

  - 在特定目录中：

    ```plaintext
    ^directory-name\/config\.yml$
    ```

- 在任何位置，此示例阻止推送任何名为 `install.exe`的文件：

  ```plaintext
  (^|\/)install\.exe$
  ```

<a id="combine-patterns"></a>

#### 组合模式

您可以将多个模式组合成一个表达式。此示例组合了之前的所有表达式：

```plaintext
(\.exe|^config\.yml|^directory-name\/config\.yml|(^|\/)install\.exe)$
```

<a id="require-signed-commits"></a>

## 要求签名提交

[签名提交](signed_commits/_index.md)是用于验证 Git 提交真实性和完整性的数字签名。使用**拒绝未签名提交**推送规则来强制外部贡献者进行签名提交，同时允许极狐GitLab 创建的提交保持未签名状态。

当您启用**拒绝未签名提交**推送规则时：

- 从极狐GitLab 外部推送的提交（使用 `git push`）必须包含有效的加密签名。未签名提交会被拒绝。
- 通过极狐GitLab UI 或 API 创建的提交即使没有签名也被允许。这些提交可以来自 Web IDE、合并请求操作和 API 操作。

> [!warning]
> 由于在极狐GitLab 中创建的提交不受此规则约束，因此即使启用了该规则，未签名提交仍可能出现在您的提交历史中。该规则仅验证从外部 Git 客户端推送的提交。
>
> 有关更多信息，请参阅 [议题 5361](https://gitlab.com/gitlab-org/gitaly/-/issues/5361)。

签名必须使用受支持的签名方法创建：

- GPG
- SSH
- X.509

签名无效或损坏的提交会被拒绝。

<a id="enable-the-rule"></a>

### 启用规则

要启用**拒绝未签名提交**推送规则：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**推送规则**。
1. 选择**拒绝未签名提交**。
1. 选择**保存推送规则**。

<a id="reject-unsigned-commits-and-the-web-ide"></a>

### 拒绝未签名提交与 Web IDE

如果项目启用了**拒绝未签名提交**推送规则，用户默认无法通过极狐GitLab Web IDE 创建提交。

要在启用了此推送规则的项目中允许通过 Web IDE 提交，极狐GitLab 管理员必须禁用功能标志 `reject_unsigned_commits_by_gitlab`：

```ruby
Feature.disable(:reject_unsigned_commits_by_gitlab)
```

禁用此功能标志后，在 Web IDE 中创建的提交无需签名即可被允许。有关更多信息，请参阅[启用或禁用功能](../../../administration/feature_flags/_index.md#enable-or-disable-the-feature)。

<a id="reject-commits-that-arent-dco-certified"></a>

## 拒绝未经 DCO 认证的提交

使用[开发者原产地证书](https://developercertificate.org/)（DCO）签名的提交证明贡献者编写了或有权利提交该提交中所贡献的代码。您可以要求项目的所有提交都符合 DCO。此推送规则要求每个提交消息中都包含 `Signed-off-by:` 尾注，并拒绝任何缺少该尾注的提交。

<a id="troubleshooting"></a>

## 故障排除

<a id="bulk-update-push-rules-for-all-projects"></a>

### 批量更新所有项目的推送规则

要将所有项目的推送规则更新为相同，请使用 [Rails 控制台](../../../administration/operations/rails_console.md#starting-a-rails-console-session)，或编写脚本使用[推送规则 API 端点](../../../api/project_push_rules.md)更新每个项目。

例如，要启用**检查提交作者是否为极狐GitLab 用户**和**不允许用户使用 `git push` 删除 Git 标签**复选框，并通过 Rails 控制台创建仅允许来自特定邮箱域的提交的过滤器：

> [!warning]
> 更改数据的命令如果未正确运行或在正确条件下运行，可能会造成损害。请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

``` ruby
Project.find_each do |p|
  pr = p.push_rule || PushRule.new(project: p)
  # Check whether the commit author is a GitLab user
  pr.member_check = true
  # Do not allow users to remove Git tags with `git push`
  pr.deny_delete_tag = true
  # Commit author's email
  pr.author_email_regex = '@domain\.com$'
  pr.save!
end
```
