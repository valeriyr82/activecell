class Customer
  include Api::NameDocument
  include Api::BelongsCompany

  field :qbd_id, type: String
  field :qbo_id, type: String

  belongs_to :channel
  belongs_to :segment

  # Returns json with id, name, channel and segment
  # {"name"=>"Lucky Strike", "id"=>"500d3c64b0207ae648000034",
  #  "channel"=>{"...channel json..."}, "segment"=>{"...segment json..."}}
  def as_json(options = {})
    options[:only] = [:id, :name]
    super(options).merge('channel' => channel.as_json, 'segment' => segment.as_json)
  end
end
