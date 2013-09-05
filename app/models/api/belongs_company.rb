module Api::BelongsCompany
  extend ActiveSupport::Concern

  included do
    belongs_to :company
    
    # Default json presentaion without company_id
    def as_json(options = {})
      options[:except] = [:company_id]
      super(options)
    end
  end
end
