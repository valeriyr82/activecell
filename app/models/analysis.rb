class Analysis
  include Api::BaseDocument
  include Mongoid::Timestamps::Created

  field :type,              type: String #legacy (to-do: remove safely!)
  field :analysisId,        type: String
  field :analysisCategory,  type: String
  field :prefix,            type: String
  field :showId,            type: String
  embedded_in :report
end
