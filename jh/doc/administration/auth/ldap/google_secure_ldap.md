---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: Google Secure LDAP
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

[Google Cloud Identity](https://cloud.google.com/identity/) 提供一项 Secure LDAP 服务，可以配置 极狐GitLab 以进行身份验证和群组同步。

Secure LDAP 需要与标准 LDAP 服务器略有不同的配置。以下步骤涵盖：

- 在 Google 管理员控制台中配置 Secure LDAP 客户端。
- 极狐GitLab 所需的配置。

Secure LDAP 仅适用于特定的 Google Workspace 版本。更多信息，请参见 [Google Secure LDAP 服务文档](https://support.google.com/a/answer/9048516)。

<a id="configuring-google-ldap-client"></a>

## 配置 Google LDAP 客户端

1. 导航到 <https://admin.google.com/Dashboard> 并以 Google Workspace 域管理员身份登录。
1. 转到 **应用** > **LDAP** > **添加客户端**。
1. 提供一个 **LDAP 客户端名称** 和一个可选的 **描述**。任何描述性值均可接受。例如，名称可以是 `极狐GitLab`，描述可以是 `极狐GitLab LDAP 客户端`。选择 **继续**。

   ![显示添加 LDAP 客户端详细信息的 Google Workspace 窗口。](img/google_secure_ldap_add_step_1_v11_9.png)

1. 根据需求设置 **访问权限**。对于 **验证用户凭证** 和 **读取用户信息**，必须选择 `整个域（极狐GitLab）` 或 `选定的组织单元`。选择 **添加 LDAP 客户端**。

   > [!note]
   > 如果您计划使用极狐GitLab [LDAP 群组同步](ldap_synchronization.md#group-sync)，请开启 `读取群组信息`。

   ![显示添加 LDAP 客户端访问权限的 Google Workspace 窗口。](img/google_secure_ldap_add_step_2_v11_9.png)

1. 下载生成的证书。这是 极狐GitLab 与 Google Secure LDAP 服务通信所必需的。保存下载的证书以备后用。下载后，选择 **继续转到客户端详细信息**。
1. 展开 **服务状态** 部分，并将 LDAP 客户端切换为 `为所有人开启`。选择 **保存** 后，再次选择 **服务状态** 栏将其折叠，并返回其他设置。
1. 展开 **身份验证** 部分并选择 **生成新凭证**。复制/记录这些凭证以备后用。选择 **关闭** 后，再次选择 **身份验证** 栏将其折叠，并返回其他设置。

现在 Google Secure LDAP 客户端配置已完成。以下屏幕截图显示了最终设置的示例。继续配置 极狐GitLab。

![显示已为 极狐GitLab 配置 LDAP 设置的 Google Workspace 管理窗口。](img/google_secure_ldap_client_settings_v11_9.png)

<a id="configuring-gitlab"></a>

## 配置 极狐GitLab

编辑 极狐GitLab 配置，插入之前获取的访问凭证和证书。

以下是需要修改的配置键，使用之前在 LDAP 客户端配置过程中获取的值：

- `bind_dn`：访问凭证用户名
- `password`：访问凭证密码
- `cert`：下载的证书包中的 `.crt` 文件文本
- `key`：下载的证书包中的 `.key` 文件文本

对于 Linux 软件包安装：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_enabled'] = true
   gitlab_rails['ldap_servers'] = YAML.load <<-EOS # 记得在下方用 'EOS' 关闭此块
     main: # 'main' 是此 LDAP 服务器的 极狐GitLab '提供者 ID'
       label: 'Google Secure LDAP'

       host: 'ldap.google.com'
       port: 636
       uid: 'uid'
       bind_dn: 'DizzyHorse'
       password: 'd6V5H8nhMUW9AuDP25abXeLd'
       encryption: 'simple_tls'
       verify_certificates: true
       retry_empty_result_with_codes: [80]
       base: "DC=example,DC=com"
       tls_options:
         cert: |
           -----BEGIN CERTIFICATE-----
           MIIDbDCCAlSgAwIBAgIGAWlzxiIfMA0GCSqGSIb3DQEBCwUAMHcxFDASBgNVBAoTC0dvb2dsZSBJ
           bmMuMRYwFAYDVQQHEw1Nb3VudGFpbiBWaWV3MRQwEgYDVQQDEwtMREFQIENsaWVudDEPMA0GA1UE
           CxMGR1N1aXRlMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTAeFw0xOTAzMTIyMTE5
           MThaFw0yMjAzMTEyMTE5MThaMHcxFDASBgNVBAoTC0dvb2dsZSBJbmMuMRYwFAYDVQQHEw1Nb3Vu
           dGFpbiBWaWV3MRQwEgYDVQQDEwtMREFQIENsaWVudDEPMA0GA1UECxMGR1N1aXRlMQswCQYDVQQG
           EwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
           ALOTy4aC38dyjESk6N8fRsKk8DN23ZX/GaNFL5OUmmA1KWzrvVC881OzNdtGm3vNOIxr9clteEG/
           tQwsmsJvQT5U+GkBt+tGKF/zm7zueHUYqTP7Pg5pxAnAei90qkIRFi17ulObyRHPYv1BbCt8pxNB
           4fG/gAXkFbCNxwh1eiQXXRTfruasCZ4/mHfX7MVm8JmWU9uAVIOLW+DSWOFhrDQduJdGBXJOyC2r
           Gqoeg9+tkBmNH/jjxpnEkFW8q7io9DdOUqqNgoidA1h9vpKTs3084sy2DOgUvKN9uXWx14uxIyYU
           Y1DnDy0wczcsuRt7l+EgtCEgpsLiLJQbKW+JS1UCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAf60J
           yazhbHkDKIH2gFxfm7QLhhnqsmafvl4WP7JqZt0u0KdnvbDPfokdkM87yfbKJU1MTI86M36wEC+1
           P6bzklKz7kXbzAD4GggksAzxsEE64OWHC+Y64Tkxq2NiZTw/76POkcg9StiIXjG0ZcebHub9+Ux/
           rTncip92nDuvgEM7lbPFKRIS/YMhLCk09B/U0F6XLsf1yYjyf5miUTDikPkov23b/YGfpc8kh6hq
           1kqdi6a1cYPP34eAhtRhMqcZU9qezpJF6s9EeN/3YFfKzLODFSsVToBRAdZgGHzj//SAtLyQTD4n
           KCSvK1UmaMxNaZyTHg8JnMf0ZuRpv26iSg==
           -----END CERTIFICATE-----

         key: |
           -----BEGIN PRIVATE KEY-----
           MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCzk8uGgt/HcoxEpOjfH0bCpPAz
           dt2V/xmjRS+TlJpgNSls671QvPNTszXbRpt7zTiMa/XJbXhBv7UMLJrCb0E+VPhpAbfrRihf85u8
           7nh1GKkz+z4OacQJwHovdKpCERYte7pTm8kRz2L9QWwrfKcTQeHxv4AF5BWwjccIdXokF10U367m
           rAmeP5h31+zFZvCZllPbgFSDi1vg0ljhYaw0HbiXRgVyTsgtqxqqHoPfrZAZjR/448aZxJBVvKu4
           qPQ3TlKqjYKInQNYfb6Sk7N9POLMtgzoFLyjfbl1sdeLsSMmFGNQ5w8tMHM3LLkbe5fhILQhIKbC
           4iyUGylviUtVAgMBAAECggEAIPb0CQy0RJoX+q/lGbRVmnyJpYDf+115WNnl+mrwjdGkeZyqw4v0
           BPzkWYzUFP1esJRO6buBNFybQRFdFW0z5lvVv/zzRKq71aVUBPInxaMRyHuJ8D5lIL8nDtgVOwyE
           7DOGyDtURUMzMjdUwoTe7K+O6QBU4X/1pVPZYgmissYSMmt68LiP8k0p601F4+r5xOi/QEy44aVp
           aOJZBUOisKB8BmUXZqmQ4Cy05vU9Xi1rLyzkn9s7fxnZ+JO6Sd1r0Thm1mE0yuPgxkDBh/b4f3/2
           GsQNKKKCiij/6TfkjnBi8ZvWR44LnKpu760g/K7psVNrKwqJG6C/8RAcgISWQQKBgQDop7BaKGhK
           1QMJJ/vnlyYFTucfGLn6bM//pzTys5Gop0tpcfX/Hf6a6Dd+zBhmC3tBmhr80XOX/PiyAIbc0lOI
           31rafZuD/oVx5mlIySWX35EqS14LXmdVs/5vOhsInNgNiE+EPFf1L9YZgG/zA7OUBmqtTeYIPDVC
           7ViJcydItQKBgQDFmK0H0IA6W4opGQo+zQKhefooqZ+RDk9IIZMPOAtnvOM7y3rSVrfsSjzYVuMS
           w/RP/vs7rwhaZejnCZ8/7uIqwg4sdUBRzZYR3PRNFeheW+BPZvb+2keRCGzOs7xkbF1mu54qtYTa
           HZGZj1OsD83AoMwVLcdLDgO1kw32dkS8IQKBgFRdgoifAHqqVah7VFB9se7Y1tyi5cXWsXI+Wufr
           j9U9nQ4GojK52LqpnH4hWnOelDqMvF6TQTyLIk/B+yWWK26Ft/dk9wDdSdystd8L+dLh4k0Y+Whb
           +lLMq2YABw+PeJUnqdYE38xsZVHoDjBsVjFGRmbDybeQxauYT7PACy3FAoGBAK2+k9bdNQMbXp7I
           j8OszHVkJdz/WXlY1cmdDAxDwXOUGVKIlxTAf7TbiijILZ5gg0Cb+hj+zR9/oI0WXtr+mAv02jWp
           W8cSOLS4TnBBpTLjIpdu+BwbnvYeLF6MmEjNKEufCXKQbaLEgTQ/XNlchBSuzwSIXkbWqdhM1+gx
           EjtBAoGARAdMIiDMPWIIZg3nNnFebbmtBP0qiBsYohQZ+6i/8s/vautEHBEN6Q0brIU/goo+nTHc
           t9VaOkzjCmAJSLPUanuBC8pdYgLu5J20NXUZLD9AE/2bBT3OpezKcdYeI2jqoc1qlWHlNtVtdqQ2
           AcZSFJQjdg5BTyvdEDhaYUKGdRw=
           -----END PRIVATE KEY-----
   EOS
   ```

1. 保存文件并[重新配置](../../restart_gitlab.md#reconfigure-a-linux-package-installation) 极狐GitLab 以使更改生效。

对于自编译安装：

1. 编辑 `config/gitlab.yml`：

   ```yaml
   ldap:
     enabled: true
     servers:
       main: # 'main' 是此 LDAP 服务器的 极狐GitLab '提供者 ID'
         label: 'Google Secure LDAP'
         base: "DC=example,DC=com"
         host: 'ldap.google.com'
         port: 636
         uid: 'uid'
         bind_dn: 'DizzyHorse'
         password: 'd6V5H8nhMUW9AuDP25abXeLd'
         encryption: 'simple_tls'
         verify_certificates: true
         retry_empty_result_with_codes: [80]

         tls_options:
           cert: |
             -----BEGIN CERTIFICATE-----
             MIIDbDCCAlSgAwIBAgIGAWlzxiIfMA0GCSqGSIb3DQEBCwUAMHcxFDASBgNVBAoTC0dvb2dsZSBJ
             bmMuMRYwFAYDVQQHEw1Nb3VudGFpbiBWaWV3MRQwEgYDVQQDEwtMREFQIENsaWVudDEPMA0GA1UE
             CxMGR1N1aXRlMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTAeFw0xOTAzMTIyMTE5
             MThaFw0yMjAzMTEyMTE5MThaMHcxFDASBgNVBAoTC0dvb2dsZSBJbmMuMRYwFAYDVQQHEw1Nb3Vu
             dGFpbiBWaWV3MRQwEgYDVQQDEwtMREFQIENsaWVudDEPMA0GA1UECxMGR1N1aXRlMQswCQYDVQQG
             EwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
             ALOTy4aC38dyjESk6N8fRsKk8DN23ZX/GaNFL5OUmmA1KWzrvVC881OzNdtGm3vNOIxr9clteEG/
             tQwsmsJvQT5U+GkBt+tGKF/zm7zueHUYqTP7Pg5pxAnAei90qkIRFi17ulObyRHPYv1BbCt8pxNB
             4fG/gAXkFbCNxwh1eiQXXRTfruasCZ4/mHfX7MVm8JmWU9uAVIOLW+DSWOFhrDQduJdGBXJOyC2r
             Gqoeg9+tkBmNH/jjxpnEkFW8q7io9DdOUqqNgoidA1h9vpKTs3084sy2DOgUvKN9uXWx14uxIyYU
             Y1DnDy0wczcsuRt7l+EgtCEgpsLiLJQbKW+JS1UCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAf60J
             yazhbHkDKIH2gFxfm7QLhhnqsmafvl4WP7JqZt0u0KdnvbDPfokdkM87yfbKJU1MTI86M36wEC+1
             P6bzklKz7kXbzAD4GggksAzxsEE64OWHC+Y64Tkxq2NiZTw/76POkcg9StiIXjG0ZcebHub9+Ux/
             rTncip92nDuvgEM7lbPFKRIS/YMhLCk09B/U0F6XLsf1yYjyf5miUTDikPkov23b/YGfpc8kh6hq
             1kqdi6a1cYPP34eAhtRhMqcZU9qezpJF6s9EeN/3YFfKzLODFSsVToBRAdZgGHzj//SAtLyQTD4n
             KCSvK1UmaMxNaZyTHg8JnMf0ZuRpv26iSg==
             -----END CERTIFICATE-----

           key: |
             -----BEGIN PRIVATE KEY-----
             MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCzk8uGgt/HcoxEpOjfH0bCpPAz
             dt2V/xmjRS+TlJpgNSls671QvPNTszXbRpt7zTiMa/XJbXhBv7UMLJrCb0E+VPhpAbfrRihf85u8
             7nh1GKkz+z4OacQJwHovdKpCERYte7pTm8kRz2L9QWwrfKcTQeHxv4AF5BWwjccIdXokF10U367m
             rAmeP5h31+zFZvCZllPbgFSDi1vg0ljhYaw0HbiXRgVyTsgtqxqqHoPfrZAZjR/448aZxJBVvKu4
             qPQ3TlKqjYKInQNYfb6Sk7N9POLMtgzoFLyjfbl1sdeLsSMmFGNQ5w8tMHM3LLkbe5fhILQhIKbC
             4iyUGylviUtVAgMBAAECggEAIPb0CQy0RJoX+q/lGbRVmnyJpYDf+115WNnl+mrwjdGkeZyqw4v0
             BPzkWYzUFP1esJRO6buBNFybQRFdFW0z5lvVv/zzRKq71aVUBPInxaMRyHuJ8D5lIL8nDtgVOwyE
             7DOGyDtURUMzMjdUwoTe7K+O6QBU4X/1pVPZYgmissYSMmt68LiP8k0p601F4+r5xOi/QEy44aVp
             aOJZBUOisKB8BmUXZqmQ4Cy05vU9Xi1rLyzkn9s7fxnZ+JO6Sd1r0Thm1mE0yuPgxkDBh/b4f3/2
             GsQNKKKCiij/6TfkjnBi8ZvWR44LnKpu760g/K7psVNrKwqJG6C/8RAcgISWQQKBgQDop7BaKGhK
             1QMJJ/vnlyYFTucfGLn6bM//pzTys5Gop0tpcfX/Hf6a6Dd+zBhmC3tBmhr80XOX/PiyAIbc0lOI
             31rafZuD/oVx5mlIySWX35EqS14LXmdVs/5vOhsInNgNiE+EPFf1L9YZgG/zA7OUBmqtTeYIPDVC
             7ViJcydItQKBgQDFmK0H0IA6W4opGQo+zQKhefooqZ+RDk9IIZMPOAtnvOM7y3rSVrfsSjzYVuMS
             w/RP/vs7rwhaZejnCZ8/7uIqwg4sdUBRzZYR3PRNFeheW+BPZvb+2keRCGzOs7xkbF1mu54qtYTa
             HZGZj1OsD83AoMwVLcdLDgO1kw32dkS8IQKBgFRdgoifAHqqVah7VFB9se7Y1tyi5cXWsXI+Wufr
             j9U9nQ4GojK52LqpnH4hWnOelDqMvF6TQTyLIk/B+yWWK26Ft/dk9wDdSdystd8L+dLh4k0Y+Whb
             +lLMq2YABw+PeJUnqdYE38xsZVHoDjBsVjFGRmbDybeQxauYT7PACy3FAoGBAK2+k9bdNQMbXp7I
             j8OszHVkJdz/WXlY1cmdDAxDwXOUGVKIlxTAf7TbiijILZ5gg0Cb+hj+zR9/oI0WXtr+mAv02jWp
             W8cSOLS4TnBBpTLjIpdu+BwbnvYeLF6MmEjNKEufCXKQbaLEgTQ/XNlchBSuzwSIXkbWqdhM1+gx
             EjtBAoGARAdMIiDMPWIIZg3nNnFebbmtBP0qiBsYohQZ+6i/8s/vautEHBEN6Q0brIU/goo+nTHc
             t9VaOkzjCmAJSLPUanuBC8pdYgLu5J20NXUZLD9AE/2bBT3OpezKcdYeI2jqoc1qlWHlNtVtdqQ2
             AcZSFJQjdg5BTyvdEDhaYUKGdRw=
             -----END PRIVATE KEY-----
   ```

1. 保存文件并[重启](../../restart_gitlab.md#self-compiled-installations) 极狐GitLab 以使更改生效。

<a id="using-encrypted-credentials"></a>

## 使用加密凭证

您可以选择使用[与常规 LDAP 集成相同的步骤](_index.md#use-encrypted-credentials)，将 `bind_dn` 和 `password` 存储在单独的加密配置文件中。