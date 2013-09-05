# fixtures = SmartFixtures.instance
# fixtures.by_name('sample API data').capture do
# ...
# end
class SmartFixtures
  include Singleton

  attr_reader :fixtures

  def initialize
    @fixtures = {}
  end

  def find_by_name(name)
    fixtures[name.to_sym] ||= Fixture.new
    fixtures[name.to_sym]
  end

  def capture(name, &block)
    find_by_name(name).capture(&block)
  end
end
