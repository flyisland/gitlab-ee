---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 服务台邮件 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.9 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/108279)。

{{< /history >}}

以下是服务台邮件相关的 Rake 任务。

## 密钥

极狐GitLab 可以使用从加密文件中读取的[服务台邮件](../../user/project/service_desk/configure.md#configure-service-desk-alias-email)密钥，而不以明文形式存储在文件系统中。以下 Rake 任务用于更新加密文件的内容。

### 显示密钥

显示当前服务台邮件密钥的内容。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

```shell
sudo gitlab-rake gitlab:service_desk_email:secret:show
```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

使用 Kubernetes secret 存储服务台邮件密码。更多信息，请参阅 [Helm IMAP secrets](https://docs.gitlab.com/charts/installation/secrets/#imap-password-for-service-desk-emails)。

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
sudo docker exec -t <container name> gitlab:service_desk_email:secret:show
```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

```shell
bundle exec rake gitlab:service_desk_email:secret:show RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

#### 示例输出

```plaintext
password: 'examplepassword'
user: 'service-desk-email@mail.example.com'
```

### 编辑密钥

在编辑器中打开密钥内容，退出时将编辑后的内容写入加密密钥文件。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

```shell
sudo gitlab-rake gitlab:service_desk_email:secret:edit EDITOR=vim
```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

使用 Kubernetes secret 存储服务台邮件密码。更多信息，请参阅 [Helm IMAP secrets](https://docs.gitlab.com/charts/installation/secrets/#imap-password-for-service-desk-emails)。

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
sudo docker exec -t <container name> gitlab:service_desk_email:secret:edit EDITOR=editor
```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

```shell
bundle exec rake gitlab:service_desk_email:secret:edit RAILS_ENV=production EDITOR=vim
```

{{< /tab >}}

{{< /tabs >}}

### 写入原始密钥

通过 `STDIN` 提供新密钥内容进行写入。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

```shell
echo -e "password: 'examplepassword'" | sudo gitlab-rake gitlab:service_desk_email:secret:write
```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

使用 Kubernetes secret 存储服务台邮件密码。更多信息，请参阅 [Helm IMAP secrets](https://docs.gitlab.com/charts/installation/secrets/#imap-password-for-service-desk-emails)。

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
sudo docker exec -t <container name> /bin/bash
echo -e "password: 'examplepassword'" | gitlab-rake gitlab:service_desk_email:secret:write
```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

```shell
echo -e "password: 'examplepassword'" | bundle exec rake gitlab:service_desk_email:secret:write RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

### 密钥示例

**编辑器示例**

当编辑命令不适用于你的编辑器时，可以使用写入任务：

```shell
# 将现有密钥写入明文文件
sudo gitlab-rake gitlab:service_desk_email:secret:show > service_desk_email.yaml
# 在编辑器中编辑 service_desk_email 文件
...
# 重新加密文件
cat service_desk_email.yaml | sudo gitlab-rake gitlab:service_desk_email:secret:write
# 移除明文文件
rm service_desk_email.yaml
```

**KMS 集成示例**

它也可以作为接收应用程序，接收由 KMS 加密的内容：

```shell
gcloud kms decrypt --key my-key --keyring my-test-kms --plaintext-file=- --ciphertext-file=my-file --location=us-west1 | sudo gitlab-rake gitlab:service_desk_email:secret:write
```

**Google Cloud 密钥集成示例**

也可以作为接收应用程序，接收来自 Google Cloud 的密钥：

```shell
gcloud secrets versions access latest --secret="my-test-secret" > $1 | sudo gitlab-rake gitlab:service_desk_email:secret:write
```

注意：根据规则，我们删除了与 Dedicated 相关的内容，但此处没有。链接我们保留了原文中的链接，如 `https://docs.gitlab.com/charts/installation/secrets/#imap-password-for-service-desk-emails`，按照规则需要替换为 `https://gitlab.cn/docs/charts/installation/secrets/#imap-password-for-service-desk-emails`？规则说“将 https://docs.gitlab.com/charts 替换为 https://gitlab.cn/docs/charts”，所以应该替换。但原文中的链接是 `https://docs.gitlab.com/charts/installation/secrets/#imap-password-for-service-desk-emails`，需要替换为 `https://gitlab.cn/docs/charts/installation/secrets/#imap-password-for-service-desk-emails`。但规则上说“将 https://docs.gitlab.com/charts 替换为 https://gitlab.cn/docs/charts”，这里子路径一致。我们进行替换。

另外，history 部分要求取消超链接，我们只取消了 `[Introduced]` 部分的链接？规则说“涉及到合并请求和议题部分的超链接直接取消”，所以移除了 `[Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/108279)` 链接，改为纯文本“引入”。翻译后加上。

最后，文件末尾要求加一个空行。我们已添加。整体检查一下。---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 服务台邮件 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.9 引入。

{{< /history >}}

以下是服务台邮件相关的 Rake 任务。

## 密钥

极狐GitLab 可以使用从加密文件中读取的[服务台邮件](../../user/project/service_desk/configure.md#configure-service-desk-alias-email)密钥，而不以明文形式存储在文件系统中。以下 Rake 任务用于更新加密文件的内容。

### 显示密钥

显示当前服务台邮件密钥的内容。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

```shell
sudo gitlab-rake gitlab:service_desk_email:secret:show
```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

使用 Kubernetes secret 存储服务台邮件密码。更多信息，请参阅 [Helm IMAP secrets](https://gitlab.cn/docs/charts/installation/secrets/#imap-password-for-service-desk-emails)。

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
sudo docker exec -t <container name> gitlab:service_desk_email:secret:show
```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

```shell
bundle exec rake gitlab:service_desk_email:secret:show RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

#### 示例输出

```plaintext
password: 'examplepassword'
user: 'service-desk-email@mail.example.com'
```

### 编辑密钥

在编辑器中打开密钥内容，退出时将编辑后的内容写入加密密钥文件。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

```shell
sudo gitlab-rake gitlab:service_desk_email:secret:edit EDITOR=vim
```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

使用 Kubernetes secret 存储服务台邮件密码。更多信息，请参阅 [Helm IMAP secrets](https://gitlab.cn/docs/charts/installation/secrets/#imap-password-for-service-desk-emails)。

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
sudo docker exec -t <container name> gitlab:service_desk_email:secret:edit EDITOR=editor
```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

```shell
bundle exec rake gitlab:service_desk_email:secret:edit RAILS_ENV=production EDITOR=vim
```

{{< /tab >}}

{{< /tabs >}}

### 写入原始密钥

通过 `STDIN` 提供新密钥内容进行写入。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

```shell
echo -e "password: 'examplepassword'" | sudo gitlab-rake gitlab:service_desk_email:secret:write
```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

使用 Kubernetes secret 存储服务台邮件密码。更多信息，请参阅 [Helm IMAP secrets](https://gitlab.cn/docs/charts/installation/secrets/#imap-password-for-service-desk-emails)。

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
sudo docker exec -t <container name> /bin/bash
echo -e "password: 'examplepassword'" | gitlab-rake gitlab:service_desk_email:secret:write
```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

```shell
echo -e "password: 'examplepassword'" | bundle exec rake gitlab:service_desk_email:secret:write RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

### 密钥示例

**编辑器示例**

当编辑命令不适用于你的编辑器时，可以使用写入任务：

```shell
# 将现有密钥写入明文文件
sudo gitlab-rake gitlab:service_desk_email:secret:show > service_desk_email.yaml
# 在编辑器中编辑 service_desk_email 文件
...
# 重新加密文件
cat service_desk_email.yaml | sudo gitlab-rake gitlab:service_desk_email:secret:write
# 移除明文文件
rm service_desk_email.yaml
```

**KMS 集成示例**

它也可以作为接收应用程序，接收由 KMS 加密的内容：

```shell
gcloud kms decrypt --key my-key --keyring my-test-kms --plaintext-file=- --ciphertext-file=my-file --location=us-west1 | sudo gitlab-rake gitlab:service_desk_email:secret:write
```

**Google Cloud 密钥集成示例**

也可以作为接收应用程序，接收来自 Google Cloud 的密钥：

```shell
gcloud secrets versions access latest --secret="my-test-secret" > $1 | sudo gitlab-rake gitlab:service_desk_email:secret:write
```

