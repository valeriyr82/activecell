module.exports =
  getAnalysesInGroups: ->
    for analysisCategory in @groups()
      analyses = []
      for prefix in ['index', 'show']
        for analysisId, name of analysisCategory[prefix]?.analyses when !/list$/.test(analysisId)
          analyses.push {
            analysisCategory: analysisCategory.id
            analysisId: analysisId
            name: name
            prefix: prefix
          }
      name: analysisCategory.name, analyses: analyses, id: analysisCategory.id

  getName: (analysisId) ->
    names = {}
    for analysisCategory in @groups()
      _.extend names, analysisCategory.index.analyses
    names[analysisId]
  
  getObjectName: (type, id) -> 
    # if we have a complicated typeName like 'revenue_streams' or 'employee_types'
    # we should bring it to names like 'revenueStreams' and 'employeeTypes'
    curType = type.replace /(_\w)/g, (a) ->
      a[1].toUpperCase()

    app[curType]?.get(id)?.get('name')

  getItems: (type, viewType) ->
    @[type]?[viewType].analyses ? []

  groups: -> [
    @company, @products, @revenue_streams, @customers, @channels
    @segments, @employees, @employee_types, @vendors, @categories
  ]

  company:
    id: 'company'
    mainNav: 'company'
    name: 'company'
    index:
      default: 'profit_loss'
      analyses:
        cash_on_hand:     'cash on hand'
        burn_runway:      'burn & runway'
        profit_loss:      'profit & loss'
        cash_flow:        'cash flow'
        balance_sheet:    'balance sheet'
        chart_of_accts:   'chart of accounts'
        stages:           'customer acq. stages'

  products:
    id: 'products'
    mainNav: 'products'
    name: 'products'
    index:
      default: 'mrr'
      analyses:
        mrr:              'monthly recurring rev.'
        unit_sm:          'unit sales & marketing'
        breakeven:        'breakeven'
        inv_turns:        'inventory turns'
        inv_roi:          'return on inventory'
        profitability:    'profitability'
        list:             'product list'
    show:
      default: 'revenue'
      analyses:
        revenue:          'revenue'
        unit_cogs:        'unit cogs'
        customer_pareto:  'customer pareto'
        profit_loss:      'product p&l'

  revenue_streams:
    id: 'revenue_streams'
    mainNav: 'products'
    name: 'revenue streams'
    index:
      default: 'revenue'
      analyses:
        revenue:          'revenue'
        margin:           'margin'
        unit_cogs:        'unit cogs'
        items_per_txn:    'items / transaction'
        profitability:    'profitability'
        list:             'revenue stream list'
    show:
      default: 'revenue'
      analyses:
        revenue:          'revenue'
        margin:           'margin'
        unit_cogs:        'unit cogs'
        segment_pareto:   'segment pareto'
        customer_pareto:  'customer pareto'
        profit_loss:      'revenue stream p&l'

  customers:
    id: 'customers'
    mainNav: 'customers'
    name: 'customers'
    index:
      default: 'volume'
      analyses:
        volume:           'volume'
        mrr:              'mrr'
        ar_aging:         'a/r aging'
        nps:              'net promoter score'
        profitability:    'profitability'
        list:             'customer list'
    show:
      default: 'revenue'
      analyses:
        revenue:          'revenue'
        invoices_out:     'outstanding invoices'
        product_mix:      'product mix'
        purchase_profile: 'purchase profile'
        profit_loss:      'customer p&l'

  channels:
    id: 'channels'
    mainNav: 'customers'
    name: 'channels'
    index:
      default: 'roi'
      analyses:
        roi:              'sales & marketing roi'
        reach:            'reach'
        conversion:       'conversion'
        cac:              'customer acq. cost'
        profitability:    'profitability'
        list:             'channel list'
        account_mapping:  'account mapping'
    show:
      default: 'conversion'
      analyses:
        segment_mix:      'segment mix'
        reach:            'reach'
        conversion:       'conversion'
        cac:              'customer acq. cost'
        profit_loss:      'channel p&l'

  segments:
    id: 'segments'
    mainNav: 'customers'
    name: 'segments'
    index:
      default: 'churn'
      analyses:
        arpc:             'arpc'
        churn:            'churn'
        customer_equity:  'customer equity'
        return_on_cust:   'return on customer'
        profitability:    'profitability'
        list:             'segment list'
    show:
      default: 'churn'
      analyses:
        arpc:             'arpc'
        net_contribution: 'sales contribution'
        churn:            'churn'
        ltv:              'lifetime value'
        profit_loss:      'segment p&l'

  employees:
    id: 'employees'
    mainNav: 'employees'
    name: 'employees'
    index:
      default: 'revenue_per_head'
      analyses:
        revenue_per_head: 'revenue per head'
        emp_cost:         'cost of employment'
        activity_cost:    'activity cost'
        profitability:    'profitability'
        list:             'employee list'
    show:
      default: 'activity_cost'
      analyses:
        revenue:          'revenue'
        emp_cost:         'cost of employment'
        activity_cost:    'activity cost'
        utilization:      'utilization'
        profit_loss:      'employee p&l'

  employee_types:
    id: 'employee_types'
    mainNav: 'employees'
    name: 'employee types'
    index:
      default: 'staffing_plan'
      analyses:
        staffing_plan:    'staffing plan'
        team_cost:        'team cost'
        utilization:      'utilization'
        profitability:    'profitability'
        list:             'employee type list'
    show:
      default: 'demand_forecast'
      analyses:
        demand_forecast:  'demand forecasting'
        recruiting:       'recruiting funnel'
        emp_cost:         'cost of employment'
        utilization:      'utilization'
        profit_loss:      'employee type p&l'

  vendors:
    id: 'vendors'
    mainNav: 'vendors'
    name: 'vendors'
    index:
      default: 'spend'
      analyses:
        spend:            'spend'
        ap_aging:         'a/p aging'
        list:             'vendor list'
    show:
      default: 'spend'
      analyses:
        spend:            'spend'
        bills_out:        'outstanding bills'
        category_mix:     'category mix'
        item_mix:         'item mix'
        purchase_profile: 'purchase profile'

  categories:
    id: 'categories'
    mainNav: 'vendors'
    name: 'categories'
    index:
      default: 'spend'
      analyses:
        spend:            'spend'
        capex:            'capex'
        rev_share:        'revenue share'
        list:             'category list'
    show:
      default: 'demand_forecast'
      analyses:
        spend:            'spend'
        vendor_pareto:    'vendor pareto'
        demand_forecast:  'demand forecast'
        purchase_profile: 'purchase profile'
