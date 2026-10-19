---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在极狐GitLab 中生成并导出监管链报告，以跟踪项目变更和合并详情，满足合规要求。
title: 监管链报告
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

监管链报告提供群组下某个项目最近一个月内所有提交的追溯窗口。

要为所有提交生成报告，极狐GitLab 会：

1. 获取该群组下的所有项目。
1. 对于每个项目，按时间顺序（最新的在前）获取最近一个月的提交。每个项目最多 1024 个提交。如果一个月窗口内的提交超过
   1024 个，则会被截断。
1. 按提交日期（降序）对所有提交排序，并以提交 SHA 作为确定性的次级排序依据，以保证排序一致。
1. 将提交写入 CSV 文件。由于报告以附件形式通过电子邮件发送，文件会在 15 MB 处截断。

报告包含：

- 提交 SHA。
- 提交作者。
- 提交者（在可用时根据提交者邮箱规范化为极狐GitLab 用户名）。
- 提交日期（以 UTC 格式表示，精确到毫秒）。
- 群组。
- 项目。

如果提交有相关的合并提交，则还会包含以下内容：

- 合并提交 SHA。
- 合并请求 ID。
- 合并合并请求的用户。
- 合并日期。
- 流水线 ID。
- 合并请求审批人。

<a id="generate-chain-of-custody-report"></a>

## 生成监管链报告

要生成监管链报告：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **合规中心**。
1. 在右上角，选择**导出**。
1. 选择**导出监管链报告**。

监管链报告通过电子邮件发送。

<a id="generate-commit-specific-chain-of-custody-report"></a>

## 生成特定提交的监管链报告

您可以为给定的提交 SHA 生成特定提交的监管链报告。此报告仅提供所提供提交 SHA 的详细信息。

要生成特定提交的监管链报告：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **合规中心**。
1. 在右上角，选择**导出**。
1. 选择**导出特定提交的监管报告**。
1. 输入提交 SHA，然后选择**导出监管报告**。

监管链报告通过电子邮件发送。

或者，使用直接链接：`https://jihulab.com/groups/<group-name>/-/security/merge_commit_reports.csv?commit_sha={optional_commit_sha}`，为 `commit_sha` 查询参数传入一个可选值。
