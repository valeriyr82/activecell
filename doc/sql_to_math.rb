# Example posted at:
# https://docs.google.com/spreadsheet/ccc?key=0Aq6I3AMo8MZjdFN4ZHpacWxJODRjTF9vQ3FfUTVPSUE

~ Conversion forecast ~

def conversion_forecast(channel_id, segment_id, stage_id, month_id)
  if is_topline(stage_id)
    topline_forecast(channel_id, month_id) * channel_segment_mix(channel_id, segment_id)
  else
    conversion_rate(channel_id, stage_id, month_id) * conversion_forecast(channel_id, segment_id, stage_id, previous_period(month_id))
  end
end

SQL version:

-- Function: get_stage_volume_forecast(integer, integer, integer, integer)

CREATE OR REPLACE FUNCTION get_stage_volume_forecast(chnnl_id integer, t_stg_id integer, prd_id integer, cust_seg_id integer)
  RETURNS integer AS

      DECLARE
        prior_amt int4;
      BEGIN
        IF is_topline_stage(t_stg_id) THEN
        -- looking for forecast top-line figure (e.g. visitors)
        -- no conversion rate for top line, but we do split it up with
        -- segment distribution
          return coalesce(
            (
              select cast(
                amount * (
                  select distribution
                  from channel_customer_segments
                  where channel_id = chnnl_id
                  and customer_segment_id = cust_seg_id
                ) as integer
              )
              from top_line_growth_forecasts
              where month_period_id = prd_id and channel_id = chnnl_id
            ),0
          );
        ELSE
          prior_amt := coalesce((
            select amount from initial_volume_facts
            where customer_acq_stage_id = get_prior_cust_acq_stage(t_stg_id)
            and channel_id = chnnl_id
            and customer_segment_id = cust_seg_id
            and month_period_id = get_prior_forecast_period(t_stg_id, prd_id)
          ),0);
          if (prior_amt = 0) then
            prior_amt := coalesce((
              select step_increment from conversion_step_forecasts
              where customer_acq_stage_id = get_prior_cust_acq_stage(t_stg_id)
              and channel_id = chnnl_id
              and month_period_id = get_prior_forecast_period(t_stg_id, prd_id)
              and customer_segment_id = cust_seg_id
            ),0);
          end if;
          return cast(
            get_conversion_rate(chnnl_id, t_stg_id, prd_id) * prior_amt
            as integer
          );
        END IF;
      END;

~ Churn forecast ~

def churned_customer_forecast(channel_id, segment_id, month_id)
  customer_volume_forecast(channel_id, segment_id, previous_period(month_id)) *
    churn_forecast(segment_id, previous_period(month_id))
end

-- Function: get_period_churn(integer, integer, integer)

CREATE OR REPLACE FUNCTION get_period_churn(chnnl_id integer, sgmnt_id integer, prd_id integer)
  RETURNS integer AS

    -- returns forecast of churned customers for a channel/segment/period
    DECLARE
      initial_volume int4;
    BEGIN
      initial_volume := coalesce((
        select amount from initial_volume_facts
        where is_customer_stage(customer_acq_stage_id)
        and channel_id = chnnl_id
        and customer_segment_id = sgmnt_id
        and month_period_id = get_prior_period(prd_id)
      ),0);
      IF initial_volume <> 0 THEN -- looking for current period
        return coalesce(
          cast(get_churn_rate(sgmnt_id, prd_id) * (initial_volume) as integer),
          0
        );
      ELSE
        return coalesce(
          cast(get_churn_rate(sgmnt_id, prd_id)
          *   (select   amount
            from  customer_volume_forecasts
            where month_period_id = get_prior_period(prd_id)
            and   channel_id = chnnl_id
            and   customer_segment_id = sgmnt_id
          )as integer
        ),0);
      END IF;
    END;


~ Customer volume forecast ~

def customer_volume_forecast(channel_id, segment_id, month_id)
  if previous_period(month_id)) == CURRENT_MONTH
    forecast = initial_volume_forecast(channel_id, segment_id, CUSTOMER_STAGE)
  else
    forecast = customer_volume_forecast(channel_id, segment_id, previous_period(month_id))
  end
  forecast += new_customer_forecast(channel_id, segment_id, month_id)
  forecast -= churned_customer_forecast(channel_id, segment_id, month_id)
  forecast
end

SQL Version:

-- Function: get_cumulative_customers(integer, integer, integer)

CREATE OR REPLACE FUNCTION get_cumulative_customers(chnnl_id integer, sgmnt_id integer, prd_id integer)
 RETURNS integer AS

   -- returns forecast of cumulative customers for a channel/segment/period
   DECLARE
    total int4;
    initial_volume int4;
   BEGIN

    -- prior period customers
   initial_volume := coalesce((
     select amount from initial_volume_facts
     where is_customer_stage(customer_acq_stage_id)
     and channel_id = chnnl_id
     and customer_segment_id = sgmnt_id
     and month_period_id = get_prior_period(prd_id)
   ),0);
    IF initial_volume <> 0 THEN -- looking for current period
      total := initial_volume;
    ELSE
      total :=
        coalesce((  -- last period's customers
          select  amount
          from  customer_volume_forecasts
          where channel_id = chnnl_id
          and   customer_segment_id = sgmnt_id
          and   month_period_id = get_prior_period(prd_id)
        ),0);
    END IF;

    -- churned customers
    total := total - coalesce((select get_period_churn(chnnl_id, sgmnt_id, prd_id)),0);
    -- new customers
    total := total + coalesce((
      select  step_increment
      from  conversion_step_forecasts
      where   channel_id = chnnl_id
      and   customer_segment_id = sgmnt_id
      and   month_period_id = prd_id
      and   is_customer_stage(customer_acq_stage_id)
      ),0);

    return total;
   END;



