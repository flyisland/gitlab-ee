---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Cron
description: 安排作业应在何时运行。
---

Cron 语法用于安排作业应在何时运行。

您可能需要使用 cron 语法字符串来创建[流水线计划](../../ci/pipelines/schedules.md)，或通过设置[部署冻结](../../user/project/releases/_index.md#prevent-unintentional-releases-by-setting-a-deploy-freeze)来防止意外发布。

<a id="cron-syntax"></a>

## Cron 语法

Cron 调度使用一系列由空格分隔的五个数字：

```plaintext
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday)
# │ │ │ │ │
# │ │ │ │ │
# │ │ │ │ │
# * * * * * <command to execute>
```

（来源：[Wikipedia](https://en.wikipedia.org/wiki/Cron)）

在 cron 语法中，星号（`*`）表示“每”，因此以下 cron 字符串是有效的：

- 每小时整点运行一次：`0 * * * *`
- 每天午夜运行一次：`0 0 * * *`
- 每周日午夜运行一次：`0 0 * * 0`
- 每月第一天午夜运行一次：`0 0 1 * *`
- 每月 22 日运行一次：`0 0 22 * *`
- 每年 1 月 1 日午夜运行一次：`0 0 1 1 *`
- 每月 1 日和 15 日凌晨 3 点运行两次：`0 3 1,15 * *`

有关完整的 cron 文档，请参阅
[crontab(5) Linux 手册页](https://man7.org/linux/man-pages/man5/crontab.5.html)。
在 Linux 或 macOS 终端中输入 `man 5 crontab` 即可离线访问此文档。

此外，极狐GitLab 使用 [`fugit`](#how-gitlab-parses-cron-syntax-strings)，它接受 `#` 和 `%` 语法。此语法可能无法在所有 cron 测试器中正常工作：

- 每月第二个星期一运行一次：`0 0 * * 1#2`。此语法来自 [`fugit` hash 扩展](https://github.com/floraison/fugit#the-hash-extension)。
- 每隔一个星期日 09:00 运行一次：`0 9 * * sun%2`。此语法来自 [`fugit` 取模扩展](https://github.com/floraison/fugit#the-modulo-extension)。

<a id="cron-examples"></a>

## Cron 示例

```plaintext
# Run at 7:00pm every day:
0 19 * * *

# Run every minute on the 3rd of June:
* * 3 6 *

# Run at 06:30 every Friday:
30 6 * * 5
```

更多关于如何编写 cron 计划的示例，请参见
[crontab.guru](https://crontab.guru/examples.html)。

<a id="how-gitlab-parses-cron-syntax-strings"></a>

## 极狐GitLab 如何解析 cron 语法字符串

极狐GitLab 使用 [`fugit`](https://github.com/floraison/fugit) 在服务器端解析 cron 语法
字符串，并使用 [cron-validator](https://github.com/GuillaumeRochat/cron-validator)
在浏览器中验证 cron 语法。极狐GitLab 使用 [`cRonstrue`](https://github.com/bradymholt/cRonstrue) 在浏览器中将 cron 转换为人类可读的字符串。
