require 'thor/runner'
require 'yaml'

# Load industries
puts 'Loading industries'
industries = [
  {
    name: 'Non-Profit',
    suggested_streams: ['Stream 1', 'Stream 2', 'Stream 3'],
    suggested_channels: ['Channel 1','Channel 2','Channel 3'],
    suggested_segments: ['Segment 1','Segment 2','Segment 3'],
    suggested_stages: ['Stage 1','Stage 2','Stage 3']
  },
  {
    name: 'Manufacturing',
    suggested_streams: ['Stream 1', 'Stream 2', 'Stream 3'],
    suggested_channels: ['Channel 1','Channel 2','Channel 3'],
    suggested_segments: ['Segment 1','Segment 2','Segment 3'],
    suggested_stages: ['Stage 1','Stage 2','Stage 3']
  },
  {
    name: 'Retail',
    suggested_streams: ['Stream 1', 'Stream 2', 'Stream 3'],
    suggested_channels: ['Channel 1','Channel 2','Channel 3'],
    suggested_segments: ['Segment 1','Segment 2','Segment 3'],
    suggested_stages: ['Stage 1','Stage 2','Stage 3']
  },
  {
    name: 'Services',
    suggested_streams: ['Stream 1', 'Stream 2', 'Stream 3'],
    suggested_channels: ['Channel 1','Channel 2','Channel 3'],
    suggested_segments: ['Segment 1','Segment 2','Segment 3'],
    suggested_stages: ['Stage 1','Stage 2','Stage 3']
  },
  {
    name: 'Software/Tech',
    suggested_streams: ['Stream 1', 'Stream 2', 'Stream 3'],
    suggested_channels: ['Channel 1','Channel 2','Channel 3'],
    suggested_segments: ['Segment 1','Segment 2','Segment 3'],
    suggested_stages: ['Stage 1','Stage 2','Stage 3']
  },
  {
    name: 'Hybrid of the above',
    suggested_streams: ['Stream 1', 'Stream 2', 'Stream 3'],
    suggested_channels: ['Channel 1','Channel 2','Channel 3'],
    suggested_segments: ['Segment 1','Segment 2','Segment 3'],
    suggested_stages: ['Stage 1','Stage 2','Stage 3']
  }
]

industries.each do |industry|
  Industry.find_or_create_by(industry)
end

# Load employee activities
puts 'Loading employee activities'
EmployeeActivity::NAMED_ACTIVITIES.values.each do |employee_activity|
  EmployeeActivity.find_or_create_by(name: employee_activity)
end

# Load countries
puts 'Loading countries'
countries = YAML.load_file('db/countries.yml')
countries.each do |country|
  name, code = country.keys.first(), country.values.first()
  Country.find_or_create_by(name: name, code: code)
end

# Load periods
puts 'Loading periods'
first_period = Time.now.beginning_of_month - 60.months
120.times do |time|
  Period.find_or_create_by(first_day: first_period + time.months)
end

# Load base objects
puts 'Loading base objects...'
Thor::Runner.new.sample_company 'build_one'
