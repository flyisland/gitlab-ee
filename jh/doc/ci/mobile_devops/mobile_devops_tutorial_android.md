---
stage: Verify
group: Mobile DevOps
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用极狐GitLab Mobile DevOps 构建 Android 应用'
---

在本教程中，您将使用极狐GitLab CI/CD 创建一个流水线，用于构建您的 Android 移动应用、使用您的凭据为其签名，并将其分发到应用商店。

要设置移动 DevOps：

1. [设置您的构建环境](#set-up-your-build-environment)
1. [使用 fastlane 和 Gradle 配置代码签名](#configure-code-signing-with-fastlane-and-gradle)
1. [使用 Google Play 集成和 fastlane 设置 Android 应用分发](#set-up-android-apps-distribution-with-google-play-integration-and-fastlane)

<a id="before-you-begin"></a>

## 开始之前

在开始本教程之前，请确保您已具备：

- 一个可访问 CI/CD 流水线的极狐GitLab 账号
- 您的移动应用代码已存放在极狐GitLab 代码仓库中
- 一个 Google Play 开发者账号
- 已在本地安装 [`fastlane`](https://fastlane.tools)

<a id="set-up-your-build-environment"></a>

## 设置您的构建环境

使用[极狐GitLab 托管的 Runner](../runners/_index.md)，
或设置[私有化部署 Runner](https://gitlab.cn/docs/runner/#use-self-managed-runners) 以完全控制构建环境。

Android 构建使用 Docker 镜像，提供多个 Android API 版本。

1. 在代码仓库根目录中创建一个 `.gitlab-ci.yml` 文件。
1. 添加来自 [Fabernovel](https://hub.docker.com/r/fabernovel/android/tags)的 Docker 镜像：

   ```yaml
   test:
     image: fabernovel/android:api-33-v1.7.0
     stage: test
     script:
       - fastlane test
   ```

<a id="configure-code-signing-with-fastlane-and-gradle"></a>

## 使用 fastlane 和 Gradle 配置代码签名

要为 Android 设置代码签名：

1. 创建一个密钥库：

   1. 运行以下命令生成密钥库文件：

      ```shell
      keytool -genkey -v -keystore release-keystore.jks -storepass password -alias release -keypass password \
      -keyalg RSA -keysize 2048 -validity 10000
      ```

   1. 将密钥库配置放入 `release-keystore.properties` 文件：

      ```plaintext
      storeFile=.secure_files/release-keystore.jks
      keyAlias=release
      keyPassword=password
      storePassword=password
      ```

   1. 将这两个文件作为[安全文件](../secure_files/_index.md)上传到您的项目设置中。
   1. 将这两个文件添加到您的 `.gitignore` 文件中，以免它们被提交到版本控制。
1. 配置 Gradle 以使用新创建的密钥库。在应用的 `build.gradle` 文件中：

   1. 紧接在 plugins 部分之后，添加：

      ```gradle
      def keystoreProperties = new Properties()
      def keystorePropertiesFile = rootProject.file('.secure_files/release-keystore.properties')
      if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
      }
      ```

   1. 在 `android` 块中的任意位置，添加：

      ```gradle
      signingConfigs {
        release {
          keyAlias keystoreProperties['keyAlias']
          keyPassword keystoreProperties['keyPassword']
          storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
          storePassword keystoreProperties['storePassword']
        }
      }
      ```

   1. 将 `signingConfig` 添加到 release 构建类型：

      ```gradle
      signingConfig signingConfigs.release
      ```

以下是使用此配置的示例 `fastlane/Fastfile` 和 `.gitlab-ci.yml` 文件：

- `fastlane/Fastfile`：

  ```ruby
  default_platform(:android)

  platform :android do
    desc "Create and sign a new build"
    lane :build do
      gradle(tasks: ["clean", "assembleRelease", "bundleRelease"])
    end
  end
  ```

- `.gitlab-ci.yml`：

  ```yaml
  build:
    image: fabernovel/android:api-33-v1.7.0
    stage: build
    script:
      - apt update -y && apt install -y curl
      - wget https://gitlab.com/gitlab-org/cli/-/releases/v1.74.0/downloads/glab_1.74.0_linux_amd64.deb
      - apt install ./glab_1.74.0_linux_amd64.deb
      - glab auth login --hostname $CI_SERVER_FQDN --job-token $CI_JOB_TOKEN
      - glab securefile download --all --output-dir .secure_files/
      - fastlane build
  ```

<a id="set-up-android-apps-distribution-with-google-play-integration-and-fastlane"></a>

## 使用 Google Play 集成和 fastlane 设置 Android 应用分发

已签名的构建可以通过 Mobile DevOps 分发集成上传到 Google Play 商店。

1. 在 Google Cloud Platform 中[创建一个 Google 服务账号](https://docs.fastlane.tools/actions/supply/#setup)，并授予该账号访问 Google Play 中项目的权限。
1. 启用 Google Play 集成：
   1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
   1. 选择**设置** > **集成**。
   1. 选择 **Google Play**。
   1. 在**启用集成**下，选中**活跃**复选框。
   1. 在**软件包名称**中，输入应用的软件包名称。例如，`com.gitlab.app_name`。
   1. 在**服务账号密钥 (.JSON)**中，拖入或上传您的密钥文件。
   1. 选择**保存更改**。
1. 将发布步骤添加到您的流水线。

以下是示例 `fastlane/Fastfile`：

```ruby
default_platform(:android)

platform :android do
  desc "Submit a new Beta build to the Google Play store"
  lane :beta do
    upload_to_play_store(
      track: 'internal',
      aab: 'app/build/outputs/bundle/release/app-release.aab',
      release_status: 'draft'
    )
  end
end
```

以下是示例 `.gitlab-ci.yml`：

```yaml
beta:
  image: fabernovel/android:api-33-v1.7.0
  stage: beta
  script:
    - fastlane beta
```

恭喜！您的应用现已设置为可自动构建、签名和分发。尝试创建一个合并请求来触发您的第一个流水线。
