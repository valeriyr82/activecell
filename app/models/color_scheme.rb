class ColorScheme
  include Api::BaseDocument
  include Mongoid::Timestamps

  # List of default colors
  PRIMARY_LIGHT   = '#30878F'
  PRIMARY_DARK    = '#00455B'
  SECONDARY_LIGHT = '#266872'
  SECONDARY_DARK  = '#083749'
  MENU_OTHER      = '#003647'
  WHITE           = '#FFFFFF'
  LIGHT_GREY      = '#F5F5F5'
  GREY            = '#E6E6E6'
  DARK_GREY       = '#333333'
  BLACK           = '#000000'

  DEFAULT_COLOR_SCHEME = {
    primary_light:   PRIMARY_LIGHT,
    primary_dark:    PRIMARY_DARK,
    secondary_light: SECONDARY_LIGHT,
    secondary_dark:  SECONDARY_DARK,
    menu_other:      MENU_OTHER,
    white:           WHITE,
    light_grey:      LIGHT_GREY,
    grey:            GREY,
    dark_grey:       DARK_GREY,
    black:           BLACK,
  }

  field :primary_light,   type: String, default: PRIMARY_LIGHT
  field :primary_dark,    type: String, default: PRIMARY_DARK
  field :secondary_light, type: String, default: SECONDARY_LIGHT
  field :secondary_dark,  type: String, default: SECONDARY_DARK
  field :menu_other,      type: String, default: MENU_OTHER
  field :white,           type: String, default: WHITE
  field :light_grey,      type: String, default: LIGHT_GREY
  field :grey,            type: String, default: GREY
  field :dark_grey,       type: String, default: DARK_GREY
  field :black,           type: String, default: BLACK

  embedded_in :company_branding
end
