module Api::NameDocument
  extend ActiveSupport::Concern

  included do
    include Api::BaseDocument

    field :name, type: String
    validates :name, presence: true

    # TODO Re-implement handling (auto-merge, etc.)
    #   of records from different systems with the same name
    # validates :name, uniqueness: {scope: :company_id} if :company_id
    #
  end
end
