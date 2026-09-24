---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在极狐GitLab CI/CD 中运行 Composer 和 npm 脚本并通过 SCP 部署
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本指南介绍了如何使用[极狐GitLab CI/CD](../../_index.md)构建 PHP 项目的依赖项，同时通过 npm 脚本编译资源。

你可以使用自定义的 PHP 和 Node.js 版本创建自己的镜像。为简洁起见，本指南使用了一个已安装 PHP 和 Node.js 的现有 [Docker 镜像](https://hub.docker.com/r/tetraweb/php/)。

```yaml
image: tetraweb/php
```

下一步是安装 zip/unzip 软件包并使 composer 可用。将这些内容放入 `before_script` 部分：

```yaml
before_script:
  - apt-get update
  - apt-get install zip unzip
  - php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  - php composer-setup.php
  - php -r "unlink('composer-setup.php');"
```

这确保了所有要求都已准备就绪。接下来，运行 `composer install` 获取所有 PHP 依赖项，运行 `npm install` 加载 Node.js 软件包。然后执行 `npm` 脚本。将这些命令追加到 `before_script` 部分：

```yaml
before_script:
  # ...
  - php composer.phar install
  - npm install
  - npm run deploy
```

在此特定案例中，`npm deploy` 脚本是一个 Gulp 脚本，它执行以下操作：

1. 编译 CSS 和 JS
1. 创建精灵图
1. 复制各种资源（图片、字体）
1. 替换部分字符串

所有这些操作会将所有文件放入一个 `build` 文件夹中，该文件夹已准备好部署到生产服务器。

<a id="how-to-transfer-files-to-a-live-server"></a>

## 如何将文件传输到生产服务器

你有多种选择，例如 rsync、SCP 或 SFTP。现在，我们使用 SCP。

要实现此目的，你必须添加一个极狐GitLab CI/CD 变量（可在 `gitlab.example/your-project-name/variables` 访问）。将此变量命名为 `STAGING_PRIVATE_KEY`，并将其设置为服务器的 **私有** SSH 密钥。

<a id="security-tip"></a>

### 安全提示

创建一个**仅**对需要更新的文件夹具有访问权限的用户。

创建该变量后，确保在运行时将密钥添加到 Docker 容器中：

```yaml
before_script:
  # - ....
  - 'which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )'
  - mkdir -p ~/.ssh
  - eval $(ssh-agent -s)
  - '[[ -f /.dockerenv ]] && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config'
```

该脚本执行以下操作：

1. 检查 `ssh-agent` 是否可用，如果不可用则安装它。
1. 创建 `~/.ssh` 文件夹。
1. 确保脚本执行环境正在运行 bash。
1. 禁用主机检查。每次连接都在新环境中进行，因此禁用主机检查可确保极狐GitLab 不会在每次连接前要求用户验证并接受服务器的身份。

基本上，这就是你在 `before_script` 部分所需的全部内容。

<a id="how-to-deploy"></a>

## 如何部署

要将 `build` 文件夹从 Docker 镜像部署到你的服务器，请创建一个新作业：

```yaml
stage_deploy:
  artifacts:
    paths:
      - build/
  rules:
    - if: $CI_COMMIT_BRANCH == "dev"
  script:
    - ssh-add <(echo "$STAGING_PRIVATE_KEY")
    - ssh -p22 server_user@server_host "mkdir htdocs/wp-content/themes/_tmp"
    - scp -P22 -r build/* server_user@server_host:htdocs/wp-content/themes/_tmp
    - ssh -p22 server_user@server_host "mv htdocs/wp-content/themes/live htdocs/wp-content/themes/_old && mv htdocs/wp-content/themes/_tmp htdocs/wp-content/themes/live"
    - ssh -p22 server_user@server_host "rm -rf htdocs/wp-content/themes/_old"
```

以下是详细分解：

1. `rules:if: $CI_COMMIT_BRANCH == "dev"` 表示仅当有内容推送到 `dev` 分支时才运行此构建。你可以完全移除此块，让所有内容在每次推送时都运行（但这可能不是你想要的效果）。
1. `ssh-add ...` 将你在 Web UI 上添加的私钥添加到 Docker 容器中。
1. 使用 `ssh` 连接并创建一个新的 `_tmp` 文件夹。
1. 使用 `scp` 连接并将 `build` 文件夹（由 `npm` 脚本生成）上传到之前创建的 `_tmp` 文件夹。
1. 再次使用 `ssh` 连接，将 `live` 文件夹移动到 `_old` 文件夹，然后将 `_tmp` 移动到 `live`。
1. 连接到 SSH 并删除 `_old` 文件夹。

`artifacts` 部分指示极狐GitLab CI/CD 保留 `build` 目录（之后你可以根据需要下载）。

<a id="why-do-it-this-way"></a>

### 为什么这样做

如果你仅在 staging 服务器上使用，可以分两步完成：

```yaml
- ssh -p22 server_user@server_host "rm -rf htdocs/wp-content/themes/live/*"
- scp -P22 -r build/* server_user@server_host:htdocs/wp-content/themes/live
```

问题在于，会有一小段时间你的服务器上没有应用程序。

因此，对于生产环境，额外的步骤可确保在任何给定时间都有一个功能正常的应用程序在运行。

<a id="where-to-go-next"></a>

## 后续步骤

由于这是一个 WordPress 项目，因此包含真实代码片段。你可以进一步探索的一些想法：

- 为默认分支使用略微不同的脚本，使你可以从该分支部署到生产服务器，并从任何其他分支部署到 staging 服务器。
- 你可以将其推送到 WordPress 官方仓库，而不是直接上线。
- 你可以即时生成 i18n 文本域。

---

最终的 `.gitlab-ci.yml` 如下所示：

```yaml
stage_deploy:
  image: tetraweb/php
  artifacts:
    paths:
      - build/
  rules:
    - if: $CI_COMMIT_BRANCH == "dev"
  before_script:
    - apt-get update
    - apt-get install zip unzip
    - php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    - php composer-setup.php
    - php -r "unlink('composer-setup.php');"
    - php composer.phar install
    - npm install
    - npm run deploy
    - 'which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )'
    - mkdir -p ~/.ssh
    - eval $(ssh-agent -s)
    - '[[ -f /.dockerenv ]] && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config'
  script:
    - ssh-add <(echo "$STAGING_PRIVATE_KEY")
    - ssh -p22 server_user@server_host "mkdir htdocs/wp-content/themes/_tmp"
    - scp -P22 -r build/* server_user@server_host:htdocs/wp-content/themes/_tmp
    - ssh -p22 server_user@server_host "mv htdocs/wp-content/themes/live htdocs/wp-content/themes/_old && mv htdocs/wp-content/themes/_tmp htdocs/wp-content/themes/live"
    - ssh -p22 server_user@server_host "rm -rf htdocs/wp-content/themes/_old"
```