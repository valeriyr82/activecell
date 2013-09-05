class Api::V1::CompaniesController < Api::ResourcesController

  def create
    company = Company.new(params[:company])
    if company.save
      company.invite_user(current_user)
    end

    # location: nil because respond_with would try to fetch it from company_url
    # and we don't have such route
    respond_with(company, location: nil)
  end
  
  # POST /api/v1/companies/4fdf2a14b0207a25dd000002/create_advised_company.json
  def create_advised_company
    company = Company.new(params[:company])
    company.invite_advisor(current_company) if company.save
    respond_with(company, location: nil)
  end

  # PUT /api/v1/companies/4fdf2a14b0207a25dd000002.json
  def update
    resource.update_attributes(params[:company])
    respond_with(resource)
  end

  # Upgrades the company to advisor
  # PUT /api/v1/companies/4fdf2a14b0207a25dd000002/upgrade_to_advisor.json
  def upgrade
    updated_company = current_company.upgrade_to_advisor!
    respond_with(updated_company)
  end

  # Downgrades the company from advisor
  # PUT /api/v1/companies/4fdf2a14b0207a25dd000002/downgrade_from_advisor.json
  def downgrade
    downgraded_company = current_company.downgrade_from_advisor!
    respond_with(downgraded_company)
  end

  # DELETE /api/v1/companies/4fdf2a14b0207a25dd000002.json
  def destroy
    resource.destroy
    respond_with(resource)
  end

  # PUT /api/v1/companies/4fdf2a14b0207a25dd000002/invite_user.json
  def invite_user
    email = params[:user][:email]
    user = User.find_by_email(email)
    
    if params[:ignoreIfAdvisor] != 'true' && user.try(:is_advisor?)
      invite_advisor_by_user(params[:user])
    else
      invitation = resource.invite_user_by_email(email)

      if invitation.valid? && invitation.is_a?(CompanyInvitation)
        Notifications.company_invitation(invitation.id).deliver
      end

      response.headers['x-invitation-type'] = invitation.class.to_s
      respond_with(invitation)
    end
  end

  # PUT /api/v1/companies/4fdf2a14b0207a25dd000002/invite_advisor.json
  def invite_advisor
    if params[:company].blank?
      render json: { errors: { company: "cannot be blank" } }, status: :unprocessable_entity 
    end
    advisor_company = AdvisorCompany.find(params[:company][:id])
    invitation = resource.invite_advisor(advisor_company)
    respond_with(invitation)
  end

  # PUT /api/v1/companies/4fdf2a14b0207a25dd000002/remove_user.json
  def remove_user
    affiliation = resource.user_affiliations.where(:user_id => params[:user][:id]).first
    affiliation.destroy
    respond_with(resource)
  end
  
  # PUT /api/v1/companies/4fdf2a14b0207a25dd000002/remove_advised_company.json
  def remove_advised_company
    affiliation = resource.advised_company_affiliations.where(:company_id => params[:company][:id]).first
    affiliation.destroy
    respond_with(affiliation)
  end
  
  # GET /api/v1/companies/4fdf2a14b0207a25dd000002/users_count.json
  def users_count
    render json: resource.user_affiliations.with_access.count
  end

  private

  def collection
    current_user.companies
  end

  def resource
    @company ||= collection.find(params[:id])
  end

  def invite_advisor_by_user(user_params)
    user = User.find_by_email(user_params[:email])

    if not user.present? or not user.is_advisor?
      respond_with do |format|
        format.json do
          errors = { errors: { email: "cannot be found" } }
          render json: errors, status: :unprocessable_entity
        end
      end
      return
    end

    respond_with do |format|
      format.json do
        data = { companies: user.advisor_companies, user: user, email: user.email }
        render json: data, status: :unprocessable_entity
      end
    end
  end

end
