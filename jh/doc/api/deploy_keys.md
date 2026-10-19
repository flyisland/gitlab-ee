---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 部署密钥 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与[部署密钥](../user/project/deploy_keys/_index.md)交互。

<a id="deploy-key-fingerprints"></a>

## 部署密钥指纹

部分端点在响应中返回公钥指纹。您可以使用这些指纹来识别创建该部署密钥的用户。更多信息，请参阅[通过部署密钥指纹获取用户](keys.md#retrieve-user-by-deploy-key-fingerprint)。

以下属性包含部署密钥指纹：

- `fingerprint`：使用 MD5 哈希。在启用了 FIPS 的系统上不可用。
- `fingerprint_sha256`：使用 SHA256 哈希。

<a id="list-all-deploy-keys"></a>

## 列出所有部署密钥

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

获取极狐GitLab 实例所有项目中的所有部署密钥列表。此端点需要管理员访问权限，并且在 JihuLab.com 上不可用。

```plaintext
GET /deploy_keys
```

支持的属性：

| 属性   | 类型     | 是否必需 | 描述           |
|:------------|:---------|:---------|:----------------------|
| `public` | boolean | 否 | 仅返回公开的部署密钥。默认为 `false`。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/deploy_keys?public=true"
```

示例响应：

```json
[
  {
    "id": 1,
    "title": "Public key",
    "key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDNJAkI3Wdf0r13c8a5pEExB2YowPWCSVzfZV22pNBc1CuEbyYLHpUyaD0GwpGvFdx2aP7lMEk35k6Rz3ccBF6jRaVJyhsn5VNnW92PMpBJ/P1UebhXwsFHdQf5rTt082cSxWuk61kGWRQtk4ozt/J2DF/dIUVaLvc+z4HomT41fQ==",
    "fingerprint": "4a:9d:64:15:ed:3a:e6:07:6e:89:36:b3:3b:03:05:d9",
    "fingerprint_sha256": "SHA256:Jrs3LD1Ji30xNLtTVf9NDCj7kkBgPBb2pjvTZ3HfIgU",
    "created_at": "2013-10-02T10:12:29Z",
    "expires_at": null,
    "projects_with_write_access": [
      {
        "id": 73,
        "description": null,
        "name": "project2",
        "name_with_namespace": "Sidney Jones / project2",
        "path": "project2",
        "path_with_namespace": "sidney_jones/project2",
        "created_at": "2021-10-25T18:33:17.550Z"
      },
      {
        "id": 74,
        "description": null,
        "name": "project3",
        "name_with_namespace": "Sidney Jones / project3",
        "path": "project3",
        "path_with_namespace": "sidney_jones/project3",
        "created_at": "2021-10-25T18:33:17.666Z"
      }
    ],
    "projects_with_readonly_access": []
  },
  {
    "id": 3,
    "title": "Another Public key",
    "key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDIJFwIL6YNcCgVBLTHgM6hzmoL5vf0ThDKQMWT3HrwCjUCGPwR63vBwn6+/Gx+kx+VTo9FuojzR0O4XfwD3LrYA+oT3ETbn9U4e/VS4AH/G4SDMzgSLwu0YuPe517FfGWhWGQhjiXphkaQ+6bXPmcASWb0RCO5+pYlGIfxv4eFGQ==",
    "fingerprint": "0b:cf:58:40:b9:23:96:c7:ba:44:df:0e:9e:87:5e:75",
    "": "SHA256:lGI/Ys/Wx7PfMhUO1iuBH92JQKYN+3mhJZvWO4Q5ims",
    "created_at": "2013-10-02T11:12:29Z",
    "expires_at": null,
    "projects_with_write_access": [],
    "projects_with_readonly_access": [
      {
        "id": 74,
        "description": null,
        "name": "project3",
        "name_with_namespace": "Sidney Jones / project3",
        "path": "project3",
        "path_with_namespace": "sidney_jones/project3",
        "created_at": "2021-10-25T18:33:17.666Z"
      }
    ]
  }
]
```

<a id="add-deploy-key"></a>

## 添加部署密钥

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

为极狐GitLab 实例创建部署密钥。此端点需要管理员访问权限。

```plaintext
POST /deploy_keys
```

支持的属性：

| 属性     | 类型     | 是否必需 | 描述                                                                                                                       |
|:--------------|:---------|:---------|:----------------------------------------------------------------------------------------------------------------------------------|
| `key`         | string   | 是      | 新部署密钥                                                                                                                    |
| `title`       | string   | 是      | 新部署密钥的标题                                                                                                            |
| `expires_at`  | datetime | 否       | 部署密钥的过期日期。如果未提供值则不会过期。预期为 ISO 8601 格式（`2024-12-31T08:00:00Z`） |

示例请求：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"title": "My deploy key", "key": "ssh-rsa AAAA...", "expires_at": "2024-12-31T08:00:00Z"}' \
     --url "https://gitlab.example.com/api/v4/deploy_keys/"
```

示例响应：

```json
{
  "id": 5,
  "title": "My deploy key",
  "key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDNJAkI3Wdf0r13c8a5pEExB2YowPWCSVzfZV22pNBc1CuEbyYLHpUyaD0GwpGvFdx2aP7lMEk35k6Rz3ccBF6jRaVJyhsn5VNnW92PMpBJ/P1UebhXwsFHdQf5rTt082cSxWuk61kGWRQtk4ozt/J2DF/dIUVaLvc+z4HomT41fQ==",
  "fingerprint": "4a:9d:64:15:ed:3a:e6:07:6e:89:36:b3:3b:03:05:d9",
  "fingerprint_sha256": "SHA256:Jrs3LD1Ji30xNLtTVf9NDCj7kkBgPBb2pjvTZ3HfIgU",
  "usage_type": "auth_and_signing",
  "created_at": "2024-10-03T01:32:21.992Z",
  "expires_at": "2024-12-31T08:00:00.000Z"
}
```

<a id="list-deploy-keys-for-project"></a>

## 列出项目的部署密钥

获取项目的部署密钥列表。

```plaintext
GET /projects/:id/deploy_keys
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/deploy_keys"
```

示例响应：

```json
[
  {
    "id": 1,
    "title": "Public key",
    "key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDNJAkI3Wdf0r13c8a5pEExB2YowPWCSVzfZV22pNBc1CuEbyYLHpUyaD0GwpGvFdx2aP7lMEk35k6Rz3ccBF6jRaVJyhsn5VNnW92PMpBJ/P1UebhXwsFHdQf5rTt082cSxWuk61kGWRQtk4ozt/J2DF/dIUVaLvc+z4HomT41fQ==",
    "fingerprint": "4a:9d:64:15:ed:3a:e6:07:6e:89:36:b3:3b:03:05:d9",
    "fingerprint_sha256": "SHA256:Jrs3LD1Ji30xNLtTVf9NDCj7kkBgPBb2pjvTZ3HfIgU",
    "created_at": "2013-10-02T10:12:29Z",
    "expires_at": null,
    "can_push": false
  },
  {
    "id": 3,
    "title": "Another Public key",
    "key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDIJFwIL6YNcCgVBLTHgM6hzmoL5vf0ThDKQMWT3HrwCjUCGPwR63vBwn6+/Gx+kx+VTo9FuojzR0O4XfwD3LrYA+oT3ETbn9U4e/VS4AH/G4SDMzgSLwu0YuPe517FfGWhWGQhjiXphkaQ+6bXPmcASWb0RCO5+pYlGIfxv4eFGQ==",
    "fingerprint": "0b:cf:58:40:b9:23:96:c7:ba:44:df:0e:9e:87:5e:75",
    "": "SHA256:lGI/Ys/Wx7PfMhUO1iuBH92JQKYN+3mhJZvWO4Q5ims",
    "created_at": "2013-10-02T11:12:29Z",
    "expires_at": null,
    "can_push": false
  }
]
```

<a id="list-project-deploy-keys-for-user"></a>

## 列出用户的项目部署密钥

获取指定用户（被请求者）与已认证用户（请求者）共有的[项目部署密钥](../user/project/deploy_keys/_index.md#scope)列表。它仅列出请求者和被请求者共有项目中已启用的项目密钥。

```plaintext
GET /users/:id_or_username/project_deploy_keys
```

参数：

| 属性          | 类型   | 是否必需 | 描述                                                        |
|------------------- |--------|----------|------------------------------------------------------------------- |
| `id_or_username`   | string | 是      | 要获取其项目部署密钥的用户的 ID 或用户名。 |

```json
[
  {
    "id": 1,
    "title": "Key A",
    "created_at": "2022-05-30T12:28:27.855Z",
    "expires_at": null,
    "key": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILkYXU2fVeO4/0rDCSsswP5iIX2+B6tv15YT3KObgyDl Key",
    "fingerprint": "40:8e:fa:df:70:f7:a7:06:1e:0d:6f:ae:f2:27:92:01",
    "fingerprint_sha256": "SHA256:Ojq2LZW43BFK/AMP81jBkDGn9YpPWYRNcViKBB44LPU"
  },
  {
    "id": 2,
    "title": "Key B",
    "created_at": "2022-05-30T13:34:56.219Z",
    "expires_at": null,
    "key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDNJAkI3Wdf0r13c8a5pEExB2YowPWCSVzfZV22pNBc1CuEbyYLHpUyaD0GwpGvFdx2aP7lMEk35k6Rz3ccBF6jRaVJyhsn5VNnW92PMpBJ/P1UebhXwsFHdQf5rTt082cSxWuk61kGWRQtk4ozt/J2DF/dIUVaLvc+z4HomT41fQ==",
    "fingerprint": "4a:9d:64:15:ed:3a:e6:07:6e:89:36:b3:3b:03:05:d9",
    "": "SHA256:Jrs3LD1Ji30xNLtTVf9NDCj7kkBgPBb2pjvTZ3HfIgU"
  }
]
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/20/project_deploy_keys"
```

示例响应：

```json
[
  {
    "id": 1,
    "title": "Key A",
    "created_at": "2022-05-30T12:28:27.855Z",
    "expires_at": "2022-10-30T12:28:27.855Z",
    "key": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILkYXU2fVeO4/0rDCSsswP5iIX2+B6tv15YT3KObgyDl Key",
    "fingerprint": "40:8e:fa:df:70:f7:a7:06:1e:0d:6f:ae:f2:27:92:01",
    "fingerprint_sha256": "SHA256:Ojq2LZW43BFK/AMP81jBkDGn9YpPWYRNcViKBB44LPU"
  }
]
```

<a id="retrieve-a-deploy-key"></a>

## 检索部署密钥

检索指定的部署密钥。

```plaintext
GET /projects/:id/deploy_keys/:key_id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `key_id`  | integer | 是 | 部署密钥的 ID |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/deploy_keys/1"
```

示例响应：

```json
{
  "id": 1,
  "title": "Public key",
  "key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDNJAkI3Wdf0r13c8a5pEExB2YowPWCSVzfZV22pNBc1CuEbyYLHpUyaD0GwpGvFdx2aP7lMEk35k6Rz3ccBF6jRaVJyhsn5VNnW92PMpBJ/P1UebhXwsFHdQf5rTt082cSxWuk61kGWRQtk4ozt/J2DF/dIUVaLvc+z4HomT41fQ==",
  "fingerprint": "4a:9d:64:15:ed:3a:e6:07:6e:89:36:b3:3b:03:05:d9",
  "fingerprint_sha256": "SHA256:Jrs3LD1Ji30xNLtTVf9NDCj7kkBgPBb2pjvTZ3HfIgU",
  "created_at": "2013-10-02T10:12:29Z",
  "expires_at": null,
  "can_push": false
}
```

<a id="add-a-deploy-key-for-a-project"></a>

## 为项目添加部署密钥

为指定项目添加部署密钥。

如果该部署密钥已存在于另一个项目中，则仅当原项目可由同一用户访问时，它才会加入当前项目。

```plaintext
POST /projects/:id/deploy_keys
```

| 属性    | 类型 | 是否必需 | 描述 |
| -----------  | ---- | -------- | ----------- |
| `id`         | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `key`        | string   | 是 | 新部署密钥 |
| `title`      | string   | 是 | 新部署密钥的标题 |
| `can_push`   | boolean  | 否  | 部署密钥是否可以推送到项目的代码仓库 |
| `expires_at` | datetime | 否 | 部署密钥的过期日期。如果未提供值则不会过期。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`） |

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"title": "My deploy key", "key": "ssh-rsa AAAA...", "can_push": true}' \
     --url "https://gitlab.example.com/api/v4/projects/5/deploy_keys/"
```

示例响应：

```json
{
  "key": "ssh-rsa AAAA...",
  "id": 12,
  "title": "My deploy key",
  "can_push": true,
  "created_at": "2015-08-29T12:44:31.550Z",
  "expires_at": null
}
```

<a id="update-a-deploy-key"></a>

## 更新部署密钥

更新项目的部署密钥。

```plaintext
PUT /projects/:id/deploy_keys/:key_id
```

| 属性  | 类型 | 是否必需 | 描述 |
| ---------  | ---- | -------- | ----------- |
| `id`       | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `key_id`   | integer | 是 | 部署密钥的 ID |
| `can_push` | boolean | 否  | 部署密钥是否可以推送到项目的代码仓库 |
| `title`    | string  | 否 | 新部署密钥的标题 |

> [!note]
> 您必须至少提供 `can_push` 或 `title` 之一。

```shell
curl --request PUT \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"title": "New deploy key", "can_push": true}' \
     --url "https://gitlab.example.com/api/v4/projects/5/deploy_keys/11"
```

示例响应：

```json
{
  "id": 11,
  "title": "New deploy key",
  "key": "ssh-rsa AAAA...",
  "created_at": "2015-08-29T12:44:31.550Z",
  "expires_at": null,
  "can_push": true
}
```

<a id="delete-a-deploy-key"></a>

## 删除部署密钥

从项目中移除部署密钥。如果该部署密钥仅用于此项目，则会从系统中删除。

```plaintext
DELETE /projects/:id/deploy_keys/:key_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `key_id`  | integer | 是 | 部署密钥的 ID |

```shell
curl --request DELETE \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/5/deploy_keys/13"
```

<a id="enable-a-deploy-key"></a>

## 启用部署密钥

为项目启用部署密钥以便使用。成功时返回已启用的密钥，状态码为 201。

```plaintext
POST /projects/:id/deploy_keys/:key_id/enable
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `key_id`  | integer | 是 | 部署密钥的 ID |

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/5/deploy_keys/12/enable"
```

示例响应：

```json
{
  "key": "ssh-rsa AAAA...",
  "id": 12,
  "title": "My deploy key",
  "created_at": "2015-08-29T12:44:31.550Z",
  "expires_at": null
}
```

<a id="add-deploy-keys-to-multiple-projects"></a>

## 将部署密钥添加到多个项目

如果您想将同一个部署密钥添加到同一群组中的多个项目，可以通过 API 实现。

首先，通过列出所有项目来找到您感兴趣的项目的 ID：

```shell
curl --request GET \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects"
```

或者查找群组的 ID：

```shell
curl --request GET \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/groups"
```

然后列出该群组中的所有项目（例如群组 1234）：

```shell
curl --request GET \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/groups/1234"
```

有了这些 ID，即可将同一个部署密钥添加到所有项目：

```shell
for project_id in 321 456 987; do
    curl --request POST \
         --header "PRIVATE-TOKEN: <your_access_token>" \
         --header "Content-Type: application/json" \
         --data '{"title": "my key", "key": "ssh-rsa AAAA..."}' \
         --url "https://gitlab.example.com/api/v4/projects/${project_id}/deploy_keys"
done
```
