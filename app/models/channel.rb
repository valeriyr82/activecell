class Channel
  include Api::NameDocument
  include Api::BelongsCompany
  include Api::ValidateLast
  include Api::LimitSizeTo50

  field :commission, type: Float, default: 0.0

  has_many :customers
  embeds_many :channel_segment_mix, class_name: 'ChannelSegmentMix'

  DEFAULT_NAME = 'General'

  before_save :check_channel_segment_mix

  # Includes correct channel_segment_mix json
  #
  # Returns channel json representaion
  # => {"commission"=>0, "name"=>"Content marketing", "id"=>"500d3c64b0207ae64800000b",
  #     "channel_segment_mix"=>[{"distribution"=>1, "segment_id"=>"500d3c64b0207ae648000010"},
  #                             {"distribution"=>0, "segment_id"=>"500d3c64b0207ae648000011"}]}
  def as_json(options = {})
    options[:except] = [:company_id]
    super(options).merge('channel_segment_mix' => channel_segment_mix.as_json)
  end

  private

  def check_channel_segment_mix
    if channel_segment_mix.sum(:distribution) != 1
      if channel_segment_mix.present?
        errors.add :channel_segment_mix, 'Sum of channel/segment mix should be 100%'
      else
        if company.present? && company.segments.present?
          channel_segment_mix.build(segment_id: company.segments.first.id)
        end
      end
    end
  end
end