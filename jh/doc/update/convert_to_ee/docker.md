---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将 Docker CE 实例转换为 EE
---

你可以使用与[升级版本](../docker/_index.md)相同的方法，将现有的极狐GitLab 基础版（CE）Docker 容器转换为极狐GitLab [企业版](https://gitlab.cn/pricing/)（EE）容器。

你应该从相同版本的 CE 转换到 EE（例如，CE 18.1 到 EE 18.1）。不过，这并不是强制要求。任何标准升级（例如，CE 18.0 到 EE 18.1）都应该可行。以下步骤假定你转换到相同版本。

1. 进行[备份](../../install/docker/backup.md)。至少需要备份[数据库](../../install/docker/backup.md#create-a-database-backup)和极狐GitLab 密钥文件。
1. 停止当前基础版容器，并移除或重命名它。
1. 要创建极狐GitLab EE 的新容器，请在 `docker run` 命令或 `docker-compose.yml` 文件中将 `ce` 替换为 `ee`。重复使用基础版容器的名称、端口映射、文件映射和版本。