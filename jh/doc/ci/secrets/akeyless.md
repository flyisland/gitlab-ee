---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 在极狐GitLab CI/CD 中使用 Akeyless 密钥
---

{{< details >}}

- Status: 实验

{{< /details >}}

{{< history >}}

- 引入于GitLab 17.4。

{{< /history >}}

{{< alert type="flag" >}}

此功能是一个[实验](../../policy/development_stages_support.md)功能，并未生产就绪。这项功能不提供支持，且根据极狐GitLab 政策，可能随时被移除。

{{< /alert >}}

你可以使用 `secrets:akeyless` 关键字来认证和检索 Akeyless 密钥。

先决条件：

- 将你的 Akeyless 访问 ID 保存为 [私有化部署的极狐GitLab 项目中的 CI/CD 变量](../variables/_index.md#for-a-project)，命名为 `AKEYLESS_ACCESS_ID`。
- 此集成仅支持静态密钥。

要从 Akeyless 检索密钥，请查看适合你使用场景的 CI/CD 配置示例。`akeyless:name` 关键字可以包含任何类型的密钥。

<a id="jwt-authentication"></a>

## JWT 认证

```yaml
job:
  id_tokens:
    AKEYLESS_JWT:
      aud: 'https://gitlab.com'
  secrets:
    DATABASE_PASSWORD:
      token: $AKEYLESS_JWT
      akeyless:
        name: 'secret_name'
```

<a id="akeyless_token"></a>

## `akeyless_token`

```yaml
job:
  secrets:
    DATABASE_PASSWORD:
      akeyless:
        name: 'secret_name'
        akeyless_token: '<akeyless_token>'
```

<a id="akeyless-access-types"></a>

## Akeyless 访问类型

<a id="aws_iam"></a>

### `aws_iam`

```yaml
job:
  secrets:
    DATABASE_PASSWORD:
      akeyless:
        name: 'secret_name'
        akeyless_access_type: 'aws_iam'
```

<a id="azure_ad"></a>

### `azure_ad`

```yaml
job:
  secrets:
    DATABASE_PASSWORD:
      akeyless:
        name: 'secret_name'
        akeyless_access_type: 'azure_ad'
        azure_object_id: 'azure_object_id'
```

<a id="gcp"></a>

### `gcp`

```yaml
job:
  secrets:
    DATABASE_PASSWORD:
      akeyless:
        name: 'secret_name'
        akeyless_access_type: 'gcp'
        gcp_audience: 'gcp_audience'
```

<a id="universal_identity"></a>

### `universal_identity`

```yaml
job:
  secrets:
    DATABASE_PASSWORD:
      akeyless:
        name: 'secret_name'
        akeyless_access_type: 'universal_identity'
        uid_token: 'uid_token'
```

<a id="k8s"></a>

### `k8s`

```yaml
job:
  secrets:
    DATABASE_PASSWORD:
      akeyless:
        name: 'secret_name'
        akeyless_access_type: 'k8s'
        k8s_service_account_token: 'k8s_service_account_token'
        k8s_auth_config_name: 'k8s_auth_config_name'
        akeyless_api_url: 'akeyless_api_url'
```

<a id="api_key"></a>

### `api_key`

```yaml
job:
  secrets:
    DATABASE_PASSWORD:
      akeyless:
        name: 'secret_name'
        akeyless_access_type: 'api_key'
        akeyless_access_key: "<Access Key>"
```

如果你打算使用相同的 Akeyless 令牌获取多个密钥或运行多个作业，应该运行第一个作业以如下方式存储并重用相同的令牌作为专用的 CI/CD 变量。

<a id="jwt-reuse"></a>

## JWT 重用

当重用相同的令牌时，没有 `akeyless:name` 引用，这允许令牌被多个作业重用。

```yaml
job:  # This job fetches the Akeyless Token
  id_tokens:
    AKEYLESS_JWT:
      aud: 'https://gitlab.com'
  secrets:
    AKEYLESS_TOKEN:
      token: $AKEYLESS_JWT
      akeyless:
```

<a id="fetch-a-json-secret"></a>

## 获取 JSON 密钥

```yaml
job:
  id_tokens:
    AKEYLESS_JWT:
      aud: 'https://gitlab.com'
  secrets:
    DATABASE_PASSWORD:
      token: $AKEYLESS_JWT
      akeyless:
        name: 'secret_name'
        data_key: 'imp'
```

此示例获取 `imp` JSON 密钥。

<a id="issue-certificate"></a>

## 颁发证书

在颁发证书时使用 `public_key_data`。

<a id="ssh"></a>

### SSH

```yaml
job:
  id_tokens:
    AKEYLESS_JWT:
      aud: 'https://gitlab.com'
  secrets:
    DATABASE_PASSWORD:
      token: $AKEYLESS_JWT
      akeyless:
        name: 'secret_name'
        cert_user_name: 'cert_user_name'
        public_key_data: 'public_key_data'
```

<a id="issue-certificate-1"></a>

### 颁发证书

```yaml
job:
  id_tokens:
    AKEYLESS_JWT:
      aud: 'https://gitlab.com'
  secrets:
    DATABASE_PASSWORD:
      token: $AKEYLESS_JWT
      akeyless:
        name: 'secret_name'
        public_key_data: 'public_key_data'
```

你也可以使用 `csr_data` 替代 `public_key_data`。

<a id="work-with-a-gateway"></a>

## 使用网关

使用 `akeyless_api_url` 关键字设置你的网关 URL。在使用 CA 证书时，你也可以提供 `gateway_ca_certificate`：

```yaml
job:
  id_tokens:
    AKEYLESS_JWT:
      aud: 'https://gitlab.com'
  secrets:
    DATABASE_PASSWORD:
      token: $AKEYLESS_JWT
      akeyless:
        name: 'secret_name'
        akeyless_api_url: 'http://gateway_url:8080/v2'
        gateway_ca_certificate: 'ca_certificate'
```

<a id="troubleshooting"></a>

## 故障排除

<a id="the-secrets-provider-can-not-be-found-check-your-ci-cd-variables-and-try-again-message"></a>

### `The secrets provider can not be found. Check your CI/CD variables and try again.` 提示

当尝试启动配置为访问 Akeyless 的作业时，你可能会收到此错误：

```plaintext
The secrets provider can not be found. Check your CI/CD variables and try again.
```

作业无法创建，因为所需变量未定义：

- `AKEYLESS_ACCESS_ID`
