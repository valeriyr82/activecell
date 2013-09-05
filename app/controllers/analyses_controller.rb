class AnalysesController < Api::ResourcesController
  actions :create, :update, :destroy

  def begin_of_association_chain
    current_company.reports.find(params[:report_id])
  end
end
