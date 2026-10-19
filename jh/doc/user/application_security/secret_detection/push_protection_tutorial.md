---
stage: Application Security Testing
group: Secret Detection
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用密钥推送保护保护你的项目'
---

如果你的应用程序使用外部资源，通常需要使用 **密钥**（如令牌或密钥）来认证你的应用程序。如果密钥被推送到远程仓库，任何可以访问该仓库的人都可以冒充你或你的应用程序。

通过密钥推送保护，如果极狐GitLab 在提交历史中检测到密钥，它可以阻止推送以防止泄露。启用密钥推送保护是一个好方法，可以减少你审查提交中敏感数据以及在发生泄露时进行补救所花费的时间。

在本教程中，你将配置密钥推送保护，并了解当你尝试提交一个虚假密钥时会发生什么。
你还会学习如何在需要绕过误报时跳过密钥推送保护。

## 准备工作

在开始本教程之前，请确保你具备以下条件：

- 一个极狐GitLab 旗舰版订阅。
- 一个测试项目。你可以使用任何你喜欢的项目，但建议为本教程专门创建一个测试项目。
- 熟悉命令行 Git。

此外，仅在私有化部署的极狐GitLab 上，请确保密钥推送保护已[在实例上启用](secret_push_protection/_index.md#allow-the-use-of-secret-push-protection-in-your-gitlab-instance)。

## 启用密钥推送保护

要使用密钥推送保护，你需要为每个你想保护的项目启用它。
让我们从在一个测试项目中启用它开始。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 打开 **密钥推送保护** 开关。

接下来，你将测试密钥推送保护。

## 尝试向你的项目推送一个密钥

极狐GitLab 通过匹配特定的字母、数字和符号模式来识别密钥。这些模式也用于识别密钥类型。
让我们通过将虚假密钥 `glpat-12345678901234567890` 添加到我们的项目中来测试此功能：

1. 在项目中，检出一个新分支：

   ```shell
   git checkout -b push-protection-tutorial
   ```

1. 创建一个包含以下内容的新文件。
   请务必移除 `-` 前后的空格，以匹配个人访问令牌的确切格式：

   ```plaintext
   hello, world!

   # 为使示例生效，请移除
   # 短横线前后的空格：
   glpat - 12345678901234567890
   ```

1. 将此文件提交到你的分支：

   ```shell
   git add .
   git commit -m "添加虚假密钥"
   ```

   密钥现已进入提交历史。密钥推送保护并不会阻止你提交密钥；它只会在你推送时发出警报。
1. 将更改推送到极狐GitLab。你应该会看到类似以下内容：

   ```shell
   $ git push
   remote: 极狐GitLab：
   remote: 推送被阻止：在代码变更中检测到密钥
   remote:
   remote: 密钥推送保护在以下提交中发现了密钥：123abc
   remote: -- myFile.txt:2 | GitLab Personal Access Token
   remote:
   remote: 要推送你的更改，你必须移除已识别的密钥。
   To jihulab.com:
    ! [remote rejected] push-protection-tutorial -> main (pre-receive hook declined)
   ```

   极狐GitLab 检测到密钥并阻止了推送。从错误报告中，我们可以看到：

   - 包含密钥的提交 (`123abc`)
   - 包含密钥的文件和行号 (`myFile.txt:2`)
   - 密钥类型 (`GitLab Personal Access Token`)

如果我们成功推送了更改，将需要花费大量时间和精力来撤销并替换密钥。
相反，我们可以[从提交历史中移除密钥](remove_secrets_tutorial.md)，并因为阻止了密钥泄露而高枕无忧。

## 跳过密钥推送保护

有时你需要推送一个提交，即使密钥推送保护已经识别出一个密钥。这可能会在极狐GitLab 检测到误报时发生。
为了演示，我们将把上次的提交推送到极狐GitLab。

### 使用推送选项

你可以使用推送选项来跳过密钥检测：

- 使用 `secret_detection.skip_all` 选项推送你的提交：

  ```shell
  git push -o secret_detection.skip_all
  ```

密钥检测被跳过，更改被推送到远程仓库。

### 使用提交信息

如果你无法访问命令行，或者不想使用推送选项：

- 将字符串 `[skip secret push protection]` 添加到提交信息中。例如：

  ```shell
  git commit --amend -m "添加虚假密钥 [skip secret push protection]"
  ```

你只需要在其中一个提交信息中添加 `[skip secret push protection]` 就可以推送你的更改，即使有多个提交也是如此。

## 下一步

考虑启用[流水线密钥检测](pipeline/_index.md)以进一步提高项目的安全性。