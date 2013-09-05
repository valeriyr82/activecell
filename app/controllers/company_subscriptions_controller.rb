class CompanySubscriptionsController < ApplicationController
  protect_from_forgery except: :create

  # Generates json response with options required for create a new subscription form with Recurly.js
  # @see http://docs.recurly.com/api/recurlyjs/integration#js-new-subscriptions
  def new
    plan_code = params[:plan_code] || 'monthly'
    signature = Recurly.js.sign(subscription: { plan_code: plan_code })
    options = default_options.merge \
      success_url: company_subscriptions_url,
      signature: signature

    render json: options
  end

  # Callback for finalizing creating a subscription
  # :recurly_token is used to retrieve the result of the transaction from Recurly via the API.
  def create
    current_subscriber.update_company_subscription_by_token(params[:recurly_token])

    # TODO hide advisor plan when the company is advised
    if current_subscriber.subscription.plan_code == 'advisor_annual'
      current_company.upgrade_to_advisor!
    end

    flash[:notice] = 'Subscription was successfully created!'
    redirect_to app_url(subdomain: current_company.subdomain)
  end

  # Return options for editing billing information
  def edit
    signature = Recurly.js.sign(account: { account_code: current_subscriber.account_code })
    options = default_options.merge \
      success_url: update_billing_info_company_subscriptions_url,
      signature: signature

    render json: options
  end

  # Callback for updating billing info
  # It has to be handled by POST method, @see http://docs.recurly.com/api/recurlyjs/integration#results-overview
  def update_billing_info
    billing_info = Recurly.js.fetch(params[:recurly_token])
    logger.info billing_info

    flash[:notice] = 'Billing information was successfully updated!'
    redirect_to app_url(subdomain: current_company.subdomain)
  end

  # Action used for changing subscription plan
  def upgrade
    plan_code = params[:plan_code]
    current_subscriber.change_plan_to(plan_code)

    flash[:notice] = 'Subscription plan has been changed.'
    render json: { success: true }
  end

  # Cancel the current subscription
  def cancel
    success = current_subscriber.cancel_subscription
    render json: { success: success }
  end

  private

  # Returns a hash with default options for Recurly subscriptions
  def default_options
    recurly_settings = Settings.recurly
    {
      company_subdomain: recurly_settings.company_subdomain,
      default_currency: recurly_settings.default_currency
    }
  end

end
