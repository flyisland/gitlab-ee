---
stage: Application Security Testing
group: Secret Detection
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 检测到的密钥
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

此表列出了由以下方式检测到的密钥：

- 流水线密钥检测
- 客户端密钥检测
- 密钥推送保护

密钥检测规则在[默认规则集](https://jihulab.com/gitlab-cn/security-products/secret-detection/secret-detection-rules/-/tree/main)中更新。对于模式已被移除或更新的已检测密钥，它们将保持打开状态，以便你进行分类。

如果你想添加新的密钥检测规则，可以为所有极狐GitLab 用户[提议新的检测规则](pipeline/configure.md#propose-new-detection-rules)，或为你特定的项目[自定义规则集](pipeline/configure.md#customize-analyzer-rulesets)。

<!-- markdownlint-disable MD044 -->
<!-- vale gitlab_base.Spelling = NO -->
<!-- vale gitlab_base.SentenceSpacing = NO -->

| 描述 | ID | 流水线密钥检测 | 客户端密钥检测 | 密钥推送保护 |
|:---|:---|:---|:---|:---|
| Adafruit IO 密钥 | AdafruitIOKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Adobe 客户端 ID（OAuth Web） | Adobe Client ID (Oauth Web) | {{< yes >}} | {{< no >}} | {{< no >}} |
| Adobe 客户端密钥 | Adobe Client Secret | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Adobe IMS 访问令牌 | AdobeIMSAccessToken | {{< yes >}} | {{< no >}} | {{< no >}} |
| Age 密钥 | Age secret key | {{< yes >}} | {{< no >}} | {{< no >}} |
| Aiven 服务密码 | AivenServicePassword | {{< yes >}} | {{< no >}} | {{< yes >}} |
| 阿里云 AccessKey ID | Alibaba AccessKey ID | {{< yes >}} | {{< no >}} | {{< no >}} |
| 阿里云 Secret Key | Alibaba Secret Key | {{< yes >}} | {{< no >}} | {{< no >}} |
| Amazon OAuth 客户端 ID | AmazonOAuthClientID | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Anthropic API 密钥 | anthropic_key | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| Artifactory API 密钥 | ArtifactoryApiKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Artifactory 身份令牌 | ArtifactoryIdentityToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Asana 客户端 ID | Asana Client ID | {{< yes >}} | {{< no >}} | {{< no >}} |
| Asana 客户端密钥 | Asana Client Secret | {{< yes >}} | {{< no >}} | {{< no >}} |
| Asana 个人访问令牌 V1 | AsanaPersonalAccessTokenV1 | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Asana 个人访问令牌 V2 | AsanaPersonalAccessTokenV2 | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Atlassian API 密钥 | AtlassianApiKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Atlassian API 令牌 | Atlassian API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Atlassian 用户 API 令牌 | AtlassianUserApiToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Auth0 客户端密钥 | Auth0ClientSecret | {{< yes >}} | {{< no >}} | {{< no >}} |
| AWS 访问密钥 ID | AWS | {{< yes >}} | {{< no >}} | {{< yes >}} |
| AWS 秘密访问密钥 | AWSSecretAccessKey | {{< yes >}} | {{< no >}} | {{< no >}} |
| AWS 会话令牌 | AWSSessionToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| AWS Cognito 身份池 ID | AWSCognitoIdentityPoolID | {{< yes >}} | {{< no >}} | {{< no >}} |
| AWS Bedrock 密钥 | AWSBedrockKey | {{< yes >}} | {{< no >}} | {{< no >}} |
| AWS Bedrock 短期密钥 | AWSBedrockShortLivedKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Azure API 管理网关密钥 | AzureAPIManagementGatewayKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Azure API 管理直接密钥 | AzureAPIManagementDirectKey | {{< yes >}} | {{< no >}} | {{< no >}} |
| Azure 应用配置连接字符串 | AzureAppConfigConnectionString | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Azure 通信服务连接字符串 | AzureCommServicesConnectionString | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Azure Cosmos DB 凭据 | AzureCosmosDBCredentials | {{< yes >}} | {{< no >}} | {{< no >}} |
| Azure Entra 客户端密钥 | AzureEntraClientSecret | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Azure Entra 客户端 ID 令牌 | AzureEntraIDToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Azure 事件网格访问密钥 | AzureEventGridAccessKey | {{< yes >}} | {{< no >}} | {{< no >}} |
| Azure 函数 API 密钥 | AzureFunctionsAPIKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Azure 逻辑应用 SAS | AzureLogicAppSAS | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Azure OpenAI API 密钥 | AzureOpenAIAPIKey | {{< yes >}} | {{< no >}} | {{< no >}} |
| Azure 个人访问令牌 | AzurePersonalAccessToken | {{< yes >}} | {{< no >}} | {{< no >}} |
| Azure SignalR 访问密钥 | AzureSignalRAccessKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Beamer API 令牌 | Beamer API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Bitbucket 客户端 ID | Bitbucket client ID | {{< yes >}} | {{< no >}} | {{< no >}} |
| Bitbucket 客户端密钥 | Bitbucket client secret | {{< yes >}} | {{< no >}} | {{< no >}} |
| Brevo API 令牌 | Sendinblue API token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Brevo SMTP 令牌 | Sendinblue SMTP token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| 加拿大数字服务通知 API 密钥 | CDSCanadaNotifyAPIKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| CircleCI 访问令牌 | CircleCI access tokens | {{< yes >}} | {{< no >}} | {{< no >}} |
| CircleCI 个人访问令牌 | CircleCIPersonalAccessToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Clojars 部署令牌 | Clojars API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Contentful 交付 API 令牌 | Contentful delivery API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Contentful 个人访问令牌 | ContentfulPersonalAccessToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Contentful 预览 API 令牌 | Contentful preview API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Databricks API 令牌 | Databricks API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| DataDog API 密钥 | DataDogAPIKey | {{< yes >}} | {{< no >}} | {{< no >}} |
| DigitalOcean OAuth 访问令牌 | digitalocean-access-token | {{< yes >}} | {{< no >}} | {{< no >}} |
| DigitalOcean 个人访问令牌 | digitalocean-pat | {{< yes >}} | {{< no >}} | {{< no >}} |
| DigitalOcean 刷新令牌 | digitalocean-refresh-token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Discord API 密钥 | Discord API key | {{< yes >}} | {{< no >}} | {{< no >}} |
| Discord 客户端 ID | Discord client ID | {{< yes >}} | {{< no >}} | {{< no >}} |
| Discord 客户端密钥 | Discord client secret | {{< yes >}} | {{< no >}} | {{< no >}} |
| Docker 个人访问令牌 | DockerPersonalAccessToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Doppler API 令牌 | Doppler API token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Doppler 服务令牌 | Doppler Service token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Dropbox API 密钥/密钥对 | Dropbox API secret/key | {{< yes >}} | {{< no >}} | {{< no >}} |
| Dropbox 应用访问令牌 | DropboxAppAccessToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Dropbox 长期 API 令牌 | Dropbox long lived API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Dropbox 短期 API 令牌 | Dropbox short lived API token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Duffel API 令牌 | Duffel API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Dynatrace 平台令牌 | DynatracePlatformToken | {{< yes >}} | {{< no >}} | {{< no >}} |
| EasyPost 生产 API 密钥 | EasyPost API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| EasyPost 测试 API 密钥 | EasyPost test API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Facebook 令牌 | Facebook token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Fastly API 用户或自动化令牌 | Fastly API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Figma 个人访问令牌 | FigmaPersonalAccessToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Finicity API 令牌 | Finicity API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Finicity 客户端密钥 | Finicity client secret | {{< yes >}} | {{< no >}} | {{< no >}} |
| Flutterwave 生产加密密钥 | FlutterwaveProdEncryptedKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Flutterwave 测试加密密钥 | Flutterwave encrypted key | {{< yes >}} | {{< no >}} | {{< no >}} |
| Flutterwave 生产公钥 | FlutterwaveProdPublicKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Flutterwave 测试公钥 | Flutterwave public key | {{< yes >}} | {{< no >}} | {{< no >}} |
| Flutterwave 生产密钥 | FlutterwaveProdSecretKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Flutterwave 测试密钥 | Flutterwave secret key | {{< yes >}} | {{< no >}} | {{< no >}} |
| Frame.io API 令牌 | Frame.io API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| GCP API 密钥 | GCP API key | {{< yes >}} | {{< no >}} | {{< no >}} |
| GCP OAuth 客户端密钥 | GCP OAuth client secret | {{< yes >}} | {{< no >}} | {{< yes >}} |
| GCP Vertex 快速模式密钥 | GCPVertexExpressModeKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| GitHub 应用令牌 | Github App Token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| GitHub 应用安装令牌 | GithubAppInstallationToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| GitHub 细粒度个人访问令牌 | GithubFineGrainedPersonalAccessToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| GitHub OAuth 访问令牌 | Github OAuth Access Token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| GitHub 个人访问令牌（经典版） | Github Personal Access Token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| GitHub 刷新令牌 | Github Refresh Token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| 极狐GitLab CI/CD 作业令牌 | gitlab_ci_build_token | {{< yes >}} | {{< yes >}} | {{< no >}} |
| 极狐GitLab 部署令牌 | gitlab_deploy_token | {{< yes >}} | {{< yes >}} | {{< no >}} |
| 极狐GitLab 功能标志客户端令牌 | None | {{< no >}} | {{< yes >}} | {{< no >}} |
| 极狐GitLab 订阅令牌 | gitlab_feed_token | {{< yes >}} | {{< yes >}} | {{< no >}} |
| 极狐GitLab 订阅令牌 v2 | gitlab_feed_token_v2 | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 极狐GitLab 收件邮件令牌 | gitlab_incoming_email_token | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 极狐GitLab Kubernetes 代理令牌 | gitlab_kubernetes_agent_token | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 极狐GitLab OAuth 应用密钥 | gitlab_oauth_app_secret | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 极狐GitLab 个人访问令牌 | gitlab_personal_access_token | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 极狐GitLab 个人访问令牌（可路由） | gitlab_personal_access_token_routable | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 极狐GitLab 流水线触发令牌 | gitlab_pipeline_trigger_token | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 极狐GitLab Runner 认证令牌 | gitlab_runner_auth_token | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 极狐GitLab Runner 注册令牌 | gitlab_runner_registration_token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| 极狐GitLab SCIM OAuth 令牌 | gitlab_scim_oauth_token | {{< yes >}} | {{< yes >}} | {{< no >}} |
| GoCardless API 令牌 | GoCardless API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Google API 密钥 | GCP API key | {{< yes >}} | {{< no >}} | {{< no >}} |
| Google (GCP) 服务账户 | Google (GCP) Service-account | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Grafana 服务账户令牌 | GrafanaServiceAccountToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Grafana Cloud 访问策略令牌 | GrafanaCloudAccessPolicyToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| HashiCorp Terraform API 令牌 | Hashicorp Terraform user/org API token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| HashiCorp Vault 批量令牌 | Hashicorp Vault batch token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| HashiCorp Vault 服务令牌 | HashicorpVaultServiceToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Heroku API 密钥或应用授权令牌 | Heroku API Key | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Highnote 实时密钥 | HighnoteLiveSecretKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Highnote 测试密钥 | HighnoteTestSecretKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| HubSpot 私有应用 API 令牌 | Hubspot API token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Hugging Face 用户访问令牌 | HuggingFaceUserAccessToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Instagram 访问令牌 | Instagram access token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Intercom API 令牌 | Intercom API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Intercom 应用访问令牌 | IntercomAppAccessToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Intercom 客户端密钥或客户端 ID | Intercom client secret/ID | {{< yes >}} | {{< no >}} | {{< no >}} |
| Ionic 个人访问令牌 | Ionic API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| JFrog 平台访问令牌 | JfrogPlatformAccessToken | {{< yes >}} | {{< no >}} | {{< no >}} |
| Kubernetes 服务账户令牌 | KubernetesServiceAccToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| LangChain API 密钥 | LangChainAPIKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Linear API 令牌 | Linear API token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Linear 客户端密钥或 ID（OAuth 2.0） | Linear client secret/ID | {{< yes >}} | {{< no >}} | {{< no >}} |
| LinkedIn 客户端 ID | Linkedin Client ID | {{< yes >}} | {{< no >}} | {{< no >}} |
| LinkedIn 客户端密钥 | Linkedin Client secret | {{< yes >}} | {{< no >}} | {{< no >}} |
| Lob API 密钥 | Lob API Key | {{< yes >}} | {{< no >}} | {{< no >}} |
| Lob 可发布 API 密钥 | Lob Publishable API Key | {{< yes >}} | {{< no >}} | {{< no >}} |
| Mailchimp API 密钥 | Mailchimp API key | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Mailgun 私有 API 令牌 | Mailgun private API token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Mailgun 公共验证密钥 | Mailgun public validation key | {{< yes >}} | {{< no >}} | {{< no >}} |
| Mailgun Webhook 签名密钥 | Mailgun webhook signing key | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Mapbox API 令牌 | Mapbox API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Mapbox 密钥 API 令牌 | MapboxSecretApiToken | {{< yes >}} | {{< no >}} | {{< no >}} |
| MaxMind 许可证密钥 | MaxMind License Key | {{< yes >}} | {{< no >}} | {{< yes >}} |
| MessageBird 访问密钥 | messagebird-api-token | {{< yes >}} | {{< no >}} | {{< no >}} |
| MessageBird API 客户端 ID | MessageBird API client ID | {{< yes >}} | {{< no >}} | {{< no >}} |
| Meta 访问令牌 | Meta access token | {{< yes >}} | {{< no >}} | {{< no >}} |
| New Relic 注入浏览器 API 令牌 | New Relic ingest browser API token | {{< yes >}} | {{< no >}} | {{< no >}} |
| New Relic 注入浏览器 API 令牌 v2 | New Relic ingest browser API token v2 | {{< yes >}} | {{< no >}} | {{< yes >}} |
| New Relic REST API 密钥 | New Relic REST API Key | {{< yes >}} | {{< no >}} | {{< yes >}} |
| New Relic 用户 API ID | New Relic user API ID | {{< yes >}} | {{< no >}} | {{< yes >}} |
| New Relic 用户 API 密钥 | New Relic user API Key | {{< yes >}} | {{< no >}} | {{< yes >}} |
| npm 访问令牌 | npm access token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Oculus 访问令牌 | Oculus access token | {{< yes >}} | {{< no >}} | {{< no >}} |
| Okta API 令牌 | OktaAPIToken | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Okta 客户端密钥 | OktaClientSecret | {{< yes >}} | {{< no >}} | {{< no >}} |
| Onfido 实时 API 令牌 | Onfido Live API Token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| OpenAI API 密钥 | open ai token | {{< yes >}} | {{< no >}} | {{< no >}} |
| OpenAI 项目密钥 | OpenAiProjectKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| OpenAI 服务账户密钥 | OpenAiServiceAccountKey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| URL 中的密码 | Password in URL | {{< yes >}} | {{< no >}} | {{< no >}} |
| PGP 私钥 | PGP private key | {{< yes >}} | {{< no >}} | {{< no >}} |
| PKCS8 私钥 | PKCS8 private key | {{< yes >}} | {{< no >}} | {{< no >}} |
| PlanetScale API 令牌 | Planetscale API token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| PlanetScale 应用密钥 | PlanetscaleAppSecret | {{< yes >}} | {{< no >}} | {{< yes >}} |
| PlanetScale OAuth 密钥 | PlanetscaleOAuthSecret | {{< yes >}} | {{< no >}} | {{< yes >}} |
| PlanetScale 密码 | Planetscale password | {{< yes >}} | {{< no >}} | {{< yes >}} |
| PostHog 个人 API 密钥 | PostHogPersonalAPIkey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| PostHog 项目 API 密钥 | PostHogProjectAPIkey | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Postman API 令牌 | Postman API token | {{< yes >}} | {{< no >}} | {{< yes >}} |
| 密钥名称 | 描述 | 检测到 | 可撤销 | 推送保护 |
|-------------------------------------------|----------------------------------------------|----------|----------|----------|
| Postman Collection Access Key             | Postman 集合访问密钥                         | {{< yes >}} | {{< no >}} | {{< no >}} |
| Pulumi API token                          | Pulumi API 令牌                              | {{< yes >}} | {{< no >}} | {{< no >}} |
| PyPi upload token                         | PyPI 上传令牌                                | {{< yes >}} | {{< no >}} | {{< yes >}} |
| RSA private key                           | RSA 私钥                                     | {{< yes >}} | {{< no >}} | {{< no >}} |
| RubyGems API token                        | RubyGems API 令牌                            | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Segment public API token                  | Segment 公共 API 令牌                        | {{< yes >}} | {{< no >}} | {{< yes >}} |
| SendGrid API token                        | SendGrid API 令牌                            | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Shippo API token                          | Shippo API 令牌                              | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Shippo Test API token                     | Shippo 测试 API 令牌                         | {{< yes >}} | {{< no >}} | {{< no >}} |
| Shopify Partner API Token                 | Shopify 合作伙伴 API 令牌                    | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Shopify personal access token             | Shopify 个人访问令牌                         | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Shopify private app access token          | Shopify 私有应用访问令牌                     | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Shopify Custom App Access Token           | Shopify 自定义应用访问令牌                   | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Shopify shared secret                     | Shopify 共享密钥                             | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Slack App Configuration Token             | Slack 应用配置令牌                           | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Slack App Configuration Refresh Token     | Slack 应用配置刷新令牌                       | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Slack app level token                     | Slack 应用级令牌                             | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Slack bot user OAuth token                | Slack 机器人用户 OAuth 令牌                  | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Slack webhook                             | Slack Webhook                                | {{< yes >}} | {{< no >}} | {{< no >}} |
| SonarQube Global Analysis Token           | SonarQube 全局分析令牌                       | {{< yes >}} | {{< no >}} | {{< yes >}} |
| SonarQube Project Analysis Token          | SonarQube 项目分析令牌                       | {{< yes >}} | {{< no >}} | {{< yes >}} |
| SonarQube User Token                      | SonarQube 用户令牌                           | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Splunk Authentication Token               | Splunk 认证令牌                              | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Splunk HTTP Event Collector (HEC) Token    | Splunk HTTP 事件收集器 (HEC) 令牌            | {{< yes >}} | {{< no >}} | {{< no >}} |
| SSH (DSA) private key                     | SSH (DSA) 私钥                               | {{< yes >}} | {{< no >}} | {{< no >}} |
| SSH (EC) private key                      | SSH (EC) 私钥                                | {{< yes >}} | {{< no >}} | {{< no >}} |
| SSH private key                           | SSH 私钥                                     | {{< yes >}} | {{< no >}} | {{< no >}} |
| Stripe live restricted key                | Stripe 生产受限密钥                          | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Stripe live secret key                    | Stripe 生产密钥                              | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Stripe Live Short Secret Key              | Stripe 生产短密钥                            | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Stripe publishable live key               | Stripe 生产可发布密钥                        | {{< yes >}} | {{< no >}} | {{< no >}} |
| Stripe publishable test key               | Stripe 测试可发布密钥                        | {{< yes >}} | {{< no >}} | {{< no >}} |
| Stripe restricted test key                | Stripe 测试受限密钥                          | {{< yes >}} | {{< no >}} | {{< no >}} |
| Stripe secret test key                    | Stripe 测试密钥                              | {{< yes >}} | {{< no >}} | {{< no >}} |
| Stripe Test Short Secret Key              | Stripe 测试短密钥                            | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Tailscale OAuth Client Secret             | Tailscale OAuth 客户端密钥                   | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Tailscale API Access Token                | Tailscale API 访问令牌                       | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Tailscale Personal Auth Key               | Tailscale 个人认证密钥                       | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Tencent Cloud Secret ID                   | 腾讯云 Secret ID                             | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Twilio Account SID                        | Twilio 账户 SID                              | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Twilio API key                            | Twilio API 密钥                              | {{< yes >}} | {{< no >}} | {{< yes >}} |
| Twitch OAuth client secret                | Twitch OAuth 客户端密钥                      | {{< yes >}} | {{< no >}} | {{< no >}} |
| Typeform personal access token            | Typeform 个人访问令牌                        | {{< yes >}} | {{< no >}} | {{< no >}} |
| Volcengine Access Key ID                  | 火山引擎 Access Key ID                       | {{< yes >}} | {{< no >}} | {{< yes >}} |
| WakaTime API Key                          | WakaTime API 密钥                            | {{< yes >}} | {{< no >}} | {{< yes >}} |
| X token                                   | X (Twitter) 令牌                             | {{< yes >}} | {{< no >}} | {{< no >}} |
| Yandex.Cloud AWS API compatible access secret | Yandex.Cloud AWS API 兼容访问密钥        | {{< yes >}} | {{< no >}} | {{< no >}} |
| Yandex.Cloud API Key                      | Yandex.Cloud API 密钥                        | {{< yes >}} | {{< no >}} | {{< no >}} |
| Yandex.Cloud IAM cookie v1-1              | Yandex.Cloud IAM Cookie v1-1                 | {{< yes >}} | {{< no >}} | {{< no >}} |
| Yandex.Cloud IAM cookie v1-3              | Yandex.Cloud IAM Cookie v1-3                 | {{< yes >}} | {{< no >}} | {{< no >}} |

<!-- vale gitlab_base.SentenceSpacing = YES -->
<!-- vale gitlab_base.Spelling = YES -->
<!-- markdownlint-enable MD044 -->