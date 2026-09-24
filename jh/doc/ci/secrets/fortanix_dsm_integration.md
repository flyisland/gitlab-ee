---
type: concepts, howto
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：将 Fortanix Data Security Manager (DSM) 与极狐GitLab 结合使用'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以将 Fortanix Data Security Manager (DSM) 用作极狐GitLab CI/CD 流水线的密钥管理器。

本教程介绍了在 Fortanix DSM 中生成新密钥或使用现有密钥，并在极狐GitLab CI/CD 作业中使用它们所需的步骤。请仔细遵循说明，以实现此集成，从而增强数据安全性并优化你的 CI/CD 流水线。

<a id="before-you-begin"></a>

## 开始之前

确保你拥有：

- 一个具有适当管理权限的 Fortanix DSM 账户。更多信息，请参考 [Fortanix Data Security Manager 入门](https://www.fortanix.com/start-your-free-trial)。
- 一个 [极狐GitLab 账户](https://gitlab.com/users/sign_up)，并且可以访问你打算设置集成的项目。
- 了解在 Fortanix DSM 中保存密钥的过程，包括生成和导入密钥。
- 在 Fortanix DSM 和极狐GitLab 中拥有群组、应用、插件、变量和密钥管理所需的权限。

<a id="generate-and-import-a-new-secret"></a>

## 生成并导入新密钥

要在 Fortanix DSM 中生成新密钥并将其用于极狐GitLab：

1. 登录你的 Fortanix DSM 账户。
1. 在 Fortanix DSM 中，[创建一个新群组和一个应用](https://support.fortanix.com/hc/en-us/articles/360015809372-User-s-Guide-Getting-Started-with-Fortanix-Data-Security-Manager-UI)。
1. 配置 [API 密钥作为应用的身份验证方法](https://support.fortanix.com/hc/en-us/articles/360033272171-User-s-Guide-Authentication)。
1. 使用以下代码在 Fortanix DSM 中生成一个新插件：

   ```lua
   numericAlphabet = "0123456789"
   alphanumericAlphabet = numericAlphabet .. "abcdefghijklmnopqrstuvwxyz"
   alphanumericCapsAlphabet = alphanumericAlphabet .. "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
   alphanumericCapsSymbolsAlphabets = alphanumericCapsAlphabet .. "!@#$&*_%="

   function genPass(alphabet, len, name, import)
       local alphabetSize = #alphabet
       local password = ''

       for i = 1, len, 1 do
           local random_char = math.random(alphabetSize)
           password = password .. string.sub(alphabet, random_char, random_char)
       end

       local pass = Blob.from_bytes(password)

       if import == "yes" then
           local sobject = assert(Sobject.import { name = name, obj_type = "SECRET", value = pass, key_ops = {'APPMANAGEABLE', 'EXPORT'} })
           return password
       end

       return password;
   end

   function run(input)
       if input.type == "numeric" then
           return genPass(numericAlphabet, input.length, input.name, input.import)
       end

       if input.type == "alphanumeric" then
           return genPass(alphanumericAlphabet, input.length, input.name, input.import)
       end

       if input.type == "alphanumeric_caps" then
           return genPass(alphanumericCapsAlphabet, input.length, input.name, input.import)
       end

       if input.type == "alphanumeric_caps_symbols" then
           return genPass(alphanumericCapsSymbolsAlphabets, input.length, input.name, input.import)
       end
   end
   ```

   更多信息，请参见 [Fortanix 用户指南：插件库](https://support.fortanix.com/hc/en-us/articles/360041950371-User-s-Guide-Plugin-Library)。

   - 如果要将密钥存储在 Fortanix DSM 中，请将导入选项设置为 `yes`：

     ```json
     {
         "type": "alphanumeric_caps",
         "length": 64,
         "name": "GitLab-Secret",
         "import": "yes"
     }
     ```

   - 如果只想为轮换生成一个新值，请将导入选项设置为 `no`：

     ```json
     {
         "type": "numeric",
         "length": 64,
         "name": "GitLab-Secret",
         "import": "no"
     }
     ```

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量** 并添加以下变量：
   - `FORTANIX_API_ENDPOINT`
   - `FORTANIX_API_KEY`
   - `FORTANIX_PLUGIN_ID`

1. 在你的项目中创建或编辑 `.gitlab-ci.yml` 配置文件以使用该集成：

   ```yaml
   stages:
     - build

   build:
     stage: build
     image: ubuntu
     script:
       - apt-get update
       - apt install --assume-yes jq
       - apt install --assume-yes curl
       - jq --version
       - curl --version
       - secret=$(curl --silent --request POST --header "Authorization:Basic ${FORTANIX_API_KEY}" ${FORTANIX_API_ENDPOINT}/sys/v1/plugins/${FORTANIX_PLUGIN_ID} --data "{\"type\":\"alphanumeric_caps\", \"name\":\"$CI_PIPELINE_ID\",\"import\":\"yes\", \"length\":\"48\"}" | jq --raw-output)
       - nsecret=$(curl --silent --request POST --header "Authorization:Basic ${FORTANIX_API_KEY}" ${FORTANIX_API_ENDPOINT}/sys/v1/plugins/${FORTANIX_PLUGIN_ID} --data "{\"type\":\"alphanumeric_caps\", \"import\":\"no\", \"length\":\"48\"}" | jq --raw-output)
       - encodesecret=$(echo $nsecret | base64)
       - rotate=$(curl --silent --request POST --header "Authorization:Basic ${FORTANIX_API_KEY}" ${FORTANIX_API_ENDPOINT}/crypto/v1/keys/rekey --data "{\"name\":\"$CI_PIPELINE_ID\", \"value\":\"$encodesecret\"}" | jq --raw-output .kid)
   ```

1. 保存 `.gitlab-ci.yml` 文件后，流水线应自动运行。
   如果没有，请选择 **构建** > **流水线** > **运行流水线**。
1. 转到 **构建** > **作业** 并查看 `build` 作业的日志：

   ![构建作业日志显示成功的 Fortanix DSM 配置。](img/gitlab_build_result_1_v16_9.png)

![Fortanix Data Security Manager 密钥视图。](img/dsm_secrets_v16_9.png)

<a id="use-an-existing-secret-from-fortanix-dsm"></a>

## 使用 Fortanix DSM 中的现有密钥

要使用 Fortanix DSM 中已存在的密钥与极狐GitLab 配合：

1. 密钥必须在 Fortanix 中标记为可导出：

   ![Fortanix Data Security Manager 中的可导出密钥设置。](img/dsm_secret_import_1_v16_9.png)

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量** 并添加以下变量：
   - `FORTANIX_API_ENDPOINT`
   - `FORTANIX_API_KEY`
   - `FORTANIX_PLUGIN_ID`

1. 在你的项目中创建或编辑 `.gitlab-ci.yml` 配置文件以使用该集成：

   ```yaml
   stages:
     - build

   build:
     stage: build
     image: ubuntu
     script:
     - apt-get update
     - apt install --assume-yes jq
     - apt install --assume-yes curl
     - jq --version
     - curl --version
     - secret=$(curl --silent --request POST --header "Authorization:Basic ${FORTANIX_API_KEY}" ${FORTANIX_API_ENDPOINT}/crypto/v1/keys/export --data "{\"name\":\"${FORTANIX_SECRET_NAME}\"}" | jq --raw-output .value)
   ```

1. 保存 `.gitlab-ci.yml` 文件后，流水线应自动运行。
   如果没有，请选择 **构建** > **流水线** > **运行流水线**。
1. 转到 **构建** > **作业** 并查看 `build` 作业的日志：

   - ![构建作业日志显示成功检索现有 Fortanix 密钥。](img/gitlab_build_result_2_v16_9.png)

<a id="code-signing"></a>

## 代码签名

要在你的极狐GitLab 环境中安全地设置代码签名：

1. 登录你的 Fortanix DSM 账户。
1. 将 `keystore_password` 和 `key_password` 作为密钥导入到 Fortanix DSM 中。确保它们被标记为可导出。

   ![在 Fortanix Data Security Manager 中作为可导出密钥导入的密钥库和密钥密码。](img/dsm_secret_import_2_v16_9.png)

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量** 并添加以下变量：
   - `FORTANIX_API_ENDPOINT`
   - `FORTANIX_API_KEY`
   - `FORTANIX_SECRET_NAME_1`（用于 `keystore_password`）
   - `FORTANIX_SECRET_NAME_2`（用于 `key_password`）

1. 在你的项目中创建或编辑 `.gitlab-ci.yml` 配置文件以使用该集成：

   ```yaml
   stages:
     - build

   build:
     stage: build
     image: ubuntu
     script:
     - apt-get update -qy
     - apt install --assume-yes jq
     - apt install --assume-yes curl
     - apt-get install wget
     - apt-get install unzip
     - apt-get install --assume-yes openjdk-8-jre-headless openjdk-8-jdk   # Install Java
     - keystore_password=$(curl --silent --request POST --header "Authorization:Basic ${FORTANIX_API_KEY}" ${FORTANIX_API_ENDPOINT}/crypto/v1/keys/export --data "{\"name\":\"${FORTANIX_SECRET_NAME_1}\"}" | jq --raw-output .value)
     - key_password=$(curl --silent --request POST --header "Authorization:Basic ${FORTANIX_API_KEY}" ${FORTANIX_API_ENDPOINT}/crypto/v1/keys/export --data "{\"name\":\"${FORTANIX_SECRET_NAME_2}\"}" | jq --raw-output .value)
     - echo "yes" | keytool -genkeypair -alias mykey -keyalg RSA -keysize 2048 -keystore keystore.jks -storepass $keystore_password -keypass $key_password -dname "CN=test"
     - mkdir -p src/main/java
     - echo 'public class HelloWorld { public static void main(String[] args) { System.out.println("Hello, World!"); } }' > src/main/java/HelloWorld.java
     - javac src/main/java/HelloWorld.java
     - mkdir -p target
     - jar cfe target/HelloWorld.jar HelloWorld -C src/main/java HelloWorld.class
     - jarsigner -keystore keystore.jks -storepass $keystore_password -keypass $key_password -signedjar signed.jar target/HelloWorld.jar mykey
   ```

1. 保存 `.gitlab-ci.yml` 文件后，流水线应自动运行。
   如果没有，请选择 **构建** > **流水线** > **运行流水线**。
1. 转到 **构建** > **作业** 并查看 `build` 作业的日志：

   - ![构建作业日志显示使用 Fortanix 密钥的代码签名过程。](img/gitlab_build_result_3_v16_9.png)