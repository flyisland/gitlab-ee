---
title: Credits 用量导出中的逐事件明细
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: fulfillment
documentation_link: "../../../subscriptions/gitlab_credits_dashboard/#export-usage-data"
work_item: https://gitlab.com/gitlab-org/customers-gitlab-com/-/work_items/18963
categories: [ Consumables Cost Management ]
level: secondary
---

Credits 用量导出过去每天只提供一行数据，只能说明某个订阅花费了多少，却无法说明花费在哪些方面。要将 Credits 归因到某个团队、某个项目或某个单独的自动化流程，只能靠猜测。

现在，该导出会返回一个 ZIP 文件，其中包含两个 CSV 文件：一个是您原本就有的每日汇总，另一个是逐事件文件，每个计费事件对应一行。每行包含产品、任务流类型、会话、用户、命名空间、项目、已用 Credits 和 Token 数量。导出在后台运行，文件准备就绪后，极狐GitLab 会通过电子邮件向您发送下载链接。
