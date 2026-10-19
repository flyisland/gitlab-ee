---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 测试环境的应用
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

这是极狐GitLab 支持团队收集的测试环境相关信息，供故障排除时使用。此处列出这些信息是为了保持透明，对于熟悉这些工具的用户可能也有帮助。如果您当前在使用极狐GitLab 时遇到问题，在尝试使用这些信息之前，不妨先查看[支持选项](https://gitlab.cn/support)。

> [!note]
> 本页面最初是为支持工程师编写的，因此部分链接仅在 GitLab 内部可用。

<a id="docker"></a>

## Docker

以下内容已在云端运行的 Docker 容器上测试过。支持工程师请参阅[这些文档](https://gitlab.com/gitlab-com/dev-resources/tree/master/dev-resources#running-docker-containers)，了解如何在 `dev-resources` 上运行 Docker 容器。其他环境尚未测试，但欢迎贡献。

<a id="gitlab"></a>

### 极狐GitLab

关于如何在 Docker 上运行极狐GitLab，请参阅[我们的官方 Docker 安装方法](../../install/docker/_index.md)。

<a id="saml"></a>

### SAML

<a id="saml-for-authentication"></a>

#### 用于身份验证的 SAML

在以下示例中，替换 `<GITLAB_IP_OR_DOMAIN>` 和 `<SAML_IP_OR_DOMAIN>` 时，务必在 IP 或域名前加上所使用的协议（`http://` 或 `https://`）。

我们可以使用 [`test-saml-idp` Docker 镜像](https://hub.docker.com/r/jamedjo/test-saml-idp)来替我们完成这项工作：

```shell
docker run --name gitlab_saml -p 8080:8080 -p 8443:8443 \
-e SIMPLESAMLPHP_SP_ENTITY_ID=<GITLAB_IP_OR_DOMAIN> \
-e SIMPLESAMLPHP_SP_ASSERTION_CONSUMER_SERVICE=<GITLAB_IP_OR_DOMAIN>/users/auth/saml/callback \
-d jamedjo/test-saml-idp
```

以下内容也必须写入您的 `/etc/gitlab/gitlab.rb`。更多信息请参阅[我们的 SAML 文档](../../integration/saml.md)，以及[默认用户名、密码和电子邮件](https://hub.docker.com/r/jamedjo/test-saml-idp/#usage)列表。

```ruby
gitlab_rails['omniauth_enabled'] = true
gitlab_rails['omniauth_allow_single_sign_on'] = ['saml']
gitlab_rails['omniauth_sync_email_from_provider'] = 'saml'
gitlab_rails['omniauth_sync_profile_from_provider'] = ['saml']
gitlab_rails['omniauth_sync_profile_attributes'] = ['email']
gitlab_rails['omniauth_auto_sign_in_with_provider'] = 'saml'
gitlab_rails['omniauth_block_auto_created_users'] = false
gitlab_rails['omniauth_auto_link_ldap_user'] = false
gitlab_rails['omniauth_auto_link_saml_user'] = true
gitlab_rails['omniauth_providers'] = [
  {
    "name" => "saml",
    "label" => "SAML",
    "args" => {
      assertion_consumer_service_url: '<GITLAB_IP_OR_DOMAIN>/users/auth/saml/callback',
      idp_cert_fingerprint: '119b9e027959cdb7c662cfd075d9e2ef384e445f',
      idp_sso_target_url: '<SAML_IP_OR_DOMAIN>:8080/simplesaml/saml2/idp/SSOService.php',
      issuer: '<GITLAB_IP_OR_DOMAIN>',
      name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
    }
  }
]
```

<a id="groupsaml-for-gitlabcom"></a>

#### 用于 JihuLab.com 的 GroupSAML

请参阅 [GDK SAML 文档](https://gitlab.com/gitlab-org/gitlab-development-kit/blob/main/doc/howto/saml.md)。

<a id="elasticsearch"></a>

### Elasticsearch

```shell
docker run -d --name elasticsearch \
-p 9200:9200 -p 9300:9300 \
-e "discovery.type=single-node" \
docker.elastic.co/elasticsearch/elasticsearch:5.5.1
```

然后在浏览器中通过 `curl "http://<IP_ADDRESS>:9200/_cat/health"` 确认其正常工作。在 Elasticsearch 中，默认用户名为 `elastic`，默认密码为 `changeme`。

<a id="kroki"></a>

### Kroki

关于如何在 Docker 中运行 Kroki，请参阅[我们的 Kroki 文档](../integration/kroki.md#docker)。

<a id="plantuml"></a>

### PlantUML

关于如何在 Docker 中运行 PlantUML，请参阅[我们的 PlantUML 文档](../integration/plantuml.md#docker)。

<a id="jira"></a>

### Jira

```shell
docker run -d -p 8081:8080 cptactionhank/atlassian-jira:latest
```

然后在浏览器中访问 `<IP_ADDRESS>:8081` 进行设置。这需要 Jira 许可证。

<a id="grafana"></a>

### Grafana

```shell
docker run -d --name grafana -e "GF_SECURITY_ADMIN_PASSWORD=gitlab" -p 3000:3000 grafana/grafana
```

通过 `<IP_ADDRESS>:3000` 访问它。
