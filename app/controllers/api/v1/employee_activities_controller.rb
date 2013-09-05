class Api::V1::EmployeeActivitiesController < Api::BaseController
  inherit_resources
  actions :index, :show
end
