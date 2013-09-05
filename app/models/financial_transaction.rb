class FinancialTransaction
  include Api::BaseDocument
  include Api::BelongsCompany
  include Api::SummaryDocument

  field :amount_cents,  type: Integer
  field :plug,          type: Boolean
  field :source,        type: String
  field :qbd_id,        type: String
  field :qbo_id,        type: String
  field :is_credit,     type: Boolean
  field :status,        type: String

  has_summaries sum_field: :amount_cents,
                group_by_fields: [:period_id, :account_id, :product_id, :customer_id, :employee_id, :vendor_id]
  
  belongs_to :period              
  belongs_to :account
  belongs_to :product
  belongs_to :customer
  belongs_to :employee
  belongs_to :vendor

  validates :period, presence: true
  validates :account, presence: true
  validates :amount_cents, presence: true, numericality: true
                           
  # filter methods (in place of scopes)
  class << self
    # Public: filters a set based on transaction date
    #
    # range - a Range of Date values by which to filter (inclusively)
    #
    # returns a chainable subset of FinancialTransactions
    def in_range(range)
      where(:transaction_date => range)
    end

    # Public: filters a set to those with revenue accounts
    #
    # returns a chainable subset of FinancialTransactions
    def revenue
      where(:account_id.in => Account.revenue.map(&:id))
    end
    
    # Public: filters a set to those with expense accounts
    #
    # returns a chainable subset of FinancialTransactions
    def expense
      where(:account_id.in => Account.expense.map(&:id))
    end
    
    # Public: filters a set to those with p&l accounts
    #
    # returns a chainable subset of FinancialTransactions
    def balance_sheet
      where(:account_id.in => Account.balance_sheet.map(&:id))
    end
    
    # Public: filters a set to those with balance sheet accounts
    #
    # returns a chainable subset of FinancialTransactions
    def profit_loss
      where(:account_id.in => Account.profit_loss.map(&:id))
    end
    
    # Public: filters a set to those with expense or cogs accounts
    #
    # returns a chainable subset of FinancialTransactions
    def expense_cogs
      where(:account_id.in => Account.expense_cogs.map(&:id))
    end
    
    # Public: filters a set to plug (system-generated) values
    #
    # returns a chainable subset of FinancialTransactions
    def plug
     where(:source => 'Profitably:Plug')
    end
  end
  
  # calculation methods
  class << self
    
    # Public: calculates the sum of the amount_cents field
    #
    # returns an Integer
    def total_amount
      sum(:amount_cents)
    end
  end
  
  # Public: creates a plug (system-generated) record given the provided 
  #   attributes. Note: The method will generate the transaction date (and 
  #   thus the period) if not provided, but all other required fields must
  #   be specified in the attributes hash.
  #
  # attrs - a Hash of attributes defining the plug value
  #
  # returns nothing
  def self.create_plug!(attrs)
    company = attrs[:company]
    attrs = {
      :source => 'Profitably:Plug',
      :transaction_date => Time.now.to_date
    }.merge(attrs)
    attrs[:period_id] ||= Period.find_id_by_date(attrs[:transaction_date])
    create! attrs
  end
  
end
