class Api::V1::UsersController < Api::ResourcesController

  def create
    user = User.new(params[:user])
    if user.save
      current_company.invite_user(user)
    end

    respond_with(user) do |format|
      format.json { render json: user, status: :created }
    end
  end

  def update
    raise Api::SecurityError unless resource == current_user
    resource.update_attributes(params[:user])
    respond_with(resource)
  end

  def update_password
    if resource.update_with_password(params[:user])
      sign_in(resource, :bypass => true)
    end

    respond_with(resource)
  end

  private

  def collection
    user_ids = current_company.user_affiliations.with_access.map(&:user_id)
    User.where(:id.in => user_ids)
  end

  def resource
    @user ||= collection.find(params[:id])
  end

end
