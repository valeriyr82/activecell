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
    class QboAccountsProcessor < ETL::Processor::RowProcessor
      include ETL::Processor::AccountsProcessor
      def initialize(control, configuration)
        @credit_account = configuration[:credit_account]
        @debit_account = configuration[:debit_account]
        @lookup_class = ETL::QBO
        super
      end
    end
  end
end
