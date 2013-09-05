class Api::V1::TimesheetTransactionsController < Api::BaseController

  # GET /api/v1/timesheet_transactions.json?period_id=17cc67093475061e3d95369d&employee_activity_id=...
  def index
    timesheet_transactions = current_company.timesheet_transactions_by_params(params)
    respond_with timesheet_transactions
  end

end
