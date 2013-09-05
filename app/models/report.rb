class Report
  include Api::NameDocument
  include Api::BelongsCompany
  include Mongoid::Timestamps::Created

  # Report types:
  # 0 - Custom report
  # 1 - Dashboard
  field :report_type, type: Integer, default: 0
  embeds_many :analyses, class_name: 'Analysis'

  def as_json(options = {})
    options[:only] = [:id, :name, :report_type]
    super(options).merge('analyses' => analyses.as_json)
  end
end
