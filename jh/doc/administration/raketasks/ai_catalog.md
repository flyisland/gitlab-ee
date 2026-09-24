---
stage: AI-powered
group: Workflow Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: AI Catalog Rake 任务
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供了一个 Rake 任务，用于为私有化部署的 AI Catalog 填充以下外部代理：

- 国内 SOTA 模型
- 国内 SOTA 模型

<a id="seed-ai-catalog-external-agents"></a>

## 填充 AI Catalog 外部代理

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```shell
sudo gitlab-rake gitlab:ai_catalog:seed_external_agents
```

{{< /tab >}}

{{< tab title="自编译 (源代码)" >}}

```shell
bundle exec rake gitlab:ai_catalog:seed_external_agents
```

{{< /tab >}}

{{< /tabs >}}