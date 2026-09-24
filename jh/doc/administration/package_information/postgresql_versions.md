---
stage: 极狐GitLab Delivery
group: Build
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Linux 安装包自带的 PostgreSQL 版本
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 此表格仅列出在 PostgreSQL 版本方面发生重大变化的极狐GitLab 版本，并非全部。

通常，PostgreSQL 版本会随着极狐GitLab 的大版本或小版本发布而变化。但是，Linux 安装包的补丁版本有时也会更新 PostgreSQL 的补丁级别。我们已经为 PostgreSQL 升级设定了年度节奏，并在要求使用新版本之前的发行版中触发自动数据库升级。

例如：

- Linux 安装包 12.7.6 附带 PostgreSQL 9.6.14 和 10.9。
- Linux 安装包 12.7.7 附带 PostgreSQL 9.6.17 和 10.12。

了解每个 Linux 安装包发布版本[随附的 PostgreSQL（及其他组件）版本](https://gitlab-org.gitlab.io/omnibus-gitlab/licenses.html)。

支持的最低 PostgreSQL 版本列在[安装要求](../../install/requirements.md#postgresql)中。

在 PostgreSQL [升级文档](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)中阅读更多关于升级策略和警告的信息。

| 首个极狐GitLab 版本 | PostgreSQL 版本 | 全新安装的默认版本 | 升级时的默认版本 | 备注 |
| -------------- | ------------------- | ---------------------------------- | ---------------------------- | ----- |
| 18.11.0 | 16.11, 17.7 | 17.7 | 17.7 | 全新安装默认使用 PostgreSQL 17。除非[选择退出](https://gitlab.cn/docs/omnibus/settings/database/#opt-out-of-automatic-postgresql-upgrades)，否则 Linux 安装包实例升级会自动为不属于 Geo 或高可用集群的节点执行到 PostgreSQL 17 的升级。 |
| 18.4.1, 18.3.3, 18.2.7 | 16.10 | 16.10 | 16.10 | |
| 18.0.0 | 16.8 | 16.8 | 16.8 | 如果尚未升级到 PostgreSQL 16，则安装包升级将中止。 |
| 17.11.0 | 14.17, 16.8 | 16.8 | 16.8 | 除非[选择退出](https://gitlab.cn/docs/omnibus/settings/database/#opt-out-of-automatic-postgresql-upgrades)，否则安装包升级会自动为不属于 Geo 或高可用集群的节点执行到 PostgreSQL 16 的升级。 |
| 17.10.0 | 14.17, 16.8 | 16.8 | 16.8 | 全新安装现在默认使用 PostgreSQL 16。 |
| 17.9.2, 17.8.5, 17.7.7 | 14.17, 16.8 | 14.17 | 16.8 | |
| 17.8.0 | 14.15, 16.6 | 14.15 | 16.6 | |
| 17.5.0 | 14.11, 16.4 | 14.11 | 16.4 | 现在支持单节点从 PostgreSQL 14 升级到 PostgreSQL 16。从极狐GitLab 17.5.0 开始，PostgreSQL 16 完全支持 Geo 部署中的全新安装和升级（17.4.0 的限制不再适用）。 |
| 17.4.0 | 14.11, 16.4 | 14.11 | 14.11 | 如果不使用 [Geo](../geo/_index.md#requirements-for-running-geo) 或 [Patroni](../postgresql/_index.md#postgresql-replication-and-failover-for-linux-package-installations)，PostgreSQL 16 可用于全新安装。 |
| 17.0.0 | 14.11 | 14.11 | 14.11 | 如果尚未升级到 PostgreSQL 14，则安装包升级将中止。 |
| 16.10.1, 16.9.3, 16.8.5 | 13.14, 14.11 | 14.11 | 14.11 | |
| 16.6.7, 16.7.5, 16.8.2 | 13.13, 14.10 | 14.10 | 14.10 | |
| 16.7.0 | 13.12, 14.9 | 14.9 | 14.9 | |
| 16.4.3, 16.5.3, 16.6.1 | 13.12, 14.9 | 13.12 | 13.12 | 对于升级，你可以根据[升级文档](../../update/versions/gitlab_16_changes.md#linux-package-installations-2)手动升级到 14.9。 |
| 16.2.0 | 13.11, 14.8 | 13.11 | 13.11 | 对于升级，你可以根据[升级文档](../../update/versions/gitlab_16_changes.md#linux-package-installations-2)手动升级到 14.8。 |
| 16.0.2 | 13.11 | 13.11 | 13.11 | |
| 16.0.0 | 13.8  | 13.8  | 13.8  | |
| 15.11.7 | 13.11 | 13.11 | 12.12 | |
| 15.10.8 | 13.11 | 13.11 | 12.12 | |
| 15.6 | 12.12, 13.8 | 13.8 | 12.12 | 对于升级，你可以根据[升级文档](../../update/versions/gitlab_15_changes.md#linux-package-installations-2)手动升级到 13.8。 |
| 15.0 | 12.10, 13.6 | 13.6 | 12.10 | 对于升级，你可以根据[升级文档](../../update/versions/gitlab_15_changes.md#linux-package-installations-2)手动升级到 13.6。 |
| 14.1 | 12.7, 13.3 | 12.7 | 12.7 | 如果不使用 [Geo](../geo/_index.md#requirements-for-running-geo) 或 [Patroni](../postgresql/_index.md#postgresql-replication-and-failover-for-linux-package-installations)，PostgreSQL 13 可用于全新安装。 |
| 14.0 | 12.7       | 12.7 | 12.7 | 不再支持使用 repmgr 的高可用安装，并阻止其升级到 Linux 安装包 14.0 |
| 13.8 | 11.9, 12.4 | 12.4 | 12.4 | 安装包升级会自动为不属于 Geo 或高可用集群的节点执行 PostgreSQL 升级。 |
| 13.7 | 11.9, 12.4 | 12.4 | 11.9 | 对于升级，用户可以根据[升级文档](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)手动升级到 12.4。 |
| 13.4 | 11.9, 12.4 | 11.9 | 11.9 | 如果用户尚未运行 PostgreSQL 11，则安装包升级将中止 |
| 13.3 | 11.7, 12.3 | 11.7 | 11.7 | 如果用户尚未运行 PostgreSQL 11，则安装包升级将中止 |
| 13.0 | 11.7 | 11.7 | 11.7 | 如果用户尚未运行 PostgreSQL 11，则安装包升级将中止 |
| 12.10 | 9.6.17, 10.12, 和 11.7 | 11.7 | 11.7 | 安装包升级会自动为不属于 Geo 或 repmgr 集群的节点执行 PostgreSQL 升级。 |
| 12.8 | 9.6.17, 10.12, 和 11.7 | 10.12 | 10.12 | 用户可以根据升级文档手动升级到 11.7。 |
| 12.0 | 9.6.11 和 10.7 | 10.7 | 10.7 | 安装包升级会自动执行 PostgreSQL 升级。 |
| 11.11 | 9.6.11 和 10.7 | 9.6.11 | 9.6.11 | 用户可以根据升级文档手动升级到 10.7。 |
| 10.0 | 9.6.3 | 9.6.3 | 9.6.3 | 如果用户仍在使用 9.2，则安装包升级将中止。 |
| 9.0 | 9.2.18 和 9.6.1 | 9.6.1 | 9.6.1 | 安装包升级会自动执行 PostgreSQL 升级。 |
| 8.14 | 9.2.18 和 9.6.1 | 9.2.18 | 9.2.18 | 用户可以根据升级文档手动升级到 9.6。 |
