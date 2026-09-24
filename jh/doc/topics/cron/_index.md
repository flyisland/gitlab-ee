---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.cn/handbook/product/ux/technical-writing/#assignments>
title: Cron
description: 计划作业何时运行。
---

Cron 语法用于计划作业何时运行。

你可能需要使用 cron 语法字符串来
创建[流水线计划](../../ci/pipelines/schedules.md)，
或通过设置[部署冻结窗口](../../user/project/releases/_index.md#prevent-unintentional-releases-by-setting-a-deploy-freeze)来防止意外发布。

<a id="cron-syntax"></a>

## Cron 语法

Cron 计划使用一系列由空格分隔的五个数字：

```plaintext
# ┌───────────── 分钟 (0 - 59)
# │ ┌───────────── 小时 (0 - 23)
# │ │ ┌───────────── 一个月中的第几天 (1 - 31)
# │ │ │ ┌───────────── 月份 (1 - 12)
# │ │ │ │ ┌───────────── 一周中的第几天 (0 - 6) (周日 到 周六)
# │ │ │ │ │
# │ │ │ │ │
# │ │ │ │ │
# * * * * * <要执行的命令>
```

(来源：[Wikipedia](https://en.wikipedia.org/wiki/Cron))

在 cron 语法中，星号 (`*`) 意味着“每”，因此以下 cron 字符串
是有效的：

- 每小时开始时运行一次：`0 * * * *`
- 每天午夜运行一次：`0 0 * * *`
- 每周日凌晨的午夜运行一次：`0 0 * * 0`
- 每月第一天的午夜运行一次：`0 0 1 * *`
- 每月 22 日运行一次：`0 0 22 * *`
- 每年 1 月 1 日午夜运行一次：`0 0 1 1 *`
- 每月运行两次，分别是 1 号和 15 号凌晨 3 点：`0 3 1,15 * *`

有关完整的 cron 文档，请参阅
[crontab(5) Linux 手册页](https://man7.org/linux/man-pages/man5/crontab.5.html)。
可以在 Linux 或 MacOS 终端中输入 `man 5 crontab` 来离线访问此文档。

此外，极狐GitLab 使用 [`fugit`](#how-gitlab-parses-cron-syntax-strings)，它
接受 `#` 和 `%` 语法。此语法可能并非在所有 cron 测试器中都有效：

- 在每月的第二个星期一下午 3 点运行一次：`0 0 * * 1#2`。此语法来自 [`fugit` 哈希扩展](https://github.com/floraison/fugit#the-hash-extension)。
- 每隔一周的星期日上午 9 点运行：`0 9 * * sun%2`。此语法来自 [`fugit` 取模扩展](https://github.com/floraison/fugit#the-modulo-extension)。

<a id="cron-examples"></a>

## Cron 示例

```plaintext
# 每晚 7:00 运行：
0 19 * * *

# 在 6 月 3 日的每一分钟运行：
* * 3 6 *

# 每周五 06:30 运行：
30 6 * * 5
```

更多关于如何编写 cron 计划的示例，请访问
[crontab.guru](https://crontab.guru/examples.html)。

<a id="how-gitlab-parses-cron-syntax-strings"></a>

## 极狐GitLab 如何解析 cron 语法字符串

极狐GitLab 在服务端使用 [`fugit`](https://github.com/floraison/fugit) 来解析 cron 语法
字符串，并在浏览器中使用 [cron-validator](https://github.com/TheCloudConnectors/cron-validator)
来验证 cron 语法。极狐GitLab 在浏览器中使用
[`cRonstrue`](https://github.com/bradymholt/cRonstrue) 将 cron 转换为人类可读的字符串。