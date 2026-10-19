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

使用极狐GitLab CI/CD 构建、签名并发布面向 Android 和 iOS 的原生及跨平台移动应用。极狐GitLab 移动 DevOps 提供工具和最佳实践，帮助您自动化移动应用开发工作流。

极狐GitLab 移动 DevOps 将关键的移动开发能力集成到极狐GitLab DevSecOps 平台中：

- 适用于 iOS 和 Android 开发的构建环境
- 安全的代码签名和证书管理
- 面向 Google Play 和 Apple App Store 的应用商店分发

<a id="build-environments"></a>

## 构建环境

如需完全控制构建环境，您可以使用[极狐GitLab 托管的 Runner](../runners/_index.md)，或设置[私有化部署 Runner](https://gitlab.cn/docs/runner/#use-self-managed-runners)。

<a id="code-signing"></a>

## 代码签名

所有 Android 和 iOS 应用在通过各应用商店分发之前，都必须经过安全签名。签名可确保应用在到达用户设备之前未被篡改。

借助[项目级安全文件](../secure_files/_index.md)，您可以将以下内容存储在极狐GitLab 中，以便在 CI/CD 构建中安全地为应用签名：

- 密钥库
- 预置描述文件
- 签名证书

<a id="distribution"></a>

## 分发

已签名的构建产物可以通过移动 DevOps 分发集成上传到 Google Play 商店或 Apple App Store。
