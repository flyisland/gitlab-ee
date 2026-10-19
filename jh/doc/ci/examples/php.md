---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 测试 PHP 项目
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用这些基本说明，通过极狐GitLab CI/CD 构建 PHP 项目。

本文涵盖两种测试场景：使用 Docker 执行器和使用 Shell 执行器。

<a id="test-php-projects-using-the-docker-executor"></a>

## 使用 Docker 执行器测试 PHP 项目

虽然可以在任何系统上测试 PHP 应用，但这需要开发者进行手动配置。您可以使用 Docker Hub 上提供的官方 [PHP Docker 镜像](https://hub.docker.com/_/php) 来克服这一点。

这使您可以针对不同版本的 PHP 测试 PHP 项目。但是，您仍然需要手动配置一些内容。

与每个作业一样，您需要创建一个有效的 `.gitlab-ci.yml` 来描述构建环境。

首先，指定用于作业进程的 PHP 镜像。有关镜像的更多信息，请参阅 [使用 Docker 镜像](../docker/using_docker_images.md#what-is-an-image)。

首先将镜像添加到您的 `.gitlab-ci.yml` 中：

```yaml
image: php:5.6
```

官方镜像很好，但缺少一些测试工具。您需要先准备构建环境。为此，请创建一个脚本，在实际测试开始前安装所有先决条件。

在代码仓库的根目录中创建一个 `ci/docker_install.sh` 文件，内容如下：

```shell
#!/bin/bash

# You need to install dependencies only for Docker
[[ ! -e /.dockerenv ]] && exit 0

set -xe

# Install git (the php image doesn't have it) which is required by composer
apt-get update -yqq
apt-get install git -yqq

# Install phpunit, the tool that you will use for testing
curl --location --output /usr/local/bin/phpunit "https://phar.phpunit.de/phpunit.phar"
chmod +x /usr/local/bin/phpunit

# Install mysql driver
# Here you can install any other extension that you need
docker-php-ext-install pdo_mysql
```

您可能想知道 `docker-php-ext-install` 是什么。简而言之，它是官方 PHP Docker 镜像提供的一个脚本，您可以使用它来安装扩展。有关更多信息，请阅读 [相关文档](https://hub.docker.com/_/php)。

现在您已经创建了包含构建环境先决条件的脚本，可以将其添加到 `.gitlab-ci.yml` 中：

```yaml
before_script:
  - bash ci/docker_install.sh > /dev/null
```

最后，使用 `phpunit` 运行实际测试：

```yaml
test:app:
  script:
    - phpunit --configuration phpunit_myapp.xml
```

最后，提交您的文件并将其推送到极狐GitLab，以查看您的构建成功（或失败）。

最终的 `.gitlab-ci.yml` 应类似于：

```yaml
default:
  # Select image from https://hub.docker.com/_/php
  image: php:5.6
  before_script:
    # Install dependencies
    - bash ci/docker_install.sh > /dev/null

test:app:
  script:
    - phpunit --configuration phpunit_myapp.xml
```

<a id="test-against-different-php-versions-in-docker-builds"></a>

### 在 Docker 构建中针对不同 PHP 版本进行测试

要针对多个 PHP 版本进行测试，请添加另一个使用不同 Docker 镜像版本的作业。其余工作由 Runner 完成：

```yaml
default:
  before_script:
    # Install dependencies
    - bash ci/docker_install.sh > /dev/null

# Test PHP5.6
test:5.6:
  image: php:5.6
  script:
    - phpunit --configuration phpunit_myapp.xml

# Test PHP7.0 (good luck with that)
test:7.0:
  image: php:7.0
  script:
    - phpunit --configuration phpunit_myapp.xml
```

<a id="custom-php-configuration-in-docker-builds"></a>

### 在 Docker 构建中自定义 PHP 配置

要自定义您的 PHP 环境，请通过 `before_script` 操作将您的 `.ini` 文件复制到 `/usr/local/etc/php/conf.d/`。该 `.ini` 文件（本例中为 `my_php.ini`）必须位于代码仓库的根目录中：

```yaml
before_script:
  - cp my_php.ini /usr/local/etc/php/conf.d/test.ini
```

<a id="test-php-projects-using-the-shell-executor"></a>

## 使用 Shell 执行器测试 PHP 项目

Shell 执行器在您服务器上的终端会话中运行您的作业。要测试您的项目，您必须首先确保所有依赖项都已安装。

例如，在运行 Debian 8 的虚拟机中，首先更新缓存，然后安装 `phpunit` 和 `php5-mysql`：

```shell
sudo apt-get update -y
sudo apt-get install -y phpunit php5-mysql
```

接下来，将以下代码片段添加到您的 `.gitlab-ci.yml` 中：

```yaml
test:app:
  script:
    - phpunit --configuration phpunit_myapp.xml
```

最后，推送到极狐GitLab，让测试开始吧！

<a id="test-against-different-php-versions-in-shell-builds"></a>

### 在 Shell 构建中针对不同 PHP 版本进行测试

[phpenv](https://github.com/phpenv/phpenv) 项目允许您管理不同版本的 PHP，每个版本都有自己的配置。在使用 Shell 执行器测试 PHP 项目时，请使用 phpenv。

您必须按照 [上游安装指南](https://github.com/phpenv/phpenv#installation) 在构建机器上以 `gitlab-runner` 用户身份安装它。

使用 phpenv 还可以让您通过以下方式配置 PHP 环境：

```shell
phpenv config-add my_config.ini
```

**重要说明**：`phpenv/phpenv` 似乎 [已被弃用](https://github.com/phpenv/phpenv/issues/57)。有一个位于 [`madumlao/phpenv`](https://github.com/madumlao/phpenv) 的分支试图让该项目重获新生。[`CHH/phpenv`](https://github.com/CHH/phpenv) 似乎也是一个不错的选择。选择上述任何工具都可以使用基本的 phpenv 命令。指导您选择正确的 phpenv 超出了本教程的范围。

<a id="install-custom-extensions"></a>

### 安装自定义扩展

由于这是一个非常精简的 PHP 环境安装，您可能需要一些构建机器上不存在的扩展。

要安装额外的扩展，请执行：

```shell
pecl install <extension>
```

不建议将此添加到 `.gitlab-ci.yml` 中。您应该只执行此命令一次，仅用于设置构建环境。

<a id="extend-your-tests"></a>

## 扩展您的测试

<a id="using-atoum"></a>

### 使用 `atoum`

除了 PHPUnit，您还可以使用任何其他工具来运行单元测试。例如，您可以使用 [`atoum`](https://github.com/atoum/atoum)：

```yaml
test:atoum:
  before_script:
    - wget http://downloads.atoum.org/nightly/mageekguy.atoum.phar
  script:
    - php mageekguy.atoum.phar
```

<a id="using-composer"></a>

### 使用 Composer

大多数 PHP 项目使用 Composer 来管理其 PHP 软件包。要在运行测试之前执行 Composer，请将以下内容添加到您的 `.gitlab-ci.yml` 中：

```yaml
# Composer stores all downloaded packages in the vendor/ directory.
# Do not use the following if the vendor/ directory is committed to
# your git repository.
default:
  cache:
    paths:
      - vendor/
  before_script:
    # Install composer dependencies
    - wget https://composer.github.io/installer.sig -O - -q | tr -d '\n' > installer.sig
    - php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    - php -r "if (hash_file('SHA384', 'composer-setup.php') === file_get_contents('installer.sig')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    - php composer-setup.php
    - php -r "unlink('composer-setup.php'); unlink('installer.sig');"
    - php composer.phar install
```

<a id="access-private-packages-or-dependencies"></a>

## 访问私有软件包或依赖项

如果您的测试套件需要访问私有代码仓库，则需要配置 [SSH 密钥](../jobs/ssh_keys.md) 来克隆它。

<a id="use-databases-or-other-services"></a>

## 使用数据库或其他服务

大多数情况下，您的测试需要一个正在运行的数据库。如果您使用 Docker 执行器，则可以利用 Docker 链接到其他容器。使用极狐GitLab Runner，可以通过定义 `service` 来实现这一点。

此功能在 [CI 服务](../services/_index.md) 文档中介绍。

<a id="example-project"></a>

## 示例项目

为了方便您，有一个 [示例 PHP 项目](https://gitlab.com/gitlab-examples/php)，它使用公开可用的 [实例 Runner](../runners/_index.md) 在 [GitLab.com](https://gitlab.com) 上运行。

想要修改它吗？分叉它，提交并推送您的更改。片刻之后，公共 Runner 会获取这些更改，作业随即开始。
