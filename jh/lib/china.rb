# frozen_string_literal: true

module China
  include ::Gitlab::Utils::StrongMemoize
  extend self

  # See https://baike.baidu.com/item/%E7%9C%81%E4%BB%BD/1635191?fr=aladdin
  PROVINCES = [
    %w[河北省 河北],
    %w[山西省 山西],
    %w[辽宁省 辽宁],
    %w[吉林省 吉林],
    %w[黑龙江省 黑龙江],
    %w[江苏省 江苏],
    %w[浙江省 浙江],
    %w[安徽省 安徽],
    %w[福建省 福建],
    %w[江西省 江西],
    %w[山东省 山东],
    %w[河南省 河南],
    %w[湖北省 湖北],
    %w[湖南省 湖南],
    %w[广东省 广东],
    %w[海南省 海南],
    %w[四川省 四川],
    %w[贵州省 贵州],
    %w[云南省 云南],
    %w[陕西省 陕西],
    %w[甘肃省 甘肃],
    %w[青海省 青海],
    %w[台湾省 台湾],
    %w[内蒙古自治区 内蒙古],
    %w[广西壮族自治区 广西],
    %w[西藏自治区 西藏],
    %w[宁夏回族自治区 宁夏],
    %w[新疆维吾尔自治区 新疆],
    %w[北京市 北京],
    %w[天津市 天津],
    %w[上海市 上海],
    %w[重庆市 重庆],
    %w[香港特别行政区 香港],
    %w[澳门特别行政区 澳门]
  ].freeze

  def provinces_for_select
    PROVINCES
  end
  strong_memoize_attr :provinces_for_select
end
