class Vendor
  include Api::NameDocument
  include Api::BelongsCompany
  
  field :qbd_id, type: String
  field :qbo_id, type: String
  field :active, type: String
  
end
