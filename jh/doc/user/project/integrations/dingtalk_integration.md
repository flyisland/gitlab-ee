---
stage: Foundations
group: Import and Integrate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 钉钉命令
---

{{< details >}}

- Tier: 专业版, 旗舰版
- Offering: 私有化部署

{{< /details >}}

> - [引入](https://jihulab.com/gitlab-cn/gitlab/-/issues/531)于极狐GitLab 15.1，功能标志为 `dingtalk_integration`。默认禁用。
> - 功能标志 `dingtalk_integration` [移除](https://jihulab.com/gitlab-cn/gitlab/-/issues/533)于极狐GitLab 15.5。

当您想从钉钉上控制或查看极狐GitLab 内容时，您可以在钉钉中使用命令实现。首先您需要分别配置钉钉与极狐GitLab，完成集成。

## 配置钉钉

* 在钉钉中创建企业机器人
* 在钉钉群组中添加机器人

在钉钉中创建企业机器人：

1. 访问 [https://open.dingtalk.com](https://open.dingtalk.com)，进入 **钉钉开放平台** 页面，选择右上角 **开发者后台**。
2. 扫描二维码，登录进入您的组织。
3. 在顶部栏上，选择  **应用开发 > 企业内部开发**。
4. 在左侧边栏中，选择 **机器人**。在右侧页面中选择右上角的 **创建应用**。
5. 在弹出的窗口中填写应用名称、应用描述和应用图标，选择 **确定创建**。您可以记录跳转页面中显示的 **AppKey** 和 **AppSecret**，以便后续使用。
6. 在左侧边栏中，选择 **开发管理**，在右侧页面中填写 **服务器出口IP** 和 **消息接收地址**，其中 **服务器出口IP** 是您的极狐Gitlab 站点公网 IP，**消息接收地址** 需要以您的极狐Gitlab 站点网址或者 IP 作为前缀，后面补充 "/api/v4/integrations/dingtalk/robot"，比如 http://my-jihulab.com/api/v4/integrations/dingtalk/robot。
7. 在左侧边栏中，选择 **权限管理**。在右侧页面中申请 **企业内机器人发送消息权限**，确保您拥有该项权限。
8. 在左侧边栏中，选择 **版本管理与发布**，在右侧页面中选择 **上线**。


在钉钉群组中添加机器人：

1. 打开一个钉钉群组，选择右上角 **群设置** > **智能群助手**。
2. 选择 **添加机器人** 后面的三个点将您创建的机器人添加进来。


## 配置极狐GitLab

1. 启动极狐GitLab Rails 控制台，在控制台中运行 `Feature.enable(:dingtalk_integration)`, 完成钉钉特性开关的启用。详情请参见[功能标志文档](../../../administration/feature_flags.md)（功能标志为 dingtalk_integration，15.5 及之后的版本跳过此步骤）。
2. 以管理员身份登录极狐GitLab，在左侧边栏中选择 **管理中心** > **设置** > **通用**。
3. 选择 **钉钉集成** 右侧的 **展开**，勾选 **启用钉钉集成** 复选框，并填写
   **钉钉CorpId**、**钉钉AppKey** 和 **钉钉AppSecret**，选择 **保存更改**。
4. 在左侧边栏中，选择 **管理中心** > **设置** > **集成**。
5. 选择 **钉钉** > **设置**，输入 **钉钉CorpId**，选择 **保存更改**。

**提示**：**钉钉CorpId** 是您的企业在钉钉的唯一 ID，可以在钉钉开放平台的首页中查询到；**钉钉AppKey** 是钉钉机器人的 AppKey； **钉钉AppSecret** 是钉钉机器人的 AppSecret。

至此，您已经完成了钉钉和极狐GitLab 集成所需的所有配置工作。


