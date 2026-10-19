import './vue_overrides';
import './duo_ui_overrides';
import './super_sidebar/feature_library_overrides';
import { addAppealModalPopupListener } from 'jh/appeal';
import { initCaptcha } from 'jh/captcha/init_captcha';
import { initAccountNotification } from 'jh/banners/user_notification';
import { initPhoneAuthUsernameLabel } from 'jh/phone_auth_username_label';
import { initProjectTerms } from 'jh/init_project_terms';
import { initJHGitlabNext } from 'jh/super_sidebar/gitlab_next';

addAppealModalPopupListener();

// init captcha button if there exists a .js-captcha stub element in HTML
initCaptcha();
initAccountNotification();
initPhoneAuthUsernameLabel();
initProjectTerms();
initJHGitlabNext();
