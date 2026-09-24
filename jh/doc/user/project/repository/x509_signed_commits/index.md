---
stage: Create
group: Source Code
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments"
type: concepts, howto
---

# 使用 X.509 证书签名提交和标签 **(BASIC ALL)**

<!--
> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/17773) in GitLab 12.8.
-->

X.509 是公共或私有公钥基础设施 (PKI) 颁发的公钥证书的标准格式。
个人 X.509 证书用于身份验证或签名目的，例如 S/MIME（安全/多用途 Internet 邮件扩展）。
但是，Git 还支持使用 X.509 证书对提交和标签进行签名，其方式与 [GPG（GnuPG，或 GNU Privacy Guard）](../signed_commits/gpg.md) 类似。
主要区别在于极狐GitLab 判断开发者签名是否可信的方式：

- 对于 X.509，将根证书颁发机构添加到 GitLab 信任库。（信任库是受信任安全证书的存储库。）结合签名中任何所需的中间证书，开发人员的证书可以链接回受信任的根证书。
- 对于 GPG，开发人员[添加他们的 GPG 密钥](../signed_commits/gpg.md#添加-gpg-密钥到您的账户)到他们的账户。

极狐GitLab 使用自己的证书存储，因此定义了[信任链](https://www.ssl.com/faqs/what-is-a-certificate-authority/)。
对于要由 GitLab *验证* 的提交或标签：

- 签名证书电子邮件必须与极狐GitLab 中经过验证的电子邮件地址相匹配。
- GitLab 实例必须能够建立一个完整的信任链，从签名中的证书到可信GitLab 证书存储中的证书。该链可能包括签名中提供的中间证书。您可能需要添加证书，例如证书颁发机构根证书[到 GitLab 证书存储](https://docs.gitlab.cn/omnibus/settings/ssl.html#安装自定义公共证书)。
- 签名时间必须在[证书有效期](https://www.rfc-editor.org/rfc/rfc5280.html#section-4.1.2.5)的时间范围内，通常最长为三年。
- 签名时间等于或晚于提交时间。

如果提交的状态已经确定并存储在数据库中，请使用 Rake 任务重新检查状态<!--[重新检查状态](../../../../administration/raketasks/x509_signatures.md)-->。
请参阅[疑难解答部分](#故障排查)。
系统每天都通过后台 worker 检查证书吊销列表。

## 限制

- 不支持没有 `authorityKeyIdentifier`、`subjectKeyIdentifier` 和 `crlDistributionPoints` 的自签名证书。我们建议使用来自 PKI 的符合 [RFC 5280](https://www.rfc-editor.org/rfc/rfc5280) 的证书。
- 如果您的签名证书的主题备用名称列表中有多个电子邮件，仅使用第一个用于验证提交。
- 颁发者证书和签名证书中的 `X509v3 X509v3 Subject Key Identifier`（SKI）长度必须为 40 个字符。如果您的 SKI 较短，则提交不会在极狐GitLab 中显示为已验证，并且较短的 SKI 也可能导致访问项目时出错，例如 `An error occurred while loading commit signatures` 和 `HTTP 422 Unprocessable Entity` 错误。

## 配置签名提交

要签署您的提交、标签或两者都有，您必须：

1. [获取 X.509 密钥对](#获取-x509-密钥对)。
1. [将您的 X.509 证书与 Git 关联](#将您的-x509-证书与-git-关联)。
1. [签名并验证提交](#签名并验证提交)。
1. [签名并验证标签](#签名并验证标签)。

### 获取 X.509 密钥对

如果您的组织具有公钥基础结构 (PKI)，则该 PKI 会提供 S/MIME 密钥。如果您没有来自 PKI 的 S/MIME 密钥对，您可以创建自己的自签名对，或购买一对。

### 将您的 X.509 证书与 Git 关联

要利用 X.509 签名，您需要 Git 2.19.0 或更高版本。您可以使用命令 `git --version` 检查 Git 版本。

如果您有正确的版本，则可以继续配置 Git。

### Linux

配置 Git 以使用您的密钥进行签名：

```shell
signingkey=$( gpgsm --list-secret-keys | egrep '(key usage|ID)' | grep -B 1 digitalSignature | awk '/ID/ {print $2}' )
git config --global user.signingkey $signingkey
git config --global gpg.format x509
```

#### Windows and macOS

要配置 Windows 或 macOS：

1. 通过以下任一方式安装 [S/MIME Sign](https://github.com/github/smimesign)：
    - 下载安装程序。
    - 在 macOS 上运行 `brew install smimesign`。
1. 通过运行 `smimesign --list-keys` 来获取你的证书 ID。
1. 通过运行 `git config --global user.signingkey ID` 来设置你的签名密钥。
1. 使用以下命令配置 X.509：

   ```shell
   git config --global gpg.x509.program smimesign
   git config --global gpg.format x509
   ```

### 签名并验证提交

在您[将您的 X.509 证书与 Git 相关联](#将您的-x509-证书与-git-关联)之后，您可以签署您的提交：

1. 创建 Git 提交时，添加 `-S` 标志：

   ```shell
   git commit -S -m "feat: x509 signed commits"
   ```

1. 推送到极狐GitLab，并检查您的提交是否已使用 `--show-signature` 标志进行验证：

   ```shell
   git log --show-signature
   ```

1. *如果您不想在每次提交时都输入 `-S` 标志，* 每次都运行此命令让 Git 对您的提交进行签名：

   ```shell
   git config --global commit.gpgsign true
   ```

### 签名并验证标签

在您[将您的 X.509 证书与 Git 相关联](#将您的-x509-证书与-git-关联)之后，您可以开始签名您的标签：

1. 创建 Git 标签时，添加 `-s` 标志：

   ```shell
   git tag -s v1.1.1 -m "My signed tag"
   ```

1. 推送到极狐GitLab 并使用以下命令验证您的标签是否已签名：

   ```shell
   git tag --verify v1.1.1
   ```

1. *如果您不想在每次标签时都输入 `-s` 标志，* 每次运行此命令让 Git 对您的标签进行签名：

   ```shell
   git config --global tag.gpgsign true
   ```

<!--
## Resources

- [Rake task for X.509 signatures](../../../../administration/raketasks/x509_signatures.md)
-->

## 故障排查

对于没有管理员访问权限的提交者，请查看[签名提交的验证问题](../signed_commits/gpg.md#fix-verification-problems-with-signed-commits)列表，获得可能的修复。此页面上的其他故障排除建议需要管理员访问权限。

### 重新验证提交

极狐GitLab 将任何已检查提交的状态存储在数据库中。您可以使用 Rake 任务来检查任何先前检查过的提交的状态<!--[检查任何先前检查过的提交的状态](../../../../administration/raketasks/x509_signatures.md)-->。

进行任何更改后，运行以下命令：

```shell
sudo gitlab-rake gitlab:x509:update_signatures
```

### 主要验证检查

代码执行[这些关键检查](https://jihulab.com/gitlab-cn/gitlab/-/blob/v14.1.0-ee/lib/gitlab/x509/signature.rb#L33)，所有这些都必须返回 `已验证`：

- `x509_certificate.nil?` 应为 false。
- `x509_certificate.revoked?` 应为 false。
- `verified_signature` 应为 true。
- `user.nil?` 应为 false。
- `user.verified_emails.include?(@email)` 应为 true。
- `certificate_email == @email` 应为 true。

要调查提交显示为 `未验证` 的原因：

1. 启动 Rails 控制台<!--[启动 Rails 控制台](../../../../administration/operations/rails_console.md#starting-a-rails-console-session)-->：

   ```shell
   sudo gitlab-rails console
   ```

1. 确定您正在调查的项目（通过路径或 ID）和完整提交 SHA。使用此信息创建 `签名` 以运行其他检查：

   ```ruby
   project = Project.find_by_full_path('group/subgroup/project')
   project = Project.find_by_id('121')
   commit = project.repository.commit_by(oid: '87fdbd0f9382781442053b0b76da729344e37653')
   signedcommit=Gitlab::X509::Commit.new(commit)
   signature=Gitlab::X509::Signature.new(signedcommit.signature_text, signedcommit.signed_text, commit.committer_email, commit.created_at)
   ```

   如果您对通过检查发现的问题进行了更改，请重新启动 Rails 控制台并从头开始再次运行检查。

1. 检查提交时的证书：

   ```ruby
   signature.x509_certificate.nil?
   signature.x509_certificate.revoked?
   ```

   两个检查都应该返回 `false`：

   ```ruby
   > signature.x509_certificate.nil?
   => false
   > signature.x509_certificate.revoked?
   => false
   ```

   已知问题导致这些检查失败，并显示 `Validation failed: Subject key identifier is invalid`。

1. 对签名运行加密检查。代码必须返回 `true`：

   ```ruby
   signature.verified_signature
   ```

   如果它返回`false`，则[进一步调查此检查](#密码验证检查)。

1. 确认提交和签名上的电子邮件地址匹配：

   - Rails 控制台显示正在比较的电子邮件地址。
   - 最后的命令必须返回 `true`：

   ```ruby
   sigemail=signature.__send__:certificate_email
   commitemail=commit.committer_email
   sigemail == commitemail
   ```

   存在一个已知问题：仅比较 `Subject Alternative Name` 列表中的第一封电子邮件。 要显示 `Subject Alternative Name` 列表，请运行：

   ```ruby
   signature.__send__ :get_certificate_extension,'subjectAltName'
   ```

   如果开发人员的电子邮件地址不是列表中的第一个，则此检查失败，并且提交标记为“未验证”。

1. 提交中的电子邮件地址必须与极狐GitLab 中的账户相关联。 此检查应返回“false”：

   ```ruby
   signature.user.nil?
   ```

1. 检查电子邮件地址是否与极狐GitLab 中的用户相关联。这个检查应该返回一个用户，比如 `#<User id:1234 @user_handle>`：

   ```ruby
   User.find_by_any_email(commit.committer_email)
   ```

   如果返回 `nil`，则电子邮件地址与用户无关，检查失败。

1. 确认开发者的电子邮件地址已通过验证。此检查必须返回 true：

   ```ruby
   signature.user.verified_emails.include?(commit.committer_email)
   ```

   如果之前的检查返回 `nil`，这个命令会显示一个错误：

   ```plaintext
   NoMethodError (undefined method `verified_emails' for nil:NilClass)
   ```

1. 验证状态存储在数据库中。显示数据库记录：

   ```ruby
   pp CommitSignatures::X509CommitSignature.by_commit_sha(commit.sha);nil
   ```

   如果之前的所有检查都返回正确的值：

   - `verification_status: "unverified"` 表示数据库记录需要更新。[使用 Rake 任务](#重新验证提交)。

   - `[]` 表示数据库还没有记录。在极狐GitLab 中找到提交以检查签名并存储结果。

#### 密码验证检查

如果 GitLab 确定 `verified_signature` 为 `false`，请在 Rails 控制台中调查原因。这些检查需要存在“签名”。参考前面[主要验证检查](#主要验证检查)的 `signature` 步骤。

1. 检查签名，不检查发行者，返回 `true`：

   ```ruby
   signature.__send__ :valid_signature?
   ```

1. 检查签名时间和日期。此检查必须返回 `true`：

   ```ruby
   signature.__send__ :valid_signing_time?
   ```

   - 该代码允许代码签名证书过期。
   - 提交必须在证书的有效期内以及提交的日期戳或之后签名。显示提交时间和证书详细信息，包括 `not_before`、`not_after`：

     ```ruby
     commit.created_at
     pp signature.__send__ :cert; nil
     ```

1. 检查签名，包括可以建立 TLS 信任。此检查必须返回 `true`：

   ```ruby
   signature.__send__(:p7).verify([], signature.__send__(:cert_store), signature.__send__(:signed_text))
   ```

   1. 如果失败，请添加建立信任所需的缺失证书[到 GitLab 证书存储](https://docs.gitlab.cn/omnibus/settings/ssl.html#安装自定义公共证书)。

   1. 添加更多证书后，（如果这些故障排除步骤通过）运行 Rake 任务以[重新验证提交](#重新验证提交)。

   1. 显示证书，包括在签名中：

      ```ruby
      pp signature.__send__(:p7).certificates ; nil
      ```

确保将任何其他中间证书和根证书添加到证书存储中。为了与在 Web 服务器上构建证书链的方式保持一致：

- 签署提交的 Git 客户端应在签名中包含证书和所有中间证书。
- 极狐GitLab 证书存储应该只包含根证书。

如果您从极狐GitLab 信任存储中删除根证书，例如当它过期时，链接回该根证书的提交签名显示为 `unverified`。
