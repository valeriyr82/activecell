class ConversionSummary
  include Api::BaseDocument
  include Api::BelongsCompany

  field :customer_volume, type: Integer

  belongs_to :period
  belongs_to :stage
  belongs_to :channel
end
