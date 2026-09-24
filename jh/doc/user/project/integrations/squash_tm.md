---
stage: Plan
group: Product Planning
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Squash TM
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 15.10。

{{< /history >}}

当 Squash TM（测试管理）集成在极狐GitLab 中启用并配置后，在极狐GitLab 中创建的议题（通常是用户故事）会作为需求同步到 Squash TM 中，并且测试进度会在极狐GitLab 议题中报告。

<a id="configure-squash-tm"></a>

## 配置 Squash TM

1. （可选）请系统管理员[在属性文件中配置令牌](https://tm-en.doc.squashtest.com/latest/redirect/gitlab-integration-token.html)。
1. 根据 [Squash TM 文档](https://tm-en.doc.squashtest.com/latest/redirect/gitlab-integration-configuration.html)执行以下操作：
   1. 创建一个极狐GitLab 服务器。
   1. 启用 `Xsquash4GitLab` 插件。
   1. 配置同步。
   1. 从 **实时同步** 面板中，复制以下字段以供稍后在极狐GitLab 中使用：

      - **Webhook URL**。
      - 如果在第1步中 Squash TM 系统管理员配置了密钥令牌，则复制 **密钥令牌**。

<a id="configure-gitlab"></a>

## 配置极狐GitLab

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Squash TM**。
1. 确保 **活跃** 开关已启用。
1. 在 **触发器** 部分，指定实时同步关注的是哪种议题类型。
1. 填写以下字段：

   - 输入 **Squash TM webhook URL**，
   - 如果 Squash TM 系统管理员之前配置了密钥令牌，则输入 **密钥令牌**。