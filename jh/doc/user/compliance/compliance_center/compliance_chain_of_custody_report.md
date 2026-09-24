---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Generate and export the chain of custody report in GitLab to track project changes and merge details for compliance.
title: 监管链报告
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 13.3 引入。
- 通过电子邮件发送的监管链报告在极狐GitLab 15.3 引入，带有一个名为 `async_chain_of_custody_report` 的功能标志。默认禁用。
- 在极狐GitLab 15.5 GA。功能标志 `async_chain_of_custody_report` 已移除。
- 监管链报告包含所有提交（而不仅仅是合并提交），在极狐GitLab 15.9 引入，带有一个名为 `all_commits_compliance_report` 的功能标志。默认禁用。
- 在极狐GitLab 15.9 GA。功能标志 `all_commits_compliance_report` 已移除。

{{< /history >}}

监管链报告提供群组下某个项目最近一个月所有提交的跟踪窗口。

为生成所有提交的报告，极狐GitLab 会：

1. 获取群组下的所有项目。
1. 对于每个项目，按时间顺序（最新的在前）获取最近一个月的提交。每个项目最多包含 1024 个提交。如果一个月窗口内的提交数量超过 1024，则超出的部分将被截断。
1. 按提交日期（降序）对所有提交排序，并以提交 SHA 作为确定性次要排序标准，以保证顺序一致。
1. 将提交信息写入 CSV 文件。由于报告会作为邮件附件发送，文件大小限制为 15 MB。

报告包含以下信息：

- 提交 SHA。
- 提交作者。
- 提交者（当基于提交者邮箱能匹配到 GitLab 用户名时，会标准化显示该用户名）。
- 提交日期（UTC 格式，精确到毫秒）。
- 群组。
- 项目。

如果该提交存在关联的合并提交，则还会包含：

- 合并提交 SHA。
- 合并请求 ID。
- 合并该合并请求的用户。
- 合并日期。
- 流水线 ID。
- 合并请求审批人。

<a id="generate-chain-of-custody-report"></a>

## 生成监管链报告

要生成监管链报告：

1. 在顶部导航栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **安全** > **合规中心**。
1. 在右上角，选择 **导出**。
1. 选择 **导出监管链报告**。

根据你使用的极狐GitLab 版本，监管链报告可能通过邮件发送，或可直接下载。

<a id="generate-commit-specific-chain-of-custody-report"></a>

## 为特定提交生成监管链报告

{{< history >}}

- 在极狐GitLab 13.6 引入。
- 在极狐GitLab 15.10 中，支持包含所有提交，而不仅仅是合并提交。

{{< /history >}}

你可以为指定的提交 SHA 生成特定提交的监管链报告。该报告仅提供该提交 SHA 的详细信息。

要生成特定提交的监管链报告：

1. 在顶部导航栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **安全** > **合规中心**。
1. 在右上角，选择 **导出**。
1. 选择 **导出特定提交的监管报告**。
1. 输入提交 SHA，然后选择 **导出监管报告**。

根据你使用的极狐GitLab 版本，监管链报告可能通过邮件发送，或可直接下载。

或者，你也可以使用直接链接：`https://jihulab.com/groups/<group-name>/-/security/merge_commit_reports.csv?commit_sha={optional_commit_sha}`，并为 `commit_sha` 查询参数传入可选值。