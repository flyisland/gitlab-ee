---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 接收邮件 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.9 引入。

{{< /history >}}

以下是接收邮件相关的 Rake 任务。

<a id="secrets"></a>

## 密钥

极狐GitLab 可以使用从加密文件读取的[接收邮件](../incoming_email.md)密钥，而不是将它们以明文形式存储在文件系统中。以下 Rake 任务用于更新加密文件的内容。

<a id="show-secret"></a>

### 显示密钥

显示当前接收邮件密钥内容。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```shell
sudo gitlab-rake gitlab:incoming_email:secret:show
```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

使用 Kubernetes 密钥存储接收邮件密码。更多信息，请阅读 [Helm IMAP 密钥](https://gitlab.cn/docs/charts/installation/secrets/#imap-password-for-incoming-emails)。

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
sudo docker exec -t <container name> gitlab:incoming_email:secret:show
```

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

```shell
bundle exec rake gitlab:incoming_email:secret:show RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="example-output"></a>

#### 示例输出

```plaintext
password: 'examplepassword'
user: 'incoming-email@mail.example.com'
```

<a id="edit-secret"></a>

### 编辑密钥

在编辑器中打开密钥内容，并在退出时将结果内容写入加密的密钥文件。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```shell
sudo gitlab-rake gitlab:incoming_email:secret:edit EDITOR=vim
```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

使用 Kubernetes 密钥存储接收邮件密码。更多信息，请阅读 [Helm IMAP 密钥](https://gitlab.cn/docs/charts/installation/secrets/#imap-password-for-incoming-emails)。

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
sudo docker exec -t <container name> gitlab:incoming_email:secret:edit EDITOR=editor
```

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

```shell
bundle exec rake gitlab:incoming_email:secret:edit RAILS_ENV=production EDITOR=vim
```

{{< /tab >}}

{{< /tabs >}}

<a id="write-raw-secret"></a>

### 写入原始密钥

通过提供 `STDIN` 输入来写入新的密钥内容。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```shell
echo -e "password: 'examplepassword'" | sudo gitlab-rake gitlab:incoming_email:secret:write
```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

使用 Kubernetes 密钥存储接收邮件密码。更多信息，请阅读 [Helm IMAP 密钥](https://gitlab.cn/docs/charts/installation/secrets/#imap-password-for-incoming-emails)。

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
sudo docker exec -t <container name> /bin/bash
echo -e "password: 'examplepassword'" | gitlab-rake gitlab:incoming_email:secret:write
```

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

```shell
echo -e "password: 'examplepassword'" | bundle exec rake gitlab:incoming_email:secret:write RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="secrets-examples"></a>

### 密钥示例

**编辑器示例**

在编辑命令不适用于你的编辑器的情况下，可以使用写入任务：

```shell
# 将现有密钥写入明文文件
sudo gitlab-rake gitlab:incoming_email:secret:show > incoming_email.yaml
# 在编辑器中编辑 incoming_email 文件
...
# 重新加密文件
cat incoming_email.yaml | sudo gitlab-rake gitlab:incoming_email:secret:write
# 删除明文文件
rm incoming_email.yaml
```