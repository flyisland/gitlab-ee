---
stage: GitLab Delivery
group: Build
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包签名
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<!-- vale gitlab_base.SubstitutionWarning = NO -->

GitLab 生成的 Linux 软件包使用 [Omnibus](https://github.com/chef/omnibus) 创建，GitLab
在[自己的 fork](https://gitlab.com/gitlab-org/omnibus)中使用 `debsigs` 添加了 DEB 签名。

<!-- vale gitlab_base.SubstitutionWarning = YES -->

结合现有的 RPM 签名功能，这一新增能力使 GitLab 能够为所有受支持的发行版提供使用 DEB 或 RPM 的已签名软件包。

这些软件包由 GitLab CI 流程生成（参见 [`omnibus-gitlab` 项目](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/blob/master/.gitlab-ci.yml)），随后交付到 <https://packages.gitlab.com>，以确保软件包在交付给 GitLab 社区之前未被篡改。

<a id="gnupg-public-keys"></a>

## GnuPG 公钥

所有软件包均使用 [GnuPG](https://www.gnupg.org/) 按其格式适用的方式进行签名。用于签署这些软件包的密钥可在 [MIT PGP 公钥服务器](https://pgp.mit.edu)上找到，地址为
[`0x3cfcf9baf27eab47`](https://pgp.mit.edu/pks/lookup?op=vindex&search=0x3CFCF9BAF27EAB47)。

<a id="verifying-signatures"></a>

## 验证签名

有关如何验证极狐GitLab 软件包签名的信息，请参见[软件包签名](https://gitlab.cn/docs/omnibus/update/package_signatures/)。

<a id="gpg-signature-management"></a>

## GPG 签名管理

有关极狐GitLab 如何管理用于软件包签名的 GPG 密钥的信息，请参见 [runbook](https://gitlab.com/gitlab-com/runbooks/-/blob/master/docs/packaging/manage-package-signing-keys.md)。
