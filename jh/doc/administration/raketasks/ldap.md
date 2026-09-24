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

LDAP 检查 Rake 任务会测试 `bind_dn` 和 `password` 凭证（如果配置了），并列出部分 LDAP 用户。此任务也作为 `gitlab:check` 任务的一部分执行，但可以使用下面的命令独立运行。

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

默认情况下，任务会返回 100 个 LDAP 用户样本。可以通过向检查任务传递一个数字来修改此限制：

```shell
rake gitlab:ldap:check[50]
```

<a id="run-a-group-sync"></a>

## 运行群组同步

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下任务会立即运行[群组同步](../auth/ldap/ldap_synchronization.md#group-sync)。当你希望根据 LDAP 更新所有已配置的群组成员关系，而不想等到下一次计划群组同步时，该任务非常有用。

> [!note]
> 如果你想更改群组同步的执行频率，
> 请[调整 Cron 计划](../auth/ldap/ldap_synchronization.md#adjust-ldap-sync-schedule)。

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

## 重命名提供者

如果你在 `gitlab.yml` 或 `gitlab.rb` 中更改了 LDAP 服务器 ID，则需要更新所有用户身份标识，否则用户将无法登录。输入旧的提供者和新的提供者，此任务将更新数据库中所有匹配的身份标识。

`old_provider` 和 `new_provider` 源自前缀 `ldap` 加上配置文件中 LDAP 服务器 ID。例如，在 `gitlab.yml` 或 `gitlab.rb` 中，你可能会看到如下 LDAP 配置：

```yaml
main:
  label: 'LDAP'
  host: '_your_ldap_server'
  port: 389
  uid: 'sAMAccountName'
  # ...
```

`main` 是 LDAP 服务器 ID。合在一起，唯一的提供者为 `ldapmain`。

> [!warning]
> 如果输入了错误的新提供者，用户将无法登录。如果发生这种情况，请再次运行该任务，将错误的提供者作为 `old_provider`，正确的提供者作为 `new_provider`。

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

假设起初使用默认服务器 ID `main`（完整提供者为 `ldapmain`）。如果我们将 `main` 更改为 `mycompany`，则 `new_provider` 为 `ldapmycompany`。要重命名所有用户身份标识，请运行以下命令：

```shell
sudo gitlab-rake gitlab:ldap:rename_provider[ldapmain,ldapmycompany]
```

示例输出：

```plaintext
100 个提供者为 'ldapmain' 的用户将被更新为 'ldapmycompany'。
如果新的提供者不正确，用户将无法登录。
是否要继续（yes/no）？ yes

用户身份标识已成功更新
```

<a id="other-options"></a>

### 其他选项

如果你不指定 `old_provider` 和 `new_provider`，任务会提示你输入它们：

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
旧的提供者是什么？例如 'ldapmain'： ldapmain
新的提供者是什么？例如 'ldapcustom'： ldapmycompany
```

此任务也接受 `force` 环境变量，该变量会跳过确认对话框：

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

在你的编辑器中打开密钥内容，并在退出时将编辑后的内容写入加密的密钥文件。

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

通过 STDIN 提供新的密钥内容进行写入。

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

  当编辑命令不适用于你的编辑器时，可以使用写入任务：

  ```shell
  # 将现有密钥写入纯文本文件
  sudo gitlab-rake gitlab:ldap:secret:show > ldap.yaml
  # 在编辑器中编辑 ldap 文件
  ...
  # 重新加密文件
  cat ldap.yaml | sudo gitlab-rake gitlab:ldap:secret:write
  # 删除纯文本文件
  rm ldap.yaml
  ```