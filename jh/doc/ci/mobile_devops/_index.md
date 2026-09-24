---
stage: Verify
group: Mobile DevOps
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 移动 DevOps
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用极狐GitLab CI/CD 构建、签名和发布适用于 Android 和 iOS 的原生和跨平台移动应用。
极狐GitLab 移动 DevOps 提供了工具和最佳实践，以自动化您的移动应用开发工作流。

极狐GitLab 移动 DevOps 将关键的移动开发能力集成到极狐GitLab DevSecOps 平台中：

- 适用于 iOS 和 Android 开发的构建环境
- 安全的代码签名和证书管理
- Google Play 和 Apple App Store 的应用商店分发

## 构建环境

要完全控制构建环境，您可以使用 [极狐GitLab 托管的 runner](../runners/_index.md)，或者设置 [私有化部署的 runner](https://gitlab.cn/docs/runner/#use-self-managed-runners)。

## 代码签名

所有 Android 和 iOS 应用在通过各种应用商店分发之前必须进行安全签名。签名可确保应用在到达用户设备之前未被篡改。

通过 [项目级安全文件](../secure_files/_index.md)，您可以将以下内容存储在极狐GitLab 中，以便在 CI/CD 构建中安全签名应用：

- 密钥库
- 配置文件
- 签名证书

## 分发

通过使用极狐GitLab 移动 DevOps 分发的集成，签名构建版本可以上传到 Google Play Store 或 Apple App Store。