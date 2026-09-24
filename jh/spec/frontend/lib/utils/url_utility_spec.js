import * as urlUtils from 'jh_else_ce/lib/utils/url_utility';

describe('JiHuPromoUrl', () => {
  it('JiHu(Gitlab) about page url', () => {
    const url = 'https://about.gitlab.cn';

    expect(urlUtils.PROMO_URL).toEqual(url);
  });
});
