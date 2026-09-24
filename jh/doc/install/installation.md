---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 自编译安装
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: 私有化部署

{{< /details >}}

这是使用源文件设置生产极狐GitLab服务器的官方安装指南。它是为 **Debian/Ubuntu** 操作系统创建和测试的。阅读[要求](requirements.md) 以了解硬件和操作系统要求。如果您想在 RHEL/CentOS 上安装，应使用 [Linux 软件包](https://gitlab.cn/install/)。有关许多其他安装选项，请参阅[主安装页面](_index.md)。

以下步骤已知可行。**当您偏离此指南时要小心**。确保您不会违反极狐GitLab对其环境的任何假设。例如，许多人因为更改了目录的位置或以错误的用户身份运行服务而遇到权限问题。


<a id="consider-the-linux-package-installation"></a>

## 考虑 Linux 软件包安装

由于自编译安装工作量大且容易出错，我们强烈推荐快速可靠的 [Linux 软件包安装](https://gitlab.cn/install/)（deb/rpm）。

Linux 软件包更可靠的一个原因是它使用 runit 在极狐GitLab进程崩溃时重新启动任何极狐GitLab进程。在使用频繁的极狐GitLab实例中，Sidekiq 后台工作者的内存使用量会随着时间增长。Linux 软件包通过[允许 Sidekiq 优雅地终止](../administration/sidekiq/sidekiq_memory_killer.md)来解决此问题。终止后，runit 检测到 Sidekiq 未运行并启动它。由于自编译安装不使用 runit 进行进程监控，因此 Sidekiq 无法终止，其内存使用量会随着时间增长。

<a id="select-a-version-to-install"></a>

## 选择要安装的版本

确保您查看的是要安装的极狐GitLab版本的[此安装指南](https://gitlab.cn/install/)。您可以在极狐GitLab左上角的版本下拉列表中选择分支（在菜单栏下方）。

如果最高编号的稳定分支不明确，请查看[极狐GitLab博客](https://gitlab.cn/resources/articles/)以获取按版本排列的安装指南链接。

<a id="software-requirements"></a>

## 软件要求

| 软件                     | 最低版本  | 备注                                                                                                                                                            |
|:------------------------|:---------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Ruby](#2-ruby)         | `3.2.x`  | 在极狐GitLab 17.5及更高版本中，需要 Ruby 3.2。您必须使用标准 MRI 实现的 Ruby。我们喜爱 JRuby 和 Rubinius，但极狐GitLab需要几个具有本机扩展的 Gems。 |
| [RubyGems](#3-rubygems) | `3.5.x`  | 不需要特定的 RubyGems 版本，但您应该更新以从一些已知的性能改进中受益。 |
| [Go](#4-go)             | `1.22.x` | 在极狐GitLab 17.1及更高版本中，需要 Go 1.22 或更高版本。                                                                                                                                              |
| [Git](#git)             | `2.47.x` | 在极狐GitLab 17.7及更高版本中，需要 Git 2.47.x 和更高版本。您应该使用 [Gitaly 提供的 Git 版本](#git)。                                                                                          |
| [Node.js](#5-node)      | `20.13.x`| 在极狐GitLab 17.0及更高版本中，需要 Node.js 20.13 或更高版本。                                                                                                                                       |
| [PostgreSQL](#7-database)| `14.x`   | 在极狐GitLab 17.0及更高版本中，需要 PostgreSQL 14 或更高版本。                                                                                                                                       |

<a id="gitlab-directory-structure"></a>

## 极狐GitLab目录结构

在您执行安装步骤时，将创建以下目录：

```plaintext
|-- home
|   |-- git
|       |-- .ssh
|       |-- gitlab
|       |-- gitlab-shell
|       |-- repositories
```

- `/home/git/.ssh` - 包含 OpenSSH 设置。特别是由极狐GitLab Shell 管理的 `authorized_keys` 文件。
- `/home/git/gitlab` - 极狐GitLab核心软件。
- `/home/git/gitlab-shell` - 极狐GitLab 的核心附加组件。维护 SSH 克隆和其他功能。
- `/home/git/repositories` - 所有项目的裸库按命名空间组织。这是推送/拉取的 Git 仓库为所有项目维护的地方。**此区域包含项目的关键数据。[请备份](../administration/backup_restore/_index.md)。**

库的默认位置可以在极狐GitLab的 `config/gitlab.yml` 和极狐GitLab Shell 的 `config.yml` 中配置。

目前手动创建这些目录没有必要，这样做可能会导致安装过程中的错误。

有关更深入的概述，请参阅 [极狐GitLab 架构文档](../development/architecture.md)。

<a id="overview"></a>

## 概览

极狐GitLab的安装包括设置以下组件：

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

### sudo

Debian 默认未安装 `sudo`。确保您的系统是最新的并安装它。

```shell
# 以 root 身份运行！
apt-get update -y
apt-get upgrade -y
apt-get install sudo -y
```

### 构建依赖项

安装所需的软件包（需要编译 Ruby 和 Ruby gems 的本机扩展）：

```shell
sudo apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libre2-dev \
  libreadline-dev libncurses5-dev libffi-dev curl openssh-server libxml2-dev libxslt-dev \
  libcurl4-openssl-dev libicu-dev libkrb5-dev logrotate rsync python3-docutils pkg-config cmake \
  runit-systemd
```

{{< alert type="note" >}}

极狐GitLab需要 OpenSSL 版本 1.1。如果您的 Linux 发行版包含不同版本的 OpenSSL，您可能需要手动安装 1.1。

{{< /alert >}}

### Git

您应该使用 Gitaly 提供的 Git 版本，它：

- 总是处于极狐GitLab需要的版本。
- 可能包含正常操作所需的自定义补丁。

1. 安装所需的依赖项：

   ```shell
   sudo apt-get install -y libcurl4-openssl-dev libexpat1-dev gettext libz-dev libssl-dev libpcre2-dev build-essential git-core
   ```

1. 克隆 Gitaly 仓库并编译 Git。用您要安装的极狐GitLab版本匹配的稳定分支替换 `<X-Y-stable>`。例如，如果您想安装极狐GitLab 16.7，请使用分支名称 `16-7-stable`：

   ```shell
   git clone https://jihulab.com/gitlab-cn/gitaly.git -b <X-Y-stable> /tmp/gitaly
   cd /tmp/gitaly
   sudo make git GIT_PREFIX=/usr/local
   ```

1. 可选地，您可以移除系统 Git 及其依赖项：

   ```shell
   sudo apt remove -y git-core
   sudo apt autoremove
   ```

稍后在[编辑 `config/gitlab.yml`](#configure-it) 时，请记住更改 Git 路径：

- 从：

  ```yaml
  git:
    bin_path: /usr/bin/git
  ```

- 到：

  ```yaml
  git:
    bin_path: /usr/local/bin/git
  ```

### GraphicsMagick

为了让[自定义 Favicon](../administration/appearance.md#customize-the-favicon)正常工作，必须安装 GraphicsMagick。

```shell
sudo apt-get install -y graphicsmagick
```

### 邮件服务器

要接收邮件通知，请确保安装邮件服务器。Debian 默认附带 `exim4`，但这在 Ubuntu 中有问题，而 Ubuntu 没有附带邮件服务器。推荐的邮件服务器是 `postfix`，您可以用以下命令安装：

```shell
sudo apt-get install -y postfix
```

然后选择 'Internet Site' 并按 <kbd>Enter</kbd> 确认主机名。

### ExifTool

极狐GitLab Workhorse 需要 `exiftool` 来移除上传图片中的 EXIF 数据。

```shell
sudo apt-get install -y libimage-exiftool-perl
```

<a id="2-ruby"></a>

## 2. Ruby

极狐GitLab运行需要 Ruby 解释器。请参阅[要求部分](#software-requirements)以获取最低 Ruby 要求。

在生产环境中使用 Ruby 版本管理器，如 `RVM`、`rbenv` 或 `chruby` 时，极狐GitLab经常会遇到难以诊断的问题。不支持版本管理器，我们强烈建议大家按照以下说明使用系统 Ruby。

Linux 发行版通常提供旧版本的 Ruby，因此这些说明旨在从官方源代码安装 Ruby。

[安装 Ruby](https://www.ruby-lang.org/en/documentation/installation/)。

<a id="3-rubygems"></a>

## 3. RubyGems

有时，RubyGems 的更新版本比 Ruby 捆绑的版本更为需要。

要更新到特定版本：

```shell
gem update --system 3.4.12
```

或者更新到最新版本：

```shell
gem update --system
```

<a id="4-go"></a>

## 4. Go

极狐GitLab有几个用 Go 编写的守护进程。要安装极狐GitLab，我们需要一个 Go 编译器。下面的说明假设您使用的是 64 位 Linux。您可以在 [Go 下载页面](https://go.dev/dl/)上找到其他平台的下载。

```shell
# 移除旧的 Go 安装文件夹
sudo rm -rf /usr/local/go

curl --remote-name --location --progress-bar "https://go.dev/dl/go1.22.5.linux-amd64.tar.gz"
echo '904b924d435eaea086515bc63235b192ea441bd8c9b198c507e85009e6e4c7f0  go1.22.5.linux-amd64.tar.gz' | shasum -a256 -c - && \
  sudo tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz
sudo ln -sf /usr/local/go/bin/{go,gofmt} /usr/local/bin/
rm go1.22.5.linux-amd64.tar.gz
```

<a id="5-node"></a>

## 5. Node

极狐GitLab需要使用 Node 来编译 JavaScript 资产，并使用 Yarn 来管理 JavaScript 依赖项。当前的最低要求是：

- `node` 20.x 版本（v20.13.0 或更高版本）。Node.js 的其他 LTS 版本可能能够构建资产，但我们只保证 Node.js 20.x。
- `yarn` = v1.22.x（Yarn 2 尚不支持）

在许多发行版中，官方软件包库提供的版本已经过时，因此我们必须通过以下命令安装：

```shell
# 安装 node v20.x
curl --location "https://deb.nodesource.com/setup_20.x" | sudo bash -
sudo apt-get install -y nodejs

npm install --global yarn
```

如果您在这些步骤中遇到任何问题，请访问 node 和 yarn 的官方网站。

<a id="6-system-users"></a>

## 6. 系统用户

为极狐GitLab创建一个 `git` 用户：

```shell
sudo adduser --disabled-login --gecos 'GitLab' git
```

<a id="7-database"></a>

## 7. 数据库

{{< alert type="note" >}}

仅支持 PostgreSQL。在极狐GitLab 17.0及更高版本中，我们[要求 PostgreSQL 14+](requirements.md#postgresql)。

{{< /alert >}}

1. 安装数据库软件包。

   对于 Ubuntu 22.04 及更高版本：

   ```shell
   sudo apt install -y postgresql postgresql-client libpq-dev postgresql-contrib
   ```

   对于 Ubuntu 20.04 及更早版本，可用的 PostgreSQL 不满足最低版本要求。您必须添加 PostgreSQL 的存储库：

   ```shell
   sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
   wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
   sudo apt-get update
   sudo apt-get -y install postgresql-14
   ```

1. 验证您拥有的 PostgreSQL 版本是否受您要安装的极狐GitLab版本支持：

   ```shell
   psql --version
   ```

1. 启动 PostgreSQL 服务并确认该服务正在运行：

   ```shell
   sudo service postgresql start
   sudo service postgresql status
   ```

1. 为极狐GitLab创建一个数据库用户：

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

1. 创建极狐GitLab生产数据库并授予数据库上的所有权限：

   ```shell
   sudo -u postgres psql -d template1 -c "CREATE DATABASE gitlabhq_production OWNER git;"
   ```

1. 尝试使用新用户连接到新数据库：

   ```shell
   sudo -u git -H psql -d gitlabhq_production
   ```

1. 检查 `pg_trgm` 扩展是否已启用：

   ```sql
   SELECT true AS enabled
   FROM pg_available_extensions
   WHERE name = 'pg_trgm'
   AND installed_version IS NOT NULL;
   ```

   如果扩展已启用，则会产生以下输出：

   ```plaintext
   enabled
   ---------
    t
   (1 row)
   ```

1. 检查 `btree_gist` 扩展是否已启用：

   ```sql
   SELECT true AS enabled
   FROM pg_available_extensions
   WHERE name = 'btree_gist'
   AND installed_version IS NOT NULL;
   ```

   如果扩展已启用，则会产生以下输出：

   ```plaintext
   enabled
   ---------
    t
   (1 row)
   ```

1. 检查 `plpgsql` 扩展是否已启用：

   ```sql
   SELECT true AS enabled
   FROM pg_available_extensions
   WHERE name = 'plpgsql'
   AND installed_version IS NOT NULL;
   ```

   如果扩展已启用，则会产生以下输出：

   ```plaintext
   enabled
   ---------
    t
   (1 row)
   ```

1. 退出数据库会话：

   ```shell
   gitlabhq_production> \q
   ```

<a id="8-redis"></a>

## 8. Redis

请参阅[要求页面](requirements.md#redis)以获取最低 Redis 要求。

通过以下命令安装 Redis：

```shell
sudo apt-get install redis-server
```

完成后，您可以配置 Redis：

```shell
# 配置 redis 使用套接字
sudo cp /etc/redis/redis.conf /etc/redis/redis.conf.orig

# 通过将 'port' 设置为 0 来禁用 Redis 在 TCP 上监听
sudo sed 's/^port .*/port 0/' /etc/redis/redis.conf.orig | sudo tee /etc/redis/redis.conf

# 为默认 Debian / Ubuntu 路径启用 Redis 套接字
echo 'unixsocket /var/run/redis/redis.sock' | sudo tee -a /etc/redis/redis.conf

# 授予套接字对 redis 组的所有成员的权限
echo 'unixsocketperm 770' | sudo tee -a /etc/redis/redis.conf

# 将 git 添加到 redis 组
sudo usermod -aG redis git
```

### 使用 systemd 监督 Redis

如果您的发行版使用 systemd init，并且以下命令的输出为 `notify`，则无需进行任何更改：

```shell
systemctl show --value --property=Type redis-server.service
```

如果输出**不是** `notify`，请运行：

```shell
# 配置 Redis 不作为守护进程，而是由 systemd 监督，并禁用 pidfile
sudo sed -i \
         -e 's/^daemonize yes$/daemonize no/' \
         -e 's/^supervised no$/supervised systemd/' \
         -e 's/^pidfile/# pidfile/' /etc/redis/redis.conf
sudo chown redis:redis /etc/redis/redis.conf

# 对 systemd 单元文件进行相同的更改
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

### 让 Redis 不受监督

如果您的系统使用 SysV init，请运行这些命令：

```shell
# 创建包含套接字的目录
sudo mkdir -p /var/run/redis
sudo chown redis:redis /var/run/redis
sudo chmod 755 /var/run/redis

# 保留包含套接字的目录（如果适用）
if [ -d /etc/tmpfiles.d ]; then
  echo 'd  /var/run/redis  0755  redis  redis  10d  -' | sudo tee -a /etc/tmpfiles.d/redis.conf
fi

# 激活对 redis.conf 的更改
sudo service redis-server restart
```

<a id="9-gitlab"></a>

## 9. 极狐GitLab

```shell
# 我们将极狐GitLab安装到用户 "git" 的主目录中
cd /home/git
```

### 克隆源码

克隆极狐版：

```shell
# 克隆极狐GitLab仓库
sudo -u git -H git clone https://jihulab.com/gitlab-cn/gitlab.git -b <X-Y-stable-jh> gitlab
```

请务必用您要安装的版本匹配的稳定分支替换 `<X-Y-stable-jh>`。例如，如果您想安装 18.8，您将使用分支名称 `18-8-stable-jh`。

{{< alert type="warning" >}}

如果您希望安装 *前沿* 版本，可以将 `<X-Y-stable-jh>` 更改为 `main-jh`，但绝不要在生产服务器上安装 `main-jh`！

{{< /alert >}}

### 配置

```shell
# 转到极狐GitLab安装文件夹
cd /home/git/gitlab

# 复制示例极狐GitLab配置
sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml

# 更新极狐GitLab配置文件，按照文件顶部的说明进行操作
sudo -u git -H editor config/gitlab.yml

# 复制示例密钥文件
sudo -u git -H cp config/secrets.yml.example config/secrets.yml
sudo -u git -H chmod 0600 config/secrets.yml

# 确保极狐GitLab可以写入日志和临时目录
sudo chown -R git log/
sudo chown -R git tmp/
sudo chmod -R u+rwX,go-w log/
sudo chmod -R u+rwX tmp/

# 确保极狐GitLab可以写入 tmp/pids 和 tmp/sockets 目录
sudo chmod -R u+rwX tmp/pids/
sudo chmod -R u+rwX tmp/sockets/

# 创建 public/uploads 目录
sudo -u git -H mkdir -p public/uploads/

# 确保只有极狐GitLab用户可以访问 public/uploads 目录，因为现在 public/uploads 中的文件由 gitlab-workhorse 提供服务
sudo chmod 0700 public/uploads

# 更改存储 CI 作业日志的目录的权限
sudo chmod -R u+rwX builds/

# 更改存储 CI 产物的目录的权限
sudo chmod -R u+rwX shared/artifacts/

# 更改存储极狐GitLab Pages 的目录的权限
sudo chmod -R ug+rwX shared/pages/

# 复制示例 Puma 配置
sudo -u git -H cp config/puma.rb.example config/puma.rb

# 请参考 https://github.com/puma/puma#configuration 以获取更多信息。您应该根据可用的 CPU 核心数量来扩展 Puma 工作者和线程。您可以通过 `nproc` 命令获取该数量。
sudo -u git -H editor config/puma.rb

# 配置 Redis 连接设置
sudo -u git -H cp config/resque.yml.example config/resque.yml
sudo -u git -H cp config/cable.yml.example config/cable.yml

# 如果您未使用默认的 Debian / Ubuntu 配置，请更改 Redis 套接字路径
sudo -u git -H editor config/resque.yml config/cable.yml
```

请确保编辑 `gitlab.yml` 和 `puma.rb` 以匹配您的设置。

如果您想使用 HTTPS，请参阅[使用 HTTPS](#using-https)以获取其他步骤。

### 配置极狐GitLab数据库设置

{{< alert type="note" >}}

从极狐GitLab 15.9开始，仅带有一个部分：`main:` 的 `database.yml` 已被弃用。在极狐GitLab 17.0及更高版本中，您的 `database.yml` 中必须包含 `main:` 和 `ci:` 两个部分。

{{< /alert >}}

```shell
sudo -u git cp config/database.yml.postgresql config/database.yml

# 从 config/database.yml 中移除 host、username 和 password 行。修改后，`production` 设置如下：
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
# 更新 config/database.yml 中的用户名/密码。您只需调整生产设置（第一部分）。如果您遵循了数据库指南，请按以下步骤操作：
# 将 'secure password' 更改为您给 $password 的值。您可以保留密码周围的双引号。
sudo -u git -H editor config/database.yml

# 在 config/database.yml 中取消注释 `ci:` 部分。
# 确保 `ci:` 中的 `database` 值与 `main:` 中的数据库值匹配。

# 使 config/database.yml 仅对 git 可读
sudo -u git -H chmod o-rwx config/database.yml
```

您应该在 `database.yml` 中有两个部分：`main:` 和 `ci:`。`ci:` 连接[必须连接到同一个数据库](../administration/postgresql/multiple_databases.md)。

### 安装 Gems

{{< alert type="note" >}}

从 Bundler 1.5.2 开始，您可以调用 `bundle install -jN`（其中 `N` 是您的处理器核心数量）并享受并行 Gems 安装，完成时间有显著差异（快约 60%）。通过 `nproc` 检查您的核心数量。有关更多信息，请参阅此[文章](https://thoughtbot.com/blog/parallel-gem-installing-using-bundler)。

{{< /alert >}}

确保您有 `bundle`（运行 `bundle -v`）：

- `>= 1.5.2`，因为某些问题，已在 1.5.2 中修复。
- `< 2.x`。

安装 Gems（如果您想使用 Kerberos 进行用户身份验证，请在下面的 `--without` 选项中省略 `kerberos`）：

```shell
sudo -u git -H bundle config set --local deployment 'true'
sudo -u git -H bundle config set --local without 'development test kerberos'
sudo -u git -H bundle config path /home/git/gitlab/vendor/bundle
sudo -u git -H bundle install
```

### 安装极狐GitLab Shell

极狐GitLab Shell 是专为极狐GitLab开发的 SSH 访问和仓库管理软件。

```shell
# 运行 gitlab-shell 的安装任务：
sudo -u git -H bundle exec rake gitlab:shell:install RAILS_ENV=production

# 默认情况下，gitlab-shell 配置是从您的主极狐GitLab配置生成的。
# 您可以查看（并修改）gitlab-shell 配置如下：
sudo -u git -H editor /home/git/gitlab-shell/config.yml
```

如果您想使用 HTTPS，请参阅[使用 HTTPS](#using-https)以获取其他步骤。

请确保您的主机名可以通过适当的 DNS 记录或 `/etc/hosts` 中的附加行（"127.0.0.1 hostname"）在机器本身上解析。例如，如果您在反向代理后设置极狐GitLab，这可能是必要的。如果主机名无法解析，最终的安装检查会失败并显示 `Check GitLab API access: FAILED. code: 401`，并且推送提交会被拒绝并显示 `[remote rejected] master -> master (hook declined)`。

### 安装极狐GitLab Workhorse

极狐GitLab-Workhorse 使用 GNU Make。以下命令行在推荐位置 `/home/git/gitlab-workhorse` 中安装极狐GitLab-Workhorse。

```shell
sudo -u git -H bundle exec rake "gitlab:workhorse:install[/home/git/gitlab-workhorse]" RAILS_ENV=production
```

您可以通过提供额外参数来指定不同的 Git 仓库：

```shell
sudo -u git -H bundle exec rake "gitlab:workhorse:install[/home/git/gitlab-workhorse,https://example.com/gitlab-workhorse.git]" RAILS_ENV=production
```

### 安装极狐GitLab-Elasticsearch-indexer

{{< details >}}

- Tier: Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

极狐GitLab-Elasticsearch-Indexer 使用 GNU Make。以下命令行在推荐位置 `/home/git/gitlab-elasticsearch-indexer` 中安装极狐GitLab-Elasticsearch-Indexer。

```shell
sudo -u git -H bundle exec rake "gitlab:indexer:install[/home/git/gitlab-elasticsearch-indexer]" RAILS_ENV=production
```

您可以通过提供额外参数来指定不同的 Git 仓库：

```shell
sudo -u git -H bundle exec rake "gitlab:indexer:install[/home/git/gitlab-elasticsearch-indexer,https://example.com/gitlab-elasticsearch-indexer.git]" RAILS_ENV=production
```

源代码首先被提取到第一个参数指定的路径。然后在其 `bin` 目录下构建一个二进制文件。然后您必须更新 `gitlab.yml` 的 `production -> elasticsearch -> indexer_path` 设置以指向该二进制文件。

### 安装极狐GitLab Pages

极狐GitLab Pages 使用 GNU Make。此步骤是可选的，仅在您希望从极狐GitLab中托管静态网站时才需要。以下命令在 `/home/git/gitlab-pages` 中安装极狐GitLab Pages。

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

# 使用 Git 获取 Gitaly 源代码并使用 Go 编译
cd /home/git/gitlab
sudo -u git -H bundle exec rake "gitlab:gitaly:install[/home/git/gitaly,/home/git/repositories]" RAILS_ENV=production
```

您可以通过提供额外参数来指定不同的 Git 仓库：

```shell
sudo -u git -H bundle exec rake "gitlab:gitaly:install[/home/git/gitaly,/home/git/repositories,https://example.com/gitaly.git]" RAILS_ENV=production
```

接下来，确保 Gitaly 已配置：

```shell
# 限制对 Gitaly 套接字的访问
sudo chmod 0700 /home/git/gitlab/tmp/sockets/private
sudo chown git /home/git/gitlab/tmp/sockets/private

# 如果您使用非默认设置，则需要更新 config.toml
cd /home/git/gitaly
sudo -u git -H editor config.toml
```

有关配置 Gitaly 的更多信息，请参阅[Gitaly 文档](../administration/gitaly/_index.md)。

### 安装服务

极狐GitLab始终支持 SysV init 脚本，这些脚本被广泛支持且具有可移植性，但现在 systemd 是服务监控的标准，所有主要的 Linux 发行版都在使用它。如果可以，您应该使用本地 systemd 服务以受益于自动重启、更好的沙盒和资源控制。

#### 安装 systemd 单元

如果您使用 systemd 作为 init，请使用这些步骤。否则，请按照 [SysV init 脚本步骤](#install-sysv-init-script)。

复制服务并运行 `systemctl daemon-reload` 以便 systemd 识别它们：

```shell
cd /home/git/gitlab
sudo mkdir -p /usr/local/lib/systemd/system
sudo cp lib/support/systemd/* /usr/local/lib/systemd/system/
sudo systemctl daemon-reload
```

极狐GitLab提供的单元对您运行 Redis 和 PostgreSQL 的位置几乎没有假设。

如果您在另一台机器上运行极狐GitLab，您应该：

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

`systemctl edit` 在 `/etc/systemd/system/<name of the unit>.d/override.conf` 处安装了分段配置文件，因此您的本地配置在以后更新单元文件时不会被覆盖。要分割您的分段配置文件，您可以将上述片段添加到 `/etc/systemd/system/<name of the unit>.d/` 下的 `.conf` 文件中。

如果您手动更改了单元文件或添加了分段配置文件（未使用 `systemctl edit`），请运行以下命令以使其生效：

```shell
sudo systemctl daemon-reload
```

使极狐GitLab在启动时启动：

```shell
sudo systemctl enable gitlab.target
```

#### 安装 SysV init 脚本

如果您使用 SysV init 脚本，请使用这些步骤。如果您使用 systemd，请按照 [systemd 单元步骤](#install-systemd-units)。

下载 init 脚本（路径为 `/etc/init.d/gitlab`）：

```shell
cd /home/git/gitlab
sudo cp lib/support/init.d/gitlab /etc/init.d/gitlab
```

如果您使用非默认文件夹或用户进行安装，请复制并编辑默认文件：

```shell
sudo cp lib/support/init.d/gitlab.default.example /etc/default/gitlab
```

如果您在其他目录或非默认用户下安装极狐GitLab，您应该在 `/etc/default/gitlab` 中更改这些设置。请勿编辑 `/etc/init.d/gitlab`，因为它在升级时会更改。

使极狐GitLab在启动时启动：

```shell
sudo update-rc.d gitlab defaults 21
# 或者如果在运行 systemd 的机器上运行此命令
sudo systemctl daemon-reload
sudo systemctl enable gitlab.service
```

### 设置 Logrotate

```shell
sudo cp lib/support/logrotate/gitlab /etc/logrotate.d/gitlab
```

### 启动 Gitaly

Gitaly 必须在下一节中运行。

- 要使用 systemd 启动 Gitaly：

  ```shell
  sudo systemctl start gitlab-gitaly.service
  ```

- 要手动为 SysV 启动 Gitaly：

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
# 输入 'yes' 以创建数据库表。

# 或者您可以通过添加 force=yes 来跳过问题
sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production force=yes

# 完成后，您将看到 'Administrator account created:'
```

您可以通过在环境变量 `GITLAB_ROOT_PASSWORD` 和 `GITLAB_ROOT_EMAIL` 中提供来设置管理员/root 密码和电子邮件，如下所示。如果您不设置密码（并且设置为默认密码），请在安装完成并首次登录服务器之前，不要将极狐GitLab暴露给公众互联网。在第一次登录期间，您被强制更改默认密码。通过在 `GITLAB_ACTIVATION_CODE` 环境变量中提供激活码，可以在此时激活极狐GitLab 订阅。

```shell
sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production GITLAB_ROOT_PASSWORD=yourpassword GITLAB_ROOT_EMAIL=youremail GITLAB_ACTIVATION_CODE=yourcode
```

### 确保 `secrets.yml` 安全

`secrets.yml` 文件存储会话和安全变量的加密密钥。将 `secrets.yml` 备份到安全的地方，但不要将其存储在与数据库备份相同的位置。否则，如果您的备份之一被泄露，您的密钥将会暴露。

### 检查应用程序状态

检查极狐GitLab及其环境是否配置正确：

```shell
sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production
```

### 编译资产

```shell
sudo -u git -H yarn install --production --pure-lockfile
sudo -u git -H bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production
```

如果 `rake` 失败并出现 `JavaScript heap out of memory` 错误，请尝试按以下方式设置 `NODE_OPTIONS` 运行。

```shell
sudo -u git -H bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production NODE_OPTIONS="--max_old_space_size=4096"
```

### 启动您的极狐GitLab实例

```shell
# 对于运行 systemd 的系统
sudo systemctl start gitlab.target

# 对于运行 SysV init 的系统
sudo service gitlab start
```

<a id="10-nginx"></a>

## 10. NGINX

NGINX 是极狐GitLab的官方支持的 Web 服务器。

### 安装

```shell
sudo apt-get install -y nginx
```

### 站点配置

复制示例站点配置：

```shell
sudo cp lib/support/nginx/gitlab /etc/nginx/sites-available/gitlab
sudo ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab
```

确保编辑配置文件以匹配您的设置。还要确保您的极狐GitLab路径匹配，特别是如果为非 `git` 用户安装：

```shell
# 将 YOUR_SERVER_FQDN 更改为为您的主机提供服务的极狐GitLab的完全限定域名。
#
# 请记住将您的路径与极狐GitLab匹配，特别是
# 如果为非 'git' 用户安装。
#
# 如果使用 Ubuntu 默认 nginx 安装：
# 要么从监听行中删除 default_server，
# 要么执行 sudo rm -f /etc/nginx/sites-enabled/default
sudo editor /etc/nginx/sites-available/gitlab
```

如果您打算启用极狐GitLab Pages，需要使用单独的 NGINX 配置。请阅读[极狐GitLab Pages 管理指南](../administration/pages/_index.md)中所需的配置。

如果您想使用 HTTPS，请用 `gitlab-ssl` 替换 `gitlab` NGINX 配置。有关 HTTPS 配置的详细信息，请参阅[使用 HTTPS](#using-https)。

为了让 NGINX 能够读取极狐GitLab-Workhorse 套接字，您必须确保 `www-data` 用户可以读取由极狐GitLab用户拥有的套接字。可以通过将其设置为世界可读，例如权限为 `0755`，这是默认的。`www-data` 还必须能够列出父目录。

### 测试配置

使用以下命令验证您的 `gitlab` 或 `gitlab-ssl` NGINX 配置文件：

```shell
sudo nginx -t
```

您应该收到 `syntax is okay` 和 `test is successful` 消息。如果您收到错误消息，请检查您的 `gitlab` 或 `gitlab-ssl` NGINX 配置文件中是否有拼写错误，如提供的错误消息所示。

验证安装的版本是否大于 1.12.1：

```shell
nginx -v
```

如果较低，您可能会收到以下错误：

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

<a id="post-install"></a>

## 安装后

### 仔细检查应用程序状态

为了确保您没有遗漏任何东西，请通过以下方式运行更彻底的检查：

```shell
sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production
```

如果所有项目都为绿色，恭喜您成功安装了极狐GitLab！

{{< alert type="note" >}}

为 `gitlab:check` 提供 `SANITIZE=true` 环境变量，以从检查命令的输出中省略项目名称。

{{< /alert >}}

### 初次登录

在您的网络浏览器中访问您的服务器以进行首次极狐GitLab登录。

如果您在[设置过程中没有提供 root 密码](#initialize-database-and-activate-advanced-features)，您将被重定向到密码重置屏幕以提供初始管理员帐户的密码。输入您想要的密码，您将被重定向回登录屏幕。

默认帐户的用户名是 **root**。提供您之前创建的密码并登录。登录后，您可以根据需要更改用户名。

**享受吧！**

要启动和停止极狐GitLab时使用：

- systemd 单元：使用 `sudo systemctl start gitlab.target` 或 `sudo systemctl stop gitlab.target`。
- SysV init 脚本：使用 `sudo service gitlab start` 或 `sudo service gitlab stop`。

### 推荐的后续步骤

完成安装后，请考虑采取[推荐的后续步骤](next_steps.md)，包括认证选项和注册限制。

<a id="advanced-setup-tips"></a>

## 高级设置提示

### 相对 URL 支持

有关如何使用相对 URL 配置极狐GitLab的更多信息，请参阅[相对 URL 文档](relative_url.md)。

### 使用 HTTPS

要使用极狐GitLab的 HTTPS：

1. 在 `gitlab.yml` 中：
   1. 将第 1 节中的 `port` 选项设置为 `443`。
   1. 将第 1 节中的 `https` 选项设置为 `true`。
1. 在极狐GitLab Shell 的 `config.yml` 中：
   1. 将 `gitlab_url` 选项设置为极狐GitLab 的 HTTPS 端点（例如，`https://git.example.com`）。
   1. 使用 `ca_file` 或 `ca_path` 选项设置证书。
1. 使用 `gitlab-ssl` NGINX 示例配置而不是 `gitlab` 配置。
   1. 更新 `YOUR_SERVER_FQDN`。
   1. 更新 `ssl_certificate` 和 `ssl_certificate_key`。
   1. 检查配置文件并考虑应用其他安全和性能增强功能。

不建议使用自签名证书。如果您必须使用自签名证书，请按照标准说明生成自签名 SSL 证书：

   ```shell
   mkdir -p /etc/nginx/ssl/
   cd /etc/nginx/ssl/
   sudo openssl req -newkey rsa:2048 -x509 -nodes -days 3560 -out gitlab.crt -keyout gitlab.key
   sudo chmod o-r gitlab.key
   ```

<a id="enable-reply-by-email"></a>

### 启用通过电子邮件回复

有关如何设置此功能的更多信息，请参阅["通过电子邮件回复"文档](../administration/reply_by_email.md)。

<a id="ldap-authentication"></a>

### LDAP 认证

您可以在 `config/gitlab.yml` 中配置 LDAP 认证。编辑此文件后重启极狐GitLab。

<a id="using-custom-omniauth-providers"></a>

### 使用自定义 OmniAuth 提供程序

请参阅 [OmniAuth 集成文档](../integration/omniauth.md)。

<a id="build-your-projects"></a>

### 构建您的项目

极狐GitLab 可以构建您的项目。要启用此功能，您需要 runner 来为您执行。请参阅 [极狐GitLab Runner 部分](https://gitlab.cn/docs/runner/)以安装它。

<a id="adding-your-trusted-proxies"></a>

### 添加您的受信任代理

如果您在单独的机器上使用反向代理，您可能需要将代理添加到受信任代理列表中。否则，用户会显示为从代理的 IP 地址登录。

您可以通过在 `config/gitlab.yml` 中自定义 `trusted_proxies` 选项来添加受信任代理。保存文件并[重新配置极狐GitLab](../administration/restart_gitlab.md)以使更改生效。

如果您在 URL 中遇到字符编码不正确的问题，请参阅[使用反向代理时的错误：`404 Not Found`](../api/rest/troubleshooting.md#error-404-not-found-when-using-a-reverse-proxy)。

<a id="custom-redis-connection"></a>

### 自定义 Redis 连接

如果您想连接到非标准端口或不同主机上的 Redis 服务器，您可以通过 `config/resque.yml` 文件配置其连接字符串。

```yaml
# 示例
production:
  url: redis://redis.example.tld:6379
```

如果您想通过套接字连接 Redis 服务器，请在 `config/resque.yml` 文件中使用 `unix:` URL 方案和 Redis 套接字文件的路径。

```yaml
# 示例
production:
  url: unix:/path/to/redis/socket
```

此外，您还可以在 `config/resque.yml` 文件中使用环境变量：

```yaml
# 示例
production:
  url: <%= ENV.fetch('GITLAB_REDIS_URL') %>
```

<a id="custom-ssh-connection"></a>

### 自定义 SSH 连接

如果您在非标准端口上运行 SSH，则必须更改极狐GitLab 用户的 SSH 配置。

```plaintext
# 添加到 /home/git/.ssh/config
host localhost          # 给您的设置起一个名称（这里：覆盖 localhost）
    user git            # 您的远程 git 用户
    port 2222           # 您的端口号
    hostname 127.0.0.1; # 您的服务器名称或 IP
```

您还必须更改 `config/gitlab.yml` 文件中的相应选项（例如，`ssh_user`、`ssh_host`、`admin_uri`）。

<a id="additional-markup-styles"></a>

### 其他标记样式

除了始终支持的 Markdown 样式外，极狐GitLab 还可以显示其他富文本文件。但您可能需要安装依赖项才能实现这一点。有关更多信息，请参阅`github-markup` gem README。

<a id="prometheus-server-setup"></a>

### Prometheus 服务器设置

您可以在 `config/gitlab.yml` 中配置 Prometheus 服务器：

```yaml
# 示例
prometheus:
  enabled: true
  server_address: '10.1.2.3:9090'
```

<a id="troubleshooting"></a>

## 疑难解答

<a id="you-appear-to-have-cloned-an-empty-repository"></a>

### "您似乎克隆了一个空的仓库。"

如果您在尝试克隆由极狐GitLab 托管的仓库时看到此消息，这可能是由于 NGINX 或 Apache 配置过时，或者缺少或配置错误的极狐GitLab Workhorse 实例。请仔细检查您是否已[安装 Go](#4-go)、[安装极狐GitLab Workhorse](#install-gitlab-workhorse)，并正确[配置 NGINX](#site-configuration)。

<a id="google-protobuf-loaderror-lib-x86_64-linux-gnu-libc-so-6-version-glibc_2-14-not-found"></a>

### `google-protobuf` "LoadError: /lib/x86_64-linux-gnu/libc.so.6: 版本 'GLIBC_2.14' 未找到"

在某些平台上，这可能发生在某些版本的 `google-protobuf` gem 上。解决方法是安装此 gem 的仅源代码版本。

首先，您必须找到您的极狐GitLab 安装所需的 `google-protobuf` 的确切版本：

```shell
cd /home/git/gitlab

# 以下两个命令中只有一个会打印内容。
# 它看起来像：* google-protobuf (3.2.0)
bundle list | grep google-protobuf
bundle check | grep google-protobuf
```

下面以 `3.2.0` 为例。用您在上面找到的版本号替换它：

```shell
cd /home/git/gitlab
sudo -u git -H gem install google-protobuf --version 3.2.0 --platform ruby
```

最后，您可以测试 `google-protobuf` 是否正确加载。以下内容应打印 'OK'。

```shell
sudo -u git -H bundle exec ruby -rgoogle/protobuf -e 'puts :OK'
```

如果 `gem install` 命令失败，您可能需要安装操作系统的开发工具。

在 Debian/Ubuntu 上：

```shell
sudo apt-get install build-essential libgmp-dev
```

在 RedHat/CentOS 上：

```shell
sudo yum groupinstall 'Development Tools'
```

<a id="error-compiling-gitlab-assets"></a>

### 编译极狐GitLab 资产时出错

在编译资产时，您可能会收到以下错误消息：

```plaintext
Killed
error Command failed with exit code 137.
```

当 Yarn 终止一个内存不足的容器时，可能会发生这种情况。要解决此问题：

1. 将系统内存增加到至少 8 GB。

1. 运行此命令以清理资产：

   ```shell
   sudo -u git -H bundle exec rake gitlab:assets:clean RAILS_ENV=production NODE_ENV=production
   ```

1. 再次运行 `yarn` 命令以解决任何冲突：

   ```shell
   sudo -u git -H yarn install --production --pure-lockfile
   ```

1. 重新编译资产：

   ```shell
   sudo -u git -H bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production
   ```
