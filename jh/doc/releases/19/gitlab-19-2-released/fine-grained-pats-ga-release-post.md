---
title: "细粒度 PAT 权限正式发布"
tier: [Free, Premium, Ultimate]
offering: [gitlab_com, self_managed, gitlab_dedicated]
stage: software_supply_chain_security
documentation_link: "../../../auth/tokens/fine_grained_access_tokens/"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/18554"
categories: [Permissions]
weight: 50
---

细粒度个人访问令牌（PAT）已正式发布。与旧版 PAT 不同（旧版 PAT 会授予您所属每个项目和群组的访问权限），细粒度 PAT 允许您将每个令牌限制在特定的资源和操作上。这使得在自动化和集成中应用最小权限原则更加容易，有助于降低令牌泄露或被盗用的潜在影响。

为简化设置，您可以在创建令牌时使用 **使用 Duo 添加权限** 功能来选择正确的权限。您现有的旧版 PAT 将继续像以前一样工作。对于新令牌，极狐GitLab 建议使用细粒度 PAT，以便每个令牌仅限定于其所需的资源和操作。

细粒度 PAT 已正式发布。它现已完全覆盖 REST API 端点，并覆盖最常用的 GraphQL 类型和变更操作。
