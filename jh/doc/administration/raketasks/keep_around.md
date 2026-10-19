---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 孤立的 keep-around 引用 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

`gitlab:keep_around:orphaned` 会为项目代码仓库中的每个 keep-around 引用以及每个指向 Git 提交的数据库引用生成一份 CSV 报告。

CSV 报告包含三列：

- 引用类型。keep-around 引用为 `keep`，数据库引用为 `usage`。
- Git 提交 ID。
- 引用的来源（如果已知）。例如 `Pipeline`。

<a id="run-orphaned-reference-report"></a>

## 运行孤立引用报告

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

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
