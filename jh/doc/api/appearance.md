---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 应用外观 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 控制极狐GitLab 实例的外观。更多信息，请参见[极狐GitLab 外观](../administration/appearance.md)。

先决条件：

- 您必须拥有该实例的管理员访问权限。

<a id="retrieve-application-appearance"></a>

## 检索应用外观

检索此极狐GitLab 实例的外观配置。

```plaintext
GET /application/appearance
```

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/application/appearance"
```

示例响应：

```json
{
  "title": "GitLab Test Instance",
  "description": "gitlab-test.example.com",
  "pwa_name": "GitLab PWA",
  "pwa_short_name": "GitLab",
  "pwa_description": "GitLab as PWA",
  "pwa_icon": "/uploads/-/system/appearance/pwa_icon/1/pwa_logo.png",
  "logo": "/uploads/-/system/appearance/logo/1/logo.png",
  "header_logo": "/uploads/-/system/appearance/header_logo/1/header.png",
  "favicon": "/uploads/-/system/appearance/favicon/1/favicon.png",
  "member_guidelines": "Custom member guidelines",
  "new_project_guidelines": "Please read the FAQs for help.",
  "profile_image_guidelines": "Custom profile image guidelines",
  "header_message": "",
  "footer_message": "",
  "message_background_color": "#e75e40",
  "message_font_color": "#ffffff",
  "email_header_and_footer_enabled": false,
  "site_name": "Production"
}
```

<a id="update-application-appearance"></a>

## 更新应用外观

更新此极狐GitLab 实例的外观配置。

```plaintext
PUT /application/appearance
```

| 属性                         | 类型    | 是否必需 | 描述 |
|-----------------------------------|---------|----------|-------------|
| `title`                           | string  | 否       | 登录页面和新用户账号页面上的实例标题 |
| `description`                     | string  | 否       | 登录页面和新用户账号页面上显示的 Markdown 文本 |
| `pwa_name`                        | string  | 否       | 渐进式 Web 应用的全名。用于 `manifest.json`中的 `name` 属性。 |
| `pwa_short_name`                  | string  | 否       | 渐进式 Web 应用的短名称。 |
| `pwa_description`                 | string  | 否       | 对渐进式 Web 应用功能的说明。用于 `manifest.json`中的 `description` 属性。 |
| `pwa_icon`                        | mixed   | 否       | 用于渐进式 Web 应用的图标。请参见[更新应用标志](#update-application-logo)。 |
| `logo`                            | mixed   | 否       | 登录页面和新用户账号页面上使用的实例图像。请参见[更新应用标志](#update-application-logo) |
| `header_logo`                     | mixed   | 否       | 用于主导航栏的实例图像 |
| `favicon`                         | mixed   | 否       | `.ico` 或 `.png` 格式的实例网站图标 |
| `member_guidelines`               | string  | 否       | 在群组或项目成员页面上向有权更改成员的用户显示的 Markdown 文本 |
| `new_project_guidelines`          | string  | 否       | 新项目页面上显示的 Markdown 文本 |
| `profile_image_guidelines`        | string  | 否       | 个人资料页面上公开头像下方显示的 Markdown 文本 |
| `header_message`                  | string  | 否       | 系统页眉栏中的消息 |
| `footer_message`                  | string  | 否       | 系统页脚栏中的消息 |
| `message_background_color`        | string  | 否       | 系统页眉/页脚栏的背景颜色 |
| `message_font_color`              | string  | 否       | 系统页眉/页脚栏的字体颜色 |
| `email_header_and_footer_enabled` | boolean | 否       | 如果启用，则为所有外发电子邮件添加页眉和页脚 |
| `site_name`                       | string  | 否       | 在页面标题后附加站点名称。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/application/appearance?email_header_and_footer_enabled=true&header_message=test"
```

示例响应：

```json
{
  "title": "GitLab Test Instance",
  "description": "gitlab-test.example.com",
  "pwa_name": "GitLab PWA",
  "pwa_short_name": "GitLab",
  "pwa_description": "GitLab as PWA",
  "pwa_icon": "/uploads/-/system/appearance/pwa_icon/1/pwa_logo.png",
  "logo": "/uploads/-/system/appearance/logo/1/logo.png",
  "header_logo": "/uploads/-/system/appearance/header_logo/1/header.png",
  "favicon": "/uploads/-/system/appearance/favicon/1/favicon.png",
  "member_guidelines": "Custom member guidelines",
  "new_project_guidelines": "Please read the FAQs for help.",
  "profile_image_guidelines": "Custom profile image guidelines",
  "header_message": "test",
  "footer_message": "",
  "message_background_color": "#e75e40",
  "message_font_color": "#ffffff",
  "email_header_and_footer_enabled": true,
  "site_name": ""
}
```

<a id="update-application-logo"></a>

## 更新应用标志

使用包含的图像文件更新此极狐GitLab 实例的标志。

要从本地文件系统上传头像，请使用 `--form` 参数包含该文件。这会使 cURL 使用请求头 `Content-Type: multipart/form-data` 提交数据。`file=` 参数必须指向您文件系统上的图像文件，并且前面加上 `@`。

```plaintext
PUT /application/appearance
```

| 属性  | 类型  | 是否必需 | 描述 |
|------------|-------|----------|-------------|
| `logo`     | mixed | 是      | 用作标志的图像。 |
| `pwa_icon` | mixed | 是      | 用于渐进式 Web 应用的图像。 |

示例请求：

```shell
curl --location --request PUT \
  --url "https://gitlab.example.com/api/v4/application/appearance?data=image/png" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: multipart/form-data" \
  --form "logo=@/path/to/logo.png"
```

示例响应：

```json
{
  "logo":"/uploads/-/system/appearance/logo/1/logo.png"
}
```
