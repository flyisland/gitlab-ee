---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 升级自编译实例
description: 升级单节点自编译实例。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

将自编译实例升级到较新版本的极狐GitLab。

<a id="prerequisites"></a>

## 先决条件

在升级之前：

1. 您必须[阅读所需信息并执行所需步骤](plan_your_upgrade.md)。
1. 查看针对 Ruby、Node.js、Go 和 PostgreSQL 的[软件要求](../install/self_compiled/_index.md#software-requirements)。

<a id="upgrade-a-self-compiled-instance"></a>

## 升级自编译实例

要升级自编译实例：

1. 考虑在升级过程中[启用维护模式](../administration/maintenance_mode/_index.md)。
1. [暂停正在运行的 CI/CD 流水线和作业](plan_your_upgrade.md#pause-cicd-pipelines-and-jobs)。
1. [将极狐GitLab Runner 升级](https://gitlab.cn/docs/runner/install/)到与目标极狐GitLab 版本相同的版本。
1. 按照本页说明升级极狐GitLab。

升级后：

1. 取消暂停[正在运行的 CI/CD 流水线和作业](plan_your_upgrade.md#pause-cicd-pipelines-and-jobs)。
1. 如果已启用，[关闭维护模式](../administration/maintenance_mode/_index.md#disable-maintenance-mode)。
1. 运行[升级健康检查](plan_your_upgrade.md#run-upgrade-health-checks)。

<a id="create-a-backup"></a>

### 创建备份

先决条件：

- 确保已安装 `rsync`。

要创建备份：

```shell
cd /home/git/gitlab

sudo -u git -H bundle exec rake gitlab:backup:create RAILS_ENV=production
```

<a id="stop-gitlab"></a>

### 停止极狐GitLab

要停止极狐GitLab：

```shell
# 对于运行 systemd 的系统
sudo systemctl stop gitlab.target

# 对于运行 SysV init 的系统
sudo service gitlab stop
```

<a id="update-ruby"></a>

### 更新 Ruby

如果需要较新版本的 Ruby，您必须更新 Ruby：

1. 要检查您拥有的 Ruby 版本，请运行：

   ```shell
   ruby -v
   ```

1. 有关更新到较新版本 Ruby 的说明，请参见[Ruby 安装说明](https://www.ruby-lang.org/en/documentation/installation/)。

<a id="update-nodejs"></a>

### 更新 Node.js

如果需要较新版本的 Node.js，您必须更新 Node.js：

1. 要检查您拥有的 Node.js 版本，请运行：

   ```shell
   node -v
   ```

1. 有关更新到较新版本 Node.js 的说明，请参见[Node.js 下载说明](https://nodejs.org/en/download)。

极狐GitLab 还需要 Yarn `>= v1.10.0` 来管理 JavaScript 依赖项。更多信息，请参见[Yarn 网站](https://classic.yarnpkg.com/en/docs/install)。

<a id="update-go"></a>

### 更新 Go

如果需要较新版本的 Go，您必须更新 Go：

1. 要检查您拥有的 Go 版本，请运行：

   ```shell
   go version
   ```

1. 有关更新到较新版本 Go 的说明，请参见[Go 安装说明](https://go.dev/doc/install)。

<a id="update-git"></a>

### 更新 Git

您应该使用 Gitaly 提供的 Git 版本。更多信息，请参见[极狐GitLab 安装说明中的 Git 部分](../install/self_compiled/_index.md#git)。

<a id="update-postgresql"></a>

### 更新 PostgreSQL

如果需要较新版本的 PostgreSQL，您必须更新 PostgreSQL：

1. 要检查您拥有的 PostgreSQL 版本，请运行：

   ```shell
   pg_ctl --version
   ```

1. 有关更新到较新版本 PostgreSQL 的说明，请参见[PostgreSQL 升级文档](https://www.postgresql.org/docs/16/upgrading.html)。
1. 确保您具有所需的[PostgreSQL 扩展](../install/requirements.md#postgresql)。

<a id="update-the-gitlab-codebase"></a>

### 更新极狐GitLab 代码库

要更新极狐GitLab 代码库的克隆：

1. 获取仓库元数据：

   ```shell
   cd /home/git/gitlab

   sudo -u git -H git fetch --all --prune
   sudo -u git -H git checkout -- Gemfile.lock db/structure.sql locale
   ```

1. 检出您要升级到的版本的分支：

   {{< tabs >}}

   {{< tab title="极狐GitLab 企业版" >}}

   ```shell
   cd /home/git/gitlab

   sudo -u git -H git checkout <BRANCH-ee>
   ```

   {{< /tab >}}

   {{< tab title="极狐GitLab 基础版" >}}

   ```shell
   cd /home/git/gitlab

   sudo -u git -H git checkout <BRANCH>
   ```

   {{< /tab >}}

   {{< /tabs >}}

<a id="update-configuration-files"></a>

### 更新配置文件

极狐GitLab 升级可能需要更新以下配置：

- `gitlab.yml`
- `database.yml`
- NGINX（或 Apache）
- SMTP
- systemd
- SysV

以下章节介绍了如何确定是否需要配置更新。

<a id="new-configuration-for-gitlabyml"></a>

#### `gitlab.yml` 的新配置

可能存在可用的新配置选项，针对
[`gitlab.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/config/gitlab.yml.example)。

1. 查看可能的新配置：

   ```shell
   cd /home/git/gitlab
   git diff origin/PREVIOUS_BRANCH:config/gitlab.yml.example origin/BRANCH:config/gitlab.yml.example
   ```

1. 手动将新配置应用到您当前的 `gitlab.yml`。

<a id="new-configuration-for-databaseyml"></a>

#### `database.yml` 的新配置

{{< history >}}

- 在极狐GitLab 16.0 中更改，增加了`ci:`部分在`config/database.yml.postgresql`中。

{{< /history >}}

可能存在可用的新配置选项，针对
[`database.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/config/database.yml.postgresql)。

1. 查看可能的新配置：

   ```shell
   cd /home/git/gitlab
   git diff origin/PREVIOUS_BRANCH:config/database.yml.postgresql origin/BRANCH:config/database.yml.postgresql
   ```

1. 手动将新配置应用到您当前的 `database.yml`。

<a id="new-configuration-for-nginx-or-apache"></a>

#### NGINX 或 Apache 的新配置

确保您仍然与最新的 NGINX 配置更改保持同步：

```shell
cd /home/git/gitlab

# 对于 HTTPS 配置
git diff origin/PREVIOUS_BRANCH:lib/support/nginx/gitlab-ssl origin/BRANCH:lib/support/nginx/gitlab-ssl

# 对于 HTTP 配置
git diff origin/PREVIOUS_BRANCH:lib/support/nginx/gitlab origin/BRANCH:lib/support/nginx/gitlab
```

极狐GitLab 应用程序不再在您的安装中设置 Strict-Transport-Security。您必须在 NGINX 配置中启用它才能继续使用。

如果您使用的是 Apache 而不是 NGINX，请参见更新后的 [Apache 模板](https://jihulab.com/gitlab-cn/gitlab-recipes/tree/master/web-server/apache)。
因为 Apache 不支持 Unix 套接字后的 upstream，您必须让极狐GitLab Workhorse 在 TCP 端口上监听，通过
使用[`/etc/default/gitlab`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/support/init.d/gitlab.default.example#L38)。

<a id="smtp-configuration"></a>

#### SMTP 配置

如果您使用 SMTP 发送邮件，您必须在 `config/initializers/smtp_settings.rb` 中添加以下行：

```ruby
ActionMailer::Base.delivery_method = :smtp
```

参见[`smtp_settings.rb.sample`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/config/initializers/smtp_settings.rb.sample#L13)
中的示例。

<a id="configure-systemd-units"></a>

#### 配置 systemd 单元

1. 检查 systemd 单元是否已更新：

   ```shell
   cd /home/git/gitlab

   git diff origin/PREVIOUS_BRANCH:lib/support/systemd origin/BRANCH:lib/support/systemd
   ```

1. 复制它们：

   ```shell
   sudo mkdir -p /usr/local/lib/systemd/system
   sudo cp lib/support/systemd/* /usr/local/lib/systemd/system/
   sudo systemctl daemon-reload
   ```

<a id="configure-sysv-init-script"></a>

#### 配置 SysV init 脚本

可能存在可用的新配置选项，针对
[`gitlab.default.example`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/support/init.d/gitlab.default.example)。

1. 查看可能的新配置：

   ```shell
   cd /home/git/gitlab

   git diff origin/PREVIOUS_BRANCH:lib/support/init.d/gitlab.default.example origin/BRANCH:lib/support/init.d/gitlab.default.example
   ```

1. 手动将它们应用到您当前的 `/etc/default/gitlab`。

确保您仍然与最新的 init 脚本更改保持同步：

```shell
cd /home/git/gitlab

sudo cp lib/support/init.d/gitlab /etc/init.d/gitlab
```

如果您在运行 systemd 的系统上使用 init 脚本，因为您尚未切换到原生 systemd 单元，请运行：

```shell
sudo systemctl daemon-reload
```

<a id="install-libraries-and-run-migrations"></a>

### 安装库并运行迁移

要安装库并运行迁移：

1. 安装所需的库：

   ```shell
   cd /home/git/gitlab

   # 如果您在安装过程中或之前的升级中没有做过
   sudo -u git -H bundle config set --local deployment 'true'
   sudo -u git -H bundle config set --local without 'development test kerberos'

   # 更新 gems
   sudo -u git -H bundle install

   # 可选：清理旧的 gems
   sudo -u git -H bundle clean
   ```

1. 运行迁移：

   ```shell
   # 运行数据库迁移
   sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production

   # 更新 Node 依赖项并重新编译 assets
   sudo -u git -H bundle exec rake yarn:install gitlab:assets:clean gitlab:assets:compile RAILS_ENV=production NODE_ENV=production NODE_OPTIONS="--max_old_space_size=4096"

   # 清理缓存
   sudo -u git -H bundle exec rake cache:clear RAILS_ENV=production
   ```

<a id="update-gitlab-shell"></a>

### 更新极狐GitLab Shell

要更新极狐GitLab Shell，请运行这些命令：

```shell
cd /home/git/gitlab-shell

sudo -u git -H git fetch --all --tags --prune
sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_SHELL_VERSION)
sudo -u git -H make build
```

<a id="update-gitlab-workhorse"></a>

### 更新极狐GitLab Workhorse

要安装和编译极狐GitLab Workhorse，请运行这些命令：

```shell
cd /home/git/gitlab

sudo -u git -H bundle exec rake "gitlab:workhorse:install[/home/git/gitlab-workhorse]" RAILS_ENV=production
```

<a id="update-gitaly"></a>

### 更新 Gitaly

在升级应用程序服务器之前，先将 Gitaly 服务器升级到较新版本。这可以防止应用程序服务器上的 gRPC 客户端发送旧 Gitaly 版本不支持的 RPC。

如果 Gitaly 位于自己的服务器上，或者您使用 Gitaly 集群（Praefect），请参见[零停机升级](zero_downtime.md)。

在构建过程中，Gitaly [编译并嵌入 Git 二进制文件](https://jihulab.com/gitlab-cn/gitaly/-/issues/6089)，这需要额外的依赖项。

```shell
# 安装依赖项
sudo apt-get install -y libcurl4-openssl-dev libexpat1-dev gettext libz-dev libssl-dev libpcre2-dev build-essential

# 使用 Git 获取 Gitaly 源码并使用 Go 编译
cd /home/git/gitlab
sudo -u git -H bundle exec rake "gitlab:gitaly:install[/home/git/gitaly,/home/git/repositories]" RAILS_ENV=production
```

<a id="update-gitlab-pages"></a>

### 更新极狐GitLab Pages

要安装和编译极狐GitLab Pages：

```shell
cd /home/git/gitlab-pages

sudo -u git -H git fetch --all --tags --prune
sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_PAGES_VERSION)
sudo -u git -H make
```

<a id="post-upgrade-steps"></a>

### 升级后步骤

升级后：

1. [启动极狐GitLab 和 NGINX](#start-gitlab-and-nginx)。
1. [检查极狐GitLab 状态](#check-gitlab-status)。

<a id="start-gitlab-and-nginx"></a>

#### 启动极狐GitLab 和 NGINX

要启动极狐GitLab 和 NGINX：

```shell
# 对于运行 systemd 的系统
sudo systemctl start gitlab.target
sudo systemctl restart nginx.service

# 对于运行 SysV init 的系统
sudo service gitlab start
sudo service nginx restart
```

<a id="check-gitlab-status"></a>

#### 检查极狐GitLab 状态

要检查极狐GitLab 的状态：

1. 检查极狐GitLab 及其环境是否配置正确：

   ```shell
   cd /home/git/gitlab
   sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production
   ```

1. 为了确保您没有遗漏任何内容，运行更彻底的检查：

   ```shell
   cd /home/git/gitlab

   sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production
   ```

如果所有项均为绿色，那么恭喜，升级完成！

<a id="troubleshooting"></a>

## 故障排查

如果您在升级过程中遇到问题，请尝试以下部分中的一些步骤。

<a id="revert-the-code-to-the-previous-version"></a>

### 将代码回退到上一个版本

要回退到先前的版本，您必须遵循先前版本的升级指南。

例如，如果您已升级到极狐GitLab 16.6 并希望回退到 16.5，请遵循从 16.4 升级到 16.5 的指南。

回退时：

- 您 **不要** 遵循数据库迁移指南，因为备份已经迁移到先前的版本。
- 如果您运行了数据库迁移，您必须在降级后从备份恢复。代码的版本必须与使用的模式版本兼容。旧的模式在备份中。

<a id="restore-from-a-backup"></a>

### 从备份恢复

要从备份恢复：

```shell
cd /home/git/gitlab

sudo -u git -H bundle exec rake gitlab:backup:restore RAILS_ENV=production
```

如果您有多个备份 `*.tar` 文件，请在前面的代码块中添加 `BACKUP=timestamp_of_backup`。