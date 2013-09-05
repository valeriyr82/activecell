class Api::V1::FinancialSummaryController < Api::BaseController

  # GET /api/v1/financial_summary.json
  def index
    financial_summary = current_company.financial_transactions_summary
    respond_with financial_summary
  end

end
