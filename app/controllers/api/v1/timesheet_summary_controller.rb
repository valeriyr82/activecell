class Api::V1::TimesheetSummaryController < Api::BaseController

  # GET /api/v1/timesheet_summary.json
  def index
    timesheet_summary = current_company.timesheet_transactions_summary
    respond_with timesheet_summary
  end

end
