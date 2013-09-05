if ENV['FACTORY_GIRL_PERFORMANCE']
  slow_factories = {}

  # Look for slow factories
  # @see: https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md#activesupport-instrumentation
  ActiveSupport::Notifications.subscribe("factory_girl.run_factory") do |name, start, finish, id, payload|
    execution_time_in_seconds = finish - start

    key = :"#{payload[:strategy]} :#{payload[:name]}"
    slow_factories[key] ||= []
    slow_factories[key] << execution_time_in_seconds
  end

  RSpec.configure do |config|
    config.after(:suite) do
      Result = Struct.new(:name, :total_time, :average_time, :calls)
      results = []

      slow_factories.each do |key, times|
        total_time = times.inject(0.0) { |sum, el| sum + el }
        average_time = total_time / times.size
        results << Result.new(key, total_time, average_time, times.size)
      end
      results.sort_by! { |result| -result.average_time }

      def print_list(items, *fields)
        # find max length for each field; start with the field names themselves
        fields = items.first.class.column_names unless fields.any?
        max_len = Hash[*fields.map { |f| [f, f.to_s.length] }.flatten]
        items.each do |item|
          fields.each do |field|
            len = item.send(field).to_s.length
            max_len[field] = len if len > max_len[field]
          end
        end

        border = '+-' + fields.map { |f| '-' * max_len[f] }.join('-+-') + '-+'
        title_row = '| ' + fields.map { |f| sprintf("%-#{max_len[f]}s", f.to_s) }.join(' | ') + ' |'

        puts border
        puts title_row
        puts border

        items.each do |item|
          row = '| ' + fields.map { |f| sprintf("%-#{max_len[f]}s", item.send(f)) }.join(' | ') + ' |'
          puts row
        end

        puts border
        puts "#{items.length} rows in set\n"
      end

      puts "\n\nTop 10 slow factories:"
      print_list(results[0..9], :name, :average_time, :total_time, :calls)
    end
  end
end
