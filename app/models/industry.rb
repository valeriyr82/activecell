class Industry
  include Api::NameDocument

  has_many :companies
  field :suggested_streams, type: Array
  field :suggested_channels, type: Array
  field :suggested_segments, type: Array
  field :suggested_stages, type: Array
end
