---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在极狐GitLab CI/CD 中使用 SSH 密钥
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 没有在构建环境（极狐GitLab Runner 运行的地方）中管理 SSH 密钥的内置支持。

当你想执行以下操作时，可以使用 SSH 密钥：

- 检出内部子模块。
- 使用软件包管理器下载私有软件包。例如，Bundler。
- 将你的应用程序部署到自己的服务器或例如 Heroku。
- 从构建环境向远程服务器执行 SSH 命令。
- 将构建环境中的文件 Rsync 到远程服务器。

最广泛支持的方法是通过扩展 `.gitlab-ci.yml` 将 SSH 密钥注入构建环境。此方法适用于任何类型的 [执行器](https://gitlab.cn/docs/runner/executors/)，例如 Docker 或 shell。

> [!note]
> 在 CI/CD 中使用 SSH 密钥时，请安全存储私钥，并避免将个人 SSH 密钥重复用于自动化作业。
> 定期轮换密钥以降低未经授权访问的风险。

<a id="create-and-use-an-ssh-key"></a>

## 创建和使用 SSH 密钥

要在极狐GitLab CI/CD 中创建和使用 SSH 密钥：

1. [生成新的 SSH 密钥对](../../user/ssh.md#generate-an-ssh-key-pair)。
1. 将私钥添加为名为 `SSH_PRIVATE_KEY` 的 [文件类型 CI/CD 变量](#add-an-ssh-key-as-a-file-type-variable)。
1. 在作业中运行 [`ssh-agent`](https://linux.die.net/man/1/ssh-agent)，加载私钥。
1. 将公钥复制到你想要访问的服务器上（通常放在 `~/.ssh/authorized_keys` 中）。
   如果你要访问私有极狐GitLab 仓库，还需要将公钥添加为 [部署密钥](../../user/project/deploy_keys/_index.md)。

在以下示例中，`ssh-add -` 命令不会在作业日志中显示 `$SSH_PRIVATE_KEY` 的值，但如果你启用了 [调试日志](../variables/variables_troubleshooting.md#enable-debug-logging)，它可能会被暴露。你可能还需要检查 [流水线的可见性](../pipelines/settings.md#change-which-users-can-view-your-pipelines)。

<a id="add-an-ssh-key-as-a-file-type-variable"></a>

### 将 SSH 密钥添加为文件类型变量

要将 SSH 密钥添加到你的项目，请将其添加为 [文件类型 CI/CD 变量](../variables/_index.md#for-a-project)：

1. 将 **Visibility** 设置为 **可见**。

   > [!note]
   > 可见性设置必须为 **可见**，因为 SSH 密钥包含空白字符，而 **隐藏** 或 **隐藏并保密** 变量不能包含空白字符。
   > 切勿在变量上运行诸如 `cat` 或 `tee` 之类的命令，因为如果 SSH 密钥出现在作业日志中，它就不会被隐藏。

1. 在 **Key** 文本框中，输入变量名称。例如，`SSH_PRIVATE_KEY`。
1. 在 **Value** 文本框中，粘贴私钥内容。
   该值必须以换行符（`LF` 字符）结尾。
   要添加换行符，请在保存前在最后一行末尾按 <kbd>Enter</kbd> 或 <kbd>Return</kbd>。

<a id="add-an-ssh-key-as-a-regular-variable"></a>

### 将 SSH 密钥添加为常规变量

如果你不想使用文件类型 CI/CD 变量，请参阅 [示例 SSH 项目](https://jihulab.com/gitlab-examples/ssh-private-key/)。
此方法使用常规 CI/CD 变量而不是文件类型变量。通常，文件类型变量是首选，因为它们保留多行格式并降低与格式相关的错误风险。

<a id="ssh-keys-when-using-the-docker-executor"></a>

## 使用 Docker 执行器时的 SSH 密钥

当你的 CI/CD 作业在 Docker 容器中运行时，环境是隔离的。要将你的代码部署到私有服务器，你可以使用 SSH 密钥对。

1. [生成新的 SSH 密钥对](../../user/ssh.md#generate-an-ssh-key-pair)。
   不要为 SSH 密钥添加密码，否则 `before_script` 会提示输入密码。
1. 将私钥添加为名为 `SSH_PRIVATE_KEY` 的 [文件类型 CI/CD 变量](#add-an-ssh-key-as-a-file-type-variable)。
1. 修改你的 `.gitlab-ci.yml`，添加 `before_script` 操作。以下示例假设使用基于 Debian 的镜像，并且作业在有权安装软件包的容器中运行。

   ```yaml
   before_script:
     ##
     ## 如果 ssh-agent 未安装，则安装它，Docker 需要 ssh-agent。
     ## （如果你使用的是基于 RPM 的镜像，请将 apt-get 替换为 yum）
     ##
     - 'command -v ssh-agent >/dev/null || ( apt-get update -y && apt-get install openssh-client -y )'

     ##
     ## 运行 ssh-agent（在构建环境内部）
     ##
     - eval $(ssh-agent -s)

     ##
     ## 给予正确的权限，否则 ssh-add 将拒绝添加文件
     ## 将存储在 SSH_PRIVATE_KEY 文件类型 CI/CD 变量中的 SSH 密钥添加到代理存储中
     ##
     - chmod 400 "$SSH_PRIVATE_KEY"
     - ssh-add "$SSH_PRIVATE_KEY"

     ##
     ## 创建 SSH 目录并赋予正确的权限
     ##
     - mkdir -p ~/.ssh
     - chmod 700 ~/.ssh

     ##
     ## 可选，如果你使用 Git 命令，设置用户名和电子邮件。
     ##
     # - git config --global user.email "user@example.com"
     # - git config --global user.name "User name"
   ```

   可以将 [`before_script`](../yaml/_index.md#before_script) 设置为默认或按作业设置。

1. 确保验证私有服务器的 [SSH 主机密钥](#verifying-the-ssh-host-keys)。
1. 最后，将你在第一步中创建的公钥添加到你想从构建环境内部访问的服务中。如果你要访问私有极狐GitLab 仓库，必须将其添加为 [部署密钥](../../user/project/deploy_keys/_index.md)。

就是这样！你现在可以在构建环境中访问私有服务器或仓库了。

<a id="ssh-keys-when-using-the-shell-executor"></a>

## 使用 Shell 执行器时的 SSH 密钥

如果你使用的是 Shell 执行器而不是 Docker，设置 SSH 密钥会更容易。

你可以在安装了极狐GitLab Runner 的机器上生成 SSH 密钥，并将该密钥用于在该机器上运行的所有项目。

1. 首先，登录到运行作业的服务器。
1. 然后，在终端以 `gitlab-runner` 用户身份登录：

   ```shell
   sudo su - gitlab-runner
   ```

1. [生成新的 SSH 密钥对](../../user/ssh.md#generate-an-ssh-key-pair)。
   不要为 SSH 密钥添加密码，否则 `before_script` 会提示输入密码。
1. 最后，将你之前创建的公钥添加到你想从构建环境内部访问的服务中。
   如果你要访问私有极狐GitLab 仓库，必须将其添加为 [部署密钥](../../user/project/deploy_keys/_index.md)。

生成密钥后，尝试登录到远程服务器以接受指纹：

```shell
ssh example.com
```

对于访问 JihuLab.com 上的仓库，你可以使用 `git@jihulab.com`。

<a id="verifying-the-ssh-host-keys"></a>

## 验证 SSH 主机密钥

最好检查私有服务器自己的公钥，以确保你没有成为中间人攻击的目标。如果出现任何可疑情况，你会注意到，因为作业会失败（当公钥不匹配时，SSH 连接会失败）。

要找出你服务器的主机密钥，请从受信任的网络（理想情况下，从私有服务器本身）运行 `ssh-keyscan` 命令：

```shell
## 使用域名
ssh-keyscan example.com

## 或使用 IP
ssh-keyscan 10.0.2.2
```

将主机作为 [文件类型 CI/CD 变量](#add-an-ssh-key-as-a-file-type-variable) 添加到你的项目中，但：

- 使用 `SSH_KNOWN_HOSTS` 作为 **Key**。
- 使用 `ssh-keyscan` 的输出作为 **Value**。

如果你必须连接到多台服务器，则所有服务器的主机密钥必须收集在变量的 **Value** 中，每行一个密钥。

> [!note]
> 通过在 `.gitlab-ci.yml` 外部使用文件类型 CI/CD 变量，而不是直接在 `.gitlab-ci.yml` 中使用 `ssh-keyscan`，有一个好处：如果主机域名因某些原因发生变化，你不必更改 `.gitlab-ci.yml`。此外，这些值由你预定义，这意味着如果主机密钥突然更改，CI/CD 作业不会失败，因此服务器或网络有问题。
>
> 不要直接在 CI/CD 作业中运行 `ssh-keyscan`，因为这是一种容易受到中间人攻击的安全风险。

现在，已创建 `SSH_KNOWN_HOSTS` 变量，除了 [Docker 执行器部分的 `.gitlab-ci.yml` 内容](#ssh-keys-when-using-the-docker-executor) 外，你还必须添加：

```yaml
before_script:
  ##
  ## 假设你已创建 SSH_KNOWN_HOSTS 文件类型 CI/CD 变量：
  ##
  - cp "$SSH_KNOWN_HOSTS" ~/.ssh/known_hosts
  - chmod 644 ~/.ssh/known_hosts
```

<a id="troubleshooting"></a>

## 故障排除

<a id="error-error-in-libcrypto"></a>

### 错误：`... libcrypto 中的错误`

在 CI/CD 作业中加载 SSH 密钥时，你可能会遇到以下错误：

```plaintext
Error loading key "/builds/path/SSH_PRIVATE_KEY": error in libcrypto
```

当 SSH 密钥值未以换行符（`LF` 字符）结尾时，可能会出现此问题。

要解决此问题，请编辑 [文件类型 CI/CD 变量](../variables/_index.md#use-file-type-cicd-variables)，并在 SSH 密钥的 `-----END OPENSSH PRIVATE KEY-----` 行末尾按 <kbd>Enter</kbd> 或 <kbd>Return</kbd>，然后保存变量。

<a id="error-value-cannot-contain"></a>

### 错误：`... 值不能包含...`

在将 SSH 密钥另存为 CI/CD 变量时，你可能会遇到错误：

```plaintext
Unable to create masked variable because: The value cannot contain the
following characters: whitespace characters.
```

当变量 **Visibility** 设置为 **隐藏** 或 **隐藏并保密** 时，会出现此问题。
隐藏的变量必须是单行且不包含空格，但 SSH 密钥包含与隐藏不兼容的空白字符。

要解决此问题，请在 [将 SSH 密钥添加为文件类型变量](#add-an-ssh-key-as-a-file-type-variable) 时将 **Visibility** 设置为 **可见**。
文件类型变量不会在作业日志中暴露，这为密钥值提供了额外的保护层。

