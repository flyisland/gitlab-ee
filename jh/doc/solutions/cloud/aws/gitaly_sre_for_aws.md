---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
description: Doing SRE for Gitaly instances on AWS.
title: AWS 上 Gitaly 的 SRE 考虑
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="gitaly-sre-considerations"></a>

## Gitaly SRE 考虑

Gitaly 是一个用于 Git 仓库存储的嵌入式服务。极狐GitLab 设计了 Gitaly 和 Gitaly 集群 (Praefect)，以克服在极狐GitLab 服务端必须使用的开源 Git 二进制文件水平扩展的基本挑战。以下是有关该主题的深入技术资料：

<a id="why-gitaly-was-built"></a>

### 为什么构建 Gitaly

如果你想了解极狐GitLab 为何必须投资创建 Gitaly，请阅读以下最低限度的主题列表：

- [导致水平扩展困难的 Git 特性](https://jihulab.com/gitlab-cn/gitaly/-/blob/master/doc/DESIGN.md#git-characteristics-that-make-horizontal-scaling-difficult)
- [Git 架构特性与假设](https://jihulab.com/gitlab-cn/gitaly/-/blob/master/doc/DESIGN.md#git-architectural-characteristics-and-assumptions)
- [对水平计算架构的影响](https://jihulab.com/gitlab-cn/gitaly/-/blob/master/doc/DESIGN.md#affects-on-horizontal-compute-architecture)
- [构建新的水平层以扩展 Git 的证据](https://jihulab.com/gitlab-cn/gitaly/-/blob/master/doc/DESIGN.md#evidence-to-back-building-a-new-horizontal-layer-to-scale-git)

<a id="gitaly-and-praefect-elections"></a>

### Gitaly 和 Praefect 选举

作为 Gitaly 集群 (Praefect) 一致性的一部分，Praefect 节点有时必须对哪个数据副本最准确进行投票。这要求 Praefect 节点数量为奇数，以避免僵局。这意味着对于高可用性，Gitaly 和 Praefect 至少需要三个节点。

<a id="gitaly-performance-monitoring"></a>

### Gitaly 性能监控

应为 Gitaly 实例收集完整的性能指标，以识别瓶颈，因为这些瓶颈可能与磁盘 IO、网络 IO 或内存有关。

<a id="gitaly-performance-guidelines"></a>

### Gitaly 性能指南

Gitaly 作为极狐GitLab 中主要的 Git 仓库存储运行。然而，它不是一个流式文件服务器。它还执行大量计算密集型工作，例如准备和缓存 Git 包文件，这为以下一些性能建议提供了依据。

> [!note]
> 所有建议均适用于生产配置，包括性能测试。对于测试配置，如培训或功能测试，你可以使用成本较低的选项。但是，如果性能出现问题，你应该进行调整或重建。

<a id="overall-recommendations"></a>

#### 总体建议

- 由于上述所有及后续特性，生产级 Gitaly 必须实施在实例计算上。
- 绝不使用[可突增实例类型](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances.html) (如 `t2`、`t3`、`t4g`) 用于 Gitaly。
- 始终至少使用 [AWS Nitro 系列实例](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#ec2-nitro-instances)，以确保自动处理以下许多关注点。
- 使用 Amazon Linux 2 以确保最大化所有 [面向 AWS 的硬件和 OS 优化](https://aws.amazon.com/amazon-linux-2/faqs/)，无需额外配置或 SRE 管理。

<a id="cpu-and-memory-recommendations"></a>

#### CPU 和内存建议

- 通用的 极狐GitLab Gitaly 节点 CPU 和内存建议假设各个仓库之间的负载相对均匀。对任何非特征性仓库进行 极狐GitLab 性能工具 (GPT) 测试和/或对 Gitaly 指标进行 SRE 监控，可能会提示何时选择高于通用建议的内存和/或 CPU。

**适应以下情况**：

- Git 包文件操作是内存和 CPU 密集型的。
- 如果仓库提交流量密集、庞大或非常频繁，则需要更多的 CPU 和内存来处理负载。诸如存储二进制文件和/或繁忙或大型单一仓库的模式是可能导致高负载的示例。

<a id="disk-io-recommendations"></a>

#### 磁盘 I/O 建议

- 仅使用 SSD 存储和适合你持久性和速度要求的 [Elastic Block Store (EBS) 存储类别](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html)。
- 当不使用预配置 EBS IO 时，EBS 卷大小决定 I/O 级别，因此配置比所需大得多的卷可能是提高 EBS IO 的成本最低的方式。
- 如果 Gitaly 性能监控显示磁盘压力迹象，则可以选择预配置 IOPS 级别之一。EBS IOPS 级别还具有增强的持久性，除了性能考虑外，对于某些实施可能具有吸引力。

**适应以下情况**：

- Gitaly 存储应为本地存储（非任何类型的 NFS，包括 EFS）。
- Gitaly 服务器还需要磁盘空间来构建和缓存 Git 包文件。这超出了 Git 仓库的永久存储需求。
- Git 包文件在 Gitaly 中缓存。在临时磁盘上创建包文件受益于快速磁盘，而包文件的磁盘缓存受益于充足的磁盘空间。

<a id="network-io-recommendations"></a>

#### 网络 I/O 建议

- 仅使用[支持 Elastic Network Adapter (ENA) 高级联网的实例类型](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#instance-type-summary-table)，以确保集群复制延迟不是由实例级网络 I/O 瓶颈引起的。
- 选择网络带宽超过 10 Gbps 的实例 - 但仅在需要时，且仅在通过监控和/或压力测试证明存在节点级网络瓶颈时才选择。

**适应以下情况**：

- Gitaly 节点主要负责为推送和拉取操作（向开发端点以及 CI/CD 推送）流式传输仓库。
- Gitaly 服务器需要在集群节点之间以及与 Praefect 服务之间保持合理的低延迟，以便集群保持运行和数据完整性。
- 选择 Gitaly 节点时应将避免网络瓶颈作为首要考虑。
- 应监控 Gitaly 节点的网络饱和情况。
- 并非所有网络问题都能通过优化节点级网络来解决：
  - Gitaly 集群 (Praefect) 节点复制取决于节点之间的所有网络连接。
  - Gitaly 与拉取和推送端点之间的网络性能取决于之间的所有网络连接。

<a id="aws-gitaly-backup"></a>

### AWS Gitaly 备份

由于 Praefect 跟踪 Gitaly 磁盘信息复制元数据的方式特性，最佳备份方法是[官方备份和恢复 Rake 任务](../../../administration/backup_restore/_index.md)。

<a id="aws-gitaly-recovery"></a>

### AWS Gitaly 恢复

Gitaly 集群 (Praefect) 不支持快照备份，因为这可能导致 Praefect 数据库与磁盘存储不同步的问题。由于 Praefect 在恢复期间重建 Gitaly 磁盘信息复制元数据的方式特性，最佳恢复方法是[官方备份和恢复 Rake 任务](../../../administration/backup_restore/_index.md)。

<a id="gitaly-long-term-management"></a>

### Gitaly 长期管理

必须监控并增加 Gitaly 节点磁盘大小，以适应 Git 仓库的增长以及 Gitaly 临时和缓存存储需求。所有节点上的存储配置应保持一致。