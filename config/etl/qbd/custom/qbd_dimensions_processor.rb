module ETL
  module Processor
    # Public: ETL Row Processor to perform foreign key lookup on 
    #   company-provided dimensions
    #
    class QbdDimensionsProcessor < ETL::Processor::RowProcessor
      attr_reader :company_id
      include ETL::Processor::DimensionsProcessor
      
      def initialize(control, configuration)
        @lookup_class = ETL::QBD
        super
      end
    end
  end
end
