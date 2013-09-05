class CompanyBranding
  DEFAULT_LOGO_URL = '/assets/branding/style_guide/logo/activecell-full-color-darkBG-small.png'

  include Api::BaseDocument
  include Mongoid::Paperclip

  embedded_in :company, inverse_of: :branding
  embeds_one :color_scheme

  has_mongoid_attached_file :logo,
      styles: { resized: '161x46' },
      path: 'uploads/company/logo/:id/:style/:filename',
      url: 'uploads/company/logo/:id/:style/:filename',
      default_url: DEFAULT_LOGO_URL

  validates :logo, attachment_content_type: {
      content_type: %w(image/png image/gif image/jpg image/jpeg),
      message: "must be in 'png/jpg/jpeg/gif' format"
  }, attachment_size: { less_than: 5.megabytes }

  def logo_url
    logo.url(:resized) if logo.present?
  end

end
