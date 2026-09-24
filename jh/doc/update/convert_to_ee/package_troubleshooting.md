---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 基础版转换到企业版的问题排查
---

当将 Linux 软件包安装从极狐GitLab 基础版转换为企业版时，可能会遇到以下问题。

<a id="rpm-package-is-already-installed-error"></a>

## RPM '软件包已安装' 错误

如果你正在使用 RPM，可能会遇到类似以下错误：

```shell
软件包 gitlab-7.5.2_omnibus.5.2.1.ci-1.el7.x86_64（比 gitlab-7.5.2_ee.omnibus.5.2.1.ci-1.el7.x86_64 更新）已经安装
```

你可以使用 `--oldpackage` 选项覆盖此版本检查：

```shell
sudo rpm -Uvh --oldpackage gitlab-7.5.2_ee.omnibus.5.2.1.ci-1.el7.x86_64.rpm
```

<a id="package-obsoleted-by-installed-package"></a>

## 软件包被已安装的软件包废弃

基础版 (CE) 和企业版 (EE) 软件包互相标记为废弃，因此两者不会同时安装。

如果你使用本地 RPM 文件从 CE 切换到 EE 或反之，请使用 `rpm` 安装软件包，而不是使用 `yum`。如果尝试使用 yum，可能会遇到类似这样的错误：

```plaintext
无法安装软件包 gitlab-ee-11.8.3-jh.0.el6.x86_64。它已被已安装的软件包 gitlab-ce-11.8.3-jh.0.el6.x86_64 废弃
```

为避免此问题，可以：

- 使用[使用下载的软件包升级](../package/_index.md#upgrade-with-a-downloaded-package)部分中提供的相同说明。
- 在 yum 命令的选项中添加 `--setopt=obsoletes=0`，临时禁用此检查。

<a id="500-error-when-accessing-project-repository-settings"></a>

## 访问项目仓库设置时出现 500 错误

当极狐GitLab 从基础版 (CE) 转换到企业版 (EE)，然后再回到 CE，最后又回到 EE 时，会发生此错误。

查看项目仓库设置时，你可以在日志中看到此错误：

```shell
Processing by Projects::Settings::RepositoryController#show as HTML
  Parameters: {"namespace_id"=>"<namespace_id>", "project_id"=>"<project_id>"}
Completed 500 Internal Server Error in 62ms (ActiveRecord: 4.7ms | Elasticsearch: 0.0ms | Allocations: 14583)

NoMethodError (undefined method `commit_message_negative_regex' for #<PushRule:0x00007fbddf4229b8>
Did you mean?  commit_message_regex_change):
```

此错误是由于在初次迁移到 EE 时，EE 功能被添加到了 CE 实例。当实例移回 CE 然后再次升级到 EE 后，数据库中的 `push_rules` 表已经存在，因此迁移无法添加 `commit_message_regex_change` 列。

这导致 [EE 表的向后移植迁移](https://jihulab.com/gitlab-cn/gitlab/-/blob/cf00e431024018ddd82158f8a9210f113d0f4dbc/db/migrate/20190402150158_backport_enterprise_schema.rb#L1619) 无法正常工作。该向后移植迁移假定在运行 CE 时数据库中某些表不存在。

要解决此问题：

1. 启动数据库控制台：

   ```shell
   sudo gitlab-rails dbconsole --database main
   ```

1. 手动添加缺失的 `commit_message_negative_regex` 列：

   ```sql
   ALTER TABLE push_rules ADD COLUMN commit_message_negative_regex VARCHAR;

   # 退出 psql
   \q
   ```

1. 重启极狐GitLab：

   ```shell
   sudo gitlab-ctl restart
   ```