---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Snowflake
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Snowflake [极狐GitLab 数据连接器](https://app.snowflake.com/marketplace/listing/GZTYZXESENG/gitlab-gitlab-data-connector)会将数据拉取到 [Snowflake](https://www.snowflake.com/en/)中。

随后，您可以在 Snowflake 中查看、合并、操作并报告所有数据。极狐GitLab 数据连接器基于[极狐GitLab REST API](../api/rest/_index.md)，需要同时配置 Snowflake 和极狐GitLab。

<a id="prerequisites"></a>

## 先决条件

1. 如果您没有极狐GitLab 个人访问令牌：
   1. 登录极狐GitLab。
   1. 按照所列步骤[创建个人访问令牌](../user/profile/personal_access_tokens.md#create-a-personal-access-token)。
1. 在 Snowflake 中创建[外部访问集成](https://docs.snowflake.com/en/developer-guide/external-network-access/creating-using-external-network-access)。有关更多信息，请参阅 `snowflake-connector` 项目中的[设置文档](https://gitlab.com/gitlab-org/software-supply-chain-security/compliance/engineering/snowflake-connector#setup)。
1. 在 Snowflake 中创建[仓库](https://docs.snowflake.com/en/user-guide/warehouses-tasks#creating-a-warehouse)。

<a id="configure-the-gitlab-data-connector"></a>

## 配置极狐GitLab 数据连接器

1. 登录 Snowflake。
1. 选择 **数据产品** > **市场**。
1. 搜索 **GitLab Data Connector**。
1. 选择 **数据产品** > **应用**。
1. 选择 **GitLab Data Connector**。
1. 选择运行极狐GitLab 数据连接器的[仓库](https://docs.snowflake.com/en/user-guide/warehouses)。
1. 选择 **开始配置**。
1. 选择 **授予权限**。
1. 输入目标仓库和架构。它们可以是您想要的任意仓库和架构。
1. 选择 **配置**。
1. 输入外部访问集成。
1. 输入存储极狐GitLab 个人访问令牌密钥的路径。
1. 输入极狐GitLab 实例的域名。例如，`gitlab.com`。
1. 选择 **连接**。
1. 输入群组名称。例如，`my-group`。
1. 选择 **完成配置**。
1. 选择 **配置**。

<a id="enable-projects-and-groups"></a>

## 启用项目和群组

配置极狐GitLab 数据连接器后，您必须指定哪些项目或群组的审计事件会被采集到 Snowflake 中。如果未添加至少一个项目或群组，则不会采集任何数据。

<a id="enable-projects"></a>

### 启用项目

要添加您希望采集其审计事件的项目：

1. 登录 Snowflake。
1. 选择 **数据产品** > **应用**。
1. 选择 **GitLab Data Connector**。
1. 选择 **已启用的项目** 选项卡。
1. 输入您要启用的项目路径。例如，`my-group/my-project`。
1. 选择 **添加**。
1. 对每个其他项目重复此操作。

<a id="enable-groups"></a>

### 启用群组

要添加您希望采集其审计事件的群组：

1. 登录 Snowflake。
1. 选择 **数据产品** > **应用**。
1. 选择 **GitLab Data Connector**。
1. 选择 **已启用的群组** 选项卡。
1. 输入您要启用的群组路径。例如，`my-group`。
1. 选择 **添加**。
1. 对每个其他群组重复此操作。

<a id="view-data-in-snowflake"></a>

## 在 Snowflake 中查看数据

1. 登录 Snowflake。
1. 选择 **数据** > **数据库**。
1. 选择之前配置的仓库。

<a id="troubleshooting"></a>

## 故障排除

<a id="no-data-appearing-in-snowflake"></a>

### Snowflake 中未显示数据

如果 Snowflake 中未显示数据，请检查以下内容：

- 您尚未在 **已启用的项目** 或 **已启用的群组** 选项卡中添加至少一个项目或群组。
  有关更多信息，请参阅[启用项目和群组](#enable-projects-and-groups)。
- 极狐GitLab 个人访问令牌没有读取审计事件所需的范围。
- 为极狐GitLab 数据连接器配置的 Snowflake 仓库已暂停。
