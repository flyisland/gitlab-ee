---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: LDAP Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下是与 LDAP 相关的 Rake 任务。

<a id="check"></a>

## 检查

LDAP 检查 Rake 任务会测试 `bind_dn` 和 `password` 凭据（如果已配置），并列出部分 LDAP 用户样本。此任务也会作为 `gitlab:check` 任务的一部分执行，但可以使用以下命令独立运行。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:ldap:check
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:ldap:check
```

{{< /tab >}}

{{< /tabs >}}

默认情况下，该任务会返回 100 个 LDAP 用户的样本。通过向检查任务传递一个数字来更改此限制：

```shell
rake gitlab:ldap:check[50]
```

<a id="run-a-group-sync"></a>

## 运行群组同步

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下任务会立即运行[群组同步](../auth/ldap/ldap_synchronization.md#group-sync)。当您希望根据 LDAP 更新所有已配置的群组成员关系，而不必等待下一次计划中的群组同步运行时，此任务非常有用。

> [!note]
> 如果您想更改群组同步的执行频率，
> 请改为[调整 cron 计划](../auth/ldap/ldap_synchronization.md#adjust-ldap-sync-schedule)。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:ldap:group_sync
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:ldap:group_sync
```

{{< /tab >}}

{{< /tabs >}}

<a id="rename-a-provider"></a>

## 重命名提供商

如果您更改了 `gitlab.yml` 或 `gitlab.rb`中的 LDAP 服务器 ID，则需要更新所有用户身份，否则用户将无法登录。输入旧提供商和新提供商，此任务会更新数据库中所有匹配的身份。

`old_provider` 和 `new_provider` 由前缀 `ldap` 加上配置文件中的 LDAP 服务器 ID 派生而来。例如，在 `gitlab.yml` 或 `gitlab.rb`中，您可能会看到如下 LDAP 配置：

```yaml
main:
  label: 'LDAP'
  host: '_your_ldap_server'
  port: 389
  uid: 'sAMAccountName'
  # ...
```

`main` 是 LDAP 服务器 ID。二者组合后，唯一的提供商为 `ldapmain`。

> [!warning]
> 如果您输入了错误的新提供商，用户将无法登录。如果发生这种情况，
> 请再次运行该任务，将错误的提供商作为 `old_provider`，将
> 正确的提供商作为 `new_provider`。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:ldap:rename_provider[old_provider,new_provider]
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:ldap:rename_provider[old_provider,new_provider]
```

{{< /tab >}}

{{< /tabs >}}

<a id="example"></a>

### 示例

假设从默认服务器 ID `main` 开始（完整提供商为 `ldapmain`）。如果我们将 `main` 更改为 `mycompany`，则 `new_provider` 为 `ldapmycompany`。要重命名所有用户身份，请运行以下命令：

```shell
sudo gitlab-rake gitlab:ldap:rename_provider[ldapmain,ldapmycompany]
```

示例输出：

```plaintext
100 users with provider 'ldapmain' will be updated to 'ldapmycompany'.
If the new provider is incorrect, users will be unable to sign in.
Do you want to continue (yes/no)? yes

User identities were successfully updated
```

<a id="other-options"></a>

### 其他选项

如果您未指定 `old_provider` 和 `new_provider`，该任务会提示您输入它们：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:ldap:rename_provider
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:ldap:rename_provider
```

{{< /tab >}}

{{< /tabs >}}

**示例输出**：

```plaintext
What is the old provider? Ex. 'ldapmain': ldapmain
What is the new provider? Ex. 'ldapcustom': ldapmycompany
```

此任务还接受 `force` 环境变量，该变量会跳过确认对话框：

```shell
sudo gitlab-rake gitlab:ldap:rename_provider[old_provider,new_provider] force=yes
```

<a id="secrets"></a>

## 密钥

极狐GitLab 可以使用 [LDAP 配置密钥](../auth/ldap/_index.md#use-encrypted-credentials)从加密文件中读取。以下 Rake 任务用于更新加密文件的内容。

<a id="show-secret"></a>

### 显示密钥

显示当前 LDAP 密钥的内容。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:ldap:secret:show
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:ldap:secret:show
```

{{< /tab >}}

{{< /tabs >}}

**示例输出**：

```plaintext
main:
  password: '123'
  bind_dn: 'gitlab-adm'
```

<a id="edit-secret"></a>

### 编辑密钥

在您的编辑器中打开密钥内容，并在您退出时将生成的内容写入加密密钥文件。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:ldap:secret:edit EDITOR=vim
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
sudo RAILS_ENV=production EDITOR=vim -u git -H bundle exec rake gitlab:ldap:secret:edit
```

{{< /tab >}}

{{< /tabs >}}

<a id="write-raw-secret"></a>

### 写入原始密钥

通过在 STDIN 上提供新密钥内容来写入。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
echo -e "main:\n  password: '123'" | sudo gitlab-rake gitlab:ldap:secret:write
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
echo -e "main:\n  password: '123'" | sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:ldap:secret:write
```

{{< /tab >}}

{{< /tabs >}}

<a id="secrets-examples"></a>

### 密钥示例

- 编辑器示例：

  当编辑命令无法与您的编辑器配合使用时，可以使用写入任务：

  ```shell
  # Write the existing secret to a plaintext file
  sudo gitlab-rake gitlab:ldap:secret:show > ldap.yaml
  # Edit the ldap file in your editor
  ...
  # Re-encrypt the file
  cat ldap.yaml | sudo gitlab-rake gitlab:ldap:secret:write
  # Remove the plaintext file
  rm ldap.yaml
  ```

- KMS 集成示例：

  它还可以用作接收使用 KMS 加密的内容的接收应用程序：

  ```shell
  gcloud kms decrypt --key my-key --keyring my-test-kms --plaintext-file=- --ciphertext-file=my-file --location=us-west1 | sudo gitlab-rake gitlab:ldap:secret:write
  ```

- Google Cloud 密钥集成示例：

  它还可以用作接收来自 Google Cloud 的密钥的接收应用程序：

  ```shell
  gcloud secrets versions access latest --secret="my-test-secret" > $1 | sudo gitlab-rake gitlab:ldap:secret:write
  ```
