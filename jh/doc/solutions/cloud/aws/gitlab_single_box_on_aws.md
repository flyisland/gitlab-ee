---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
description: Guide to provision a single GitLab instance on AWS using Marketplace subscriptions or official GitLab AMIs, including CE/EE editions and licensing considerations.
title: 在 AWS 上的单个 EC2 实例上部署极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您想在 AWS 上部署单个极狐GitLab 实例，有两种选择：

- Marketplace 订阅
- 官方极狐GitLab AMI

## Marketplace 订阅

极狐GitLab 提供 5 用户订阅作为 AWS Marketplace 订阅，帮助各种规模的团队快速开始使用旗舰版许可实例。Marketplace 订阅可以通过 AWS Marketplace 私有报价升级到任何极狐GitLab 许可，并享受持续的 AWS 账单便利。无需迁移即可从极狐GitLab 获取更大、非基于时间的许可证。当您接受私有报价时，按分钟计费的许可将自动移除。

有关通过 Marketplace 订阅部署极狐GitLab 实例的教程，请[使用此教程](https://gitlab.awsworkshop.io/040_partner_setup.html)。该教程链接到[极狐GitLab 旗舰版 Marketplace 列表](https://aws.amazon.com/marketplace/pp/prodview-g6ktjmpuc33zk)，但您也可以使用[极狐GitLab 专业版 Marketplace 列表](https://aws.amazon.com/marketplace/pp/prodview-amk6tacbois2k)来部署实例。

<a id="official-gitlab-releases-as-amis"></a>

## 官方极狐GitLab AMI 发布

极狐GitLab 在常规发布过程中生成 Amazon Machine Images (AMI)。这些 AMI 可用于单实例极狐GitLab 安装，或者通过配置 `/etc/gitlab/gitlab.rb`，可以专门用于特定的极狐GitLab 服务角色（例如 Gitaly 服务器）。旧版本仍然可用，可用于将旧的极狐GitLab 服务器迁移到 AWS。

初始许可可以是基础版企业版许可证 (EE) 或开源基础版 (CE)。如果需要，企业版提供了通往许可版本的最简单途径。

目前，Amazon AMI 使用 Amazon 准备的 Ubuntu AMI（x86 和 ARM 可用）作为其起点。

> [!note]
> 使用官方 AMI 部署极狐GitLab 实例时，实例的 root 密码是 EC2 **实例** ID（不是 AMI ID）。这种设置 root 账户密码的方式仅适用于官方发布的极狐GitLab AMI。

运行基础版 (CE) 的实例需要迁移到企业版 (EE) 才能订阅极狐GitLab 专业版或旗舰版计划。如果您想获取订阅，使用企业版的基础版永久计划是破坏性最小的方法。

> [!note]
> 由于任何极狐GitLab 升级都可能涉及数据磁盘更新或数据库架构升级，因此更换 AMI 不足以进行升级。

1. 登录 AWS Web 控制台，以便在下一步中选择链接时直接进入 AMI 列表。
1. 选择您想要的版本：

   - [极狐GitLab 企业版](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;owner=782774275127;search=GitLab%20EE;sort=desc:name)：如果您想解锁企业功能，需要许可证。
   - [极狐GitLab 基础版](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;owner=782774275127;search=GitLab%20CE;sort=desc:name)：极狐GitLab 的开源版本。
   - [极狐GitLab 专业版或旗舰版 Marketplace（预许可）](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:visibility=public-images;source=Marketplace;search=GitLab%20EE;sort=desc:name)：5 用户许可内置于按分钟计费中。

1. AMI ID 在每个区域都是唯一的。加载任一版本后，在控制台右上角选择所需的目标区域以查看相应的 AMI。
1. 控制台加载后，您可以添加其他搜索条件以进一步缩小范围。例如，输入 `13.` 仅查找 13.x 版本。
1. 要使用列出的 AMI 启动 EC2 实例，请选中相关行开头的复选框，然后选择页面左上角附近的 **启动**。