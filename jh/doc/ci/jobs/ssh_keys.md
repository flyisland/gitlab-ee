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

极狐GitLab 不内置支持在构建环境（即极狐GitLab Runner 运行的环境）中管理 SSH 密钥。

在以下情况下，您可以使用 SSH 密钥：

- 检出内部子模块。
- 使用软件包管理器下载私有软件包。例如 Bundler。
- 将应用部署到您自己的服务器，或者例如 Heroku。
- 从构建环境向远程服务器执行 SSH 命令。
- 从构建环境将文件通过 Rsync 传输到远程服务器。

支持最广泛的方法是通过扩展 `.gitlab-ci.yml` 将 SSH 密钥注入构建环境。此方法适用于任何类型的[执行器](https://gitlab.cn/docs/runner/executors/)，
例如 Docker 或 shell。

> [!note]
> 在 CI/CD 中使用 SSH 密钥时，请安全存储私钥，并避免将个人 SSH 密钥复用于自动化作业。
> 请定期轮换密钥，以降低未授权访问的风险。

<a id="create-and-use-an-ssh-key"></a>

## 创建并使用 SSH 密钥

要在极狐GitLab CI/CD 中创建并使用 SSH 密钥：

1. [生成新的 SSH 密钥对](../../user/ssh.md#generate-an-ssh-key-pair)。
1. 将私钥添加为名为 `SSH_PRIVATE_KEY`的[文件类型 CI/CD 变量](#add-an-ssh-key-as-a-file-type-variable)。
1. 在作业中运行 [`ssh-agent`](https://linux.die.net/man/1/ssh-agent)，它会加载
   该私钥。
1. 将公钥复制到您希望访问的服务器上（通常位于 `~/.ssh/authorized_keys`）。
   如果您要访问私有极狐GitLab 代码仓库，还需要将该公钥添加为
   [部署密钥](../../user/project/deploy_keys/_index.md)。

在以下示例中，`ssh-add -` 命令不会在作业日志中显示 `$SSH_PRIVATE_KEY`的值，但如果您启用[调试日志](../variables/variables_troubleshooting.md#enable-debug-logging)，它可能会被暴露。您可能还需要检查[流水线的可见性](../pipelines/settings.md#change-which-users-can-view-your-pipelines)。

<a id="add-an-ssh-key-as-a-file-type-variable"></a>

### 将 SSH 密钥添加为文件类型变量

要将 SSH 密钥添加到您的项目，请将该密钥添加为[文件类型 CI/CD 变量](../variables/_index.md#for-a-project)：

1. 将**可见性**设置为**可见的**。

   > [!note]
   > 可见性设置必须为**可见的**，因为 SSH 密钥包含空白字符，
   > 而**掩码**或**掩码并隐藏**变量不能包含空白字符。
   > 切勿对该变量运行 `cat` 或 `tee` 之类的命令，因为如果 SSH 密钥
   > 出现在作业日志中，它不会被掩码。

1. 在 **Key** 文本框中，输入变量的名称。例如 `SSH_PRIVATE_KEY`。
1. 在 **Value** 文本框中，粘贴私钥内容。
   该值必须以换行符（`LF` 字符）结尾。
   要添加换行符，请在保存前于最后一行的末尾按 <kbd>Enter</kbd> 或 <kbd>Return</kbd>。

<a id="add-an-ssh-key-as-a-regular-variable"></a>

### 将 SSH 密钥添加为常规变量

如果您不想使用文件类型 CI/CD 变量，请参阅[示例 SSH 项目](https://gitlab.com/gitlab-examples/ssh-private-key/)。此方法使用常规 CI/CD 变量而非文件类型变量。通常更推荐使用文件类型变量，因为它们会保留多行格式，并降低与格式相关的错误风险。

<a id="ssh-keys-when-using-the-docker-executor"></a>

## 使用 Docker 执行器时的 SSH 密钥

当您的 CI/CD 作业在 Docker 容器中运行时，环境是隔离的。要将代码部署到私有服务器，您可以使用 SSH 密钥对。

1. [生成新的 SSH 密钥对](../../user/ssh.md#generate-an-ssh-key-pair)。
   不要为 SSH 密钥添加密码短语。如果添加了，`before_script` 会提示您输入它。
1. 将私钥添加为名为 `SSH_PRIVATE_KEY`的[文件类型 CI/CD 变量](#add-an-ssh-key-as-a-file-type-variable)。
1. 使用 `before_script` 操作修改您的 `.gitlab-ci.yml`。以下示例假设使用
   基于 Debian 的镜像，并且该作业在具有安装软件包权限的容器中运行。

   ```yaml
   before_script:
     ##
     ## Install ssh-agent if not already installed, it is required by Docker.
     ## (change apt-get to yum if you use an RPM-based image)
     ##
     - 'command -v ssh-agent >/dev/null || ( apt-get update -y && apt-get install openssh-client -y )'

     ##
     ## Run ssh-agent (inside the build environment)
     ##
     - eval $(ssh-agent -s)

     ##
     ## Give the right permissions, otherwise ssh-add will refuse to add files
     ## Add the SSH key stored in SSH_PRIVATE_KEY file type CI/CD variable to the agent store
     ##
     - chmod 400 "$SSH_PRIVATE_KEY"
     - ssh-add "$SSH_PRIVATE_KEY"

     ##
     ## Create the SSH directory and give it the right permissions
     ##
     - mkdir -p ~/.ssh
     - chmod 700 ~/.ssh

     ##
     ## Optionally, if you use Git commands, set the user name and email.
     ##
     # - git config --global user.email "user@example.com"
     # - git config --global user.name "User name"
   ```

   [`before_script`](../yaml/_index.md#before_script) 可以设置为默认值
   或按作业设置。

1. 确保私有服务器的 [SSH 主机密钥已验证](#verifying-the-ssh-host-keys)。
1. 作为最后一步，将您在第一步中创建的公钥添加到您希望从构建
   环境内部访问的服务。如果您要访问私有极狐GitLab 代码仓库，必须将其添加为
   [部署密钥](../../user/project/deploy_keys/_index.md)。

就是这样！现在您可以在构建环境中访问私有服务器或代码仓库了。

<a id="ssh-keys-when-using-the-shell-executor"></a>

## 使用 Shell 执行器时的 SSH 密钥

如果您使用的是 Shell 执行器而非 Docker，则设置 SSH 密钥会更容易。

您可以从安装了极狐GitLab Runner 的机器上生成 SSH 密钥，并将该密钥用于在此机器上运行的所有项目。

1. 首先，登录到运行您作业的服务器。
1. 然后，在终端中以 `gitlab-runner` 用户身份登录：

   ```shell
   sudo su - gitlab-runner
   ```

1. [生成新的 SSH 密钥对](../../user/ssh.md#generate-an-ssh-key-pair)。
   不要为 SSH 密钥添加密码短语，否则 `before_script` 会
   提示您输入它。
1. 作为最后一步，将您之前创建的公钥添加到您希望从构建环境内部
   访问的服务。如果您要访问私有极狐GitLab 代码仓库，必须将其添加为
   [部署密钥](../../user/project/deploy_keys/_index.md)。

生成密钥后，尝试登录到远程服务器以接受指纹：

```shell
ssh example.com
```

要访问 JihuLab.com 上的代码仓库，您可以使用 `git@jihulab.com`。

<a id="verifying-the-ssh-host-keys"></a>

## 验证 SSH 主机密钥

检查私有服务器自身的公钥是一种良好的做法，可确保您没有成为中间人攻击的目标。如果发生任何可疑情况，您会注意到，因为作业会失败（当公钥不匹配时，SSH 连接会失败）。

要找出您服务器的主机密钥，请从受信任的网络（最好是私有服务器本身）运行 `ssh-keyscan` 命令：

```shell
## Use the domain name
ssh-keyscan example.com

## Or use an IP
ssh-keyscan 10.0.2.2
```

将这些主机作为[文件类型 CI/CD 变量](#add-an-ssh-key-as-a-file-type-variable)添加到您的项目，但有以下例外：

- 使用 `SSH_KNOWN_HOSTS` 作为 **Key**。
- 使用 `ssh-keyscan`的输出作为 **Value**。

如果您必须连接到多个服务器，则所有服务器主机密钥都必须收集到该变量的 **Value**中，每行一个密钥。

> [!note]
> 通过使用文件类型 CI/CD 变量，而不是直接在
> `.gitlab-ci.yml`中使用 `ssh-keyscan`，其好处是，如果主机域名
> 因某种原因发生变化，您无需更改 `.gitlab-ci.yml`。此外，这些值由您预先定义，
> 这意味着如果主机密钥突然发生变化，CI/CD 作业不会失败，
> 因此说明服务器或网络出了问题。
>
> 不要在 CI/CD 作业中直接运行 `ssh-keyscan`，因为这是一种安全风险，容易
> 受到中间人攻击。

现在 `SSH_KNOWN_HOSTS` 变量已创建，除了 [`.gitlab-ci.yml`的内容](#ssh-keys-when-using-the-docker-executor)之外，您还必须添加：

```yaml
before_script:
  ##
  ## Assuming you created the SSH_KNOWN_HOSTS file type CI/CD variable:
  ##
  - cp "$SSH_KNOWN_HOSTS" ~/.ssh/known_hosts
  - chmod 644 ~/.ssh/known_hosts
```

<a id="troubleshooting"></a>

## 故障排除

<a id="error--error-in-libcrypto"></a>

### 错误：`... error in libcrypto`

在 CI/CD 作业中加载 SSH 密钥时，您可能会遇到以下错误：

```plaintext
Error loading key "/builds/path/SSH_PRIVATE_KEY": error in libcrypto
```

当 SSH 密钥值不以换行符（`LF` 字符）结尾时，可能会出现此问题。

要解决此问题，请编辑[文件类型 CI/CD 变量](../variables/_index.md#use-file-type-cicd-variables)，并在保存该变量之前，于 SSH 密钥的 `-----END OPENSSH PRIVATE KEY-----`
行末尾按 <kbd>Enter</kbd> 或 <kbd>Return</kbd>。

<a id="error--value-cannot-contain"></a>

### 错误：`... value cannot contain...`

将 SSH 密钥保存为 CI/CD 变量时，您可能会遇到错误：

```plaintext
Unable to create masked variable because: The value cannot contain the
following characters: whitespace characters.
```

当变量的**可见性**设置为**掩码**或**掩码并隐藏**时，会出现此问题。掩码变量必须是单行且不含空格，但 SSH 密钥包含空白字符，与掩码不兼容。

要解决此问题，请在[将 SSH 密钥添加为文件类型变量](#add-an-ssh-key-as-a-file-type-variable)时，将**可见性**设置为**可见的**。文件类型变量不会在作业日志中暴露，这为密钥值提供了额外一层保护。
