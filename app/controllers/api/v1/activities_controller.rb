class Api::V1::ActivitiesController < Api::ResourcesController

  def index
    activities = current_company.activities.recent
    respond_with(activities)
  end

  def create
    activity = current_company.activities.build(params[:activity])
    activity.sender = current_user

    activity.save
    respond_with(activity, location: api_v1_activity_url(activity))
  end
  
  def collection
    current_company.activities
  end

  def resource
    @activity ||= collection.find(params[:id])
  end
end
