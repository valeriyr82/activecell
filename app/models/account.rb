class Account
  include Api::NameDocument
  include Api::BelongsCompany

  field :type,                      type: String
  field :sub_type,                  type: String
  field :activecell_category,       type: String
  field :account_number,            type: String
  field :current_balance,           type: Integer
  field :current_balance_currency,  type: String
  field :current_balance_as_of,     type: Date
  field :is_active,                 type: Boolean
  field :qbd_id,                    type: String
  field :qbo_id,                    type: String
  field :parent_qbd_id,             type: String
  field :parent_qbo_id,             type: String
  field :description,               type: String
  field :active,                    type: String

  # optional associations
  belongs_to :revenue_stream
  belongs_to :channel
  belongs_to :category

  has_many :children_accounts, class_name: 'Account', inverse_of: :parent_account
  belongs_to :parent_account, class_name: 'Account', inverse_of: :children_accounts

  has_many :financial_transactions

  ACCOUNT_TYPES   = [
    'Asset', 'Liability', 'Equity', 
    'Revenue', 'Cost of Goods Sold', 'Expense', 'Non-Posting'
  ]
  CATEGORIES  = [
    'cash', 'non-cash',
    'short-term', 'long-term',
    'payroll', 'sales & marketing', 'other'
  ]
  
  validates_inclusion_of :type, in: ACCOUNT_TYPES
  validates_inclusion_of :activecell_category, in: CATEGORIES, allow_blank: :true

  # creates scopes for each account type
  ACCOUNT_TYPES.each do |value|
    sanitized = value.downcase
      .gsub(/[^a-zA-Z\d\-\s]/, '') # illegal chars
      .gsub(/(\s)+/, '_') # white characters
      .gsub('-', '_') # dashes
    scope sanitized.to_sym, where(:type => value)
  end
  
  # filter methods (in place of scopes)
  class << self
    def balance_sheet
      where(:type.in => ['Asset', 'Liability', 'Equity'] )
    end
    
    def profit_loss
      where(:type.in => ['Revenue', 'Cost of Goods Sold', 'Expense'])
    end
    
    def expense_cogs
      where(:type.in => ['Cost of Goods Sold', 'Expense'])
    end
    
    def posting
      where(:type != 'Non-Posting' )
    end
  end
  
  def transactions_over(range)
    financial_transactions.in_range(range)
  end

  def total_over(range)
    transactions_over(range).total_amount || 0
  end
  
  def balance_as_of(snapshot_date)
    range = snapshot_date.to_date + 1.day .. current_balance_as_of.to_date
    current_balance - total_over(range)
  end
  
end
