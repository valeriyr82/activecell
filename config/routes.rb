ActiveCell::Application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'registrations',
    sessions: 'sessions',
    passwords: 'passwords'
  }

  # Mount resque server
  mount Resque::SecureServer.new, :at => "/resque"

  class AppSubdomainConstraint
    def matches?(request)
      SubdomainResolver.request_subdomain_not_reserved?(request)
    end
  end

  class LaunchpadSubdomainConstraint
    def matches?(request)
      subdomain = SubdomainResolver.current_subdomain_from(request)
      subdomain.empty? or subdomain == 'launchpad'
    end
  end

  # Application
  get '' => 'home#index', as: 'app', constraints: AppSubdomainConstraint.new
  get 'bootstrap' => 'home#bootstrap'

  # Sign in page is a default
  get '' => redirect('/users/sign_in'), subdomain: 'launchpad', as: 'root', constraints: LaunchpadSubdomainConstraint.new

  # TODO backward compatibility with UserVoice for old site, could be removed in the future
  get '/sign_in' => redirect { |params, request| "/users/sign_in?#{request.params.to_query}" }
  get '/logout' => redirect('/users/sign_out')

  match '/auth/intuit/callback' => 'intuit_companies#callback'
  resource :intuit_company, only: [] do
    collection do
      get :callback
      get :proxy
      put :disconnect
    end
  end

  match '/auth/intuit_sso/callback' => 'intuit_sessions#callback'
  match '/auth/failure' => 'intuit_sessions#failure'
  resource :intuit_session, only: [] do
    collection do
      get :callback
      get :failure
    end
  end

  resource :company_subscriptions, only: [:new, :create, :edit] do
    member do
      post :update_billing_info
      put :upgrade
      put :cancel
    end
  end

  # Reports
  resources :reports, only: [:create, :update, :destroy] do
    resources :analyses, only: [:create, :update, :destroy]
  end

  namespace :api do
    namespace :v1 do
      # Companies
      resources :accounts, except: [:new, :edit]
      resources :users, except: [:new, :edit] do
        member do
          put :update_password
        end
      end

      resources :companies, except: [:new, :edit] do
        member do
          put :invite_user
          put :remove_user

          put :upgrade
          put :downgrade

          put :invite_advisor
          put :remove_advised_company
          post :create_advised_company
          get :users_count
        end
      end

      resource :color_scheme, controller: 'color_schemes', only: [:show, :create, :update, :destroy]
      resource :company_branding, controller: 'company_brandings', only: [:update]

      # Relations
      resources :company_affiliations, only: [:index, :update],
                path: '/company/affiliations', controller: 'company/affiliations'
      resources :advised_company_affiliations, only: [:index, :update],
                path: '/company/advised_company_affiliations', controller: 'company/advised_company_affiliations'

      resources :scenarios, except: [:new, :edit]

      # Background jobs
      resources :background_jobs, only: [:create, :show] do
        collection do
          get :last
        end
      end

      # Canonical
      resources :countries, only: [:index]
      resources :employee_activities, only: [:index, :show]
      resources :industries, only: [:index, :show]
      resources :periods, only: [:index]
      # Customer
      resources :channels, except: [:new, :edit]
      resources :customers, except: [:new, :edit]
      resources :segments, except: [:new, :edit]
      resources :stages, except: [:new, :edit]
      # Employee
      resources :employees, except: [:new, :edit]
      resources :employee_types, except: [:new, :edit]
      # Products
      resources :products, except: [:new, :edit]
      resources :revenue_streams, except: [:new, :edit]
      # Vendor
      resources :categories, except: [:new, :edit]
      resources :vendors, except: [:new, :edit]
      # Activities and tasks
      resources :activities, except: [:new, :edit, :show, :update]
      resources :tasks
      
      # Historical
      resources :conversion_summary, only: [:index, :update]
      resources :documents, only: [:show]
      resources :financial_summary, only: [:index]
      resources :financial_transactions, only: [:index]
      resources :timesheet_summary, only: [:index]
      resources :timesheet_transactions, only: [:index]

      # Forecasts
      resources :churn_forecast, only: [:index, :update]
      resources :conversion_forecast, only: [:index, :update]
      resources :unit_cac_forecast, only: [:index, :update]
      resources :unit_rev_forecast, only: [:index, :update]
      resources :expense_forecasts, except: [:new, :edit]
      resources :staffing_forecasts, except: [:new, :edit]
    end
  end

  namespace :admin do
    root to: 'admin#index'
    get 'tests' => 'admin#tests'
    get 'style_guide'             => 'admin#style_guide'
    get 'style_guide/scaffolding' => 'admin#style_guide'
    get 'style_guide/base_css'    => 'admin#style_guide'
    get 'style_guide/components'  => 'admin#style_guide'
    get 'style_guide/tables'      => 'admin#style_guide'
    get 'style_guide/charts'      => 'admin#style_guide'
    get 'style_guide/air1'        => 'admin#air1'
    get 'style_guide/air2'        => 'admin#air2'
    get 'style_guide/air3'        => 'admin#air3'
    get 'style_guide/air4'        => 'admin#air4'
    get 'style_guide/air5'        => 'admin#air5'
  end
end
