module ETL
  module Processor
    # Public: ETL Row Processor to split 1 transaction with a credit and a 
    #   debit into 2 balancing credit and debit transactions
    #   
    #   This is part of the standard "double-entry accounting" practice. 
    #   Each transaction in the source data has a credit and a debit account,
    #   But aggregating data with awareness of both accounts in each row is 
    #   quite challenging. It is better to split to a single consistent row.
    #
    #   Per accounting standards, the amount of the credit transaction is 
    #   inverted.
    #
    # Example
    #   input: 
    #     row = {:credit_account => 'A', :debit_account => 'B', 'Amount' => 100}
    #   output:
    #     result => [
    #       {:account => 'A', :is_credit => true, :amount => -100},
    #       {:account => 'B', :is_credit => false, :amount => 100},
    #     ]
    #
    module AccountsProcessor
      extend ActiveSupport::Concern
      included do
        attr_reader :company_id
        attr_reader :credit_account
        attr_reader :debit_account
        attr_reader :lookup_class
         
        def process(row)
          account_transform = lookup_class.get_account_id_lookup
          
          # confirm first if account has already been looked up (surrogate key)
          if row[:credit_account_sk]
            credit_account_id = row[@credit_account]
          else
            credit_account_id = account_transform.transform(nil,row[@credit_account],row)
          end
          if row[:debit_account_sk]
            debit_account_id = row[@debit_account]
          else 
            debit_account_id = account_transform.transform(nil,row[@debit_account],row)
          end
          
          rows = []
          row[:amount] = (row['Amount'].to_f * 100).round
          row.reject!{|k,v| ["IsCredit", "AccountId", "Amount"].include? k}
          
          neg_amount = row[:amount] * -1
          rows << row.merge(:is_credit => 1, :account_id => credit_account_id, :amount => neg_amount )
          rows << row.merge(:is_credit => 0, :account_id => debit_account_id)
          rows
          
        end
      end
    end
  end
end
