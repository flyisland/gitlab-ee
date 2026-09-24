# frozen_string_literal: true

module QA
  root = "#{__dir__}/qa"

  loader = Zeitwerk::Loader.new
  loader.push_dir(root, namespace: ::QA)

  loader.ignore("#{root}/specs/features")
  loader.ignore("#{root}/specs/spec_helper.rb")

  loader.inflector.inflect(
    "jh" => "JH",
    "ce" => "CE",
    "ee" => "EE",
    "api" => "API",
    "ssh" => "SSH",
    "ssh_key" => "SSHKey",
    "ssh_keys" => "SSHKeys",
    "ecdsa" => "ECDSA",
    "ed25519" => "ED25519",
    "rsa" => "RSA",
    "ldap" => "LDAP",
    "ldap_tls" => "LDAPTLS",
    "ldap_no_tls" => "LDAPNoTLS",
    "ldap_no_server" => "LDAPNoServer",
    "rspec" => "RSpec",
    "web_ide" => "WebIDE",
    "ci_cd" => "CiCd",
    "project_imported_from_url" => "ProjectImportedFromURL",
    "repo_by_url" => "RepoByURL",
    "oauth" => "OAuth",
    "saml_sso_sign_in" => "SamlSSOSignIn",
    "saml_sso_sign_up" => "SamlSSOSignUp",
    "group_saml" => "GroupSAML",
    "instance_saml" => "InstanceSAML",
    "saml_sso" => "SamlSSO",
    "ldap_sync" => "LDAPSync",
    "ip_address" => "IPAddress",
    "gpg" => "GPG",
    "user_gpg" => "UserGPG",
    "smtp" => "SMTP",
    "otp" => "OTP",
    "jira_api" => "JiraAPI",
    "registry_tls" => "RegistryTLS",
    "jetbrains" => "JetBrains",
    "vscode" => "VSCode",
    "registry_with_cdn" => "RegistryWithCDN"
  )

  # # Configure knapsack at the very begining of the setup
  # loader.on_setup do
  #   ::QA::Support::KnapsackReport.configure!
  # end

  loader.do_not_eager_load("#{root}/fixtures")
  loader.do_not_eager_load("#{root}/page")
  loader.do_not_eager_load("#{root}/flow")
  loader.do_not_eager_load("#{root}/resource")
  loader.do_not_eager_load("#{root}/runtime")
  loader.do_not_eager_load("#{root}/scenario")
  loader.do_not_eager_load("#{root}/specs")
  loader.do_not_eager_load("#{root}/third_party_page")
  loader.setup

  # eager load jh file first to make sure prepend module works
  loader.eager_load
end
