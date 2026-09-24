---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 外部数据库的监控和日志记录设置
---

外部 PostgreSQL 数据库系统有多种日志记录选项可用于监控性能和排查故障，但默认情况下这些选项并未启用。本节将提供针对私有化部署 PostgreSQL 的建议，以及针对一些主流 PostgreSQL 托管服务提供商的建议。

<a id="recommended-postgresql-logging-settings"></a>

## 推荐的 PostgreSQL 日志记录设置

你应该启用以下日志记录设置：

- `log_statement=ddl`：记录数据库模型定义（DDL）的更改，例如对象的 `CREATE`、`ALTER` 或 `DROP`。这有助于追踪可能导致性能问题的近期模型更改，并识别安全漏洞和人为错误。
- `log_lock_waits=on`：记录长时间持有[锁](https://www.postgresql.org/docs/16/explicit-locking.html)的进程，这是查询性能不佳的常见原因。
- `log_temp_files=0`：记录大量且异常的临时文件使用情况，这可以表明查询性能不佳。
- `log_autovacuum_min_duration=0`：记录所有自动清理（autovacuum）执行情况。自动清理是整个 PostgreSQL 引擎性能的关键组件。对于排查和调优表中未被移除的死元组至关重要。
- `log_min_duration_statement=1000`：记录慢查询（慢于 1 秒）。

这些参数设置的完整说明可以在
[PostgreSQL 错误报告和日志记录文档](https://www.postgresql.org/docs/16/runtime-config-logging.html#RUNTIME-CONFIG-LOGGING-WHAT)中找到。

<a id="amazon-rds"></a>

## Amazon RDS

Amazon Relational Database Service（RDS）提供了大量的[监控指标](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Monitoring.html)和[日志记录接口](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Monitor_Logs_Events.html)。以下是你应该配置的几项：

- 通过 [RDS 参数组](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithDBInstanceParamGroups.html)更改所有[推荐的 PostgreSQL 日志记录设置](#recommended-postgresql-logging-settings)。
  - 由于推荐的日志记录参数在 [RDS 中是动态的](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.Parameters.html)，因此更改这些设置后无需重启。
  - PostgreSQL 日志可以通过 [RDS 控制台](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/logs-events-streams-console.html)进行查看。
- 启用 [RDS 性能洞察](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.html)可以让你通过 PostgreSQL 数据库引擎的许多重要性能指标来可视化数据库负载。
- 启用 [RDS 增强监控](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.html)来监控操作系统指标。这些指标可以指示底层硬件和操作系统中影响数据库性能的瓶颈。
  - 在生产环境中，将监控间隔设置为 10 秒（或更短），以捕获导致许多性能问题的微突发资源使用情况。在控制台中将 `Granularity` 设置为 `10`，或在 CLI 中将 `monitoring-interval` 设置为 `10`。