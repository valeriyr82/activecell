class Category
  include Api::NameDocument
  include Api::BelongsCompany
  include Api::ValidateLast

  has_many :children_categories, class_name: 'Category'
  belongs_to :parent_category, class_name: 'Category'

  DEFAULT_NAME = 'General'
end
