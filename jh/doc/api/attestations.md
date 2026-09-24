---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 证明 API
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- 状态：实验性

{{< /details >}}

{{< history >}}

- 引入于 极狐GitLab 18.5，通过一个[功能标志](../administration/feature_flags/_index.md)，名为 `slsa_provenance_statement`。默认禁用。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。
> 此功能可用于测试，但尚未准备好用于生产环境。

使用此 API 与[来源证明](../ci/pipeline_security/slsa/level_3/provenance_v1.md)进行交互。

<a id="provenance-attestations"></a>

## 来源证明

某些端点会返回 [Sigstore bundles](https://docs.sigstore.dev/about/bundle/) 作为响应的一部分。您可以使用 [glab](https://gitlab.cn/docs/cli/) 或 [cosign](https://github.com/sigstore/cosign) 来验证这些内容。有关来源的更多信息，请参阅 [SLSA 来源证明规范](../ci/pipeline_security/slsa/level_3/provenance_v1.md)。

<a id="list-all-attestations"></a>

## 列出所有证明

{{< history >}}

- 引入于 极狐GitLab 18.5。

{{< /history >}}

列出指定项目和 SHA-256 哈希的所有证明。

```plaintext
GET /:id/attestations/:subject_digest
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
| ---- | ---- | ---- | ---- |
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `subject_digest` | 字符串 | 是 | 产物的十六进制编码 SHA-256 哈希值 |

示例请求：

```shell
curl --request GET \
  --url "https://gitlab.example.com/api/v4/projects/namespace%2fproject/attestations/5db1fee4b5703808c48078a76768b155b421b210c0761cd6a5d223f4d99f1eaa"
```

示例响应：

```json
[
  {
    "id": 1,
    "iid": 1,
    "created_at": "2025-10-07T20:59:27.085Z",
    "updated_at": "2025-10-07T20:59:27.085Z",
    "expire_at": "2027-10-07T20:59:26.967Z",
    "project_id": 1,
    "build_id": 1,
    "status": "success",
    "predicate_kind": "provenance",
    "predicate_type": "https://slsa.dev/provenance/v1",
    "subject_digest": "76c34666f719ef14bd2b124a7db51e9c05e4db2e12a84800296d559064eebe2c",
    "download_url": "https://gitlab.example.com/api/v4/projects/1/attestations/1/download"
  }
]
```

<a id="download-an-attestation"></a>

## 下载证明

{{< history >}}

- 引入于 极狐GitLab 18.7。

{{< /history >}}

根据项目和证明 IID 下载特定的来源 Sigstore 包。该包本身在响应体中返回。有关此文件格式的更多信息，请参阅相关的 [Sigstore 文档](https://docs.sigstore.dev/about/bundle/)。

```plaintext
GET /:id/attestations/:attestation_iid/download
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
| ---- | ---- | ---- | ---- |
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `attestation_iid` | 整数 | 是 | 证明的 IID，由列出证明 API 端点返回。 |

示例请求：

```shell
curl --request GET \
  --url "https://gitlab.example.com/api/v4/projects/72356192/attestations/1/download
```

示例响应：

```json
{
  "mediaType": "application/vnd.dev.sigstore.bundle.v0.3+json",
  "verificationMaterial": {
    "certificate": {
      "rawBytes": "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"
    },
    "tlogEntries": [
[...]
```

