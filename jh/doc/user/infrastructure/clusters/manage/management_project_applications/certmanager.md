---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用集群管理项目安装 cert-manager
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

假设你已经从
[管理项目模板](../../../../clusters/management_project_template.md) 创建了一个项目，要安装 cert-manager 你应
在 `helmfile.yaml` 中取消下面这一行的注释：

```yaml
  - path: applications/cert-manager/helmfile.yaml
```

并使用有效的电子邮件地址更新 `applications/cert-manager/helmfile.yaml`。

```yaml
  values:
    - letsEncryptClusterIssuer:
        #
        # 重要：此值必须设置为有效电子邮件。
        #
        email: example@example.com
```

> [!note]
> 如果你的 Kubernetes 版本低于 1.20 并且你正在
> [从极狐GitLab Managed Apps 迁移到集群管理项目](../../../../clusters/migrating_from_gma_to_project_template.md)，
> 那么你可以改用 `- path: applications/cert-manager-legacy/helmfile.yaml` 来
> 接管现有的 cert-manager v0.10 版本。

cert-manager：

- 默认安装到集群的 `gitlab-managed-apps` 命名空间中。
- 默认包含一个已启用的
  [Let's Encrypt `ClusterIssuer`](https://cert-manager.io/docs/configuration/acme/)。在 `certmanager-issuer` 版本中，该签发者需要为 `letsEncryptClusterIssuer.email` 提供一个有效的电子邮件地址。Let's Encrypt 使用此电子邮件地址
  就即将过期的证书以及与你账户相关的问题与你联系。
- 可以通过在 `applications/cert-manager/helmfile.yaml` 中向 `certmanager` 版本传递自定义
  `values` 来进行定制。可用的配置选项请参考
  [chart](https://github.com/jetstack/cert-manager)。