class SmartFixtures
  class Fixture
    attr_accessor :captured_data

    def initialize
      @captured_data = []
    end

    def capture(&block)
      unless captured?
        ActiveSupport::Notifications.subscribe('mongodb.insert') do |name, start, finish, id, payload|
          captured_data << [payload[:collection], payload[:documents]]
        end

        block.call

        ActiveSupport::Notifications.unsubscribe('mongodb.insert')
      else
        insert_all
      end
    end

    def captured?
      not captured_data.empty?
    end

    # insert data from the query cache
    def insert_all
      captured_data.each do |data|
        collection, documents = *data

        session = User.collection.database.session
        session[collection].insert(documents)
      end
    end
  end
end
