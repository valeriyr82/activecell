class Api::V1::TasksController < Api::ResourcesController

  def index
    collection.reactivate_recurring!
    respond_with(collection)
  end
  
  def create
    task = Task.new(params[:task])
    task.user_id ||= current_user.id
    task.company = current_company
    
    user = User.find(task.user_id)
    
    unless user.companies.include? current_company
      render json: { errors: { user: "Must belong to this company" } }, status: :unprocessable_entity 
      return
    end

    task.save
    
    respond_with(task, location: api_v1_task_url(task))
  end
  
  private

  def resource
    @task ||= collection.find(params[:id])
  end
end
