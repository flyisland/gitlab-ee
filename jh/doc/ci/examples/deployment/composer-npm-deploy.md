---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在极狐GitLab CI/CD 中使用 Composer 和 npm 脚本并通过 SCP 进行部署
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用[极狐GitLab CI/CD](../../_index.md) 构建 PHP 项目的依赖，同时通过 npm 脚本编译资源。

您可以创建自己的镜像，使用自定义的 PHP 和 Node.js 版本。为简洁起见，本指南使用官方 [`php`](https://hub.docker.com/_/php) Docker 镜像，并在 `before_script`中安装 Node.js。

```yaml
image: php:8.3
```

下一步是安装 zip/unzip 软件包和 Node.js，并使 Composer 可用。将这些内容放入 `before_script` 部分：

```yaml
before_script:
  - apt-get update
  - apt-get install -y git zip unzip nodejs npm
  - php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  - php composer-setup.php
  - php -r "unlink('composer-setup.php');"
```

这样可以确保所有要求都已就绪。接下来，运行 `composer install` 获取所有 PHP 依赖，运行 `npm install` 加载 Node.js 软件包。然后运行 `npm` 脚本。将这些命令追加到 `before_script` 部分：

```yaml
before_script:
  # ...
  - php composer.phar install
  - npm install
  - npm run deploy
```

在此特定情况下，`npm deploy` 脚本是一个 Gulp 脚本，它会执行以下操作：

1. 编译 CSS 和 JS
1. 创建精灵图
1. 复制各种资源（图片、字体）
1. 替换一些字符串

所有这些操作会将所有文件放入一个 `build` 文件夹，该文件夹已准备好部署到线上服务器。

<a id="how-to-transfer-files-to-a-live-server"></a>

## 如何将文件传输到线上服务器

您有多种选择，例如 rsync、SCP 或 SFTP。目前，请使用 SCP。

要实现这一点，您必须添加一个极狐GitLab CI/CD 变量（可在 `gitlab.example/your-project-name/variables` 上访问）。将此变量命名为 `STAGING_PRIVATE_KEY`，并将其设置为服务器的私有 SSH 密钥。

<a id="security-tip"></a>

### 安全提示

创建一个仅能访问需要更新的文件夹的用户。

创建该变量后，请确保在运行时将该密钥添加到 Docker 容器中：

```yaml
before_script:
  # - ....
  - 'which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )'
  - mkdir -p ~/.ssh
  - eval $(ssh-agent -s)
  - '[[ -f /.dockerenv ]] && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config'
```

此脚本执行以下操作：

1. 检查 `ssh-agent` 是否可用，如果不可用则安装它。
1. 创建 `~/.ssh` 文件夹。
1. 确保脚本执行环境运行的是 bash。
1. 禁用主机检查。每次连接都发生在新环境中，因此禁用主机检查可确保极狐GitLab 不会在每次连接前要求用户验证并接受服务器身份。

这基本上就是您在 `before_script` 部分所需的全部内容。

<a id="how-to-deploy"></a>

## 如何部署

要将 `build` 文件夹从 Docker 镜像部署到您的服务器，请创建一个新作业：

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

以下是详细说明：

1. `rules:if: $CI_COMMIT_BRANCH == "dev"` 表示此构建仅在向 `dev` 分支推送内容时运行。您可以完全移除此块，让所有内容在每次推送时都运行（但您可能并不希望这样）。
1. `ssh-add ...` 将您在 Web UI 上添加的私有密钥添加到 Docker 容器中。
1. 使用 `ssh` 连接并创建一个新的 `_tmp` 文件夹。
1. 使用 `scp` 连接，并将 `build` 文件夹（由 `npm` 脚本生成）上传到之前创建的 `_tmp` 文件夹。
1. 再次使用 `ssh` 连接，将 `live` 文件夹移动到 `_old` 文件夹，然后将 `_tmp` 移动到 `live`。
1. 连接到 SSH 并删除 `_old` 文件夹。

`artifacts` 部分指示极狐GitLab CI/CD 保留 `build` 目录（之后，您可以根据需要下载它）。

<a id="why-do-it-this-way"></a>

### 为什么要这样做

如果您仅将其用于预发布服务器，可以分两步完成：

```yaml
- ssh -p22 server_user@server_host "rm -rf htdocs/wp-content/themes/live/*"
- scp -P22 -r build/* server_user@server_host:htdocs/wp-content/themes/live
```

问题在于，会有一小段时间您的服务器上没有该应用。

因此，对于生产环境，这些额外的步骤可确保在任何时刻都有一个可正常工作的应用。

<a id="where-to-go-next"></a>

## 后续步骤

由于这是一个 WordPress 项目，它包含真实的代码片段。您可以进一步探索的一些想法：

- 为默认分支使用略有不同的脚本，可以让您从该分支部署到生产服务器，并从任何其他分支部署到预发布服务器。
- 您可以将其推送到 WordPress 官方代码仓库，而不是推送到线上。
- 您可以动态生成 i18n 文本域。

---

最终的 `.gitlab-ci.yml` 如下所示：

```yaml
stage_deploy:
  image: php:8.3
  artifacts:
    paths:
      - build/
  rules:
    - if: $CI_COMMIT_BRANCH == "dev"
  before_script:
    - apt-get update
    - apt-get install -y git zip unzip nodejs npm
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
