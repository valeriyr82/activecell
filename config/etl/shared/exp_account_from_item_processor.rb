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
    module ExpAccountFromItemProcessor
      extend ActiveSupport::Concern
      included do
        attr_reader :lookup_class
         
        def process(row)
          row[:exp_account_id] = row["AccountId"]
          row[:exp_account_id] ||= row["OverrideItemAccountId"]
          if row[:exp_account_id].nil?
            @posting_type == :credit ? row[:credit_account_sk] = true : row[:debit_account_sk] = true
            product_exp_account_lookup = lookup_class.get_product_exp_account_lookup
            product_cogs_account_lookup = lookup_class.get_product_cogs_account_lookup
            product_asset_account_lookup = lookup_class.get_product_asset_account_lookup
            row[:exp_account_id] ||= product_exp_account_lookup.transform(nil, row["ItemId"], row)
            row[:exp_account_id] ||= product_cogs_account_lookup.transform(nil, row["ItemId"], row)
            row[:exp_account_id] ||= product_asset_account_lookup.transform(nil, row["ItemId"], row)
            row[:exp_account_id] ||= lookup_class::get_default_exp_account
          end

          row.reject!{|k,v| ["ExpAccountId"].include? k }
          row
        end
      end
    end
  end
end
