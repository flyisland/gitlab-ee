---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Praefect Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

对于在 Praefect 存储上创建的项目，可以使用 Rake 任务。有关配置 Praefect 的信息，请参阅
[Praefect 文档](../gitaly/praefect/_index.md)。

<a id="replica-checksums"></a>

## 副本校验和

`gitlab:praefect:replicas` 会输出以下节点上代码仓库的校验和：

- 主 Gitaly 节点。
- 内部从 Gitaly 节点。

您可以检查特定项目或所有项目的副本。

请在安装了极狐GitLab 的节点上运行此 Rake 任务，而不是在安装了 Praefect 的节点上运行。

<a id="check-replicas-for-a-specific-project"></a>

### 检查特定项目的副本

- Linux 软件包安装：

  ```shell
  sudo gitlab-rake "gitlab:praefect:replicas[project_id]"
  ```

- 自行编译安装：

  ```shell
  sudo -u git -H bundle exec rake "gitlab:praefect:replicas[project_id]" RAILS_ENV=production
  ```

<a id="check-replicas-for-all-projects"></a>

### 检查所有项目的副本

在拥有数千个项目的大型极狐GitLab 实例上，检查所有项目的副本可能会消耗大量资源，因为每个项目都需要对 Gitaly 服务进行外部调用。请考虑在非高峰时段运行此任务，或安排在不会影响生产性能的时间运行。

- Linux 软件包安装：

  ```shell
  sudo gitlab-rake gitlab:praefect:replicas
  ```

- 自行编译安装：

  ```shell
  sudo -u git -H bundle exec rake gitlab:praefect:replicas RAILS_ENV=production
  ```
