---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: SMTP Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下是 SMTP 相关的 Rake 任务。

<a id="secrets"></a>

## 密钥

极狐GitLab 可以使用 SMTP 配置密钥从加密文件中读取数据。以下 Rake 任务用于更新加密文件的内容。

<a id="show-secret"></a>

### 显示密钥

显示当前 SMTP 密钥的内容。

- Linux 软件包安装方式：

  ```shell
  sudo gitlab-rake gitlab:smtp:secret:show
  ```

- 自编译安装方式：

  ```shell
  bundle exec rake gitlab:smtp:secret:show RAILS_ENV=production
  ```

**示例输出**：

```plaintext
password: '123'
user_name: 'gitlab-inst'
```

<a id="edit-secret"></a>

### 编辑密钥

在编辑器中打开密钥内容，退出时将修改后的内容写入加密密钥文件。

- Linux 软件包安装方式：

  ```shell
  sudo gitlab-rake gitlab:smtp:secret:edit EDITOR=vim
  ```

- 自编译安装方式：

  ```shell
  bundle exec rake gitlab:smtp:secret:edit RAILS_ENV=production EDITOR=vim
  ```

<a id="write-raw-secret"></a>

### 写入原始密钥

通过 `STDIN` 提供新的密钥内容并写入。

- Linux 软件包安装方式：

  ```shell
  echo -e "password: '123'" | sudo gitlab-rake gitlab:smtp:secret:write
  ```

- 自编译安装方式：

  ```shell
  echo -e "password: '123'" | bundle exec rake gitlab:smtp:secret:write RAILS_ENV=production
  ```

<a id="secrets-examples"></a>

### 密钥示例

**编辑器示例**

当编辑命令与你的编辑器不兼容时，可以使用写入任务：

```shell
# 将现有密钥写入明文文件
sudo gitlab-rake gitlab:smtp:secret:show > smtp.yaml
# 在编辑器中编辑 smtp 文件
...
# 重新加密文件
cat smtp.yaml | sudo gitlab-rake gitlab:smtp:secret:write
# 删除明文文件
rm smtp.yaml
```

**KMS 集成示例**

它还可以用作接收通过 KMS 加密的内容的应用程序：

```shell
gcloud kms decrypt --key my-key --keyring my-test-kms --plaintext-file=- --ciphertext-file=my-file --location=us-west1 | sudo gitlab-rake gitlab:smtp:secret:write
```

**Google Cloud 密钥集成示例**

它还可以用作从 Google Cloud 中获取密钥的应用程序：

```shell
gcloud secrets versions access latest --secret="my-test-secret" > $1 | sudo gitlab-rake gitlab:smtp:secret:write
```