import { s__ } from '~/locale';

// Values are from lib/gitlab/visibility_level.rb
export const PRIVATE_VISIBILITY_LEVEL = 0;
export const INTERNAL_VISIBILITY_LEVEL = 10;
export const PUBLIC_VISIBILITY_LEVEL = 20;

export const I18N_NEW_PROJECT_TERMS_DECLARATION = s__('JH|ProjectTerms|Declaration');

export const I18N_NEW_PROJECT_TERMS_ONE = s__(
  'JH|ProjectTerms|I hereby declare that I have read, understand, and agree to the %{linkStart}JiHu(GitLab) Terms of Service%{linkEnd} and all irregularly-updated agreements, user statements, disclaimers, and other content on this webpage. The content of this project does not violate relevant laws and regulations of any country or infringe on the intellectual property rights or other rights of any third parties. I will take full responsibility for any violation or infringement, and JiHu(GitLab) will be exempted from any responsibility.',
);

export const I18N_NEW_PROJECT_TERMS_TWO = s__(
  'JH|ProjectTerms|I declare that I have the complete, independent, and legitimate intellectual property rights and other rights of the content of this project. If it involves citation of others’ works, achievements, rights, and authorization or in other similar situations, I declare that the cited content complies with relevant laws and regulations and has been properly reviewed and authorized without any infringement or illegal acts, and I will expressly attach annotations and statements for the cited content. I will undertake all the risks and liabilities arising from such citation, and JiHu(GitLab) will be exempted from them.',
);
