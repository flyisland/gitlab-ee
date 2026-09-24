---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Dockerfiles API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 为整个实例提供了 Dockerfile 模板的 API 端点。默认模板定义在极狐GitLab 仓库的 [`vendor/Dockerfile`](https://jihulab.com/gitlab-cn/gitlab-foss/-/tree/master/vendor/Dockerfile) 中。

拥有访客角色的用户无法访问 Dockerfiles 模板。更多信息，请参阅[项目和群组可见性](../../user/public_access.md)。

<a id="override-dockerfile-api-templates"></a>

## 覆盖 Dockerfile API 模板

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在[极狐GitLab 专业版和旗舰版](https://gitlab.cn/pricing/)中，极狐GitLab 实例管理员可以在[**管理员**区域](../../administration/settings/instance_template_repository.md)中覆盖模板。

<a id="list-all-dockerfile-templates"></a>

## 列出所有 Dockerfile 模板

列出所有 Dockerfile 模板。

```plaintext
GET /templates/dockerfiles
```

示例请求：

```shell
curl "https://gitlab.example.com/api/v4/templates/dockerfiles"
```

示例响应：

```json
[
  {
    "key": "Binary",
    "name": "Binary"
  },
  {
    "key": "Binary-alpine",
    "name": "Binary-alpine"
  },
  {
    "key": "Binary-scratch",
    "name": "Binary-scratch"
  },
  {
    "key": "Golang",
    "name": "Golang"
  },
  {
    "key": "Golang-alpine",
    "name": "Golang-alpine"
  },
  {
    "key": "Golang-scratch",
    "name": "Golang-scratch"
  },
  {
    "key": "HTTPd",
    "name": "HTTPd"
  },
  {
    "key": "Node",
    "name": "Node"
  },
  {
    "key": "Node-alpine",
    "name": "Node-alpine"
  },
  {
    "key": "OpenJDK",
    "name": "OpenJDK"
  },
  {
    "key": "PHP",
    "name": "PHP"
  },
  {
    "key": "Python",
    "name": "Python"
  },
  {
    "key": "Python-alpine",
    "name": "Python-alpine"
  },
  {
    "key": "Python2",
    "name": "Python2"
  },
  {
    "key": "Ruby",
    "name": "Ruby"
  },
  {
    "key": "Ruby-alpine",
    "name": "Ruby-alpine"
  },
  {
    "key": "Rust",
    "name": "Rust"
  },
  {
    "key": "Swift",
    "name": "Swift"
  }
]
```

<a id="retrieve-a-single-dockerfile-template"></a>

## 获取单个 Dockerfile 模板

获取单个 Dockerfile 模板。

```plaintext
GET /templates/dockerfiles/:key
```

| 属性 | 类型 | 是否必需 | 描述 |
|-------|------|----------|------|
| `key` | string | 是 | Dockerfile 模板的键 |

示例请求：

```shell
curl "https://gitlab.example.com/api/v4/templates/dockerfiles/Binary"
```

示例响应：

```json
{
  "name": "Binary",
  "content": "# This file is a template, and might need editing before it works on your project.\n# This Dockerfile installs a compiled binary into a bare system.\n# You must either commit your compiled binary into source control (not recommended)\n# or build the binary first as part of a CI/CD pipeline.\n\nFROM buildpack-deps:buster\n\nWORKDIR /usr/local/bin\n\n# Change `app` to whatever your binary is called\nAdd app .\nCMD [\"./app\"]\n"
}
```