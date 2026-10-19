---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 服务台电子邮件 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下是与服务台电子邮件相关的 Rake 任务。

<a id="secrets"></a>

## 密钥

极狐GitLab 可以从加密文件中读取[服务台电子邮件](../../user/project/service_desk/configure.md#configure-service-desk-alias-email)密钥，而不是将其以明文形式存储在文件系统中。以下 Rake 任务用于更新加密文件的内容。

<a id="show-secret"></a>

### 显示密钥

显示当前服务台电子邮件密钥的内容。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:service_desk_email:secret:show
```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

使用 Kubernetes 密钥存储服务台电子邮件密码。有关更多信息，
请阅读 [Helm IMAP 密钥](https://gitlab.cn/docs/charts/installation/secrets/#imap-password-for-service-desk-emails)。

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
sudo docker exec -t <container name> gitlab:service_desk_email:secret:show
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
bundle exec rake gitlab:service_desk_email:secret:show RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="example-output"></a>

#### 输出示例

```plaintext
password: 'examplepassword'
user: 'service-desk-email@mail.example.com'
```

<a id="edit-secret"></a>

### 编辑密钥

在您的编辑器中打开密钥内容，并在您退出时将生成的内容写入加密密钥文件。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:service_desk_email:secret:edit EDITOR=vim
```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

使用 Kubernetes 密钥存储服务台电子邮件密码。有关更多信息，
请阅读 [Helm IMAP 密钥](https://gitlab.cn/docs/charts/installation/secrets/#imap-password-for-service-desk-emails)。

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
sudo docker exec -t <container name> gitlab:service_desk_email:secret:edit EDITOR=editor
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
bundle exec rake gitlab:service_desk_email:secret:edit RAILS_ENV=production EDITOR=vim
```

{{< /tab >}}

{{< /tabs >}}

<a id="write-raw-secret"></a>

### 写入原始密钥

通过 `STDIN` 提供新的密钥内容以写入。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
echo -e "password: 'examplepassword'" | sudo gitlab-rake gitlab:service_desk_email:secret:write
```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

使用 Kubernetes 密钥存储服务台电子邮件密码。有关更多信息，
请阅读 [Helm IMAP 密钥](https://gitlab.cn/docs/charts/installation/secrets/#imap-password-for-service-desk-emails)。

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
sudo docker exec -t <container name> /bin/bash
echo -e "password: 'examplepassword'" | gitlab-rake gitlab:service_desk_email:secret:write
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
echo -e "password: 'examplepassword'" | bundle exec rake gitlab:service_desk_email:secret:write RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="secrets-examples"></a>

### 密钥示例

**编辑器示例**

当编辑命令与您的编辑器不兼容时，可以使用写入任务：

```shell
# Write the existing secret to a plaintext file
sudo gitlab-rake gitlab:service_desk_email:secret:show > service_desk_email.yaml
# Edit the service_desk_email file in your editor
...
# Re-encrypt the file
cat service_desk_email.yaml | sudo gitlab-rake gitlab:service_desk_email:secret:write
# Remove the plaintext file
rm service_desk_email.yaml
```

**KMS 集成示例**

它还可以用作接收使用 KMS 加密的内容的应用程序：

```shell
gcloud kms decrypt --key my-key --keyring my-test-kms --plaintext-file=- --ciphertext-file=my-file --location=us-west1 | sudo gitlab-rake gitlab:service_desk_email:secret:write
```

**Google Cloud 密钥集成示例**

它还可以用作接收来自 Google Cloud 的密钥的应用程序：

```shell
gcloud secrets versions access latest --secret="my-test-secret" > $1 | sudo gitlab-rake gitlab:service_desk_email:secret:write
```
