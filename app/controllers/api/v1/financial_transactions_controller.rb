class Api::V1::FinancialTransactionsController < Api::BaseController

  # GET /api/v1/financial_transactions.json?period_id=17cc67093475061e3d95369d&&account_id=...
  def index
    financial_transactions = current_company.financial_transactions_by_params(params)
    respond_with financial_transactions
  end

end
