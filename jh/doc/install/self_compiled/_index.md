---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Install GitLab from source on Debian or Ubuntu by compiling and configuring each component manually.
title: 自编译安装
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

这是使用源文件设置生产环境极狐GitLab 服务器的官方安装指南。本指南基于 **Debian/Ubuntu** 操作系统创建并测试。阅读 [requirements.md](../requirements.md) 了解硬件和操作系统要求。如果你想在 RHEL/CentOS 上安装，你应该使用 [Linux 软件包](https://gitlab.cn/install/)。更多安装选项，请参见 [主安装页面](_index.md)。

本指南篇幅较长，因为它涵盖了多种场景，并包含你需要执行的所有命令。以下步骤已经过验证可以正常工作。**当你偏离**本指南时请务必谨慎。确保不要破坏极狐GitLab 对其运行环境的任何假设。例如，许多用户因为改变了目录位置或以错误的用户身份运行服务而遇到权限问题。

如果你在本指南中发现漏洞或错误，请遵循 [贡献指南](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/CONTRIBUTING.md) **提交合并请求**。

<a id="consider-the-linux-package-installation"></a>

## 考虑 Linux 软件包安装

由于自编译安装工作量大且容易出错，我们强烈推荐使用快速、可靠的 [Linux 软件包安装](https://gitlab.cn/install/)（deb/rpm）。

Linux 软件包更可靠的一个原因是它使用 runit 在任何极狐GitLab 进程崩溃时重启它们。在负载较重的极狐GitLab 实例上，Sidekiq 后台工作进程的内存使用会随时间增长。如果 Sidekiq 使用过多内存，Linux 软件包会通过[优雅地终止 Sidekiq](../../administration/sidekiq/sidekiq_memory_killer.md) 来解决此问题。终止后，runit 检测到 Sidekiq 没有运行并启动它。由于自编译安装不使用 runit 进行进程管理，因此无法终止 Sidekiq，其内存使用会随时间增长。

<a id="select-a-version-to-install"></a>

## 选择要安装的版本

确保你从想要安装的极狐GitLab 版本对应的分支（例如 `16-0-stable`）中查看 [本安装指南](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/doc/install/self_compiled/_index.md)。你可以在极狐GitLab 左上角的版本下拉列表（菜单栏下方）中选择分支。

如果版本号最高的稳定分支不明确，请查看 [极狐GitLab 博客](https://gitlab.cn/blog/) 以获取按版本划分的安装指南链接。

<a id="software-requirements"></a>

## 软件要求

| 软件                | 最低版本 | 备注                                                                                                                                                                                                                                                                                  |
|:------------------------|:----------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Ruby](#2-ruby)         | `3.2.x`         | 从极狐GitLab 16.7 到 17.4，需要 Ruby 3.1。在极狐GitLab 17.5 及更高版本中，需要 Ruby 3.2。你必须使用标准的 MRI Ruby 实现。我们热爱 [JRuby](https://www.jruby.org/) 和 [Rubinius](https://github.com/rubinius/rubinius#the-rubinius-language-platform)，但极狐GitLab 需要一些带有原生扩展的 Gem。 |
| [RubyGems](#3-rubygems) | `3.5.x`         | 不要求特定的 RubyGems 版本，但你应该更新以受益于一些已知的性能改进。 |
| [Go](#4-go)             | `1.22.x`        | 在极狐GitLab 17.1 及更高版本中，需要 Go 1.22 或更高版本。                                                                                                                                                                                                                                        |
| [Git](#git)             | `2.47.x`        | 在极狐GitLab 17.7 及更高版本中，需要 Git 2.47.x 或更高版本。你应该使用 [Gitaly 提供的 Git 版本](#git)。                                                                                                                                                   |
| [Node.js](#5-node)      | `20.13.x`       | 在极狐GitLab 17.0 及更高版本中，需要 Node.js 20.13 或更高版本。                                                                                                                                                                                                                                  |
| [PostgreSQL](#7-database) | `16.x`          | 在极狐GitLab 18.0 及更高版本中，需要 PostgreSQL 16 或更高版本。                                                                                                                                                                                                                                  |

<a id="gitlab-directory-structure"></a>

## 极狐GitLab 目录结构

在安装过程中，会创建以下目录：

```plaintext
|-- home
|   |-- git
|       |-- .ssh
|       |-- gitlab
|       |-- gitlab-shell
|       |-- repositories
```

- `/home/git/.ssh` - 包含 OpenSSH 设置。特别是由极狐GitLab Shell 管理的 `authorized_keys` 文件。
- `/home/git/gitlab` - 极狐GitLab 核心软件。
- `/home/git/gitlab-shell` - 极狐GitLab 的核心附加组件。维护 SSH 克隆和其他功能。
- `/home/git/repositories` - 所有项目的裸仓库，按命名空间组织。此目录用于存放所有项目的推送/拉取的 Git 仓库。**此区域包含项目的关键数据。[请做好备份](../../administration/backup_restore/_index.md)**。

仓库的默认位置可以在极狐GitLab 的 `config/gitlab.yml` 和极狐GitLab Shell 的 `config.yml` 中配置。

现在无需手动创建这些目录，否则后续安装可能会出错。

<a id="installation-workflow"></a>

## 安装流程

极狐GitLab 安装包括设置以下组件：

1. [软件包和依赖项](#1-packages-and-dependencies)。
1. [Ruby](#2-ruby)。
1. [RubyGems](#3-rubygems)。
1. [Go](#4-go)。
1. [Node](#5-node)。
1. [系统用户](#6-system-users)。
1. [数据库](#7-database)。
1. [Redis](#8-redis)。
1. [极狐GitLab](#9-gitlab)。
1. [NGINX](#10-nginx)。

<a id="1-packages-and-dependencies"></a>

## 1. 软件包和依赖项

<a id="sudo"></a>

### sudo

Debian 默认未安装 `sudo`。请确保系统是最新的，然后安装它。

```shell
# 以 root 身份运行！
apt-get update -y
apt-get upgrade -y
apt-get install sudo -y
```

<a id="build-dependencies"></a>

### 构建依赖项

安装必需的软件包（编译 Ruby 和 Ruby gem 的原生扩展需要）：

```shell
sudo apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libre2-dev \
  libreadline-dev libncurses5-dev libffi-dev curl openssh-server libxml2-dev libxslt-dev \
  libcurl4-openssl-dev libicu-dev libkrb5-dev logrotate rsync python3-docutils pkg-config cmake \
  runit-systemd
```

> [!note]
> 极狐GitLab 需要 OpenSSL 版本 1.1。如果你的 Linux 发行版包含不同版本的 OpenSSL，你可能需要手动安装 1.1。

<a id="git"></a>

### Git

你应该使用 [Gitaly 提供的 Git 版本](https://jihulab.com/gitlab-cn/gitaly/-/issues/2729)，因为它：

- 始终是极狐GitLab 要求的版本。
- 可能包含正常运行所需的自定义补丁。

1. 安装所需的依赖项：

   ```shell
   sudo apt-get install -y libcurl4-openssl-dev libexpat1-dev gettext libz-dev libssl-dev libpcre2-dev build-essential git-core
   ```

1. 克隆 Gitaly 仓库并编译 Git。将 `<X-Y-stable>` 替换为与要安装的极狐GitLab 版本匹配的稳定分支。例如，如果你想安装极狐GitLab 16.7，请使用分支名称 `16-7-stable`：

   ```shell
   git clone https://jihulab.com/gitlab-cn/gitaly.git -b <X-Y-stable> /tmp/gitaly
   cd /tmp/gitaly
   sudo make git GIT_PREFIX=/usr/local
   ```

1. 或者，你可以移除系统的 Git 及其依赖项：

   ```shell
   sudo apt remove -y git-core
   sudo apt autoremove
   ```

当[稍后编辑 `config/gitlab.yml`](#configure-it) 时，请记得修改 Git 路径：

- 从：

  ```yaml
  git:
    bin_path: /usr/bin/git
  ```

- 改为：

  ```yaml
  git:
    bin_path: /usr/local/bin/git
  ```

<a id="graphicsmagick"></a>

### GraphicsMagick

为了使[自定义网站图标](../../administration/appearance.md#customize-the-favicon)正常工作，必须安装 GraphicsMagick。

```shell
sudo apt-get install -y graphicsmagick
```

<a id="mail-server"></a>

### 邮件服务器

要接收邮件通知，请确保安装邮件服务器。默认情况下，Debian 自带 `exim4`，但[存在问题](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/12754)，而 Ubuntu 不自带。推荐的邮件服务器是 `postfix`，你可以通过以下命令安装：

```shell
sudo apt-get install -y postfix
```

然后选择 `Internet 站点` 并按下 <kbd>Enter</kbd> 确认主机名。

<a id="exiftool"></a>

### ExifTool

[极狐GitLab Workhorse](https://gitlab.com/gitlab-org/gitlab-workhorse#dependencies) 需要 `exiftool` 来移除上传图片的 EXIF 数据。

```shell
sudo apt-get install -y libimage-exiftool-perl
```

<a id="2-ruby"></a>

## 2. Ruby

运行极狐GitLab 需要 Ruby 解释器。请参阅[要求部分](#software-requirements)了解最低 Ruby 要求。

RVM、rbenv 或 chruby 等 Ruby 版本管理器可能导致难以诊断的极狐GitLab 问题。你应该改为[从官方源代码安装 Ruby](https://www.ruby-lang.org/en/documentation/installation/)。

<a id="3-rubygems"></a>

## 3. RubyGems

有时，需要的 RubyGems 版本比 Ruby 捆绑的更新。

更新到特定版本：

```shell
gem update --system 3.4.12
```

或更新到最新版本：

```shell
gem update --system
```

<a id="4-go"></a>

## 4. Go

极狐GitLab 有几个用 Go 编写的守护进程。要安装极狐GitLab，你必须安装 Go 编译器。以下说明假设你使用的是 64 位 Linux。你可以在 [Go 下载页面](https://go.dev/dl/) 找到其他平台的下载。

```shell
# 移除以前的 Go 安装文件夹
sudo rm -rf /usr/local/go

curl --remote-name --location --progress-bar "https://go.dev/dl/go1.22.5.linux-amd64.tar.gz"
echo '904b924d435eaea086515bc63235b192ea441bd8c9b198c507e85009e6e4c7f0  go1.22.5.linux-amd64.tar.gz' | shasum -a256 -c - && \
  sudo tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz
sudo ln -sf /usr/local/go/bin/{go,gofmt} /usr/local/bin/
rm go1.22.5.linux-amd64.tar.gz
```

<a id="5-node"></a>

## 5. Node

极狐GitLab 需要使用 Node 来编译 JavaScript 资产，以及使用 Yarn 来管理 JavaScript 依赖。当前的最低要求是：

- `node` 20.x 版本（v20.13.0 或更高版本）。[其他 LTS 版本的 Node.js](https://github.com/nodejs/release#release-schedule) 可能能够构建资产，但我们仅保证 Node.js 20.x。
- `yarn` = v1.22.x（尚不支持 Yarn 2）

在许多发行版中，官方软件包仓库提供的版本已过时，因此我们必须通过以下命令安装：

```shell
# 安装 node v20.x
curl --location "https://deb.nodesource.com/setup_20.x" | sudo bash -
sudo apt-get install -y nodejs

npm install --global yarn
```

如果在这些步骤中遇到任何问题，请访问 [node](https://nodejs.org/en/download) 和 [yarn](https://classic.yarnpkg.com/en/docs/install/) 的官方网站。

<a id="6-system-users"></a>

## 6. 系统用户

为极狐GitLab 创建一个 `git` 用户：

```shell
sudo adduser --disabled-login --gecos 'GitLab' git
```

<a id="7-database"></a>

## 7. 数据库

> [!note]
> 仅支持 PostgreSQL。在极狐GitLab 18.0 及更高版本中，我们[要求 PostgreSQL 16+](../requirements.md#postgresql)。

1. 安装数据库软件包。

   对于 Ubuntu 22.04 及更高版本：

   ```shell
   sudo apt install -y postgresql postgresql-client libpq-dev postgresql-contrib
   ```

   对于 Ubuntu 20.04 及更早版本，可用的 PostgreSQL 不满足最低版本要求。你必须添加 PostgreSQL 的仓库：

   ```shell
   sudo curl --fail --silent --show-error --output /etc/apt/keyrings/postgresql.asc \
             --url "https://www.postgresql.org/media/keys/ACCC4CF8.asc"
   echo "deb [ signed-by=/etc/apt/keyrings/postgresql.asc ] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" |
        sudo tee /etc/apt/sources.list.d/pgdg.list
   sudo apt-get update
   sudo apt-get -y install postgresql-16
   ```

1. 验证你安装的 PostgreSQL 版本是否被你要安装的极狐GitLab 版本支持：

   ```shell
   psql --version
   ```

1. 启动 PostgreSQL 服务并确认服务正在运行：

   ```shell
   sudo service postgresql start
   sudo service postgresql status
   ```

1. 为极狐GitLab 创建一个数据库用户：

   ```shell
   sudo -u postgres psql -d template1 -c "CREATE USER git CREATEDB;"
   ```

1. 创建 `pg_trgm` 扩展：

   ```shell
   sudo -u postgres psql -d template1 -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
   ```

1. 创建 `btree_gist` 扩展：

   ```shell
   sudo -u postgres psql -d template1 -c "CREATE EXTENSION IF NOT EXISTS btree_gist;"
   ```

1. 创建 `plpgsql` 扩展：

   ```shell
   sudo -u postgres psql -d template1 -c "CREATE EXTENSION IF NOT EXISTS plpgsql;"
   ```

1. 创建极狐GitLab 生产数据库并授予数据库的所有权限：

   ```shell
   sudo -u postgres psql -d template1 -c "CREATE DATABASE gitlabhq_production OWNER git;"
   ```

1. 尝试使用新用户连接新数据库：

   ```shell
   sudo -u git -H psql -d gitlabhq_production
   ```

1. 检查是否已启用 `pg_trgm` 扩展：

   ```sql
   SELECT true AS enabled
   FROM pg_available_extensions
   WHERE name = 'pg_trgm'
   AND installed_version IS NOT NULL;
   ```

   如果扩展已启用，将产生以下输出：

   ```plaintext
   已启用
   ---------
    t
   (1 行)
   ```

1. 检查是否已启用 `btree_gist` 扩展：

   ```sql
   SELECT true AS enabled
   FROM pg_available_extensions
   WHERE name = 'btree_gist'
   AND installed_version IS NOT NULL;
   ```

   如果扩展已启用，将产生以下输出：

   ```plaintext
   已启用
   ---------
    t
   (1 行)
   ```

1. 检查是否已启用 `plpgsql` 扩展：

   ```sql
   SELECT true AS enabled
   FROM pg_available_extensions
   WHERE name = 'plpgsql'
   AND installed_version IS NOT NULL;
   ```

   如果扩展已启用，将产生以下输出：

   ```plaintext
   已启用
   ---------
    t
   (1 行)
   ```

1. 退出数据库会话：

   ```shell
   gitlabhq_production> \q
   ```

<a id="8-redis"></a>

## 8. Redis

请参阅[要求页面](../requirements.md#redis) 了解最低 Redis 要求。

使用以下命令安装 Redis：

```shell
sudo apt-get install redis-server
```

完成后，你可以配置 Redis：

```shell
# 配置 Redis 使用套接字
sudo cp /etc/redis/redis.conf /etc/redis/redis.conf.orig

# 通过将 'port' 设为 0 来禁用 Redis 监听 TCP
sudo sed 's/^port .*/port 0/' /etc/redis/redis.conf.orig | sudo tee /etc/redis/redis.conf

# 为默认的 Debian / Ubuntu 路径启用 Redis 套接字
echo 'unixsocket /var/run/redis/redis.sock' | sudo tee -a /etc/redis/redis.conf

# 将套接字权限授予 redis 组的所有成员
echo 'unixsocketperm 770' | sudo tee -a /etc/redis/redis.conf

# 将 git 用户添加到 redis 组
sudo usermod -aG redis git
```

<a id="supervise-redis-with-systemd"></a>

### 使用 systemd 管理 Redis

如果你的发行版使用 systemd init，并且以下命令的输出是 `notify`，那么你无需做任何更改：

```shell
systemctl show --value --property=Type redis-server.service
```

如果输出**不是** `notify`，请运行：

```shell
# 配置 Redis 不以后台进程方式运行，而是由 systemd 管理，并禁用 pidfile
sudo sed -i \
         -e 's/^daemonize yes$/daemonize no/' \
         -e 's/^supervised no$/supervised systemd/' \
         -e 's/^pidfile/# pidfile/' /etc/redis/redis.conf
sudo chown redis:redis /etc/redis/redis.conf

# 对 systemd 单元文件做相同的更改
sudo mkdir -p /etc/systemd/system/redis-server.service.d
sudo tee /etc/systemd/system/redis-server.service.d/10fix_type.conf <<EOF
[Service]
Type=notify
PIDFile=
EOF

# 重新加载 redis 服务
sudo systemctl daemon-reload

# 激活对 redis.conf 的更改
sudo systemctl restart redis-server.service
```

<a id="leave-redis-unsupervised"></a>

### 让 Redis 不受管理

如果你的系统使用 SysV init，运行以下命令：

```shell
# 创建包含套接字的目录
sudo mkdir -p /var/run/redis
sudo chown redis:redis /var/run/redis
sudo chmod 755 /var/run/redis

# 如果适用，持久化包含套接字的目录
if [ -d /etc/tmpfiles.d ]; then
  echo 'd  /var/run/redis  0755  redis  redis  10d  -' | sudo tee -a /etc/tmpfiles.d/redis.conf
fi

# 激活对 redis.conf 的更改
sudo service redis-server restart
```

<a id="9-gitlab"></a>

## 9. 极狐GitLab

```shell
# 我们将把极狐GitLab 安装到用户 "git" 的家目录中
cd /home/git
```

<a id="clone-the-source"></a>

### 克隆源代码

克隆极狐版：

```shell
# 克隆极狐GitLab 仓库
sudo -u git -H git clone https://jihulab.com/gitlab-cn/gitlab.git -b <X-Y-stable-jh> gitlab
```

确保将 `<X-Y-stable-jh>` 替换为与你要安装的版本匹配的稳定分支。例如，如果你想安装 18.8，请使用分支名称 `18-8-stable-jh`。

> [!warning]
> 如果你想要“前沿”版本，可以将 `<X-Y-stable-jh>` 更改为 `main-jh`，但切勿在生产服务器上安装 `main-jh`！

<a id="configure-it"></a>

### 配置极狐GitLab

```shell
# 进入极狐GitLab 安装文件夹
cd /home/git/gitlab

# 复制示例极狐GitLab 配置
sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml

# 更新极狐GitLab 配置文件，按照文件顶部的指示操作
sudo -u git -H editor config/gitlab.yml

# 复制示例密钥文件
sudo -u git -H cp config/secrets.yml.example config/secrets.yml
sudo -u git -H chmod 0600 config/secrets.yml

# 确保极狐GitLab 可以写入 log/ 和 tmp/ 目录
sudo chown -R git log/
sudo chown -R git tmp/
sudo chmod -R u+rwX,go-w log/
sudo chmod -R u+rwX tmp/

# 确保极狐GitLab 可以写入 tmp/pids/ 和 tmp/sockets/ 目录
sudo chmod -R u+rwX tmp/pids/
sudo chmod -R u+rwX tmp/sockets/

# 创建 public/uploads/ 目录
sudo -u git -H mkdir -p public/uploads/

# 确保只有极狐GitLab 用户可以访问 public/uploads/ 目录
# 因为现在 public/uploads 中的文件由 gitlab-workhorse 提供服务
sudo chmod 0700 public/uploads

# 更改存储 CI 作业日志的目录的权限
sudo chmod -R u+rwX builds/

# 更改存储 CI 产物的目录的权限
sudo chmod -R u+rwX shared/artifacts/

# 更改存储极狐GitLab Pages 的目录的权限
sudo chmod -R ug+rwX shared/pages/

# 复制示例 Puma 配置
sudo -u git -H cp config/puma.rb.example config/puma.rb

# 更多信息请参考 https://github.com/puma/puma#configuration。
# 你应该根据可用的 CPU 核心数调整 Puma 工作进程和线程的数量。你可以通过 `nproc` 命令获取该数字。
sudo -u git -H editor config/puma.rb

# 配置 Redis 连接设置
sudo -u git -H cp config/resque.yml.example config/resque.yml
sudo -u git -H cp config/cable.yml.example config/cable.yml

# 如果你未使用默认的 Debian / Ubuntu 配置，请更改 Redis 套接字路径
sudo -u git -H editor config/resque.yml config/cable.yml
```

请确保编辑 `gitlab.yml` 和 `puma.rb` 以匹配你的设置。

如果你希望使用 HTTPS，请参阅[使用 HTTPS](#using-https) 了解额外的步骤。

<a id="configure-gitlab-db-settings"></a>

### 配置极狐GitLab 数据库设置

> [!note]
> 从[极狐GitLab 15.9](https://gitlab.com/gitlab-org/gitlab/-/issues/387898) 开始，仅包含 `main:` 部分的 `database.yml` 已弃用。在极狐GitLab 17.0 及更高版本中，你的 `database.yml` 中必须同时包含 `main:` 和 `ci:` 两个部分。

```shell
sudo -u git cp config/database.yml.postgresql config/database.yml

# 从 config/database.yml 中删除 host、username 和 password 行。
# 修改后，`production` 设置将如下所示：
#
#   production:
#     main:
#       adapter: postgresql
#       encoding: unicode
#       database: gitlabhq_production
#     ci:
#       adapter: postgresql
#       encoding: unicode
#       database: gitlabhq_production
#       database_tasks: false
#
sudo -u git -H editor config/database.yml

# 仅远程 PostgreSQL：
# 在 config/database.yml 中更新用户名/密码。
# 你只需要调整 production 设置（第一部分）。
# 如果你按照数据库指南操作，请执行以下操作：
# 将 'secure password' 更改为你为 $password 设置的值
# 你可以保留密码两边的双引号
sudo -u git -H editor config/database.yml

# 取消注释 config/database.yml 中的 `ci:` 部分。
# 确保 `ci:` 中的 `database` 值与 `main:` 中的 `database` 值匹配。

# 使 config/database.yml 仅对 git 可读
sudo -u git -H chmod o-rwx config/database.yml
```

你的 `database.yml` 中应该有两个部分：`main:` 和 `ci:`。`ci:` 连接[必须指向同一个数据库](../../administration/postgresql/_index.md)。

<a id="install-gems"></a>

### 安装 Gem

> [!note]
> 从 Bundler 1.5.2 开始，你可以运行 `bundle install -jN`（其中 `N` 是你的处理器核心数），以并行方式安装 gem，这可以显著缩短完成时间（约快 60%）。使用 `nproc` 查看你的核心数。更多信息，请参阅此[文章](https://thoughtbot.com/blog/parallel-gem-installing-using-bundler)。

确保你已安装 `bundle`（运行 `bundle -v`）并且：

- `>= 1.5.2`，因为 1.5.2 中[修复](https://github.com/rubygems/bundler/pull/2817)了一些[问题](https://devcenter.heroku.com/changelog-items/411)。
- `< 2.x`。

安装 gem（如果你想使用 Kerberos 进行用户认证，请在以下命令的 `--without` 选项中省略 `kerberos`）：

```shell
sudo -u git -H bundle config set --local deployment 'true'
sudo -u git -H bundle config set --local without 'development test kerberos'
sudo -u git -H bundle config path /home/git/gitlab/vendor/bundle
sudo -u git -H bundle install
```

<a id="install-gitlab-shell"></a>

### 安装极狐GitLab Shell

极狐GitLab Shell 是专门为极狐GitLab 开发的 SSH 访问和仓库管理软件。

```shell
# 运行 gitlab-shell 的安装任务：
sudo -u git -H bundle exec rake gitlab:shell:install RAILS_ENV=production

# 默认情况下，gitlab-shell 配置是根据你的主要极狐GitLab 配置生成的。
# 你可以按如下方式查看（和修改）gitlab-shell 配置：
sudo -u git -H editor /home/git/gitlab-shell/config.yml
```

如果你希望使用 HTTPS，请参阅[使用 HTTPS](#using-https) 了解额外的步骤。

确保你的主机名能在本机上解析，可以通过正确的 DNS 记录或者在 `/etc/hosts` 中添加一行（如 "127.0.0.1 hostname"）来实现。例如，如果你在反向代理后面设置极狐GitLab，这就很有必要。如果无法解析主机名，最终的安装检查会失败，并显示 `Check GitLab API access: FAILED. code: 401`，并且推送提交会被拒绝，显示 `[remote rejected] master -> master (hook declined)`。

<a id="install-gitlab-workhorse"></a>

### 安装极狐GitLab Workhorse

极狐GitLab Workhorse 使用 [GNU Make](https://www.gnu.org/software/make/)。以下命令行将极狐GitLab Workhorse 安装到 `/home/git/gitlab-workhorse`（推荐位置）。

```shell
sudo -u git -H bundle exec rake "gitlab:workhorse:install[/home/git/gitlab-workhorse]" RAILS_ENV=production
```

你可以通过提供一个额外的参数来指定不同的 Git 仓库：

```shell
sudo -u git -H bundle exec rake "gitlab:workhorse:install[/home/git/gitlab-workhorse,https://example.com/gitlab-workhorse.git]" RAILS_ENV=production
```

<a id="install-gitlab-elasticsearch-indexer-on-enterprise-edition"></a>

### 安装极狐GitLab Elasticsearch 索引器

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab Elasticsearch 索引器使用 [GNU Make](https://www.gnu.org/software/make/)。以下命令行将极狐GitLab Elasticsearch 索引器安装到 `/home/git/gitlab-elasticsearch-indexer`（推荐位置）。

```shell
sudo -u git -H bundle exec rake "gitlab:indexer:install[/home/git/gitlab-elasticsearch-indexer]" RAILS_ENV=production
```
你可以指定一个不同的 Git 仓库，通过提供额外的参数：

```shell
sudo -u git -H bundle exec rake "gitlab:indexer:install[/home/git/gitlab-elasticsearch-indexer,https://example.com/gitlab-elasticsearch-indexer.git]" RAILS_ENV=production
```

首先会将源代码拉取到第一个参数指定的路径。然后在它的 `bin` 目录下构建出二进制文件。
之后，你需要更新 `gitlab.yml` 中 `production -> elasticsearch -> indexer_path` 的配置，将其指向该二进制文件。

### 安装极狐GitLab Pages

极狐GitLab Pages 使用 [GNU Make](https://www.gnu.org/software/make/)。此步骤为可选操作，仅在你希望在极狐GitLab 中托管静态站点时需要。以下命令会将极狐GitLab Pages 安装到 `/home/git/gitlab-pages`。对于额外的设置步骤，请查阅对应你极狐GitLab 版本的[管理指南](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/doc/administration/pages/source.md)，因为极狐GitLab Pages 守护进程可以有多种运行方式。

```shell
cd /home/git
sudo -u git -H git clone https://jihulab.com/gitlab-cn/gitlab-pages.git
cd gitlab-pages
sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_PAGES_VERSION)
sudo -u git -H make
```

### 安装 Gitaly

```shell
# 创建并限制对 git 仓库数据目录的访问
sudo install -d -o git -m 0700 /home/git/repositories

# 使用 Git 拉取 Gitaly 源代码，并用 Go 编译
cd /home/git/gitlab
sudo -u git -H bundle exec rake "gitlab:gitaly:install[/home/git/gitaly,/home/git/repositories]" RAILS_ENV=production
```

你可以指定一个不同的 Git 仓库，通过提供额外的参数：

```shell
sudo -u git -H bundle exec rake "gitlab:gitaly:install[/home/git/gitaly,/home/git/repositories,https://example.com/gitaly.git]" RAILS_ENV=production
```

接下来，确保 Gitaly 配置正确：

```shell
# 限制 Gitaly 套接字访问
sudo chmod 0700 /home/git/gitlab/tmp/sockets/private
sudo chown git /home/git/gitlab/tmp/sockets/private

# 如果你使用了非默认设置，需要更新 config.toml
cd /home/git/gitaly
sudo -u git -H editor config.toml
```

有关配置 Gitaly 的更多信息，请参见
[Gitaly 文档](../../administration/gitaly/_index.md)。

<a id="install-the-service"></a>

### 安装服务

极狐GitLab 一直以来都支持 SysV init 脚本，它们被广泛支持且具有良好的可移植性，但现在 systemd 已成为服务监控的标准，并且所有主流 Linux 发行版都在使用。如果可能，你应当使用原生的 systemd 服务，以便享受自动重启、更好的沙箱和资源控制等优点。

<a id="install-systemd-units"></a>

#### 安装 systemd 单元

如果你使用 systemd 作为初始化系统，请按此步骤操作。否则，请遵循 [SysV init 脚本步骤](#install-sysv-init-script)。

复制服务文件，并运行 `systemctl daemon-reload` 使 systemd 加载它们：

```shell
cd /home/git/gitlab
sudo mkdir -p /usr/local/lib/systemd/system
sudo cp lib/support/systemd/* /usr/local/lib/systemd/system/
sudo systemctl daemon-reload
```

极狐GitLab 提供的单元文件对 Redis 和 PostgreSQL 的运行位置仅做了极少的假设。

如果你将极狐GitLab 安装在了其他目录，或者使用了非默认用户，你也必须同样修改这些单元文件中的对应值。

例如，如果你在与极狐GitLab 相同的机器上运行 Redis 和 PostgreSQL，你应该：

- 编辑 Puma 服务：

  ```shell
  sudo systemctl edit gitlab-puma.service
  ```

  在打开的编辑器中，添加以下内容并保存文件：

  ```plaintext
  [Unit]
  Wants=redis-server.service postgresql.service
  After=redis-server.service postgresql.service
  ```

- 编辑 Sidekiq 服务：

  ```shell
  sudo systemctl edit gitlab-sidekiq.service
  ```

  添加以下内容并保存文件：

  ```plaintext
  [Unit]
  Wants=redis-server.service postgresql.service
  After=redis-server.service postgresql.service
  ```

`systemctl edit` 会在 `/etc/systemd/system/<单元名称>.d/override.conf` 安装附加配置文件，这样在以后更新单元文件时，你的本地配置就不会被覆盖。要拆分你的附加配置文件，你可以将上述片段添加到 `/etc/systemd/system/<单元名称>.d/` 下的 `.conf` 文件中。

如果你手动修改了单元文件，或者添加了附加配置文件（而没有使用 `systemctl edit`），请运行以下命令以使改动生效：

```shell
sudo systemctl daemon-reload
```

让极狐GitLab 开机自启动：

```shell
sudo systemctl enable gitlab.target
```

<a id="install-sysv-init-script"></a>

#### 安装 SysV init 脚本

如果你使用 SysV init 脚本，请按此步骤操作。如果使用 systemd，请遵循 [systemd 单元步骤](#install-systemd-units)。

下载 init 脚本（即 `/etc/init.d/gitlab`）：

```shell
cd /home/git/gitlab
sudo cp lib/support/init.d/gitlab /etc/init.d/gitlab
```

如果你安装在非默认目录或使用了非默认用户，请复制并编辑默认配置文件：

```shell
sudo cp lib/support/init.d/gitlab.default.example /etc/default/gitlab
```

如果你将极狐GitLab 安装在了其他目录，或者使用了非默认用户，你应该在 `/etc/default/gitlab` 中修改这些设置。不要编辑 `/etc/init.d/gitlab`，因为它会在升级时被覆盖。

让极狐GitLab 开机自启动：

```shell
sudo update-rc.d gitlab defaults 21
# 或者，如果在运行 systemd 的机器上执行
sudo systemctl daemon-reload
sudo systemctl enable gitlab.service
```

### 设置 Logrotate

```shell
sudo cp lib/support/logrotate/gitlab /etc/logrotate.d/gitlab
```

### 启动 Gitaly

在进入下一部分之前，Gitaly 必须处于运行状态。

- 使用 systemd 启动 Gitaly：

  ```shell
  sudo systemctl start gitlab-gitaly.service
  ```

- 对于 SysV，手动启动 Gitaly：

  ```shell
  gitlab_path=/home/git/gitlab
  gitaly_path=/home/git/gitaly

  sudo -u git -H sh -c "$gitlab_path/bin/daemon_with_pidfile $gitlab_path/tmp/pids/gitaly.pid \
    $gitaly_path/_build/bin/gitaly $gitaly_path/config.toml >> $gitlab_path/log/gitaly.log 2>&1 &"
  ```

### 初始化数据库并激活高级功能

```shell
cd /home/git/gitlab
sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production
# 输入 'yes' 来创建数据库表。

# 或者你可以通过添加 force=yes 来跳过该问题
sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production force=yes

# 完成后，你会看到 '管理员账户已创建：'
```

你可以通过环境变量 `GITLAB_ROOT_PASSWORD` 和 `GITLAB_ROOT_EMAIL` 来设置管理员/root 密码和邮箱，如下所示。如果你没有设置密码（将使用默认密码），在安装完成并首次登录服务器之前，不要将极狐GitLab 暴露到公网。首次登录时，你会被强制要求修改默认密码。此时也可以通过提供 `GITLAB_ACTIVATION_CODE` 环境变量来激活极狐GitLab 订阅。

```shell
sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production GITLAB_ROOT_PASSWORD=您的密码 GITLAB_ROOT_EMAIL=您的邮箱 GITLAB_ACTIVATION_CODE=您的激活码
```

### 保护 `secrets.yml`

`secrets.yml` 文件存储用于会话和安全变量的加密密钥。
将 `secrets.yml` 备份到安全的位置，但不要将其与数据库备份存放在同一位置。
否则，如果其中一个备份遭到泄露，你的密钥也会暴露。

### 检查应用状态

检查极狐GitLab 及其环境是否配置正确：

```shell
sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production
```

### 编译静态资源

```shell
sudo -u git -H yarn install --production --pure-lockfile
sudo -u git -H bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production
```

如果 `rake` 因 `JavaScript heap out of memory` 错误而失败，请尝试按如下方式设置 `NODE_OPTIONS` 再运行。

```shell
sudo -u git -H bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production NODE_OPTIONS="--max_old_space_size=4096"
```

### 启动你的极狐GitLab 实例

```shell
# 对于运行 systemd 的系统
sudo systemctl start gitlab.target

# 对于运行 SysV init 的系统
sudo service gitlab start
```

## 10. NGINX

NGINX 是极狐GitLab 官方支持的 Web 服务器。如果你不能或不想使用 NGINX 作为 Web 服务器，请参阅 [极狐GitLab recipes](https://jihulab.com/gitlab-cn/gitlab-recipes/)。

### 安装

```shell
sudo apt-get install -y nginx
```

### 站点配置

复制站点配置示例：

```shell
sudo cp lib/support/nginx/gitlab /etc/nginx/sites-available/gitlab
sudo ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab
```

务必编辑配置文件以匹配你的设置。同时，确保你的路径与极狐GitLab 的路径一致，特别是为非 `git` 用户安装时：

```shell
# 将 YOUR_SERVER_FQDN 更改为承载极狐GitLab 主机的完全限定域名。
#
# 记得将路径与极狐GitLab 的路径匹配，特别是
# 为非 'git' 用户安装时。
#
# 如果使用 Ubuntu 默认的 nginx 安装：
# 要么从 listen 行中删除 default_server，
# 要么执行 sudo rm -f /etc/nginx/sites-enabled/default
sudo editor /etc/nginx/sites-available/gitlab
```

如果你打算启用极狐GitLab Pages，需要使用一个单独的 NGINX 配置。请阅读
[极狐GitLab Pages 管理指南](../../administration/pages/_index.md) 了解所有必要的配置。

如果你想使用 HTTPS，请将 `gitlab` NGINX 配置替换为 `gitlab-ssl`。有关 HTTPS 配置的详细信息，请参阅[使用 HTTPS](#using-https)。

为了使 NGINX 能够读取极狐GitLab Workhorse 套接字，你必须确保 `www-data` 用户能够读取该套接字，该套接字由极狐GitLab 用户所有。如果套接字是全局可读的，例如权限为 `0755`（默认值），即可实现这一点。`www-data` 还必须能够列出父目录。

### 测试配置

使用以下命令验证你的 `gitlab` 或 `gitlab-ssl` NGINX 配置文件：

```shell
sudo nginx -t
```

你应该会收到 `syntax is okay` 和 `test is successful` 的消息。如果收到错误消息，请根据提供的错误信息，检查你的 `gitlab` 或 `gitlab-ssl` NGINX 配置文件是否存在拼写错误。

验证已安装的版本是否大于 1.12.1：

```shell
nginx -v
```

如果版本较低，你可能会收到以下错误：

```plaintext
nginx: [emerg] unknown "start$temp=[filtered]$rest" variable
nginx: configuration file /etc/nginx/nginx.conf test failed
```

### 重启

```shell
# 对于运行 systemd 的系统
sudo systemctl restart nginx.service

# 对于运行 SysV init 的系统
sudo service nginx restart
```

## 安装后

### 再次检查应用状态

为确保你没有遗漏任何步骤，请执行更全面的检查：

```shell
sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production
```

如果所有项目均为绿色，恭喜你成功安装了极狐GitLab！

> [!note]
> 在 `gitlab:check` 中添加 `SANITIZE=true` 环境变量，以从检查命令的输出中省略项目名称。

### 首次登录

在 Web 浏览器中访问 YOUR_SERVER 进行首次极狐GitLab 登录。

如果你在[设置过程中未提供 root 密码](#initialize-database-and-activate-advanced-features)，
你将被重定向到密码重置界面，为初始管理员账户设置密码。输入你想要的密码后，你将被重定向回登录界面。

默认账户的用户名是 **root**。输入你之前创建的密码并登录。登录后，你可以根据需要更改用户名。

**尽情享受！**

启动和停止极狐GitLab 时：

- 如果使用 systemd 单元：使用 `sudo systemctl start gitlab.target` 或 `sudo systemctl stop gitlab.target`。
- 如果使用 SysV init 脚本：使用 `sudo service gitlab start` 或 `sudo service gitlab stop`。

### 推荐的后续步骤

安装完成后，建议参考
[推荐的后续步骤](../next_steps.md)，包括身份验证选项和新用户账号限制。

## 高级设置提示

### 相对 URL 支持

有关如何配置具有相对 URL 的极狐GitLab 的更多信息，请参阅[相对 URL 文档](../relative_url.md)。

### 使用 HTTPS

将极狐GitLab 与 HTTPS 结合使用：

1. 在 `gitlab.yml` 中：
   1. 将第 1 节中的 `port` 选项设置为 `443`。
   1. 将第 1 节中的 `https` 选项设置为 `true`。
1. 在极狐GitLab Shell 的 `config.yml` 中：
   1. 将 `gitlab_url` 选项设置为极狐GitLab 的 HTTPS 端点（例如 `https://git.example.com`）。
   1. 使用 `ca_file` 或 `ca_path` 选项设置证书。
1. 使用 `gitlab-ssl` NGINX 配置示例，而不是 `gitlab` 配置。
   1. 更新 `YOUR_SERVER_FQDN`。
   1. 更新 `ssl_certificate` 和 `ssl_certificate_key`。
   1. 检查配置文件，并考虑应用其他安全性和性能增强功能。

不鼓励使用自签名证书。如果必须使用，请按照标准指南生成自签名 SSL 证书：

   ```shell
   mkdir -p /etc/nginx/ssl/
   cd /etc/nginx/ssl/
   sudo openssl req -newkey rsa:2048 -x509 -nodes -days 3560 -out gitlab.crt -keyout gitlab.key
   sudo chmod o-r gitlab.key
   ```

### 启用通过邮件回复

有关如何设置的更多信息，请参阅[“通过邮件回复”文档](../../administration/reply_by_email.md)。

### LDAP 身份验证

你可以在 `config/gitlab.yml` 中配置 LDAP 身份验证。编辑此文件后重启极狐GitLab。

### 使用自定义 OmniAuth 提供程序

请参阅 [OmniAuth 集成文档](../../integration/omniauth.md)。

### 构建你的项目

极狐GitLab 可以构建你的项目。要启用该功能，你需要一些 Runner 来为你执行。
请参阅 [极狐GitLab Runner 部分](https://gitlab.cn/docs/runner/) 以进行安装。

### 添加受信任的代理

如果你在单独的机器上使用反向代理，你可能希望将该代理添加到受信任的代理列表中。否则，用户会显示为从代理的 IP 地址登录。

你可以在 `config/gitlab.yml` 的第 1 节中自定义 `trusted_proxies` 选项来添加受信任的代理。保存文件并[重新配置极狐GitLab](../../administration/restart_gitlab.md) 以使更改生效。

如果你遇到 URL 中出现编码不正确字符的问题，请参阅
[错误：使用反向代理时出现 `404 Not Found`](../../api/rest/troubleshooting.md#error-404-not-found-when-using-a-reverse-proxy)。

### 自定义 Redis 连接

如果你想连接到非标准端口上的 Redis 服务器或不同的主机，可以通过 `config/resque.yml` 文件配置其连接字符串。

```yaml
# 示例
production:
  url: redis://redis.example.tld:6379
```

如果你想通过套接字连接 Redis 服务器，请在 `config/resque.yml` 文件中使用 `unix:` URL 方案和 Redis 套接字文件的路径。

```yaml
# 示例
production:
  url: unix:/path/to/redis/socket
```

此外，你还可以在 `config/resque.yml` 文件中使用环境变量：

```yaml
# 示例
production:
  url: <%= ENV.fetch('GITLAB_REDIS_URL') %>
```

### 自定义 SSH 连接

如果你在非标准端口上运行 SSH，你必须更改极狐GitLab 用户的 SSH 配置。

```plaintext
# 添加到 /home/git/.ssh/config
host localhost          # 给你的设置起个名字（此处：覆盖 localhost）
    user git            # 你的远程 git 用户
    port 2222           # 你的端口号
    hostname 127.0.0.1; # 你的服务器名称或 IP
```

你还需要更改 `config/gitlab.yml` 文件中的相应选项（例如 `ssh_user`、`ssh_host`、`admin_uri`）。

### 额外的标记样式

除了始终支持的 Markdown 样式外，极狐GitLab 还可以显示其他富文本文件。但你可能需要安装依赖项才能实现。有关更多信息，请参阅 [`github-markup` gem README](https://github.com/gitlabhq/markup#markups)。

### Prometheus 服务器设置

你可以在 `config/gitlab.yml` 中配置 Prometheus 服务器：

```yaml
# 示例
prometheus:
  enabled: true
  server_address: '10.1.2.3:9090'
```

## 故障排除

### 消息：`你似乎克隆了一个空仓库。`

如果在尝试克隆极狐GitLab 托管的仓库时看到此消息，这很可能是由于 NGINX 或 Apache 配置过时，或者极狐GitLab Workhorse 实例缺失或配置错误。请仔细检查你是否已
[安装 Go](#4-go)、[安装极狐GitLab Workhorse](#install-gitlab-workhorse)，
并正确[配置了 NGINX](#site-configuration)。

### `google-protobuf` 错误：`LoadError: /lib/x86_64-linux-gnu/libc.so.6: version 'GLIBC_2.14' not found`

在某些平台的某些 `google-protobuf` gem 版本中可能会发生此问题。解决方法是安装此 gem 的纯源码版本。

首先，你必须找到你的极狐GitLab 安装所需的 `google-protobuf` 的确切版本：

```shell
cd /home/git/gitlab

# 以下两个命令中只有一个会输出内容。输出内容
# 类似于：* google-protobuf (3.2.0)
bundle list | grep google-protobuf
bundle check | grep google-protobuf
```

在以下命令中，以 `3.2.0` 为例。请将其替换为你先前找到的版本号：

```shell
cd /home/git/gitlab
sudo -u git -H gem install google-protobuf --version 3.2.0 --platform ruby
```

最后，你可以测试 `google-protobuf` 是否正确加载。以下命令应输出 `OK`。

```shell
sudo -u git -H bundle exec ruby -rgoogle/protobuf -e 'puts :OK'
```

如果 `gem install` 命令失败，你可能需要安装操作系统的开发者工具。

在 Debian/Ubuntu 上：

```shell
sudo apt-get install build-essential libgmp-dev
```

在 RedHat/CentOS 上：

```shell
sudo yum groupinstall 'Development Tools'
```

### 编译极狐GitLab 静态资源时出错

编译静态资源时，你可能会收到以下错误消息：

```plaintext
Killed
error Command failed with exit code 137.
```

这可能是由于 Yarn 终止了内存不足的容器。要解决此问题：

1. 将系统内存增加到至少 8 GB。
1. 运行此命令以清理静态资源：

   ```shell
   sudo -u git -H bundle exec rake gitlab:assets:clean RAILS_ENV=production NODE_ENV=production
   ```

1. 再次运行 `yarn` 命令以解决任何冲突：

   ```shell
   sudo -u git -H yarn install --production --pure-lockfile
   ```

1. 重新编译静态资源：

   ```shell
   sudo -u git -H bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production
   ```
