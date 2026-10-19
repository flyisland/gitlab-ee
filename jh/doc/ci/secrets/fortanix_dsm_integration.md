---
type: concepts, howto
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：将 Fortanix Data Security Manager (DSM) 与极狐GitLab 配合使用'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以将 Fortanix Data Security Manager (DSM) 用作极狐GitLab CI/CD 流水线的密钥管理器。

本教程介绍在 Fortanix DSM 中生成新密钥或使用现有密钥，并在极狐GitLab CI/CD 作业中使用它们的步骤。请仔细按照说明实施此集成，以增强数据安全性并优化您的 CI/CD 流水线。

<a id="before-you-begin"></a>

## 开始之前

请确保您具备：

- 对具有相应管理权限的 Fortanix DSM 账号的访问权限。有关更多信息，请参阅[开始使用 Fortanix Data Security Manager](https://www.fortanix.com/start-your-free-trial)。
- 一个[极狐GitLab 账号](https://jihulab.com/users/sign_up)，并且可以访问您打算设置该集成的项目。
- 了解在 Fortanix DSM 中保存密钥的流程，包括生成和导入密钥。
- 在 Fortanix DSM 和极狐GitLab 中拥有群组、应用、插件、变量和密钥管理所需的权限。

<a id="generate-and-import-a-new-secret"></a>

## 生成并导入新密钥

要在 Fortanix DSM 中生成新密钥并在极狐GitLab 中使用：

1. 登录您的 Fortanix DSM 账号。
1. 在 Fortanix DSM 中，[创建新群组和应用](https://support.fortanix.com/docs/getting-started-with-fortanix-data-security-manager-ui)。
1. 将 [API 密钥配置为应用的认证方式](https://support.fortanix.com/docs/dsm-authentication)。
1. 使用以下代码在 Fortanix DSM 中生成新插件：

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

   有关更多信息，请参阅 Fortanix 文档中的[插件库](https://support.fortanix.com/docs/dsm-plugin-library)。

   - 如果要将密钥存储在 Fortanix DSM 中，请将导入选项设置为 `yes`：

     ```json
     {
         "type": "alphanumeric_caps",
         "length": 64,
         "name": "GitLab-Secret",
         "import": "yes"
     }
     ```

   - 如果只想生成新值用于轮换，请将导入选项设置为 `no`：

     ```json
     {
         "type": "numeric",
         "length": 64,
         "name": "GitLab-Secret",
         "import": "no"
     }
     ```

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**并添加以下变量：
   - `FORTANIX_API_ENDPOINT`
   - `FORTANIX_API_KEY`
   - `FORTANIX_PLUGIN_ID`

1. 在您的项目中创建或编辑 `.gitlab-ci.yml` 配置文件以使用该集成：

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
   如果没有运行，请选择**构建** > **流水线** > **运行流水线**。
1. 转到**构建** > **作业**，并检查 `build` 作业的日志：

   ![显示 Fortanix DSM 配置成功的构建作业日志。](img/gitlab_build_result_1_v16_9.png)

![Fortanix Data Security Manager 密钥视图。](img/dsm_secrets_v16_9.png)

<a id="use-an-existing-secret-from-fortanix-dsm"></a>

## 使用 Fortanix DSM 中的现有密钥

要在极狐GitLab 中使用 Fortanix DSM 中已存在的密钥：

1. 该密钥必须在 Fortanix 中标记为可导出：

   ![Fortanix Data Security Manager 中的可导出密钥设置。](img/dsm_secret_import_1_v16_9.png)

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**并添加以下变量：
   - `FORTANIX_API_ENDPOINT`
   - `FORTANIX_API_KEY`
   - `FORTANIX_PLUGIN_ID`

1. 在您的项目中创建或编辑 `.gitlab-ci.yml` 配置文件以使用该集成：

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
   如果没有运行，请选择**构建** > **流水线** > **运行流水线**。
1. 转到**构建** > **作业**，并检查 `build` 作业的日志：

   - ![显示成功检索现有 Fortanix 密钥的构建作业日志。](img/gitlab_build_result_2_v16_9.png)

<a id="code-signing"></a>

## 代码签名

要在您的极狐GitLab 环境中安全地设置代码签名：

1. 登录您的 Fortanix DSM 账号。
1. 将 `keystore_password` 和 `key_password` 作为密钥导入 Fortanix DSM。确保它们已标记为可导出。

   ![在 Fortanix Data Security Manager 中作为可导出密钥导入的密钥库密码和密钥密码。](img/dsm_secret_import_2_v16_9.png)

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**并添加以下变量：
   - `FORTANIX_API_ENDPOINT`
   - `FORTANIX_API_KEY`
   - `FORTANIX_SECRET_NAME_1`（用于 `keystore_password`）
   - `FORTANIX_SECRET_NAME_2`（用于 `key_password`）

1. 在您的项目中创建或编辑 `.gitlab-ci.yml` 配置文件以使用该集成：

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
   如果没有运行，请选择**构建** > **流水线** > **运行流水线**。
1. 转到**构建** > **作业**，并检查 `build` 作业的日志：

   - ![显示使用 Fortanix 密钥进行代码签名过程的构建作业日志。](img/gitlab_build_result_3_v16_9.png)
