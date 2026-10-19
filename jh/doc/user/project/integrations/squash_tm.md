---
stage: Plan
group: Portfolio Planning
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Squash TM
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在极狐GitLab 中启用并配置 [Squash TM](https://www.squashtest.com/en/squash-gitlab-platform)（测试管理）集成后，在极狐GitLab 中创建的议题（通常是用户故事）会同步为 Squash TM 中的需求，测试进度则会在极狐GitLab 议题中报告。


<a id="configure-squash-tm"></a>

## 配置 Squash TM

1. 可选。请您的系统管理员[在属性文件中配置令牌](https://tm-en.doc.squashtest.com/latest/redirect/gitlab-integration-token.html)。
1. 按照 [Squash TM 文档](https://tm-en.doc.squashtest.com/latest/redirect/gitlab-integration-configuration.html)执行以下操作：
   1. 创建极狐GitLab 服务器。
   1. 启用 `Xsquash4GitLab` 插件。
   1. 配置同步。
   1. 在**实时同步**面板中，复制以下字段，以便稍后在极狐GitLab 中使用：

      - **Webhook URL**。
      - **密钥令牌**（如果您的 Squash TM 系统管理员在步骤 1 中配置了）。

<a id="configure-gitlab"></a>

## 配置极狐GitLab

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Squash TM**。
1. 确保已启用**活跃**开关。
1. 在**触发器**部分，指明实时同步涉及哪种类型的议题。
1. 填写以下字段：

   - 输入 **Squash TM webhook URL**。
   - 如果您的 Squash TM 系统管理员之前配置了**密钥令牌**，请输入该令牌。
