module Api::SummaryDocument
  extend ActiveSupport::Concern

  included do
    field :document_type,    type: String
    field :document_id,      type: String
    field :document_line,    type: String
    field :transaction_date, type: Date

    class << self

      # Macros for define group by and sum field names
      def has_summaries(options = {})
        define_singleton_method(:sum_field) { options[:sum_field] }
        define_singleton_method(:group_by_fields) { options[:group_by_fields] }
      end

      # Aggregates transactions into summary format
      #
      # Example
      #
      #   txns.create!(period: @period_1, amount_cents: 1)
      #   txns.create!(period: @period_1, amount_cents: 5)
      #   txns.create!(period: @period_2, amount_cents: 9)
      #   txns.summary # => [
      #     {period: @period_1, amount_cents: 6}
      #     {period: @period_2, amount_cents: 9}
      #   ]
      #
      # Returns Array of Hash values containing aggregated rows
      def summary

        # Array to return once populated
        results = []
        if self.count > 0
          # Build the map function based on group by and sum fields
          map = "function(){ emit({"
          # "Pack" the unique group by fields into a hash
          map += group_by_fields.map { | group_by_field |
            "#{group_by_field.to_s}: this.#{group_by_field.to_s}"
          }.join(',')
          map += "}, {amount: this.#{sum_field.to_s}});};"

          # Reduce function is constant
          reduce = "function(key, values){
            var sum = 0;
            values.forEach(
              function(doc){
                sum += doc.amount;
              }
            );
            return {amount: sum};
          };"

          # Execute MapReduce function on whatever set of Transactions is provided
          self.map_reduce(map, reduce).out(inline: true).to_a.map do |reduce|
            # Unpack the group by fields
            hash = {}
            group_by_fields.each do |group_by_field|
              hash[group_by_field] = reduce['_id'][group_by_field.to_s] if
                reduce['_id'][group_by_field.to_s]
            end
            # Include the aggregated value
            hash[sum_field] = reduce['value']['amount']
            results << hash
          end
        end

        # Return the Array of Hash values containing the aggregated rows
        results
      end

      # Filter transaction data by params
      def by_params(params)
        query_params = {}
        group_by_fields.each do |field|
          query_params[field] = params[field] if params[field].present?
        end
        where(query_params)
      end
    end
  end
end
