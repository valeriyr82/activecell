module ETL
  module Processor
    # Public: ETL Processor to map each transaction to its balancing 
    #   transaction. See "QbdAccountsProcessor" for more information on the 
    #   double-entry bookkeeping process and how single transactions are split
    #   into 2 balancing transactions.
    #
    #   At the time of the split, no IDs are assigned because the values have 
    #   not yet been inserted into the database.
    #   
    #   TO-DO: Update for activecell and mongoid
    #
    # Example
    #   QbdAccountsProcessor input: 
    #     row = {:credit_account => 'A', :debit_account => 'B', :amount => 100}
    #   QbdAccountsProcessor output:
    #     result => [
    #       {:account => 'A', :is_credit => true, :amount => -100},
    #       {:account => 'B', :is_credit => false, :amount => 100},
    #     ]
    #   result in db:
    #     result => [
    #       {:id => '12345', :account => 'A', :is_credit => true, :amount => -100},
    #       {:id => '54321', :account => 'B', :is_credit => false, :amount => 100},
    #     ]
    #   QbdBalancingIdProcessor output:
    #     result => [
    #       {:id => '12345', :account => 'A', :is_credit => true, :amount => -100, :balancing_id => '54321'},
    #       {:id => '54321', :account => 'B', :is_credit => false, :amount => 100, :balancing_id => '12345'}
    #     ]
    #
    class QbdBalancingIdProcessor < ETL::Processor::Processor
      attr_reader :company_id
      attr_reader :source

      def initialize(control, configuration)
        @company_id = configuration[:company_id]
        @source = configuration[:source]
        super
      end
      
      def process
        # TODO Fix this.
        #         FinancialTransaction.where
        #         # Obviously this needs to be replaced!
        #         ActiveRecord::Base.connection.execute(
        #  "update  general_journal_facts
        #           set     balancing_id = gjf.id
        #           from    general_journal_facts gjf
        #           where   general_journal_facts.company_id = #{@company_id} 
        #           and     general_journal_facts.source = '#{@source}'
        #           and     general_journal_facts.company_id = gjf.company_id
        #           and     general_journal_facts.source = gjf.source
        #           and     general_journal_facts.quickbooks_id = gjf.quickbooks_id
        #           and     general_journal_facts.is_credit <> gjf.is_credit
        #           and    (general_journal_facts.balancing_id <> gjf.id
        #           or      general_journal_facts.balancing_id is null)"
        # )      
    	end
    end
  end
end
