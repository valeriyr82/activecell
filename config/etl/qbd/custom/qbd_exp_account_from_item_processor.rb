module ETL
  module Processor
    # Public: ETL Row Processor to look up expense account from qbd_item
    #   
    # This processor is used by jobs that load expense facts, such as
    #   qbd_bills. The processor is essentially a hierarchy of sources
    #   for the expense account. Once the expense account is identified, 
    #   no further lookups are required. 
    #
    # If the account value is raw (source system id), row[:credit_account_sk]
    #   and row[:debit_account_sk] are left false. But if the value is a 
    #   surrogate key from our system, the field is set to true to bypass
    #   future lookups
    #
    class QbdExpAccountFromItemProcessor < ETL::Processor::RowProcessor
      include ExpAccountFromItemProcessor
      
      def initialize(control, configuration)
        @posting_type = configuration[:posting_type]
        @lookup_class = ETL::QBD
        super
      end
    end
  end
end