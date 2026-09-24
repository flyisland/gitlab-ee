---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用集群管理项目安装 Ingress
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

假设你已经从 [管理项目模板](../../../../clusters/management_project_template.md) 创建了一个项目，为了安装 Ingress，你应该取消注释 `helmfile.yaml` 中的这一行：

```yaml
  - path: applications/ingress/helmfile.yaml
```

默认情况下，Ingress 安装在集群的 `gitlab-managed-apps` 命名空间中。

你可以通过更新集群管理项目中的 `applications/ingress/values.yaml` 文件来自定义 Ingress 的安装。有关可用的配置选项，请参阅 [chart](https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx)。