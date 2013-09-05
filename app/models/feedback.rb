class Feedback
  include Api::BaseDocument
  include Mongoid::Timestamps

  field :active_page, type: String
  field :body, type: String

  belongs_to :user
  validates :body, presence: true
end
