---
stage: Foundations
group: Import and Integrate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: LigaAI 集成
---

{{< details >}}

- Tier: 专业版, 旗舰版
- Offering: 私有化部署

{{< /details >}}

> [引入](https://jihulab.com/gitlab-cn/gitlab/-/issues/2799)于极狐GitLab 16.1。[功能标志](../../../administration/feature_flags.md)为 `integration_with_ligaai_issues`，默认禁用。

如果您想在极狐GitLab 中实时同步查看 LigaAI 的工作项，如需求、任务或缺陷，您可以将极狐GitLab 与 LigaAI 集成，以便在极狐GitLab 中快速查看 LigaAI 工作项的标题、描述、指派人和创建时间等。

## 准备工作

在极狐GitLab 上配置 LigaAI 集成之前，您需要在 LigaAI 中获取必要信息，以供后续的集成配置使用。

### 获取 LigaAI 项目 ID

获取 LigaAI 项目 ID：

1. 使用您的账号和密码或手机号和验证码登录进入 LigaAI。
1. 在左侧边栏中，在 **项目** 下选择您想同步的项目。
1. 点击浏览器中的 URL，获取您需要的项目 ID。

以 [LigaAI](https://ligai.cn) 中的某个项目为例：

```
https://ligai.cn/app/project/automation?shortcut=shortcut&pid=102658443
```

在此示例中，`102658443` 即为 **LigaAI 项目 ID**。记录这个项目 ID，以供后续配置使用。

### 获取 LigaAI Client ID 和 LigaAI Secret Key

获取 LigaAI Client ID 和 LigaAI Secret Key：

1. 使用您的账号和密码或手机号和验证码登录进入 LigaAI。
1. 在 LigaAI 主页的左下角点击您的头像。
1. 在菜单栏中选择 **系统设置**。
1. 在左侧边栏中选择 **API 管理**。
1. 在 **API 管理** 页面中，选择右上角的 **创建 API**。
1. 在弹出的窗口中，按要求填写 API 名称、API 描述和 API 选择等。
1. 选择右下角的 **添加**。
1. 在跳转的页面中，记录 Client ID 和 Secret Key，以供后续配置使用。

NOTE:
您必须具有 LigaAI 的组织管理员身份才能访问 **系统设置**。

## 配置极狐GitLab

支持在项目级别集成 LigaAI，您需要在极狐GitLab 上完成以下步骤：

1. 在左侧边栏中，选择 **搜索或转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置 > 集成**。
1. 在 **添加集成** 下，选择 **LigaAI**。
1. 在 **启用集成** 下，勾选 **启用**。
1. 在 **LigaAI 网页 URL** 下，填写 "https://ligai.cn"（推荐）。 
1. 在 **LigaAI API URL（可选）** 下，填写 "https://ligai.cn/openapi/api"（推荐）。
1. 在 **LigaAI 项目 ID** 下，填写您在 LigaAI 中获取的项目 ID。
1. 在 **LigaAI Client ID** 下，填写您在 LigaAI 中获取的 Client ID。
1. 在 **LigaAI Secret Key** 下，填写您在 LigaAI 中获取的 Secret Key。
1. 填写完毕后，选择 **测试设置**。如果左下角出现"连接成功"，则表明配置正确；如果测试失败，您需要重新填写配置项。
1. 选择 **保存更改**。

NOTE:
如果您在 **LigaAI API URL（可选）** 下未填写任何内容，那么 **LigaAI 网页 URL** 必须填写为 "https://ligai.cn/openapi/api"。
有关更多内容，请参见 [LigaAI API 文档](https://apifox.com/apidoc/shared-8af53dca-b5fd-4de4-bc89-9a83f5444dae/api-64423737)。

## 在极狐GitLab 访问 LigaAI 工作项

完成以上配置后，您就可以在极狐GitLab 中快速访问 LigaAI 的工作项或访问 LigaAI 的官方网站：

1. 在左侧边栏中，选择 **搜索或转到** 并找到您集成了 LigaAI 的项目。
2. 在左侧边栏中，选择 **计划 > LigaAI 议题**。
 - 在 **LigaAI 议题** 页面中，您可以查看 **开放中**、**已关闭** 和 **全部** 的 LigaAI 议题，您还可以按照 **创建日期** 或 **更新日期** 进行排序或输入关键字检索所需议题。
 - 在 LigaAI 议题列表页面点击某个议题的标题，进入详情页面。详情页面展示 LigaAI 工作项的标题、描述、指派人、创建时间、截止日期、状态、标记和评论等。
3. 您也可以在左侧边栏中，选择 **计划 > 打开 LigaAI** 访问 LigaAI 官方网站进行登录或注册。
