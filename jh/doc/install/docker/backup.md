---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在 Docker 容器中运行的极狐GitLab 备份
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以使用以下命令创建极狐GitLab 备份：

```shell
docker exec -t <container name> gitlab-backup create
```

更多信息，请参见[备份和恢复极狐GitLab](../../administration/backup_restore/_index.md)。

如果您的极狐GitLab 配置完全通过 `GITLAB_OMNIBUS_CONFIG` 环境变量提供（通过["预配置 Docker 容器"](configuration.md#pre-configure-docker-container) 步骤），则配置设置不会存储在 `gitlab.rb` 文件中，因此您无需备份 `gitlab.rb` 文件。

> [!warning]
> 为避免从备份恢复极狐GitLab 时出现[复杂步骤](../../administration/backup_restore/troubleshooting_backup_gitlab.md#when-the-secrets-file-is-lost)，您还应遵循[备份极狐GitLab 密钥文件](../../administration/backup_restore/backup_gitlab.md#storing-configuration-files)中的说明。
> 密钥文件存储在容器内的 `/etc/gitlab/gitlab-secrets.json` 文件中，或[容器主机上](installation.md#create-a-directory-for-the-volumes)的 `$GITLAB_HOME/config/gitlab-secrets.json` 文件中。

<a id="create-a-database-backup"></a>

## 创建数据库备份

在升级极狐GitLab 之前，请创建仅数据库备份。如果在极狐GitLab 升级过程中遇到问题，您可以恢复数据库备份以回滚升级。要创建数据库备份，请运行以下命令：

```shell
docker exec -t <container name> gitlab-backup create SKIP=artifacts,repositories,registry,uploads,builds,pages,lfs,packages,terraform_state
```

备份将写入 `/var/opt/gitlab/backups`，该目录应位于[Docker 挂载的卷](installation.md#create-a-directory-for-the-volumes)上。

有关使用备份回滚升级的更多信息，请参见[回滚 Docker 实例](../../update/package/downgrade.md#roll-back-a-docker-instance)。

