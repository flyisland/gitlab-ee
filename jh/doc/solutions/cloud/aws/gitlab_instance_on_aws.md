---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
title: 在 AWS 上部署极狐GitLab 实例
description: 用于在 AWS 上部署极狐GitLab 实例的可用基础设施即代码工具和经过验证的 AWS 托管服务。
---

<a id="available-infrastructure-as-code-for-gitlab-instance-installation-on-aws"></a>

## 在 AWS 上安装极狐GitLab 实例的可用基础设施即代码

[GitLab Environment Toolkit (GET)](https://jihulab.com/gitlab-cn/gitlab-environment-toolkit/-/blob/main/README.md) 是一组预设的 Terraform 和 Ansible 脚本。这些脚本用于帮助在选定云提供商上部署 Linux 软件包或云原生混合环境，并由极狐GitLab 开发者使用。

您可以使用 GitLab Environment Toolkit 在 AWS 上部署云原生混合环境。不过，它并非必需，也可能不支持所有有效排列组合。尽管如此，这些脚本按原样提供，您可以根据需要对其进行调整。

<a id="two-and-three-zone-high-availability"></a>

## 双区和三区高可用性

虽然极狐GitLab 参考架构通常鼓励三区冗余，但 AWS Well-Architected 框架将双区冗余视为架构完善。具体实施应根据自身的高可用性需求，权衡双区和三区配置的成本，以确定最终配置。

Gitaly 集群 (Praefect) 使用一致投票系统在同步节点之间实现强一致性。无论实施多少个可用区，集群中始终需要至少三个 Gitaly 节点和三个 Praefect 节点，以避免因偶数节点导致投票僵局。

<a id="aws-paas-qualified-for-all-gitlab-implementations"></a>

## 适用于所有极狐GitLab 实现的 AWS PaaS

对于使用 Linux 软件包或云原生混合实现，以下极狐GitLab 服务角色可由 AWS 服务 (PaaS) 执行。任何需要根据实例规模进行预配置的 PaaS 解决方案也将在每个实例规模的物料清单中列出。不需要特定规模调整的 PaaS 则不会在 BOM 列表中重复列出（例如，AWS Certification Manager）。

这些服务已经过极狐GitLab 测试。

某些服务（如日志聚合、外发邮件）并非由极狐GitLab 指定，但在提供时已作说明。

| 极狐GitLab 服务                                              | AWS PaaS (已测试)              |
| ------------------------------------------------------------ | ------------------------------ |
| <u>参考架构中提及的经过测试的 PaaS</u>      |                                |
| **PostgreSQL 数据库**                                      | Amazon RDS PostgreSQL          |
| **Redis 缓存**                                            | Redis ElastiCache              |
| **Gitaly 集群 (Git 仓库存储)**<br />(包括 Praefect 和 PostgreSQL) | ASG 和实例              |
| **除 Git 仓库存储之外的所有极狐GitLab 存储**<br />(包括与 S3 兼容的 Git-LFS) | AWS S3                         |
|                                                              |                                |
| <u>针对补充服务的经过测试的 PaaS</u>                 |                                |
| **前端负载均衡**                                 | AWS ELB                        |
| **内部负载均衡**                                  | AWS ELB                        |
| **外发邮件服务**                                  | AWS Simple Email Service (SES) |
| **证书颁发机构和管理**                     | AWS Certificate Manager (ACM)  |
| **DNS**                                                      | AWS Route53 (已测试)           |
| **极狐GitLab 和基础设施日志聚合**                | AWS CloudWatch Logs            |
| **基础设施性能指标**                       | AWS CloudWatch Metrics         |
|                                                              |                                |
| <u>补充服务和配置</u>              |                                |
| **极狐GitLab 的 Prometheus**                                    | AWS EKS (仅云原生)    |
| **极狐GitLab 的 Grafana**                                       | AWS EKS (仅云原生)    |
| **加密 (传输中/静态)**                        | AWS KMS                        |
| **用于配置的密钥存储**                         | AWS Secrets Manager            |
| **用于配置的配置数据**                      | AWS Parameter Store            |
| **Kubernetes 自动扩缩**                                   | EKS AutoScaling Agent          |

