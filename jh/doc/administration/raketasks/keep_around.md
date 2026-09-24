---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 保留的孤立引用 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 对 Rake 任务的改进在极狐GitLab 18.4 中引入。

{{< /history >}}

`gitlab:keep_around:orphaned` 会生成一份 CSV 报告，其中包含项目仓库中的每个保留引用以及指向 Git 提交的每个数据库引用。

CSV 报告包含三列：

- 引用类型。`keep` 表示保留引用，`usage` 表示数据库引用。
- Git 提交 ID。
- 引用的来源（如果已知）。例如，`Pipeline`。

<a id="run-orphaned-reference-report"></a>

## 运行孤立引用报告

{{< tabs >}}

{{< tab title="Linux 安装包 (Omnibus)" >}}

```shell
sudo gitlab-rake gitlab:keep_around:orphaned PROJECT_PATH=project/path FILENAME=/tmp/report.csv
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
bundle exec rake gitlab:keep_around:orphaned RAILS_ENV=production PROJECT_PATH=project/path FILENAME=/tmp/report.csv
```

{{< /tab >}}

{{< /tabs >}}