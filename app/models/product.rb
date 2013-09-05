class Product
  include Api::NameDocument
  include Api::BelongsCompany

  field :description, type: String
  field :qbd_id,      type: String
  field :qbo_id,      type: String
  field :qbd_type,    type: String
  field :active,      type: String

  belongs_to :income_account,   class_name: 'Account'
  belongs_to :cogs_account,     class_name: 'Account'
  belongs_to :expense_account,  class_name: 'Account'
  belongs_to :asset_account,    class_name: 'Account'
  belongs_to :revenue_stream

  # Returns id, name and revenue_stream
  # {"name"=>"Affiliate revenue", "id"=>"500d3c64b0207ae648000033", "revenue_stream"=>{...revenue stream json...}}
  def as_json(options = {})
    options[:only] = [:id, :name]
    super(options).merge('revenue_stream' => revenue_stream.as_json)
  end
end
