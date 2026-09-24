---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Snowflake
---

{{< details >}}

- Tier：专业版，旗舰版
- Offering：JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.1 中为审计事件引入。

{{< /history >}}

Snowflake [极狐GitLab Data Connector](https://app.snowflake.com/marketplace/listing/GZTYZXESENG/gitlab-gitlab-data-connector) 将数据拉取到 [Snowflake](https://www.snowflake.com/en/) 中。

然后，您可以在 Snowflake 中查看、合并、操作和报告所有数据。极狐GitLab Data Connector 基于[极狐GitLab REST API](../api/rest/_index.md)，需要同时配置 Snowflake 和极狐GitLab。

<a id="prerequisites"></a>

## 前提条件

1. 如果您没有极狐GitLab 个人访问令牌：
   1. 登录极狐GitLab。
   1. 按照 [创建个人访问令牌](../user/profile/personal_access_tokens.md#create-a-personal-access-token) 中的步骤操作。
1. 在 Snowflake 中创建[外部访问集成](https://docs.snowflake.com/en/developer-guide/external-network-access/creating-using-external-network-access)。更多信息，请参阅 `snowflake-connector` 项目中的[设置文档](https://jihulab.com/gitlab-cn/software-supply-chain-security/compliance/engineering/snowflake-connector#setup)。
1. 在 Snowflake 中创建一个[仓库](https://docs.snowflake.com/en/user-guide/warehouses-tasks#creating-a-warehouse)。

<a id="configure-the-gitlab-data-connector"></a>

## 配置极狐GitLab Data Connector

1. 登录 Snowflake。
1. 选择 **数据产品** > **市场**。
1. 搜索 **极狐GitLab Data Connector**。
1. 选择 **数据产品** > **应用**。
1. 选择 **极狐GitLab Data Connector**。
1. 选择极狐GitLab Data Connector 运行的[仓库](https://docs.snowflake.com/en/user-guide/warehouses)。
1. 选择 **开始配置**。
1. 选择 **授予权限**。
1. 输入目标仓库和模式。这些可以是您想要的任何仓库和模式。
1. 选择 **配置**。
1. 输入外部访问集成。
1. 输入存储极狐GitLab 个人访问令牌机密的路径。
1. 输入您的极狐GitLab 实例的域名。例如，`jihulab.com`。
1. 选择 **连接**。
1. 输入群组名称。例如，`my-group`。
1. 选择 **完成配置**。
1. 选择 **配置**。

<a id="view-data-in-snowflake"></a>

## 在 Snowflake 中查看数据

1. 登录 Snowflake。
1. 选择 **数据** > **数据库**。
1. 选择之前配置的仓库。