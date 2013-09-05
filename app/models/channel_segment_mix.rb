class ChannelSegmentMix
  include Api::BaseDocument
  include Api::BelongsCompany
  include Api::ForecastDocument

  field :distribution, type: Float, default: 1.0

  belongs_to :period
  belongs_to :segment
  belongs_to :channel

  # Returns json presentation without id
  # => {"distribution"=>1, "segment_id"=>"500d3c64b0207ae648000010"}
  def as_json(options = {})
    attrs = super(options)
    attrs.delete('id')
    attrs
  end
end
